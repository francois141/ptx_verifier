//! Lowering of warp-level instructions: `shfl.sync`, `elect.sync`,
//! `redux.sync`, `bar.warp.sync`, `ldmatrix`/`stmatrix`, `mma.sync` and
//! `wmma`.

use volta_frontend::ascii::AsciiSliceExt;
use volta_frontend::ast::{
    BarWarpSyncInstr, ElectSyncInstr, FromAscii, Operand as AstOperand, RedOp, ReduxSyncInstr,
    ScalarType, SharedStateSpaceQualifier, ShflSyncInstr,
};
use volta_frontend::lex::DottedIdent;

use crate::ir::mma::{MmaLayout, MmaOperand, MmaShape};
use crate::ir::{BinOp, LoweredInstr, MemSpace, Predicate};

use super::context::{LoweringContext, parse_scalar_type_modifier, unsupported};
use super::error::{LowerError, LowerResult};

pub(super) fn lower_shfl_sync(
    ctx: &mut LoweringContext,
    shfl: &ShflSyncInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // The destination may be written `d|p` where `p` receives the validity
    // predicate; the parser surfaces that as a PredicatePair operand.
    let (dst, pair_pred) = match &shfl.dst {
        AstOperand::PredicatePair(d, p) => (
            ctx.resolve_register(&d.to_string())?,
            Some(ctx.resolve_register(&p.to_string())?),
        ),
        other => (ctx.resolve_dst(other)?, None),
    };
    let dst_pred = match (&shfl.dst_pred, pair_pred) {
        (Some(op), None) => Some(ctx.resolve_dst(op)?),
        (None, p) => p,
        (Some(_), Some(_)) => {
            return Err(LowerError::UnsupportedInstruction {
                instruction: "shfl.sync".to_string(),
                reason: Some("conflicting predicate destinations".to_string()),
            });
        }
    };
    let src = ctx.resolve_operand(&shfl.src)?;
    let offset_or_lane = ctx.resolve_operand(&shfl.src_b)?;
    let clamp = ctx.resolve_operand(&shfl.src_c)?;
    let membermask = ctx.resolve_operand(&shfl.membermask)?;

    ctx.emit(
        LoweredInstr::ShflSync {
            mode: ctx.convert_shfl_mode(shfl.mode),
            dst,
            dst_pred,
            src,
            offset_or_lane,
            clamp,
            membermask,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `elect.sync d|p, membermask`. `dst_pred` is always a real
/// register - the ISA's `d|p` pair is mandatory, so the parser already
/// rejected anything else - but `dst` may be sink.
pub(super) fn lower_elect_sync(
    ctx: &mut LoweringContext,
    elect: &ElectSyncInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let dst = match &elect.dst {
        AstOperand::Underscore => None,
        other => Some(ctx.resolve_dst(other)?),
    };
    let dst_pred = ctx.resolve_dst(&elect.dst_pred)?;
    let membermask = ctx.resolve_operand(&elect.membermask)?;
    ctx.emit(
        LoweredInstr::ElectSync {
            dst,
            dst_pred,
            membermask,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `redux.sync.op.type d, a, membermask` (PTX ISA Block 143). `inc`/`dec`
/// (from the shared `RedOp`) are invalid here and rejected; `.NaN` is accepted
/// as in `reject_minmax_modifiers`, `.abs` is unmodeled and rejected.
pub(super) fn lower_redux_sync(
    ctx: &mut LoweringContext,
    redux: &ReduxSyncInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "redux.sync";
    let invalid = |reason: String| LowerError::InvalidInstruction {
        instruction: NAME.to_string(),
        reason,
    };
    // The three forms (PTX ISA 9.7.15.13): `.add`/`.min`/`.max` on
    // `.u32`/`.s32`, `.and`/`.or`/`.xor` on `.b32`, and `.min`/`.max` on
    // `.f32`, the only type `.abs`/`.NaN` apply to.
    let op = match (redux.op, redux.ty) {
        (RedOp::Add, ScalarType::U32 | ScalarType::S32) => BinOp::Add,
        (RedOp::Min, ScalarType::U32 | ScalarType::S32 | ScalarType::F32) => BinOp::Min,
        (RedOp::Max, ScalarType::U32 | ScalarType::S32 | ScalarType::F32) => BinOp::Max,
        (RedOp::And, ScalarType::B32) => BinOp::And,
        (RedOp::Or, ScalarType::B32) => BinOp::Or,
        (RedOp::Xor, ScalarType::B32) => BinOp::Xor,
        (op, ty) => {
            return Err(invalid(format!(
                "{op:?} on {ty:?} is not a redux.sync form (.add/.min/.max on .u32/.s32, \
                 .and/.or/.xor on .b32, .min/.max on .f32)"
            )));
        }
    };
    if (redux.abs || redux.nan) && redux.ty != ScalarType::F32 {
        return Err(invalid(format!(
            ".abs/.NaN only apply to redux.sync.f32, not {:?}",
            redux.ty
        )));
    }
    if redux.abs {
        return Err(unsupported(NAME, ".abs modifier"));
    }
    if redux.nan {
        return Err(unsupported(NAME, ".NaN (NaN propagation is not modeled)"));
    }

    let dst_typed = ctx.resolve_dst_typed(&redux.dst)?;
    let src_typed = ctx.resolve_operand_typed(&redux.src)?;
    ctx.check_dst_type(&dst_typed, redux.ty, "redux.sync")?;
    ctx.check_operand_type(&src_typed, redux.ty, "redux.sync")?;
    let membermask = ctx.resolve_operand(&redux.membermask)?;

    ctx.emit(
        LoweredInstr::ReduxSync {
            op,
            ty: redux.ty,
            dst: dst_typed.reg,
            src: src_typed.operand,
            membermask,
        },
        predicate,
    )?;
    Ok(())
}

pub(super) fn lower_bar_warp_sync(
    ctx: &mut LoweringContext,
    bws: &BarWarpSyncInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // The membermask lowers exactly like shfl.sync's: any operand
    // form, required concrete at evaluation time.
    let mask = ctx.resolve_operand(&bws.membermask)?;
    ctx.emit(LoweredInstr::BarWarpSync { mask }, predicate)?;
    Ok(())
}

/// Lower `ldmatrix.sync.aligned[.trans].x{1,2,4}.m8n8.shared.b16`
pub(super) fn lower_ldmatrix(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let mut trans = false;
    let mut num: Option<u32> = None;

    for modifier in modifiers {
        // Handled separately so `::cluster` gets its own diagnostic instead
        // of falling into the generic "modifier .X" catch-all below.
        if let DottedIdent::Qualified(parts) = modifier
            && let [base, sub] = parts.as_slice()
            && base.as_slice().as_bytes() == b"shared"
        {
            match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                Some(SharedStateSpaceQualifier::Cta) => continue,
                Some(SharedStateSpaceQualifier::Cluster) => {
                    return Err(unsupported(
                        "ldmatrix",
                        "shared::cluster (only the executing CTA's own shared memory is modeled)",
                    ));
                }
                None => {
                    return Err(unsupported("ldmatrix", format!("modifier .shared::{sub}")));
                }
            }
        }

        let s = modifier.to_string();
        match s.as_str() {
            // The modeled form: ldmatrix.sync.aligned.x{1,2,4}[.trans].m8n8.shared.b16
            "sync" | "aligned" | "shared" | "m8n8" | "b16" => {}
            "trans" => trans = true,
            "x1" => num = Some(1),
            "x2" => num = Some(2),
            "x4" => num = Some(4),
            // Everything else (m8n16, m16n16, b8, dst/src format types,
            // ...) selects an unmodeled fragment layout.
            other => {
                return Err(unsupported("ldmatrix", format!("modifier .{}", other)));
            }
        }
    }

    let num = num.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "ldmatrix".to_string(),
        reason: Some("missing x1/x2/x4 modifier".to_string()),
    })?;

    if operands.len() < 2 {
        return Err(LowerError::InvalidOperand {
            instruction: "ldmatrix".to_string(),
            operand: format!("{:?}", operands),
            reason: "expected destination vector and address operands",
        });
    }

    let dst = ctx.resolve_dst_vector(&operands[0])?;
    // `resolve_operand` drops a `[reg+imm]` offset, so pull it out
    // separately, as `lower_cp_async` does.
    let (addr, addr_offset) = match &operands[1] {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };

    ctx.emit(
        LoweredInstr::Ldmatrix {
            dst,
            addr,
            addr_offset,
            num,
            trans,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `mma.sync.aligned.m16n8k16.row.col.f32.f16.f16.f32` and the tf32
/// (`m16n8k8`/`m16n8k4`) and fp8 (`m16n8k32.f32.e4m3.e4m3.f32`) forms.
pub(super) fn lower_mma(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let mut shape: Option<MmaShape> = None;
    let mut layouts: Vec<MmaLayout> = Vec::new();
    let mut types: Vec<ScalarType> = Vec::new();

    for modifier in modifiers {
        let s = modifier.to_string();
        if s == "sync" || s == "aligned" {
            // The modeled execution mode.
        } else if let Some(sh) = MmaShape::parse(&s) {
            shape = Some(sh);
        } else if let Some(layout) = MmaLayout::parse(&s) {
            layouts.push(layout);
        } else if let Some(ty) = parse_scalar_type_modifier(modifier) {
            types.push(ty);
        } else {
            // Everything else (.sp sparsity, .satfinite, b1 ops, ...) is an
            // unmodeled variant.
            return Err(unsupported("mma", format!("modifier .{}", s)));
        }
    }

    let shape = shape.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "mma".to_string(),
        reason: Some("missing shape modifier (e.g., m16n8k16)".to_string()),
    })?;

    if layouts.len() != 2 {
        return Err(LowerError::UnsupportedInstruction {
            instruction: "mma".to_string(),
            reason: Some(format!(
                "expected 2 layout modifiers (row/col), found {}",
                layouts.len()
            )),
        });
    }

    if types.len() != 4 {
        return Err(LowerError::UnsupportedInstruction {
            instruction: "mma".to_string(),
            reason: Some(format!(
                "expected 4 type modifiers (d_type, a_type, b_type, c_type), found {}",
                types.len()
            )),
        });
    }

    // Modeled fragments: f16 pairs (m16n8k16), tf32 (m16n8k8/k4), or packed
    // e4m3/s8 bytes (m16n8k32) into f32, s32 or packed f16; any other
    // combination would use the wrong layout.
    const MODELED_TYPES: [[ScalarType; 4]; 5] = [
        [
            ScalarType::F32,
            ScalarType::F16,
            ScalarType::F16,
            ScalarType::F32,
        ],
        // The `.f16` accumulator halves the D/C register count: two packed
        // pairs rather than four f32s, the same four matrix elements.
        [
            ScalarType::F16,
            ScalarType::F16,
            ScalarType::F16,
            ScalarType::F16,
        ],
        [
            ScalarType::F32,
            ScalarType::Tf32,
            ScalarType::Tf32,
            ScalarType::F32,
        ],
        [
            ScalarType::F32,
            ScalarType::E4m3,
            ScalarType::E4m3,
            ScalarType::F32,
        ],
        [
            ScalarType::S32,
            ScalarType::S8,
            ScalarType::S8,
            ScalarType::S32,
        ],
    ];
    if !MODELED_TYPES
        .iter()
        .any(|modeled| modeled == types.as_slice())
    {
        return Err(unsupported(
            "mma",
            format!(
                "type combination {:?} (only .f32.f16.f16.f32, .f16.f16.f16.f16, \
                 .f32.tf32.tf32.f32, .f32.e4m3.e4m3.f32 and .s32.s8.s8.s32 are \
                 modeled)",
                types
            ),
        ));
    }
    let shape_supported = match types[1] {
        ScalarType::F16 => shape == MmaShape::new(16, 8, 16),
        ScalarType::E4m3 | ScalarType::S8 => shape == MmaShape::new(16, 8, 32),
        _ => shape == MmaShape::new(16, 8, 8) || shape == MmaShape::new(16, 8, 4),
    };
    if !shape_supported {
        return Err(unsupported(
            "mma",
            format!(
                "shape {} with {:?} multiplicands (f16 needs m16n8k16; tf32 needs \
                 m16n8k8 or m16n8k4; e4m3 and s8 need m16n8k32)",
                shape, types[1]
            ),
        ));
    }

    if operands.len() < 4 {
        return Err(LowerError::InvalidOperand {
            instruction: "mma".to_string(),
            operand: format!("{:?}", operands),
            reason: "expected 4 vector operands (dst, src_a, src_b, src_c)",
        });
    }

    let dst = ctx.resolve_dst_vector(&operands[0])?;
    let src_a = ctx.resolve_dst_vector(&operands[1])?;
    let src_b = ctx.resolve_dst_vector(&operands[2])?;
    let src_c = ctx.resolve_operand_vector(&operands[3])?;

    let a_layout = layouts[0];
    let b_layout = layouts[1];
    // PTX syntax order: d_type, a_type, b_type, c_type (every modeled
    // combination has c_type == d_type)
    let d_type = types[0];
    let a_type = types[1];
    let b_type = types[2];

    ctx.emit(
        LoweredInstr::Mma {
            shape,
            dst,
            src_a,
            src_b,
            src_c,
            a_layout,
            b_layout,
            a_type,
            b_type,
            d_type,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `stmatrix.sync.aligned.x{1,2,4}[.trans].m8n8.shared.b16 [addr],
/// {src...}` (PTX ISA 9.7.14.5.17): `ldmatrix`'s store mirror, same grammar
/// and scope, with the address first and the source vector second.
pub(super) fn lower_stmatrix(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "stmatrix";
    let mut trans = false;
    let mut num: Option<u32> = None;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier
            && let [base, sub] = parts.as_slice()
            && base.as_slice().as_bytes() == b"shared"
        {
            match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                Some(SharedStateSpaceQualifier::Cta) => continue,
                Some(SharedStateSpaceQualifier::Cluster) => {
                    return Err(unsupported(
                        NAME,
                        "shared::cluster (only the executing CTA's own shared memory is modeled)",
                    ));
                }
                None => {
                    return Err(unsupported(NAME, format!("modifier .shared::{sub}")));
                }
            }
        }

        let s = modifier.to_string();
        match s.as_str() {
            "sync" | "aligned" | "shared" | "m8n8" | "b16" => {}
            "trans" => trans = true,
            "x1" => num = Some(1),
            "x2" => num = Some(2),
            "x4" => num = Some(4),
            other => {
                return Err(unsupported(NAME, format!("modifier .{}", other)));
            }
        }
    }

    let num = num.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: NAME.to_string(),
        reason: Some("missing x1/x2/x4 modifier".to_string()),
    })?;

    if operands.len() < 2 {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected address and source vector operands",
        });
    }

    let (addr, addr_offset) = match &operands[0] {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };
    let src = ctx.resolve_operand_vector(&operands[1])?;
    if src.len() != num as usize {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands[1]),
            reason: "source vector length must match x1/x2/x4",
        });
    }

    ctx.emit(
        LoweredInstr::Stmatrix {
            addr,
            addr_offset,
            src,
            num,
            trans,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `wmma.load.{a,b,c}.sync.aligned.{row,col}.m16n16k16[.shared].f16`
pub(super) fn lower_wmma_load(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let mut operand_kind: Option<MmaOperand> = None;
    let mut layout: Option<MmaLayout> = None;
    let mut shape: Option<MmaShape> = None;
    let mut elem_type: Option<ScalarType> = None;
    let mut space: Option<MemSpace> = None;

    for modifier in modifiers {
        let s = modifier.to_string();
        if s == "sync" || s == "aligned" {
            // The modeled execution mode.
        } else if s == "shared" {
            space = Some(MemSpace::Shared);
        } else if s == "global" {
            space = Some(MemSpace::Global);
        } else if let Some(op) = MmaOperand::parse(&s) {
            operand_kind = Some(op);
        } else if let Some(l) = MmaLayout::parse(&s) {
            layout = Some(l);
        } else if let Some(sh) = MmaShape::parse(&s) {
            shape = Some(sh);
        } else if let Some(ty) = parse_scalar_type_modifier(modifier) {
            elem_type = Some(ty);
        } else {
            return Err(unsupported("wmma.load", format!("modifier .{}", s)));
        }
    }

    // Memory spaces have separate address spaces here, so a generic
    // (spaceless) wmma access cannot be resolved to the right memory.
    let space = space.ok_or_else(|| {
        unsupported(
            "wmma.load",
            "no explicit state space (generic addressing is not modeled)",
        )
    })?;

    let operand_kind = operand_kind.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.load".to_string(),
        reason: Some("missing operand modifier (a, b, or c)".to_string()),
    })?;

    let layout = layout.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.load".to_string(),
        reason: Some("missing layout modifier (row or col)".to_string()),
    })?;

    let shape = shape.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.load".to_string(),
        reason: Some("missing shape modifier (e.g., m16n16k16)".to_string()),
    })?;

    let elem_type = elem_type.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.load".to_string(),
        reason: Some("missing element type modifier (e.g., f16)".to_string()),
    })?;

    // The evaluator's fragment tables are fixed: f16 multiplicands (b16 raw
    // bits allowed) and f32 accumulators. Anything else would be read with
    // the wrong per-lane layout.
    match operand_kind {
        MmaOperand::A | MmaOperand::B => {
            if !matches!(elem_type, ScalarType::F16 | ScalarType::B16) {
                return Err(unsupported(
                    "wmma.load",
                    format!(
                        "a/b fragment element type {:?} (only f16 is modeled)",
                        elem_type
                    ),
                ));
            }
        }
        MmaOperand::C => {
            if elem_type != ScalarType::F32 {
                return Err(unsupported(
                    "wmma.load",
                    format!(
                        "accumulator element type {:?} (only .f32 accumulators are modeled)",
                        elem_type
                    ),
                ));
            }
        }
        MmaOperand::D => {
            return Err(unsupported("wmma.load", "operand .d (loads are a/b/c)"));
        }
    }

    if operands.len() < 3 {
        return Err(LowerError::InvalidOperand {
            instruction: "wmma.load".to_string(),
            operand: format!("{:?}", operands),
            reason: "expected destination vector, address, and stride operands",
        });
    }

    let dst = ctx.resolve_dst_vector(&operands[0])?;
    // See `lower_ldmatrix`: `resolve_operand` alone drops a `[reg+imm]`
    // constant offset.
    let (addr, addr_offset) = match &operands[1] {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };
    let stride = ctx.resolve_operand(&operands[2])?;

    ctx.emit(
        LoweredInstr::WmmaLoad {
            operand: operand_kind,
            shape,
            layout,
            dst,
            addr,
            addr_offset,
            stride,
            elem_type,
            space,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `wmma.store.d.sync.aligned.{row,col}.m16n16k16[.shared].f32`
pub(super) fn lower_wmma_store(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let mut layout: Option<MmaLayout> = None;
    let mut shape: Option<MmaShape> = None;
    let mut elem_type: Option<ScalarType> = None;
    let mut space: Option<MemSpace> = None;

    for modifier in modifiers {
        let s = modifier.to_string();
        if s == "sync" || s == "aligned" || s == "d" {
            // The modeled execution mode; stores always write the d fragment.
        } else if s == "shared" {
            space = Some(MemSpace::Shared);
        } else if s == "global" {
            space = Some(MemSpace::Global);
        } else if let Some(l) = MmaLayout::parse(&s) {
            layout = Some(l);
        } else if let Some(sh) = MmaShape::parse(&s) {
            shape = Some(sh);
        } else if let Some(ty) = parse_scalar_type_modifier(modifier) {
            elem_type = Some(ty);
        } else {
            return Err(unsupported("wmma.store", format!("modifier .{}", s)));
        }
    }

    // Memory spaces have separate address spaces here, so a generic
    // (spaceless) wmma access cannot be resolved to the right memory.
    let space = space.ok_or_else(|| {
        unsupported(
            "wmma.store",
            "no explicit state space (generic addressing is not modeled)",
        )
    })?;

    let layout = layout.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.store".to_string(),
        reason: Some("missing layout modifier (row or col)".to_string()),
    })?;

    let shape = shape.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.store".to_string(),
        reason: Some("missing shape modifier (e.g., m16n16k16)".to_string()),
    })?;

    let elem_type = elem_type.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.store".to_string(),
        reason: Some("missing element type modifier (e.g., f32)".to_string()),
    })?;

    // The evaluator's d-fragment layout is the fixed f32 accumulator table;
    // an .f16 accumulator has a different (packed) layout.
    if elem_type != ScalarType::F32 {
        return Err(unsupported(
            "wmma.store",
            format!(
                "accumulator element type {:?} (only .f32 accumulators are modeled)",
                elem_type
            ),
        ));
    }

    if operands.len() < 3 {
        return Err(LowerError::InvalidOperand {
            instruction: "wmma.store".to_string(),
            operand: format!("{:?}", operands),
            reason: "expected address, source vector, and stride operands",
        });
    }

    // See `lower_ldmatrix`: `resolve_operand` alone drops a `[reg+imm]`
    // constant offset.
    let (addr, addr_offset) = match &operands[0] {
        AstOperand::Address(a) => (ctx.resolve_address(a)?, ctx.get_address_offset(a)),
        other => (ctx.resolve_operand(other)?, 0),
    };
    let src = ctx.resolve_dst_vector(&operands[1])?;
    let stride = ctx.resolve_operand(&operands[2])?;

    ctx.emit(
        LoweredInstr::WmmaStore {
            shape,
            layout,
            src,
            addr,
            addr_offset,
            stride,
            elem_type,
            space,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `wmma.mma.sync.aligned.{row}.{row}.m16n16k16.f32.f32`
pub(super) fn lower_wmma_mma(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let mut layouts: Vec<MmaLayout> = Vec::new();
    let mut shape: Option<MmaShape> = None;
    let mut types: Vec<ScalarType> = Vec::new();

    for modifier in modifiers {
        let s = modifier.to_string();
        if s == "sync" || s == "aligned" {
            // The modeled execution mode.
        } else if let Some(layout) = MmaLayout::parse(&s) {
            layouts.push(layout);
        } else if let Some(sh) = MmaShape::parse(&s) {
            shape = Some(sh);
        } else if let Some(ty) = parse_scalar_type_modifier(modifier) {
            types.push(ty);
        } else {
            return Err(unsupported("wmma.mma", format!("modifier .{}", s)));
        }
    }

    let shape = shape.ok_or_else(|| LowerError::UnsupportedInstruction {
        instruction: "wmma.mma".to_string(),
        reason: Some("missing shape modifier (e.g., m16n16k16)".to_string()),
    })?;

    if layouts.len() != 2 {
        return Err(LowerError::UnsupportedInstruction {
            instruction: "wmma.mma".to_string(),
            reason: Some(format!(
                "expected 2 layout modifiers (row/col), found {}",
                layouts.len()
            )),
        });
    }

    if types.len() != 2 {
        return Err(LowerError::UnsupportedInstruction {
            instruction: "wmma.mma".to_string(),
            reason: Some(format!(
                "expected 2 type modifiers (d_type, c_type), found {}",
                types.len()
            )),
        });
    }

    // The evaluator computes f16 multiplicands into f32 accumulators; the
    // alternate-float forms carry more/other type modifiers.
    if types != [ScalarType::F32, ScalarType::F32] {
        return Err(unsupported(
            "wmma.mma",
            format!("type combination {:?} (only .f32.f32 is modeled)", types),
        ));
    }

    if operands.len() < 4 {
        return Err(LowerError::InvalidOperand {
            instruction: "wmma.mma".to_string(),
            operand: format!("{:?}", operands),
            reason: "expected 4 vector operands (dst, src_a, src_b, src_c)",
        });
    }

    let dst = ctx.resolve_dst_vector(&operands[0])?;
    let src_a = ctx.resolve_dst_vector(&operands[1])?;
    let src_b = ctx.resolve_dst_vector(&operands[2])?;
    let src_c = ctx.resolve_dst_vector(&operands[3])?;

    ctx.emit(
        LoweredInstr::WmmaMma {
            shape,
            dst,
            src_a,
            src_b,
            src_c,
        },
        predicate,
    )?;
    Ok(())
}
