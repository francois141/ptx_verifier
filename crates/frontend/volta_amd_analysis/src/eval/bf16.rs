//! Instructions on words holding two bf16 halves: moves, selects, negating both halves, and
//! taking one half out as an f32. Each half stays the real it encodes; an instruction these do
//! not cover is left to the ordinary evaluation.

use volta_expr::symbolic_full::{ExprArena, ExprId, Type, Width};

use crate::ir::{BinOp, LaneMask, LoweredInstr, ModifiedSrc, Src0, UnaryOp, Vgpr, Vop3Src};

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
        // `v_perm_b32 dst, a, b, 0x07060302` packs the high halves of `b` and `a`, the bf16 pair
        // of two f32 words truncated, which this model packs exactly as `v_cvt_pk_bf16_f32` does.
        LoweredInstr::TernaryOp {
            op: crate::ir::TernaryOp::Perm32,
            dst,
            srcs: [high_src, low_src, selector],
        } => {
            let selector = registers.read_src(arena, lane, selector.src).ok()?;
            if concrete_word(arena, selector) != Some(0x0706_0302) {
                return None;
            }
            let mut high_of = |src: ModifiedSrc| -> Option<ExprId> {
                match registers.read_vgpr_word(lane, plain_vgpr(src)?).ok()? {
                    Word::Value(value) if concrete_word(arena, value).is_some() => None,
                    word => high_half(arena, word),
                }
            };
            let word = Word::Bf16 {
                low: high_of(low_src)?,
                high: high_of(high_src)?,
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
