//! Vector ALU arithmetic: the value of a unary, binary, ternary or comparison operation in one
//! lane.

use volta_expr::{ExprArena, ExprId, ExprNode, Real, RealRepr};

use crate::ir::{BinOp, CmpOp, LaneMask, Src0, TernaryOp, UnaryOp, Vgpr, Vop3Src};

use super::EvalError;
use super::wave::{WaveRegisters, concrete_word};

enum OperandType {
    Word,
    F32,
}

fn operand_type(op: BinOp) -> OperandType {
    match op {
        BinOp::And32
        | BinOp::Or32
        | BinOp::Xor32
        | BinOp::LShlRev32
        | BinOp::LShrRev32
        | BinOp::AddU32
        | BinOp::SubU32
        | BinOp::SubRevU32
        | BinOp::AShrRevI32
        | BinOp::Xnor32
        | BinOp::MinI32
        | BinOp::MaxI32
        | BinOp::MinU32
        | BinOp::MaxU32
        | BinOp::MulU32U24
        | BinOp::MulHiU32U24
        | BinOp::MulI32I24
        | BinOp::MulHiI32I24 => OperandType::Word,
        BinOp::AddF32
        | BinOp::SubF32
        | BinOp::SubRevF32
        | BinOp::MulF32
        | BinOp::MinF32
        | BinOp::MaxF32 => OperandType::F32,
    }
}

fn ternary_operand_type(op: TernaryOp) -> OperandType {
    match op {
        TernaryOp::Min3F32 | TernaryOp::Max3F32 | TernaryOp::Med3F32 => OperandType::F32,
        _ => OperandType::Word,
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
    // Bitwise operations need concrete bits, which symbolic values do not satisfy.
    if matches!(
        op,
        BinOp::And32
            | BinOp::Or32
            | BinOp::Xor32
            | BinOp::Xnor32
            | BinOp::LShlRev32
            | BinOp::LShrRev32
    ) {
        concrete_words(arena, lane, [a, b])?;
    }
    Ok(match op {
        BinOp::And32 => arena.bit_and(a, b),
        BinOp::Or32 => arena.bit_or(a, b),
        BinOp::Xor32 => arena.bit_xor(a, b),
        BinOp::LShlRev32 => shl32(arena, b, a),
        BinOp::LShrRev32 => lshr32(arena, b, a),
        BinOp::AddU32 => {
            let sum = arena.add(a, b);
            low_word(arena, sum)
        }
        BinOp::SubU32 => {
            let difference = arena.sub(a, b);
            low_word(arena, difference)
        }
        BinOp::SubRevU32 => {
            let difference = arena.sub(b, a);
            low_word(arena, difference)
        }
        BinOp::AShrRevI32 => fold_concrete_words(arena, lane, [a, b], |[a, b]| {
            ((b as i32) >> (a & 31)) as u32
        })?,
        BinOp::Xnor32 => {
            let xor = arena.bit_xor(a, b);
            not32(arena, xor)
        }
        BinOp::MinI32 => fold_concrete_words(arena, lane, [a, b], |[a, b]| {
            (a as i32).min(b as i32) as u32
        })?,
        BinOp::MaxI32 => fold_concrete_words(arena, lane, [a, b], |[a, b]| {
            (a as i32).max(b as i32) as u32
        })?,
        BinOp::MinU32 => arena.min(a, b),
        BinOp::MaxU32 => arena.max(a, b),
        BinOp::MulU32U24 => {
            fold_concrete_words(arena, lane, [a, b], |[a, b]| mul_u24(a, b) as u32)?
        }
        BinOp::MulHiU32U24 => {
            fold_concrete_words(arena, lane, [a, b], |[a, b]| (mul_u24(a, b) >> 32) as u32)?
        }
        BinOp::MulI32I24 => {
            fold_concrete_words(arena, lane, [a, b], |[a, b]| mul_i24(a, b) as u32)?
        }
        BinOp::MulHiI32I24 => {
            fold_concrete_words(arena, lane, [a, b], |[a, b]| (mul_i24(a, b) >> 32) as u32)?
        }
        BinOp::AddF32 => arena.add(a, b),
        BinOp::SubF32 => arena.sub(a, b),
        BinOp::SubRevF32 => arena.sub(b, a),
        BinOp::MulF32 => arena.mul(a, b),
        BinOp::MinF32 => arena.min(a, b),
        BinOp::MaxF32 => arena.max(a, b),
    })
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

/// `mask ? src1 : src0` in `lane`, each source mixed with the other as `evaluate_cndmask` does.
pub(super) fn evaluate_cndmask_e64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    src0: Vop3Src,
    src1: Vop3Src,
    mask: LaneMask,
) -> Result<ExprId, EvalError> {
    let condition = registers.read_lane_condition(arena, lane, mask)?;
    let a = registers.read_src(arena, lane, src0)?;
    let b = registers.read_src(arena, lane, src1)?;
    // A symbolic source is a real, so a concrete word selected against it must be the f32 its
    // bits encode, or the select would mix raw bits with reals; two words stay bits.
    let (a, b) = match (arena.as_int_const(a), arena.as_int_const(b)) {
        (Some(_), None) => (registers.read_f32_src(arena, lane, src0)?, b),
        (None, Some(_)) => (a, registers.read_f32_src(arena, lane, src1)?),
        _ => (a, b),
    };
    Ok(arena.select(condition, b, a))
}

/// `op(srcs)` in `lane`, each source read as `op`'s operand type.
pub(super) fn evaluate_ternary_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: TernaryOp,
    srcs: [Vop3Src; 3],
) -> Result<ExprId, EvalError> {
    let [a, b, c] = srcs.map(|src| match ternary_operand_type(op) {
        OperandType::Word => registers.read_src(arena, lane, src),
        OperandType::F32 => registers.read_f32_src(arena, lane, src),
    });
    let (a, b, c) = (a?, b?, c?);
    // Require concrete bits only for operands used by the bitwise part of the instruction.
    match op {
        TernaryOp::Bfe32
        | TernaryOp::LShlOr32
        | TernaryOp::Or3_32
        | TernaryOp::AndOr32
        | TernaryOp::Bfi32
        | TernaryOp::AlignBit32
        | TernaryOp::AlignByte32 => {
            concrete_words(arena, lane, [a, b, c])?;
        }
        TernaryOp::LShlAdd32 | TernaryOp::Xad32 => {
            concrete_words(arena, lane, [a, b])?;
        }
        _ => {}
    }
    Ok(match op {
        TernaryOp::AddLShl32 => {
            let sum = arena.add(a, b);
            let sum = low_word(arena, sum);
            concrete_words(arena, lane, [sum, c])?;
            shl32(arena, sum, c)
        }
        TernaryOp::Bfe32 => {
            let shifted = lshr32(arena, a, b);
            let width = low_five_bits(arena, c);
            let one = arena.int(1);
            let bit = arena.shl(one, width);
            let mask = arena.sub(bit, one);
            arena.bit_and(shifted, mask)
        }
        TernaryOp::LShlOr32 => {
            let shifted = shl32(arena, a, b);
            arena.bit_or(shifted, c)
        }
        TernaryOp::Or3_32 => {
            let ab = arena.bit_or(a, b);
            arena.bit_or(ab, c)
        }
        TernaryOp::LShlAdd32 => {
            let shifted = shl32(arena, a, b);
            let sum = arena.add(shifted, c);
            low_word(arena, sum)
        }
        TernaryOp::Add3_32 => {
            let ab = arena.add(a, b);
            let sum = arena.add(ab, c);
            low_word(arena, sum)
        }
        TernaryOp::AndOr32 => {
            let masked = arena.bit_and(a, b);
            arena.bit_or(masked, c)
        }
        TernaryOp::Xad32 => {
            let xor = arena.bit_xor(a, b);
            let sum = arena.add(xor, c);
            low_word(arena, sum)
        }
        TernaryOp::Bfi32 => {
            let inserted = arena.bit_and(a, b);
            let not_a = not32(arena, a);
            let kept = arena.bit_and(not_a, c);
            arena.bit_or(inserted, kept)
        }
        TernaryOp::BfeI32 => {
            fold_concrete_words(arena, lane, [a, b, c], |[a, b, c]| bfe_i32(a, b, c))?
        }
        TernaryOp::AlignBit32 => {
            let amount = low_five_bits(arena, c);
            align(arena, a, b, amount)
        }
        TernaryOp::AlignByte32 => {
            let three = arena.int(3);
            let bytes = arena.bit_and(c, three);
            let eight = arena.int(8);
            let amount = arena.mul(bytes, eight);
            align(arena, a, b, amount)
        }
        TernaryOp::MadU32U24 => fold_concrete_words(arena, lane, [a, b, c], |[a, b, c]| {
            (mul_u24(a, b) as u32).wrapping_add(c)
        })?,
        TernaryOp::MadI32I24 => fold_concrete_words(arena, lane, [a, b, c], |[a, b, c]| {
            (mul_i24(a, b) as u32).wrapping_add(c)
        })?,
        TernaryOp::Min3I32 => fold_concrete_words(arena, lane, [a, b, c], |[a, b, c]| {
            (a as i32).min(b as i32).min(c as i32) as u32
        })?,
        TernaryOp::Max3I32 => fold_concrete_words(arena, lane, [a, b, c], |[a, b, c]| {
            (a as i32).max(b as i32).max(c as i32) as u32
        })?,
        TernaryOp::Med3I32 => fold_concrete_words(arena, lane, [a, b, c], |[a, b, c]| {
            let [a, b, c] = [a, b, c].map(|word| word as i32);
            a.min(b).max(a.max(b).min(c)) as u32
        })?,
        TernaryOp::Min3U32 | TernaryOp::Min3F32 => {
            let ab = arena.min(a, b);
            arena.min(ab, c)
        }
        TernaryOp::Max3U32 | TernaryOp::Max3F32 => {
            let ab = arena.max(a, b);
            arena.max(ab, c)
        }
        TernaryOp::Med3U32 | TernaryOp::Med3F32 => {
            let low = arena.min(a, b);
            let high = arena.max(a, b);
            let capped = arena.min(high, c);
            arena.max(low, capped)
        }
        TernaryOp::SadU32 => {
            let difference = arena.sub(a, b);
            let distance = arena.abs(difference);
            let sum = arena.add(distance, c);
            low_word(arena, sum)
        }
        TernaryOp::BitOp3(table) => {
            let [a, b, c] = [a, b, c].map(|value| concrete_word(arena, value));
            let (Some(a), Some(b), Some(c)) = (a, b, c) else {
                return Err(EvalError::SymbolicWord { lane });
            };
            arena.int(i64::from(bitop3(table, a, b, c)))
        }
    })
}

/// Bit `i` of the result is bit `4 * a_i + 2 * b_i + c_i` of `table`.
fn bitop3(table: u8, a: u32, b: u32, c: u32) -> u32 {
    (0..32)
        .filter(|&bit| {
            let index = ((a >> bit) & 1) << 2 | ((b >> bit) & 1) << 1 | ((c >> bit) & 1);
            (table >> index) & 1 == 1
        })
        .fold(0, |result, bit| result | 1 << bit)
}

/// Read concrete words, rejecting operands whose bit patterns are unknown.
fn concrete_words<const N: usize>(
    arena: &ExprArena,
    lane: usize,
    values: [ExprId; N],
) -> Result<[u32; N], EvalError> {
    let mut words = [0; N];
    for (word, value) in words.iter_mut().zip(values) {
        *word = concrete_word(arena, value).ok_or(EvalError::SymbolicWord { lane })?;
    }
    Ok(words)
}

/// Evaluate `op` on concrete words and store the result in the expression arena.
fn fold_concrete_words<const N: usize>(
    arena: &mut ExprArena,
    lane: usize,
    values: [ExprId; N],
    op: impl FnOnce([u32; N]) -> u32,
) -> Result<ExprId, EvalError> {
    let words = concrete_words(arena, lane, values)?;
    Ok(arena.int(i64::from(op(words))))
}

fn mul_u24(a: u32, b: u32) -> u64 {
    u64::from(a & 0xff_ffff) * u64::from(b & 0xff_ffff)
}

fn mul_i24(a: u32, b: u32) -> i64 {
    let sext24 = |word: u32| ((word << 8) as i32) >> 8;
    i64::from(sext24(a)) * i64::from(sext24(b))
}

/// The `width`-bit field of `value` at bit `offset`, sign-extended, as LLVM 21.1.8's
/// `constantFoldBFE` computes it: a field past bit 31 is the arithmetic shift.
fn bfe_i32(value: u32, offset: u32, width: u32) -> u32 {
    let (offset, width) = (offset & 31, width & 31);
    if width == 0 {
        0
    } else if offset + width < 32 {
        (((value << (32 - offset - width)) as i32) >> (32 - width)) as u32
    } else {
        ((value as i32) >> offset) as u32
    }
}

/// The low word of the 64-bit `high:low` shifted right by `amount`, which is below 32.
fn align(arena: &mut ExprArena, high: ExprId, low: ExprId, amount: ExprId) -> ExprId {
    let thirty_two = arena.int(32);
    let upper = arena.shl(high, thirty_two);
    let joined = arena.bit_or(upper, low);
    let shifted = arena.lshr(joined, amount);
    let mask = arena.int(i64::from(u32::MAX));
    arena.bit_and(shifted, mask)
}

/// The word's 32 bits inverted.
fn not32(arena: &mut ExprArena, value: ExprId) -> ExprId {
    let mask = arena.int(i64::from(u32::MAX));
    arena.bit_xor(value, mask)
}

/// `op src` in `lane`, the source read as `op`'s operand type.
pub(super) fn evaluate_unary_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: UnaryOp,
    src: Src0,
) -> Result<ExprId, EvalError> {
    let a = match unary_operand_type(op) {
        OperandType::Word => registers.read_src0(arena, lane, src)?,
        OperandType::F32 => registers.read_f32_src0(arena, lane, src)?,
    };

    let non_symbolic_word =
        |arena: &ExprArena| concrete_word(arena, a).ok_or(EvalError::SymbolicWord { lane });

    Ok(match op {
        UnaryOp::Mov32 => a,
        UnaryOp::BfRev32 => {
            let reversed = non_symbolic_word(arena)?.reverse_bits();
            arena.int(i64::from(reversed))
        }
        UnaryOp::CvtF32U32 => {
            let value = Real::from_i64(i64::from(non_symbolic_word(arena)?));
            arena.real(value)
        }
        UnaryOp::CvtU32F32 => {
            let truncated = truncate_to_u32(arena, a).ok_or(EvalError::SymbolicWord { lane })?;
            arena.int(i64::from(truncated))
        }
        UnaryOp::RcpIflagF32 | UnaryOp::RcpF32 => arena.rcp(a),
        UnaryOp::Exp2F32 => arena.exp2(a),
        UnaryOp::Log2F32 => arena.log2(a),
        UnaryOp::SqrtF32 => arena.sqrt(a),
        UnaryOp::RsqF32 => {
            let root = arena.sqrt(a);
            arena.rcp(root)
        }
    })
}

fn unary_operand_type(op: UnaryOp) -> OperandType {
    match op {
        UnaryOp::Mov32 | UnaryOp::BfRev32 | UnaryOp::CvtF32U32 => OperandType::Word,
        UnaryOp::CvtU32F32
        | UnaryOp::RcpIflagF32
        | UnaryOp::Exp2F32
        | UnaryOp::Log2F32
        | UnaryOp::RcpF32
        | UnaryOp::SqrtF32
        | UnaryOp::RsqF32 => OperandType::F32,
    }
}

fn cmp_operand_type(op: CmpOp) -> OperandType {
    match op {
        CmpOp::LtI32
        | CmpOp::EqI32
        | CmpOp::LeI32
        | CmpOp::GtI32
        | CmpOp::NeI32
        | CmpOp::GeI32
        | CmpOp::LtU32
        | CmpOp::EqU32
        | CmpOp::LeU32
        | CmpOp::GtU32
        | CmpOp::NeU32
        | CmpOp::GeU32 => OperandType::Word,
        CmpOp::LtF32 | CmpOp::LeF32 | CmpOp::EqF32 | CmpOp::LgF32 => OperandType::F32,
    }
}

/// The boolean `src0 op src1` in `lane`, each source read as `op`'s operand type.
pub(super) fn evaluate_cmp(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CmpOp,
    src0: Src0,
    src1: Vgpr,
) -> Result<ExprId, EvalError> {
    let (a, b) = match cmp_operand_type(op) {
        OperandType::Word => (
            registers.read_src0(arena, lane, src0)?,
            registers.read_vgpr(lane, src1)?,
        ),
        OperandType::F32 => (
            registers.read_f32_src0(arena, lane, src0)?,
            registers.read_f32(arena, lane, src1)?,
        ),
    };
    compare(arena, lane, op, a, b)
}

/// `evaluate_cmp` over VOP3 sources.
pub(super) fn evaluate_cmp_e64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CmpOp,
    src0: Vop3Src,
    src1: Vop3Src,
) -> Result<ExprId, EvalError> {
    let (a, b) = match cmp_operand_type(op) {
        OperandType::Word => (
            registers.read_src(arena, lane, src0)?,
            registers.read_src(arena, lane, src1)?,
        ),
        OperandType::F32 => (
            registers.read_f32_src(arena, lane, src0)?,
            registers.read_f32_src(arena, lane, src1)?,
        ),
    };
    compare(arena, lane, op, a, b)
}

/// An integer comparison needs concrete words, which it reinterprets as `op`'s signedness.
fn compare(
    arena: &mut ExprArena,
    lane: usize,
    op: CmpOp,
    a: ExprId,
    b: ExprId,
) -> Result<ExprId, EvalError> {
    let words = |arena: &ExprArena| match (concrete_word(arena, a), concrete_word(arena, b)) {
        (Some(a), Some(b)) => Ok((a, b)),
        _ => Err(EvalError::SymbolicWord { lane }),
    };
    let signed = |arena: &ExprArena| words(arena).map(|(a, b)| (a as i32).cmp(&(b as i32)));
    let unsigned = |arena: &ExprArena| words(arena).map(|(a, b)| a.cmp(&b));

    Ok(match op {
        CmpOp::LtI32 => arena.bool_val(signed(arena)?.is_lt()),
        CmpOp::EqI32 => arena.bool_val(signed(arena)?.is_eq()),
        CmpOp::LeI32 => arena.bool_val(signed(arena)?.is_le()),
        CmpOp::GtI32 => arena.bool_val(signed(arena)?.is_gt()),
        CmpOp::NeI32 => arena.bool_val(signed(arena)?.is_ne()),
        CmpOp::GeI32 => arena.bool_val(signed(arena)?.is_ge()),
        CmpOp::LtU32 => arena.bool_val(unsigned(arena)?.is_lt()),
        CmpOp::EqU32 => arena.bool_val(unsigned(arena)?.is_eq()),
        CmpOp::LeU32 => arena.bool_val(unsigned(arena)?.is_le()),
        CmpOp::GtU32 => arena.bool_val(unsigned(arena)?.is_gt()),
        CmpOp::NeU32 => arena.bool_val(unsigned(arena)?.is_ne()),
        CmpOp::GeU32 => arena.bool_val(unsigned(arena)?.is_ge()),
        CmpOp::LtF32 => arena.lt(a, b),
        CmpOp::LeF32 => arena.le(a, b),
        CmpOp::EqF32 => arena.eq(a, b),
        CmpOp::LgF32 => arena.ne(a, b),
    })
}

/// A concrete real truncated toward zero and clamped to the u32 range; `None` when symbolic.
fn truncate_to_u32(arena: &ExprArena, value: ExprId) -> Option<u32> {
    let ExprNode::RealConst(real) = arena.node(value) else {
        return None;
    };
    Some(match real.repr() {
        RealRepr::NegInf => 0,
        RealRepr::PosInf => u32::MAX,
        RealRepr::Rational(rational) => {
            let integer = rational.clone().trunc();
            let integer = integer.numer();
            match integer.to_u32() {
                Some(word) => word,
                None if integer.is_negative() => 0,
                None => u32::MAX,
            }
        }
    })
}

/// Keep a concrete result's low 32 bits; preserve symbolic arithmetic.
fn low_word(arena: &mut ExprArena, value: ExprId) -> ExprId {
    if arena.as_int_const(value).is_some() {
        let mask = arena.int(i64::from(u32::MAX));
        arena.bit_and(value, mask)
    } else {
        value
    }
}

/// `count & 31`: AMD uses only the low five bits of a shift count, so 34 becomes 2 and 32
/// becomes 0.
fn low_five_bits(arena: &mut ExprArena, count: ExprId) -> ExprId {
    let mask = arena.int(31);
    arena.bit_and(count, mask)
}

/// `value << (shift & 31)`, keeping the low 32 bits.
fn shl32(arena: &mut ExprArena, value: ExprId, shift: ExprId) -> ExprId {
    let amount = low_five_bits(arena, shift);
    let shifted = arena.shl(value, amount);
    low_word(arena, shifted)
}

/// The logical `value >> (shift & 31)`.
fn lshr32(arena: &mut ExprArena, value: ExprId, shift: ExprId) -> ExprId {
    let amount = low_five_bits(arena, shift);
    arena.lshr(value, amount)
}
