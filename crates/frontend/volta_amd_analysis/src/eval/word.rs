//! The value of a 32-bit word as registers and memory hold it.

use volta_expr::symbolic_full::{ExprArena, ExprId, ExprNode, Real, Type, Width};
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

    /// The single value the word holds: its value, or the f32 a pair with a zero low half
    /// encodes, its high half widened (`v_lshlrev_b32 16` of a bf16). Volta's reals have no
    /// signed zero, so a zero half is +0's bits.
    pub fn value(self, arena: &ExprArena) -> Option<ExprId> {
        match self {
            Word::Value(value) => Some(value),
            Word::Bf16 { low, high } if is_zero_half(arena, low) => Some(high),
            Word::Bf16 { .. } => None,
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

/// Whether a bf16 half is the real 0.
pub(crate) fn is_zero_half(arena: &ExprArena, half: ExprId) -> bool {
    matches!(arena.value_node(half), ExprNode::RealConst(real) if *real == Real::zero())
}

/// The real a bf16 bit pattern encodes, the f32 with those upper bits; `None` for a NaN.
pub(crate) fn bf16_from_bits(arena: &mut ExprArena, bits: u16) -> Option<ExprId> {
    let value = f32::from_bits(u32::from(bits) << 16);
    arena.float_from_f64(f64::from(value)).ok()
}

/// A bf16's exponent field, all ones only for an infinity or a NaN.
const BF16_EXPONENT: u16 = 0x7f80;

const BITS16: Type = Type::Bits(Width(16));

/// `field == constant`, or `!=` when `equal` is false, of a `bf16_field` and a concrete word;
/// `None` when neither side is such a field. Volta's values are finite reals, so a bf16's
/// exponent is never all ones; any other test of a field is an opaque predicate.
pub(crate) fn compare_bf16_field(
    arena: &mut ExprArena,
    equal: bool,
    a: ExprId,
    b: ExprId,
) -> Option<ExprId> {
    let (field, constant) = [(a, b), (b, a)].into_iter().find_map(|(field, constant)| {
        let mask = bf16_field_mask(arena, field)?;
        Some(((field, mask), arena.as_int_const(constant)?))
    })?;
    let (field, mask) = field;
    if mask == BF16_EXPONENT && constant == i64::from(BF16_EXPONENT) {
        return Some(arena.bool_val(!equal));
    }
    let constant = arena.int(constant);
    Some(if equal {
        arena.eq(BITS16, field, constant)
    } else {
        arena.ne(BITS16, field, constant)
    })
}

/// The mask of a `bf16_field`, `None` for any other value.
fn bf16_field_mask(arena: &ExprArena, value: ExprId) -> Option<u16> {
    let ExprNode::BitAnd(_, mask) = *arena.node(value) else {
        return None;
    };
    if arena.ty(value) != Some(BITS16) {
        return None;
    }
    u16::try_from(arena.as_int_const(mask)?).ok()
}
