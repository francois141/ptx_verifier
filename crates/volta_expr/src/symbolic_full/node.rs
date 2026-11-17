//! The full language's nodes, and the arena that stores them with each node's value.

use std::fmt;
use std::num::NonZeroI64;
use std::sync::Arc;
use std::sync::atomic::{AtomicU64, Ordering};

use id_collections::{IdVec, id_type};

use crate::lower::lower_real;
use crate::symbolic_simplified;

static SYMBOL_COUNTER: AtomicU64 = AtomicU64::new(0);

/// A machine symbol's identity, unique within the process.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct SymbolId(pub u64);

impl SymbolId {
    pub fn fresh() -> Self {
        Self(SYMBOL_COUNTER.fetch_add(1, Ordering::SeqCst))
    }
}

impl fmt::Display for SymbolId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "s{}", self.0)
    }
}

/// A NaN tried to enter the model, whose values are the reals and the two infinities.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct NanError;

impl fmt::Display for NanError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "NaN is outside the analysis model (reals)")
    }
}

impl std::error::Error for NanError {}

/// An exact extended-real constant, shared so clones are cheap. The full language does no
/// arithmetic on constants; lowering does it on the simplified language's `Real`.
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct Real(Arc<RealRepr>);

/// The variant order gives the derived `Ord` the extended-real order.
#[derive(Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum RealRepr {
    NegInf,
    Rational(rug::Rational),
    PosInf,
}

impl Real {
    fn from_repr(repr: RealRepr) -> Real {
        Real(Arc::new(repr))
    }

    pub fn repr(&self) -> &RealRepr {
        &self.0
    }

    pub fn from_rational(q: rug::Rational) -> Real {
        Real::from_repr(RealRepr::Rational(q))
    }

    /// The exact value of a finite f64, or the infinity it is; NaN is an error.
    pub fn from_f64(v: f64) -> Result<Real, NanError> {
        if v.is_nan() {
            return Err(NanError);
        }
        Ok(Real::from_repr(if v == f64::INFINITY {
            RealRepr::PosInf
        } else if v == f64::NEG_INFINITY {
            RealRepr::NegInf
        } else {
            RealRepr::Rational(rug::Rational::from_f64(v).expect("a finite f64 is rational"))
        }))
    }

    pub fn from_i64(v: i64) -> Real {
        Real::from_rational(rug::Rational::from(v))
    }

    pub fn from_ratio(numerator: i64, denominator: NonZeroI64) -> Real {
        Real::from_rational(rug::Rational::from((numerator, denominator.get())))
    }

    pub fn zero() -> Real {
        Real::from_i64(0)
    }

    pub fn one() -> Real {
        Real::from_i64(1)
    }

    pub fn abs(&self) -> Real {
        match self.repr() {
            RealRepr::NegInf | RealRepr::PosInf => Real::from_repr(RealRepr::PosInf),
            RealRepr::Rational(q) => Real::from_rational(rug::Rational::from(q.abs_ref())),
        }
    }

    /// The nearest f64.
    pub fn to_f64(&self) -> f64 {
        match self.repr() {
            RealRepr::NegInf => f64::NEG_INFINITY,
            RealRepr::Rational(q) => q.to_f64(),
            RealRepr::PosInf => f64::INFINITY,
        }
    }
}

impl fmt::Display for Real {
    /// Values that round-trip through f64 print as f64s do, others as "p/q".
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.repr() {
            RealRepr::NegInf => write!(f, "-inf"),
            RealRepr::PosInf => write!(f, "inf"),
            RealRepr::Rational(q) => {
                let d = q.to_f64();
                if d.is_finite() && Real::from_f64(d).as_ref() == Ok(self) {
                    write!(f, "{d}")
                } else {
                    write!(f, "{q}")
                }
            }
        }
    }
}

/// A handle to a node of a full [`ExprArena`].
#[id_type(serde = true)]
pub struct ExprId(pub u32);

/// A handle to a string of a full [`ExprArena`]'s string table.
#[id_type(serde = true)]
pub struct StringId(pub u32);

/// One operation exactly as a frontend performed it. The variants are
/// [`symbolic_simplified::ExprNode`]'s plus the base-2 forms that lowering rewrites
/// into natural ones.
#[derive(Debug, Clone, PartialEq)]
pub enum ExprNode {
    IntConst(i64),
    RealConst(Real),
    BoolConst(bool),
    /// A fresh unknown with no launch-config identity.
    Symbol(SymbolId),
    /// A launch-config symbolic parameter (`sym:NAME`), by config name.
    ParamSymbol(StringId),
    /// Element `index` of the launch-config input array named `array`.
    InputElement {
        array: StringId,
        index: u64,
    },

    Add(ExprId, ExprId),
    Sub(ExprId, ExprId),
    Mul(ExprId, ExprId),
    Div(ExprId, ExprId),
    Rem(ExprId, ExprId),
    Neg(ExprId),

    Exp(ExprId),
    /// `2^a`.
    Exp2(ExprId),
    Log(ExprId),
    /// `log2(a)`.
    Log2(ExprId),
    Sqrt(ExprId),
    Rcp(ExprId),
    Erf(ExprId),
    /// PyTorch's tanh approximation of GELU.
    Gelu(ExprId),

    Max(ExprId, ExprId),
    Min(ExprId, ExprId),
    Abs(ExprId),
    Sign(ExprId),
    RoundEven(ExprId),
    Trunc(ExprId),

    BitAnd(ExprId, ExprId),
    BitOr(ExprId, ExprId),
    BitXor(ExprId, ExprId),
    BitNot(ExprId),
    Shl(ExprId, ExprId),
    Shr(ExprId, ExprId),
    LShr(ExprId, ExprId),

    Eq(ExprId, ExprId),
    Ne(ExprId, ExprId),
    Lt(ExprId, ExprId),
    Le(ExprId, ExprId),
    Gt(ExprId, ExprId),
    Ge(ExprId, ExprId),

    And(ExprId, ExprId),
    Or(ExprId, ExprId),
    Not(ExprId),

    Select(ExprId, ExprId, ExprId),
    ToFloat(ExprId),
    Fma(ExprId, ExprId, ExprId),
    /// `array[index]` of a launch-config input array.
    SymbolicRead {
        array: StringId,
        index: ExprId,
    },
    Discarded,
    Undefined,
}

impl ExprNode {
    /// Call `f` on every child, in operand order.
    pub fn for_each_child(&self, mut f: impl FnMut(ExprId)) {
        use ExprNode::*;
        match self {
            IntConst(_)
            | RealConst(_)
            | BoolConst(_)
            | Symbol(_)
            | ParamSymbol(_)
            | InputElement { .. }
            | Discarded
            | Undefined => {}

            Neg(a)
            | Exp(a)
            | Exp2(a)
            | Log(a)
            | Log2(a)
            | Sqrt(a)
            | Rcp(a)
            | Erf(a)
            | Gelu(a)
            | Abs(a)
            | Sign(a)
            | RoundEven(a)
            | Trunc(a)
            | BitNot(a)
            | Not(a)
            | ToFloat(a)
            | SymbolicRead { index: a, .. } => f(*a),

            Add(a, b)
            | Sub(a, b)
            | Mul(a, b)
            | Div(a, b)
            | Rem(a, b)
            | Max(a, b)
            | Min(a, b)
            | BitAnd(a, b)
            | BitOr(a, b)
            | BitXor(a, b)
            | Shl(a, b)
            | Shr(a, b)
            | LShr(a, b)
            | Eq(a, b)
            | Ne(a, b)
            | Lt(a, b)
            | Le(a, b)
            | Gt(a, b)
            | Ge(a, b)
            | And(a, b)
            | Or(a, b) => {
                f(*a);
                f(*b);
            }

            Select(a, b, c) | Fma(a, b, c) => {
                f(*a);
                f(*b);
                f(*c);
            }
        }
    }

    /// Whether this is an int, real or bool constant.
    pub fn is_constant(&self) -> bool {
        matches!(
            self,
            ExprNode::IntConst(_) | ExprNode::RealConst(_) | ExprNode::BoolConst(_)
        )
    }

    /// The `StringId` this node references, if any.
    pub fn string_id(&self) -> Option<StringId> {
        match self {
            ExprNode::ParamSymbol(sid)
            | ExprNode::InputElement { array: sid, .. }
            | ExprNode::SymbolicRead { array: sid, .. } => Some(*sid),
            _ => None,
        }
    }
}

/// The nodes a frontend built, never folded, plus each node's *value*: the node lowering
/// makes of it when that is a constant, one of its operands or an input element. Execution
/// decides addresses, branches and modelled cases on values; lowering reads the nodes.
pub struct ExprArena {
    pub(super) nodes: IdVec<ExprId, ExprNode>,
    pub(crate) strings: IdVec<StringId, String>,
    /// Each node's value, the node itself unless lowering replaces it.
    pub(super) values: IdVec<ExprId, ExprId>,
    /// Each real constant's simplified counterpart, converted once for every evaluation and
    /// lowering that reads it.
    pub(super) lowered_reals: IdVec<ExprId, Option<symbolic_simplified::Real>>,
    /// Working space of [`ExprArena::value`]'s evaluation, empty between operations.
    pub(super) scratch: symbolic_simplified::ExprArena,
}

impl ExprArena {
    pub fn new() -> Self {
        Self {
            nodes: IdVec::new(),
            strings: IdVec::new(),
            values: IdVec::new(),
            lowered_reals: IdVec::new(),
            scratch: symbolic_simplified::ExprArena::new(),
        }
    }

    /// Push `node` with value `value`, or itself.
    pub(super) fn push(&mut self, node: ExprNode, value: Option<ExprId>) -> ExprId {
        let lowered_real = match &node {
            ExprNode::RealConst(real) => Some(lower_real(real)),
            _ => None,
        };
        self.push_lowered(node, value, lowered_real)
    }

    /// Push `node`, whose simplified counterpart as a real constant is `lowered_real`.
    pub(super) fn push_lowered(
        &mut self,
        node: ExprNode,
        value: Option<ExprId>,
        lowered_real: Option<symbolic_simplified::Real>,
    ) -> ExprId {
        let id = self.nodes.push(node);
        let value_slot = self.values.push(value.unwrap_or(id));
        let real_slot = self.lowered_reals.push(lowered_real);
        debug_assert!(value_slot == id && real_slot == id);
        id
    }

    /// The simplified counterpart of the real constant `id`.
    pub(crate) fn lowered_real(&self, id: ExprId) -> Option<&symbolic_simplified::Real> {
        self.lowered_reals[id].as_ref()
    }

    pub(super) fn atom(&mut self, node: ExprNode) -> ExprId {
        self.push(node, None)
    }

    /// The node exactly as built.
    pub fn node(&self, id: ExprId) -> &ExprNode {
        &self.nodes[id]
    }

    pub fn node_count(&self) -> usize {
        self.nodes.len()
    }

    pub fn string(&self, id: StringId) -> &str {
        &self.strings[id]
    }

    /// The node `id` evaluates to: a constant, an operand or an input element lowering
    /// replaces it with, else `id` itself.
    pub fn value(&self, id: ExprId) -> ExprId {
        self.values[id]
    }

    /// The node of [`Self::value`].
    pub fn value_node(&self, id: ExprId) -> &ExprNode {
        self.node(self.value(id))
    }

    /// Check that every node's children precede it and every `StringId` is in range.
    pub fn validate(&self) -> Result<(), String> {
        for (id, node) in self.nodes.as_slice().iter().enumerate() {
            let mut bad_child = None;
            node.for_each_child(|child| {
                if id_collections::Id::to_index(child) as usize >= id && bad_child.is_none() {
                    bad_child = Some(child);
                }
            });
            if let Some(child) = bad_child {
                return Err(format!(
                    "node {id} references child expression {}, but children must precede \
                     their parents",
                    id_collections::Id::to_index(child),
                ));
            }
            if let Some(sid) = node.string_id()
                && id_collections::Id::to_index(sid) as usize >= self.strings.len()
            {
                return Err(format!(
                    "node {id} references string {} but the arena has {} strings",
                    id_collections::Id::to_index(sid),
                    self.strings.len()
                ));
            }
        }
        Ok(())
    }

    /// The value as a concrete i64; real constants coerce through the nearest f64 with `as`
    /// semantics (truncating, saturating).
    pub fn as_i64(&self, id: ExprId) -> Option<i64> {
        match self.value_node(id) {
            ExprNode::IntConst(v) => Some(*v),
            ExprNode::RealConst(v) => Some(v.to_f64() as i64),
            ExprNode::BoolConst(b) => Some(i64::from(*b)),
            _ => None,
        }
    }

    /// The value as an integer constant, without coercing float or bool constants.
    pub fn as_int_const(&self, id: ExprId) -> Option<i64> {
        match self.value_node(id) {
            ExprNode::IntConst(v) => Some(*v),
            _ => None,
        }
    }

    /// The value as a concrete u64 (see [`Self::as_i64`] for the real-constant coercion).
    pub fn as_u64(&self, id: ExprId) -> Option<u64> {
        match self.value_node(id) {
            ExprNode::IntConst(v) => Some(*v as u64),
            ExprNode::RealConst(v) => Some(v.to_f64() as u64),
            ExprNode::BoolConst(b) => Some(u64::from(*b)),
            _ => None,
        }
    }

    /// The value as the nearest f64 (a diagnostic approximation).
    pub fn as_f64(&self, id: ExprId) -> Option<f64> {
        match self.value_node(id) {
            ExprNode::IntConst(v) => Some(*v as f64),
            ExprNode::RealConst(v) => Some(v.to_f64()),
            _ => None,
        }
    }

    /// The value as a concrete bool.
    pub fn as_bool(&self, id: ExprId) -> Option<bool> {
        match self.value_node(id) {
            ExprNode::BoolConst(b) => Some(*b),
            ExprNode::IntConst(v) => Some(*v != 0),
            _ => None,
        }
    }

    /// Whether the value is an int, real or bool constant.
    pub fn is_concrete(&self, id: ExprId) -> bool {
        self.value_node(id).is_constant()
    }

    pub fn is_undefined(&self, id: ExprId) -> bool {
        matches!(self.value_node(id), ExprNode::Undefined)
    }

    pub fn is_discarded(&self, id: ExprId) -> bool {
        matches!(self.value_node(id), ExprNode::Discarded)
    }
}

impl Default for ExprArena {
    fn default() -> Self {
        Self::new()
    }
}

impl Clone for ExprArena {
    fn clone(&self) -> Self {
        Self {
            nodes: self.nodes.clone(),
            strings: self.strings.clone(),
            values: self.values.clone(),
            lowered_reals: self.lowered_reals.clone(),
            scratch: symbolic_simplified::ExprArena::new(),
        }
    }
}

impl fmt::Debug for ExprArena {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("ExprArena")
            .field("num_nodes", &self.nodes.len())
            .field("num_strings", &self.strings.len())
            .finish()
    }
}
