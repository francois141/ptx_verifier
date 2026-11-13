//! The expression language's values and nodes, and the arena that stores them.

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

    pub(super) fn pos_inf() -> Real {
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

    /// The integer nearest a finite real, ties to even; an infinity is its own rounding.
    pub fn round_even(&self) -> Real {
        let RealRepr::Rational(q) = self.repr() else {
            return self.clone();
        };
        let floor = q.clone().floor();
        let fraction = rug::Rational::from(q - &floor);
        let half = rug::Rational::from((1, 2));
        let round_up = match fraction.cmp(&half) {
            std::cmp::Ordering::Less => false,
            std::cmp::Ordering::Greater => true,
            std::cmp::Ordering::Equal => floor.numer().is_odd(),
        };
        let rounded = if round_up { floor + 1u32 } else { floor };
        Real::from_rational(rounded)
    }

    /// A finite real rounded toward zero; an infinity is its own rounding.
    pub fn trunc(&self) -> Real {
        match self.repr() {
            RealRepr::Rational(q) => Real::from_rational(q.clone().trunc()),
            _ => self.clone(),
        }
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
    /// The error function: erf(a)
    Erf(ExprId),

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
    /// The integer nearest `a`, ties to even (`rintf`).
    RoundEven(ExprId),
    /// `a` rounded toward zero (`truncf`).
    Trunc(ExprId),

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
            | ExprNode::Erf(a)
            | ExprNode::RoundEven(a)
            | ExprNode::Trunc(a)
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
    pub(super) nodes: IdVec<ExprId, ExprNode>,
    pub(super) strings: IdVec<StringId, String>,
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
        | (Erf(a1), Erf(b1))
        | (RoundEven(a1), RoundEven(b1))
        | (Trunc(a1), Trunc(b1))
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
