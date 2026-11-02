//! Vector ALU arithmetic: the value of a unary, binary or comparison operation in one lane.

use volta_expr::{ExprArena, ExprId};

use crate::ir::{BinOp, CmpOp, Src0, UnaryOp, Vgpr};

use super::EvalError;
use super::wave::WaveRegisters;

enum OperandType {
    Word,
    F32,
}

fn operand_type(op: BinOp) -> OperandType {
    match op {
        BinOp::And32 | BinOp::Or32 | BinOp::Xor32 => OperandType::Word,
        BinOp::AddF32 | BinOp::SubF32 | BinOp::MulF32 | BinOp::MinF32 | BinOp::MaxF32 => {
            OperandType::F32
        }
    }
}

/// `src0 op src1` in `lane`, each source read as `op`'s operand type.
pub(super) fn evaluate_bin_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: BinOp,
    src0: Src0,
    src1: Vgpr,
) -> Result<ExprId, EvalError> {
    let (a, b) = match operand_type(op) {
        OperandType::Word => (
            registers.read_src0(arena, lane, src0)?,
            registers.read_vgpr(lane, src1)?,
        ),
        OperandType::F32 => (
            registers.read_f32_src0(arena, lane, src0)?,
            registers.read_f32(arena, lane, src1)?,
        ),
    };
    if let Some(result) = sign_bit_op(arena, op, a, b) {
        return Ok(result);
    }
    Ok(match op {
        BinOp::And32 => arena.bit_and(a, b),
        BinOp::Or32 => arena.bit_or(a, b),
        BinOp::Xor32 => arena.bit_xor(a, b),
        BinOp::AddF32 => arena.add(a, b),
        BinOp::SubF32 => arena.sub(a, b),
        BinOp::MulF32 => arena.mul(a, b),
        BinOp::MinF32 => arena.min(a, b),
        BinOp::MaxF32 => arena.max(a, b),
    })
}

const SIGN_BIT: i64 = 0x8000_0000;

/// A word op of a symbolic value with an f32 sign-bit mask, as the sign operation it is on the
/// real an f32 register holds (`WaveRegisters::read_f32`); `None` for any other operands.
fn sign_bit_op(arena: &mut ExprArena, op: BinOp, a: ExprId, b: ExprId) -> Option<ExprId> {
    let (mask, value) = match (arena.as_int_const(a), arena.as_int_const(b)) {
        (Some(mask), None) => (mask, b),
        (None, Some(mask)) => (mask, a),
        _ => return None,
    };
    match (op, mask) {
        (BinOp::Xor32, SIGN_BIT) => Some(arena.neg(value)),
        (BinOp::And32, 0x7FFF_FFFF) => Some(arena.abs(value)),
        (BinOp::Or32, SIGN_BIT) => {
            let magnitude = arena.abs(value);
            Some(arena.neg(magnitude))
        }
        _ => None,
    }
}

/// `VCC ? src1 : src0` in `lane`. A word selected against a real is the f32 its bits encode,
/// read as `WaveRegisters::read_f32` reads it; two words are selected as words.
pub(super) fn evaluate_cndmask(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    src0: Src0,
    src1: Vgpr,
) -> Result<ExprId, EvalError> {
    let condition = registers.read_vcc(lane)?;
    let a = registers.read_src0(arena, lane, src0)?;
    let b = registers.read_vgpr(lane, src1)?;
    let (a, b) = match (arena.as_int_const(a), arena.as_int_const(b)) {
        (Some(_), None) => (registers.read_f32_src0(arena, lane, src0)?, b),
        (None, Some(_)) => (a, registers.read_f32(arena, lane, src1)?),
        _ => (a, b),
    };
    Ok(arena.select(condition, b, a))
}

/// `op src` in `lane`, the source read as an f32.
pub(super) fn evaluate_unary_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: UnaryOp,
    src: Src0,
) -> Result<ExprId, EvalError> {
    let a = registers.read_f32_src0(arena, lane, src)?;
    Ok(match op {
        UnaryOp::Exp2F32 => arena.exp2(a),
        UnaryOp::Log2F32 => arena.log2(a),
        UnaryOp::RcpF32 => arena.rcp(a),
        UnaryOp::SqrtF32 => arena.sqrt(a),
        UnaryOp::RsqF32 => {
            let root = arena.sqrt(a);
            arena.rcp(root)
        }
    })
}

/// The boolean `src0 op src1` in `lane`, each source read as an f32.
pub(super) fn evaluate_cmp(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CmpOp,
    src0: Src0,
    src1: Vgpr,
) -> Result<ExprId, EvalError> {
    let a = registers.read_f32_src0(arena, lane, src0)?;
    let b = registers.read_f32(arena, lane, src1)?;
    Ok(match op {
        CmpOp::LtF32 => arena.lt(a, b),
        CmpOp::LeF32 => arena.le(a, b),
        CmpOp::EqF32 => arena.eq(a, b),
        CmpOp::LgF32 => arena.ne(a, b),
    })
}

/// `value << (shift & 31)`: AMD uses only the low five bits of the shift count, so 34 becomes 2
/// and 32 becomes 0. A concrete result keeps its low 32 bits; a symbolic one follows PTX's model
/// and keeps the shift expression without truncation. TODO: Should this be handled differently?
pub(super) fn shl32(arena: &mut ExprArena, value: ExprId, shift: u32) -> ExprId {
    let amount = arena.int(i64::from(shift & 31));
    let shifted = arena.shl(value, amount);
    if arena.as_int_const(value).is_some() {
        let mask = arena.int(i64::from(u32::MAX));
        arena.bit_and(shifted, mask)
    } else {
        shifted
    }
}
