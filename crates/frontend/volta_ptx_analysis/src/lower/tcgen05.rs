//! Lowering of the 5th-generation tensor core instructions (`tcgen05.*`).

use crate::frontend::ascii::AsciiSliceExt;
use crate::frontend::ast::{
    FromAscii, Operand as AstOperand, ScalarType, SharedStateSpaceQualifier,
};
use crate::frontend::lex::DottedIdent;

use crate::ir::tcgen05::{
    Tcgen05Collector, Tcgen05CollectorOp, Tcgen05FenceDirection, Tcgen05LdStShape, Tcgen05MmaA,
    Tcgen05MmaKind, Tcgen05MmaScales,
};
use crate::ir::{LoweredInstr, Operand, Predicate};

use super::context::{LoweringContext, unsupported};
use super::error::{LowerError, LowerResult};

/// Reject a warp-collective `tcgen05.*` instruction missing its mandatory
/// `.sync.aligned` qualifiers (PTX ISA 9.7.18.7-9: "The mandatory .sync
/// qualifier ..." / "The mandatory .aligned qualifier ...").
fn require_sync_aligned(modifiers: &[DottedIdent], instruction: &'static str) -> LowerResult<()> {
    for required in ["sync", "aligned"] {
        if !modifiers.iter().any(|m| m.to_string() == required) {
            return Err(LowerError::InvalidInstruction {
                instruction: instruction.to_string(),
                reason: format!("missing the mandatory .{required} qualifier"),
            });
        }
    }
    Ok(())
}

/// Parse the `.cta_group::{1,2}` qualifier every `tcgen05.*` requires (PTX ISA
/// 9.7.17.5). `::2` (CTA pairs) is unmodeled and rejected loudly. Returns
/// `None` for a modifier that isn't `.cta_group::N`, so callers fall through.
fn parse_tcgen05_cta_group(
    modifier: &DottedIdent,
    instruction: &'static str,
) -> Option<LowerResult<()>> {
    let DottedIdent::Qualified(parts) = modifier else {
        return None;
    };
    let [base, sub] = parts.as_slice() else {
        return None;
    };
    if base.as_slice().as_bytes() != b"cta_group" {
        return None;
    }
    Some(match sub.as_slice().as_bytes() {
        b"1" => Ok(()),
        b"2" => Err(unsupported(
            instruction,
            "cta_group::2 (peer-CTA collective execution is not modeled)",
        )),
        _ => Err(unsupported(instruction, format!("cta_group::{sub}"))),
    })
}

/// Why `.exclusive` `tcgen05.alloc`/`.dealloc` is rejected: exclusive
/// allocations (PTX ISA 9.4+) have their own rules that `TensorMemory` does
/// not model, and the non-exclusive power-of-2 rules would misjudge them.
const EXCLUSIVE_ALLOCATION: &str =
    ".exclusive (an exclusive Tensor Memory allocation) is not implemented yet";

/// Lower `tcgen05.alloc.cta_group::1.sync.aligned{.shared::cta}.b32 [dst], nCols`.
pub(super) fn lower_tcgen05_alloc(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.alloc";
    require_sync_aligned(modifiers, NAME)?;
    let mut saw_cta_group = false;

    for modifier in modifiers {
        if let Some(result) = parse_tcgen05_cta_group(modifier, NAME) {
            result?;
            saw_cta_group = true;
            continue;
        }
        // `dst` is always shared memory whether or not this qualifier is
        // written (PTX ISA 9.7.17.7), so it is consumed but not stored.
        if let DottedIdent::Qualified(parts) = modifier
            && let [base, sub] = parts.as_slice()
            && base.as_slice().as_bytes() == b"shared"
        {
            match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                Some(SharedStateSpaceQualifier::Cta) => continue,
                _ => return Err(unsupported(NAME, format!("modifier .shared::{sub}"))),
            }
        }
        match modifier.to_string().as_str() {
            "sync" | "aligned" | "shared" | "b32" => {}
            "exclusive" => return Err(unsupported(NAME, EXCLUSIVE_ALLOCATION)),
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }
    if !saw_cta_group {
        return Err(unsupported(NAME, "missing .cta_group::1 modifier"));
    }

    let [dst, num_cols] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected destination address and column-count operands",
        });
    };
    let (dst_base, dst_offset) = match dst {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };
    let num_cols = resolve_num_cols(ctx, num_cols, NAME)?;

    ctx.emit(
        LoweredInstr::Tcgen05Alloc {
            dst_base,
            dst_offset,
            num_cols,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `tcgen05.dealloc.cta_group::1.sync.aligned.b32 taddr, nCols`.
pub(super) fn lower_tcgen05_dealloc(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.dealloc";
    require_sync_aligned(modifiers, NAME)?;
    let mut saw_cta_group = false;

    for modifier in modifiers {
        if let Some(result) = parse_tcgen05_cta_group(modifier, NAME) {
            result?;
            saw_cta_group = true;
            continue;
        }
        match modifier.to_string().as_str() {
            "sync" | "aligned" | "b32" => {}
            "exclusive" => return Err(unsupported(NAME, EXCLUSIVE_ALLOCATION)),
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }
    if !saw_cta_group {
        return Err(unsupported(NAME, "missing .cta_group::1 modifier"));
    }

    let [taddr, num_cols] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected taddr and column-count operands",
        });
    };
    let taddr = ctx.resolve_operand(taddr)?;
    let num_cols = resolve_num_cols(ctx, num_cols, NAME)?;

    ctx.emit(LoweredInstr::Tcgen05Dealloc { taddr, num_cols }, predicate)?;
    Ok(())
}

/// Resolve `tcgen05.alloc`/`.dealloc`'s `nCols`: a 32-bit integer immediate, or a
/// 32-bit integer register whose value the evaluator checks like an immediate.
fn resolve_num_cols(
    ctx: &LoweringContext,
    num_cols: &AstOperand,
    name: &str,
) -> LowerResult<Operand> {
    const REASON: &str = "nCols must be a 32-bit integer immediate or register";

    match num_cols {
        AstOperand::ImmInt(_) | AstOperand::ImmUInt(_) => {
            let n = ctx.resolve_const_u32(num_cols, name, REASON)?;
            Ok(Operand::ImmU64(u64::from(n)))
        }
        AstOperand::Ident(_) | AstOperand::VectorElement(..) => {
            // `U32`, not the instruction's `.b32`: a `.b32` operand also takes `.f32` registers.
            let resolved = ctx.resolve_operand_typed(num_cols)?;
            ctx.check_operand_type(&resolved, ScalarType::U32, name)?;
            Ok(resolved.operand)
        }
        _ => Err(LowerError::InvalidOperand {
            instruction: name.to_string(),
            operand: format!("{num_cols:?}"),
            reason: REASON,
        }),
    }
}

/// Lower `tcgen05.relinquish_alloc_permit.cta_group::1.sync.aligned`.
pub(super) fn lower_tcgen05_relinquish_alloc_permit(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.relinquish_alloc_permit";
    require_sync_aligned(modifiers, NAME)?;
    let mut saw_cta_group = false;

    for modifier in modifiers {
        if let Some(result) = parse_tcgen05_cta_group(modifier, NAME) {
            result?;
            saw_cta_group = true;
            continue;
        }
        match modifier.to_string().as_str() {
            "sync" | "aligned" => {}
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }
    if !saw_cta_group {
        return Err(unsupported(NAME, "missing .cta_group::1 modifier"));
    }
    if !operands.is_empty() {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected no operands",
        });
    }

    ctx.emit(LoweredInstr::Tcgen05RelinquishAllocPermit, predicate)?;
    Ok(())
}

/// Parse the `.x1`/`.x2`/.../`.x128` repeat-factor modifier common to
/// `tcgen05.ld`/`.st` (PTX ISA 9.7.17.2.3, Table 52/53). Returns `None` for
/// a modifier that isn't one of these, so callers can fall through.
fn parse_tcgen05_num(modifier: &str) -> Option<u32> {
    Some(match modifier {
        "x1" => 1,
        "x2" => 2,
        "x4" => 4,
        "x8" => 8,
        "x16" => 16,
        "x32" => 32,
        "x64" => 64,
        "x128" => 128,
        _ => return None,
    })
}

/// A `tcgen05.ld`/`.st` shape qualifier; `.16x32bx2` is completed by its
/// `immHalfSplitoff` operand.
#[derive(Clone, Copy)]
enum Tcgen05ShapeQualifier {
    Whole(Tcgen05LdStShape),
    HalfSplit,
}

/// Parse the `.32x32b`/`.16x256b`/`.16x32bx2` shape shared by `tcgen05.ld`/`.st`
/// (PTX ISA 9.7.17.8, Tables 52/53), or `None`. Other shapes are absent: their
/// mappings are unestablished (see [`Tcgen05LdStShape::cell`]).
fn parse_tcgen05_shape(modifier: &str) -> Option<Tcgen05ShapeQualifier> {
    Some(match modifier {
        "32x32b" => Tcgen05ShapeQualifier::Whole(Tcgen05LdStShape::S32x32b),
        "16x256b" => Tcgen05ShapeQualifier::Whole(Tcgen05LdStShape::S16x256b),
        "16x32bx2" => Tcgen05ShapeQualifier::HalfSplit,
        _ => return None,
    })
}

/// The access shape: `immHalfSplitoff` is an operand exactly when the shape is `.16x32bx2`.
fn resolve_tcgen05_shape(
    ctx: &LoweringContext,
    name: &str,
    shape: Tcgen05ShapeQualifier,
    half_split_off: Option<&AstOperand>,
) -> LowerResult<Tcgen05LdStShape> {
    match (shape, half_split_off) {
        (Tcgen05ShapeQualifier::Whole(shape), None) => Ok(shape),
        (Tcgen05ShapeQualifier::HalfSplit, Some(off)) => {
            let half_split_off =
                ctx.resolve_const_u32(off, name, "immHalfSplitoff must be an integer immediate")?;
            Ok(Tcgen05LdStShape::S16x32bx2 { half_split_off })
        }
        (_, off) => Err(LowerError::InvalidOperand {
            instruction: name.to_string(),
            operand: format!("{off:?}"),
            reason: "immHalfSplitoff is given exactly when .shape is .16x32bx2",
        }),
    }
}

/// The register count `.shape` + `.num` implies per thread, checked
/// against the vector the kernel actually wrote: one `.xN` repeats the
/// shape's unit `N` times, and each unit is `regs_per_unit` registers.
fn tcgen05_vector_len(
    name: &str,
    shape: Tcgen05LdStShape,
    num: u32,
    actual: usize,
) -> LowerResult<()> {
    let expected = (num * shape.regs_per_unit()) as usize;
    if actual != expected {
        return Err(LowerError::InvalidOperand {
            instruction: name.to_string(),
            operand: format!("{actual} registers"),
            reason: "vector length does not match .shape and .num",
        });
    }
    Ok(())
}

/// Lower `tcgen05.ld.sync.aligned.shape.num.b32 r, [taddr]{, immHalfSplitoff}`. Shapes are
/// limited to those `parse_tcgen05_shape` models; `.red`/`.pack::16b` are
/// rejected loudly rather than half-modeled.
pub(super) fn lower_tcgen05_ld(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.ld";
    require_sync_aligned(modifiers, NAME)?;
    let mut num: Option<u32> = None;
    let mut shape: Option<Tcgen05ShapeQualifier> = None;

    for modifier in modifiers {
        let s = modifier.to_string();
        if let Some(n) = parse_tcgen05_num(&s) {
            num = Some(n);
            continue;
        }
        if let Some(sh) = parse_tcgen05_shape(&s) {
            shape = Some(sh);
            continue;
        }
        match s.as_str() {
            "sync" | "aligned" | "b32" => {}
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }
    let num = num.ok_or_else(|| unsupported(NAME, "missing .x1/.x2/.../.x128 modifier"))?;
    let shape = shape.ok_or_else(|| unsupported(NAME, "missing or unmodeled .shape"))?;

    let (dst, taddr, half_split_off) = match operands {
        [dst, taddr] => (dst, taddr, None),
        [dst, taddr, off] => (dst, taddr, Some(off)),
        _ => {
            return Err(LowerError::InvalidOperand {
                instruction: NAME.to_string(),
                operand: format!("{:?}", operands),
                reason: "expected destination vector, address and, for .16x32bx2, immHalfSplitoff operands",
            });
        }
    };
    let shape = resolve_tcgen05_shape(ctx, NAME, shape, half_split_off)?;
    let dst = ctx.resolve_dst_vector(dst)?;
    tcgen05_vector_len(NAME, shape, num, dst.len())?;
    let (taddr_base, taddr_offset) = match taddr {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };

    ctx.emit(
        LoweredInstr::Tcgen05Ld {
            shape,
            dst,
            taddr_base,
            taddr_offset,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `tcgen05.st.sync.aligned.shape.num.b32 [taddr], {immHalfSplitoff,} r`. Same shape
/// restriction as `lower_tcgen05_ld`.
pub(super) fn lower_tcgen05_st(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.st";
    require_sync_aligned(modifiers, NAME)?;
    let mut num: Option<u32> = None;
    let mut shape: Option<Tcgen05ShapeQualifier> = None;

    for modifier in modifiers {
        let s = modifier.to_string();
        if let Some(n) = parse_tcgen05_num(&s) {
            num = Some(n);
            continue;
        }
        if let Some(sh) = parse_tcgen05_shape(&s) {
            shape = Some(sh);
            continue;
        }
        match s.as_str() {
            "sync" | "aligned" | "b32" => {}
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }
    let num = num.ok_or_else(|| unsupported(NAME, "missing .x1/.x2/.../.x128 modifier"))?;
    let shape = shape.ok_or_else(|| unsupported(NAME, "missing or unmodeled .shape"))?;

    let (taddr, half_split_off, src) = match operands {
        [taddr, src] => (taddr, None, src),
        [taddr, off, src] => (taddr, Some(off), src),
        _ => {
            return Err(LowerError::InvalidOperand {
                instruction: NAME.to_string(),
                operand: format!("{:?}", operands),
                reason: "expected address, for .16x32bx2 immHalfSplitoff, and source vector operands",
            });
        }
    };
    let shape = resolve_tcgen05_shape(ctx, NAME, shape, half_split_off)?;
    let (taddr_base, taddr_offset) = match taddr {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };
    let src = ctx.resolve_operand_vector(src)?;
    tcgen05_vector_len(NAME, shape, num, src.len())?;

    ctx.emit(
        LoweredInstr::Tcgen05St {
            shape,
            taddr_base,
            taddr_offset,
            src,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `tcgen05.wait::ld.sync.aligned` / `tcgen05.wait::st.sync.aligned`.
/// The trie resolves these to distinct `InstrKind`s, so `is_st` arrives as a
/// plain parameter.
pub(super) fn lower_tcgen05_wait(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
    is_st: bool,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.wait";
    require_sync_aligned(modifiers, NAME)?;

    for modifier in modifiers {
        match modifier.to_string().as_str() {
            "sync" | "aligned" => {}
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }

    if !operands.is_empty() {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected no operands",
        });
    }

    ctx.emit(LoweredInstr::Tcgen05Wait { is_st }, predicate)?;
    Ok(())
}

/// Lower dense `.cta_group::1` `tcgen05.mma.kind::{f16,f8f6f4}` (PTX ISA
/// 9.7.17.10.9.1), `.kind::mxf8f6f4.block_scale` or, if `weight_stationary`,
/// `.ws` (9.7.17.10.10.3). `A` is a descriptor or `[a-tmem]`; descriptors are
/// decoded at eval (`tcgen05_mma`).
pub(super) fn lower_tcgen05_mma(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
    weight_stationary: bool,
) -> LowerResult<()> {
    let name = if weight_stationary {
        "tcgen05.mma.ws"
    } else {
        "tcgen05.mma"
    };
    let mut saw_cta_group = false;
    let mut kind = None;
    let mut block_scale = false;
    let mut saw_scale_vector_size = false;
    let mut collector = weight_stationary.then_some(Tcgen05Collector {
        buffer: 0,
        op: Tcgen05CollectorOp::Discard,
    });

    for modifier in modifiers {
        if let Some(result) = parse_tcgen05_cta_group(modifier, name) {
            result?;
            saw_cta_group = true;
            continue;
        }
        if let DottedIdent::Qualified(parts) = modifier
            && let [base, sub] = parts.as_slice()
            && base.as_slice().as_bytes() == b"kind"
        {
            kind = Some(match sub.as_slice().as_bytes() {
                b"f16" => Tcgen05MmaKind::F16,
                b"f8f6f4" => Tcgen05MmaKind::F8f6f4,
                b"mxf8f6f4" => Tcgen05MmaKind::Mxf8f6f4,
                other => {
                    return Err(unsupported(
                        name,
                        format!(
                            "kind::{} (only .kind::f16, .kind::f8f6f4 and .kind::mxf8f6f4 are \
                             modeled)",
                            String::from_utf8_lossy(other)
                        ),
                    ));
                }
            });
            continue;
        }
        // `.kind::mxf8f6f4`'s one scale vector size, `.scale_vec::1X`, which
        // `.block32` aliases (PTX ISA Table 70).
        match modifier.to_string().as_str() {
            "block_scale" => {
                block_scale = true;
                continue;
            }
            "block32" | "scale_vec::1X" => {
                saw_scale_vector_size = true;
                continue;
            }
            "block16" | "scale_vec::2X" | "scale_vec::4X" => {
                return Err(unsupported(
                    name,
                    format!(
                        ".{modifier} (only .kind::mxf8f6f4's .block32 / .scale_vec::1X is \
                         modeled)"
                    ),
                ));
            }
            _ => {}
        }
        if let Some(collector) = collector.as_mut()
            && let DottedIdent::Qualified(parts) = modifier
            && let [base, buffer, op] = parts.as_slice()
            && base.as_slice().as_bytes() == b"collector"
        {
            collector.buffer = match buffer.as_slice().as_bytes() {
                b"b0" => 0,
                b"b1" => 1,
                b"b2" => 2,
                b"b3" => 3,
                _ => return Err(unsupported(name, format!("modifier .{modifier}"))),
            };
            collector.op = match op.as_slice().as_bytes() {
                b"fill" => Tcgen05CollectorOp::Fill,
                b"use" => Tcgen05CollectorOp::Use,
                b"lastuse" => Tcgen05CollectorOp::LastUse,
                b"discard" => Tcgen05CollectorOp::Discard,
                _ => return Err(unsupported(name, format!("modifier .{modifier}"))),
            };
            continue;
        }
        return Err(unsupported(name, format!("modifier .{}", modifier)));
    }
    if !saw_cta_group {
        return Err(unsupported(name, "missing .cta_group::1 modifier"));
    }
    let Some(kind) = kind else {
        return Err(unsupported(name, "missing .kind modifier"));
    };
    let invalid = |reason: &str| LowerError::InvalidInstruction {
        instruction: name.to_string(),
        reason: reason.to_string(),
    };
    if block_scale != (kind == Tcgen05MmaKind::Mxf8f6f4) {
        return Err(invalid(
            "`.block_scale` goes with a block-scaled `.kind` (`.kind::mxf8f6f4`) and only there",
        ));
    }
    if saw_scale_vector_size && !block_scale {
        return Err(invalid("a scale vector size needs `.block_scale`"));
    }
    if block_scale && weight_stationary {
        return Err(unsupported(
            name,
            "`.block_scale` with `.ws` is not modeled",
        ));
    }

    // `disable-output-lane` is optional in practice (LLVM's NVPTX emits the
    // 5-operand form), so tell it apart by operand type: a `Vector` in its
    // slot is the mask, anything else is `enable-input-d`.
    let [d_tmem, a_operand, b_desc, idesc, rest @ ..] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: name.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [d-tmem], a-desc|[a-tmem], b-desc, idesc, \
                     {disable-output-lane}, enable-input-d",
        });
    };
    let (d_tmem_base, d_tmem_offset) = match d_tmem {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };
    let a = match a_operand {
        AstOperand::Address(a) => Tcgen05MmaA::Tmem {
            base: ctx.resolve_address(a)?,
            offset: ctx.get_address_offset(a),
        },
        other => Tcgen05MmaA::Desc(ctx.resolve_operand(other)?),
    };
    let b_desc = ctx.resolve_operand(b_desc)?;
    let idesc = ctx.resolve_operand(idesc)?;

    // `.block_scale` puts `[scale-A-tmem], [scale-B-tmem]` where the other
    // forms have `disable-output-lane`, which it lacks.
    let (scales, rest) = match rest {
        [
            AstOperand::Address(scale_a),
            AstOperand::Address(scale_b),
            rest @ ..,
        ] if block_scale => {
            let a = (
                ctx.resolve_address(scale_a)?,
                ctx.get_address_offset(scale_a),
            );
            let b = (
                ctx.resolve_address(scale_b)?,
                ctx.get_address_offset(scale_b),
            );
            (Some(Tcgen05MmaScales { a, b }), rest)
        }
        _ if block_scale => {
            return Err(LowerError::InvalidOperand {
                instruction: name.to_string(),
                operand: format!("{:?}", operands),
                reason: "expected [d-tmem], a-desc|[a-tmem], b-desc, idesc, [scale-A-tmem], \
                         [scale-B-tmem], enable-input-d",
            });
        }
        rest => (None, rest),
    };

    let (mask_elems, rest): (Option<&[AstOperand]>, &[AstOperand]) = match rest {
        [AstOperand::Vector(v), rest @ ..] if !weight_stationary && !block_scale => (Some(v), rest),
        rest => (None, rest),
    };
    // `.cta_group::1` masks have exactly 4 elements (one bit per lane 0-127);
    // an absent mask means no lane is disabled.
    let disable_output_lane = match mask_elems {
        Some(elems) if elems.len() == 4 => elems
            .iter()
            .map(|e| ctx.resolve_operand(e))
            .collect::<LowerResult<Vec<_>>>()?,
        Some(elems) => {
            return Err(LowerError::InvalidOperand {
                instruction: name.to_string(),
                operand: format!("{:?}", elems),
                reason: "disable-output-lane must have 4 elements for .cta_group::1",
            });
        }
        None => vec![Operand::ImmI64(0); 4],
    };

    let [enable_input_d, scale_rest @ ..] = rest else {
        return Err(LowerError::InvalidOperand {
            instruction: name.to_string(),
            operand: format!("{:?}", operands),
            reason: "missing enable-input-d",
        });
    };
    if !scale_rest.is_empty() {
        let operand = if weight_stationary {
            "zero-column-mask-desc"
        } else {
            "scale-input-d"
        };
        return Err(unsupported(name, format!("{operand} is not modeled")));
    }
    let enable_input_d = ctx.resolve_operand(enable_input_d)?;

    ctx.emit(
        LoweredInstr::Tcgen05Mma {
            kind,
            collector,
            scales,
            d_tmem_base,
            d_tmem_offset,
            a,
            b_desc,
            idesc,
            disable_output_lane,
            enable_input_d,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `tcgen05.fence::{before,after}_thread_sync`, a no-op under Volta's
/// sequential execution. The trie's `::`-stripping fallback maps both to one
/// `InstrKind`, so the direction arrives as a `Qualified(["", dir])` modifier.
pub(super) fn lower_tcgen05_fence(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.fence";
    let mut direction = None;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier
            && let [empty, qualifier] = parts.as_slice()
            && empty.as_slice().is_empty()
            && direction.is_none()
        {
            direction = match qualifier.as_slice().as_bytes() {
                b"before_thread_sync" => Some(Tcgen05FenceDirection::BeforeThreadSync),
                b"after_thread_sync" => Some(Tcgen05FenceDirection::AfterThreadSync),
                _ => None,
            };
            if direction.is_some() {
                continue;
            }
        }
        return Err(unsupported(NAME, format!("modifier {}", modifier)));
    }
    let Some(direction) = direction else {
        return Err(unsupported(
            NAME,
            "missing ::before_thread_sync/::after_thread_sync qualifier",
        ));
    };
    if !operands.is_empty() {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected no operands",
        });
    }

    ctx.emit(LoweredInstr::Tcgen05Fence { direction }, predicate)?;
    Ok(())
}

/// Lower `tcgen05.commit...mbarrier::arrive::one.b64 [mbar]` (PTX ISA
/// 9.7.17.11) to a plain `MbarrierArrive` with count 1: evaluation is eager, so
/// no `tcgen05.mma` is in flight. `ctaMask`/`cta_group::2` are rejected.
pub(super) fn lower_tcgen05_commit(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tcgen05.commit";
    let mut saw_cta_group = false;
    let mut saw_mbarrier_arrive_one = false;

    for modifier in modifiers {
        if let Some(result) = parse_tcgen05_cta_group(modifier, NAME) {
            result?;
            saw_cta_group = true;
            continue;
        }
        if let DottedIdent::Qualified(parts) = modifier
            && let [mbarrier, arrive, one] = parts.as_slice()
            && mbarrier.as_slice().as_bytes() == b"mbarrier"
            && arrive.as_slice().as_bytes() == b"arrive"
            && one.as_slice().as_bytes() == b"one"
        {
            saw_mbarrier_arrive_one = true;
            continue;
        }
        // As for `tcgen05.alloc`'s `dst`: an explicit `.shared::cta`/
        // `.shared::cluster` space or none resolves the same `[mbar]` address
        // (Volta models one CTA), so it is consumed, not stored.
        if let DottedIdent::Qualified(parts) = modifier
            && let [base, sub] = parts.as_slice()
            && base.as_slice().as_bytes() == b"shared"
        {
            match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                Some(_) => continue,
                None => return Err(unsupported(NAME, format!("modifier .shared::{sub}"))),
            }
        }
        match modifier.to_string().as_str() {
            "b64" => {}
            other => return Err(unsupported(NAME, format!("modifier .{}", other))),
        }
    }
    if !saw_cta_group {
        return Err(unsupported(NAME, "missing .cta_group::1 modifier"));
    }
    if !saw_mbarrier_arrive_one {
        return Err(unsupported(NAME, "missing .mbarrier::arrive::one modifier"));
    }

    let [addr] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [mbar] (ctaMask multicast is not modeled)",
        });
    };
    let (addr_base, addr_offset) = match addr {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };

    ctx.emit(
        LoweredInstr::Tcgen05Commit {
            addr_base,
            addr_offset,
        },
        predicate,
    )?;
    Ok(())
}
