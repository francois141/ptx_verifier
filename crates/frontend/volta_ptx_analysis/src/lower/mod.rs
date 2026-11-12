//! Lowering pass: AST → LoweredProgram. Builds the symbol table, resolves
//! register references and labels to indices/PCs, type-checks operands, and
//! converts instruction variants to a uniform representation.

mod arith;
mod clc;
mod context;
mod control;
mod error;
mod idioms;
mod mbarrier;
mod memory;
mod tcgen05;
#[cfg(test)]
mod tests;
mod tma;
mod warp;

use crate::frontend::ast::{
    self, Function, FunctionBody, Instruction, InstructionOp, ParsedInstruction, StateSpace,
    Statement, VarDecl,
};
use crate::frontend::instr::InstrKind;
use crate::frontend::instr_parse::parse_instruction;
use id_collections::{Id, IdVec};

use crate::ir::symbols::ParamLayout;
use crate::ir::types::ScalarTypeExt;
use crate::ir::{BarrierAlignment, BinOp, InstrId, LoweredInstr, LoweredProgram, Predicate};

use arith::{
    lower_abs, lower_add, lower_bfe, lower_bfi, lower_copysign, lower_cvt, lower_div, lower_ex2,
    lower_fma, lower_lg2, lower_logic, lower_lop3, lower_mad, lower_max, lower_min, lower_mul,
    lower_neg, lower_not, lower_prmt, lower_rcp, lower_rem, lower_rsqrt, lower_selp, lower_setp,
    lower_shf, lower_shift, lower_sqrt, lower_sub, lower_tanh,
};
use clc::{lower_clc_query_cancel, lower_clc_try_cancel};
use context::{LocalParamSlot, LoweringContext, unsupported};
use control::{lower_bar, lower_branch, lower_call, lower_fence};
use error::MbarrierWaitKind;
pub use error::{LowerError, LowerResult};
use idioms::{MbarrierWaitLoop, match_mbarrier_wait_loop, statement_span};
use mbarrier::{
    lower_mbarrier_arrive, lower_mbarrier_complete_tx, lower_mbarrier_expect_tx,
    lower_mbarrier_init, lower_mbarrier_inval, lower_mbarrier_test_wait, lower_mbarrier_try_wait,
};
use memory::{
    lower_cp_async, lower_cp_async_mbarrier_arrive, lower_cp_async_wait_all,
    lower_cp_async_wait_group, lower_cvta, lower_ld_global_nc, lower_load, lower_mapa, lower_mov,
    lower_store,
};
use tcgen05::{
    lower_tcgen05_alloc, lower_tcgen05_commit, lower_tcgen05_dealloc, lower_tcgen05_fence,
    lower_tcgen05_ld, lower_tcgen05_mma, lower_tcgen05_relinquish_alloc_permit, lower_tcgen05_st,
    lower_tcgen05_wait,
};
use tma::{
    lower_cp_async_bulk, lower_cp_async_bulk_tensor, lower_fence_proxy_tensormap,
    lower_prefetch_tensormap, lower_tensormap_cp_fenceproxy, lower_tensormap_replace,
};
use warp::{
    lower_bar_warp_sync, lower_elect_sync, lower_ldmatrix, lower_mma, lower_movmatrix,
    lower_setmaxnreg, lower_shfl_sync, lower_stmatrix, lower_wmma_load, lower_wmma_mma,
    lower_wmma_store,
};

/// Lower a PTX function to a LoweredProgram
///
/// `module_vars` should contain module-level variable declarations (e.g., extern shared memory).
pub fn lower_function(func: &Function, module_vars: &[VarDecl]) -> LowerResult<LoweredProgram> {
    let body = func.body.as_ref().ok_or(LowerError::NoFunctionBody {
        name: func.name.to_string(),
    })?;

    let mut ctx = LoweringContext::new();

    // First: collect module-level declarations (e.g., extern shared memory)
    for var in module_vars {
        collect_var_decl(&mut ctx, var)?;
    }

    // Second: collect function-level declarations
    collect_declarations(&mut ctx, &func.params, body)?;

    // Place the extern-shared window now that all static `.shared` is known
    // (the CUDA ABI puts the dynamic segment after it). Must precede
    // `lower_body`, which first resolves shared symbols to addresses.
    ctx.symbols.finalize_shared_layout()?;

    // Third: lower instructions
    lower_body(&mut ctx, body)?;

    // Resolve forward references
    ctx.resolve_forward_refs()?;

    Ok(LoweredProgram {
        instructions: IdVec::from_vec(ctx.instructions),
        predicates: IdVec::from_vec(ctx.predicates),
        symbols: ctx.symbols,
        source_map: ctx.source_map,
        entry_pc: InstrId::from_index(0),
    })
}

/// Collect all declarations (registers, labels, shared memory)
fn collect_declarations(
    ctx: &mut LoweringContext,
    params: &[ast::Parameter],
    body: &FunctionBody,
) -> LowerResult<()> {
    // Collect kernel parameters
    for param in params {
        let element =
            param.ty.scalar.size_bytes() as u64 * param.ty.vec.map_or(1, |v| v.count() as u64);
        let count = param.array_dims.iter().map(|&d| d as u64).product::<u64>();
        let layout = if param.array_dims.is_empty() {
            ParamLayout::Scalar
        } else {
            ParamLayout::Aggregate
        };
        let alignment = param.align.map_or(element, |a| a as u64);
        ctx.symbols
            .declare_param(&param.name.to_string(), element * count, alignment, layout)?;
    }

    // Collect declarations from body
    for stmt in &body.statements {
        collect_stmt_declarations(ctx, stmt)?;
    }

    Ok(())
}

/// Collect declarations from a statement
fn collect_stmt_declarations(ctx: &mut LoweringContext, stmt: &Statement) -> LowerResult<()> {
    match stmt {
        Statement::Variable(var_decl) => {
            collect_var_decl(ctx, var_decl)?;
        }
        Statement::Block(stmts) => {
            for s in stmts {
                collect_stmt_declarations(ctx, s)?;
            }
        }
        Statement::Label(_) | Statement::Instruction(_) | Statement::Directive(_) => {
            // These don't introduce declarations
        }
    }
    Ok(())
}

/// Collect a variable declaration
fn collect_var_decl(ctx: &mut LoweringContext, var: &VarDecl) -> LowerResult<()> {
    let name = var.name.to_string();
    let ty = var.ty.scalar;
    let count = var.param_count.unwrap_or(1);

    // Checked product: each dimension fits u32, but three can wrap the u64
    // product, and a wrapped count would slip past the packer's own checks.
    let num_elements: u64 = var
        .array_dims
        .iter()
        .filter_map(|d| *d)
        .try_fold(1u64, |acc, d| acc.checked_mul(d as u64))
        .ok_or_else(|| LowerError::VariableSizeOverflow {
            what: format!("variable '{}' (array dimensions overflow)", name),
        })?;
    let num_elements = if num_elements == 0 { 1 } else { num_elements };
    let alignment = var.align.unwrap_or(ty.size_bytes() as u32) as u64;

    match var.space {
        StateSpace::Reg => {
            ctx.symbols.declare_register(&name, ty, count)?;
        }
        StateSpace::Shared => {
            let is_extern = matches!(var.linkage, ast::Linkage::Extern);
            ctx.symbols
                .declare_shared(&name, ty, num_elements, is_extern, alignment)?;
        }
        StateSpace::Param => {
            // Block-scope `.param` slots used by the callseq idiom. These are
            // virtual: no memory is allocated and no instructions touch them.
            ctx.local_params.insert(name, LocalParamSlot::Empty);
        }
        StateSpace::Local => {
            // Function-scope local memory (e.g. the __local_depot stack array)
            ctx.symbols
                .declare_local(&name, ty, num_elements, alignment)?;
        }
        StateSpace::Global => {
            // Module-scope variable (e.g. set by the host via
            // cudaMemcpyToSymbol); the driver binds its value by name.
            ctx.symbols
                .declare_global_var(&name, ty, num_elements, alignment)?;
        }
        _ => {
            // Other state spaces (const, tex) - handle as needed
        }
    }

    Ok(())
}

/// Lower the function body
fn lower_body(ctx: &mut LoweringContext, body: &FunctionBody) -> LowerResult<()> {
    lower_statements(ctx, &body.statements)
}

/// Lower a run of statements one at a time, except where a multi-statement
/// idiom matches a window (see [`match_mbarrier_wait_loop`]). Windows span
/// only consecutive statements.
fn lower_statements(ctx: &mut LoweringContext, stmts: &[Statement]) -> LowerResult<()> {
    // Directives such as `.loc` lower to nothing, so they can be ignored.
    let stmts: Vec<Statement> = stmts
        .iter()
        .filter(|stmt| !matches!(stmt, Statement::Directive(_)))
        .cloned()
        .collect();
    let mut i = 0;
    while i < stmts.len() {
        if let Some(wait_loop) = match_mbarrier_wait_loop(ctx, &stmts[i..]) {
            // The label resolves to the blocking wait; the loop's branches are
            // dropped, so waking falls through to the loop's exit.
            lower_statement(ctx, &stmts[i])?;
            ctx.current_span = statement_span(&stmts[i + 1]);
            match &wait_loop.wait {
                MbarrierWaitLoop::Test(wait) => lower_mbarrier_test_wait(ctx, wait)?,
                MbarrierWaitLoop::Try(wait) => lower_mbarrier_try_wait(ctx, wait)?,
            }
            if let Some(exit) = wait_loop.exit_label {
                lower_statement(ctx, exit)?;
            }
            i += wait_loop.len;
            continue;
        }
        lower_statement(ctx, &stmts[i])?;
        i += 1;
    }
    Ok(())
}

/// Lower a statement
fn lower_statement(ctx: &mut LoweringContext, stmt: &Statement) -> LowerResult<()> {
    match stmt {
        Statement::Label(label) => {
            ctx.record_label(&label.name.to_string());
        }
        Statement::Instruction(instr) => {
            // Set current span for error reporting
            ctx.current_span = Some(instr.span);
            lower_instruction(ctx, instr)?;
        }
        Statement::Block(stmts) => {
            // A `{}` block is its own label scope (PTX ISA: labels, like
            // `.reg`s, are block-scoped; see `LabelScopeId`): push a child
            // scope for the block and restore the parent on exit.
            let parent_scope = ctx.label_scope;
            ctx.label_scope = ctx.symbols.push_label_scope(parent_scope);
            lower_statements(ctx, stmts)?;
            ctx.label_scope = parent_scope;
        }
        Statement::Variable(_) => {
            // Already handled in first pass
        }
        Statement::Directive(_) => {
            // Directives are ignored for now
        }
    }
    Ok(())
}

/// Lower an instruction
fn lower_instruction(ctx: &mut LoweringContext, instr: &Instruction) -> LowerResult<()> {
    // Resolve predicate if present
    let predicate = match &instr.predicate {
        Some(p) => Some(ctx.resolve_predicate(p)?),
        None => None,
    };

    match &instr.op {
        InstructionOp::Parsed(parsed) => {
            lower_parsed_instruction(ctx, parsed, predicate)?;
        }
        InstructionOp::Unparsed {
            kind,
            modifiers,
            operands,
        } => {
            // Try to parse the unparsed instruction into a strongly-typed form
            match parse_instruction(*kind, modifiers.clone(), operands.clone()) {
                Ok(parsed) => {
                    lower_parsed_instruction(ctx, &parsed, predicate)?;
                }
                Err(e) => {
                    // If parsing fails, report the error
                    Err(LowerError::UnsupportedInstruction {
                        instruction: format!("{:?}", kind),
                        reason: Some(format!("Instruction parsing failed: {:?}", e)),
                    })?;
                }
            }
        }
    }

    Ok(())
}

/// Lower a parsed instruction
fn lower_parsed_instruction(
    ctx: &mut LoweringContext,
    instr: &ParsedInstruction,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match instr {
        ParsedInstruction::Add(add_instr) => lower_add(ctx, add_instr, predicate),
        ParsedInstruction::Sub(sub) => lower_sub(ctx, sub, predicate),
        ParsedInstruction::Mul(mul) => lower_mul(ctx, mul, predicate),
        ParsedInstruction::Mad(mad) => lower_mad(ctx, mad, predicate),
        ParsedInstruction::Fma(fma) => lower_fma(ctx, fma, predicate),
        ParsedInstruction::Div(div) => lower_div(ctx, div, predicate),
        ParsedInstruction::Rem(rem) => lower_rem(ctx, rem, predicate),
        ParsedInstruction::Neg(neg) => lower_neg(ctx, neg, predicate),
        ParsedInstruction::Rcp(rcp) => lower_rcp(ctx, rcp, predicate),
        ParsedInstruction::Sqrt(sqrt) => lower_sqrt(ctx, sqrt, predicate),
        ParsedInstruction::Rsqrt(rsqrt) => lower_rsqrt(ctx, rsqrt, predicate),
        ParsedInstruction::Lg2(lg2) => lower_lg2(ctx, lg2, predicate),
        ParsedInstruction::Ex2(ex2) => lower_ex2(ctx, ex2, predicate),
        ParsedInstruction::Tanh(tanh) => lower_tanh(ctx, tanh, predicate),
        ParsedInstruction::Abs(abs) => lower_abs(ctx, abs, predicate),
        ParsedInstruction::Copysign(copysign) => lower_copysign(ctx, copysign, predicate),
        ParsedInstruction::Min(min) => lower_min(ctx, min, predicate),
        ParsedInstruction::Max(max) => lower_max(ctx, max, predicate),
        ParsedInstruction::And(logic) => lower_logic(ctx, BinOp::And, "and", logic, predicate),
        ParsedInstruction::Or(logic) => lower_logic(ctx, BinOp::Or, "or", logic, predicate),
        ParsedInstruction::Xor(logic) => lower_logic(ctx, BinOp::Xor, "xor", logic, predicate),
        ParsedInstruction::Not(not) => lower_not(ctx, not, predicate),
        ParsedInstruction::Shl(shift) => lower_shift(ctx, BinOp::Shl, "shl", shift, predicate),
        ParsedInstruction::Shr(shift) => lower_shift(ctx, BinOp::Shr, "shr", shift, predicate),
        ParsedInstruction::Shf(shf) => lower_shf(ctx, shf, predicate),
        ParsedInstruction::Bfi(bfi) => lower_bfi(ctx, bfi, predicate),
        ParsedInstruction::Bfe(bfe) => lower_bfe(ctx, bfe, predicate),
        ParsedInstruction::Setp(setp) => lower_setp(ctx, setp, predicate),
        ParsedInstruction::Selp(selp) => lower_selp(ctx, selp, predicate),
        ParsedInstruction::Mov(mov) => lower_mov(ctx, mov, predicate),
        ParsedInstruction::Ld(ld) => lower_load(ctx, ld, predicate),
        ParsedInstruction::St(st) => lower_store(ctx, st, predicate),
        ParsedInstruction::CpAsync(cp) => lower_cp_async(ctx, cp, predicate),
        ParsedInstruction::CpAsyncCommitGroup => {
            ctx.emit(LoweredInstr::CpAsyncCommitGroup, predicate)
        }
        ParsedInstruction::CpAsyncWaitGroup(wg) => lower_cp_async_wait_group(ctx, wg, predicate),
        ParsedInstruction::CpAsyncWaitAll => lower_cp_async_wait_all(ctx, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::CpAsyncMbarrierArrive,
            modifiers,
            operands,
        } => lower_cp_async_mbarrier_arrive(ctx, modifiers, operands, predicate),
        ParsedInstruction::Cvt(cvt) => lower_cvt(ctx, cvt, predicate),
        ParsedInstruction::Cvta(cvta) => lower_cvta(ctx, cvta, predicate),
        ParsedInstruction::Mapa(mapa) => lower_mapa(ctx, mapa, predicate),
        ParsedInstruction::Prmt(prmt) => lower_prmt(ctx, prmt, predicate),
        ParsedInstruction::Lop3(lop3) => lower_lop3(ctx, lop3, predicate),
        ParsedInstruction::ShflSync(shfl) => lower_shfl_sync(ctx, shfl, predicate),
        ParsedInstruction::ElectSync(elect) => lower_elect_sync(ctx, elect, predicate),
        ParsedInstruction::Bra(bra) => lower_branch(ctx, bra, predicate),
        ParsedInstruction::Ret(ast::RetInstr {
            // .uni is a divergence hint; it does not change what ret does.
            uniform: _uniform,
        }) => ctx.emit(LoweredInstr::Ret, predicate),
        ParsedInstruction::Exit => ctx.emit(LoweredInstr::Exit, predicate),
        ParsedInstruction::Bar(bar) => lower_bar(
            ctx,
            bar.mode,
            BarrierAlignment::Aligned,
            &bar.operands,
            predicate,
        ),
        // `bar{.cta}.sync` is `barrier{.cta}.sync.aligned` per the ISA, and
        // `.cta` is the default scope.
        ParsedInstruction::Barrier(ast::BarrierInstr {
            cta: _cta,
            aligned,
            mode,
            operands,
        }) => {
            let alignment = if *aligned {
                BarrierAlignment::Aligned
            } else {
                BarrierAlignment::Unaligned
            };
            lower_bar(ctx, *mode, alignment, operands, predicate)
        }
        ParsedInstruction::BarWarpSync(bws) => lower_bar_warp_sync(ctx, bws, predicate),
        ParsedInstruction::Setmaxnreg(setmaxnreg) => lower_setmaxnreg(ctx, setmaxnreg, predicate),
        ParsedInstruction::Membar(ast::MembarInstr::Level(_)) => {
            ctx.emit(LoweredInstr::Membar, predicate)
        }
        // TODO: implement `membar.proxy`. On sm_70+ it is a synonym for
        // `fence.proxy` (PTX ISA 9.7.15.4), so it can lower like
        // `lower_fence`'s proxy arm; on sm_60 that is an approximation.
        ParsedInstruction::Membar(ast::MembarInstr::Proxy(_)) => Err(unsupported(
            "membar.proxy",
            "membar.proxy is not implemented yet",
        )),
        ParsedInstruction::Fence(fence) => lower_fence(ctx, fence, predicate),
        ParsedInstruction::Call(call) => lower_call(ctx, call, predicate),
        // The interpreter does not model warp divergence, so inside a divergent branch
        // `activemask` would report the other side's lanes as active too.
        ParsedInstruction::Activemask(_) => Err(unsupported(
            "activemask",
            "activemask is not implemented yet (warp divergence is not modeled)",
        )),
        ParsedInstruction::Brkpt => ctx.emit(LoweredInstr::Nop, predicate),
        // Reaching a trap during evaluation is an analysis error
        ParsedInstruction::Trap => ctx.emit(LoweredInstr::Trap, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::LdGlobalNc,
            modifiers,
            operands,
        } => lower_ld_global_nc(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Ldmatrix,
            modifiers,
            operands,
        } => lower_ldmatrix(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Movmatrix,
            modifiers,
            operands,
        } => lower_movmatrix(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Mma,
            modifiers,
            operands,
        } => lower_mma(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::WmmaLoad,
            modifiers,
            operands,
        } => lower_wmma_load(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::WmmaStore,
            modifiers,
            operands,
        } => lower_wmma_store(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::WmmaMma,
            modifiers,
            operands,
        } => lower_wmma_mma(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Alloc,
            modifiers,
            operands,
        } => lower_tcgen05_alloc(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Dealloc,
            modifiers,
            operands,
        } => lower_tcgen05_dealloc(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05RelinquishAllocPermit,
            modifiers,
            operands,
        } => lower_tcgen05_relinquish_alloc_permit(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Ld,
            modifiers,
            operands,
        } => lower_tcgen05_ld(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05St,
            modifiers,
            operands,
        } => lower_tcgen05_st(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05WaitLd,
            modifiers,
            operands,
        } => lower_tcgen05_wait(ctx, modifiers, operands, predicate, false),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05WaitSt,
            modifiers,
            operands,
        } => lower_tcgen05_wait(ctx, modifiers, operands, predicate, true),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Mma,
            modifiers,
            operands,
        } => lower_tcgen05_mma(ctx, modifiers, operands, predicate, false),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05MmaWs,
            modifiers,
            operands,
        } => lower_tcgen05_mma(ctx, modifiers, operands, predicate, true),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Fence,
            modifiers,
            operands,
        } => lower_tcgen05_fence(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Commit,
            modifiers,
            operands,
        } => lower_tcgen05_commit(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind:
                kind @ (InstrKind::WgmmaMmaAsync
                | InstrKind::WgmmaMmaAsyncSp
                | InstrKind::WgmmaFence
                | InstrKind::WgmmaCommitGroup
                | InstrKind::WgmmaWaitGroup),
            ..
        } => Err(unsupported(
            kind.to_string(),
            "wgmma is not supported by Volta at the moment",
        )),
        ParsedInstruction::Other {
            kind: InstrKind::ReduxSync,
            ..
        } => Err(unsupported(
            "redux.sync",
            "redux.sync is not supported by Volta at the moment",
        )),
        ParsedInstruction::Other {
            kind: InstrKind::Stmatrix,
            modifiers,
            operands,
        } => lower_stmatrix(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::TensormapReplace,
            modifiers,
            operands,
        } => lower_tensormap_replace(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::TensormapCpFenceproxy,
            modifiers,
            operands,
        } => lower_tensormap_cp_fenceproxy(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::FenceProxyTensormap,
            modifiers,
            operands,
        } => lower_fence_proxy_tensormap(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::Prefetch,
            modifiers,
            operands,
        } => lower_prefetch_tensormap(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::CpAsyncBulkTensor,
            modifiers,
            operands,
        } => lower_cp_async_bulk_tensor(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::CpAsyncBulk,
            modifiers,
            operands,
        } => lower_cp_async_bulk(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::ClusterlaunchcontrolTryCancel,
            modifiers,
            operands,
        } => lower_clc_try_cancel(ctx, modifiers, operands, predicate),
        ParsedInstruction::Other {
            kind: InstrKind::ClusterlaunchcontrolQueryCancel,
            modifiers,
            operands,
        } => lower_clc_query_cancel(ctx, modifiers, operands, predicate),
        ParsedInstruction::MbarrierInit(init) => lower_mbarrier_init(ctx, init, predicate),
        ParsedInstruction::MbarrierInval(inval) => lower_mbarrier_inval(ctx, inval),
        ParsedInstruction::MbarrierArrive(arrive) => lower_mbarrier_arrive(ctx, arrive, predicate),
        ParsedInstruction::MbarrierExpectTx(expect_tx) => {
            lower_mbarrier_expect_tx(ctx, expect_tx, predicate)
        }
        ParsedInstruction::MbarrierCompleteTx(complete_tx) => {
            lower_mbarrier_complete_tx(ctx, complete_tx, predicate)
        }
        ParsedInstruction::MbarrierTestWait(_) => Err(LowerError::MbarrierWaitOutsideRetryLoop {
            wait: MbarrierWaitKind::TestWait,
        }),
        ParsedInstruction::MbarrierTryWait(_) => Err(LowerError::MbarrierWaitOutsideRetryLoop {
            wait: MbarrierWaitKind::TryWait,
        }),
        _ => Err(LowerError::UnsupportedInstruction {
            instruction: format!("{:?}", instr),
            reason: Some("Instruction not yet implemented".to_string()),
        }),
    }
}
