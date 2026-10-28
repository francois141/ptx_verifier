//! Multi-statement nvcc idioms matched before per-instruction lowering: the
//! mbarrier retry loop.

use crate::frontend::ast::{
    self, Instruction, InstructionOp, MbarrierTestWaitInstr, MbarrierTryWaitInstr,
    Operand as AstOperand, ParsedInstruction, Statement,
};
use crate::frontend::instr::InstrKind;
use crate::frontend::instr_parse::parse_instruction;
use volta_common::Span;

use crate::ir::symbols::RegId;

use super::context::LoweringContext;

/// A statement's mnemonic, without parsing modifiers or operands. `None`
/// for anything but a raw instruction (the parser only pre-parses `call`).
fn statement_kind(stmt: &Statement) -> Option<InstrKind> {
    match stmt {
        Statement::Instruction(Instruction {
            op: InstructionOp::Unparsed { kind, .. },
            ..
        }) => Some(*kind),
        _ => None,
    }
}

pub(super) fn statement_span(stmt: &Statement) -> Option<Span> {
    match stmt {
        Statement::Instruction(instr) => Some(instr.span),
        _ => None,
    }
}

/// A statement's typed instruction plus guard predicate, converted
/// speculatively as `lower_instruction` would. `None` if not an
/// instruction or it does not parse.
fn parsed_instruction(stmt: &Statement) -> Option<(ParsedInstruction, Option<&ast::Predicate>)> {
    let Statement::Instruction(instr) = stmt else {
        return None;
    };
    let parsed = match &instr.op {
        InstructionOp::Parsed(parsed) => parsed.clone(),
        InstructionOp::Unparsed {
            kind,
            modifiers,
            operands,
        } => parse_instruction(*kind, modifiers.clone(), operands.clone()).ok()?,
    };
    Some((parsed, instr.predicate.as_ref()))
}

/// The wait instruction of a matched mbarrier wait loop.
pub(super) enum MbarrierWaitLoop {
    Test(MbarrierTestWaitInstr),
    Try(MbarrierTryWaitInstr),
}

/// A matched wait loop: its wait, how many source statements it spans, and
/// the loop's exit label when the loop names one (`DONE:` below).
pub(super) struct MatchedWaitLoop<'s> {
    pub wait: MbarrierWaitLoop,
    pub len: usize,
    pub exit_label: Option<&'s Statement>,
}

/// Match an mbarrier retry loop, the only form in which Volta models an
/// mbarrier wait, since the scheduler can only block a thread, not spin it:
/// `L: mbarrier.{try,test}_wait.parity p, [addr], ph; @!p bra L;` (nvcc), or
/// `L: ...wait p, ...; @p bra DONE; bra L; DONE:` (ThunderKittens), which
/// leaves the loop on the same condition.
pub(super) fn match_mbarrier_wait_loop<'s>(
    ctx: &LoweringContext,
    stmts: &'s [Statement],
) -> Option<MatchedWaitLoop<'s>> {
    if let [Statement::Label(label), wait, retry, ..] = stmts {
        let (wait_loop, wait_complete) = loop_wait(ctx, wait)?;
        if branch_to(ctx, retry, Some((wait_complete, Negated::Yes)), label) {
            return Some(MatchedWaitLoop {
                wait: wait_loop,
                len: 3,
                exit_label: None,
            });
        }
    }
    let [
        Statement::Label(label),
        wait,
        exit,
        retry,
        done @ Statement::Label(done_label),
        ..,
    ] = stmts
    else {
        return None;
    };
    let (wait_loop, wait_complete) = loop_wait(ctx, wait)?;
    (branch_to(ctx, exit, Some((wait_complete, Negated::No)), done_label)
        && branch_to(ctx, retry, None, label))
    .then_some(MatchedWaitLoop {
        wait: wait_loop,
        len: 5,
        exit_label: Some(done),
    })
}

#[derive(PartialEq)]
enum Negated {
    Yes,
    No,
}

/// Whether `stmt` is a `bra` to `target`, guarded as `guard` says (`None`: unguarded).
fn branch_to(
    ctx: &LoweringContext,
    stmt: &Statement,
    guard: Option<(RegId, Negated)>,
    target: &ast::Label,
) -> bool {
    if statement_kind(stmt) != Some(InstrKind::Bra) {
        return false;
    }
    let Some((ParsedInstruction::Bra(bra), given)) = parsed_instruction(stmt) else {
        return false;
    };
    let (AstOperand::Ident(name) | AstOperand::Symbol(name)) = &bra.target else {
        return false;
    };
    let guard_matches = match (guard, given) {
        (None, None) => true,
        (Some((reg, negated)), Some(given)) => ctx
            .resolve_predicate(given)
            .is_ok_and(|g| g.reg == reg && g.negated == (negated == Negated::Yes)),
        _ => false,
    };
    guard_matches && *name == target.name
}

/// The loop's unguarded wait and the predicate register it sets.
fn loop_wait(ctx: &LoweringContext, wait: &Statement) -> Option<(MbarrierWaitLoop, RegId)> {
    if !matches!(
        statement_kind(wait),
        Some(InstrKind::MbarrierTestWait | InstrKind::MbarrierTryWait)
    ) {
        return None;
    }
    match parsed_instruction(wait)? {
        (ParsedInstruction::MbarrierTestWait(w), None) => {
            let wait_complete = ctx.resolve_dst(&w.wait_complete).ok()?;
            Some((MbarrierWaitLoop::Test(w), wait_complete))
        }
        (ParsedInstruction::MbarrierTryWait(w), None) => {
            let wait_complete = ctx.resolve_dst(&w.wait_complete).ok()?;
            Some((MbarrierWaitLoop::Try(w), wait_complete))
        }
        _ => None,
    }
}
