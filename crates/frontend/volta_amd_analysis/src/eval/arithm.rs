//! Vector ALU arithmetic: the value of a unary, binary, ternary or comparison operation in one
//! lane.

use std::num::NonZeroI64;

use volta_common::float_bits::{F8Format, decode_e4m3_byte, decode_e5m2_byte};
use volta_expr::symbolic_full::{self, ExprArena, ExprId, ExprNode, Real, RealRepr, Type, Width};

use crate::ir::{
    BinOp, CmpOp, CmpPredicate, CvtFromF64Op, CvtToF64Op, DppOp, F64Op, F64Src, LaneMask,
    ModifiedSrc, PackedF32Op, Signedness, Src0, TernaryOp, UnaryOp, Vgpr, Vop3BinOp, Vop3Src,
    WordHalf,
};

use super::EvalError;

const F32: Type = Type::Float(Width(32));
const F64: Type = Type::Float(Width(64));
const B32: Type = Type::Bits(Width(32));
const B64: Type = Type::Bits(Width(64));
const U32: Type = Type::Int(symbolic_full::Signedness::Unsigned, Width(32));
const I32: Type = Type::Int(symbolic_full::Signedness::Signed, Width(32));
use super::wave::{WaveRegisters, apply_modifiers, as_f32, concrete_word};
use super::word::Word;
use super::word::compare_bf16_field;

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
    if op.is_f32() {
        OperandType::F32
    } else {
        OperandType::Word
    }
}

/// `src0 op src1` in `lane`, each source read as `op`'s operand type.
pub(super) fn evaluate_bin_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: BinOp,
    src0: ModifiedSrc,
    src1: ModifiedSrc,
) -> Result<ExprId, EvalError> {
    let (a, b) = match operand_type(op) {
        // Input modifiers are defined for floats only.
        OperandType::Word if src0.is_modified() || src1.is_modified() => {
            return Err(EvalError::UnsupportedInstruction);
        }
        OperandType::Word => (
            registers.read_src(arena, lane, src0.src)?,
            registers.read_src(arena, lane, src1.src)?,
        ),
        OperandType::F32 => (
            registers.read_modified_src(arena, lane, src0)?,
            registers.read_modified_src(arena, lane, src1)?,
        ),
    };
    bin_op_values(arena, lane, op, a, b)
}

/// One DPP lane's result: `op` of `src0`'s word from the selected lane, its modifiers applied
/// as a float operation applies them, and of this lane's `src1`.
pub(super) fn evaluate_dpp_lane(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: DppOp,
    src0: Word,
    modifiers: ModifiedSrc<Vgpr>,
    src1: ModifiedSrc,
) -> Result<Word, EvalError> {
    let bin_op = match op {
        DppOp::Mov if modifiers.is_modified() => return Err(EvalError::UnsupportedInstruction),
        DppOp::Mov => return Ok(src0),
        DppOp::Bin(bin_op) => bin_op,
    };
    let Word::Value(value) = src0 else {
        return Err(EvalError::Bf16Halves {
            lane,
            reg: modifiers.src,
        });
    };
    let (a, b) = match operand_type(bin_op) {
        OperandType::Word if modifiers.is_modified() || src1.is_modified() => {
            return Err(EvalError::UnsupportedInstruction);
        }
        OperandType::Word => (value, registers.read_src(arena, lane, src1.src)?),
        OperandType::F32 => {
            let value = as_f32(arena, value).ok_or(EvalError::InvalidFloatVgpr {
                lane,
                reg: modifiers.src,
            })?;
            let a = apply_modifiers(arena, F32, value, modifiers.abs, modifiers.neg);
            (a, registers.read_modified_src(arena, lane, src1)?)
        }
    };
    bin_op_values(arena, lane, bin_op, a, b).map(Word::Value)
}

/// `op` of two operands already read as `operand_type(op)` reads them.
fn bin_op_values(
    arena: &mut ExprArena,
    lane: usize,
    op: BinOp,
    a: ExprId,
    b: ExprId,
) -> Result<ExprId, EvalError> {
    if let Some(result) = sign_bit_op(arena, op, a, b) {
        return Ok(result);
    }
    if let Some(result) = exponent_op(arena, op, a, b) {
        return Ok(result);
    }
    // Integer operations need concrete words: a symbolic value is a float, without known bits.
    if matches!(operand_type(op), OperandType::Word) {
        concrete_words(arena, lane, [a, b])?;
    }
    Ok(match op {
        BinOp::And32 => arena.bit_and(B32, a, b),
        BinOp::Or32 => arena.bit_or(B32, a, b),
        BinOp::Xor32 => arena.bit_xor(B32, a, b),
        BinOp::LShlRev32 => shl32(arena, b, a),
        BinOp::LShrRev32 => lshr32(arena, b, a),
        BinOp::AddU32 => {
            let sum = arena.add(U32, a, b);
            low_word(arena, sum)
        }
        BinOp::SubU32 => {
            let difference = arena.sub(U32, a, b);
            low_word(arena, difference)
        }
        BinOp::SubRevU32 => {
            let difference = arena.sub(U32, b, a);
            low_word(arena, difference)
        }
        BinOp::AShrRevI32 => fold_concrete_words(arena, lane, [a, b], |[a, b]| {
            ((b as i32) >> (a & 31)) as u32
        })?,
        BinOp::Xnor32 => {
            let xor = arena.bit_xor(B32, a, b);
            not32(arena, xor)
        }
        BinOp::MinI32 => fold_concrete_words(arena, lane, [a, b], |[a, b]| {
            (a as i32).min(b as i32) as u32
        })?,
        BinOp::MaxI32 => fold_concrete_words(arena, lane, [a, b], |[a, b]| {
            (a as i32).max(b as i32) as u32
        })?,
        BinOp::MinU32 => arena.min(U32, a, b),
        BinOp::MaxU32 => arena.max(U32, a, b),
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
        BinOp::AddF32 => arena.add(F32, a, b),
        BinOp::SubF32 => arena.sub(F32, a, b),
        BinOp::SubRevF32 => arena.sub(F32, b, a),
        BinOp::MulF32 => arena.mul(F32, a, b),
        BinOp::MinF32 => arena.min(F32, a, b),
        BinOp::MaxF32 => arena.max(F32, a, b),
    })
}

/// Compute both packed f32 results before the caller overwrites any source registers.
pub(super) fn evaluate_packed_f32(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: PackedF32Op,
) -> Result<[ExprId; 2], EvalError> {
    let mut component = |index| -> Result<ExprId, EvalError> {
        let mut read =
            |srcs: [ModifiedSrc; 2]| registers.read_modified_src(arena, lane, srcs[index]);
        match op {
            PackedF32Op::Add([src0, src1]) => {
                let a = read(src0)?;
                let b = read(src1)?;
                Ok(arena.add(F32, a, b))
            }
            PackedF32Op::Mul([src0, src1]) => {
                let a = read(src0)?;
                let b = read(src1)?;
                Ok(arena.mul(F32, a, b))
            }
            PackedF32Op::Fma([src0, src1, src2]) => {
                let a = read(src0)?;
                let b = read(src1)?;
                let c = read(src2)?;
                Ok(arena.fma(F32, a, b, c))
            }
        }
    };
    Ok([component(0)?, component(1)?])
}

/// `op(srcs)` in `lane`, as one f64 value.
pub(super) fn evaluate_f64_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: F64Op,
) -> Result<ExprId, EvalError> {
    let mut read = |src| registers.read_modified_f64(arena, lane, src);
    Ok(match op {
        F64Op::Add([a, b]) => {
            let (a, b) = (read(a)?, read(b)?);
            arena.add(F64, a, b)
        }
        F64Op::Mul([a, b]) => {
            let (a, b) = (read(a)?, read(b)?);
            arena.mul(F64, a, b)
        }
        F64Op::Min([a, b]) => {
            let (a, b) = (read(a)?, read(b)?);
            arena.min(F64, a, b)
        }
        F64Op::Max([a, b]) => {
            let (a, b) = (read(a)?, read(b)?);
            arena.max(F64, a, b)
        }
        F64Op::Fma([a, b, c]) => {
            let (a, b, c) = (read(a)?, read(b)?, read(c)?);
            arena.fma(F64, a, b, c)
        }
        F64Op::Rcp([a]) => {
            let a = read(a)?;
            arena.rcp(F64, a)
        }
        F64Op::Sqrt([a]) => {
            let a = read(a)?;
            arena.sqrt(F64, a)
        }
        F64Op::Rsq([a]) => {
            let a = read(a)?;
            arena.rsqrt(F64, a)
        }
    })
}

/// A conversion's source as a real: an f32 keeps its expression, and an integer needs known bits.
pub(super) fn evaluate_cvt_to_f64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CvtToF64Op,
    src: ModifiedSrc<Src0>,
) -> Result<ExprId, EvalError> {
    let concrete = |arena: &mut ExprArena| {
        let value = registers.read_src0(arena, lane, src.src)?;
        concrete_words(arena, lane, [value]).map(|[word]| word)
    };
    let integer = match op {
        CvtToF64Op::F32 => {
            let value = registers.read_f32_src0(arena, lane, src.src)?;
            return Ok(apply_modifiers(arena, F32, value, src.abs, src.neg));
        }
        CvtToF64Op::I32 => i64::from(concrete(arena)? as i32),
        CvtToF64Op::U32 => i64::from(concrete(arena)?),
    };
    Ok(arena.real(Real::from_i64(integer)))
}

/// An f64 source converted to `op`'s type: an f32 keeps the exact real, and an integer needs a
/// concrete value.
pub(super) fn evaluate_cvt_from_f64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CvtFromF64Op,
    src: ModifiedSrc<F64Src>,
) -> Result<ExprId, EvalError> {
    let value = registers.read_modified_f64(arena, lane, src)?;
    let symbolic = EvalError::SymbolicWord { lane };
    Ok(match op {
        CvtFromF64Op::F32 => value,
        CvtFromF64Op::I32 => {
            let truncated = truncate_to_i32(arena, value).ok_or(symbolic)?;
            arena.int(i64::from(truncated as u32))
        }
        CvtFromF64Op::U32 => {
            let truncated = truncate_to_u32(arena, value).ok_or(symbolic)?;
            arena.int(i64::from(truncated))
        }
    })
}

/// The boolean `src0 op src1` in `lane` over f64 values.
pub(super) fn evaluate_cmp_f64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CmpPredicate,
    src0: ModifiedSrc<F64Src>,
    src1: ModifiedSrc<F64Src>,
) -> Result<ExprId, EvalError> {
    let a = registers.read_modified_f64(arena, lane, src0)?;
    let b = registers.read_modified_f64(arena, lane, src1)?;
    Ok(match op {
        CmpPredicate::Lt => arena.lt(F64, a, b),
        CmpPredicate::Eq => arena.eq(F64, a, b),
        CmpPredicate::Le => arena.le(F64, a, b),
        CmpPredicate::Gt => arena.gt(F64, a, b),
        CmpPredicate::Ne => arena.ne(F64, a, b),
        CmpPredicate::Ge => arena.ge(F64, a, b),
    })
}

/// `VCC ? src1 : src0` in `lane`. A word selected against a real is the f32 its bits encode,
/// read as `WaveRegisters::read_f32` reads it; two words are selected by `select_words`.
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
    if let Some(word) = select_equal(arena, condition, a, b) {
        return Ok(word);
    }
    if let Some(word) = select_words(arena, lane, condition, a, b)? {
        return Ok(word);
    }
    let (a, b) = match (arena.as_int_const(a), arena.as_int_const(b)) {
        (Some(_), None) => (registers.read_f32_src0(arena, lane, src0)?, b),
        (None, Some(_)) => (a, registers.read_f32(arena, lane, src1)?),
        _ => (a, b),
    };
    if let Some(value) = select_exp_range_guard(arena, condition, a, b) {
        return Ok(value);
    }
    if let Some(value) = select_scaled_root(arena, condition, a, b) {
        return Ok(value);
    }
    if let Some(value) = select_extremum(arena, condition, a, b) {
        return Ok(value);
    }
    Ok(arena.select(B32, condition, b, a))
}

/// `mask ? src1 : src0` in `lane`, each source mixed with the other as `evaluate_cndmask` does.
pub(super) fn evaluate_cndmask_e64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    src0: ModifiedSrc,
    src1: ModifiedSrc,
    mask: LaneMask,
) -> Result<ExprId, EvalError> {
    let condition = registers.read_lane_condition(arena, lane, mask)?;
    // Source modifiers give the select float semantics (V_CNDMASK_B32).
    if src0.is_modified() || src1.is_modified() {
        let a = registers.read_modified_src(arena, lane, src0)?;
        let b = registers.read_modified_src(arena, lane, src1)?;
        return Ok(arena.select(B32, condition, b, a));
    }
    let a = registers.read_src(arena, lane, src0.src)?;
    let b = registers.read_src(arena, lane, src1.src)?;
    if let Some(word) = select_equal(arena, condition, a, b) {
        return Ok(word);
    }
    if let Some(word) = select_words(arena, lane, condition, a, b)? {
        return Ok(word);
    }
    // A symbolic source is a real, so a concrete word selected against it must be the f32 its
    // bits encode, or the select would mix raw bits with reals.
    let (a, b) = match (arena.as_int_const(a), arena.as_int_const(b)) {
        (Some(_), None) => (registers.read_f32_src(arena, lane, src0.src)?, b),
        (None, Some(_)) => (a, registers.read_f32_src(arena, lane, src1.src)?),
        _ => (a, b),
    };
    if let Some(value) = select_exp_range_guard(arena, condition, a, b) {
        return Ok(value);
    }
    if let Some(value) = select_scaled_root(arena, condition, a, b) {
        return Ok(value);
    }
    if let Some(value) = select_extremum(arena, condition, a, b) {
        return Ok(value);
    }
    Ok(arena.select(B32, condition, b, a))
}

/// `condition ? b : a` for two concrete words: the word when both agree, else the chosen word
/// under a concrete condition. A symbolic condition would yield a value that is neither a
/// concrete integer nor a known float, so it is rejected. `None` unless both are words.
fn select_words(
    arena: &mut ExprArena,
    lane: usize,
    condition: ExprId,
    a: ExprId,
    b: ExprId,
) -> Result<Option<ExprId>, EvalError> {
    let (Some(x), Some(y)) = (arena.as_int_const(a), arena.as_int_const(b)) else {
        return Ok(None);
    };
    if x == y {
        return Ok(Some(a));
    }
    match arena.as_bool(condition) {
        Some(_) => Ok(Some(arena.select(B32, condition, b, a))),
        None => Err(EvalError::AmbiguousSelect { lane }),
    }
}

/// `op(srcs)` in `lane`, each source read as `op`'s operand type.
pub(super) fn evaluate_ternary_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: TernaryOp,
    srcs: [ModifiedSrc; 3],
) -> Result<ExprId, EvalError> {
    let [a, b, c] = srcs.map(|src| match ternary_operand_type(op) {
        OperandType::Word => registers.read_src(arena, lane, src.src),
        OperandType::F32 => registers.read_modified_src(arena, lane, src),
    });
    let (a, b, c) = (a?, b?, c?);
    // Integer operations need concrete words: a symbolic value is a float, without known bits.
    if matches!(ternary_operand_type(op), OperandType::Word) {
        concrete_words(arena, lane, [a, b, c])?;
    }
    let min_max = if op.is_f32() { F32 } else { U32 };
    Ok(match op {
        TernaryOp::AddLShl32 => {
            let sum = arena.add(U32, a, b);
            let sum = low_word(arena, sum);
            shl32(arena, sum, c)
        }
        TernaryOp::Bfe32 => {
            let shifted = lshr32(arena, a, b);
            let width = low_five_bits(arena, c);
            let one = arena.int(1);
            let bit = arena.shl(B32, one, width);
            let mask = arena.sub(U32, bit, one);
            arena.bit_and(B32, shifted, mask)
        }
        TernaryOp::LShlOr32 => {
            let shifted = shl32(arena, a, b);
            arena.bit_or(B32, shifted, c)
        }
        TernaryOp::Or3_32 => {
            let ab = arena.bit_or(B32, a, b);
            arena.bit_or(B32, ab, c)
        }
        TernaryOp::LShlAdd32 => {
            let shifted = shl32(arena, a, b);
            let sum = arena.add(U32, shifted, c);
            low_word(arena, sum)
        }
        TernaryOp::Add3_32 => {
            let ab = arena.add(U32, a, b);
            let sum = arena.add(U32, ab, c);
            low_word(arena, sum)
        }
        TernaryOp::AndOr32 => {
            let masked = arena.bit_and(B32, a, b);
            arena.bit_or(B32, masked, c)
        }
        TernaryOp::Xad32 => {
            let xor = arena.bit_xor(B32, a, b);
            let sum = arena.add(U32, xor, c);
            low_word(arena, sum)
        }
        TernaryOp::Bfi32 => {
            let inserted = arena.bit_and(B32, a, b);
            let not_a = not32(arena, a);
            let kept = arena.bit_and(B32, not_a, c);
            arena.bit_or(B32, inserted, kept)
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
            let bytes = arena.bit_and(B32, c, three);
            let eight = arena.int(8);
            let amount = arena.mul(U32, bytes, eight);
            align(arena, a, b, amount)
        }
        TernaryOp::Perm32 => {
            fold_concrete_words(arena, lane, [a, b, c], |[a, b, c]| perm32(a, b, c))?
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
            let ab = arena.min(min_max, a, b);
            arena.min(min_max, ab, c)
        }
        TernaryOp::Max3U32 | TernaryOp::Max3F32 => {
            let ab = arena.max(min_max, a, b);
            arena.max(min_max, ab, c)
        }
        TernaryOp::Med3U32 | TernaryOp::Med3F32 => arena.median3(min_max, a, b, c),
        TernaryOp::SadU32 => {
            let difference = arena.sub(U32, a, b);
            let distance = arena.abs(U32, difference);
            let sum = arena.add(U32, distance, c);
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

/// Evaluate `op(src0, src1)` in `lane` on concrete 32-bit integers, rejecting symbolic operands.
pub(super) fn evaluate_vop3_bin_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: Vop3BinOp,
    src0: Vop3Src,
    src1: Vop3Src,
) -> Result<ExprId, EvalError> {
    let a = registers.read_src(arena, lane, src0)?;
    let b = registers.read_src(arena, lane, src1)?;
    // Bit `n` is set for each lane `n` below this one; each masked count examines one word of it.
    let lower_lanes = (1u64 << lane) - 1;
    fold_concrete_words(arena, lane, [a, b], |[a, b]| match op {
        Vop3BinOp::MulLoU32 => a.wrapping_mul(b),
        Vop3BinOp::MulHiU32 => ((u64::from(a) * u64::from(b)) >> 32) as u32,
        Vop3BinOp::MulHiI32 => ((i64::from(a as i32) * i64::from(b as i32)) >> 32) as u32,
        Vop3BinOp::BcntU32 => b.wrapping_add(a.count_ones()),
        Vop3BinOp::MbcntLoU32 => b.wrapping_add((a & lower_lanes as u32).count_ones()),
        Vop3BinOp::MbcntHiU32 => b.wrapping_add((a & (lower_lanes >> 32) as u32).count_ones()),
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

/// `x & 0x7fffffff` clears a float's sign bit and `x ^ 0x80000000` flips it: a symbolic `x`
/// is an f32, so the operation is typed f32 and lowering makes it `|x|` or `-x` exactly.
fn sign_bit_op(arena: &mut ExprArena, op: BinOp, a: ExprId, b: ExprId) -> Option<ExprId> {
    let (mask, value) = match (concrete_word(arena, a), concrete_word(arena, b)) {
        (Some(mask), None) => (mask, b),
        (None, Some(mask)) => (mask, a),
        _ => return None,
    };
    if matches!(arena.value_node(value), ExprNode::Undefined) {
        return None;
    }
    match (op, mask) {
        (BinOp::And32, 0x7fff_ffff) => {
            let mask = arena.int(0x7fff_ffff);
            Some(arena.bit_and(F32, value, mask))
        }
        (BinOp::Xor32, 0x8000_0000) => {
            let mask = arena.int(0x8000_0000);
            Some(arena.bit_xor(F32, value, mask))
        }
        _ => None,
    }
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
    let upper = arena.shl(B64, high, thirty_two);
    let joined = arena.bit_or(B64, upper, low);
    let shifted = arena.lshr(B64, joined, amount);
    let mask = arena.int(i64::from(u32::MAX));
    arena.bit_and(B64, shifted, mask)
}

/// The word's 32 bits inverted.
fn not32(arena: &mut ExprArena, value: ExprId) -> ExprId {
    let mask = arena.int(i64::from(u32::MAX));
    arena.bit_xor(B32, value, mask)
}

/// `op src` in `lane`, the source read as `op`'s operand type, an f32 one after its input
/// modifiers.
pub(super) fn evaluate_unary_op(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: UnaryOp,
    src: ModifiedSrc,
) -> Result<ExprId, EvalError> {
    let a = match unary_operand_type(op) {
        OperandType::Word => registers.read_src(arena, lane, src.src)?,
        OperandType::F32 => registers.read_modified_src(arena, lane, src)?,
    };

    let non_symbolic_word =
        |arena: &ExprArena| concrete_word(arena, a).ok_or(EvalError::SymbolicWord { lane });

    Ok(match op {
        UnaryOp::Mov32 => a,
        UnaryOp::Not32 => {
            non_symbolic_word(arena)?;
            not32(arena, a)
        }
        UnaryOp::BfRev32 => {
            let reversed = non_symbolic_word(arena)?.reverse_bits();
            arena.int(i64::from(reversed))
        }
        UnaryOp::CvtF32I32 => {
            let value = Real::from_i64(i64::from(non_symbolic_word(arena)? as i32));
            arena.real(value)
        }
        UnaryOp::CvtF32U32 => {
            let value = Real::from_i64(i64::from(non_symbolic_word(arena)?));
            arena.real(value)
        }
        UnaryOp::CvtOffF32I4 => {
            let nibble = i64::from(non_symbolic_word(arena)? & 0xf);
            let signed = if nibble < 8 { nibble } else { nibble - 16 };
            let value = Real::from_ratio(signed, NonZeroI64::new(16).expect("16 is nonzero"));
            arena.real(value)
        }
        UnaryOp::CvtF32Ubyte(byte) => {
            let value = (non_symbolic_word(arena)? >> byte.shift()) & 0xff;
            arena.real(Real::from_i64(i64::from(value)))
        }
        UnaryOp::CvtI32F32 => match (truncate_to_i32(arena, a), arena.value_node(a)) {
            (Some(truncated), _) => arena.int(i64::from(truncated as u32)),
            // A rounded real is an integer already: kept as a symbolic i32 for `v_ldexp_f32`.
            (None, &ExprNode::RoundEven(x)) => arena.round_even(I32, x),
            (None, _) => return Err(EvalError::SymbolicWord { lane }),
        },
        UnaryOp::CvtU32F32 => {
            let truncated = truncate_to_u32(arena, a).ok_or(EvalError::SymbolicWord { lane })?;
            arena.int(i64::from(truncated))
        }
        UnaryOp::RcpIflagF32 | UnaryOp::RcpF32 => arena.rcp(F32, a),
        UnaryOp::Exp2F32 => arena.exp2(F32, a),
        UnaryOp::Log2F32 => arena.log2(F32, a),
        UnaryOp::SqrtF32 => arena.sqrt(F32, a),
        UnaryOp::RsqF32 => arena.rsqrt(F32, a),
        UnaryOp::RndneF32 => arena.round_even(F32, a),
        UnaryOp::TruncF32 => arena.trunc(F32, a),
        UnaryOp::FrexpMantF32 => match arena.as_f64(a) {
            Some(value) => {
                let (mantissa, _) = frexp(value);
                arena.real(Real::from_f64(mantissa).expect("a real's mantissa is not a NaN"))
            }
            None => {
                let exponent = frexp_exponent(arena, a);
                let negated = arena.neg(I32, exponent);
                scale_by_exponent(arena, a, negated)
            }
        },
        UnaryOp::FrexpExpI32F32 => match arena.as_f64(a) {
            Some(value) => arena.int(i64::from(frexp(value).1 as u32)),
            None => frexp_exponent(arena, a),
        },
    })
}

/// The hardware's `(m, e)` with `value = m * 2^e` and `|m|` in [1/2, 1); 0, infinities and
/// NaN give `(value, 0)`. Every f32 is a normal f64, so the f64 exponent field gives `e`.
fn frexp(value: f64) -> (f64, i32) {
    if value == 0.0 || !value.is_finite() {
        return (value, 0);
    }
    let exponent = ((value.to_bits() >> 52) & 0x7ff) as i32 - 1022;
    (value / 2f64.powi(exponent), exponent)
}

/// frexp's exponent of a symbolic real `x`, `floor(log2 |x|) + 1`, typed i32: with a rounded
/// real converted to i32, the only symbolic integers this interpreter builds (`exponent_op`,
/// `evaluate_ldexp_f32`). The solver takes its truncation and select as uninterpreted.
fn frexp_exponent(arena: &mut ExprArena, x: ExprId) -> ExprId {
    let magnitude = arena.abs(F32, x);
    let log = arena.log2(F32, magnitude);
    let truncated = arena.trunc(F32, log);
    let below = arena.lt(F32, log, truncated);
    let (one, zero) = (arena.int(1), arena.int(0));
    let correction = arena.select(I32, below, one, zero);
    let floor = arena.sub(I32, truncated, correction);
    arena.add(I32, floor, one)
}

/// A symbolic frexp exponent, as `frexp_exponent` types it.
fn is_symbolic_exponent(arena: &ExprArena, value: ExprId) -> bool {
    arena.ty(value) == Some(I32) && concrete_word(arena, value).is_none()
}

/// An integer add or subtract of frexp exponents and concrete words, kept exact: exponents are
/// within a few hundred of zero, where 32-bit arithmetic does not wrap. `None` unless an
/// operand is a symbolic exponent and the other one is too or is concrete.
fn exponent_op(arena: &mut ExprArena, op: BinOp, a: ExprId, b: ExprId) -> Option<ExprId> {
    if !is_symbolic_exponent(arena, a) && !is_symbolic_exponent(arena, b) {
        return None;
    }
    let mut signed = |value: ExprId| -> Option<ExprId> {
        if is_symbolic_exponent(arena, value) {
            return Some(value);
        }
        let word = concrete_word(arena, value)?;
        Some(arena.int(i64::from(word as i32)))
    };
    let (a, b) = (signed(a)?, signed(b)?);
    match op {
        BinOp::AddU32 => Some(arena.add(I32, a, b)),
        BinOp::SubU32 => Some(arena.sub(I32, a, b)),
        BinOp::SubRevU32 => Some(arena.sub(I32, b, a)),
        _ => None,
    }
}

/// `src0 * 2^src1` in `lane`, for a concrete i32 exponent.
pub(super) fn evaluate_ldexp_f32(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    src0: ModifiedSrc,
    src1: Vop3Src,
) -> Result<ExprId, EvalError> {
    let value = registers.read_modified_src(arena, lane, src0)?;
    let exponent = registers.read_src(arena, lane, src1)?;
    if let Some(exponent) = concrete_word(arena, exponent) {
        return Ok(scale_by_power_of_two(arena, value, exponent as i32));
    }
    if is_symbolic_exponent(arena, exponent) {
        if let Some(exponential) = undo_exp_range_reduction(arena, value, exponent) {
            return Ok(exponential);
        }
        return Ok(scale_by_exponent(arena, value, exponent));
    }
    Err(EvalError::SymbolicWord { lane })
}

/// LLVM's accurate `expf(x)`: `exp2((h - r) + l) * 2^r`, `r = rndne(h)`, with `h = x * c_hi` and
/// `l = fma(x, c_lo, fma(x, c_hi, -h))`, which is `exp2(x * (c_hi + c_lo))` over the reals.
/// `None` unless `value` and the symbolic `exponent` have exactly that form.
fn undo_exp_range_reduction(
    arena: &mut ExprArena,
    value: ExprId,
    exponent: ExprId,
) -> Option<ExprId> {
    let ExprNode::RoundEven(high) = *arena.value_node(exponent) else {
        return None;
    };
    let ExprNode::Exp2(argument) = *arena.value_node(value) else {
        return None;
    };
    let ExprNode::Add(p, q) = *arena.value_node(argument) else {
        return None;
    };
    let low = [(p, q), (q, p)].into_iter().find_map(|(reduced, low)| {
        let ExprNode::Sub(h, rounded) = *arena.value_node(reduced) else {
            return None;
        };
        let ExprNode::RoundEven(h_rounded) = *arena.value_node(rounded) else {
            return None;
        };
        (h == high && h_rounded == high).then_some(low)
    })?;
    let ExprNode::Mul(a, b) = *arena.value_node(high) else {
        return None;
    };
    let (x, c_hi) = [(a, b), (b, a)]
        .into_iter()
        .find_map(|(x, c)| Some((x, real_constant(arena, c)?)))?;
    let ExprNode::Fma(a, b, inner) = *arena.value_node(low) else {
        return None;
    };
    let c_lo = factor_of(arena, a, b, x)?;
    let ExprNode::Fma(a, b, negated) = *arena.value_node(inner) else {
        return None;
    };
    let ExprNode::Neg(h) = *arena.value_node(negated) else {
        return None;
    };
    if h != high || factor_of(arena, a, b, x)? != c_hi {
        return None;
    }
    let (RealRepr::Rational(hi), RealRepr::Rational(lo)) = (c_hi.repr(), c_lo.repr()) else {
        return None;
    };
    let factor = arena.real(Real::from_rational(hi.clone() + lo));
    let product = arena.mul(F32, x, factor);
    Some(arena.exp2(F32, product))
}

/// The finite real constant `id` holds.
fn real_constant(arena: &ExprArena, id: ExprId) -> Option<Real> {
    match arena.value_node(id) {
        ExprNode::RealConst(real) if matches!(real.repr(), RealRepr::Rational(_)) => {
            Some(real.clone())
        }
        _ => None,
    }
}

/// The constant `c` of the product `a * b` when it is `x * c` in either order.
fn factor_of(arena: &ExprArena, a: ExprId, b: ExprId, x: ExprId) -> Option<Real> {
    match (a == x, b == x) {
        (true, _) => real_constant(arena, b),
        (_, true) => real_constant(arena, a),
        _ => None,
    }
}

/// `condition ? b : a` as the `e^u = exp2(x * ±log2(e))` it guards: LLVM's `expf` gives 0 only
/// for `u` below a bound under `ln(2^-149)` and +inf above one over `ln(f32::MAX)`, f32 rounding,
/// which the reals ignore. `None` unless the select has exactly that form.
fn select_exp_range_guard(
    arena: &ExprArena,
    condition: ExprId,
    a: ExprId,
    b: ExprId,
) -> Option<ExprId> {
    // `(x, s)` for the exponential `e^(s x)`.
    let argument_of = |id: ExprId| {
        let ExprNode::Exp2(argument) = *arena.value_node(id) else {
            return None;
        };
        let ExprNode::Mul(p, q) = *arena.value_node(argument) else {
            return None;
        };
        [(p, q), (q, p)].into_iter().find_map(|(x, k)| {
            let k = arena.as_f64(k)?;
            let log2e = std::f64::consts::LOG2_E;
            ((k.abs() - log2e).abs() <= log2e * 1e-6).then_some((x, k.signum()))
        })
    };
    // The exponential branch, the constant branch, and the condition value taking the constant.
    let (exponential, constant, constant_when) = match (argument_of(a), argument_of(b)) {
        (Some(_), None) => (a, b, true),
        (None, Some(_)) => (b, a, false),
        _ => return None,
    };
    let (x, sign) = argument_of(exponential)?;
    // `u = sign_of(operand) * operand` for a comparison operand that is `x` or its negation;
    // LLVM folds `exp(-y)`'s negation into the guard on `y`.
    let sign_of = |operand: ExprId| {
        if same_operand(arena, operand, x) {
            return Some(sign);
        }
        match (arena.value_node(operand), arena.value_node(x)) {
            (&ExprNode::Neg(inner), _) if same_operand(arena, inner, x) => Some(-sign),
            (_, &ExprNode::Neg(inner)) if same_operand(arena, inner, operand) => Some(-sign),
            _ => None,
        }
    };
    let (left, right, at_most) = match *arena.node(condition) {
        ExprNode::Lt(l, r) | ExprNode::Le(l, r) => (l, r, true),
        ExprNode::Gt(l, r) | ExprNode::Ge(l, r) => (l, r, false),
        _ => return None,
    };
    // Whether the operand is at most (else at least) `bound` whenever the constant is taken.
    let (operand_sign, bound, below) = match (sign_of(left), sign_of(right)) {
        (Some(s), None) => (s, arena.as_f64(right)?, at_most == constant_when),
        (None, Some(s)) => (s, arena.as_f64(left)?, at_most != constant_when),
        _ => return None,
    };
    let (bound, below) = if operand_sign > 0.0 {
        (bound, below)
    } else {
        (-bound, !below)
    };
    let underflow = -149.0 * std::f64::consts::LN_2;
    let overflow = f64::from(f32::MAX).ln();
    let guards = match arena.value_node(constant) {
        ExprNode::RealConst(real) => match real.repr() {
            RealRepr::Rational(_) => *real == Real::zero() && below && bound <= underflow,
            RealRepr::PosInf => !below && bound >= overflow,
            RealRepr::NegInf => false,
        },
        _ => false,
    };
    guards.then_some(exponential)
}

/// `condition ? b : a` as `r(v)` for OCML's denormal-safe roots, `c ? k * r(c ? v * s : v) :
/// r(c ? v * s : v)`, which is `r(v)` over the reals when `k^2 = s` (`r = rsqrt`) or `k^2 s = 1`
/// (`r = sqrt`). `None` unless the branches have exactly that form.
fn select_scaled_root(
    arena: &mut ExprArena,
    condition: ExprId,
    a: ExprId,
    b: ExprId,
) -> Option<ExprId> {
    // A root node's operand on the side `when` of a select on `condition`, and whether it is
    // `rsqrt` (else `sqrt`).
    let root_input = |arena: &ExprArena, id: ExprId, when: bool| {
        let (operand, reciprocal) = match *arena.value_node(id) {
            ExprNode::Rsqrt(operand) => (operand, true),
            ExprNode::Sqrt(operand) => (operand, false),
            _ => return None,
        };
        match *arena.value_node(operand) {
            ExprNode::Select(selected, then, otherwise) if selected == condition => {
                Some((if when { then } else { otherwise }, reciprocal))
            }
            _ => None,
        }
    };
    for (scaled, scaled_when, plain, plain_when) in [(b, true, a, false), (a, false, b, true)] {
        let Some((v, reciprocal)) = root_input(arena, plain, plain_when) else {
            continue;
        };
        let ExprNode::Mul(p, q) = *arena.value_node(scaled) else {
            continue;
        };
        let Some((root, k)) = [(p, q), (q, p)]
            .into_iter()
            .find_map(|(root, k)| Some((root, real_constant(arena, k)?)))
        else {
            continue;
        };
        let Some((input, scaled_reciprocal)) = root_input(arena, root, scaled_when) else {
            continue;
        };
        let ExprNode::Mul(p, q) = *arena.value_node(input) else {
            continue;
        };
        let Some(s) = [(p, q), (q, p)].into_iter().find_map(|(x, s)| {
            same_operand(arena, x, v)
                .then(|| real_constant(arena, s))
                .flatten()
        }) else {
            continue;
        };
        let (RealRepr::Rational(k), RealRepr::Rational(s)) = (k.repr(), s.repr()) else {
            continue;
        };
        let square = k.clone() * k;
        let exact = if reciprocal {
            square == *s
        } else {
            square * s == 1
        };
        if scaled_reciprocal == reciprocal && exact {
            return Some(if reciprocal {
                arena.rsqrt(F32, v)
            } else {
                arena.sqrt(F32, v)
            });
        }
    }
    None
}

/// Whether two operands are one value: the same expression, or the same input modifier of one,
/// as each read of `|v|` builds its own node.
fn same_operand(arena: &ExprArena, a: ExprId, b: ExprId) -> bool {
    a == b
        || match (arena.value_node(a), arena.value_node(b)) {
            (ExprNode::Abs(x), ExprNode::Abs(y)) | (ExprNode::Neg(x), ExprNode::Neg(y)) => x == y,
            _ => false,
        }
}

/// `value * 2^exponent` for a symbolic i32 `exponent`: its integer terms scale exactly, so only
/// its symbolic terms pass through `exp2`, which lowers through an f32 `ln 2`.
fn scale_by_exponent(arena: &mut ExprArena, value: ExprId, exponent: ExprId) -> ExprId {
    let (symbolic, constant) = split_exponent(arena, exponent);
    let scaled = scale_by_power_of_two(arena, value, constant as i32);
    match symbolic {
        Some(symbolic) => {
            let scale = arena.exp2(F32, symbolic);
            arena.mul(F32, scaled, scale)
        }
        None => scaled,
    }
}

/// A symbolic exponent as its symbolic terms (`None` if there are none) plus an integer.
fn split_exponent(arena: &mut ExprArena, exponent: ExprId) -> (Option<ExprId>, i64) {
    if let Some(word) = concrete_word(arena, exponent) {
        return (None, i64::from(word as i32));
    }
    if arena.ty(exponent) != Some(I32) {
        return (Some(exponent), 0);
    }
    let combine = |arena: &mut ExprArena,
                   a: (Option<ExprId>, i64),
                   b: (Option<ExprId>, i64),
                   negate_b: bool| {
        let constant = if negate_b { a.1 - b.1 } else { a.1 + b.1 };
        let symbolic = match (a.0, b.0) {
            (a, None) => a,
            (None, Some(b)) if negate_b => Some(arena.neg(I32, b)),
            (None, Some(b)) => Some(b),
            (Some(a), Some(b)) if negate_b => Some(arena.sub(I32, a, b)),
            (Some(a), Some(b)) => Some(arena.add(I32, a, b)),
        };
        (symbolic, constant)
    };
    match *arena.node(exponent) {
        ExprNode::Add(a, b) => {
            let (a, b) = (split_exponent(arena, a), split_exponent(arena, b));
            combine(arena, a, b, false)
        }
        ExprNode::Sub(a, b) => {
            let (a, b) = (split_exponent(arena, a), split_exponent(arena, b));
            combine(arena, a, b, true)
        }
        ExprNode::Neg(a) => {
            let a = split_exponent(arena, a);
            combine(arena, (None, 0), a, true)
        }
        _ => (Some(exponent), 0),
    }
}

fn scale_by_power_of_two(arena: &mut ExprArena, value: ExprId, exponent: i32) -> ExprId {
    // Every power of two in f64's range is exact; beyond it an f32 result is 0 or infinite.
    let power = Real::from_f64(2f64.powi(exponent)).expect("a power of two is not a NaN");
    let scale = arena.real(power);
    arena.mul(F32, value, scale)
}

/// `v_cvt_pk_{fp8,bf8}_f32` in `lane`: `dst`'s word with `half` replaced by the sources'
/// `format` codes.
pub(super) fn evaluate_cvt_pk_f8_f32(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    format: F8Format,
    dst: Vgpr,
    srcs: [Src0; 2],
    half: WordHalf,
) -> Result<ExprId, EvalError> {
    let mut codes = [0; 2];
    for (code, src) in codes.iter_mut().zip(srcs) {
        let value = registers.read_f32_src0(arena, lane, src)?;
        let ExprNode::RealConst(real) = arena.value_node(value) else {
            return Err(EvalError::UnmodeledFp8 { lane });
        };
        *code = f8_code(format, real).ok_or(EvalError::UnmodeledFp8 { lane })?;
    }
    let old = registers.read_vgpr(lane, dst)?;
    let old = word_bits(arena, old).ok_or(EvalError::SymbolicWord { lane })?;
    let packed = u32::from(codes[0]) | (u32::from(codes[1]) << 8);
    let word = match half {
        WordHalf::Low => (old & 0xffff_0000) | packed,
        WordHalf::High => (old & 0x0000_ffff) | (packed << 16),
    };
    Ok(arena.int(i64::from(word)))
}

/// A register's 32 bits: a concrete word, or a constant real that is exactly an f32.
fn word_bits(arena: &ExprArena, value: ExprId) -> Option<u32> {
    if let Some(word) = concrete_word(arena, value) {
        return Some(word);
    }
    let ExprNode::RealConst(real) = arena.value_node(value) else {
        return None;
    };
    let single = real.to_f64() as f32;
    (Real::from_f64(f64::from(single)).ok()? == *real).then(|| single.to_bits())
}

/// The `format` code of `value`, rounding only magnitudes up to half the least subnormal,
/// which round to zero; `None` for any other value that needs rounding. Zero has no sign over
/// the reals, so it is +0.
fn f8_code(format: F8Format, value: &Real) -> Option<u8> {
    let exact = |magnitude: f64| Real::from_f64(magnitude).expect("not a NaN");
    let magnitude = value.abs();
    let sign = if *value < Real::zero() { 0x80 } else { 0 };
    // The positive finite codes run from the least subnormal, 0x01, to the largest finite one.
    let (least_subnormal, largest_finite, decode): (_, u8, fn(u8) -> Option<f64>) = match format {
        F8Format::E4M3 => (2f64.powi(-9), 0x7e, decode_e4m3_byte),
        F8Format::E5M2 => (2f64.powi(-16), 0x7b, decode_e5m2_byte),
    };
    if magnitude <= exact(least_subnormal / 2.0) {
        return Some(sign);
    }
    (1..=largest_finite)
        .find(|code| {
            let decoded = decode(*code).expect("codes up to the largest finite one are finite");
            exact(decoded) == magnitude
        })
        .map(|code| sign | code)
}

fn unary_operand_type(op: UnaryOp) -> OperandType {
    match op {
        UnaryOp::Mov32
        | UnaryOp::Not32
        | UnaryOp::BfRev32
        | UnaryOp::CvtF32I32
        | UnaryOp::CvtF32U32
        | UnaryOp::CvtOffF32I4
        | UnaryOp::CvtF32Ubyte(_) => OperandType::Word,
        UnaryOp::CvtI32F32
        | UnaryOp::CvtU32F32
        | UnaryOp::RcpIflagF32
        | UnaryOp::Exp2F32
        | UnaryOp::Log2F32
        | UnaryOp::RcpF32
        | UnaryOp::SqrtF32
        | UnaryOp::RsqF32
        | UnaryOp::RndneF32
        | UnaryOp::TruncF32
        | UnaryOp::FrexpMantF32
        | UnaryOp::FrexpExpI32F32 => OperandType::F32,
    }
}

fn cmp_operand_type(op: CmpOp) -> OperandType {
    if op.is_f32() {
        OperandType::F32
    } else {
        OperandType::Word
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

/// `evaluate_cmp` over VOP3 sources; an f32 comparison applies their input modifiers.
pub(super) fn evaluate_cmp_e64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CmpOp,
    src0: ModifiedSrc,
    src1: ModifiedSrc,
) -> Result<ExprId, EvalError> {
    let (a, b) = match cmp_operand_type(op) {
        OperandType::Word => (
            registers.read_src(arena, lane, src0.src)?,
            registers.read_src(arena, lane, src1.src)?,
        ),
        OperandType::F32 => (
            registers.read_modified_src(arena, lane, src0)?,
            registers.read_modified_src(arena, lane, src1)?,
        ),
    };
    compare(arena, lane, op, a, b)
}

/// The boolean `src0 op src1` in `lane`, reading each source as two concrete words,
/// low word first, that together form one 64-bit integer of the given signedness.
pub(super) fn evaluate_cmp64(
    arena: &mut ExprArena,
    registers: &WaveRegisters,
    lane: usize,
    op: CmpPredicate,
    signedness: Signedness,
    src0: [Src0; 2],
    src1: [Src0; 2],
) -> Result<ExprId, EvalError> {
    let words = [
        registers.read_src0(arena, lane, src0[0])?,
        registers.read_src0(arena, lane, src0[1])?,
        registers.read_src0(arena, lane, src1[0])?,
        registers.read_src0(arena, lane, src1[1])?,
    ];
    let [a_low, a_high, b_low, b_high] = concrete_words(arena, lane, words)?;
    let a = (u64::from(a_high) << 32) | u64::from(a_low);
    let b = (u64::from(b_high) << 32) | u64::from(b_low);
    let order = match signedness {
        Signedness::Signed => (a as i64).cmp(&(b as i64)),
        Signedness::Unsigned => a.cmp(&b),
    };
    Ok(arena.bool_val(match op {
        CmpPredicate::Lt => order.is_lt(),
        CmpPredicate::Eq => order.is_eq(),
        CmpPredicate::Le => order.is_le(),
        CmpPredicate::Gt => order.is_gt(),
        CmpPredicate::Ne => order.is_ne(),
        CmpPredicate::Ge => order.is_ge(),
    }))
}

/// The bitwise (in)equality of two f32 words of which one is symbolic: over the reals, with no
/// NaN and no signed zero, two words hold the same bits exactly when they hold the same real.
fn compare_real_words(arena: &mut ExprArena, equal: bool, a: ExprId, b: ExprId) -> Option<ExprId> {
    if concrete_word(arena, a).is_some() && concrete_word(arena, b).is_some() {
        return None;
    }
    if a == b {
        return Some(arena.bool_val(equal));
    }
    let a = as_f32(arena, a)?;
    let b = as_f32(arena, b)?;
    Some(if equal {
        arena.eq(F32, a, b)
    } else {
        arena.ne(F32, a, b)
    })
}

/// Whether `a` and `b` are one value: one node, or equal constants.
fn same_value(arena: &ExprArena, a: ExprId, b: ExprId) -> bool {
    a == b
        || match (arena.value_node(a), arena.value_node(b)) {
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => x == y,
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => x == y,
            _ => false,
        }
}

/// `condition ? b : a` as the `max` or `min` it is when `condition` orders the two branches and
/// one is a constant, a clamp such as `0 <= v ? v : 0`; over the reals, ties pick equal values.
fn select_extremum(
    arena: &mut ExprArena,
    condition: ExprId,
    a: ExprId,
    b: ExprId,
) -> Option<ExprId> {
    let constant = |id| {
        matches!(
            arena.value_node(id),
            ExprNode::RealConst(_) | ExprNode::IntConst(_)
        )
    };
    if !constant(a) && !constant(b) {
        return None;
    }
    // `(x, y)` with `condition` meaning `x <= y` (or `x < y`).
    let (x, y) = match *arena.node(condition) {
        ExprNode::Le(x, y) | ExprNode::Lt(x, y) => (x, y),
        ExprNode::Ge(x, y) | ExprNode::Gt(x, y) => (y, x),
        _ => return None,
    };
    if same_value(arena, b, y) && same_value(arena, a, x) {
        Some(arena.max(F32, a, b))
    } else if same_value(arena, b, x) && same_value(arena, a, y) {
        Some(arena.min(F32, a, b))
    } else {
        None
    }
}

/// `condition ? b : a` when `condition` is `x == y` and the sources are `x` and `y`: whichever
/// way the condition goes, the result equals `a`.
fn select_equal(arena: &ExprArena, condition: ExprId, a: ExprId, b: ExprId) -> Option<ExprId> {
    match *arena.node(condition) {
        ExprNode::Eq(x, y) if (x, y) == (a, b) || (x, y) == (b, a) => Some(a),
        _ => None,
    }
}

/// An integer comparison needs concrete words, which it reinterprets as `op`'s signedness.
fn compare(
    arena: &mut ExprArena,
    lane: usize,
    op: CmpOp,
    a: ExprId,
    b: ExprId,
) -> Result<ExprId, EvalError> {
    if matches!(op, CmpOp::EqU32 | CmpOp::NeU32)
        && let Some(predicate) = compare_bf16_field(arena, op == CmpOp::EqU32, a, b)
    {
        return Ok(predicate);
    }
    if matches!(op, CmpOp::EqU32 | CmpOp::NeU32)
        && let Some(predicate) = compare_real_words(arena, op == CmpOp::EqU32, a, b)
    {
        return Ok(predicate);
    }
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
        CmpOp::LtF32 => arena.lt(F32, a, b),
        CmpOp::LeF32 => arena.le(F32, a, b),
        CmpOp::GtF32 => arena.gt(F32, a, b),
        CmpOp::GeF32 => arena.ge(F32, a, b),
        CmpOp::EqF32 => arena.eq(F32, a, b),
        CmpOp::LgF32 => arena.ne(F32, a, b),
        CmpOp::OF32 => arena.bool_val(true),
        CmpOp::UF32 => arena.bool_val(false),
    })
}

/// `v_perm_b32`: each result byte chosen by a selector byte from the 64-bit `high:low`
/// (0 to 7), a sign byte of its odd bytes (8 to 11), zero (12) or all ones (13 and above).
pub(super) fn perm32(high: u32, low: u32, selectors: u32) -> u32 {
    let bytes = (u64::from(high) << 32) | u64::from(low);
    (0..4).fold(0, |word, i| {
        let byte = match (selectors >> (8 * i)) as u8 {
            sel @ 0..=7 => (bytes >> (8 * sel)) as u8,
            sel @ 8..=11 => {
                let sign = bytes >> (16 * u32::from(sel - 8) + 15) & 1;
                if sign == 1 { 0xff } else { 0 }
            }
            12 => 0,
            _ => 0xff,
        };
        word | (u32::from(byte) << (8 * i))
    })
}

/// A concrete real truncated toward zero and clamped to the u32 range; `None` when symbolic.
fn truncate_to_u32(arena: &ExprArena, value: ExprId) -> Option<u32> {
    let ExprNode::RealConst(real) = arena.value_node(value) else {
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

/// A concrete real truncated toward zero and clamped to the i32 range; `None` when symbolic.
fn truncate_to_i32(arena: &ExprArena, value: ExprId) -> Option<i32> {
    let ExprNode::RealConst(real) = arena.value_node(value) else {
        return None;
    };
    Some(match real.repr() {
        RealRepr::NegInf => i32::MIN,
        RealRepr::PosInf => i32::MAX,
        RealRepr::Rational(rational) => {
            let integer = rational.clone().trunc();
            let integer = integer.numer();
            match integer.to_i32() {
                Some(word) => word,
                None if integer.is_negative() => i32::MIN,
                None => i32::MAX,
            }
        }
    })
}

/// The low 32 bits of a concrete integer result.
fn low_word(arena: &mut ExprArena, value: ExprId) -> ExprId {
    let mask = arena.int(i64::from(u32::MAX));
    arena.bit_and(B32, value, mask)
}

/// `count & 31`: AMD uses only the low five bits of a shift count, so 34 becomes 2 and 32
/// becomes 0.
fn low_five_bits(arena: &mut ExprArena, count: ExprId) -> ExprId {
    let mask = arena.int(31);
    arena.bit_and(B32, count, mask)
}

/// `value << (shift & 31)`, keeping the low 32 bits.
fn shl32(arena: &mut ExprArena, value: ExprId, shift: ExprId) -> ExprId {
    let amount = low_five_bits(arena, shift);
    let shifted = arena.shl(B32, value, amount);
    low_word(arena, shifted)
}

/// The logical `value >> (shift & 31)`.
fn lshr32(arena: &mut ExprArena, value: ExprId, shift: ExprId) -> ExprId {
    let amount = low_five_bits(arena, shift);
    arena.lshr(B32, value, amount)
}
