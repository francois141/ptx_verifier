//! Lowering of `mbarrier.*`: init, inval, arrive, expect_tx, complete_tx and
//! the parity waits.

use crate::frontend::ast::{
    self, MbarrierArriveInstr, MbarrierCompleteTxInstr, MbarrierExpectTxInstr, MbarrierInitInstr,
    MbarrierInvalInstr, MbarrierTestWaitInstr, MbarrierTryWaitInstr, MemSemantics,
    Operand as AstOperand, SharedStateSpaceQualifier, StateSpace,
};

use crate::ir::{LoweredInstr, MBARRIER_COUNT_RANGE, MemSpace, Operand, Predicate};

use super::context::{LoweringContext, unsupported};
use super::error::{LowerError, LowerResult};

fn lower_mbarrier_addr(ctx: &LoweringContext, addr: &AstOperand) -> LowerResult<(Operand, i64)> {
    match addr {
        AstOperand::Address(a) => Ok((ctx.resolve_address(a)?, ctx.get_address_offset(a))),
        other => Ok((ctx.resolve_operand(other)?, 0)),
    }
}

/// Whether an `mbarrier` instruction has a `.shared::cluster` form (PTX ISA
/// 9.7.15.16): `arrive`/`complete_tx` do, while `init`/`inval`/`test_wait`/
/// `try_wait` only take `.shared{::cta}`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum MbarrierClusterForm {
    Exists,
    Absent,
}

impl LoweringContext {
    /// Validate an `mbarrier.*` state space. Only `.shared`/`.shared::cta` is
    /// modeled (all the corpus uses; `::cluster` names another CTA's memory):
    /// `.shared::cluster` is unsupported where the form exists, else invalid.
    fn convert_mbarrier_space(
        &self,
        space: Option<StateSpace>,
        space_qualifier: Option<ast::StateSpaceQualifier>,
        cluster_form: MbarrierClusterForm,
        instruction: &str,
    ) -> LowerResult<()> {
        match space_qualifier {
            None | Some(ast::StateSpaceQualifier::Shared(SharedStateSpaceQualifier::Cta)) => {}
            Some(ast::StateSpaceQualifier::Shared(SharedStateSpaceQualifier::Cluster))
                if cluster_form == MbarrierClusterForm::Absent =>
            {
                return Err(LowerError::InvalidInstruction {
                    instruction: instruction.to_string(),
                    reason: format!(
                        "{instruction} has no .shared::cluster form (only .shared{{::cta}})"
                    ),
                });
            }
            Some(other) => {
                return Err(unsupported(
                    instruction,
                    format!("state space qualifier {other} (single-CTA analysis only)"),
                ));
            }
        }
        match self.convert_space(space, instruction)? {
            MemSpace::Shared => Ok(()),
            other => Err(unsupported(
                instruction,
                format!("state space {other:?} (mbarrier objects must be .shared)"),
            )),
        }
    }
}

/// Reject any `.sem` other than `expected` (the ISA default: `.release` for
/// `arrive`, `.acquire` for the waits), the only case for which an
/// arrive-to-wait happens-before edge is sound (`.relaxed` is not).
fn check_mbarrier_sem(
    instruction: &str,
    sem: Option<MemSemantics>,
    expected: MemSemantics,
) -> LowerResult<()> {
    match sem {
        None => Ok(()),
        Some(s) if s == expected => Ok(()),
        Some(other) => Err(unsupported(
            instruction,
            format!(
                "memory-ordering qualifier {other:?} (the happens-before edge this analysis \
                 establishes on phase completion requires the default {expected:?} semantics)"
            ),
        )),
    }
}

/// Reject an immediate arrival count outside [`MBARRIER_COUNT_RANGE`]; a
/// register count is checked when it executes.
fn check_mbarrier_count(instruction: &str, count: &Operand) -> LowerResult<()> {
    let in_range = match count {
        Operand::ImmI64(v) => u64::try_from(*v).is_ok_and(|v| MBARRIER_COUNT_RANGE.contains(&v)),
        Operand::ImmU64(v) => MBARRIER_COUNT_RANGE.contains(v),
        _ => true,
    };
    if in_range {
        Ok(())
    } else {
        Err(LowerError::InvalidOperand {
            instruction: instruction.to_string(),
            operand: format!("{count:?}"),
            reason: "the arrival count must lie in [1, 2^20 - 1]",
        })
    }
}

/// Lower `mbarrier.init{.shared{::cta}}.b64 [addr], count`.
pub(super) fn lower_mbarrier_init(
    ctx: &mut LoweringContext,
    init: &MbarrierInitInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "mbarrier.init";
    ctx.convert_mbarrier_space(
        init.space,
        init.space_qualifier,
        MbarrierClusterForm::Absent,
        NAME,
    )?;
    let (addr_base, addr_offset) = lower_mbarrier_addr(ctx, &init.addr)?;
    let count = ctx.resolve_operand(&init.count)?;
    check_mbarrier_count(NAME, &count)?;
    ctx.emit(
        LoweredInstr::MbarrierInit {
            addr_base,
            addr_offset,
            count,
        },
        predicate,
    )?;
    Ok(())
}

/// Why `mbarrier.inval` is rejected: mbarrier operations are not memory accesses of the event
/// graph and no check orders an object's other operations before its invalidation, so a late
/// `arrive` racing with the reuse of the invalidated object's bytes would go unnoticed.
const MBARRIER_INVAL: &str = "mbarrier.inval is not implemented yet (nothing orders the object's other operations before it)";

/// Reject `mbarrier.inval{.shared{::cta}}.b64 [addr]` ([`MBARRIER_INVAL`]), after the state-space
/// check that makes a `.shared::cluster` form invalid rather than unsupported.
pub(super) fn lower_mbarrier_inval(
    ctx: &mut LoweringContext,
    inval: &MbarrierInvalInstr,
) -> LowerResult<()> {
    const NAME: &str = "mbarrier.inval";
    ctx.convert_mbarrier_space(
        inval.space,
        inval.space_qualifier,
        MbarrierClusterForm::Absent,
        NAME,
    )?;
    Err(unsupported(NAME, MBARRIER_INVAL))
}

/// Lower `mbarrier.arrive{.expect_tx}{.shared{::cta}}.b64 state, [addr]{,
/// count}`. With `.expect_tx` the arrive count is 1 and the operand is
/// `txCount` (PTX ISA 9.7.14.16.16). `.noComplete`/`arrive_drop` are unmodeled.
pub(super) fn lower_mbarrier_arrive(
    ctx: &mut LoweringContext,
    arrive: &MbarrierArriveInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "mbarrier.arrive";
    ctx.convert_mbarrier_space(
        arrive.space,
        arrive.space_qualifier,
        MbarrierClusterForm::Exists,
        NAME,
    )?;
    check_mbarrier_sem(NAME, arrive.sem, MemSemantics::Release)?;
    if arrive.no_complete {
        return Err(unsupported(NAME, ".noComplete"));
    }
    let state = match &arrive.state {
        AstOperand::Underscore => None,
        other => Some(ctx.resolve_dst(other)?),
    };
    let (addr_base, addr_offset) = lower_mbarrier_addr(ctx, &arrive.addr)?;
    let (count, expect_tx) = if arrive.expect_tx {
        let tx_count = arrive
            .count
            .as_ref()
            .ok_or_else(|| LowerError::InvalidOperand {
                instruction: NAME.to_string(),
                operand: "<missing>".to_string(),
                reason: "mbarrier.arrive.expect_tx requires a txCount operand",
            })?;
        (None, Some(ctx.resolve_operand(tx_count)?))
    } else {
        let count = arrive
            .count
            .as_ref()
            .map(|c| ctx.resolve_operand(c))
            .transpose()?;
        if let Some(count) = &count {
            check_mbarrier_count(NAME, count)?;
        }
        (count, None)
    };
    ctx.emit(
        LoweredInstr::MbarrierArrive {
            state,
            addr_base,
            addr_offset,
            count,
            expect_tx,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `mbarrier.expect_tx{.sem.scope}{.space}.b64 [addr], txCount`.
pub(super) fn lower_mbarrier_expect_tx(
    ctx: &mut LoweringContext,
    expect_tx: &MbarrierExpectTxInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "mbarrier.expect_tx";
    ctx.convert_mbarrier_space(
        expect_tx.space,
        expect_tx.space_qualifier,
        MbarrierClusterForm::Exists,
        NAME,
    )?;
    let (addr_base, addr_offset) = lower_mbarrier_addr(ctx, &expect_tx.addr)?;
    let tx_count = ctx.resolve_operand(&expect_tx.tx_count)?;
    ctx.emit(
        LoweredInstr::MbarrierExpectTx {
            addr_base,
            addr_offset,
            tx_count,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `mbarrier.complete_tx{.sem.scope}{.space}.b64 [addr], txCount`.
pub(super) fn lower_mbarrier_complete_tx(
    ctx: &mut LoweringContext,
    complete_tx: &MbarrierCompleteTxInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "mbarrier.complete_tx";
    ctx.convert_mbarrier_space(
        complete_tx.space,
        complete_tx.space_qualifier,
        MbarrierClusterForm::Exists,
        NAME,
    )?;
    let (addr_base, addr_offset) = lower_mbarrier_addr(ctx, &complete_tx.addr)?;
    let tx_count = ctx.resolve_operand(&complete_tx.tx_count)?;
    ctx.emit(
        LoweredInstr::MbarrierCompleteTx {
            addr_base,
            addr_offset,
            tx_count,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `mbarrier.test_wait.parity{...}.b64 waitComplete, [addr],
/// phaseParity`. The opaque-state-token form is unmodeled (it would need
/// per-`arrive` token identities, not a parity bit).
pub(super) fn lower_mbarrier_test_wait(
    ctx: &mut LoweringContext,
    wait: &MbarrierTestWaitInstr,
) -> LowerResult<()> {
    lower_mbarrier_wait_parity(
        ctx,
        "mbarrier.test_wait",
        wait.parity,
        wait.sem,
        wait.space,
        wait.space_qualifier,
        &wait.wait_complete,
        &wait.addr,
        &wait.state_or_parity,
    )
}

/// Lower `mbarrier.try_wait.parity{...}.b64 waitComplete, [addr],
/// phaseParity{, suspendHint}`. `suspendHint` is a pure timing hint: it is
/// validated and dropped.
pub(super) fn lower_mbarrier_try_wait(
    ctx: &mut LoweringContext,
    wait: &MbarrierTryWaitInstr,
) -> LowerResult<()> {
    if let Some(hint) = &wait.suspend_hint {
        ctx.resolve_operand(hint)?;
    }
    lower_mbarrier_wait_parity(
        ctx,
        "mbarrier.try_wait",
        wait.parity,
        wait.sem,
        wait.space,
        wait.space_qualifier,
        &wait.wait_complete,
        &wait.addr,
        &wait.state_or_parity,
    )
}

/// Shared lowering for a matched wait loop's `test_wait`/`try_wait` (see
/// `match_mbarrier_wait_loop`): both collapse to one unpredicated, blocking
/// `LoweredInstr::MbarrierWaitParity`.
#[allow(clippy::too_many_arguments)]
fn lower_mbarrier_wait_parity(
    ctx: &mut LoweringContext,
    name: &str,
    parity: bool,
    sem: Option<MemSemantics>,
    space: Option<StateSpace>,
    space_qualifier: Option<ast::StateSpaceQualifier>,
    wait_complete: &AstOperand,
    addr: &AstOperand,
    phase_parity: &AstOperand,
) -> LowerResult<()> {
    ctx.convert_mbarrier_space(space, space_qualifier, MbarrierClusterForm::Absent, name)?;
    if !parity {
        return Err(unsupported(
            name,
            "non-.parity form (opaque state-token tracking not modeled)",
        ));
    }
    check_mbarrier_sem(name, sem, MemSemantics::Acquire)?;
    let wait_complete = ctx.resolve_dst(wait_complete)?;
    let (addr_base, addr_offset) = lower_mbarrier_addr(ctx, addr)?;
    let phase_parity = ctx.resolve_operand(phase_parity)?;
    ctx.emit(
        LoweredInstr::MbarrierWaitParity {
            wait_complete,
            addr_base,
            addr_offset,
            phase_parity,
        },
        None,
    )?;
    Ok(())
}
