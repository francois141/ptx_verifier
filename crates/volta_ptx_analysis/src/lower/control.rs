//! Lowering of control flow (`bra`, `call`) and of CTA-level synchronization
//! (`bar`, `fence`).

use crate::frontend::ast::{self, BarMode, BraInstr, CallInstr, Operand as AstOperand};
use id_collections::Id;

use crate::ir::{BarrierAlignment, InstrId, LoweredInstr, MemSpace, Predicate};

use super::context::{LocalParamSlot, LoweringContext, unsupported};
use super::error::{LowerError, LowerResult};

/// Lower a direct call. Only `__symexpf` (the paper's hook for symbolic exp)
/// is supported. The call emits nothing; it marks the retval slot as the
/// pending exp of the argument, which the consuming `ld.param` materializes.
pub(super) fn lower_call(
    ctx: &mut LoweringContext,
    call: &CallInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // .uni is a divergence hint; it does not change what the call does.
    let CallInstr {
        uniform: _uniform,
        return_operands,
        target,
        arguments,
    } = call;
    let target_name = match target {
        AstOperand::Ident(name) => name.to_string(),
        other => {
            return Err(LowerError::UnsupportedInstruction {
                instruction: format!("call via {:?}", other),
                reason: Some("only direct calls are supported".to_string()),
            });
        }
    };
    if target_name != "__symexpf" {
        return Err(LowerError::UnsupportedInstruction {
            instruction: format!("call {}", target_name),
            reason: Some("only calls to the __symexpf symbolic-exp hook are supported".to_string()),
        });
    }
    if predicate.is_some() {
        return Err(LowerError::UnsupportedInstruction {
            instruction: format!("call {}", target_name),
            reason: Some("predicated calls are not supported".to_string()),
        });
    }

    let [arg] = arguments.as_slice() else {
        return Err(LowerError::UnsupportedInstruction {
            instruction: format!("call {}", target_name),
            reason: Some("__symexpf takes exactly one argument".to_string()),
        });
    };
    let [ret] = return_operands.as_slice() else {
        return Err(LowerError::UnsupportedInstruction {
            instruction: format!("call {}", target_name),
            reason: Some("__symexpf returns exactly one value".to_string()),
        });
    };
    let (AstOperand::Ident(arg_name), AstOperand::Ident(ret_name)) = (arg, ret) else {
        return Err(LowerError::UnsupportedInstruction {
            instruction: format!("call {}", target_name),
            reason: Some("call operands must be .param slot names".to_string()),
        });
    };

    let arg_name = arg_name.to_string();
    let src = match ctx.local_params.get(&arg_name) {
        Some(LocalParamSlot::Stored(op)) => *op,
        Some(_) => {
            return Err(LowerError::UnsupportedInstruction {
                instruction: format!("call {}", target_name),
                reason: Some(format!(
                    ".param slot '{}' was not written before the call",
                    arg_name
                )),
            });
        }
        None => return Err(LowerError::UndefinedSymbol { name: arg_name }),
    };

    let ret_name = ret_name.to_string();
    if !ctx.local_params.contains_key(&ret_name) {
        return Err(LowerError::UndefinedSymbol { name: ret_name });
    }
    ctx.local_params
        .insert(ret_name, LocalParamSlot::PendingExp(src));
    Ok(())
}

pub(super) fn lower_branch(
    ctx: &mut LoweringContext,
    bra: &BraInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // .uni is a divergence hint; it does not change where the branch goes.
    let BraInstr {
        uniform: _uniform,
        target,
    } = bra;

    // Get target label
    let target_name = match target {
        AstOperand::Symbol(name) => name.to_string(),
        AstOperand::Ident(name) => name.to_string(), // Labels are parsed as identifiers
        _ => {
            return Err(LowerError::InvalidBranchTarget {
                target: format!("{:?}", target),
            });
        }
    };

    // Try to resolve the label, from the scope this `bra` itself is in.
    let target = match ctx.symbols.resolve_label(&target_name, ctx.label_scope) {
        Some(pc) => pc,
        None => {
            // Forward reference - record it (with this branch's scope, so
            // it resolves against the right chain later) and emit placeholder.
            ctx.record_forward_ref(&target_name, ctx.label_scope);
            InstrId::from_index(0) // Will be patched later
        }
    };

    ctx.emit(LoweredInstr::Bra { target }, predicate)?;
    Ok(())
}

/// Lower a named-barrier arrival (`bar.sync a{, b}` / `bar.arrive a, b` and
/// the `barrier.*` spellings). The id and the count may be registers, both
/// checked at eval (the id's range, the count's value and its pinning).
pub(super) fn lower_bar(
    ctx: &mut LoweringContext,
    mode: BarMode,
    alignment: BarrierAlignment,
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let mnemonic = match mode {
        BarMode::Sync => "bar.sync",
        BarMode::Arrive => "bar.arrive",
        // bar.red also produces a reduction value in its destination.
        BarMode::Red => return Err(unsupported("bar.red", "reduction barrier")),
    };

    let (barrier_id, thread_count) = match operands {
        [id] => (ctx.resolve_operand(id)?, None),
        [id, count] => (ctx.resolve_operand(id)?, Some(ctx.resolve_operand(count)?)),
        _ => {
            return Err(LowerError::InvalidOperand {
                instruction: mnemonic.to_string(),
                operand: format!("{:?}", operands),
                reason: "expected a barrier id and an optional thread count",
            });
        }
    };
    ctx.check_barrier_arrivals(mnemonic, &barrier_id, thread_count.as_ref())?;

    let instr = match mode {
        BarMode::Sync => LoweredInstr::BarSync {
            barrier_id,
            thread_count,
            alignment,
        },
        // The thread count is mandatory for an arrival (PTX ISA 9.7.13.1):
        // a non-blocking arrive that does not say how many threads release
        // the barrier has no full-CTA reading the way `bar.sync a` does.
        BarMode::Arrive => match thread_count {
            Some(thread_count) => LoweredInstr::BarArrive {
                barrier_id,
                thread_count,
                alignment,
            },
            None => {
                return Err(unsupported(
                    "bar.arrive",
                    "missing thread-count operand (bar.arrive a, b)",
                ));
            }
        },
        BarMode::Red => unreachable!("rejected above"),
    };
    ctx.emit(instr, predicate)?;
    Ok(())
}

/// Lower `fence{.sem}.scope`, `fence.proxy.{alias,async}` and
/// `fence.mbarrier_init` (PTX ISA 9.7.15.4). Only `.async` has a modeled
/// effect; its `::cta`/`::cluster` restriction collapses to `MemSpace::Shared`.
pub(super) fn lower_fence(
    ctx: &mut LoweringContext,
    fence: &ast::FenceInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match fence.proxy {
        None | Some(ast::FenceProxyKind::Alias) => {
            ctx.emit(LoweredInstr::Fence, predicate)?;
        }
        Some(ast::FenceProxyKind::Async(restrict)) => {
            let restrict = restrict.map(|r| match r {
                ast::AsyncProxyRestrict::Global => MemSpace::Global,
                ast::AsyncProxyRestrict::Shared(_) => MemSpace::Shared,
            });
            ctx.emit(LoweredInstr::FenceProxyAsync { restrict }, predicate)?;
        }
    }
    Ok(())
}
