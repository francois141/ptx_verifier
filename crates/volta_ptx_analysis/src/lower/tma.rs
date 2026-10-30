//! Lowering of tensor-map objects (`tensormap.replace`,
//! `tensormap.cp_fenceproxy`, `fence.proxy.tensormap`) and of the bulk copies
//! (`cp.async.bulk{.tensor}`).

use crate::frontend::ascii::AsciiSliceExt;
use crate::frontend::ast::{
    FromAscii, Operand as AstOperand, ScalarType, SharedStateSpaceQualifier,
};
use crate::frontend::lex::DottedIdent;

use crate::ir::tensor_map::{
    TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorLoadMode, TensorSwizzleAtomicity,
    TensorSwizzleMode, TensormapFieldWrite,
};
use crate::ir::{BulkWaitScope, LoweredInstr, MemSpace, Operand, Predicate, TensormapFence};

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

/// Lower `prefetch{.const,.param}.tensormap [a]` to a no-op: it only brings
/// the map into the cache, so it reads nothing the analysis models and orders
/// nothing. Other `prefetch` forms stay unsupported.
pub(super) fn lower_prefetch_tensormap(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "prefetch";
    let mut saw_tensormap = false;

    for modifier in modifiers {
        match modifier.to_string().as_str() {
            "tensormap" => saw_tensormap = true,
            "const" | "param" => {}
            other => return Err(unsupported(NAME, format!("modifier .{other}"))),
        }
    }
    if !saw_tensormap {
        return Err(unsupported(NAME, "only prefetch.tensormap is implemented"));
    }

    let [addr] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [a]",
        });
    };
    resolve_addr_operand(ctx, addr)?;

    ctx.emit(LoweredInstr::Nop, predicate)
}

/// The tensor rank a `cp.async.bulk.tensor` `.dim` modifier names: every
/// rank the ISA has, `.1d` to `.5d`, for loads and stores alike.
fn tensor_rank(modifier: &str) -> Option<usize> {
    match modifier {
        "1d" => Some(1),
        "2d" => Some(2),
        "3d" => Some(3),
        "4d" => Some(4),
        "5d" => Some(5),
        _ => None,
    }
}

/// The rank range of an `.im2col` copy: an N, a C and one to three spatial
/// dimensions (PTX ISA 5.5.4).
const IM2COL_RANKS: std::ops::RangeInclusive<usize> = 3..=5;

/// The `.load_mode` a TMA load spells.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum LoadModeQualifier {
    Tile,
    Im2col,
}

/// Lower `.1d` to `.5d` `.tile` and `.3d` to `.5d` `.im2col` global-to-shared
/// `cp.async.bulk.tensor` with mbarrier completion (PTX ISA 9.7.9.26.5.2); both
/// destinations hit the one modeled CTA's shared memory. Every other form is rejected loudly.
pub(super) fn lower_cp_async_bulk_tensor(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "cp.async.bulk.tensor";
    if modifiers.iter().any(|m| m.to_string() == "bulk_group") {
        return lower_cp_async_bulk_tensor_store(ctx, modifiers, operands, predicate);
    }

    let mut dim: Option<usize> = None;
    let mut load_mode: Option<LoadModeQualifier> = None;
    let mut saw_shared_destination = false;
    let mut saw_global = false;
    let mut saw_completion = false;
    let mut cache_hint = CacheHint::Absent;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier {
            match parts.as_slice() {
                [level, hint]
                    if level.as_slice().as_bytes() == b"L2"
                        && hint.as_slice().as_bytes() == b"cache_hint" =>
                {
                    cache_hint = CacheHint::Present;
                    continue;
                }
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
                             .tile::gather4/scatter4, .im2col::w{{::128}} are not)"
                        ),
                    ));
                }
            }
        }
        match modifier.to_string().as_str() {
            "global" => saw_global = true,
            "tile" | "im2col" if load_mode.is_some() => {
                return Err(unsupported(NAME, "more than one .load_mode"));
            }
            "tile" => load_mode = Some(LoadModeQualifier::Tile),
            "im2col" => load_mode = Some(LoadModeQualifier::Im2col),
            other => match tensor_rank(other) {
                Some(rank) => dim = Some(rank),
                None => return Err(unsupported(NAME, format!("modifier .{other}"))),
            },
        }
    }

    let dim = dim.ok_or_else(|| unsupported(NAME, "missing .dim (.1d to .5d are modeled)"))?;
    let load_mode = load_mode.unwrap_or(LoadModeQualifier::Tile);
    if load_mode == LoadModeQualifier::Im2col && !IM2COL_RANKS.contains(&dim) {
        return Err(unsupported(
            NAME,
            format!(".im2col of a .{dim}d tensor (the im2col mode needs .3d to .5d)"),
        ));
    }
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

    let operands = strip_cache_policy(ctx, operands, cache_hint)?;
    let (dst, tm, mbar, offsets) = match (load_mode, operands) {
        (LoadModeQualifier::Tile, [dst, tm, mbar]) => (dst, tm, mbar, None),
        (LoadModeQualifier::Im2col, [dst, tm, mbar, offsets]) => (dst, tm, mbar, Some(offsets)),
        _ => {
            let reason = match load_mode {
                LoadModeQualifier::Tile => "expected [dstMem], [tensorMap, {coords}], [mbar]",
                LoadModeQualifier::Im2col => {
                    "expected [dstMem], [tensorMap, {coords}], [mbar], {im2colOffsets}"
                }
            };
            return Err(LowerError::InvalidOperand {
                instruction: NAME.to_string(),
                operand: format!("{:?}", operands),
                reason,
            });
        }
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

    let mode = match offsets {
        None => TensorLoadMode::Tile,
        Some(offsets) => TensorLoadMode::Im2col {
            offsets: lower_im2col_offsets(ctx, offsets, dim)?,
        },
    };

    let (mbar_base, mbar_offset) = resolve_addr_operand(ctx, mbar)?;

    ctx.emit(
        LoweredInstr::CpAsyncBulkTensorLoad {
            dst_base,
            dst_offset,
            tensormap_base,
            tensormap_offset,
            coords: lowered_coords,
            mode,
            mbar_base,
            mbar_offset,
        },
        predicate,
    )?;
    Ok(())
}

/// Whether a TMA load carries `.L2::cache_hint` and so a trailing cache-policy operand.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum CacheHint {
    Absent,
    Present,
}

/// The operands without `.L2::cache_hint`'s trailing 64-bit cache policy: it only
/// sets the L2 eviction priority, so it changes neither the data nor any order.
fn strip_cache_policy<'a>(
    ctx: &LoweringContext,
    operands: &'a [AstOperand],
    cache_hint: CacheHint,
) -> LowerResult<&'a [AstOperand]> {
    const NAME: &str = "cp.async.bulk.tensor";

    if cache_hint == CacheHint::Absent {
        return Ok(operands);
    }
    let Some((policy, rest)) = operands.split_last() else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: ".L2::cache_hint needs a trailing cache-policy operand",
        });
    };
    let typed = ctx.resolve_operand_typed(policy)?;
    ctx.check_operand_type(&typed, ScalarType::B64, NAME)?;

    Ok(rest)
}

/// An `.im2col` load's `{im2colOffsets}`: one 16-bit offset per spatial dimension, `dim - 2`.
fn lower_im2col_offsets(
    ctx: &LoweringContext,
    operand: &AstOperand,
    dim: usize,
) -> LowerResult<Vec<Operand>> {
    const NAME: &str = "cp.async.bulk.tensor";

    let AstOperand::Vector(offsets) = operand else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operand),
            reason: "expected {im2colOffsets}",
        });
    };
    if offsets.len() != dim - 2 {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", offsets),
            reason: "im2colOffsets needs one offset per spatial dimension (.dim - 2)",
        });
    }

    let mut lowered = Vec::with_capacity(offsets.len());
    for offset in offsets {
        let typed = ctx.resolve_operand_typed(offset)?;
        ctx.check_operand_type(&typed, ScalarType::B16, NAME)?;
        lowered.push(typed.operand);
    }

    Ok(lowered)
}

/// Lower `cp.async.bulk.tensor.Nd.global.shared::cta{.tile}.bulk_group
/// [tensorMap, {coords}], [srcMem]`, the TMA store (PTX ISA 9.7.9.26.5.2).
fn lower_cp_async_bulk_tensor_store(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "cp.async.bulk.tensor";

    let given: Vec<String> = modifiers.iter().map(|m| m.to_string()).collect();

    // `.tile` is the ISA's default load mode, so it may be omitted.
    let form = match given.as_slice() {
        [dim, global, shared, tile, group] if tile == "tile" => Some((dim, global, shared, group)),
        [dim, global, shared, group] => Some((dim, global, shared, group)),
        _ => None,
    };

    let dim = match form {
        Some((dim, global, shared, group))
            if global == "global" && shared == "shared::cta" && group == "bulk_group" =>
        {
            tensor_rank(dim).ok_or_else(|| unsupported(NAME, format!("modifier .{dim}")))?
        }
        _ => {
            return Err(unsupported(
                NAME,
                format!(
                    "store form .{} (only .Nd.global.shared::cta{{.tile}}.bulk_group is modeled)",
                    given.join(".")
                ),
            ));
        }
    };

    let [tm, src] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [tensorMap, {coords...}], [srcMem]",
        });
    };

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
    let coords = coords
        .iter()
        .map(|c| ctx.resolve_operand(c))
        .collect::<LowerResult<Vec<_>>>()?;
    let (src_base, src_offset) = resolve_addr_operand(ctx, src)?;

    ctx.emit(
        LoweredInstr::CpAsyncBulkTensorStore {
            tensormap_base,
            tensormap_offset,
            coords,
            src_base,
            src_offset,
        },
        predicate,
    )
}

/// Lower `cp.async.bulk.commit_group` and `cp.async.bulk.wait_group{.read} n`.
fn lower_bulk_group(
    ctx: &mut LoweringContext,
    given: &[String],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let instr = match (given, operands) {
        ([commit], []) if commit == "commit_group" => LoweredInstr::CpAsyncBulkCommitGroup,
        ([wait, rest @ ..], [n]) if wait == "wait_group" => {
            let scope = match rest {
                [] => BulkWaitScope::Complete,
                [read] if read == "read" => BulkWaitScope::SourceReads,
                _ => {
                    return Err(unsupported(
                        "cp.async.bulk.wait_group",
                        format!("modifier .{}", rest.join(".")),
                    ));
                }
            };

            let n = ctx.resolve_const_u32(
                n,
                "cp.async.bulk.wait_group",
                "n must be a compile-time integer immediate",
            )?;

            LoweredInstr::CpAsyncBulkWaitGroup { n, scope }
        }
        _ => {
            return Err(LowerError::InvalidOperand {
                instruction: format!("cp.async.bulk.{}", given.join(".")),
                operand: format!("{:?}", operands),
                reason: "expected commit_group with no operand or wait_group{.read} n",
            });
        }
    };

    ctx.emit(instr, predicate)
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
    let given: Vec<String> = modifiers.iter().map(|m| m.to_string()).collect();
    if matches!(
        given.first().map(String::as_str),
        Some("commit_group" | "wait_group")
    ) {
        return lower_bulk_group(ctx, &given, operands, predicate);
    }

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
