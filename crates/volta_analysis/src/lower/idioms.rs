//! Multi-statement nvcc idioms matched before per-instruction lowering: the
//! mbarrier retry loop and the warp max sign trick.

use volta_common::Span;
use volta_frontend::ast::{
    self, CmpOp as AstCmpOp, Instruction, InstructionOp, MbarrierTestWaitInstr,
    MbarrierTryWaitInstr, Operand as AstOperand, ParsedInstruction, RedOp, ScalarType, SetpInstr,
    Statement,
};
use volta_frontend::instr::InstrKind;
use volta_frontend::instr_parse::parse_instruction;

use crate::ir::Operand;
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

/// Source instructions spanned by the warp-max sign trick: the broadcast
/// `mov`, the `redux.sync.max.s32`, the sign-check `setp`, and the
/// predicated fixup `redux.sync.min.s32`.
pub(super) const WARP_MAX_SIGN_TRICK_LEN: usize = 4;

/// What a matched warp-max sign trick collapses to - the operands of the
/// one [`LoweredInstr::ReduxSyncBroadcastMax`] that replaces its reduction
/// trio.
pub(super) struct WarpMaxSignTrick {
    /// `%x` from the broadcast `mov.b32 %pair, {%x, %x}`: the real-valued
    /// operand the reduction is *actually* over.
    pub(super) src: Operand,
    /// The register both reduxes write.
    pub(super) dst: RegId,
    pub(super) membermask: Operand,
    /// Span of the `redux.sync.max.s32` the collapsed instruction stands in
    /// for.
    pub(super) span: Option<Span>,
}

/// Match nvcc's warp-max "sortable signed int" idiom (broadcast, s32 max redux,
/// negative fixup) as one real max ([`LoweredInstr::ReduxSyncBroadcastMax`]),
/// exact since reals are never bit-encoded; near-misses lower normally.
pub(super) fn match_warp_max_sign_trick(
    ctx: &LoweringContext,
    stmts: &[Statement],
) -> Option<WarpMaxSignTrick> {
    let window = stmts.get(..WARP_MAX_SIGN_TRICK_LEN)?;

    // Cheap pre-filter on mnemonics alone, so ordinary code pays a handful
    // of comparisons rather than four speculative instruction parses.
    let kinds = [
        InstrKind::Mov,
        InstrKind::ReduxSync,
        InstrKind::Setp,
        InstrKind::ReduxSync,
    ];
    if !window
        .iter()
        .zip(kinds)
        .all(|(stmt, kind)| statement_kind(stmt) == Some(kind))
    {
        return None;
    }

    // 1. `mov.b32 %pair, {%x, %x}` - unpredicated, both lanes the same.
    let (ParsedInstruction::Mov(mov), None) = parsed_instruction(&window[0])? else {
        return None;
    };
    let AstOperand::Vector(lanes) = &mov.src else {
        return None;
    };
    let [lo, hi] = lanes.as_slice() else {
        return None;
    };
    let src = ctx.resolve_operand(lo).ok()?;
    if mov.ty.bits() != 32 || src != ctx.resolve_operand(hi).ok()? {
        return None;
    }
    let pair = Operand::Reg(ctx.resolve_dst(&mov.dst).ok()?);

    // 2. `redux.sync.max.s32 %dst, %pair, MASK` - unpredicated.
    let (ParsedInstruction::ReduxSync(max), None) = parsed_instruction(&window[1])? else {
        return None;
    };
    if max.abs
        || max.nan
        || max.op != RedOp::Max
        || max.ty != ScalarType::S32
        || ctx.resolve_operand(&max.src).ok()? != pair
    {
        return None;
    }
    let dst = ctx.resolve_dst(&max.dst).ok()?;
    let membermask = ctx.resolve_operand(&max.membermask).ok()?;

    // 3. `setp.lt.s32 %p, %dst, 0` - unpredicated, single destination.
    let (ParsedInstruction::Setp(setp), None) = parsed_instruction(&window[2])? else {
        return None;
    };
    let SetpInstr::Simple {
        cmp_op: AstCmpOp::Lt,
        ty: ScalarType::S32,
        dst_p,
        dst_q: None,
        src_a,
        src_b,
        ..
    } = setp
    else {
        return None;
    };
    if ctx.resolve_operand(&src_a).ok()? != Operand::Reg(dst)
        || !matches!(
            ctx.resolve_operand(&src_b).ok()?,
            Operand::ImmI64(0) | Operand::ImmU64(0)
        )
    {
        return None;
    }
    let sign_check = ctx.resolve_dst(&dst_p).ok()?;

    // 4. `@%p redux.sync.min.s32 %dst, %pair, MASK` - the fixup, guarded by
    //    exactly that sign check, over exactly the same reduction.
    let (ParsedInstruction::ReduxSync(min), Some(guard)) = parsed_instruction(&window[3])? else {
        return None;
    };
    let guard = ctx.resolve_predicate(guard).ok()?;
    if guard.negated
        || guard.reg != sign_check
        || min.abs
        || min.nan
        || min.op != RedOp::Min
        || min.ty != ScalarType::S32
        || ctx.resolve_operand(&min.src).ok()? != pair
        || ctx.resolve_dst(&min.dst).ok()? != dst
        || ctx.resolve_operand(&min.membermask).ok()? != membermask
    {
        return None;
    }

    Some(WarpMaxSignTrick {
        src,
        dst,
        membermask,
        span: statement_span(&window[1]),
    })
}
