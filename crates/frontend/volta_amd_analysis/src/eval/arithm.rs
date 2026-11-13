//! Vector ALU arithmetic: the value of a unary, binary, ternary or comparison operation in one
//! lane.

use volta_expr::{ExprArena, ExprId, ExprNode, Real, RealRepr};

use crate::ir::{
    BinOp, CmpOp, CmpPredicate, CvtFromF64Op, CvtToF64Op, F64Op, F64Src, LaneMask, ModifiedSrc,
    PackedF32Op, Signedness, Src0, TernaryOp, UnaryOp, Vgpr, Vop3BinOp, Vop3Src,
};

use super::EvalError;
use super::wave::{WaveRegisters, apply_modifiers, concrete_word};

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
    if let Some(result) = sign_bit_op(arena, op, a, b) {
        return Ok(result);
    }
    // Integer operations need concrete words: a symbolic value is a float, without known bits.
    if matches!(operand_type(op), OperandType::Word) {
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
                Ok(arena.add(a, b))
            }
            PackedF32Op::Mul([src0, src1]) => {
                let a = read(src0)?;
                let b = read(src1)?;
                Ok(arena.mul(a, b))
            }
            PackedF32Op::Fma([src0, src1, src2]) => {
                let a = read(src0)?;
                let b = read(src1)?;
                let c = read(src2)?;
                Ok(arena.fma(a, b, c))
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
            arena.add(a, b)
        }
        F64Op::Mul([a, b]) => {
            let (a, b) = (read(a)?, read(b)?);
            arena.mul(a, b)
        }
        F64Op::Min([a, b]) => {
            let (a, b) = (read(a)?, read(b)?);
            arena.min(a, b)
        }
        F64Op::Max([a, b]) => {
            let (a, b) = (read(a)?, read(b)?);
            arena.max(a, b)
        }
        F64Op::Fma([a, b, c]) => {
            let (a, b, c) = (read(a)?, read(b)?, read(c)?);
            arena.fma(a, b, c)
        }
        F64Op::Rcp([a]) => {
            let a = read(a)?;
            arena.rcp(a)
        }
        F64Op::Sqrt([a]) => {
            let a = read(a)?;
            arena.sqrt(a)
        }
        F64Op::Rsq([a]) => {
            let a = read(a)?;
            let root = arena.sqrt(a);
            arena.rcp(root)
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
            return Ok(apply_modifiers(arena, value, src.abs, src.neg));
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
        CmpPredicate::Lt => arena.lt(a, b),
        CmpPredicate::Eq => arena.eq(a, b),
        CmpPredicate::Le => arena.le(a, b),
        CmpPredicate::Gt => arena.gt(a, b),
        CmpPredicate::Ne => arena.ne(a, b),
        CmpPredicate::Ge => arena.ge(a, b),
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
    if let Some(word) = select_words(arena, lane, condition, a, b)? {
        return Ok(word);
    }
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
    src0: ModifiedSrc,
    src1: ModifiedSrc,
    mask: LaneMask,
) -> Result<ExprId, EvalError> {
    let condition = registers.read_lane_condition(arena, lane, mask)?;
    // Source modifiers give the select float semantics (V_CNDMASK_B32).
    if src0.is_modified() || src1.is_modified() {
        let a = registers.read_modified_src(arena, lane, src0)?;
        let b = registers.read_modified_src(arena, lane, src1)?;
        return Ok(arena.select(condition, b, a));
    }
    let a = registers.read_src(arena, lane, src0.src)?;
    let b = registers.read_src(arena, lane, src1.src)?;
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
    Ok(arena.select(condition, b, a))
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
        Some(_) => Ok(Some(arena.select(condition, b, a))),
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
    Ok(match op {
        TernaryOp::AddLShl32 => {
            let sum = arena.add(a, b);
            let sum = low_word(arena, sum);
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

/// `x & 0x7fffffff` clears a float's sign bit and `x ^ 0x80000000` flips it, so for a
/// symbolic f32 `x`, whose other bits are unknown, they are `|x|` and `-x` exactly.
fn sign_bit_op(arena: &mut ExprArena, op: BinOp, a: ExprId, b: ExprId) -> Option<ExprId> {
    let (mask, value) = match (concrete_word(arena, a), concrete_word(arena, b)) {
        (Some(mask), None) => (mask, b),
        (None, Some(mask)) => (mask, a),
        _ => return None,
    };
    if matches!(arena.node(value), ExprNode::Undefined) {
        return None;
    }
    match (op, mask) {
        (BinOp::And32, 0x7fff_ffff) => Some(arena.abs(value)),
        (BinOp::Xor32, 0x8000_0000) => Some(arena.neg(value)),
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
        UnaryOp::CvtI32F32 => {
            let truncated = truncate_to_i32(arena, a).ok_or(EvalError::SymbolicWord { lane })?;
            arena.int(i64::from(truncated as u32))
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
        UnaryOp::RndneF32 => arena.round_even(a),
        UnaryOp::TruncF32 => arena.trunc(a),
    })
}

fn unary_operand_type(op: UnaryOp) -> OperandType {
    match op {
        UnaryOp::Mov32
        | UnaryOp::Not32
        | UnaryOp::BfRev32
        | UnaryOp::CvtF32I32
        | UnaryOp::CvtF32U32 => OperandType::Word,
        UnaryOp::CvtI32F32
        | UnaryOp::CvtU32F32
        | UnaryOp::RcpIflagF32
        | UnaryOp::Exp2F32
        | UnaryOp::Log2F32
        | UnaryOp::RcpF32
        | UnaryOp::SqrtF32
        | UnaryOp::RsqF32
        | UnaryOp::RndneF32
        | UnaryOp::TruncF32 => OperandType::F32,
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
        CmpOp::GtF32 => arena.gt(a, b),
        CmpOp::GeF32 => arena.ge(a, b),
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

/// A concrete real truncated toward zero and clamped to the i32 range; `None` when symbolic.
fn truncate_to_i32(arena: &ExprArena, value: ExprId) -> Option<i32> {
    let ExprNode::RealConst(real) = arena.node(value) else {
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
    arena.bit_and(value, mask)
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
