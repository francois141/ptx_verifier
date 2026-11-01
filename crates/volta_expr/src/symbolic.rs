//! Symbolic expressions for abstract interpretation, over the mathematical reals (the paper
//! treats floating-point values as reals for equivalence checking). Nodes live in an
//! `ExprArena` and are referred to by lightweight, copyable `ExprId` handles.

use std::fmt;
use std::sync::atomic::{AtomicU64, Ordering};

use id_collections::{IdVec, id_type};

/// Global counter for generating fresh symbol IDs
static SYMBOL_COUNTER: AtomicU64 = AtomicU64::new(0);

/// A unique identifier for a symbolic variable
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, serde::Serialize, serde::Deserialize)]
pub struct SymbolId(pub u64);

impl SymbolId {
    /// Generate a fresh symbol ID
    pub fn fresh() -> Self {
        Self(SYMBOL_COUNTER.fetch_add(1, Ordering::SeqCst))
    }
}

impl fmt::Display for SymbolId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "s{}", self.0)
    }
}

// =========================================================================
// Exact real constants
// =========================================================================

/// A NaN bit pattern tried to enter the analysis model. The model is the reals (plus ±infinity
/// for running-max/min seeds); NaN denotes no real, so every f64 ingestion point rejects it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct NanError;

impl fmt::Display for NanError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "NaN is outside the analysis model (reals)")
    }
}

impl std::error::Error for NanError {}

/// An exact extended-real constant: an arbitrary-precision rational or ±infinity (no NaN). Finite
/// f64s convert exactly, so folding coincides with the decision procedure's rational algebra.
/// The repr is boxed so `Real` is one `NonNull` pointer and `ExprNode` stays 16 bytes.
#[derive(
    Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord, serde::Serialize, serde::Deserialize,
)]
pub struct Real(Box<RealRepr>);

/// The pointed-to representation of a [`Real`]; match via [`Real::repr`]. The variant order
/// gives the derived `Ord` the extended-real order, and on the wire a serialized `Real` is
/// exactly a serialized `RealRepr` (the newtype and `Box` layers are transparent).
#[derive(
    Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord, serde::Serialize, serde::Deserialize,
)]
pub enum RealRepr {
    NegInf,
    Rational(rug::Rational),
    PosInf,
}

impl Real {
    fn from_repr(repr: RealRepr) -> Real {
        Real(Box::new(repr))
    }

    fn pos_inf() -> Real {
        Real::from_repr(RealRepr::PosInf)
    }

    fn neg_inf() -> Real {
        Real::from_repr(RealRepr::NegInf)
    }

    /// The underlying representation, for matching.
    pub fn repr(&self) -> &RealRepr {
        &self.0
    }

    /// Wrap an exact rational.
    pub fn from_rational(q: rug::Rational) -> Real {
        Real::from_repr(RealRepr::Rational(q))
    }

    /// Exact conversion. Every finite f64 converts to the exact rational it
    /// denotes; the infinities map to the extended-real infinities; NaN is
    /// an error (see [`NanError`]).
    pub fn from_f64(v: f64) -> Result<Real, NanError> {
        if v.is_nan() {
            return Err(NanError);
        }
        if v == f64::INFINITY {
            return Ok(Real::pos_inf());
        }
        if v == f64::NEG_INFINITY {
            return Ok(Real::neg_inf());
        }
        let q = rug::Rational::from_f64(v).expect("every finite f64 is an exact rational");
        Ok(Real::from_rational(q))
    }

    /// Exact conversion from an integer (no rounding, unlike `v as f64`).
    pub fn from_i64(v: i64) -> Real {
        Real::from_rational(rug::Rational::from(v))
    }

    pub fn zero() -> Real {
        Real::from_i64(0)
    }

    pub fn one() -> Real {
        Real::from_i64(1)
    }

    /// Nearest-f64 approximation (rounding; for the numeric oracle,
    /// diagnostics, and integer coercion parity - never for folding).
    pub fn to_f64(&self) -> f64 {
        match self.repr() {
            RealRepr::NegInf => f64::NEG_INFINITY,
            RealRepr::Rational(q) => q.to_f64(),
            RealRepr::PosInf => f64::INFINITY,
        }
    }

    pub fn is_zero(&self) -> bool {
        matches!(self.repr(), RealRepr::Rational(q) if q.cmp0() == std::cmp::Ordering::Equal)
    }

    pub fn is_one(&self) -> bool {
        matches!(self.repr(), RealRepr::Rational(q) if *q == 1)
    }

    pub fn is_neg_inf(&self) -> bool {
        matches!(self.repr(), RealRepr::NegInf)
    }

    pub fn is_pos_inf(&self) -> bool {
        matches!(self.repr(), RealRepr::PosInf)
    }

    /// Either infinity (the ingredients of every undefined form).
    pub fn is_infinite(&self) -> bool {
        matches!(self.repr(), RealRepr::NegInf | RealRepr::PosInf)
    }

    /// Sign as -1 / 0 / +1 (the infinities are signed; only the rational
    /// zero has sign 0).
    fn sign(&self) -> i32 {
        match self.repr() {
            RealRepr::NegInf => -1,
            RealRepr::Rational(q) => match q.cmp0() {
                std::cmp::Ordering::Less => -1,
                std::cmp::Ordering::Equal => 0,
                std::cmp::Ordering::Greater => 1,
            },
            RealRepr::PosInf => 1,
        }
    }

    // ---------------------------------------------------------------------
    // Total operations
    // ---------------------------------------------------------------------

    pub fn neg(&self) -> Real {
        match self.repr() {
            RealRepr::NegInf => Real::pos_inf(),
            RealRepr::Rational(q) => Real::from_rational(rug::Rational::from(-q)),
            RealRepr::PosInf => Real::neg_inf(),
        }
    }

    pub fn abs(&self) -> Real {
        match self.repr() {
            RealRepr::NegInf | RealRepr::PosInf => Real::pos_inf(),
            RealRepr::Rational(q) => Real::from_rational(rug::Rational::from(q.abs_ref())),
        }
    }

    /// Extended-real maximum (total: the infinities absorb/yield exactly). Returns the winning
    /// operand by reference, so callers that only inspect it never clone the rational.
    pub fn max<'a>(&'a self, other: &'a Real) -> &'a Real {
        if self >= other { self } else { other }
    }

    /// Extended-real minimum (total; borrowed like [`Real::max`]).
    pub fn min<'a>(&'a self, other: &'a Real) -> &'a Real {
        if self <= other { self } else { other }
    }

    // Partial operations: exact on the rationals and the unambiguous extended-real forms, `None`
    // on undefined ones (inf - inf, 0 * inf, inf / inf, x / 0), so the caller builds the node
    // unfolded and the decision procedure fails loudly if it reaches a VC.

    pub fn try_add(&self, other: &Real) -> Option<Real> {
        use RealRepr::*;
        match (self.repr(), other.repr()) {
            (Rational(a), Rational(b)) => Some(Real::from_rational(rug::Rational::from(a + b))),
            (PosInf, NegInf) | (NegInf, PosInf) => None, // inf - inf
            (PosInf, _) | (_, PosInf) => Some(Real::pos_inf()),
            (NegInf, _) | (_, NegInf) => Some(Real::neg_inf()),
        }
    }

    pub fn try_sub(&self, other: &Real) -> Option<Real> {
        use RealRepr::*;
        match (self.repr(), other.repr()) {
            (Rational(a), Rational(b)) => Some(Real::from_rational(rug::Rational::from(a - b))),
            (PosInf, PosInf) | (NegInf, NegInf) => None, // inf - inf
            (PosInf, _) | (_, NegInf) => Some(Real::pos_inf()),
            (NegInf, _) | (_, PosInf) => Some(Real::neg_inf()),
        }
    }

    pub fn try_mul(&self, other: &Real) -> Option<Real> {
        use RealRepr::*;
        match (self.repr(), other.repr()) {
            (Rational(a), Rational(b)) => Some(Real::from_rational(rug::Rational::from(a * b))),
            _ => {
                // At least one infinity: 0 * inf is undefined, otherwise
                // the sign rules apply (inf * nonzero, including inf * inf).
                let s = self.sign() * other.sign();
                match s {
                    0 => None,
                    s if s > 0 => Some(Real::pos_inf()),
                    _ => Some(Real::neg_inf()),
                }
            }
        }
    }

    /// Division: exact for a nonzero rational divisor. Division by zero and
    /// every form involving an infinity stay unfolded (the infinities fold
    /// only through the max/min/neg/add/mul table above).
    pub fn try_div(&self, other: &Real) -> Option<Real> {
        use RealRepr::*;
        match (self.repr(), other.repr()) {
            (Rational(a), Rational(b)) => {
                if b.cmp0() == std::cmp::Ordering::Equal {
                    None
                } else {
                    Some(Real::from_rational(rug::Rational::from(a / b)))
                }
            }
            _ => None,
        }
    }

    /// Reciprocal: exact for a nonzero rational; zero and the infinities
    /// stay unfolded (see [`Real::try_div`]).
    pub fn try_recip(&self) -> Option<Real> {
        match self.repr() {
            RealRepr::Rational(q) if q.cmp0() != std::cmp::Ordering::Equal => {
                Some(Real::from_rational(rug::Rational::from(q.recip_ref())))
            }
            _ => None,
        }
    }

    /// Fused multiply-add `a * b + c`, defined exactly when multiplying
    /// then adding is - by construction, `fma` folds iff `mul` + `add`
    /// fold, and to the same value.
    pub fn try_fma(&self, b: &Real, c: &Real) -> Option<Real> {
        self.try_mul(b)?.try_add(c)
    }
}

impl fmt::Display for Real {
    /// Prints the denoted number: values that round-trip through f64 (every source constant) print
    /// as f64s do ("42", "0.1", "-2.5"); others, reachable only via exact folds, print as "p/q".
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.repr() {
            RealRepr::NegInf => write!(f, "-inf"),
            RealRepr::PosInf => write!(f, "inf"),
            RealRepr::Rational(q) => {
                let d = q.to_f64();
                if d.is_finite() && Real::from_f64(d).as_ref() == Ok(self) {
                    write!(f, "{}", d)
                } else {
                    write!(f, "{}", q)
                }
            }
        }
    }
}

/// The identity of a symbolic atom, shared by every backend (canon, numeric oracle).
/// Only launch-config names carry identity (scoped PTX names get fresh machine
/// [`Symbol`](ExprNode::Symbol)s), and the three namespaces are disjoint by construction.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum SymbolRef<'a> {
    /// A launch-config symbolic parameter (`sym:NAME`), by config name.
    Param(&'a str),
    /// One element of a launch-config input array, by config array name
    /// and element index.
    Element { array: &'a str, index: u64 },
    /// A machine-generated `Symbol`, identified by its `SymbolId`.
    Machine(SymbolId),
}

// =========================================================================
// Arena IDs
// =========================================================================

/// A lightweight handle to an expression node in an `ExprArena`. Serde encodes the bare index,
/// meaningful only with the `ExprArena` that produced it.
#[id_type(serde = true)]
pub struct ExprId(pub u32);

/// A handle to a string stored in the arena's string table.
#[id_type(serde = true)]
pub struct StringId(pub u32);

// =========================================================================
// Expression node
// =========================================================================

/// A single expression node. Children are referenced by `ExprId`. Following the paper, tensor
/// values are modeled as real numbers.
#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum ExprNode {
    // =====================================================================
    // Atoms
    // =====================================================================
    /// Integer constant
    IntConst(i64),
    /// Exact real constant (see [`Real`]): every float constant is stored
    /// as the exact rational (or infinity) it denotes, never as an f64.
    RealConst(Real),
    /// Boolean constant (for predicates)
    BoolConst(bool),
    /// Machine-generated symbolic variable: a fresh unknown with no
    /// launch-config identity, correlated with nothing (see [`SymbolRef`]).
    Symbol(SymbolId),
    /// A launch-config symbolic parameter (`sym:NAME`), by config name.
    ParamSymbol(StringId),
    /// Element `index` of the launch-config input array named `array`.
    InputElement { array: StringId, index: u64 },

    // =====================================================================
    // Arithmetic (over reals)
    // =====================================================================
    /// Addition: a + b
    Add(ExprId, ExprId),
    /// Subtraction: a - b
    Sub(ExprId, ExprId),
    /// Multiplication: a * b
    Mul(ExprId, ExprId),
    /// Division: a / b
    Div(ExprId, ExprId),
    /// Remainder: a % b (integer remainder; uninterpreted for equivalence)
    Rem(ExprId, ExprId),
    /// Negation: -a
    Neg(ExprId),

    // =====================================================================
    // Transcendental functions
    // =====================================================================
    /// Exponential: e^a
    Exp(ExprId),
    /// Natural logarithm: ln(a)
    Log(ExprId),
    /// Square root: sqrt(a)
    Sqrt(ExprId),
    /// Reciprocal: 1/a
    Rcp(ExprId),

    // =====================================================================
    // Min/Max
    // =====================================================================
    /// Maximum: max(a, b)
    Max(ExprId, ExprId),
    /// Minimum: min(a, b)
    Min(ExprId, ExprId),
    /// Absolute value: |a|
    Abs(ExprId),
    /// Sign: -1 / 0 / +1 depending on a's sign.
    Sign(ExprId),

    // =====================================================================
    // Bitwise operations
    // =====================================================================
    /// Bitwise AND: a & b
    BitAnd(ExprId, ExprId),
    /// Bitwise OR: a | b
    BitOr(ExprId, ExprId),
    /// Bitwise XOR: a ^ b
    BitXor(ExprId, ExprId),
    /// Bitwise NOT: ~a
    BitNot(ExprId),
    /// Left shift: a << b
    Shl(ExprId, ExprId),
    /// Arithmetic right shift: a >> b (sign-extending)
    Shr(ExprId, ExprId),
    /// Logical right shift: a >>> b (zero-extending)
    LShr(ExprId, ExprId),

    // =====================================================================
    // Comparisons (return boolean expressions)
    // =====================================================================
    /// Equal: a == b
    Eq(ExprId, ExprId),
    /// Not equal: a != b
    Ne(ExprId, ExprId),
    /// Less than: a < b
    Lt(ExprId, ExprId),
    /// Less than or equal: a <= b
    Le(ExprId, ExprId),
    /// Greater than: a > b
    Gt(ExprId, ExprId),
    /// Greater than or equal: a >= b
    Ge(ExprId, ExprId),

    // =====================================================================
    // Boolean operations
    // =====================================================================
    /// Logical AND: a && b
    And(ExprId, ExprId),
    /// Logical OR: a || b
    Or(ExprId, ExprId),
    /// Logical NOT: !a
    Not(ExprId),

    // =====================================================================
    // Conditional
    // =====================================================================
    /// Select: cond ? then_val : else_val
    Select(ExprId, ExprId, ExprId),

    // =====================================================================
    // Type conversions
    // =====================================================================
    /// Convert to float (from int)
    ToFloat(ExprId),

    // =====================================================================
    // Special
    // =====================================================================
    /// Fused multiply-add: a * b + c
    Fma(ExprId, ExprId, ExprId),
    /// Symbolic read `array[index]` from a launch-config input array at a symbolic index; once
    /// `index` becomes a concrete `i`, it resolves to the lazily materialized `InputElement`.
    SymbolicRead { array: StringId, index: ExprId },
    /// Discarded per-thread value. Set during re-aggregation when static
    /// liveness analysis proves the register will be overwritten before being
    /// read. If the evaluator reads this, the liveness analysis has a bug.
    Discarded,
    /// Undefined value (for detecting use of uninitialized data)
    Undefined,
}

impl ExprNode {
    /// Whether this node is a real constant - the one case an infinity
    /// absorption rule must not treat as a finite real (see
    /// [`ExprArena::add`]).
    pub fn is_real_const(&self) -> bool {
        matches!(self, ExprNode::RealConst(_))
    }

    /// Call `f` on every child `ExprId` of this node. An exhaustive match
    /// (no wildcard) so a new variant fails to compile here instead of
    /// silently having its children skipped.
    pub fn for_each_child(&self, mut f: impl FnMut(ExprId)) {
        match self {
            ExprNode::IntConst(_)
            | ExprNode::RealConst(_)
            | ExprNode::BoolConst(_)
            | ExprNode::Symbol(_)
            | ExprNode::ParamSymbol(_)
            | ExprNode::InputElement { .. }
            | ExprNode::Discarded
            | ExprNode::Undefined => {}

            ExprNode::Neg(a)
            | ExprNode::Exp(a)
            | ExprNode::Log(a)
            | ExprNode::Sqrt(a)
            | ExprNode::Rcp(a)
            | ExprNode::Abs(a)
            | ExprNode::Sign(a)
            | ExprNode::BitNot(a)
            | ExprNode::Not(a)
            | ExprNode::ToFloat(a)
            | ExprNode::SymbolicRead { index: a, .. } => f(*a),

            ExprNode::Add(a, b)
            | ExprNode::Sub(a, b)
            | ExprNode::Mul(a, b)
            | ExprNode::Div(a, b)
            | ExprNode::Rem(a, b)
            | ExprNode::Max(a, b)
            | ExprNode::Min(a, b)
            | ExprNode::BitAnd(a, b)
            | ExprNode::BitOr(a, b)
            | ExprNode::BitXor(a, b)
            | ExprNode::Shl(a, b)
            | ExprNode::Shr(a, b)
            | ExprNode::LShr(a, b)
            | ExprNode::Eq(a, b)
            | ExprNode::Ne(a, b)
            | ExprNode::Lt(a, b)
            | ExprNode::Le(a, b)
            | ExprNode::Gt(a, b)
            | ExprNode::Ge(a, b)
            | ExprNode::And(a, b)
            | ExprNode::Or(a, b) => {
                f(*a);
                f(*b);
            }

            ExprNode::Select(a, b, c) | ExprNode::Fma(a, b, c) => {
                f(*a);
                f(*b);
                f(*c);
            }
        }
    }

    /// The `StringId` this node references, if any.
    pub fn string_id(&self) -> Option<StringId> {
        match self {
            ExprNode::ParamSymbol(sid) => Some(*sid),
            ExprNode::InputElement { array, .. } => Some(*array),
            ExprNode::SymbolicRead { array, .. } => Some(*array),
            _ => None,
        }
    }

    /// The symbol identity this node denotes, if it is a symbolic atom -
    /// the single mapping from node representation to [`SymbolRef`].
    pub fn symbol_ref<'a>(&self, arena: &'a ExprArena) -> Option<SymbolRef<'a>> {
        match self {
            ExprNode::ParamSymbol(sid) => Some(SymbolRef::Param(arena.string(*sid))),
            ExprNode::InputElement { array, index } => Some(SymbolRef::Element {
                array: arena.string(*array),
                index: *index,
            }),
            ExprNode::Symbol(sym) => Some(SymbolRef::Machine(*sym)),
            _ => None,
        }
    }
}

// =========================================================================
// Arena
// =========================================================================

/// Arena-based storage for expression nodes, referenced by copyable `ExprId` handles. The serde
/// impls are the `--dump-vcs`/`--from-dump` format: `IdVec` encodes exactly like a `Vec`,
/// serialized in place (no transient clone of GiB-scale arenas).
#[derive(serde::Serialize, serde::Deserialize)]
pub struct ExprArena {
    nodes: IdVec<ExprId, ExprNode>,
    strings: IdVec<StringId, String>,
}

impl ExprArena {
    /// Create an empty arena.
    pub fn new() -> Self {
        Self {
            nodes: IdVec::new(),
            strings: IdVec::new(),
        }
    }

    // -----------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------

    /// Push a node into the arena and return its id.
    pub(crate) fn push(&mut self, node: ExprNode) -> ExprId {
        self.nodes.push(node)
    }

    // -----------------------------------------------------------------
    // Lookup
    // -----------------------------------------------------------------

    /// Look up the node for a given id.
    pub fn node(&self, id: ExprId) -> &ExprNode {
        &self.nodes[id]
    }

    /// Number of nodes in the arena.
    pub fn node_count(&self) -> usize {
        self.nodes.len()
    }

    /// Look up a string by its id.
    pub fn string(&self, id: StringId) -> &str {
        &self.strings[id]
    }

    /// Check that every node's children precede it (which also bounds them) and every `StringId`
    /// is in range. Built arenas always pass; this guards dumps, where a forward or self-reference
    /// could cause unbounded recursion or an out-of-bounds panic deep inside a check.
    pub fn validate(&self) -> Result<(), String> {
        let n_strings = self.strings.len();
        for (id, node) in self.nodes.as_slice().iter().enumerate() {
            let mut bad_child = None;
            node.for_each_child(|child| {
                if id_collections::Id::to_index(child) as usize >= id && bad_child.is_none() {
                    bad_child = Some(child);
                }
            });
            if let Some(child) = bad_child {
                return Err(format!(
                    "node {} references child expression {}, but children must \
                     precede their parents (forward, self, or out-of-bounds \
                     reference)",
                    id,
                    id_collections::Id::to_index(child),
                ));
            }
            if let Some(sid) = node.string_id()
                && id_collections::Id::to_index(sid) as usize >= n_strings
            {
                return Err(format!(
                    "node {} references string {} but the arena has {} strings",
                    id,
                    id_collections::Id::to_index(sid),
                    n_strings
                ));
            }
        }
        Ok(())
    }

    /// Test-only back door for building arenas that violate construction
    /// invariants, to exercise `validate`.
    #[cfg(test)]
    pub(crate) fn from_raw_parts_for_test(nodes: Vec<ExprNode>, strings: Vec<String>) -> Self {
        Self {
            nodes: IdVec::from_vec(nodes),
            strings: IdVec::from_vec(strings),
        }
    }

    // -----------------------------------------------------------------
    // Atom constructors
    // -----------------------------------------------------------------

    /// Create an integer constant node.
    pub fn int(&mut self, v: i64) -> ExprId {
        self.push(ExprNode::IntConst(v))
    }

    /// Create an exact real constant node.
    pub fn real(&mut self, v: Real) -> ExprId {
        self.push(ExprNode::RealConst(v))
    }

    /// Create a real constant node from an f64, converting exactly. Fallible: NaN has no place in
    /// the reals model (see [`NanError`]), so every f64 ingestion point propagates the error.
    pub fn float_from_f64(&mut self, v: f64) -> Result<ExprId, NanError> {
        Ok(self.real(Real::from_f64(v)?))
    }

    /// Create a boolean constant node.
    pub fn bool_val(&mut self, v: bool) -> ExprId {
        self.push(ExprNode::BoolConst(v))
    }

    /// Create a fresh machine symbolic variable - the constructor for any
    /// value without a launch-config identity (see [`SymbolRef`]).
    pub fn symbol(&mut self) -> ExprId {
        self.push(ExprNode::Symbol(SymbolId::fresh()))
    }

    /// Intern a string, returning its id. Does not deduplicate; callers
    /// creating many nodes that share a string (e.g. one array's elements)
    /// should intern once and reuse the id.
    pub fn intern_string(&mut self, s: impl Into<String>) -> StringId {
        self.strings.push(s.into())
    }

    /// Create a launch-config symbolic parameter (`sym:NAME`); the name
    /// must come from the launch config (see [`SymbolRef`]).
    pub fn param_symbol(&mut self, name: impl Into<String>) -> ExprId {
        let sid = self.strings.push(name.into());
        self.push(ExprNode::ParamSymbol(sid))
    }

    /// Create the symbol for element `index` of the launch-config input
    /// array whose name is interned at `array`.
    pub fn input_element(&mut self, array: StringId, index: u64) -> ExprId {
        self.push(ExprNode::InputElement { array, index })
    }

    /// Create an undefined-value node.
    pub fn undefined(&mut self) -> ExprId {
        self.push(ExprNode::Undefined)
    }

    // =================================================================
    // Arithmetic builders (with eager constant folding)
    // =================================================================

    /// Addition with constant folding (exact on rationals; `inf + -inf` builds the node so canon
    /// fails loudly). An infinite constant also absorbs a *non-constant* (real) operand, keeping
    /// a `-INFINITY` seed out of live expressions.
    pub fn add(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_add(*y);
                return self.int(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_add(y) {
                    return self.real(r);
                }
            }
            (ExprNode::IntConst(0), _) => return b,
            (_, ExprNode::IntConst(0)) => return a,
            // A negative integer constant reads as a subtraction: `x - 1`,
            // not `x + -1` (the same polynomial to the canonicalizer).
            (_, &ExprNode::IntConst(y)) if y < 0 && y != i64::MIN => {
                let magnitude = self.int(-y);
                return self.sub(a, magnitude);
            }
            (&ExprNode::IntConst(x), _) if x < 0 && x != i64::MIN => {
                let magnitude = self.int(-x);
                return self.sub(b, magnitude);
            }
            (ExprNode::RealConst(x), _) if x.is_zero() => return b,
            (_, ExprNode::RealConst(y)) if y.is_zero() => return a,
            (ExprNode::RealConst(x), other) if x.is_infinite() && !other.is_real_const() => {
                return a;
            }
            (other, ExprNode::RealConst(y)) if y.is_infinite() && !other.is_real_const() => {
                return b;
            }
            _ => {}
        }
        self.push(ExprNode::Add(a, b))
    }

    /// Subtraction with constant folding (exact; see [`ExprArena::add`],
    /// including its infinity-absorption rule - here `-inf - x = -inf` and
    /// `x - inf = -inf` for a non-constant, hence real, `x`).
    pub fn sub(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_sub(*y);
                return self.int(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_sub(y) {
                    return self.real(r);
                }
            }
            (_, ExprNode::IntConst(0)) => return a,
            // `x - -7` reads as `x + 7` (see `add`).
            (_, &ExprNode::IntConst(y)) if y < 0 && y != i64::MIN => {
                let magnitude = self.int(-y);
                return self.add(a, magnitude);
            }
            (_, ExprNode::RealConst(y)) if y.is_zero() => return a,
            (ExprNode::RealConst(x), other) if x.is_infinite() && !other.is_real_const() => {
                return a;
            }
            (other, ExprNode::RealConst(y)) if y.is_infinite() && !other.is_real_const() => {
                let r = y.neg();
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Sub(a, b))
    }

    /// Multiplication with constant folding: `0.0 * x = 0` and `1.0 * x = x` over the reals (no
    /// IEEE `0 * inf`). Annihilation keeps `-INFINITY` running-max seeds out of live terms
    /// (`d * e^{m_0 - m_1}` with `d = 0.0` on FlashAttention's first iteration).
    pub fn mul(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_mul(*y);
                return self.int(r);
            }
            // Exact on rationals and the signed inf * nonzero forms;
            // a concrete 0 * inf builds the node unfolded (the arms below
            // must not annihilate it to 0).
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_mul(y) {
                    return self.real(r);
                }
            }
            // An integer zero annihilates like a real zero, except against a concrete
            // infinity: 0 * inf is undefined and builds the node unfolded (as `try_mul`).
            (ExprNode::IntConst(0), other) | (other, ExprNode::IntConst(0)) if !matches!(other, ExprNode::RealConst(r) if r.is_infinite()) =>
            {
                return self.int(0);
            }
            (ExprNode::RealConst(x), _) if x.is_zero() => return self.real(Real::zero()),
            (_, ExprNode::RealConst(y)) if y.is_zero() => return self.real(Real::zero()),
            (ExprNode::IntConst(1), _) => return b,
            (_, ExprNode::IntConst(1)) => return a,
            (ExprNode::RealConst(x), _) if x.is_one() => return b,
            (_, ExprNode::RealConst(y)) if y.is_one() => return a,
            _ => {}
        }
        self.push(ExprNode::Mul(a, b))
    }

    /// Division with constant folding: exact for a nonzero concrete divisor (`1.0 / 3.0` is exactly
    /// 1/3, as `rcp` and canon). `x / 0` and `0 / symbolic` stay unfolded, so a formally-zero
    /// denominator always reaches canon's loud division error.
    pub fn div(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) if *y != 0 => {
                let r = x.wrapping_div(*y);
                return self.int(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_div(y) {
                    return self.real(r);
                }
            }
            (_, ExprNode::IntConst(1)) => return a,
            _ => {}
        }
        self.push(ExprNode::Div(a, b))
    }

    /// Remainder with constant folding (i64 semantics when concrete).
    pub fn rem(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) if *y != 0 => {
                let r = x.wrapping_rem(*y);
                return self.int(r);
            }
            _ => {}
        }
        self.push(ExprNode::Rem(a, b))
    }

    /// Negation with constant folding (total on the extended reals).
    pub fn neg(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::IntConst(x) => {
                let r = x.wrapping_neg();
                return self.int(r);
            }
            ExprNode::RealConst(x) => {
                let r = x.neg();
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Neg(a))
    }

    /// Exponential: e^a. The infinite limits fold (`e^{-inf} = 0`, `e^{inf} = inf`): a running max
    /// seeded at `-INFINITY` reaches here via `ex2`, and the zero keeps the seed out of live terms.
    pub fn exp(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::RealConst(x) = self.node(a) {
            if x.is_neg_inf() {
                return self.real(Real::zero());
            }
            if x.is_pos_inf() {
                return self.real(Real::pos_inf());
            }
        }
        self.push(ExprNode::Exp(a))
    }

    /// Natural logarithm: ln(a)
    pub fn log(&mut self, a: ExprId) -> ExprId {
        self.push(ExprNode::Log(a))
    }

    /// `2^a` over the reals: `exp(a * ln 2)`, or `exp(v)` for the compilers' `exp(v)` idiom
    /// `2^(v * log2(e))`, which kernels spell with a float32 `log2(e)` (an `exp(v * 0.99999...)`
    /// over the reals) and is folded to the exact `exp(v)` it approximates.
    pub fn exp2(&mut self, a: ExprId) -> ExprId {
        if let Some(argument) = self.factor_log2e(a) {
            return self.exp(argument);
        }
        let ln2 = self.ln2_f32();
        let scaled = self.mul(a, ln2);
        self.exp(scaled)
    }

    /// `log2(a)` over the reals, as `log(a) / ln 2`, the mirror of [`Self::exp2`].
    pub fn log2(&mut self, a: ExprId) -> ExprId {
        let log = self.log(a);
        let ln2 = self.ln2_f32();
        self.div(log, ln2)
    }

    /// `ln 2` as the exact reciprocal of float32's `log2(e)`: scaled exponentials then
    /// canonicalize exactly to a spec's `exp` form and `exp2(log2(x))` cancels, where an f64
    /// `ln 2` would leave ~1e-8 error.
    fn ln2_f32(&mut self) -> ExprId {
        let log2e = Real::from_f64(f64::from(std::f64::consts::LOG2_E as f32))
            .expect("log2(e) is not NaN");
        self.real(log2e.try_recip().expect("log2(e) is nonzero"))
    }

    /// Pulls a `log2(e)`-ish constant (within float32 rounding) out of a `Mul`/`Fma`/`Add`
    /// chain, folding in each term's sign, so that `a == log2e * factor_log2e(a)`; `None` when
    /// no such factor exists.
    fn factor_log2e(&mut self, a: ExprId) -> Option<ExprId> {
        let log2e = std::f64::consts::LOG2_E;
        let is_log2e_like = |value: f64| (value.abs() - log2e).abs() <= log2e * 1e-6;
        match self.node(a).clone() {
            ExprNode::Mul(l, r) => {
                for (constant, other) in [(l, r), (r, l)] {
                    let value = match self.node(constant) {
                        ExprNode::RealConst(real) => real.to_f64(),
                        _ => continue,
                    };
                    if !is_log2e_like(value) {
                        continue;
                    }
                    return Some(if value < 0.0 { self.neg(other) } else { other });
                }
                None
            }
            ExprNode::Fma(x, c, rest) => {
                let value = match self.node(c) {
                    ExprNode::RealConst(real) => real.to_f64(),
                    _ => return None,
                };
                if !is_log2e_like(value) {
                    return None;
                }
                let x_signed = if value < 0.0 { self.neg(x) } else { x };
                let rest_factored = self.factor_log2e(rest)?;
                Some(self.add(x_signed, rest_factored))
            }
            ExprNode::Add(l, r) => {
                let l_factored = self.factor_log2e(l)?;
                let r_factored = self.factor_log2e(r)?;
                Some(self.add(l_factored, r_factored))
            }
            _ => None,
        }
    }

    /// Square root: sqrt(a)
    pub fn sqrt(&mut self, a: ExprId) -> ExprId {
        self.push(ExprNode::Sqrt(a))
    }

    /// Reciprocal: 1/a. A nonzero concrete rational folds to its exact reciprocal (consistent with
    /// `div` and canon's field model); `rcp(0)` and the infinities stay symbolic.
    pub fn rcp(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::RealConst(x) = self.node(a)
            && let Some(r) = x.try_recip()
        {
            return self.real(r);
        }
        self.push(ExprNode::Rcp(a))
    }

    /// Maximum with constant folding (exact and total on the extended
    /// reals). `max(-inf, x) = x`: running-max chains start at -INFINITY.
    pub fn max(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x.max(y);
                return self.int(r);
            }
            // Hand back the winning operand's existing node: no clone of
            // the rational, no new node (ties keep the left operand,
            // like `Real::max`).
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                return if x >= y { a } else { b };
            }
            (ExprNode::RealConst(x), _) if x.is_neg_inf() => return b,
            (_, ExprNode::RealConst(y)) if y.is_neg_inf() => return a,
            _ => {}
        }
        if a == b {
            return a;
        }
        self.push(ExprNode::Max(a, b))
    }

    /// Minimum with constant folding (exact and total on the extended
    /// reals). `min(inf, x) = x`: running-min chains start at INFINITY.
    pub fn min(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x.min(y);
                return self.int(r);
            }
            // See `max`: the winning operand's node, cloned from no one.
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                return if x <= y { a } else { b };
            }
            (ExprNode::RealConst(x), _) if x.is_pos_inf() => return b,
            (_, ExprNode::RealConst(y)) if y.is_pos_inf() => return a,
            _ => {}
        }
        if a == b {
            return a;
        }
        self.push(ExprNode::Min(a, b))
    }

    /// Absolute value with constant folding (exact; `abs(+-inf) = inf`).
    pub fn abs(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::IntConst(x) => {
                let r = x.wrapping_abs();
                return self.int(r);
            }
            ExprNode::RealConst(x) => {
                let r = x.abs();
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Abs(a))
    }

    /// Sign: always +1 or -1 (zero counts as non-positive, so `sign(0) =
    /// -1`), with constant folding on a concrete argument.
    pub fn sign(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::IntConst(x) => {
                let r = if *x > 0 { 1 } else { -1 };
                return self.int(r);
            }
            ExprNode::RealConst(x) => {
                let r = Real::from_i64(if x > &Real::zero() { 1 } else { -1 });
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Sign(a))
    }

    /// Fused multiply-add with constant folding: a * b + c, exact in the rationals. Folds iff
    /// `mul` then `add` would, to the same value, so fused and written-out forms cannot diverge.
    pub fn fma(&mut self, a: ExprId, b: ExprId, c: ExprId) -> ExprId {
        if let (ExprNode::RealConst(x), ExprNode::RealConst(y), ExprNode::RealConst(z)) =
            (self.node(a), self.node(b), self.node(c))
        {
            return match x.try_fma(y, z) {
                Some(r) => self.real(r),
                // An undefined extended-real form (0 * inf, inf - inf):
                // build the node unfolded, skipping the zero identity below.
                None => self.push(ExprNode::Fma(a, b, c)),
            };
        }
        let zero_a = matches!(self.node(a), ExprNode::IntConst(0))
            || matches!(self.node(a), ExprNode::RealConst(x) if x.is_zero());
        let zero_b = matches!(self.node(b), ExprNode::IntConst(0))
            || matches!(self.node(b), ExprNode::RealConst(y) if y.is_zero());
        let inf_a = matches!(self.node(a), ExprNode::RealConst(x) if x.is_infinite());
        let inf_b = matches!(self.node(b), ExprNode::RealConst(y) if y.is_infinite());
        // The zero identity must not swallow an undefined 0 * inf: mixed forms (integer
        // zero, or a non-real addend) skip `try_fma` and must stay unfolded (see `mul`).
        if (zero_a && !inf_b) || (zero_b && !inf_a) {
            return c;
        }
        self.push(ExprNode::Fma(a, b, c))
    }

    /// Symbolic read `array_name[index]` from a launch-config input array: a concrete index
    /// resolves at once to its `InputElement`, else a `SymbolicRead` resolves on TID substitution.
    /// Negative concrete indices wrap into `u64` uniformly (they can't collide with real elements).
    pub fn symbolic_read(&mut self, array_name: &str, index: ExprId) -> ExprId {
        let sid = self.strings.push(array_name.to_string());
        // Eagerly resolve if index is concrete
        if let Some(i) = self.as_i64(index) {
            return self.input_element(sid, i as u64);
        }
        self.push(ExprNode::SymbolicRead { array: sid, index })
    }

    // =================================================================
    // Bitwise builders (with eager constant folding)
    // =================================================================

    /// Bitwise AND with constant folding.
    pub fn bit_and(&mut self, a: ExprId, b: ExprId) -> ExprId {
        if let (ExprNode::IntConst(x), ExprNode::IntConst(y)) = (self.node(a), self.node(b)) {
            let r = *x & *y;
            return self.int(r);
        }
        self.push(ExprNode::BitAnd(a, b))
    }

    /// Bitwise OR with constant folding.
    pub fn bit_or(&mut self, a: ExprId, b: ExprId) -> ExprId {
        if let (ExprNode::IntConst(x), ExprNode::IntConst(y)) = (self.node(a), self.node(b)) {
            let r = *x | *y;
            return self.int(r);
        }
        self.push(ExprNode::BitOr(a, b))
    }

    /// Bitwise XOR with constant folding.
    pub fn bit_xor(&mut self, a: ExprId, b: ExprId) -> ExprId {
        if let (ExprNode::IntConst(x), ExprNode::IntConst(y)) = (self.node(a), self.node(b)) {
            let r = *x ^ *y;
            return self.int(r);
        }
        self.push(ExprNode::BitXor(a, b))
    }

    /// Bitwise NOT with constant folding.
    pub fn bit_not(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::IntConst(x) = *self.node(a) {
            return self.int(!x);
        }
        self.push(ExprNode::BitNot(a))
    }

    /// Left shift with constant folding.
    pub fn shl(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_shl(*y as u32);
                return self.int(r);
            }
            (_, ExprNode::IntConst(0)) => return a,
            _ => {}
        }
        self.push(ExprNode::Shl(a, b))
    }

    /// Arithmetic right shift with constant folding.
    pub fn shr(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_shr(*y as u32);
                return self.int(r);
            }
            (_, ExprNode::IntConst(0)) => return a,
            _ => {}
        }
        self.push(ExprNode::Shr(a, b))
    }

    /// Logical right shift with constant folding.
    pub fn lshr(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = (*x as u64).wrapping_shr(*y as u32) as i64;
                return self.int(r);
            }
            (_, ExprNode::IntConst(0)) => return a,
            (ExprNode::IntConst(0), _) => return self.int(0),
            _ => {}
        }
        self.push(ExprNode::LShr(a, b))
    }

    // =================================================================
    // Comparison builders (with eager constant folding)
    // =================================================================

    /// Equal with constant folding (exact rational comparison; over the
    /// extended reals equality of concrete constants is decidable, unlike
    /// IEEE where `-0.0 == 0.0` and NaN muddy it - both are out of model).
    pub fn eq(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x == *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = x == y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Eq(a, b))
    }

    /// Not-equal with constant folding (exact; see [`ExprArena::eq`]).
    pub fn ne(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x != *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = x != y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Ne(a, b))
    }

    /// Less-than with constant folding (exact extended-real order).
    pub fn lt(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x < *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x < *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Lt(a, b))
    }

    /// Less-or-equal with constant folding (exact extended-real order).
    pub fn le(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x <= *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x <= *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Le(a, b))
    }

    /// Greater-than with constant folding (exact extended-real order).
    pub fn gt(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x > *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x > *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Gt(a, b))
    }

    /// Greater-or-equal with constant folding (exact extended-real order).
    pub fn ge(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x >= *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x >= *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Ge(a, b))
    }

    // =================================================================
    // Boolean builders
    // =================================================================

    /// Logical AND.
    pub fn and(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.push(ExprNode::And(a, b))
    }

    /// Logical OR.
    pub fn or(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.push(ExprNode::Or(a, b))
    }

    /// Logical NOT.
    pub fn not(&mut self, a: ExprId) -> ExprId {
        self.push(ExprNode::Not(a))
    }

    // =================================================================
    // Conditional (with eager folding on concrete condition)
    // =================================================================

    /// Select: cond ? then_val : else_val
    pub fn select(&mut self, cond: ExprId, then_val: ExprId, else_val: ExprId) -> ExprId {
        match self.as_bool(cond) {
            Some(true) => return then_val,
            Some(false) => return else_val,
            None => {}
        }
        if let Some(id) = self.try_fold_sign_select(cond, then_val, else_val) {
            return id;
        }
        self.push(ExprNode::Select(cond, then_val, else_val))
    }

    /// Fold the `setp.{gt,neu}` + `selp` + `selp` signed-step idiom `(v != 0) ? ((v > 0) ? c : -c)
    /// : 0` (same `v` by `ExprId`) to `sign(v) * c`, so a `.spec` file's `sign()` and the compiled
    /// branch canonicalize to one atom rather than unmatchable opaque `Select`s.
    fn try_fold_sign_select(
        &mut self,
        cond: ExprId,
        then_val: ExprId,
        else_val: ExprId,
    ) -> Option<ExprId> {
        let &ExprNode::Ne(v, zero_v) = self.node(cond) else {
            return None;
        };
        if !self.is_zero_const(zero_v) || !self.is_zero_const(else_val) {
            return None;
        }
        let &ExprNode::Select(inner_cond, a, b) = self.node(then_val) else {
            return None;
        };
        let &ExprNode::Gt(v2, zero2) = self.node(inner_cond) else {
            return None;
        };
        if v2 != v || !self.is_zero_const(zero2) {
            return None;
        }
        let (ExprNode::RealConst(ca), ExprNode::RealConst(cb)) = (self.node(a), self.node(b))
        else {
            return None;
        };
        if ca.is_zero() || ca.neg() != cb.clone() {
            return None;
        }
        let c = ca.clone();
        let sign_v = self.sign(v);
        let c_id = self.real(c);
        Some(self.mul(sign_v, c_id))
    }

    /// Whether `id` is the exact constant zero (int or real).
    fn is_zero_const(&self, id: ExprId) -> bool {
        match self.node(id) {
            ExprNode::IntConst(0) => true,
            ExprNode::RealConst(x) => x.is_zero(),
            _ => false,
        }
    }

    // =================================================================
    // Conversions
    // =================================================================

    /// Convert to float (from int), with constant folding. The fold is
    /// exact (an i64 converts to the rational it denotes, not to the
    /// nearest f64), matching canon's identity treatment of `ToFloat`.
    pub fn to_float(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::IntConst(v) = *self.node(a) {
            return self.real(Real::from_i64(v));
        }
        self.push(ExprNode::ToFloat(a))
    }

    // =================================================================
    // Query methods
    // =================================================================

    /// Try to evaluate as a concrete i64. Real constants coerce through the nearest f64 with `as`
    /// semantics (truncating, saturating); a real used as an integer is never exact anyway.
    pub fn as_i64(&self, id: ExprId) -> Option<i64> {
        match self.node(id) {
            ExprNode::IntConst(v) => Some(*v),
            ExprNode::RealConst(v) => Some(v.to_f64() as i64),
            ExprNode::BoolConst(b) => Some(if *b { 1 } else { 0 }),
            _ => None,
        }
    }

    /// Try to read an integer constant. Unlike [`Self::as_i64`] this does not coerce float or
    /// bool constants, so value-boundary canonicalization leaves bit-moved floats
    /// (`mov.b32 %r, %f`) untouched.
    pub fn as_int_const(&self, id: ExprId) -> Option<i64> {
        match self.node(id) {
            ExprNode::IntConst(v) => Some(*v),
            _ => None,
        }
    }

    /// Try to evaluate as a concrete u64 (see [`Self::as_i64`] for the
    /// real-constant coercion).
    pub fn as_u64(&self, id: ExprId) -> Option<u64> {
        match self.node(id) {
            ExprNode::IntConst(v) => Some(*v as u64),
            ExprNode::RealConst(v) => Some(v.to_f64() as u64),
            ExprNode::BoolConst(b) => Some(if *b { 1 } else { 0 }),
            _ => None,
        }
    }

    /// Try to evaluate as a concrete f64 (rounding: real constants are
    /// exact rationals; this is a diagnostic approximation, never fold
    /// input).
    pub fn as_f64(&self, id: ExprId) -> Option<f64> {
        match self.node(id) {
            ExprNode::IntConst(v) => Some(*v as f64),
            ExprNode::RealConst(v) => Some(v.to_f64()),
            _ => None,
        }
    }

    /// Try to evaluate as a concrete bool.
    pub fn as_bool(&self, id: ExprId) -> Option<bool> {
        match self.node(id) {
            ExprNode::BoolConst(b) => Some(*b),
            ExprNode::IntConst(v) => Some(*v != 0),
            _ => None,
        }
    }

    /// Check if this is a concrete value (int, real, or bool constant).
    pub fn is_concrete(&self, id: ExprId) -> bool {
        matches!(
            self.node(id),
            ExprNode::IntConst(_) | ExprNode::RealConst(_) | ExprNode::BoolConst(_)
        )
    }

    /// Check if this is an undefined value.
    pub fn is_undefined(&self, id: ExprId) -> bool {
        matches!(self.node(id), ExprNode::Undefined)
    }

    /// Check if this is a discarded value (from re-aggregation).
    pub fn is_discarded(&self, id: ExprId) -> bool {
        matches!(self.node(id), ExprNode::Discarded)
    }

    /// Create a discarded-value node.
    pub fn discarded(&mut self) -> ExprId {
        self.push(ExprNode::Discarded)
    }

    // =================================================================
    // Display
    // =================================================================

    /// Format an expression to the given formatter, using a stacker guard
    /// to handle deep recursion.
    pub fn fmt_expr(&self, id: ExprId, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        stacker::maybe_grow(64 * 1024, 8 * 1024 * 1024, || self.fmt_expr_inner(id, f))
    }

    fn fmt_expr_inner(&self, id: ExprId, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.node(id) {
            ExprNode::IntConst(v) => write!(f, "{}", v),
            ExprNode::RealConst(v) => write!(f, "{}", v),
            ExprNode::BoolConst(b) => write!(f, "{}", b),
            ExprNode::Symbol(sid) => write!(f, "{}", sid),
            ExprNode::ParamSymbol(sid) => write!(f, "{}", self.string(*sid)),
            ExprNode::InputElement { array, index } => {
                write!(f, "{}[{}]", self.string(*array), index)
            }
            ExprNode::Add(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " + ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Sub(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " - ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Mul(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " * ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Div(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " / ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Rem(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " % ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Neg(a) => {
                write!(f, "(-")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Exp(a) => {
                write!(f, "exp(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Log(a) => {
                write!(f, "log(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Sqrt(a) => {
                write!(f, "sqrt(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Rcp(a) => {
                write!(f, "rcp(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Max(a, b) => {
                write!(f, "max(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Min(a, b) => {
                write!(f, "min(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Abs(a) => {
                write!(f, "abs(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Sign(a) => {
                write!(f, "sign(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::BitAnd(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " & ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::BitOr(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " | ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::BitXor(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " ^ ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::BitNot(a) => {
                write!(f, "(~")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Shl(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " << ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Shr(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " >> ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::LShr(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " >>> ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Eq(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " == ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Ne(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " != ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Lt(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " < ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Le(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " <= ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Gt(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " > ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Ge(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " >= ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::And(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " && ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Or(a, b) => {
                write!(f, "(")?;
                self.fmt_expr(*a, f)?;
                write!(f, " || ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ")")
            }
            ExprNode::Not(a) => {
                write!(f, "(!")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Select(c, t, e) => {
                write!(f, "(")?;
                self.fmt_expr(*c, f)?;
                write!(f, " ? ")?;
                self.fmt_expr(*t, f)?;
                write!(f, " : ")?;
                self.fmt_expr(*e, f)?;
                write!(f, ")")
            }
            ExprNode::ToFloat(a) => {
                write!(f, "float(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ")")
            }
            ExprNode::Fma(a, b, c) => {
                write!(f, "fma(")?;
                self.fmt_expr(*a, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*b, f)?;
                write!(f, ", ")?;
                self.fmt_expr(*c, f)?;
                write!(f, ")")
            }
            ExprNode::SymbolicRead { array, index } => {
                write!(f, "{}[", self.string(*array))?;
                self.fmt_expr(*index, f)?;
                write!(f, "]")
            }
            ExprNode::Discarded => write!(f, "discarded"),
            ExprNode::Undefined => write!(f, "undefined"),
        }
    }

    /// Format an expression to a `String`. `fmt_expr` re-walks shared subexpressions (no memo), so
    /// heavily shared DAGs can print exponentially large text (multi-GB for tensor-core chains);
    /// past `MAX_DISPLAY_BYTES` this returns a short placeholder instead.
    pub fn display_expr(&self, id: ExprId) -> String {
        const MAX_DISPLAY_BYTES: usize = 50 * 1024 * 1024;

        match self.display_bounded(id, MAX_DISPLAY_BYTES) {
            Ok(text) => text,
            Err(_) => format!(
                "<expression exceeds {}MB when printed - likely heavy internal \
                 sharing in this unmemoized display path; pass --print-outputs 0 \
                 to skip printing, or use 'volta verify'/'volta compare', which \
                 check equivalence without ever formatting raw expressions>",
                MAX_DISPLAY_BYTES / (1024 * 1024)
            ),
        }
    }

    /// At most the first `max_bytes` of the expression's text, ending in `…` when cut: unlike
    /// [`Self::display_expr`], a cut costs only the bytes kept.
    pub fn display_expr_prefix(&self, id: ExprId, max_bytes: usize) -> String {
        match self.display_bounded(id, max_bytes) {
            Ok(text) => text,
            Err(mut prefix) => {
                prefix.push('…');
                prefix
            }
        }
    }

    /// The expression's text, or the prefix that fit in `max_bytes` (cut at a char boundary).
    fn display_bounded(&self, id: ExprId, max_bytes: usize) -> Result<String, String> {
        use std::fmt::Write;

        struct ExprDisplay<'a> {
            arena: &'a ExprArena,
            id: ExprId,
        }
        impl fmt::Display for ExprDisplay<'_> {
            fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
                self.arena.fmt_expr(self.id, f)
            }
        }

        // A byte-budgeted `fmt::Write` sink: exceeding the budget mid-traversal
        // short-circuits `fmt_expr`'s whole walk via `?`, never materializing the full string.
        struct LimitedWriter {
            buf: String,
            remaining: usize,
        }
        impl fmt::Write for LimitedWriter {
            fn write_str(&mut self, s: &str) -> fmt::Result {
                if s.len() > self.remaining {
                    let mut cut = self.remaining;
                    while !s.is_char_boundary(cut) {
                        cut -= 1;
                    }
                    self.buf.push_str(&s[..cut]);
                    self.remaining = 0;
                    return Err(fmt::Error);
                }
                self.remaining -= s.len();
                self.buf.push_str(s);
                Ok(())
            }
        }

        let mut writer = LimitedWriter {
            buf: String::new(),
            remaining: max_bytes,
        };
        match write!(writer, "{}", ExprDisplay { arena: self, id }) {
            Ok(()) => Ok(writer.buf),
            Err(_) => Err(writer.buf),
        }
    }
}

impl Default for ExprArena {
    fn default() -> Self {
        Self::new()
    }
}

impl fmt::Debug for ExprArena {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ExprArena")
            .field("num_nodes", &self.nodes.count().to_value())
            .field("num_strings", &self.strings.count().to_value())
            .finish()
    }
}

impl Clone for ExprArena {
    fn clone(&self) -> Self {
        Self {
            nodes: self.nodes.clone(),
            strings: self.strings.clone(),
        }
    }
}

/// Check structural equality of two expressions across different arenas, walking both trees
/// in lockstep and comparing node variants and leaf values.
pub fn structurally_equal(a_arena: &ExprArena, a: ExprId, b_arena: &ExprArena, b: ExprId) -> bool {
    stacker::maybe_grow(64 * 1024, 8 * 1024 * 1024, || {
        structurally_equal_inner(a_arena, a, b_arena, b)
    })
}

fn structurally_equal_inner(
    a_arena: &ExprArena,
    a: ExprId,
    b_arena: &ExprArena,
    b: ExprId,
) -> bool {
    use ExprNode::*;
    match (a_arena.node(a), b_arena.node(b)) {
        (IntConst(x), IntConst(y)) => x == y,
        (RealConst(x), RealConst(y)) => x == y,
        (BoolConst(x), BoolConst(y)) => x == y,
        (Symbol(x), Symbol(y)) => x == y,
        (ParamSymbol(x), ParamSymbol(y)) => a_arena.string(*x) == b_arena.string(*y),
        (
            InputElement {
                array: xa,
                index: xi,
            },
            InputElement {
                array: ya,
                index: yi,
            },
        ) => xi == yi && a_arena.string(*xa) == b_arena.string(*ya),
        (Undefined, Undefined) => true,

        // Binary ops
        (Add(a1, a2), Add(b1, b2))
        | (Sub(a1, a2), Sub(b1, b2))
        | (Mul(a1, a2), Mul(b1, b2))
        | (Div(a1, a2), Div(b1, b2))
        | (Rem(a1, a2), Rem(b1, b2))
        | (Max(a1, a2), Max(b1, b2))
        | (Min(a1, a2), Min(b1, b2))
        | (BitAnd(a1, a2), BitAnd(b1, b2))
        | (BitOr(a1, a2), BitOr(b1, b2))
        | (BitXor(a1, a2), BitXor(b1, b2))
        | (Shl(a1, a2), Shl(b1, b2))
        | (Shr(a1, a2), Shr(b1, b2))
        | (LShr(a1, a2), LShr(b1, b2))
        | (Eq(a1, a2), Eq(b1, b2))
        | (Ne(a1, a2), Ne(b1, b2))
        | (Lt(a1, a2), Lt(b1, b2))
        | (Le(a1, a2), Le(b1, b2))
        | (Gt(a1, a2), Gt(b1, b2))
        | (Ge(a1, a2), Ge(b1, b2))
        | (And(a1, a2), And(b1, b2))
        | (Or(a1, a2), Or(b1, b2)) => {
            structurally_equal(a_arena, *a1, b_arena, *b1)
                && structurally_equal(a_arena, *a2, b_arena, *b2)
        }

        // Unary ops
        (Neg(a1), Neg(b1))
        | (Exp(a1), Exp(b1))
        | (Log(a1), Log(b1))
        | (Sqrt(a1), Sqrt(b1))
        | (Rcp(a1), Rcp(b1))
        | (Abs(a1), Abs(b1))
        | (BitNot(a1), BitNot(b1))
        | (Not(a1), Not(b1))
        | (ToFloat(a1), ToFloat(b1)) => structurally_equal(a_arena, *a1, b_arena, *b1),

        // Ternary ops
        (Fma(a1, a2, a3), Fma(b1, b2, b3)) | (Select(a1, a2, a3), Select(b1, b2, b3)) => {
            structurally_equal(a_arena, *a1, b_arena, *b1)
                && structurally_equal(a_arena, *a2, b_arena, *b2)
                && structurally_equal(a_arena, *a3, b_arena, *b3)
        }

        // Discarded values are structurally equal to each other
        (Discarded, Discarded) => true,

        // Symbolic array read
        (
            SymbolicRead {
                array: a1,
                index: i1,
            },
            SymbolicRead {
                array: a2,
                index: i2,
            },
        ) => {
            a_arena.string(*a1) == b_arena.string(*a2)
                && structurally_equal(a_arena, *i1, b_arena, *i2)
        }

        _ => false,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_constant_folding() {
        let mut arena = ExprArena::new();

        // Integer arithmetic
        let a = arena.int(3);
        let b = arena.int(4);
        let e = arena.add(a, b);
        assert_eq!(arena.as_i64(e), Some(7));

        let a = arena.int(10);
        let b = arena.int(3);
        let e = arena.sub(a, b);
        assert_eq!(arena.as_i64(e), Some(7));

        let a = arena.int(3);
        let b = arena.int(4);
        let e = arena.mul(a, b);
        assert_eq!(arena.as_i64(e), Some(12));

        // Shifts
        let a = arena.int(1);
        let b = arena.int(4);
        let e = arena.shl(a, b);
        assert_eq!(arena.as_i64(e), Some(16));

        // Bitwise
        let a = arena.int(0xFF);
        let b = arena.int(0x0F);
        let e = arena.bit_and(a, b);
        assert_eq!(arena.as_i64(e), Some(0x0F));
    }

    #[test]
    fn test_identity_simplification() {
        let mut arena = ExprArena::new();

        // x + 0 = x
        let x = arena.symbol();
        let zero = arena.int(0);
        let e = arena.add(x, zero);
        assert_eq!(e, x);

        // 0 + x = x
        let x = arena.symbol();
        let zero = arena.int(0);
        let e = arena.add(zero, x);
        assert_eq!(e, x);

        // x * 1 = x
        let x = arena.symbol();
        let one = arena.int(1);
        let e = arena.mul(x, one);
        assert_eq!(e, x);

        // 1 * x = x
        let x = arena.symbol();
        let one = arena.int(1);
        let e = arena.mul(one, x);
        assert_eq!(e, x);

        // x - 0 = x
        let x = arena.symbol();
        let zero = arena.int(0);
        let e = arena.sub(x, zero);
        assert_eq!(e, x);

        // x / 1 = x
        let x = arena.symbol();
        let one = arena.int(1);
        let e = arena.div(x, one);
        assert_eq!(e, x);
    }

    #[test]
    fn test_logical_shift_right() {
        let mut arena = ExprArena::new();

        // 128 >>> 1 = 64
        let a = arena.int(128);
        let b = arena.int(1);
        let e = arena.lshr(a, b);
        assert_eq!(arena.as_i64(e), Some(64));

        // -1 >>> 1 should be a large positive number (logical shift)
        let a = arena.int(-1);
        let b = arena.int(1);
        let e = arena.lshr(a, b);
        assert_eq!(arena.as_i64(e), Some(i64::MAX));

        // Nested: (128 >>> 1) << 2 = 256
        let a = arena.int(128);
        let b = arena.int(1);
        let c = arena.int(2);
        let step1 = arena.lshr(a, b);
        let e = arena.shl(step1, c);
        assert_eq!(arena.as_i64(e), Some(256));
    }

    #[test]
    fn test_div() {
        let mut arena = ExprArena::new();

        // 10 / 3 = 3 (eager folding in constructor)
        let a = arena.int(10);
        let b = arena.int(3);
        let e = arena.div(a, b);
        assert_eq!(arena.as_i64(e), Some(3));

        // 10.0 / 2.0 = 5.0
        let a = arena.float_from_f64(10.0).unwrap();
        let b = arena.float_from_f64(2.0).unwrap();
        let e = arena.div(a, b);
        assert_eq!(arena.as_f64(e), Some(5.0));
    }

    #[test]
    fn test_node_lookup() {
        let mut arena = ExprArena::new();

        let a = arena.int(42);
        assert_eq!(arena.node(a), &ExprNode::IntConst(42));

        let b = arena.float_from_f64(2.5).unwrap();
        assert_eq!(
            arena.node(b),
            &ExprNode::RealConst(Real::from_f64(2.5).unwrap())
        );

        let c = arena.bool_val(true);
        assert_eq!(arena.node(c), &ExprNode::BoolConst(true));

        let d = arena.param_symbol("alpha");
        if let ExprNode::ParamSymbol(sid) = arena.node(d) {
            assert_eq!(arena.string(*sid), "alpha");
        } else {
            panic!("expected ParamSymbol");
        }

        let sid = arena.intern_string("input");
        let e = arena.input_element(sid, 0);
        assert!(matches!(
            arena.node(e),
            ExprNode::InputElement { array, index: 0 } if arena.string(*array) == "input"
        ));

        let u = arena.undefined();
        assert_eq!(arena.node(u), &ExprNode::Undefined);
    }

    #[test]
    fn test_query_methods() {
        let mut arena = ExprArena::new();

        let i = arena.int(10);
        assert_eq!(arena.as_i64(i), Some(10));
        assert_eq!(arena.as_u64(i), Some(10));
        assert_eq!(arena.as_f64(i), Some(10.0));
        assert_eq!(arena.as_bool(i), Some(true));
        assert!(arena.is_concrete(i));
        assert!(!arena.is_undefined(i));

        let f = arena.float_from_f64(2.5).unwrap();
        assert_eq!(arena.as_f64(f), Some(2.5));
        assert!(arena.is_concrete(f));

        let b = arena.bool_val(false);
        assert_eq!(arena.as_bool(b), Some(false));
        assert!(arena.is_concrete(b));

        let s = arena.symbol();
        assert!(!arena.is_concrete(s));
        assert!(arena.as_i64(s).is_none());

        let u = arena.undefined();
        assert!(arena.is_undefined(u));
        assert!(!arena.is_concrete(u));
    }

    #[test]
    fn test_select_folding() {
        let mut arena = ExprArena::new();

        let t = arena.bool_val(true);
        let a = arena.int(1);
        let b = arena.int(2);
        let e = arena.select(t, a, b);
        assert_eq!(e, a);

        let f = arena.bool_val(false);
        let c = arena.int(3);
        let d = arena.int(4);
        let e = arena.select(f, c, d);
        assert_eq!(e, d);
    }

    #[test]
    fn test_select_folds_sign_idiom() {
        let mut arena = ExprArena::new();

        // (v != 0) ? ((v > 0) ? c : -c) : 0, the setp+selp+selp pattern
        // nvcc/Triton emit for a signed step - should fold to sign(v) * c.
        let v = arena.symbol();
        let zero = arena.int(0);
        let c = arena.float_from_f64(-0.0001).unwrap();
        let neg_c = arena.float_from_f64(0.0001).unwrap();

        let is_positive = arena.gt(v, zero);
        let inner = arena.select(is_positive, c, neg_c);
        let is_nonzero = arena.ne(v, zero);
        let folded = arena.select(is_nonzero, inner, zero);

        let &ExprNode::Mul(sign_id, c_id) = arena.node(folded) else {
            panic!("expected sign(v) * c, got {:?}", arena.node(folded));
        };
        assert!(matches!(arena.node(sign_id), ExprNode::Sign(inner) if *inner == v));
        let (ExprNode::RealConst(folded_c), ExprNode::RealConst(orig_c)) =
            (arena.node(c_id), arena.node(c))
        else {
            panic!("expected the folded multiplier to stay a real constant");
        };
        assert_eq!(folded_c, orig_c);

        // A mismatched second branch (not the negation of the first) must
        // not fold - it isn't the sign idiom.
        let mut arena = ExprArena::new();
        let v = arena.symbol();
        let zero = arena.int(0);
        let c = arena.float_from_f64(-0.0001).unwrap();
        let other = arena.float_from_f64(0.5).unwrap();
        let is_positive = arena.gt(v, zero);
        let inner = arena.select(is_positive, c, other);
        let is_nonzero = arena.ne(v, zero);
        let not_folded = arena.select(is_nonzero, inner, zero);
        assert!(matches!(arena.node(not_folded), ExprNode::Select(..)));
    }

    #[test]
    fn test_display() {
        let mut arena = ExprArena::new();

        let a = arena.int(3);
        let b = arena.int(4);
        let e = arena.add(a, b);
        // Constant folding means this is just "7"
        assert_eq!(arena.display_expr(e), "7");

        // Build a symbolic expression: (x + 1)
        let x = arena.symbol();
        let one = arena.int(1);
        let e = arena.add(x, one);
        let s = arena.display_expr(e);
        // Should contain " + 1" and parentheses
        assert!(s.contains(" + "));
        assert!(s.contains("1"));
    }

    // ---------------------------------------------------------------
    // Exact real folding
    // ---------------------------------------------------------------

    fn real_of(arena: &mut ExprArena, v: f64) -> ExprId {
        arena.float_from_f64(v).unwrap()
    }

    fn real_const(arena: &ExprArena, e: ExprId) -> &Real {
        match arena.node(e) {
            ExprNode::RealConst(r) => r,
            other => panic!("expected RealConst, got {:?}", other),
        }
    }

    /// Division and reciprocal fold to the same exact rational: the fold algebra and canon's
    /// field algebra coincide by construction (else one value under two constants flips verdicts).
    #[test]
    fn div_and_rcp_fold_to_the_same_exact_rational() {
        let mut ar = ExprArena::new();
        let one = real_of(&mut ar, 1.0);
        let three = real_of(&mut ar, 3.0);
        let d = ar.div(one, three);
        let three2 = real_of(&mut ar, 3.0);
        let r = ar.rcp(three2);
        let third = Real::from_rational(rug::Rational::from((1, 3)));
        assert_eq!(real_const(&ar, d), &third);
        assert_eq!(real_const(&ar, r), &third);
        // And distinct from the f64 approximation of 1/3.
        assert_ne!(real_const(&ar, d), &Real::from_f64(1.0 / 3.0).unwrap());
    }

    /// fma folds exactly as mul-then-add (one algebra, no fused rounding).
    #[test]
    fn fma_folds_exactly_as_mul_plus_add() {
        let mut ar = ExprArena::new();
        let (a, b, c) = (
            real_of(&mut ar, 0.1),
            real_of(&mut ar, 0.2),
            real_of(&mut ar, 0.3),
        );
        let fused = ar.fma(a, b, c);
        let prod = ar.mul(a, b);
        let spelled = ar.add(prod, c);
        assert_eq!(real_const(&ar, fused), real_const(&ar, spelled));
        // The old f64 folds disagreed: mul_add rounds once, mul+add twice.
        assert_ne!(
            real_const(&ar, fused),
            &Real::from_f64(0.1f64.mul_add(0.2, 0.3)).unwrap()
        );
    }

    /// The exact sum of two f64 constants is not the f64 the hardware
    /// would produce: `0.1 + 0.2` folds to the exact rational sum, which
    /// differs from the literal 0.30000000000000004 (0d3FD3333333333334).
    #[test]
    fn addition_is_exact_not_rounded() {
        let mut ar = ExprArena::new();
        let a = real_of(&mut ar, 0.1);
        let b = real_of(&mut ar, 0.2);
        let sum = ar.add(a, b);
        assert_ne!(
            real_const(&ar, sum),
            &Real::from_f64(0.1 + 0.2).unwrap(),
            "the exact sum must not equal the rounded f64 sum"
        );
        let exact = Real::from_f64(0.1)
            .unwrap()
            .try_add(&Real::from_f64(0.2).unwrap())
            .unwrap();
        assert_eq!(real_const(&ar, sum), &exact);
    }

    /// x / 0 (including 0 / 0) builds the node unfolded instead of minting
    /// a NaN or folding to 0; canon then errors loudly on the formally
    /// zero denominator.
    #[test]
    fn division_by_concrete_zero_stays_symbolic() {
        let mut ar = ExprArena::new();
        let z1 = real_of(&mut ar, 0.0);
        let z2 = real_of(&mut ar, 0.0);
        let e = ar.div(z1, z2);
        assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

        let one = real_of(&mut ar, 1.0);
        let z3 = real_of(&mut ar, 0.0);
        let e = ar.div(one, z3);
        assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

        let iz1 = ar.int(0);
        let iz2 = ar.int(0);
        let e = ar.div(iz1, iz2);
        assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

        // rcp(0) stays symbolic as well.
        let z4 = real_of(&mut ar, 0.0);
        let e = ar.rcp(z4);
        assert!(matches!(ar.node(e), ExprNode::Rcp(_)));
    }

    /// A zero *numerator* over a non-concrete divisor also stays unfolded, for either zero: folding
    /// `0 / x` to 0 would hide a formally-zero `x` from canon's loud division error.
    #[test]
    fn zero_numerator_over_symbolic_divisor_stays_symbolic() {
        let mut ar = ExprArena::new();

        let iz = ar.int(0);
        let s = ar.symbol();
        let e = ar.div(iz, s);
        assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

        let rz = real_of(&mut ar, 0.0);
        let e = ar.div(rz, s);
        assert!(matches!(ar.node(e), ExprNode::Div(_, _)));

        // Fully concrete quotients still fold.
        let iz = ar.int(0);
        let three = ar.int(3);
        let e = ar.div(iz, three);
        assert_eq!(ar.as_i64(e), Some(0));
        let rz = real_of(&mut ar, 0.0);
        let rthree = real_of(&mut ar, 3.0);
        let e = ar.div(rz, rthree);
        assert!(real_const(&ar, e).is_zero());
    }

    /// `abs` folds integer and real constants exactly (an integer wraps
    /// at i64::MIN; the interpreter re-reads it at the instruction's
    /// width) and builds a node over a symbolic argument.
    #[test]
    fn abs_folds_constants() {
        let mut ar = ExprArena::new();
        let i = ar.int(-7);
        let e = ar.abs(i);
        assert_eq!(ar.as_i64(e), Some(7));
        let i = ar.int(i64::MIN);
        let e = ar.abs(i);
        assert_eq!(ar.as_i64(e), Some(i64::MIN));
        let r = real_of(&mut ar, -2.5);
        let e = ar.abs(r);
        assert_eq!(real_const(&ar, e).to_f64(), 2.5);
        let x = ar.symbol();
        let e = ar.abs(x);
        assert!(matches!(ar.node(e), ExprNode::Abs(a) if *a == x));
    }

    /// The extended-real fold table: the unambiguous forms fold, the
    /// undefined forms (inf - inf, 0 * inf, inf / inf, x / 0) build nodes.
    #[test]
    fn extended_real_folds() {
        let mut ar = ExprArena::new();
        let pinf = real_of(&mut ar, f64::INFINITY);
        let ninf = real_of(&mut ar, f64::NEG_INFINITY);
        let two = real_of(&mut ar, 2.0);
        let neg3 = real_of(&mut ar, -3.0);
        let zero = real_of(&mut ar, 0.0);

        // inf +/- finite, neg, abs.
        let e = ar.add(pinf, two);
        assert!(real_const(&ar, e).is_pos_inf());
        let e = ar.sub(ninf, two);
        assert!(real_const(&ar, e).is_neg_inf());
        let e = ar.neg(pinf);
        assert!(real_const(&ar, e).is_neg_inf());
        let e = ar.abs(ninf);
        assert!(real_const(&ar, e).is_pos_inf());

        // inf * nonzero follows the sign rules.
        let e = ar.mul(pinf, neg3);
        assert!(real_const(&ar, e).is_neg_inf());
        let e = ar.mul(ninf, neg3);
        assert!(real_const(&ar, e).is_pos_inf());

        // Undefined forms stay unfolded.
        let e = ar.add(pinf, ninf);
        assert!(matches!(ar.node(e), ExprNode::Add(_, _)));
        let e = ar.sub(pinf, pinf);
        assert!(matches!(ar.node(e), ExprNode::Sub(_, _)));
        let e = ar.mul(zero, pinf);
        assert!(matches!(ar.node(e), ExprNode::Mul(_, _)));
        let e = ar.fma(zero, pinf, two);
        assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
        let e = ar.div(pinf, pinf);
        assert!(matches!(ar.node(e), ExprNode::Div(_, _)));
        let e = ar.div(two, pinf);
        assert!(matches!(ar.node(e), ExprNode::Div(_, _)));
        let e = ar.rcp(pinf);
        assert!(matches!(ar.node(e), ExprNode::Rcp(_)));

        // Comparisons use the extended-real total order.
        let e = ar.lt(ninf, two);
        assert_eq!(ar.as_bool(e), Some(true));
        let e = ar.ge(pinf, two);
        assert_eq!(ar.as_bool(e), Some(true));
        let e = ar.le(ninf, ninf);
        assert_eq!(ar.as_bool(e), Some(true));
        let e = ar.lt(ninf, ninf);
        assert_eq!(ar.as_bool(e), Some(false));
    }

    /// The *integer* zero annihilates `0 * x` like the real zero except against a concrete infinity
    /// (0 * inf stays unfolded), in both operand orders and through fma's zero shortcut, including
    /// the mixed form with a non-real-constant addend that skips `try_fma`.
    #[test]
    fn integer_zero_times_infinity_stays_unfolded() {
        let mut ar = ExprArena::new();
        let iz = ar.int(0);
        let pinf = real_of(&mut ar, f64::INFINITY);
        let ninf = real_of(&mut ar, f64::NEG_INFINITY);
        let x = ar.symbol();

        for (a, b) in [(iz, pinf), (pinf, iz), (iz, ninf), (ninf, iz)] {
            let e = ar.mul(a, b);
            assert!(matches!(ar.node(e), ExprNode::Mul(_, _)));
        }

        // The annihilation itself is intact for everything else.
        let e = ar.mul(iz, x);
        assert_eq!(ar.as_i64(e), Some(0));
        let two = real_of(&mut ar, 2.0);
        let e = ar.mul(iz, two);
        assert_eq!(ar.as_i64(e), Some(0));

        // fma: an integer-zero multiplicand against an infinity stays
        // unfolded rather than collapsing to the addend...
        let c = real_of(&mut ar, 5.0);
        let e = ar.fma(iz, pinf, c);
        assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
        let e = ar.fma(ninf, iz, c);
        assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
        // ...as does a real-zero * inf whose addend is an integer.
        let rz = real_of(&mut ar, 0.0);
        let ic = ar.int(5);
        let e = ar.fma(rz, pinf, ic);
        assert!(matches!(ar.node(e), ExprNode::Fma(_, _, _)));
        // The zero shortcut itself is intact.
        let e = ar.fma(iz, x, c);
        assert_eq!(e, c);
    }

    /// The layout the arena's economics rest on, statically: `Real` is pointer-sized (a boxed repr
    /// with a `NonNull` niche) and `ExprNode` stays 16 bytes on GiB-scale arenas.
    #[test]
    fn real_and_expr_node_stay_small() {
        assert_eq!(std::mem::size_of::<Real>(), 8);
        assert_eq!(std::mem::size_of::<ExprNode>(), 16);
    }

    /// Max/min: concrete pairs fold totally; the running-max/min seeds
    /// (-inf for max, +inf for min) still absorb against symbolic values.
    #[test]
    fn max_min_absorption_and_exact_folds() {
        let mut ar = ExprArena::new();
        let ninf = real_of(&mut ar, f64::NEG_INFINITY);
        let pinf = real_of(&mut ar, f64::INFINITY);
        let two = real_of(&mut ar, 2.0);
        let x = ar.symbol();

        let e = ar.max(ninf, x);
        assert_eq!(e, x);
        let e = ar.max(x, ninf);
        assert_eq!(e, x);
        let e = ar.min(pinf, x);
        assert_eq!(e, x);
        let e = ar.min(x, pinf);
        assert_eq!(e, x);

        let e = ar.max(ninf, two);
        assert_eq!(real_const(&ar, e), &Real::from_f64(2.0).unwrap());
        let e = ar.max(pinf, two);
        assert!(real_const(&ar, e).is_pos_inf());
        let e = ar.min(ninf, two);
        assert!(real_const(&ar, e).is_neg_inf());

        let e = ar.max(x, x);
        assert_eq!(e, x);
    }

    /// Concrete real eq/ne now fold (exact comparisons; previously only
    /// integers folded and a concrete float `setp.eq` guard failed as
    /// not-concrete).
    #[test]
    fn real_eq_ne_fold() {
        let mut ar = ExprArena::new();
        let a = real_of(&mut ar, 1.5);
        let b = real_of(&mut ar, 1.5);
        let c = real_of(&mut ar, 2.5);
        let e = ar.eq(a, b);
        assert_eq!(ar.as_bool(e), Some(true));
        let e = ar.eq(a, c);
        assert_eq!(ar.as_bool(e), Some(false));
        let e = ar.ne(a, c);
        assert_eq!(ar.as_bool(e), Some(true));
    }

    /// NaN is rejected at every ingestion point.
    #[test]
    fn nan_is_rejected() {
        assert_eq!(Real::from_f64(f64::NAN), Err(NanError));
        let mut ar = ExprArena::new();
        assert!(ar.float_from_f64(f64::NAN).is_err());
        assert!(
            ar.float_from_f64(f64::from_bits(0x7FF8_0000_0000_0000))
                .is_err()
        );
    }

    /// to_float folds exactly: a large i64 becomes the rational it
    /// denotes, not the nearest f64 (canon treats ToFloat as identity, so
    /// the eager fold must be exact too).
    #[test]
    fn to_float_is_exact() {
        let mut ar = ExprArena::new();
        let big = ar.int(i64::MAX);
        let f = ar.to_float(big);
        let exact = Real::from_i64(i64::MAX);
        assert_eq!(real_const(&ar, f), &exact);
        assert_ne!(exact, Real::from_f64(i64::MAX as f64).unwrap());
    }

    /// Display: integers print bare, f64-representable dyadics print in
    /// f64's shortest form, exact non-representable rationals print p/q.
    #[test]
    fn real_display() {
        let mut ar = ExprArena::new();
        let e = real_of(&mut ar, 42.0);
        assert_eq!(ar.display_expr(e), "42");
        let e = real_of(&mut ar, 0.0);
        assert_eq!(ar.display_expr(e), "0");
        let e = real_of(&mut ar, -0.0);
        assert_eq!(ar.display_expr(e), "0");
        let e = real_of(&mut ar, 0.1);
        assert_eq!(ar.display_expr(e), "0.1");
        let e = real_of(&mut ar, -2.5);
        assert_eq!(ar.display_expr(e), "-2.5");
        let e = real_of(&mut ar, f64::INFINITY);
        assert_eq!(ar.display_expr(e), "inf");
        let e = real_of(&mut ar, f64::NEG_INFINITY);
        assert_eq!(ar.display_expr(e), "-inf");
        let one = real_of(&mut ar, 1.0);
        let three = real_of(&mut ar, 3.0);
        let e = ar.div(one, three);
        assert_eq!(ar.display_expr(e), "1/3");
    }

    /// `validate` accepts every arena the constructors can build...
    #[test]
    fn validate_accepts_constructed_arenas() {
        let mut ar = ExprArena::new();
        let x = ar.param_symbol("x");
        let y = ar.symbol();
        let s = ar.add(x, y);
        let m = ar.max(s, x);
        let _ = ar.select(m, s, x);
        assert_eq!(ar.validate(), Ok(()));
    }

    /// ...and rejects forward/self references (e.g. `Add(0, 0)` at node 0, which would recurse
    /// without bound) and out-of-range string ids, which only a corrupt or crafted dump contains.
    #[test]
    fn validate_rejects_malformed_arenas() {
        use id_collections::Id;

        let cyclic = ExprArena::from_raw_parts_for_test(
            vec![ExprNode::Add(Id::from_index(0), Id::from_index(0))],
            vec![],
        );
        assert!(cyclic.validate().is_err());

        let forward = ExprArena::from_raw_parts_for_test(
            vec![ExprNode::Neg(Id::from_index(1)), ExprNode::IntConst(1)],
            vec![],
        );
        assert!(forward.validate().is_err());

        let oob_string = ExprArena::from_raw_parts_for_test(
            vec![ExprNode::ParamSymbol(Id::from_index(3))],
            vec!["x".to_string()],
        );
        assert!(oob_string.validate().is_err());
    }

    /// 60 levels of self-adds would print ~2^60 leaves; the prefix stops after the bytes it keeps.
    #[test]
    fn display_expr_prefix_cuts_exponentially_shared_expressions_cheaply() {
        let mut arena = ExprArena::new();
        let mut e = arena.symbol();
        for _ in 0..60 {
            e = arena.add(e, e);
        }
        let text = arena.display_expr_prefix(e, 32);
        assert!(text.ends_with('…'), "{text}");
        assert!(text.len() <= 32 + '…'.len_utf8(), "{text}");
        let small = arena.int(3);
        assert_eq!(
            arena.display_expr_prefix(small, 32),
            arena.display_expr(small)
        );
    }

    /// `display_expr` re-walks shared subexpressions, so 30 levels of self-adds print ~2^30 leaves
    /// from a ~30-node arena, far past the 50MB cap; it must end quickly with the placeholder.
    #[test]
    fn display_expr_caps_exponentially_shared_expressions() {
        let mut arena = ExprArena::new();
        let mut e = arena.symbol();
        for _ in 0..30 {
            e = arena.add(e, e);
        }
        let text = arena.display_expr(e);
        assert!(text.len() < 51 * 1024 * 1024);
        assert!(text.contains("exceeds"), "unexpected output: {text}");
    }
}
