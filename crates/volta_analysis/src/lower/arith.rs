//! Lowering of arithmetic, logic, shift and bit-field instructions, of
//! comparison and selection, and of `cvt`, with the packed-type checks they
//! share.

use volta_frontend::ast::{
    self, AbsInstr, AddInstr, BfeInstr, BfiInstr, CopysignInstr, CvtInstr, CvtRounding, DivInstr,
    Ex2Instr, FmaInstr, FpRound, Lg2Instr, LogicInstr, Lop3Instr, MadInstr, MaxInstr, MinInstr,
    MulInstr, MulMode, NegInstr, NotInstr, Operand as AstOperand, PrmtInstr, RcpInstr, RemInstr,
    RsqrtInstr, ScalarType, SelpInstr, SetpInstr, ShfInstr, ShiftInstr, SqrtInstr, SubInstr,
    TanhInstr,
};

use crate::ir::types::ScalarTypeExt;
use crate::ir::{BinOp, Clamp, LoweredInstr, Predicate, UnaryOp};

use super::context::{LoweringContext, unsupported};
use super::error::LowerResult;

/// Reject packed-SIMD (multi-lane) types in scalar arithmetic lowering:
/// `BinOp`/`UnaryOp`/`Fma` evaluate one lane, so a packed type would silently
/// compute a single lane (or integer-add float bit patterns).
fn check_not_packed(ty: ScalarType, instruction: &str) -> LowerResult<()> {
    match ty {
        ScalarType::U16x2
        | ScalarType::S16x2
        | ScalarType::F16x2
        | ScalarType::Bf16x2
        | ScalarType::F32x2 => Err(unsupported(
            instruction,
            format!("packed SIMD arithmetic on {:?}", ty),
        )),
        _ => Ok(()),
    }
}

/// Like `check_not_packed`, but lets `F16x2`/`Bf16x2`/`F32x2` through, since
/// the eval arms compute each `Value::Pair` lane independently; packed integer
/// (`U16x2`/`S16x2`) stays rejected. For real packed PTX arithmetic forms.
fn check_packed_arithmetic(ty: ScalarType, instruction: &str) -> LowerResult<()> {
    match ty {
        ScalarType::U16x2 | ScalarType::S16x2 => Err(unsupported(
            instruction,
            format!("packed SIMD arithmetic on {:?}", ty),
        )),
        _ => Ok(()),
    }
}

/// Scalar (single-lane) floating-point types - the domain of the modeled
/// float value clamps (`Clamp`). Excludes the packed float types and tf32.
fn is_scalar_float(ty: ScalarType) -> bool {
    matches!(
        ty,
        ScalarType::F16 | ScalarType::Bf16 | ScalarType::F32 | ScalarType::F64
    )
}

pub(super) fn lower_add(
    ctx: &mut LoweringContext,
    add: &AddInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match add {
        AddInstr::Integer {
            ty,
            dst,
            src_a,
            src_b,
        } => {
            check_not_packed(*ty, "add")?;

            // Resolve with type information
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            // Type check against instruction type
            ctx.check_dst_type(&dst_typed, *ty, "add")?;
            ctx.check_operand_type(&src_a_typed, *ty, "add")?;
            ctx.check_operand_type(&src_b_typed, *ty, "add")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Add,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: *ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        AddInstr::IntegerSat {
            sat,
            dst,
            src_a,
            src_b,
        } => {
            if *sat {
                return Err(unsupported("add.sat.s32", ".sat (saturating integer add)"));
            }
            let ty = ScalarType::S32;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "add.sat")?;
            ctx.check_operand_type(&src_a_typed, ty, "add.sat")?;
            ctx.check_operand_type(&src_b_typed, ty, "add.sat")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Add,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        AddInstr::Float32 {
            // Rounding mode and subnormal flushing don't apply: floats are
            // reals here, so every add is exact. `.sat` is a value clamp
            // (exact over the reals) threaded through as `Clamp::Sat`.
            rnd: _rnd,
            ftz: _ftz,
            sat,
            dst,
            src_a,
            src_b,
        } => {
            let ty = ScalarType::F32;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "add.f32")?;
            ctx.check_operand_type(&src_a_typed, ty, "add.f32")?;
            ctx.check_operand_type(&src_b_typed, ty, "add.f32")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Add,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: sat.then_some(Clamp::Sat),
                },
                predicate,
            )?;
        }
        AddInstr::Float32x2 {
            // Packed single precision (sm_100+): two f32 lanes in a 64-bit
            // register, each evaluated as an exact real like `add.f32`.
            rnd: _rnd,
            ftz: _ftz,
            dst,
            src_a,
            src_b,
        } => {
            let ty = ScalarType::F32x2;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "add.f32x2")?;
            ctx.check_operand_type(&src_a_typed, ty, "add.f32x2")?;
            ctx.check_operand_type(&src_b_typed, ty, "add.f32x2")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Add,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        AddInstr::Float64 {
            // Rounding mode doesn't apply over the reals.
            rnd: _rnd,
            dst,
            src_a,
            src_b,
        } => {
            let ty = ScalarType::F64;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "add.f64")?;
            ctx.check_operand_type(&src_a_typed, ty, "add.f64")?;
            ctx.check_operand_type(&src_b_typed, ty, "add.f64")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Add,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        AddInstr::HalfF16 {
            // Rounding mode and subnormal flushing don't apply over the
            // reals; `.sat` is an exact value clamp.
            rnd: _rnd,
            ftz: _ftz,
            sat,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            check_packed_arithmetic(*ty, "add")?;
            lower_half_binop(
                ctx,
                BinOp::Add,
                "add.f16",
                *ty,
                sat.then_some(Clamp::Sat),
                dst,
                src_a,
                src_b,
                predicate,
            )?;
        }
        AddInstr::HalfBf16 {
            // Rounding mode doesn't apply over the reals.
            rnd: _rnd,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            check_packed_arithmetic(*ty, "add")?;
            lower_half_binop(
                ctx,
                BinOp::Add,
                "add.bf16",
                *ty,
                None,
                dst,
                src_a,
                src_b,
                predicate,
            )?;
        }
        AddInstr::MixedPrecision {
            // Rounding mode doesn't apply over the reals.
            rnd: _rnd,
            sat,
            src_type,
            dst,
            src_a,
            src_b,
        } => {
            if *sat {
                return Err(unsupported("add.f32 (mixed)", ".sat modifier"));
            }
            check_not_packed(*src_type, "add (mixed)")?;

            // Mixed precision add: d = convert(a) + c, a is half (f16/bf16),
            // c and d are f32 (PTX ISA 9.7.5.1).
            let dst_ty = ScalarType::F32;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, dst_ty, "add.f32 (mixed)")?;
            ctx.check_operand_type(&src_a_typed, *src_type, "add.f32 (mixed)")?;
            ctx.check_operand_type(&src_b_typed, dst_ty, "add.f32 (mixed)")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Add,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: dst_ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
    }
    Ok(())
}

/// Shared lowering for scalar half-precision (f16/bf16) binops.
#[allow(clippy::too_many_arguments)] // thin emission helper; mirrors the instruction shape
fn lower_half_binop(
    ctx: &mut LoweringContext,
    op: BinOp,
    instr_name: &str,
    ty: ScalarType,
    clamp: Option<Clamp>,
    dst: &AstOperand,
    src_a: &AstOperand,
    src_b: &AstOperand,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_a_typed = ctx.resolve_operand_typed(src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(src_b)?;

    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_a_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_b_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::BinOp {
            op,
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            ty,
            clamp,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_sub(
    ctx: &mut LoweringContext,
    sub: &SubInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match sub {
        SubInstr::Integer {
            ty,
            dst,
            src_a,
            src_b,
        } => {
            check_not_packed(*ty, "sub")?;

            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, *ty, "sub")?;
            ctx.check_operand_type(&src_a_typed, *ty, "sub")?;
            ctx.check_operand_type(&src_b_typed, *ty, "sub")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Sub,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: *ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        SubInstr::IntegerSat {
            sat,
            dst,
            src_a,
            src_b,
        } => {
            if *sat {
                return Err(unsupported("sub.sat.s32", ".sat (saturating integer sub)"));
            }
            let ty = ScalarType::S32;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "sub.sat")?;
            ctx.check_operand_type(&src_a_typed, ty, "sub.sat")?;
            ctx.check_operand_type(&src_b_typed, ty, "sub.sat")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Sub,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        SubInstr::Float32 {
            // Rounding mode and subnormal flushing don't apply over the reals.
            rnd: _rnd,
            ftz: _ftz,
            sat,
            dst,
            src_a,
            src_b,
        } => {
            let ty = ScalarType::F32;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "sub.f32")?;
            ctx.check_operand_type(&src_a_typed, ty, "sub.f32")?;
            ctx.check_operand_type(&src_b_typed, ty, "sub.f32")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Sub,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: sat.then_some(Clamp::Sat),
                },
                predicate,
            )?;
        }
        SubInstr::Float32x2 {
            // Packed single precision (sm_100+), per lane like `sub.f32`.
            rnd: _rnd,
            ftz: _ftz,
            dst,
            src_a,
            src_b,
        } => {
            let ty = ScalarType::F32x2;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "sub.f32x2")?;
            ctx.check_operand_type(&src_a_typed, ty, "sub.f32x2")?;
            ctx.check_operand_type(&src_b_typed, ty, "sub.f32x2")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Sub,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        SubInstr::Float64 {
            // Rounding mode doesn't apply over the reals.
            rnd: _rnd,
            dst,
            src_a,
            src_b,
        } => {
            let ty = ScalarType::F64;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, ty, "sub.f64")?;
            ctx.check_operand_type(&src_a_typed, ty, "sub.f64")?;
            ctx.check_operand_type(&src_b_typed, ty, "sub.f64")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Sub,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
        SubInstr::HalfF16 {
            // Rounding mode and subnormal flushing don't apply over the
            // reals; `.sat` is an exact value clamp.
            rnd: _rnd,
            ftz: _ftz,
            sat,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            check_packed_arithmetic(*ty, "sub")?;
            lower_half_binop(
                ctx,
                BinOp::Sub,
                "sub.f16",
                *ty,
                sat.then_some(Clamp::Sat),
                dst,
                src_a,
                src_b,
                predicate,
            )?;
        }
        SubInstr::HalfBf16 {
            // Rounding mode doesn't apply over the reals.
            rnd: _rnd,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            check_packed_arithmetic(*ty, "sub")?;
            lower_half_binop(
                ctx,
                BinOp::Sub,
                "sub.bf16",
                *ty,
                None,
                dst,
                src_a,
                src_b,
                predicate,
            )?;
        }
        SubInstr::MixedPrecision {
            // Rounding mode doesn't apply over the reals.
            rnd: _rnd,
            sat,
            src_type,
            dst,
            src_a,
            src_b,
        } => {
            if *sat {
                return Err(unsupported("sub.f32 (mixed)", ".sat modifier"));
            }
            check_not_packed(*src_type, "sub (mixed)")?;

            // Mixed precision sub: d = convert(a) - c, a is half (f16/bf16),
            // c and d are f32 (PTX ISA 9.7.5.2).
            let dst_ty = ScalarType::F32;
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, dst_ty, "sub.f32 (mixed)")?;
            ctx.check_operand_type(&src_a_typed, *src_type, "sub.f32 (mixed)")?;
            ctx.check_operand_type(&src_b_typed, dst_ty, "sub.f32 (mixed)")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Sub,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: dst_ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
    }
    Ok(())
}

pub(super) fn lower_mul(
    ctx: &mut LoweringContext,
    mul: &MulInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match mul {
        MulInstr::Integer {
            mode,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            check_not_packed(*ty, "mul")?;

            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            match mode {
                MulMode::Wide => {
                    // For mul.wide, sources are type `ty`, but destination is 2x wider
                    // e.g., mul.wide.s32 produces s64 result
                    let dst_ty = ty.widen().unwrap_or(*ty);
                    ctx.check_dst_type(&dst_typed, dst_ty, "mul.wide")?;
                    ctx.check_operand_type(&src_a_typed, *ty, "mul.wide")?;
                    ctx.check_operand_type(&src_b_typed, *ty, "mul.wide")?;

                    ctx.emit(
                        LoweredInstr::MulWide {
                            dst: dst_typed.reg,
                            src_a: src_a_typed.operand,
                            src_b: src_b_typed.operand,
                            src_ty: *ty,
                        },
                        predicate,
                    )?;
                }
                MulMode::Hi => {
                    ctx.check_dst_type(&dst_typed, *ty, "mul.hi")?;
                    ctx.check_operand_type(&src_a_typed, *ty, "mul.hi")?;
                    ctx.check_operand_type(&src_b_typed, *ty, "mul.hi")?;

                    ctx.emit(
                        LoweredInstr::MulHi {
                            dst: dst_typed.reg,
                            src_a: src_a_typed.operand,
                            src_b: src_b_typed.operand,
                            ty: *ty,
                        },
                        predicate,
                    )?;
                }
                MulMode::Lo => {
                    ctx.check_dst_type(&dst_typed, *ty, "mul.lo")?;
                    ctx.check_operand_type(&src_a_typed, *ty, "mul.lo")?;
                    ctx.check_operand_type(&src_b_typed, *ty, "mul.lo")?;

                    ctx.emit(
                        LoweredInstr::BinOp {
                            op: BinOp::Mul,
                            dst: dst_typed.reg,
                            src_a: src_a_typed.operand,
                            src_b: src_b_typed.operand,
                            ty: *ty,
                            clamp: None,
                        },
                        predicate,
                    )?;
                }
            }
        }
        MulInstr::Float {
            // Rounding mode and subnormal flushing don't apply over the
            // reals; `.sat` is an exact value clamp.
            rnd: _rnd,
            ftz: _ftz,
            sat,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            // The ISA allows `.sat` on mul only for .f32 and .f16/.f16x2
            // (the instruction parser already enforces this; this guard is
            // fail-closed insurance for the variant's other types).
            if *sat && !matches!(ty, ScalarType::F32 | ScalarType::F16 | ScalarType::F16x2) {
                return Err(unsupported(
                    "mul.f",
                    format!(".sat modifier on {:?} (invalid PTX)", ty),
                ));
            }
            check_packed_arithmetic(*ty, "mul")?;

            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            ctx.check_dst_type(&dst_typed, *ty, "mul.f")?;
            ctx.check_operand_type(&src_a_typed, *ty, "mul.f")?;
            ctx.check_operand_type(&src_b_typed, *ty, "mul.f")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Mul,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: *ty,
                    clamp: sat.then_some(Clamp::Sat),
                },
                predicate,
            )?;
        }
    }
    Ok(())
}

pub(super) fn lower_mad(
    ctx: &mut LoweringContext,
    mad: &MadInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match mad {
        MadInstr::Integer {
            mode,
            sat,
            ty,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            if *sat {
                return Err(unsupported(
                    "mad.hi.sat.s32",
                    ".sat (saturating integer mad)",
                ));
            }
            check_not_packed(*ty, "mad")?;

            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;
            let src_c_typed = ctx.resolve_operand_typed(src_c)?;

            let instr_name = match mode {
                MulMode::Hi => "mad.hi",
                MulMode::Lo => "mad.lo",
                MulMode::Wide => "mad.wide",
            };

            // For mad.wide, destination is 2x wider
            let dst_ty = if matches!(mode, MulMode::Wide) {
                ty.widen().unwrap_or(*ty)
            } else {
                *ty
            };

            ctx.check_dst_type(&dst_typed, dst_ty, instr_name)?;
            ctx.check_operand_type(&src_a_typed, *ty, instr_name)?;
            ctx.check_operand_type(&src_b_typed, *ty, instr_name)?;
            // src_c is the accumulator, same type as destination
            ctx.check_operand_type(&src_c_typed, dst_ty, instr_name)?;

            ctx.emit(
                LoweredInstr::Mad {
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    src_c: src_c_typed.operand,
                    ty: *ty,
                    mode: ctx.convert_mul_mode(*mode),
                },
                predicate,
            )?;
        }
        MadInstr::Float {
            // Rounding mode and subnormal flushing don't apply over the reals.
            rnd: _rnd,
            ftz: _ftz,
            sat,
            ty,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            if *sat {
                return Err(unsupported("mad.f", ".sat modifier"));
            }
            check_not_packed(*ty, "mad")?;

            let dst_typed = ctx.resolve_dst_typed(dst)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;
            let src_c_typed = ctx.resolve_operand_typed(src_c)?;

            ctx.check_dst_type(&dst_typed, *ty, "mad.f")?;
            ctx.check_operand_type(&src_a_typed, *ty, "mad.f")?;
            ctx.check_operand_type(&src_b_typed, *ty, "mad.f")?;
            ctx.check_operand_type(&src_c_typed, *ty, "mad.f")?;

            ctx.emit(
                LoweredInstr::Fma {
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    src_c: src_c_typed.operand,
                    ty: *ty,
                    mul_ty: *ty,
                    clamp: None,
                },
                predicate,
            )?;
        }
    }
    Ok(())
}

pub(super) fn lower_fma(
    ctx: &mut LoweringContext,
    fma: &FmaInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // In every accepted arm the rounding mode (and ftz, where present) is
    // ignorable: floats are reals here, so the fused multiply-add is exact.
    // `.sat`/`.relu` are exact value clamps, threaded through as `Clamp`.
    let (ty, src_ty, instr_name, clamp, dst, src_a, src_b, src_c) = match fma {
        FmaInstr::Float32 {
            rnd: _rnd,
            ftz: _ftz,
            sat,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            let ty = ScalarType::F32;
            let clamp = sat.then_some(Clamp::Sat);
            (ty, ty, "fma.rn.f32", clamp, dst, src_a, src_b, src_c)
        }
        FmaInstr::Float32x2 {
            // Packed single precision (sm_100+), per lane like `fma.rn.f32`.
            rnd: _rnd,
            ftz: _ftz,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            let ty = ScalarType::F32x2;
            (ty, ty, "fma.rn.f32x2", None, dst, src_a, src_b, src_c)
        }
        FmaInstr::Float64 {
            rnd: _rnd,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            let ty = ScalarType::F64;
            (ty, ty, "fma.rn.f64", None, dst, src_a, src_b, src_c)
        }
        FmaInstr::HalfF16Sat {
            rnd: _rnd,
            ftz: _ftz,
            sat,
            ty,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            check_packed_arithmetic(*ty, "fma")?;
            let clamp = sat.then_some(Clamp::Sat);
            (*ty, *ty, "fma.rn.f16", clamp, dst, src_a, src_b, src_c)
        }
        FmaInstr::HalfF16Relu {
            rnd: _rnd,
            ftz: _ftz,
            ty,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            check_packed_arithmetic(*ty, "fma")?;
            let clamp = Some(Clamp::Relu);
            (*ty, *ty, "fma.rn.relu.f16", clamp, dst, src_a, src_b, src_c)
        }
        FmaInstr::HalfBf16 {
            rnd: _rnd,
            relu,
            ty,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            if *relu {
                return Err(unsupported("fma.rn.bf16", ".relu modifier"));
            }
            check_packed_arithmetic(*ty, "fma")?;
            (*ty, *ty, "fma.rn.bf16", None, dst, src_a, src_b, src_c)
        }
        FmaInstr::Oob { .. } => {
            return Err(unsupported("fma.rn.oob", ".oob modifier"));
        }
        FmaInstr::MixedPrecision {
            rnd: _rnd,
            sat,
            src_type,
            dst,
            src_a,
            src_b,
            src_c,
        } => {
            if *sat {
                return Err(unsupported("fma.rn.f32 (mixed)", ".sat modifier"));
            }
            check_not_packed(*src_type, "fma (mixed)")?;
            (
                ScalarType::F32,
                *src_type,
                "fma.rn.f32 (mixed)",
                None,
                dst,
                src_a,
                src_b,
                src_c,
            )
        }
    };

    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_a_typed = ctx.resolve_operand_typed(src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(src_b)?;
    let src_c_typed = ctx.resolve_operand_typed(src_c)?;

    // For mixed precision FMA, the multiplicands are half precision while
    // the accumulator and destination are f32; otherwise all agree with ty.
    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_a_typed, src_ty, instr_name)?;
    ctx.check_operand_type(&src_b_typed, src_ty, instr_name)?;
    ctx.check_operand_type(&src_c_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::Fma {
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            src_c: src_c_typed.operand,
            ty,
            mul_ty: src_ty,
            clamp,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_div(
    ctx: &mut LoweringContext,
    div: &DivInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // rnd/ftz and the approx/full/ieee precision split are ignorable: floats
    // are reals here, so every division is exact.
    let (ty, instr_name, dst, src_a, src_b) = match div {
        DivInstr::Integer {
            ty,
            dst,
            src_a,
            src_b,
        } => (*ty, "div", dst, src_a, src_b),
        DivInstr::Approx {
            ftz: _ftz,
            dst,
            src_a,
            src_b,
        } => (ScalarType::F32, "div.approx.f32", dst, src_a, src_b),
        DivInstr::Full {
            ftz: _ftz,
            dst,
            src_a,
            src_b,
        } => (ScalarType::F32, "div.full.f32", dst, src_a, src_b),
        DivInstr::Ieee {
            rnd: _rnd,
            ftz: _ftz,
            ty,
            dst,
            src_a,
            src_b,
        } => (*ty, "div.rn", dst, src_a, src_b),
    };

    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_a_typed = ctx.resolve_operand_typed(src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(src_b)?;

    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_a_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_b_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::BinOp {
            op: BinOp::Div,
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            ty,
            clamp: None,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_rem(
    ctx: &mut LoweringContext,
    rem: &RemInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(&rem.dst)?;
    let src_a_typed = ctx.resolve_operand_typed(&rem.src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(&rem.src_b)?;

    ctx.check_dst_type(&dst_typed, rem.ty, "rem")?;
    ctx.check_operand_type(&src_a_typed, rem.ty, "rem")?;
    ctx.check_operand_type(&src_b_typed, rem.ty, "rem")?;

    ctx.emit(
        LoweredInstr::BinOp {
            op: BinOp::Rem,
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            ty: rem.ty,
            clamp: None,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_neg(
    ctx: &mut LoweringContext,
    neg: &NegInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // ftz is ignorable: subnormal flushing doesn't apply over the reals.
    let (ty, instr_name, dst, src) = match neg {
        NegInstr::Integer { ty, dst, src } => (*ty, "neg", dst, src),
        NegInstr::Float32 {
            ftz: _ftz,
            dst,
            src,
        } => (ScalarType::F32, "neg.f32", dst, src),
        NegInstr::Float64 { dst, src } => (ScalarType::F64, "neg.f64", dst, src),
        NegInstr::HalfF16 {
            ftz: _ftz,
            ty,
            dst,
            src,
        } => (*ty, "neg.f16", dst, src),
        NegInstr::HalfBf16 { ty, dst, src } => (*ty, "neg.bf16", dst, src),
    };
    check_packed_arithmetic(ty, instr_name)?;

    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_typed = ctx.resolve_operand_typed(src)?;

    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::UnaryOp {
            op: UnaryOp::Neg,
            dst: dst_typed.reg,
            src: src_typed.operand,
            ty,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_abs(
    ctx: &mut LoweringContext,
    abs: &AbsInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // ftz is ignorable: subnormal flushing doesn't apply over the reals.
    let (ty, instr_name, dst, src) = match abs {
        AbsInstr::Integer { ty, dst, src } => (*ty, "abs", dst, src),
        AbsInstr::Float32 {
            ftz: _ftz,
            dst,
            src,
        } => (ScalarType::F32, "abs.f32", dst, src),
        AbsInstr::Float64 { dst, src } => (ScalarType::F64, "abs.f64", dst, src),
        AbsInstr::HalfF16 {
            ftz: _ftz,
            ty,
            dst,
            src,
        } => (*ty, "abs.f16", dst, src),
        AbsInstr::HalfBf16 { ty, dst, src } => (*ty, "abs.bf16", dst, src),
    };
    check_packed_arithmetic(ty, instr_name)?;

    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_typed = ctx.resolve_operand_typed(src)?;

    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::UnaryOp {
            op: UnaryOp::Abs,
            dst: dst_typed.reg,
            src: src_typed.operand,
            ty,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `copysign.type d, a, b` (PTX ISA Block 32, `.f32`/`.f64` only, no
/// packed form). Per the ISA, `a` is the sign source and `b` the magnitude
/// source - see `CopysignInstr`.
pub(super) fn lower_copysign(
    ctx: &mut LoweringContext,
    copysign: &CopysignInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "copysign";
    let ty = copysign.ty;
    if !matches!(ty, ScalarType::F32 | ScalarType::F64) {
        return Err(unsupported(
            NAME,
            format!(".{:?} (only .f32/.f64 modeled)", ty),
        ));
    }

    let dst_typed = ctx.resolve_dst_typed(&copysign.dst)?;
    let sign_typed = ctx.resolve_operand_typed(&copysign.sign_src)?;
    let magnitude_typed = ctx.resolve_operand_typed(&copysign.magnitude_src)?;

    ctx.check_dst_type(&dst_typed, ty, NAME)?;
    ctx.check_operand_type(&sign_typed, ty, NAME)?;
    ctx.check_operand_type(&magnitude_typed, ty, NAME)?;

    ctx.emit(
        LoweredInstr::Copysign {
            dst: dst_typed.reg,
            sign_src: sign_typed.operand,
            magnitude_src: magnitude_typed.operand,
            ty,
        },
        predicate,
    )?;
    Ok(())
}

/// Shared lowering for float unary ops (rcp, sqrt, rsqrt, ...)
fn lower_float_unary(
    ctx: &mut LoweringContext,
    op: UnaryOp,
    instr_name: &str,
    ty: ScalarType,
    dst: &AstOperand,
    src: &AstOperand,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_typed = ctx.resolve_operand_typed(src)?;

    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::UnaryOp {
            op,
            dst: dst_typed.reg,
            src: src_typed.operand,
            ty,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_rcp(
    ctx: &mut LoweringContext,
    rcp: &RcpInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // rnd/ftz/approx are precision controls: floats are reals here,
    // so every reciprocal is exact and they change nothing.
    let (ty, dst, src) = match rcp {
        ast::RcpInstr::Approx {
            ftz: _ftz,
            ty,
            dst,
            src,
        } => (*ty, dst, src),
        ast::RcpInstr::Ieee {
            rnd: _rnd,
            ftz: _ftz,
            ty,
            dst,
            src,
        } => (*ty, dst, src),
    };
    lower_float_unary(ctx, UnaryOp::Rcp, "rcp", ty, dst, src, predicate)?;
    Ok(())
}

pub(super) fn lower_sqrt(
    ctx: &mut LoweringContext,
    sqrt: &SqrtInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // rnd/ftz/approx are precision controls: no effect over the reals.
    let (ty, dst, src) = match sqrt {
        ast::SqrtInstr::Approx {
            ftz: _ftz,
            dst,
            src,
        } => (ScalarType::F32, dst, src),
        ast::SqrtInstr::Ieee {
            rnd: _rnd,
            ftz: _ftz,
            ty,
            dst,
            src,
        } => (*ty, dst, src),
    };
    lower_float_unary(ctx, UnaryOp::Sqrt, "sqrt", ty, dst, src, predicate)?;
    Ok(())
}

pub(super) fn lower_rsqrt(
    ctx: &mut LoweringContext,
    rsqrt: &RsqrtInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // approx/ftz are precision controls: no effect over the reals.
    let ast::RsqrtInstr {
        approx: _approx,
        ftz: _ftz,
        ty,
        dst,
        src,
    } = rsqrt;
    lower_float_unary(ctx, UnaryOp::Rsqrt, "rsqrt", *ty, dst, src, predicate)?;
    Ok(())
}

/// log2(x), evaluated as log(x) / ln2.
pub(super) fn lower_lg2(
    ctx: &mut LoweringContext,
    lg2: &Lg2Instr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // approx/ftz are precision controls: no effect over the reals.
    // `lg2` is f32-only in the ISA, so there is no type to read
    // off the instruction.
    let ast::Lg2Instr {
        ftz: _ftz,
        dst,
        src,
    } = lg2;
    lower_float_unary(
        ctx,
        UnaryOp::Lg2,
        "lg2",
        ScalarType::F32,
        dst,
        src,
        predicate,
    )?;
    Ok(())
}

/// 2^x, evaluated as exp(x * ln2).
pub(super) fn lower_ex2(
    ctx: &mut LoweringContext,
    ex2: &Ex2Instr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let (dst, src) = match ex2 {
        ast::Ex2Instr::Float32 {
            ftz: _ftz,
            dst,
            src,
        } => (dst, src),
        ast::Ex2Instr::HalfF16 { .. } | ast::Ex2Instr::HalfBf16 { .. } => {
            return Err(unsupported("ex2", "f16/bf16 packed forms"));
        }
    };
    lower_float_unary(
        ctx,
        UnaryOp::Ex2,
        "ex2",
        ScalarType::F32,
        dst,
        src,
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_tanh(
    ctx: &mut LoweringContext,
    tanh: &TanhInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // .f32/.f16/.bf16 and packed .f16x2/.bf16x2 (PTX ISA Block 61)
    // are all modeled: Tanh reduces to (e^2x-1)/(e^2x+1), packed forms
    // run per lane. Anything else is invalid PTX (fail-closed check).
    if !matches!(
        tanh.ty,
        ScalarType::F32
            | ScalarType::F16
            | ScalarType::Bf16
            | ScalarType::F16x2
            | ScalarType::Bf16x2
    ) {
        return Err(unsupported("tanh", format!("{:?} (invalid PTX)", tanh.ty)));
    }
    lower_float_unary(
        ctx,
        UnaryOp::Tanh,
        "tanh",
        tanh.ty,
        &tanh.dst,
        &tanh.src,
        predicate,
    )?;
    Ok(())
}

/// Reject unmodeled float min/max modifiers. `.NaN` is accepted: it only
/// matters for NaN inputs, which Volta's reals never are. `.xorsign.abs`/`.abs`
/// change the computed value outright.
fn reject_minmax_modifiers(
    instruction: &str,
    _nan: bool,
    xorsign_abs: bool,
    abs: bool,
) -> LowerResult<()> {
    if xorsign_abs {
        return Err(unsupported(instruction, ".xorsign.abs modifier"));
    }
    if abs {
        return Err(unsupported(instruction, ".abs modifier"));
    }
    Ok(())
}

pub(super) fn lower_min(
    ctx: &mut LoweringContext,
    min: &MinInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let (ty, instr_name, dst, src_a, src_b) = match min {
        MinInstr::Integer {
            ty,
            dst,
            src_a,
            src_b,
        } => (*ty, "min", dst, src_a, src_b),
        MinInstr::IntegerRelu {
            relu,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            if *relu {
                return Err(unsupported("min", ".relu modifier"));
            }
            (*ty, "min", dst, src_a, src_b)
        }
        MinInstr::Float32 {
            // ftz is ignorable: subnormal flushing doesn't apply over the reals.
            ftz: _ftz,
            nan,
            xorsign_abs,
            abs,
            dst,
            src_a,
            src_b,
        } => {
            reject_minmax_modifiers("min.f32", *nan, *xorsign_abs, *abs)?;
            (ScalarType::F32, "min.f32", dst, src_a, src_b)
        }
        MinInstr::Float32Acc { .. } => {
            return Err(unsupported("min.f32", "3-input min"));
        }
        MinInstr::Float64 { dst, src_a, src_b } => (ScalarType::F64, "min.f64", dst, src_a, src_b),
        MinInstr::HalfF16 {
            // ftz is ignorable: subnormal flushing doesn't apply over the reals.
            ftz: _ftz,
            nan,
            xorsign_abs,
            abs,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            reject_minmax_modifiers("min.f16", *nan, *xorsign_abs, *abs)?;
            (*ty, "min.f16", dst, src_a, src_b)
        }
        MinInstr::HalfBf16 {
            nan,
            xorsign_abs,
            abs,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            reject_minmax_modifiers("min.bf16", *nan, *xorsign_abs, *abs)?;
            (*ty, "min.bf16", dst, src_a, src_b)
        }
    };
    check_packed_arithmetic(ty, instr_name)?;

    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_a_typed = ctx.resolve_operand_typed(src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(src_b)?;

    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_a_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_b_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::BinOp {
            op: BinOp::Min,
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            ty,
            clamp: None,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_max(
    ctx: &mut LoweringContext,
    max: &MaxInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let (ty, instr_name, dst, src_a, src_b) = match max {
        MaxInstr::Integer {
            ty,
            dst,
            src_a,
            src_b,
        } => (*ty, "max", dst, src_a, src_b),
        MaxInstr::IntegerRelu {
            relu,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            if *relu {
                return Err(unsupported("max", ".relu modifier"));
            }
            (*ty, "max", dst, src_a, src_b)
        }
        MaxInstr::Float32 {
            // ftz is ignorable: subnormal flushing doesn't apply over the reals.
            ftz: _ftz,
            nan,
            xorsign_abs,
            abs,
            dst,
            src_a,
            src_b,
        } => {
            reject_minmax_modifiers("max.f32", *nan, *xorsign_abs, *abs)?;
            (ScalarType::F32, "max.f32", dst, src_a, src_b)
        }
        MaxInstr::Float32Acc { .. } => {
            return Err(unsupported("max.f32", "3-input max"));
        }
        MaxInstr::Float64 { dst, src_a, src_b } => (ScalarType::F64, "max.f64", dst, src_a, src_b),
        MaxInstr::HalfF16 {
            // ftz is ignorable: subnormal flushing doesn't apply over the reals.
            ftz: _ftz,
            nan,
            xorsign_abs,
            abs,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            reject_minmax_modifiers("max.f16", *nan, *xorsign_abs, *abs)?;
            (*ty, "max.f16", dst, src_a, src_b)
        }
        MaxInstr::HalfBf16 {
            nan,
            xorsign_abs,
            abs,
            ty,
            dst,
            src_a,
            src_b,
        } => {
            reject_minmax_modifiers("max.bf16", *nan, *xorsign_abs, *abs)?;
            (*ty, "max.bf16", dst, src_a, src_b)
        }
    };
    check_packed_arithmetic(ty, instr_name)?;

    let dst_typed = ctx.resolve_dst_typed(dst)?;
    let src_a_typed = ctx.resolve_operand_typed(src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(src_b)?;

    ctx.check_dst_type(&dst_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_a_typed, ty, instr_name)?;
    ctx.check_operand_type(&src_b_typed, ty, instr_name)?;

    ctx.emit(
        LoweredInstr::BinOp {
            op: BinOp::Max,
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            ty,
            clamp: None,
        },
        predicate,
    )?;
    Ok(())
}

/// `and`, `or` and `xor`.
pub(super) fn lower_logic(
    ctx: &mut LoweringContext,
    op: BinOp,
    instr_name: &str,
    logic: &LogicInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(&logic.dst)?;
    let src_a_typed = ctx.resolve_operand_typed(&logic.src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(&logic.src_b)?;

    ctx.check_dst_type(&dst_typed, logic.ty, instr_name)?;
    ctx.check_operand_type(&src_a_typed, logic.ty, instr_name)?;
    ctx.check_operand_type(&src_b_typed, logic.ty, instr_name)?;

    ctx.emit(
        LoweredInstr::BinOp {
            op,
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            ty: logic.ty,
            clamp: None,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_not(
    ctx: &mut LoweringContext,
    not: &NotInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(&not.dst)?;
    let src_typed = ctx.resolve_operand_typed(&not.src)?;

    ctx.check_dst_type(&dst_typed, not.ty, "not")?;
    ctx.check_operand_type(&src_typed, not.ty, "not")?;

    ctx.emit(
        LoweredInstr::UnaryOp {
            op: UnaryOp::Not,
            dst: dst_typed.reg,
            src: src_typed.operand,
            ty: not.ty,
        },
        predicate,
    )?;
    Ok(())
}

/// `shl` and `shr`.
pub(super) fn lower_shift(
    ctx: &mut LoweringContext,
    op: BinOp,
    instr_name: &str,
    shift: &ShiftInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(&shift.dst)?;
    let src_a_typed = ctx.resolve_operand_typed(&shift.src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(&shift.src_b)?;

    ctx.check_dst_type(&dst_typed, shift.ty, instr_name)?;
    ctx.check_operand_type(&src_a_typed, shift.ty, instr_name)?;
    // PTX Documentation: Shift a left by the amount specified by unsigned 32-bit value in b. <-- U32 is the type for b
    ctx.check_operand_type(&src_b_typed, ScalarType::U32, instr_name)?;

    ctx.emit(
        LoweredInstr::BinOp {
            op,
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            ty: shift.ty,
            clamp: None,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_shf(
    ctx: &mut LoweringContext,
    shf: &ShfInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // Operands stay untyped here: `lo`/`hi` are `.b32` bit-vectors
    // whose runtime value kind (plain scalar or packed f16 pair)
    // decides the semantics - see `LoweredInstr::Shf`.
    let dst = ctx.resolve_dst_typed(&shf.dst)?.reg;
    let lo = ctx.resolve_operand(&shf.lo)?;
    let hi = ctx.resolve_operand(&shf.hi)?;
    let shift = ctx.resolve_operand(&shf.shift)?;

    ctx.emit(
        LoweredInstr::Shf {
            dst,
            lo,
            hi,
            shift,
            dir: shf.dir,
            mode: shf.mode,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_bfi(
    ctx: &mut LoweringContext,
    bfi: &BfiInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(&bfi.dst)?;
    let src_a_typed = ctx.resolve_operand_typed(&bfi.src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(&bfi.src_b)?;
    // start and len are typically u32 immediates or registers
    let start = ctx.resolve_operand(&bfi.start)?;
    let len = ctx.resolve_operand(&bfi.len)?;

    ctx.check_dst_type(&dst_typed, bfi.ty, "bfi")?;
    ctx.check_operand_type(&src_a_typed, bfi.ty, "bfi")?;
    ctx.check_operand_type(&src_b_typed, bfi.ty, "bfi")?;

    ctx.emit(
        LoweredInstr::Bfi {
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            start,
            len,
            ty: bfi.ty,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_bfe(
    ctx: &mut LoweringContext,
    bfe: &BfeInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(&bfe.dst)?;
    let src_a_typed = ctx.resolve_operand_typed(&bfe.src_a)?;
    // start and len are typically u32 immediates or registers
    let start = ctx.resolve_operand(&bfe.start)?;
    let len = ctx.resolve_operand(&bfe.len)?;

    ctx.check_dst_type(&dst_typed, bfe.ty, "bfe")?;
    ctx.check_operand_type(&src_a_typed, bfe.ty, "bfe")?;

    ctx.emit(
        LoweredInstr::Bfe {
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            start,
            len,
            ty: bfe.ty,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_prmt(
    ctx: &mut LoweringContext,
    prmt: &PrmtInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    if prmt.mode != ast::PrmtMode::None {
        return Err(unsupported("prmt", "mode modifiers"));
    }
    let dst = ctx.resolve_dst_typed(&prmt.dst)?;
    let src_a = ctx.resolve_operand_typed(&prmt.src_a)?;
    let src_b = ctx.resolve_operand_typed(&prmt.src_b)?;
    let selector = ctx.resolve_operand(&prmt.selector)?;
    ctx.check_dst_type(&dst, ScalarType::B32, "prmt")?;
    ctx.check_operand_type(&src_a, ScalarType::B32, "prmt")?;
    ctx.check_operand_type(&src_b, ScalarType::B32, "prmt")?;
    ctx.emit(
        LoweredInstr::Prmt {
            dst: dst.reg,
            src_a: src_a.operand,
            src_b: src_b.operand,
            selector,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_lop3(
    ctx: &mut LoweringContext,
    lop3: &Lop3Instr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    if lop3.bool_op.is_some() || lop3.dst_pred.is_some() || lop3.pred_q.is_some() {
        return Err(unsupported("lop3", "boolean or predicate-output modifiers"));
    }
    let dst = ctx.resolve_dst_typed(&lop3.dst)?;
    let src_a = ctx.resolve_operand_typed(&lop3.src_a)?;
    let src_b = ctx.resolve_operand_typed(&lop3.src_b)?;
    let src_c = ctx.resolve_operand_typed(&lop3.src_c)?;
    ctx.check_dst_type(&dst, ScalarType::B32, "lop3")?;
    ctx.check_operand_type(&src_a, ScalarType::B32, "lop3")?;
    ctx.check_operand_type(&src_b, ScalarType::B32, "lop3")?;
    ctx.check_operand_type(&src_c, ScalarType::B32, "lop3")?;
    ctx.emit(
        LoweredInstr::Lop3 {
            dst: dst.reg,
            src_a: src_a.operand,
            src_b: src_b.operand,
            src_c: src_c.operand,
            lut: ctx.resolve_operand(&lop3.lut)?,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_setp(
    ctx: &mut LoweringContext,
    setp: &SetpInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match setp {
        SetpInstr::Simple {
            cmp_op,
            // ftz is ignorable: subnormal flushing doesn't apply over the reals.
            ftz: _ftz,
            ty,
            dst_p,
            dst_q,
            src_a,
            src_b,
        } => {
            if dst_q.is_some() {
                return Err(unsupported("setp", "dual predicate destination p|q"));
            }

            // Destination is a predicate register
            let dst_typed = ctx.resolve_dst_typed(dst_p)?;
            let src_a_typed = ctx.resolve_operand_typed(src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(src_b)?;

            // Check destination is pred type
            ctx.check_dst_type(&dst_typed, ScalarType::Pred, "setp")?;
            // Check sources match instruction type
            ctx.check_operand_type(&src_a_typed, *ty, "setp")?;
            ctx.check_operand_type(&src_b_typed, *ty, "setp")?;

            ctx.emit(
                LoweredInstr::Setp {
                    cmp: ctx.convert_cmp_op(*cmp_op),
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: *ty,
                },
                predicate,
            )?;
        }
        SetpInstr::WithBoolOp { .. } => {
            return Err(unsupported(
                "setp",
                "boolean-combine modifier (.and/.or/.xor)",
            ));
        }
    }
    Ok(())
}

pub(super) fn lower_selp(
    ctx: &mut LoweringContext,
    selp: &SelpInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst_typed = ctx.resolve_dst_typed(&selp.dst)?;
    let src_a_typed = ctx.resolve_operand_typed(&selp.src_a)?;
    let src_b_typed = ctx.resolve_operand_typed(&selp.src_b)?;
    let pred_typed = ctx.resolve_operand_typed(&selp.src_c)?;

    ctx.check_dst_type(&dst_typed, selp.ty, "selp")?;
    ctx.check_operand_type(&src_a_typed, selp.ty, "selp")?;
    ctx.check_operand_type(&src_b_typed, selp.ty, "selp")?;
    // Predicate operand must be pred type
    ctx.check_operand_type(&pred_typed, ScalarType::Pred, "selp")?;

    ctx.emit(
        LoweredInstr::Selp {
            dst: dst_typed.reg,
            src_a: src_a_typed.operand,
            src_b: src_b_typed.operand,
            pred: pred_typed.operand,
            ty: selp.ty,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_cvt(
    ctx: &mut LoweringContext,
    cvt: &CvtInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match cvt {
        CvtInstr::Standard {
            rnd,
            // ftz is ignorable: subnormal flushing doesn't apply over the reals.
            ftz: _ftz,
            sat,
            relu,
            satfinite,
            dst_type,
            src_type,
            dst,
            src,
        } => {
            // `.e4m3x2` source (PTX ISA 9.7.9.22, `cvt.rn.f16x2.e4m3x2`):
            // its result is a `Pair`, so it bypasses the scalar path below
            // (see `LoweredInstr::CvtE4m3x2ToF16x2`).
            if *src_type == ScalarType::E4m3x2 {
                if *dst_type != ScalarType::F16x2 {
                    return Err(unsupported(
                        "cvt",
                        format!(
                            ".e4m3x2 source with .{:?} destination (only .f16x2 is modeled)",
                            dst_type
                        ),
                    ));
                }
                if *satfinite {
                    return Err(unsupported("cvt", ".satfinite modifier"));
                }
                if *sat {
                    return Err(unsupported(
                        "cvt",
                        ".sat modifier on an .e4m3x2 source (not a legal PTX combination)",
                    ));
                }
                match rnd {
                    Some(CvtRounding::Float(FpRound::Rn)) => {}
                    _ => {
                        return Err(unsupported(
                            "cvt",
                            "rounding modifier other than .rn on an .e4m3x2 source",
                        ));
                    }
                }
                let dst = ctx.resolve_dst(dst)?;
                let src = ctx.resolve_operand(src)?;
                ctx.emit(
                    LoweredInstr::CvtE4m3x2ToF16x2 {
                        dst,
                        src,
                        relu: *relu,
                    },
                    predicate,
                )?;
                return Ok(());
            }
            if *satfinite {
                // .satfinite clamps to the destination format's finite range
                // - a different, format-dependent semantics from the [0,1]
                // value clamp; not modeled.
                return Err(unsupported("cvt", ".satfinite modifier"));
            }
            // Float->float `.sat`/`.relu` are exact clamps over the reals
            // (`Clamp`). Integer-destination `.sat` is a different operation
            // and stays rejected, as do illegal destination types.
            let clamp = match (*sat, *relu) {
                (false, false) => None,
                (true, true) => {
                    return Err(unsupported("cvt", ".sat and .relu together (invalid PTX)"));
                }
                (true, false) => {
                    // ISA: the float `.sat` clamp applies to .f16/.f32/.f64
                    // destinations only.
                    if !is_scalar_float(*src_type)
                        || !matches!(
                            dst_type,
                            ScalarType::F16 | ScalarType::F32 | ScalarType::F64
                        )
                    {
                        return Err(unsupported(
                            "cvt",
                            ".sat modifier outside a float->float form with .f16/.f32/.f64 \
                             destination (integer saturation is not modeled)",
                        ));
                    }
                    Some(Clamp::Sat)
                }
                (false, true) => {
                    // ISA: the scalar `.relu` forms have .f16/.bf16
                    // destinations only.
                    if !is_scalar_float(*src_type)
                        || !matches!(dst_type, ScalarType::F16 | ScalarType::Bf16)
                    {
                        return Err(unsupported(
                            "cvt",
                            ".relu modifier outside a float->float form with .f16/.bf16 \
                             destination",
                        ));
                    }
                    Some(Clamp::Relu)
                }
            };
            match rnd {
                // Float rounding modes are ignorable: floats are reals here,
                // and float<->float conversion is the identity (the paper's
                // documented abstraction).
                None | Some(CvtRounding::Float(_)) => {}
                Some(CvtRounding::Integer(_)) => {
                    return Err(unsupported(
                        "cvt",
                        "integer-rounding modifier (floor/ceil/trunc/rint not modeled)",
                    ));
                }
                Some(CvtRounding::Stochastic) => {
                    return Err(unsupported("cvt", ".rs stochastic-rounding modifier"));
                }
                // .rna is how PTX rounds f32 to tf32 for tensor cores; tf32
                // values are reals here, so the conversion is the identity.
                Some(CvtRounding::Rna) if matches!(dst_type, ScalarType::Tf32) => {}
                Some(CvtRounding::Rna) => {
                    return Err(unsupported(
                        "cvt",
                        ".rna rounding modifier outside a .tf32 destination",
                    ));
                }
            }

            let dst = ctx.resolve_dst(dst)?;
            let src = ctx.resolve_operand(src)?;
            ctx.emit(
                LoweredInstr::Cvt {
                    dst,
                    src,
                    dst_ty: *dst_type,
                    src_ty: *src_type,
                    clamp,
                },
                predicate,
            )?;
        }
        CvtInstr::Pack { .. } => {
            return Err(unsupported(
                "cvt.pack",
                "pack conversion (two-source packing)",
            ));
        }
        CvtInstr::PackHalves {
            rnd,
            dst_type,
            src_type,
            dst,
            src_hi,
            src_lo,
        } => {
            // Same rounding policy as Standard: floats are exact reals
            // here, so only "no rounding" or an FP rounding mode (itself
            // ignored) are compatible with the identity conversion.
            match rnd {
                None | Some(CvtRounding::Float(_)) => {}
                Some(CvtRounding::Integer(_)) => {
                    return Err(unsupported(
                        "cvt",
                        "integer-rounding modifier (floor/ceil/trunc/rint not modeled)",
                    ));
                }
                Some(CvtRounding::Stochastic) => {
                    return Err(unsupported("cvt", ".rs stochastic-rounding modifier"));
                }
                // .rna is how PTX rounds f32 to tf32 for tensor cores; tf32
                // values are reals here, so the conversion is the identity.
                Some(CvtRounding::Rna) if matches!(dst_type, ScalarType::Tf32) => {}
                Some(CvtRounding::Rna) => {
                    return Err(unsupported(
                        "cvt",
                        ".rna rounding modifier outside a .tf32 destination",
                    ));
                }
            }
            let dst_half_ty = match dst_type {
                ScalarType::F16x2 => ScalarType::F16,
                ScalarType::Bf16x2 => ScalarType::Bf16,
                _ => unreachable!("parse_cvt only builds PackHalves for f16x2/bf16x2 destinations"),
            };

            let dst = ctx.resolve_dst(dst)?;
            let src_hi = ctx.resolve_operand(src_hi)?;
            let src_lo = ctx.resolve_operand(src_lo)?;
            ctx.emit(
                LoweredInstr::CvtPackHalves {
                    dst,
                    src_hi,
                    src_lo,
                    dst_half_ty,
                    src_ty: *src_type,
                },
                predicate,
            )?;
        }
    }
    Ok(())
}
