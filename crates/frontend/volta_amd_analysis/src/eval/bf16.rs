//! Instructions on words holding two bf16 halves: moves, selects, moving whole halves between
//! words, negating both halves, and taking one half out as an f32. Each half stays the real it
//! encodes; an instruction these do not cover is left to the ordinary evaluation.

use volta_expr::symbolic_full::{ExprArena, ExprId, Type, Width};

use crate::ir::{
    BinOp, LaneMask, LoweredInstr, ModifiedSrc, Src0, TernaryOp, UnaryOp, Vgpr, Vop3Src,
};

use super::EvalError;
use super::interp::high_half;
use super::wave::{WaveRegisters, concrete_word};
use super::word::Word;

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
        // `v_and_b32 dst, 0xffff0000, vN`, in either operand order, is the high half.
        LoweredInstr::BinOp {
            op: BinOp::And32,
            dst,
            src0,
            src1,
        } => {
            let value = if is_inline(src0, 0xffff_0000) {
                src1
            } else if is_inline(src1, 0xffff_0000) {
                src0
            } else {
                return None;
            };
            let [_, high] = bf16_pair(registers, lane, value)?;
            Some(registers.write_vgpr(lane, dst, high))
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
            let bf16 = Type::Float(Width(16));
            let word = Word::Bf16 {
                low: arena.neg(bf16, low),
                high: arena.neg(bf16, high),
            };
            Some(registers.write_vgpr_word(lane, dst, word))
        }
        // `v_lshlrev_b32 dst, 16, vN` is the low half.
        LoweredInstr::BinOp {
            op: BinOp::LShlRev32,
            dst,
            src0,
            src1,
        } if is_inline(src0, 16) => {
            let [low, _] = bf16_pair(registers, lane, src1)?;
            Some(registers.write_vgpr(lane, dst, low))
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

/// `mask ? srcs[1] : srcs[0]` when either source holds a bf16 pair. The lane's mask bit must be
/// concrete, since a symbolic select of two pairs is no single pair.
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
        .any(|word| matches!(word, Ok(Word::Bf16 { .. })));
    holds_pair.then(|| {
        let condition = registers.read_lane_condition(arena, lane, mask)?;
        let take_src1 = arena
            .as_bool(condition)
            .ok_or(EvalError::Bf16Halves { lane, reg: srcs[0] })?;
        let [word0, word1] = words;
        let word = if take_src1 { word1? } else { word0? };
        registers.write_vgpr_word(lane, dst, word)
    })
}
