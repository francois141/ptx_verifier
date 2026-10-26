//! Multi-statement nvcc idioms matched before per-instruction lowering: the
//! mbarrier retry loop.

use crate::frontend::ast::{
    self, Instruction, InstructionOp, MbarrierTestWaitInstr, MbarrierTryWaitInstr,
    Operand as AstOperand, ParsedInstruction, Statement,
};
use crate::frontend::instr::InstrKind;
use crate::frontend::instr_parse::parse_instruction;
use volta_common::Span;

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

/// Source statements spanned by an mbarrier wait loop: the loop label, the
/// wait, and the retry `bra`.
pub(super) const MBARRIER_WAIT_LOOP_LEN: usize = 3;

/// The wait instruction of a matched mbarrier wait loop.
pub(super) enum MbarrierWaitLoop {
    Test(MbarrierTestWaitInstr),
    Try(MbarrierTryWaitInstr),
}

/// Match the retry loop `L: mbarrier.{try,test}_wait.parity p, [addr], ph;
/// @!p bra L;` - the only form in which Volta models an mbarrier wait,
/// since the scheduler can only block a thread, not spin it.
pub(super) fn match_mbarrier_wait_loop(
    ctx: &LoweringContext,
    stmts: &[Statement],
) -> Option<MbarrierWaitLoop> {
    let [Statement::Label(label), wait, retry] = stmts.get(..MBARRIER_WAIT_LOOP_LEN)? else {
        return None;
    };
    if !matches!(
        statement_kind(wait),
        Some(InstrKind::MbarrierTestWait | InstrKind::MbarrierTryWait)
    ) || statement_kind(retry) != Some(InstrKind::Bra)
    {
        return None;
    }

    let (wait_loop, wait_complete) = match parsed_instruction(wait)? {
        (ParsedInstruction::MbarrierTestWait(w), None) => {
            let wait_complete = ctx.resolve_dst(&w.wait_complete).ok()?;
            (MbarrierWaitLoop::Test(w), wait_complete)
        }
        (ParsedInstruction::MbarrierTryWait(w), None) => {
            let wait_complete = ctx.resolve_dst(&w.wait_complete).ok()?;
            (MbarrierWaitLoop::Try(w), wait_complete)
        }
        _ => return None,
    };

    let (ParsedInstruction::Bra(bra), Some(guard)) = parsed_instruction(retry)? else {
        return None;
    };
    let guard = ctx.resolve_predicate(guard).ok()?;
    let (AstOperand::Ident(target) | AstOperand::Symbol(target)) = &bra.target else {
        return None;
    };
    if !guard.negated || guard.reg != wait_complete || *target != label.name {
        return None;
    }
    Some(wait_loop)
}
