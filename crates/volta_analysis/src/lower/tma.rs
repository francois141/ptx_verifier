//! Lowering of tensor-map objects (`tensormap.replace`,
//! `tensormap.cp_fenceproxy`, `fence.proxy.tensormap`) and of the bulk copies
//! (`cp.async.bulk{.tensor}`).

use volta_frontend::ascii::AsciiSliceExt;
use volta_frontend::ast::{
    FromAscii, Operand as AstOperand, ScalarType, SharedStateSpaceQualifier,
};
use volta_frontend::lex::DottedIdent;

use crate::ir::tensor_map::{
    TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorSwizzleAtomicity,
    TensorSwizzleMode, TensormapFieldWrite,
};
use crate::ir::{LoweredInstr, MemSpace, Predicate, TensormapFence};

use super::context::{LoweringContext, resolve_addr_operand, unsupported};
use super::error::{LowerError, LowerResult};

/// Extract a required, non-negative immediate (the tensormap family's
/// `ord`/`.field3` `new_val`/`fence.proxy.tensormap::generic`'s `size` -
/// the ISA requires each of these to be a literal, not a register).
fn require_immediate_u32(op: &AstOperand, instruction: &str, what: &str) -> LowerResult<u32> {
    let invalid = |reason| LowerError::InvalidOperand {
        instruction: instruction.to_string(),
        operand: format!("{:?}", op),
        reason,
    };
    match op {
        AstOperand::ImmInt(v) => u32::try_from(*v).map_err(|_| invalid("value out of range")),
        AstOperand::ImmUInt(v) => u32::try_from(*v).map_err(|_| invalid("value out of range")),
        _ => Err(unsupported(
            instruction,
            format!("{what} must be an immediate"),
        )),
    }
}

/// Lower `tensormap.replace.tile.field{.ss}.b1024.type [addr], {ord,} new_val`
/// (PTX ISA 9.7.9.27); requires an explicit `.global`/`.shared::cta` space.
/// `.field3`'s literal `new_val` is checked against Table 33 here, loudly.
pub(super) fn lower_tensormap_replace(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tensormap.replace";
    let mut saw_tile = false;
    let mut field_name: Option<String> = None;
    let mut space: Option<MemSpace> = None;
    let mut saw_b1024 = false;
    let mut ty: Option<ScalarType> = None;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier
            && let [base, sub] = parts.as_slice()
            && base.as_slice().as_bytes() == b"shared"
        {
            match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                Some(SharedStateSpaceQualifier::Cta) => {
                    space = Some(MemSpace::Shared);
                    continue;
                }
                _ => return Err(unsupported(NAME, format!("modifier .shared::{sub}"))),
            }
        }
        match modifier.to_string().as_str() {
            "tile" => saw_tile = true,
            "global" => space = Some(MemSpace::Global),
            "b1024" => saw_b1024 = true,
            "b32" => ty = Some(ScalarType::B32),
            "b64" => ty = Some(ScalarType::B64),
            "global_address" | "rank" | "box_dim" | "global_dim" | "global_stride"
            | "element_stride" | "elemtype" | "interleave_layout" | "swizzle_mode"
            | "swizzle_atomicity" | "fill_mode" => field_name = Some(modifier.to_string()),
            other => return Err(unsupported(NAME, format!("modifier .{other}"))),
        }
    }

    if !saw_tile {
        return Err(unsupported(NAME, "missing .tile mode"));
    }
    let field_name = field_name.ok_or_else(|| unsupported(NAME, "missing field qualifier"))?;
    let space = space.ok_or_else(|| {
        unsupported(
            NAME,
            "missing explicit .global/.shared::cta state space (generic addressing not modeled)",
        )
    })?;
    if !saw_b1024 {
        return Err(unsupported(NAME, "missing .b1024"));
    }
    let ty = ty.ok_or_else(|| unsupported(NAME, "missing .b32/.b64 type"))?;

    let addr = operands
        .first()
        .ok_or_else(|| unsupported(NAME, "missing address operand"))?;
    let (addr_base, addr_offset) = resolve_addr_operand(ctx, addr)?;

    let require_ty = |expected: ScalarType| -> LowerResult<()> {
        if ty == expected {
            Ok(())
        } else {
            Err(unsupported(
                NAME,
                format!(".{field_name} requires .{expected:?} (found .{ty:?})"),
            ))
        }
    };

    let field = match field_name.as_str() {
        "global_address" => {
            require_ty(ScalarType::B64)?;
            let [_, new_val] = operands else {
                return Err(LowerError::InvalidOperand {
                    instruction: NAME.to_string(),
                    operand: format!("{:?}", operands),
                    reason: "expected [addr], new_val",
                });
            };
            TensormapFieldWrite::GlobalAddress(ctx.resolve_operand(new_val)?)
        }
        "rank" => {
            require_ty(ScalarType::B32)?;
            let [_, new_val] = operands else {
                return Err(LowerError::InvalidOperand {
                    instruction: NAME.to_string(),
                    operand: format!("{:?}", operands),
                    reason: "expected [addr], new_val",
                });
            };
            TensormapFieldWrite::Rank(ctx.resolve_operand(new_val)?)
        }
        "box_dim" | "global_dim" | "global_stride" | "element_stride" => {
            require_ty(if field_name == "global_stride" {
                ScalarType::B64
            } else {
                ScalarType::B32
            })?;
            let [_, ord_op, new_val] = operands else {
                return Err(LowerError::InvalidOperand {
                    instruction: NAME.to_string(),
                    operand: format!("{:?}", operands),
                    reason: "expected [addr], ord, new_val",
                });
            };
            let ord = require_immediate_u32(ord_op, NAME, "ord")?;
            let new_val = ctx.resolve_operand(new_val)?;
            match field_name.as_str() {
                "box_dim" => TensormapFieldWrite::BoxDim { ord, new_val },
                "global_dim" => TensormapFieldWrite::GlobalDim { ord, new_val },
                "global_stride" => TensormapFieldWrite::GlobalStride { ord, new_val },
                "element_stride" => TensormapFieldWrite::ElementStride { ord, new_val },
                _ => unreachable!(),
            }
        }
        "elemtype" | "interleave_layout" | "swizzle_mode" | "swizzle_atomicity" | "fill_mode" => {
            require_ty(ScalarType::B32)?;
            let [_, new_val] = operands else {
                return Err(LowerError::InvalidOperand {
                    instruction: NAME.to_string(),
                    operand: format!("{:?}", operands),
                    reason: "expected [addr], new_val",
                });
            };
            let code = require_immediate_u32(new_val, NAME, field_name.as_str())?;
            match field_name.as_str() {
                "elemtype" => {
                    TensormapFieldWrite::Elemtype(TensorElemType::decode(code).map_err(|c| {
                        unsupported(
                            NAME,
                            format!(
                                "elemtype value {c} (sub-byte pack types .b4x16/.b4x16_p64/\
                                 .b6x16_p32/.b6p2x16 are not modeled)"
                            ),
                        )
                    })?)
                }
                "interleave_layout" => TensormapFieldWrite::InterleaveLayout(
                    TensorInterleaveLayout::decode(code)
                        .map_err(|c| unsupported(NAME, format!("interleave_layout value {c}")))?,
                ),
                "swizzle_mode" => TensormapFieldWrite::SwizzleMode(
                    TensorSwizzleMode::decode(code)
                        .map_err(|c| unsupported(NAME, format!("swizzle_mode value {c}")))?,
                ),
                "swizzle_atomicity" => TensormapFieldWrite::SwizzleAtomicity(
                    TensorSwizzleAtomicity::decode(code)
                        .map_err(|c| unsupported(NAME, format!("swizzle_atomicity value {c}")))?,
                ),
                "fill_mode" => TensormapFieldWrite::FillMode(
                    TensorFillMode::decode(code)
                        .map_err(|c| unsupported(NAME, format!("fill_mode value {c}")))?,
                ),
                _ => unreachable!(),
            }
        }
        other => return Err(unsupported(NAME, format!(".{other} field"))),
    };

    ctx.emit(
        LoweredInstr::TensormapReplace {
            space,
            addr_base,
            addr_offset,
            field,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `tensormap.cp_fenceproxy.global.shared::cta.tensormap::generic
/// .release.scope.sync.aligned [dst], [src], 128` (PTX ISA 9.7.14.17). The
/// fixed qualifiers are validated, not stored; `.scope` has no data effect.
pub(super) fn lower_tensormap_cp_fenceproxy(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "tensormap.cp_fenceproxy";
    let mut saw_global = false;
    let mut saw_shared_cta = false;
    let mut saw_tensormap_generic = false;
    let mut saw_release = false;
    let mut saw_scope = false;
    let mut saw_sync = false;
    let mut saw_aligned = false;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier {
            match parts.as_slice() {
                [base, sub] if base.as_slice().as_bytes() == b"shared" => {
                    match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                        Some(SharedStateSpaceQualifier::Cta) => {
                            saw_shared_cta = true;
                            continue;
                        }
                        _ => {
                            return Err(unsupported(
                                NAME,
                                format!(
                                    "modifier .shared::{sub} (the ISA fixes .cp_qualifiers to \
                                     .global.shared::cta)"
                                ),
                            ));
                        }
                    }
                }
                [a, b]
                    if a.as_slice().as_bytes() == b"tensormap"
                        && b.as_slice().as_bytes() == b"generic" =>
                {
                    saw_tensormap_generic = true;
                    continue;
                }
                _ => return Err(unsupported(NAME, format!("modifier {modifier}"))),
            }
        }
        match modifier.to_string().as_str() {
            "global" => saw_global = true,
            "release" => saw_release = true,
            "cta" | "cluster" | "gpu" | "sys" => saw_scope = true,
            "sync" => saw_sync = true,
            "aligned" => saw_aligned = true,
            other => return Err(unsupported(NAME, format!("modifier .{other}"))),
        }
    }

    if !(saw_global && saw_shared_cta) {
        return Err(unsupported(NAME, "missing .global.shared::cta"));
    }
    if !saw_tensormap_generic {
        return Err(unsupported(NAME, "missing .tensormap::generic"));
    }
    if !saw_release {
        return Err(unsupported(NAME, "missing .release"));
    }
    if !saw_scope {
        return Err(unsupported(NAME, "missing .scope"));
    }
    if !(saw_sync && saw_aligned) {
        return Err(unsupported(NAME, "missing .sync.aligned"));
    }

    let [dst, src, size] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [dst], [src], 128",
        });
    };
    let size_val = require_immediate_u32(size, NAME, "size")?;
    if size_val != 128 {
        return Err(unsupported(
            NAME,
            format!("size {size_val} (only 128 is valid)"),
        ));
    }
    let (dst_base, dst_offset) = resolve_addr_operand(ctx, dst)?;
    let (src_base, src_offset) = resolve_addr_operand(ctx, src)?;

    ctx.emit(
        LoweredInstr::TensormapCpFenceproxy {
            dst_base,
            dst_offset,
            src_base,
            src_offset,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `fence.proxy.tensormap::generic{.release.scope | .acquire.scope
/// [addr], 128}` (PTX ISA 9.7.14.4): an ordering fence with no data effect.
pub(super) fn lower_fence_proxy_tensormap(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "fence.proxy.tensormap::generic";
    let mut is_acquire: Option<bool> = None;
    let mut saw_scope = false;

    for modifier in modifiers {
        match modifier.to_string().as_str() {
            "acquire" => is_acquire = Some(true),
            "release" => is_acquire = Some(false),
            "cta" | "cluster" | "gpu" | "sys" => saw_scope = true,
            other => return Err(unsupported(NAME, format!("modifier .{other}"))),
        }
    }
    let is_acquire = is_acquire.ok_or_else(|| unsupported(NAME, "missing .acquire/.release"))?;
    if !saw_scope {
        return Err(unsupported(NAME, "missing .scope"));
    }

    let fence = if is_acquire {
        let [addr, size] = operands else {
            return Err(LowerError::InvalidOperand {
                instruction: NAME.to_string(),
                operand: format!("{:?}", operands),
                reason: "expected [addr], 128",
            });
        };
        let size_val = require_immediate_u32(size, NAME, "size")?;
        if size_val != 128 {
            return Err(unsupported(
                NAME,
                format!("size {size_val} (only 128 is valid)"),
            ));
        }
        let (addr_base, addr_offset) = resolve_addr_operand(ctx, addr)?;
        TensormapFence::Acquire {
            addr_base,
            addr_offset,
        }
    } else if operands.is_empty() {
        TensormapFence::Release
    } else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected no operands",
        });
    };

    ctx.emit(LoweredInstr::FenceProxyTensormap { fence }, predicate)?;
    Ok(())
}

/// Lower `.2d`/`.3d` `.tile` global-to-shared `cp.async.bulk.tensor` with
/// mbarrier completion (PTX ISA 9.7.9.26.5.2); both destinations hit the one
/// modeled CTA's shared memory. Every other form is rejected loudly.
pub(super) fn lower_cp_async_bulk_tensor(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "cp.async.bulk.tensor";
    let mut dim: Option<usize> = None;
    let mut saw_shared_destination = false;
    let mut saw_global = false;
    let mut saw_completion = false;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier {
            match parts.as_slice() {
                [base, sub] if base.as_slice().as_bytes() == b"shared" => {
                    match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                        Some(SharedStateSpaceQualifier::Cluster) => {
                            saw_shared_destination = true;
                            continue;
                        }
                        Some(SharedStateSpaceQualifier::Cta) => {
                            saw_shared_destination = true;
                            continue;
                        }
                        None => return Err(unsupported(NAME, format!("modifier .shared::{sub}"))),
                    }
                }
                [a, b, c]
                    if a.as_slice().as_bytes() == b"mbarrier"
                        && b.as_slice().as_bytes() == b"complete_tx"
                        && c.as_slice().as_bytes() == b"bytes" =>
                {
                    saw_completion = true;
                    continue;
                }
                _ => {
                    return Err(unsupported(
                        NAME,
                        format!(
                            "modifier {modifier} (only .mbarrier::complete_tx::bytes completion \
                             is modeled - .bulk_group, .multicast::cluster, .cta_group::N, \
                             .L2::cache_hint, .tile::gather4/scatter4, .im2col* are not)"
                        ),
                    ));
                }
            }
        }
        match modifier.to_string().as_str() {
            "2d" => dim = Some(2),
            "3d" => dim = Some(3),
            "global" => saw_global = true,
            // `.tile` is both the only modeled load mode and the ISA's own
            // default, so it is validated (nothing else is accepted) but
            // has nothing further to record.
            "tile" => {}
            other => return Err(unsupported(NAME, format!("modifier .{other}"))),
        }
    }

    let dim = dim.ok_or_else(|| unsupported(NAME, "missing .dim (only .2d/.3d modeled)"))?;
    if !saw_shared_destination {
        return Err(unsupported(
            NAME,
            "missing .shared::{cta,cluster} destination (store direction .global.shared::cta not modeled)",
        ));
    }
    if !saw_global {
        return Err(unsupported(NAME, "missing .global source"));
    }
    if !saw_completion {
        return Err(unsupported(
            NAME,
            "missing .mbarrier::complete_tx::bytes completion mechanism",
        ));
    }

    let [dst, tm, mbar] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [dstMem], [tensorMap, {coords}], [mbar]",
        });
    };
    let (dst_base, dst_offset) = resolve_addr_operand(ctx, dst)?;

    let AstOperand::TensorCoordAddress { descriptor, coords } = tm else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", tm),
            reason: "expected [tensorMap, {coords...}]",
        });
    };
    if coords.len() != dim {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", coords),
            reason: "tensorCoords length does not match .dim",
        });
    }
    let tensormap_base = ctx.resolve_address(descriptor)?;
    let tensormap_offset = ctx.get_address_offset(descriptor);
    let mut lowered_coords = Vec::with_capacity(coords.len());
    for c in coords {
        lowered_coords.push(ctx.resolve_operand(c)?);
    }

    let (mbar_base, mbar_offset) = resolve_addr_operand(ctx, mbar)?;

    ctx.emit(
        LoweredInstr::CpAsyncBulkTensorLoad {
            dst_base,
            dst_offset,
            // Generic addressing of `tensorMap` is not modeled: every corpus
            // use goes through `tensormap.cp_fenceproxy`, which always puts
            // the object in `.global` (`.param`/`.const` maps are unmodeled).
            tensormap_space: MemSpace::Global,
            tensormap_base,
            tensormap_offset,
            coords: lowered_coords,
            mbar_base,
            mbar_offset,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower global -> shared `cp.async.bulk...mbarrier::complete_tx::bytes`
/// (PTX ISA 9.7.9.25.4.1); both destination spellings hit the one modeled
/// CTA's shared memory. Other directions and qualifiers are rejected loudly.
pub(super) fn lower_cp_async_bulk(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "cp.async.bulk";
    let mut saw_shared = false;
    let mut saw_global = false;
    let mut saw_completion = false;

    for modifier in modifiers {
        match modifier {
            DottedIdent::Qualified(parts) => match parts.as_slice() {
                [base, sub]
                    if !saw_shared
                        && base.as_slice().as_bytes() == b"shared"
                        && SharedStateSpaceQualifier::from_ascii(sub.as_slice()).is_some() =>
                {
                    saw_shared = true;
                }
                [a, b, c]
                    if a.as_slice().as_bytes() == b"mbarrier"
                        && b.as_slice().as_bytes() == b"complete_tx"
                        && c.as_slice().as_bytes() == b"bytes" =>
                {
                    saw_completion = true;
                }
                _ => {
                    return Err(unsupported(
                        NAME,
                        format!(
                            "modifier {modifier} (only the global -> shared load with \
                             .mbarrier::complete_tx::bytes completion is modeled)"
                        ),
                    ));
                }
            },
            _ if modifier.to_string() == "global" && saw_shared => saw_global = true,
            _ => {
                return Err(unsupported(
                    NAME,
                    format!("modifier .{modifier} (only .shared::{{cta,cluster}}.global modeled)"),
                ));
            }
        }
    }

    if !(saw_shared && saw_global && saw_completion) {
        return Err(unsupported(
            NAME,
            "only .shared::{cta,cluster}.global.mbarrier::complete_tx::bytes is modeled",
        ));
    }

    let [dst, src, size, mbar] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [dstMem], [srcMem], size, [mbar]",
        });
    };
    let (dst_base, dst_offset) = resolve_addr_operand(ctx, dst)?;
    let (src_base, src_offset) = resolve_addr_operand(ctx, src)?;
    let size = ctx.resolve_operand(size)?;
    let (mbar_base, mbar_offset) = resolve_addr_operand(ctx, mbar)?;

    ctx.emit(
        LoweredInstr::CpAsyncBulkLoad {
            dst_base,
            dst_offset,
            src_base,
            src_offset,
            size,
            mbar_base,
            mbar_offset,
        },
        predicate,
    )?;
    Ok(())
}
