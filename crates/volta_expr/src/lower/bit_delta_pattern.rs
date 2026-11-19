//! The pattern of BitDelta's kernel, which decodes its packed sign bits this way: one bit of
//! an input word, reached through shifts, masks, xors and byte permutes, where a spec
//! extracts it directly, `(word >> offset) & 1`: the pattern's standard form.

use super::bitfield_pattern::BitfieldPattern;
use super::extract_bitfield;
use super::word_bits::{Bit, BitReader, InputBit};
use crate::symbolic_full as full;
use crate::symbolic_simplified as simplified;

/// Whether an extracted bit is the input bit itself or its complement.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Polarity {
    Direct,
    Complemented,
}

/// A single-bit mask whose result is `scale` times the bit at `offset` of the input
/// element `word`, in `polarity`.
pub(super) struct BitDeltaPattern {
    word: full::ExprId,
    offset: u32,
    polarity: Polarity,
    scale: i64,
}

impl BitfieldPattern for BitDeltaPattern {
    /// A node `x & 2^s` whose bit s is exactly one input bit, or its complement.
    /// Exclude the sign bit: its numeric value depends on signed interpretation.
    fn detect(arena: &full::ExprArena, id: full::ExprId) -> Option<Self> {
        let full::ExprNode::BitAnd(a, b) = *arena.node(id) else {
            return None;
        };
        let mask = |operand| {
            let value = u32::try_from(arena.as_int_const(operand)?).ok()?;
            (value.is_power_of_two() && value < (1 << 31)).then_some(value)
        };
        let scale = mask(a).or_else(|| mask(b))?;
        let Bit { constant, inputs } = BitReader::new(arena).bit(id, scale.trailing_zeros())?;
        let mut inputs = inputs.into_iter();
        let (Some(InputBit { word, index }), None) = (inputs.next(), inputs.next()) else {
            return None;
        };
        let polarity = if constant {
            Polarity::Complemented
        } else {
            Polarity::Direct
        };
        Some(BitDeltaPattern {
            word,
            offset: index,
            polarity,
            scale: i64::from(scale),
        })
    }

    /// `scale * ((word >> offset) & 1)`; a complemented bit is 1 minus the bit.
    fn lower(
        self,
        target: &mut simplified::ExprArena,
        child: impl Fn(full::ExprId) -> simplified::ExprId,
    ) -> simplified::ExprId {
        let bit = extract_bitfield(target, child(self.word), self.offset, 1);
        let bit = match self.polarity {
            Polarity::Direct => bit,
            Polarity::Complemented => {
                let one = target.int(1);
                target.sub(one, bit)
            }
        };
        let scale = target.int(self.scale);
        target.mul(scale, bit)
    }
}
