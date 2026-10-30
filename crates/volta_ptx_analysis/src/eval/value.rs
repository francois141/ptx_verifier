//! Runtime values and per-thread register files.

use id_collections::id_type;

use crate::ir::symbols::RegId;
use crate::ir::types::{RegClass, RegCounts};
use volta_expr::ExprId;

/// Handle to one `mbarrier` object's state, which lives in an interpreter
/// table; `Copy` and `ExprId`-sized, so `Value::Mbarrier` doesn't grow `Value`.
#[id_type]
pub struct MbarrierId(pub u32);

/// A value held in a register or a memory granule. Packed variants hold each
/// lane as its own real-valued expression and are never bit-encoded, nor fed to
/// ordinary arithmetic.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Value {
    /// A single scalar expression
    Scalar(ExprId),
    /// Two packed halves (lo, hi) in one register/word: 2x16 in a `.b32`
    /// (nvcc's f16 form, through `ldmatrix`/`mma`), 2x32 in a `.b64`.
    Pair(ExprId, ExprId),
    /// Four packed lanes, lane 0 lowest: 4x8 in a `.b32` (fp8; built only by
    /// combining granules on read, split by `mov.b32 {h0,h1}` or `ld.u8`), 4x16
    /// in a `.b64` (f16, a vectorized `ld.u64`) or 4x32 in a `.b128` (`PackQuad`).
    Quad(ExprId, ExprId, ExprId, ExprId),
    /// An `mbarrier` object's state, by handle. Not program data: it has no
    /// `ExprId` and lives only at an mbarrier's address; any other context must
    /// treat it as a hard error.
    Mbarrier(MbarrierId),
}

/// A per-thread register file, indexed by (class, index). Registers start
/// uninitialized; reading one first is an analysis error surfaced by the
/// interpreter.
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
