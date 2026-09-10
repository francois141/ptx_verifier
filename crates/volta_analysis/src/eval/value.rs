//! Runtime values and per-thread register files.

use id_collections::id_type;

use crate::symbolic::ExprId;
use crate::symbols::RegId;
use crate::types::{RegClass, RegCounts};

/// Handle to one `mbarrier` object's state, held by a `Value::Mbarrier` in
/// whatever memory granule the object's address resolves to. The state
/// itself lives in an interpreter-level table, not here - this is a small,
/// `Copy` reference to it, the same size as `Value::Scalar`'s `ExprId`, so
/// adding this variant doesn't grow `Value` (or any memory granule) at all.
#[id_type]
pub struct MbarrierId(pub u32);

/// A value held in a register or a memory granule.
///
/// `Pair` models a packed pair of 16-bit halves living in one 32-bit
/// register/word — the representation nvcc uses for f16 data (loaded from
/// global as `u32`, distributed by `ldmatrix`, consumed by `mma`). We track
/// the two halves as separate real-valued expressions and never bit-encode.
///
/// `Mbarrier` is deliberately *not* program data: it never flows through
/// arithmetic, conversions, or the symbolic-expression arena (unlike
/// `Scalar`/`Pair`, it carries no `ExprId` at all) - it only ever lives in a
/// memory granule at an `mbarrier` object's address, placed and consumed by
/// the `mbarrier.*` op handlers. Every other context that matches on
/// `Value` should treat it as a hard error, not a value to compute with.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Value {
    /// A single scalar expression
    Scalar(ExprId),
    /// Two packed 16-bit halves: (lo, hi)
    Pair(ExprId, ExprId),
    /// An `mbarrier` object's state, by handle.
    Mbarrier(MbarrierId),
}

impl Value {
    /// The scalar expression, if this is a scalar.
    pub fn as_scalar(self) -> Option<ExprId> {
        match self {
            Self::Scalar(e) => Some(e),
            Self::Pair(_, _) => None,
            Self::Mbarrier(_) => None,
        }
    }

    /// The packed pair halves, if this is a pair.
    pub fn as_pair(self) -> Option<(ExprId, ExprId)> {
        match self {
            Self::Pair(lo, hi) => Some((lo, hi)),
            Self::Scalar(_) => None,
            Self::Mbarrier(_) => None,
        }
    }
}

/// A per-thread register file, indexed by (class, index).
///
/// Registers start uninitialized; reading one before writing it is an
/// analysis error (surfaced by the interpreter, which knows the pc).
#[derive(Debug, Clone)]
pub struct RegFile {
    classes: [Vec<Option<Value>>; RegClass::COUNT],
}

impl RegFile {
    pub fn new(counts: &RegCounts) -> Self {
        let class_vec = |class: RegClass| vec![None; counts.get(class) as usize];
        Self {
            classes: [
                class_vec(RegClass::Pred),
                class_vec(RegClass::Bits8),
                class_vec(RegClass::Bits16),
                class_vec(RegClass::Bits32),
                class_vec(RegClass::Bits64),
                class_vec(RegClass::Bits128),
            ],
        }
    }

    pub fn read(&self, reg: RegId) -> Option<Value> {
        self.classes[reg.class as usize][reg.index.0 as usize]
    }

    pub fn write(&mut self, reg: RegId, value: Value) {
        self.classes[reg.class as usize][reg.index.0 as usize] = Some(value);
    }
}
