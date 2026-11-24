//! Instructions on words holding two bf16 halves: moves, selects, moving whole halves between
//! words, packing halves by OR, masking a half's bit field, negating both halves, and taking one
//! half out as an f32. Each half stays the real it encodes; an instruction these do not cover is
//! left to the ordinary evaluation.

use volta_expr::symbolic_full::{ExprArena, ExprId, ExprNode, Type, Width};

use crate::ir::{
    BinOp, LaneMask, LoweredInstr, ModifiedSrc, Src0, TernaryOp, UnaryOp, Vgpr, Vop3Src,
};

use super::EvalError;
use super::interp::high_half;
use super::wave::{WaveRegisters, concrete_word, same_value};
use super::word::{Word, bf16_field, bf16_from_bits, is_zero_half};

const BF16: Type = Type::Float(Width(16));

/// One lane of an instruction that moves or selects a word holding two bf16 halves, or takes one
/// half out as an f32. `None` leaves the instruction to the ordinary evaluation.
pub(super) fn execute_bf16_pair_lane(
    arena: &mut ExprArena,
    registers: &mut WaveRegisters,
    lane: usize,
    instruction: &LoweredInstr,
) -> Option<Result<(), EvalError>> {
    match *instruction {
        // `v_mov_b32 dst, vN` copies the word in either form.
        LoweredInstr::UnaryOp {
            op: UnaryOp::Mov32,
            dst,
            src,
        } => {
            let word = registers.read_vgpr_word(lane, plain_vgpr(src)?);
            Some(word.and_then(|word| registers.write_vgpr_word(lane, dst, word)))
        }
        // `v_and_b32 dst, mask, vN`, in either operand order, keeps a whole half or, for a mask
        // within the low half such as a bf16's exponent `0x7f80`, a field of the low half.
        LoweredInstr::BinOp {
            op: BinOp::And32,
            dst,
            src0,
            src1,
        } => {
            let (mask, value) = match concrete_src(arena, registers, lane, src0) {
                Some(mask) => (mask, src1),
                None => (concrete_src(arena, registers, lane, src1)?, src0),
            };
            let [low, high] = bf16_pair(registers, lane, value)?;
            let word = match mask {
                0xffff_0000 => Word::Bf16 {
                    low: zero_half(arena),
                    high,
                },
                0xffff => Word::Bf16 {
                    low,
                    high: zero_half(arena),
                },
                1..0xffff => Word::Value(bf16_field(arena, low, mask as u16)),
                _ => return None,
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        LoweredInstr::TernaryOp {
            op: TernaryOp::Perm32,
            dst,
            srcs: [high_src, low_src, selector],
        } => {
            let selector = concrete_src(arena, registers, lane, selector)?;
            let word = pack_truncated(arena, registers, lane, selector, [low_src, high_src])
                .or_else(|| {
                    permute_halves(arena, registers, lane, selector, [low_src, high_src])
                })?;
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        // `v_bfe_{u,i}32 dst, vN, 0 or 16, 16` takes one bf16 half to the low half; above it go
        // zeros, or for the signed form the half's sign bit, unknown for a real, so undefined.
        LoweredInstr::TernaryOp {
            op: op @ (TernaryOp::Bfe32 | TernaryOp::BfeI32),
            dst,
            srcs: [value, offset, width],
        } => {
            if concrete_src(arena, registers, lane, width)? & 31 != 16 {
                return None;
            }
            let [low, high] = bf16_pair(registers, lane, value)?;
            let field = match concrete_src(arena, registers, lane, offset)? & 31 {
                0 => low,
                16 => high,
                _ => return None,
            };
            let above = match op {
                TernaryOp::Bfe32 => zero_half(arena),
                _ => arena.undefined(),
            };
            let word = Word::Bf16 {
                low: field,
                high: above,
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        // `v_alignbit_b32 dst, a, b, 16` is the middle word of `a:b`: `b`'s high half below
        // `a`'s low half.
        LoweredInstr::TernaryOp {
            op: TernaryOp::AlignBit32,
            dst,
            srcs: [high_src, low_src, amount],
        } => {
            if concrete_src(arena, registers, lane, amount)? & 31 != 16 {
                return None;
            }
            let [[_, middle_low], [middle_high, _]] =
                halves_of(arena, registers, lane, [low_src, high_src])?;
            let word = Word::Bf16 {
                low: middle_low,
                high: middle_high,
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        // `v_bfi_b32 dst, mask, a, b` with a half-word mask takes that half from `a` and the
        // other from `b`.
        LoweredInstr::TernaryOp {
            op: TernaryOp::Bfi32,
            dst,
            srcs: [mask, inserted, kept],
        } => {
            let mask = concrete_src(arena, registers, lane, mask)?;
            let [inserted, kept] = halves_of(arena, registers, lane, [inserted, kept])?;
            let word = match mask {
                0x0000_ffff => Word::Bf16 {
                    low: inserted[0],
                    high: kept[1],
                },
                0xffff_0000 => Word::Bf16 {
                    low: kept[0],
                    high: inserted[1],
                },
                _ => return None,
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        // `v_xor_b32 dst, 0x80008000, vN` flips both halves' sign bits: it negates each real.
        LoweredInstr::BinOp {
            op: BinOp::Xor32,
            dst,
            src0,
            src1,
        } => {
            let value = if is_inline(src0, 0x8000_8000) {
                src1
            } else if is_inline(src1, 0x8000_8000) {
                src0
            } else {
                return None;
            };
            let [low, high] = bf16_pair(registers, lane, value)?;
            let word = Word::Bf16 {
                low: arena.neg(BF16, low),
                high: arena.neg(BF16, high),
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        // `v_lshlrev_b32 dst, 16, vN` moves the low half up, zeroing the low half: the low
        // half widened to an f32.
        LoweredInstr::BinOp {
            op: BinOp::LShlRev32,
            dst,
            src0,
            src1,
        } if is_inline(src0, 16) => {
            let [low, _] = bf16_pair(registers, lane, src1)?;
            let word = Word::Bf16 {
                low: zero_half(arena),
                high: low,
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        LoweredInstr::BinOp {
            op: BinOp::Or32,
            dst,
            src0,
            src1,
        } => {
            let word = or_halves(arena, registers, lane, &[src0, src1])?;
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        LoweredInstr::TernaryOp {
            op: TernaryOp::Or3_32,
            dst,
            srcs,
        } => {
            let word = or_halves(arena, registers, lane, &srcs)?;
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        // `v_lshrrev_b32 dst, 16, vN` moves the high half down, zeroing the high half.
        LoweredInstr::BinOp {
            op: BinOp::LShrRev32,
            dst,
            src0,
            src1,
        } if is_inline(src0, 16) => {
            let [_, high] = bf16_pair(registers, lane, src1)?;
            let word = Word::Bf16 {
                low: high,
                high: zero_half(arena),
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        LoweredInstr::CndMask32 {
            dst,
            src0: Src0::Vgpr(src0),
            src1,
        } => select_bf16_pair(arena, registers, lane, dst, [src0, src1], LaneMask::Vcc),
        LoweredInstr::CndMask32E64 {
            dst,
            src0,
            src1,
            mask,
        } => {
            let srcs = [plain_vgpr(src0)?, plain_vgpr(src1)?];
            select_bf16_pair(arena, registers, lane, dst, srcs, mask)
        }
        _ => None,
    }
}

/// `v_perm_b32 dst, a, b, 0x07060302` packs the high halves of `b` and `a`, the bf16 pair of
/// two f32 words truncated, which this model packs exactly as `v_cvt_pk_bf16_f32` does.
fn pack_truncated(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    selector: u32,
    [low_src, high_src]: [ModifiedSrc; 2],
) -> Option<Word> {
    if selector != 0x0706_0302 {
        return None;
    }
    let high_of = |arena: &mut ExprArena, src: ModifiedSrc| -> Option<ExprId> {
        match registers.read_vgpr_word(lane, plain_vgpr(src)?).ok()? {
            Word::Value(value) if concrete_word(arena, value).is_some() => None,
            word => high_half(arena, word),
        }
    };
    Some(Word::Bf16 {
        low: high_of(arena, low_src)?,
        high: high_of(arena, high_src)?,
    })
}

/// `v_perm_b32` whose selector picks each result half as a whole, aligned half of `a:b`:
/// selector bytes `2k, 2k + 1` give half `k` of `b`'s low, `b`'s high, `a`'s low, `a`'s high.
fn permute_halves(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    selector: u32,
    srcs: [ModifiedSrc; 2],
) -> Option<Word> {
    let [[b_low, b_high], [a_low, a_high]] = halves_of(arena, registers, lane, srcs)?;
    let halves = [b_low, b_high, a_low, a_high];
    let pick = |result_half: u32| {
        let low_byte = (selector >> (16 * result_half)) & 0xff;
        let high_byte = (selector >> (16 * result_half + 8)) & 0xff;
        (low_byte.is_multiple_of(2) && high_byte == low_byte + 1 && high_byte <= 7)
            .then(|| halves[low_byte as usize / 2])
    };
    Some(Word::Bf16 {
        low: pick(0)?,
        high: pick(1)?,
    })
}

/// The OR of words each of whose halves is zero in all but at most one of them, as packing
/// two bf16s does: `(b << 16) | (a & 0xffff)`. A source that is a symbolic value, an f32 of
/// unknown bits, leaves the instruction to the ordinary evaluation.
fn or_halves(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    srcs: &[ModifiedSrc],
) -> Option<Word> {
    let mut words = Vec::with_capacity(srcs.len());
    for &src in srcs {
        words.push(source_word(arena, registers, lane, src)?);
    }
    if !words.iter().any(|word| matches!(word, Word::Bf16 { .. })) {
        return None;
    }
    or_words(arena, words)
}

/// The OR of words whose halves are each zero in all but at most one of them.
fn or_words(arena: &mut ExprArena, words: Vec<Word>) -> Option<Word> {
    let mut halves = [None, None];
    for word in words {
        let word_halves = match word {
            Word::Bf16 { low, high } => {
                [low, high].map(|half| (!is_zero_half(arena, half)).then_some(half))
            }
            Word::Value(value) => {
                let bits = concrete_word(arena, value)?;
                let mut half = |bits: u32| match bits & 0xffff {
                    0 => Some(None),
                    bits => bf16_from_bits(arena, bits as u16).map(Some),
                };
                [half(bits)?, half(bits >> 16)?]
            }
        };
        for (half, nonzero) in halves.iter_mut().zip(word_halves) {
            if let Some(nonzero) = nonzero {
                if half.is_some() {
                    return None;
                }
                *half = Some(nonzero);
            }
        }
    }
    let [low, high] = halves.map(|half| half.unwrap_or_else(|| zero_half(arena)));
    Some(Word::Bf16 { low, high })
}

/// The bf16 half whose bits are all zero, the real 0.
fn zero_half(arena: &mut ExprArena) -> ExprId {
    bf16_from_bits(arena, 0).expect("bf16 zero is no NaN")
}

/// Each source's bf16 halves, low first, when one holds a bf16 pair and every other is a
/// concrete word whose halves encode reals.
fn halves_of<const N: usize>(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    srcs: [ModifiedSrc; N],
) -> Option<[[ExprId; 2]; N]> {
    let words = srcs.map(|src| source_word(arena, registers, lane, src));
    if !words
        .iter()
        .any(|word| matches!(word, Some(Word::Bf16 { .. })))
    {
        return None;
    }
    let halves = words.map(|word| word.and_then(|word| word.bf16_halves(arena)));
    halves
        .iter()
        .all(Option::is_some)
        .then(|| halves.map(Option::unwrap))
}

/// An unmodified source as a word in either form.
fn source_word(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    src: ModifiedSrc,
) -> Option<Word> {
    if src.is_modified() {
        return None;
    }
    match src.src {
        Vop3Src::Vgpr(reg) => registers.read_vgpr_word(lane, reg).ok(),
        other => registers.read_src(arena, lane, other).ok().map(Word::Value),
    }
}

/// An unmodified source's concrete word.
fn concrete_src(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    src: ModifiedSrc,
) -> Option<u32> {
    match source_word(arena, registers, lane, src)? {
        Word::Value(value) => concrete_word(arena, value),
        Word::Bf16 { .. } => None,
    }
}

/// The VGPR a source names, when it has no modifiers.
fn plain_vgpr(src: ModifiedSrc) -> Option<Vgpr> {
    match src {
        ModifiedSrc {
            src: Vop3Src::Vgpr(reg),
            abs: false,
            neg: false,
        } => Some(reg),
        _ => None,
    }
}

/// Whether a source is the inline constant `bits`, with no modifiers.
fn is_inline(src: ModifiedSrc, bits: u32) -> bool {
    src == ModifiedSrc {
        src: Vop3Src::Inline(bits),
        abs: false,
        neg: false,
    }
}

/// The halves of a source, low first, when it is a plain VGPR holding a bf16 pair.
fn bf16_pair(registers: &WaveRegisters, lane: usize, src: ModifiedSrc) -> Option<[ExprId; 2]> {
    match registers.read_vgpr_word(lane, plain_vgpr(src)?) {
        Ok(Word::Bf16 { low, high }) => Some([low, high]),
        _ => None,
    }
}

/// `mask ? srcs[1] : srcs[0]` when either source holds a bf16 pair that is no single value: the
/// chosen word under a concrete mask bit, else a select of each half.
fn select_bf16_pair(
    arena: &mut ExprArena,
    registers: &mut WaveRegisters,
    lane: usize,
    dst: Vgpr,
    srcs: [Vgpr; 2],
    mask: LaneMask,
) -> Option<Result<(), EvalError>> {
    let words = srcs.map(|reg| registers.read_vgpr_word(lane, reg));
    let holds_pair = words
        .iter()
        .any(|word| matches!(word, Ok(word) if word.value(arena).is_none()));
    holds_pair.then(|| {
        let condition = registers.read_lane_condition(arena, lane, mask)?;
        let [word0, word1] = words;
        let word = match arena.as_bool(condition) {
            Some(true) => word1?,
            Some(false) => word0?,
            None => select_word(arena, lane, condition, [word0?, word1?])?,
        };
        registers.write_vgpr_word(lane, dst, word)
    })
}

/// `condition ? words[1] : words[0]`: the chosen word under a concrete condition, else a
/// select of each half, which needs both words' halves to be bf16 reals.
fn select_word(
    arena: &mut ExprArena,
    lane: usize,
    condition: ExprId,
    words: [Word; 2],
) -> Result<Word, EvalError> {
    if let Some(take_src1) = arena.as_bool(condition) {
        return Ok(words[usize::from(take_src1)]);
    }
    if let [Word::Value(a), Word::Value(b)] = words
        && same_value(arena, a, b)
    {
        return Ok(words[0]);
    }
    let [Some(a), Some(b)] = words.map(|word| word.bf16_halves(arena)) else {
        return Err(EvalError::AmbiguousSelect { lane });
    };
    Ok(Word::Bf16 {
        low: select_half(arena, condition, a[0], b[0]),
        high: select_half(arena, condition, a[1], b[1]),
    })
}

/// `condition ? b : a` over two bf16 reals: one of them when they are equal, and the `max` or
/// `min` it is when `condition` orders the two, as a compiled `__hmax` does.
fn select_half(arena: &mut ExprArena, condition: ExprId, a: ExprId, b: ExprId) -> ExprId {
    if same_value(arena, a, b) {
        return a;
    }
    // `(x, y)` with `condition` meaning `x <= y` (or `x < y`).
    let ordered = match *arena.node(condition) {
        ExprNode::Le(x, y) | ExprNode::Lt(x, y) => Some((x, y)),
        ExprNode::Ge(x, y) | ExprNode::Gt(x, y) => Some((y, x)),
        _ => None,
    };
    match ordered {
        Some((x, y)) if same_value(arena, b, y) && same_value(arena, a, x) => arena.max(BF16, a, b),
        Some((x, y)) if same_value(arena, b, x) && same_value(arena, a, y) => arena.min(BF16, a, b),
        _ => arena.select(BF16, condition, b, a),
    }
}
