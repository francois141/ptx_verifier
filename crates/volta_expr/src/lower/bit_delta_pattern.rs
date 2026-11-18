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

/// A node `x & 1` whose result is the bit at `offset` of the input element `word`, in
/// `polarity`.
pub(super) struct BitDeltaPattern {
    word: full::ExprId,
    offset: u32,
    polarity: Polarity,
}

impl BitfieldPattern for BitDeltaPattern {
    /// A node `x & 1` whose bit 0 is exactly one input bit, or that bit's complement.
    fn detect(arena: &full::ExprArena, id: full::ExprId) -> Option<Self> {
        let full::ExprNode::BitAnd(a, b) = *arena.node(id) else {
            return None;
        };
        let is_one = |operand| arena.as_int_const(operand) == Some(1);
        if !is_one(a) && !is_one(b) {
            return None;
        }
        let Bit { constant, inputs } = BitReader::new(arena).bit(id, 0)?;
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
        })
    }

    /// `(word >> offset) & 1`; a complemented bit, being 0 or 1, is 1 minus it.
    fn lower(
        self,
        target: &mut simplified::ExprArena,
        child: impl Fn(full::ExprId) -> simplified::ExprId,
    ) -> simplified::ExprId {
        let bit = extract_bitfield(target, child(self.word), self.offset, 1);
        match self.polarity {
            Polarity::Direct => bit,
            Polarity::Complemented => {
                let one = target.int(1);
                target.sub(one, bit)
            }
        }
    }
}
