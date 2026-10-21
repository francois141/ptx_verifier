//! Lowering of `wgmma.mma_async` and of its `fence`/`commit_group`/
//! `wait_group` companions.

use volta_frontend::ast::{Operand as AstOperand, ScalarType};
use volta_frontend::lex::DottedIdent;

use crate::ir::mma::MmaShape;
use crate::ir::{LoweredInstr, Operand, Predicate};

use super::context::{LoweringContext, parse_scalar_type_modifier, unsupported};
use super::error::{LowerError, LowerResult};

/// Lower dense `.f32`-accumulator `wgmma.mma_async` m64nNk16 f16 and m64nNk32
/// fp8 (PTX ISA 9.7.17.5.2) with both operands as descriptors and no negate
/// (scales must be immediate `1`); `imm-trans-*` resolve to `bool`.
pub(super) fn lower_wgmma_mma_async(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "wgmma.mma_async";
    let mut shape: Option<MmaShape> = None;
    let mut types: Vec<ScalarType> = Vec::new();

    for modifier in modifiers {
        let s = modifier.to_string();
        if s == "sync" || s == "aligned" {
            // The modeled execution mode.
        } else if let Some(sh) = MmaShape::parse(&s) {
            shape = Some(sh);
        } else if let Some(ty) = parse_scalar_type_modifier(modifier) {
            types.push(ty);
        } else {
            return Err(unsupported(NAME, format!("modifier .{}", s)));
        }
    }

    let is_fp8 = |ty: ScalarType| matches!(ty, ScalarType::E4m3 | ScalarType::E5m2);
    let (a_type, b_type, k) = match types[..] {
        [ScalarType::F32, ScalarType::F16, ScalarType::F16] => {
            (ScalarType::F16, ScalarType::F16, 16)
        }
        [ScalarType::F32, a, b] if is_fp8(a) && is_fp8(b) => (a, b, 32),
        _ => {
            return Err(unsupported(
                NAME,
                format!(
                    "type combination {:?} (only .f32.f16.f16 and .f32 with .e4m3/.e5m2 \
                     multiplicands are modeled)",
                    types
                ),
            ));
        }
    };

    let shape =
        shape.ok_or_else(|| unsupported(NAME, "missing shape modifier (e.g. .m64n256k16)"))?;
    if shape.m != 64 || shape.k != k || shape.n == 0 || shape.n > 256 || !shape.n.is_multiple_of(8)
    {
        return Err(unsupported(
            NAME,
            format!(
                "shape {} for {:?} multiplicands (only .m64nNk{}, N a multiple of 8 in \
                 8..=256, is modeled)",
                shape, a_type, k
            ),
        ));
    }

    // The FP8 form has no imm-trans-a/imm-trans-b operands.
    let operand_count = if k == 16 { 8 } else { 6 };
    if operands.len() != operand_count {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected d, a-desc, b-desc, scale-d, imm-scale-a, imm-scale-b, \
                     plus imm-trans-a, imm-trans-b for .f16 (register-resident A is not \
                     modeled)",
        });
    }
    let [
        d,
        a_op,
        b_desc_op,
        scale_d_op,
        imm_scale_a_op,
        imm_scale_b_op,
        trans_ops @ ..,
    ] = operands
    else {
        unreachable!()
    };
    if matches!(a_op, AstOperand::Vector(_)) {
        return Err(unsupported(
            NAME,
            "register-resident matrix A (the `d, a, b-desc, ...` syntax form) is not modeled",
        ));
    }

    let dst = ctx.resolve_dst_vector(d)?;
    if dst.len() != (shape.n / 2) as usize {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", d),
            reason: "d must have exactly N/2 f32 registers",
        });
    }
    let a_desc = ctx.resolve_operand(a_op)?;
    let b_desc = ctx.resolve_operand(b_desc_op)?;
    let scale_d = ctx.resolve_operand(scale_d_op)?;

    for (name, op) in [
        ("imm-scale-a", imm_scale_a_op),
        ("imm-scale-b", imm_scale_b_op),
    ] {
        match ctx.resolve_operand(op)? {
            Operand::ImmI64(1) => {}
            Operand::ImmI64(-1) => {
                return Err(unsupported(
                    NAME,
                    format!("{} = -1 (negate) is not modeled", name),
                ));
            }
            other => {
                return Err(LowerError::InvalidOperand {
                    instruction: NAME.to_string(),
                    operand: format!("{:?}", other),
                    reason: "must be the compile-time immediate 1 or -1",
                });
            }
        }
    }

    let mut transposes = [false; 2];
    for ((transpose, op), name) in transposes
        .iter_mut()
        .zip(trans_ops)
        .zip(["imm-trans-a", "imm-trans-b"])
    {
        *transpose =
            match ctx.resolve_const_u32(op, NAME, "imm-trans-a/imm-trans-b must be 0 or 1")? {
                0 => false,
                1 => true,
                other => {
                    return Err(unsupported(
                        NAME,
                        format!("{} = {} (must be 0 or 1)", name, other),
                    ));
                }
            };
    }
    let [transpose_a, transpose_b] = transposes;

    ctx.emit(
        LoweredInstr::WgmmaMmaAsync {
            shape,
            dst,
            a_desc,
            b_desc,
            scale_d,
            a_type,
            b_type,
            transpose_a,
            transpose_b,
        },
        predicate,
    )?;
    Ok(())
}

/// Shared grammar for `wgmma.fence`/`wgmma.commit_group` (PTX ISA
/// 9.7.17.7.1/.2): exactly `.sync.aligned`, no operands, and no modeled data
/// effect, so `instr` is emitted unchanged.
fn lower_wgmma_sync_aligned_only(
    ctx: &mut LoweringContext,
    name: &str,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    instr: LoweredInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let (mut saw_sync, mut saw_aligned) = (false, false);
    for modifier in modifiers {
        match modifier.to_string().as_str() {
            "sync" => saw_sync = true,
            "aligned" => saw_aligned = true,
            other => return Err(unsupported(name, format!("modifier .{}", other))),
        }
    }
    if !saw_sync || !saw_aligned {
        return Err(unsupported(
            name,
            "missing mandatory .sync.aligned qualifiers",
        ));
    }
    if !operands.is_empty() {
        return Err(LowerError::InvalidOperand {
            instruction: name.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected no operands",
        });
    }
    ctx.emit(instr, predicate)?;
    Ok(())
}

/// Lower `wgmma.fence.sync.aligned;` (PTX ISA 9.7.17.7.1).
pub(super) fn lower_wgmma_fence(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    lower_wgmma_sync_aligned_only(
        ctx,
        "wgmma.fence",
        modifiers,
        operands,
        LoweredInstr::WgmmaFence,
        predicate,
    )
}

/// Lower `wgmma.commit_group.sync.aligned;` (PTX ISA 9.7.17.7.2).
pub(super) fn lower_wgmma_commit_group(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    lower_wgmma_sync_aligned_only(
        ctx,
        "wgmma.commit_group",
        modifiers,
        operands,
        LoweredInstr::WgmmaCommitGroup,
        predicate,
    )
}

/// Lower `wgmma.wait_group.sync.aligned N;` (PTX ISA 9.7.17.7.3). `N` is
/// validated (must be a compile-time non-negative integer, per the ISA)
/// and kept - see `LoweredInstr::WgmmaWaitGroup`'s doc comment.
pub(super) fn lower_wgmma_wait_group(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "wgmma.wait_group";
    let (mut saw_sync, mut saw_aligned) = (false, false);
    for modifier in modifiers {
        match modifier.to_string().as_str() {
            "sync" => saw_sync = true,
            "aligned" => saw_aligned = true,
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }
    if !saw_sync || !saw_aligned {
        return Err(unsupported(
            NAME,
            "missing mandatory .sync.aligned qualifiers",
        ));
    }
    let [n] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected N",
        });
    };
    let n = ctx.resolve_const_u32(n, NAME, "N must be a compile-time non-negative integer")?;
    ctx.emit(LoweredInstr::WgmmaWaitGroup { n }, predicate)?;
    Ok(())
}
