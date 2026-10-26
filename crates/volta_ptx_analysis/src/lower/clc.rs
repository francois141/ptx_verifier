//! Lowering of cluster launch control (PTX ISA 9.7.19).

use crate::frontend::ast::Operand as AstOperand;
use crate::frontend::lex::DottedIdent;

use crate::ir::types::RegClass;
use crate::ir::{LoweredInstr, Predicate};

use super::context::{LoweringContext, resolve_addr_operand, unsupported};
use super::error::{LowerError, LowerResult};

/// Lower `clusterlaunchcontrol.try_cancel.async.shared::cta.mbarrier::complete_tx::bytes.b128
/// [addr], [mbar]`. `.multicast::cluster::all` writes the response into every
/// CTA of the cluster, beyond the one CTA Volta analyzes, so it is rejected.
pub(super) fn lower_clc_try_cancel(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "clusterlaunchcontrol.try_cancel";
    let modifiers: Vec<String> = modifiers.iter().map(|m| m.to_string()).collect();
    let modifiers: Vec<&str> = modifiers.iter().map(String::as_str).collect();
    if modifiers.contains(&"multicast::cluster::all") {
        return Err(unsupported(
            NAME,
            ".multicast::cluster::all (it writes the response into every CTA of the \
             cluster; only the executing CTA is modeled)",
        ));
    }
    if modifiers
        != [
            "async",
            "shared::cta",
            "mbarrier::complete_tx::bytes",
            "b128",
        ]
    {
        return Err(unsupported(
            NAME,
            format!(
                "modifiers .{} (only .async.shared::cta.mbarrier::complete_tx::bytes.b128 \
                 is modeled)",
                modifiers.join(".")
            ),
        ));
    }

    let [addr, mbar] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected [addr], [mbar]",
        });
    };
    let (addr_base, addr_offset) = resolve_addr_operand(ctx, addr)?;
    let (mbar_base, mbar_offset) = resolve_addr_operand(ctx, mbar)?;
    ctx.emit(
        LoweredInstr::ClcTryCancel {
            addr_base,
            addr_offset,
            mbar_base,
            mbar_offset,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `clusterlaunchcontrol.query_cancel`'s `.is_canceled.pred.b128` and
/// `.get_first_ctaid{::x,::y,::z}.b32.b128` / `.get_first_ctaid.v4.b32.b128` forms.
pub(super) fn lower_clc_query_cancel(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "clusterlaunchcontrol.query_cancel";
    let invalid = |reason| LowerError::InvalidOperand {
        instruction: NAME.to_string(),
        operand: format!("{:?}", operands),
        reason,
    };
    let [dst, response] = operands else {
        return Err(invalid(
            "expected a destination and a .b128 response register",
        ));
    };
    let response = match ctx.resolve_operand(response)?.as_reg() {
        Some(reg) if reg.class == RegClass::Bits128 => reg,
        _ => return Err(invalid("the response must be a .b128 register")),
    };

    let modifiers: Vec<String> = modifiers.iter().map(|m| m.to_string()).collect();
    let modifiers: Vec<&str> = modifiers.iter().map(String::as_str).collect();
    let instr = match modifiers.as_slice() {
        ["is_canceled", "pred", "b128"] => {
            let dst = ctx.resolve_dst(dst)?;
            if dst.class != RegClass::Pred {
                return Err(invalid(
                    "is_canceled's destination must be a .pred register",
                ));
            }
            LoweredInstr::ClcQueryIsCanceled { dst, response }
        }
        [
            "get_first_ctaid::x" | "get_first_ctaid::y" | "get_first_ctaid::z",
            "b32",
            "b128",
        ] => {
            check_b32_dst(ctx, dst, invalid)?;
            LoweredInstr::ClcQueryGetFirstCtaid { response }
        }
        ["get_first_ctaid", "v4", "b32", "b128"] => {
            let AstOperand::Vector(elems) = dst else {
                return Err(invalid(
                    "get_first_ctaid.v4 needs a 4-element vector destination",
                ));
            };
            if elems.len() != 4 {
                return Err(invalid(
                    "get_first_ctaid.v4 needs a 4-element vector destination",
                ));
            }
            for elem in elems {
                if !matches!(elem, AstOperand::Underscore) {
                    check_b32_dst(ctx, elem, invalid)?;
                }
            }
            LoweredInstr::ClcQueryGetFirstCtaid { response }
        }
        _ => {
            return Err(unsupported(
                NAME,
                format!("modifiers .{}", modifiers.join(".")),
            ));
        }
    };
    ctx.emit(instr, predicate)?;
    Ok(())
}

fn check_b32_dst(
    ctx: &LoweringContext,
    dst: &AstOperand,
    invalid: impl Fn(&'static str) -> LowerError,
) -> LowerResult<()> {
    if ctx.resolve_dst(dst)?.class != RegClass::Bits32 {
        return Err(invalid(
            "get_first_ctaid's destinations must be .b32 registers",
        ));
    }
    Ok(())
}
