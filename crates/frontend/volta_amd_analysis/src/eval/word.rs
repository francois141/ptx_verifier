//! The value of a 32-bit word as registers and memory hold it.

use volta_expr::symbolic_full::{ExprArena, ExprId};
use volta_graph::StoredValue;

/// A word holds one value, which every instruction reads, or two bf16 halves, each a real,
/// which only instructions that read bf16 halves accept; moves and memory keep either form.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) enum Word {
    Value(ExprId),
    Bf16 { low: ExprId, high: ExprId },
}

impl Word {
    /// The word's two bf16 halves, low first: a pair's reals, or the values a concrete word's
    /// halves encode; `None` for a symbolic value, whose bits are unknown, or a NaN half.
    pub fn bf16_halves(self, arena: &mut ExprArena) -> Option<[ExprId; 2]> {
        match self {
            Word::Bf16 { low, high } => Some([low, high]),
            Word::Value(value) => {
                let bits = u32::try_from(arena.as_int_const(value)?).ok()?;
                let low = bf16_from_bits(arena, bits as u16)?;
                let high = bf16_from_bits(arena, (bits >> 16) as u16)?;
                Some([low, high])
            }
        }
    }

    /// The event graph's record of the word as a store writes it.
    pub fn stored(self) -> StoredValue {
        match self {
            Word::Value(value) => StoredValue::Scalar(value),
            Word::Bf16 { low, high } => StoredValue::Pair(low, high),
        }
    }
}

/// The real a bf16 bit pattern encodes, the f32 with those upper bits; `None` for a NaN.
pub(crate) fn bf16_from_bits(arena: &mut ExprArena, bits: u16) -> Option<ExprId> {
    let value = f32::from_bits(u32::from(bits) << 16);
    arena.float_from_f64(f64::from(value)).ok()
}
