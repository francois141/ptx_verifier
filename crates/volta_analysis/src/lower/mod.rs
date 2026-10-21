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
mod wgmma;

use id_collections::{Id, IdVec};
use volta_frontend::ast::{
    self, Function, FunctionBody, Instruction, InstructionOp, Operand as AstOperand,
    ParsedInstruction, ScalarType, StateSpace, Statement, VarDecl,
};
use volta_frontend::instr::InstrKind;
use volta_frontend::instr_parse::parse_instruction;

use crate::lowered::{BinOp, InstrId, LoweredInstr, LoweredProgram, Operand, Predicate, UnaryOp};
use crate::symbols::RegId;
use crate::types::ScalarTypeExt;

use arith::{
    lower_abs, lower_add, lower_copysign, lower_cvt, lower_div, lower_float_unary, lower_fma,
    lower_mad, lower_max, lower_min, lower_mul, lower_neg, lower_setp, lower_sub,
};
use clc::{lower_clc_query_cancel, lower_clc_try_cancel};
use context::{LocalParamSlot, LoweringContext, unsupported};
use control::{lower_bar, lower_branch, lower_call, lower_fence};
use error::MbarrierWaitKind;
pub use error::{LowerError, LowerResult};
use idioms::{
    MBARRIER_WAIT_LOOP_LEN, MbarrierWaitLoop, WARP_MAX_SIGN_TRICK_LEN, match_mbarrier_wait_loop,
    match_warp_max_sign_trick, statement_span,
};
use mbarrier::{
    lower_mbarrier_arrive, lower_mbarrier_complete_tx, lower_mbarrier_init, lower_mbarrier_inval,
    lower_mbarrier_test_wait, lower_mbarrier_try_wait,
};
use memory::{
    lower_cp_async, lower_cp_async_mbarrier_arrive, lower_ld_global_nc, lower_load, lower_store,
};
use tcgen05::{
    lower_tcgen05_alloc, lower_tcgen05_commit, lower_tcgen05_dealloc, lower_tcgen05_fence,
    lower_tcgen05_ld, lower_tcgen05_mma, lower_tcgen05_relinquish_alloc_permit, lower_tcgen05_st,
    lower_tcgen05_wait,
};
use tma::{
    lower_cp_async_bulk, lower_cp_async_bulk_tensor, lower_fence_proxy_tensormap,
    lower_tensormap_cp_fenceproxy, lower_tensormap_replace,
};
use warp::{
    lower_elect_sync, lower_ldmatrix, lower_mma, lower_redux_sync, lower_shfl_sync, lower_stmatrix,
    lower_wmma_load, lower_wmma_mma, lower_wmma_store,
};
use wgmma::{
    lower_wgmma_commit_group, lower_wgmma_fence, lower_wgmma_mma_async, lower_wgmma_wait_group,
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
        ctx.symbols.declare_param(&param.name.to_string())?;
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
/// idiom matches a window (see [`match_warp_max_sign_trick`] and
/// [`match_mbarrier_wait_loop`]). Windows span only consecutive statements.
fn lower_statements(ctx: &mut LoweringContext, stmts: &[Statement]) -> LowerResult<()> {
    let mut i = 0;
    while i < stmts.len() {
        if let Some(trick) = match_warp_max_sign_trick(ctx, &stmts[i..]) {
            // The broadcast `mov` itself still lowers normally, keeping
            // its destination defined for any other reader; only the
            // reduction trio collapses.
            lower_statement(ctx, &stmts[i])?;
            ctx.current_span = trick.span;
            ctx.emit(
                LoweredInstr::ReduxSyncBroadcastMax {
                    dst: trick.dst,
                    src: trick.src,
                    membermask: trick.membermask,
                },
                None,
            )?;
            i += WARP_MAX_SIGN_TRICK_LEN;
            continue;
        }
        if let Some(wait_loop) = match_mbarrier_wait_loop(ctx, &stmts[i..]) {
            // The label resolves to the blocking wait; the retry `bra` is
            // dropped, so waking falls through to the loop's exit.
            lower_statement(ctx, &stmts[i])?;
            ctx.current_span = statement_span(&stmts[i + 1]);
            match &wait_loop {
                MbarrierWaitLoop::Test(wait) => lower_mbarrier_test_wait(ctx, wait)?,
                MbarrierWaitLoop::Try(wait) => lower_mbarrier_try_wait(ctx, wait)?,
            }
            i += MBARRIER_WAIT_LOOP_LEN;
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
        // =========================================================================
        // Arithmetic - Add
        // =========================================================================
        ParsedInstruction::Add(add_instr) => {
            lower_add(ctx, add_instr, predicate)?;
        }

        // =========================================================================
        // Arithmetic - Sub
        // =========================================================================
        ParsedInstruction::Sub(sub) => {
            lower_sub(ctx, sub, predicate)?;
        }

        // =========================================================================
        // Arithmetic - Mul
        // =========================================================================
        ParsedInstruction::Mul(mul) => {
            lower_mul(ctx, mul, predicate)?;
        }

        // =========================================================================
        // Arithmetic - Mad (multiply-add)
        // =========================================================================
        ParsedInstruction::Mad(mad) => {
            lower_mad(ctx, mad, predicate)?;
        }

        // =========================================================================
        // Arithmetic - FMA (fused multiply-add)
        // =========================================================================
        ParsedInstruction::Fma(fma) => {
            lower_fma(ctx, fma, predicate)?;
        }

        // =========================================================================
        // Arithmetic - Div
        // =========================================================================
        ParsedInstruction::Div(div) => {
            lower_div(ctx, div, predicate)?;
        }

        // =========================================================================
        // Arithmetic - Rem
        // =========================================================================
        ParsedInstruction::Rem(rem) => {
            let dst_typed = ctx.resolve_dst_typed(&rem.dst)?;
            let src_a_typed = ctx.resolve_operand_typed(&rem.src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(&rem.src_b)?;

            ctx.check_dst_type(&dst_typed, rem.ty, "rem")?;
            ctx.check_operand_type(&src_a_typed, rem.ty, "rem")?;
            ctx.check_operand_type(&src_b_typed, rem.ty, "rem")?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op: BinOp::Rem,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: rem.ty,
                    clamp: None,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Arithmetic - Neg
        // =========================================================================
        ParsedInstruction::Neg(neg) => {
            lower_neg(ctx, neg, predicate)?;
        }

        // =========================================================================
        // Float unary - Rcp / Sqrt / Rsqrt
        // =========================================================================
        ParsedInstruction::Rcp(rcp) => {
            // rnd/ftz/approx are precision controls: floats are reals here,
            // so every reciprocal is exact and they change nothing.
            let (ty, dst, src) = match rcp {
                ast::RcpInstr::Approx {
                    ftz: _ftz,
                    ty,
                    dst,
                    src,
                } => (*ty, dst, src),
                ast::RcpInstr::Ieee {
                    rnd: _rnd,
                    ftz: _ftz,
                    ty,
                    dst,
                    src,
                } => (*ty, dst, src),
            };
            lower_float_unary(ctx, UnaryOp::Rcp, "rcp", ty, dst, src, predicate)?;
        }
        ParsedInstruction::Sqrt(sqrt) => {
            // rnd/ftz/approx are precision controls: no effect over the reals.
            let (ty, dst, src) = match sqrt {
                ast::SqrtInstr::Approx {
                    ftz: _ftz,
                    dst,
                    src,
                } => (ScalarType::F32, dst, src),
                ast::SqrtInstr::Ieee {
                    rnd: _rnd,
                    ftz: _ftz,
                    ty,
                    dst,
                    src,
                } => (*ty, dst, src),
            };
            lower_float_unary(ctx, UnaryOp::Sqrt, "sqrt", ty, dst, src, predicate)?;
        }
        ParsedInstruction::Rsqrt(rsqrt) => {
            // approx/ftz are precision controls: no effect over the reals.
            let ast::RsqrtInstr {
                approx: _approx,
                ftz: _ftz,
                ty,
                dst,
                src,
            } = rsqrt;
            lower_float_unary(ctx, UnaryOp::Rsqrt, "rsqrt", *ty, dst, src, predicate)?;
        }

        // =========================================================================
        // Transcendental - Lg2 (log2(x), evaluated as log(x) / ln2)
        // =========================================================================
        ParsedInstruction::Lg2(lg2) => {
            // approx/ftz are precision controls: no effect over the reals.
            // `lg2` is f32-only in the ISA, so there is no type to read
            // off the instruction.
            let ast::Lg2Instr {
                ftz: _ftz,
                dst,
                src,
            } = lg2;
            lower_float_unary(
                ctx,
                UnaryOp::Lg2,
                "lg2",
                ScalarType::F32,
                dst,
                src,
                predicate,
            )?;
        }

        // =========================================================================
        // Transcendental - Ex2 (2^x, evaluated as exp(x * ln2))
        // =========================================================================
        ParsedInstruction::Ex2(ex2) => {
            let (dst, src) = match ex2 {
                ast::Ex2Instr::Float32 {
                    ftz: _ftz,
                    dst,
                    src,
                } => (dst, src),
                ast::Ex2Instr::HalfF16 { .. } | ast::Ex2Instr::HalfBf16 { .. } => {
                    return Err(unsupported("ex2", "f16/bf16 packed forms"));
                }
            };
            lower_float_unary(
                ctx,
                UnaryOp::Ex2,
                "ex2",
                ScalarType::F32,
                dst,
                src,
                predicate,
            )?;
        }

        // =========================================================================
        // Transcendental - Tanh (evaluated as (e^2x - 1) / (e^2x + 1))
        // =========================================================================
        ParsedInstruction::Tanh(tanh) => {
            // .f32/.f16/.bf16 and packed .f16x2/.bf16x2 (PTX ISA Block 61)
            // are all modeled: Tanh reduces to (e^2x-1)/(e^2x+1), packed forms
            // run per lane. Anything else is invalid PTX (fail-closed check).
            if !matches!(
                tanh.ty,
                ScalarType::F32
                    | ScalarType::F16
                    | ScalarType::Bf16
                    | ScalarType::F16x2
                    | ScalarType::Bf16x2
            ) {
                return Err(unsupported("tanh", format!("{:?} (invalid PTX)", tanh.ty)));
            }
            lower_float_unary(
                ctx,
                UnaryOp::Tanh,
                "tanh",
                tanh.ty,
                &tanh.dst,
                &tanh.src,
                predicate,
            )?;
        }

        // =========================================================================
        // Arithmetic - Abs
        // =========================================================================
        ParsedInstruction::Abs(abs) => {
            lower_abs(ctx, abs, predicate)?;
        }

        // =========================================================================
        // Copysign
        // =========================================================================
        ParsedInstruction::Copysign(copysign) => {
            lower_copysign(ctx, copysign, predicate)?;
        }

        // =========================================================================
        // Arithmetic - Min/Max
        // =========================================================================
        ParsedInstruction::Min(min) => {
            lower_min(ctx, min, predicate)?;
        }
        ParsedInstruction::Max(max) => {
            lower_max(ctx, max, predicate)?;
        }

        // =========================================================================
        // Logic - And/Or/Xor
        // =========================================================================
        ParsedInstruction::And(logic)
        | ParsedInstruction::Or(logic)
        | ParsedInstruction::Xor(logic) => {
            let (op, instr_name) = match instr {
                ParsedInstruction::And(_) => (BinOp::And, "and"),
                ParsedInstruction::Or(_) => (BinOp::Or, "or"),
                ParsedInstruction::Xor(_) => (BinOp::Xor, "xor"),
                _ => unreachable!(),
            };
            let dst_typed = ctx.resolve_dst_typed(&logic.dst)?;
            let src_a_typed = ctx.resolve_operand_typed(&logic.src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(&logic.src_b)?;

            ctx.check_dst_type(&dst_typed, logic.ty, instr_name)?;
            ctx.check_operand_type(&src_a_typed, logic.ty, instr_name)?;
            ctx.check_operand_type(&src_b_typed, logic.ty, instr_name)?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: logic.ty,
                    clamp: None,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Logic - Not
        // =========================================================================
        ParsedInstruction::Not(not) => {
            let dst_typed = ctx.resolve_dst_typed(&not.dst)?;
            let src_typed = ctx.resolve_operand_typed(&not.src)?;

            ctx.check_dst_type(&dst_typed, not.ty, "not")?;
            ctx.check_operand_type(&src_typed, not.ty, "not")?;

            ctx.emit(
                LoweredInstr::UnaryOp {
                    op: UnaryOp::Not,
                    dst: dst_typed.reg,
                    src: src_typed.operand,
                    ty: not.ty,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Shift - Shl/Shr
        // =========================================================================
        ParsedInstruction::Shl(shift) | ParsedInstruction::Shr(shift) => {
            let (op, instr_name) = match instr {
                ParsedInstruction::Shl(_) => (BinOp::Shl, "shl"),
                ParsedInstruction::Shr(_) => (BinOp::Shr, "shr"),
                _ => unreachable!(),
            };
            let dst_typed = ctx.resolve_dst_typed(&shift.dst)?;
            let src_a_typed = ctx.resolve_operand_typed(&shift.src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(&shift.src_b)?;

            ctx.check_dst_type(&dst_typed, shift.ty, instr_name)?;
            ctx.check_operand_type(&src_a_typed, shift.ty, instr_name)?;
            // PTX Documentation: Shift a left by the amount specified by unsigned 32-bit value in b. <-- U32 is the type for b
            ctx.check_operand_type(&src_b_typed, ScalarType::U32, instr_name)?;

            ctx.emit(
                LoweredInstr::BinOp {
                    op,
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    ty: shift.ty,
                    clamp: None,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Shift - Shf (funnel shift)
        // =========================================================================
        ParsedInstruction::Shf(shf) => {
            // Operands stay untyped here: `lo`/`hi` are `.b32` bit-vectors
            // whose runtime value kind (plain scalar or packed f16 pair)
            // decides the semantics - see `LoweredInstr::Shf`.
            let dst = ctx.resolve_dst_typed(&shf.dst)?.reg;
            let lo = ctx.resolve_operand(&shf.lo)?;
            let hi = ctx.resolve_operand(&shf.hi)?;
            let shift = ctx.resolve_operand(&shf.shift)?;

            ctx.emit(
                LoweredInstr::Shf {
                    dst,
                    lo,
                    hi,
                    shift,
                    dir: shf.dir,
                    mode: shf.mode,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Bit Field Insert - Bfi
        // =========================================================================
        ParsedInstruction::Bfi(bfi) => {
            let dst_typed = ctx.resolve_dst_typed(&bfi.dst)?;
            let src_a_typed = ctx.resolve_operand_typed(&bfi.src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(&bfi.src_b)?;
            // start and len are typically u32 immediates or registers
            let start = ctx.resolve_operand(&bfi.start)?;
            let len = ctx.resolve_operand(&bfi.len)?;

            ctx.check_dst_type(&dst_typed, bfi.ty, "bfi")?;
            ctx.check_operand_type(&src_a_typed, bfi.ty, "bfi")?;
            ctx.check_operand_type(&src_b_typed, bfi.ty, "bfi")?;

            ctx.emit(
                LoweredInstr::Bfi {
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    start,
                    len,
                    ty: bfi.ty,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Bit Field Extract - Bfe
        // =========================================================================
        ParsedInstruction::Bfe(bfe) => {
            let dst_typed = ctx.resolve_dst_typed(&bfe.dst)?;
            let src_a_typed = ctx.resolve_operand_typed(&bfe.src_a)?;
            // start and len are typically u32 immediates or registers
            let start = ctx.resolve_operand(&bfe.start)?;
            let len = ctx.resolve_operand(&bfe.len)?;

            ctx.check_dst_type(&dst_typed, bfe.ty, "bfe")?;
            ctx.check_operand_type(&src_a_typed, bfe.ty, "bfe")?;

            ctx.emit(
                LoweredInstr::Bfe {
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    start,
                    len,
                    ty: bfe.ty,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Comparison - Setp
        // =========================================================================
        ParsedInstruction::Setp(setp) => {
            lower_setp(ctx, setp, predicate)?;
        }

        // =========================================================================
        // Selection - Selp
        // =========================================================================
        ParsedInstruction::Selp(selp) => {
            let dst_typed = ctx.resolve_dst_typed(&selp.dst)?;
            let src_a_typed = ctx.resolve_operand_typed(&selp.src_a)?;
            let src_b_typed = ctx.resolve_operand_typed(&selp.src_b)?;
            let pred_typed = ctx.resolve_operand_typed(&selp.src_c)?;

            ctx.check_dst_type(&dst_typed, selp.ty, "selp")?;
            ctx.check_operand_type(&src_a_typed, selp.ty, "selp")?;
            ctx.check_operand_type(&src_b_typed, selp.ty, "selp")?;
            // Predicate operand must be pred type
            ctx.check_operand_type(&pred_typed, ScalarType::Pred, "selp")?;

            ctx.emit(
                LoweredInstr::Selp {
                    dst: dst_typed.reg,
                    src_a: src_a_typed.operand,
                    src_b: src_b_typed.operand,
                    pred: pred_typed.operand,
                    ty: selp.ty,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Data Movement - Mov
        // =========================================================================
        ParsedInstruction::Mov(mov) => {
            match (&mov.dst, &mov.src) {
                (AstOperand::Vector(_), AstOperand::Vector(_)) => {
                    return Err(LowerError::UnsupportedInstruction {
                        instruction: format!("mov.{:?} (vector-to-vector)", mov.ty),
                        reason: Some(
                            "vector destination and vector source together are not supported"
                                .to_string(),
                        ),
                    });
                }
                (AstOperand::Vector(dst_elems), _) if dst_elems.len() == 2 => {
                    // Scalar-to-vector unpack: mov.bN {lo, hi}, src; the
                    // source's value kind is resolved at eval (`UnpackHalves`).
                    // Either half may be `_` (e.g. `mov.b64 {_, %r1}, %rd2`).
                    let resolve_half = |elem: &AstOperand| -> LowerResult<Option<RegId>> {
                        match elem {
                            AstOperand::Underscore => Ok(None),
                            other => ctx.resolve_dst(other).map(Some),
                        }
                    };
                    let lo_reg = resolve_half(&dst_elems[0])?;
                    let hi_reg = resolve_half(&dst_elems[1])?;
                    let src = ctx.resolve_operand(&mov.src)?;

                    ctx.emit(
                        LoweredInstr::UnpackHalves {
                            lo: lo_reg,
                            hi: hi_reg,
                            src,
                            ty: mov.ty,
                        },
                        predicate,
                    )?;
                }
                (AstOperand::Vector(dst_elems), _) if dst_elems.len() == 4 => {
                    // Four-lane unpack: mov.b128 {e0,e1,e2,e3}, src. Same
                    // shape as the 2-element case above, one level wider -
                    // see `UnpackQuad`. Any lane may be the `_` sink.
                    let resolve_elem = |elem: &AstOperand| -> LowerResult<Option<RegId>> {
                        match elem {
                            AstOperand::Underscore => Ok(None),
                            other => ctx.resolve_dst(other).map(Some),
                        }
                    };
                    let elems = [
                        resolve_elem(&dst_elems[0])?,
                        resolve_elem(&dst_elems[1])?,
                        resolve_elem(&dst_elems[2])?,
                        resolve_elem(&dst_elems[3])?,
                    ];
                    let src = ctx.resolve_operand(&mov.src)?;

                    ctx.emit(LoweredInstr::UnpackQuad { elems, src }, predicate)?;
                }
                (AstOperand::Vector(dst_elems), _) => {
                    return Err(LowerError::UnsupportedInstruction {
                        instruction: format!(
                            "mov.{:?} (vector unpack with {} elements)",
                            mov.ty,
                            dst_elems.len()
                        ),
                        reason: Some(
                            "only 2- and 4-element vector unpack is supported".to_string(),
                        ),
                    });
                }
                (_, AstOperand::Vector(elements)) if elements.len() == 2 => {
                    // Vector-to-scalar pack: mov.bN dst, {lo, hi}
                    // PTX ISA 9.7.9.4 semantics: d = lo | (hi << w)
                    // where w = type_bits / 2
                    let dst_typed = ctx.resolve_dst_typed(&mov.dst)?;
                    let dst = dst_typed.reg;

                    let lo = ctx.resolve_operand(&elements[0])?;
                    let hi = ctx.resolve_operand(&elements[1])?;

                    if matches!(mov.ty.bits(), 32 | 64) {
                        // Always a Value::Pair, exact for real and integer
                        // halves (see PackHalves): b32 packs f16x2/bf16x2,
                        // b64 packs f32x2 or two 32-bit integer halves.
                        ctx.emit(LoweredInstr::PackHalves { dst, lo, hi }, predicate)?;
                    } else {
                        // Any other width: plain bitwise pack.
                        let elem_width = mov.ty.bits() / 2;

                        // Step 1: dst = hi << w
                        ctx.emit(
                            LoweredInstr::BinOp {
                                op: BinOp::Shl,
                                dst,
                                src_a: hi,
                                src_b: Operand::ImmI64(elem_width as i64),
                                ty: mov.ty,
                                clamp: None,
                            },
                            predicate,
                        )?;

                        // Step 2: dst = dst | lo
                        ctx.emit(
                            LoweredInstr::BinOp {
                                op: BinOp::Or,
                                dst,
                                src_a: Operand::Reg(dst),
                                src_b: lo,
                                ty: mov.ty,
                                clamp: None,
                            },
                            predicate,
                        )?;
                    }
                }
                (_, AstOperand::Vector(elements)) if elements.len() == 4 => {
                    // Four-lane pack: mov.b128 dst, {e0,e1,e2,e3}. Always a
                    // `Value::Quad`, never a bitwise composition (see
                    // `PackQuad`).
                    let dst = ctx.resolve_dst_typed(&mov.dst)?.reg;
                    let elems = [
                        ctx.resolve_operand(&elements[0])?,
                        ctx.resolve_operand(&elements[1])?,
                        ctx.resolve_operand(&elements[2])?,
                        ctx.resolve_operand(&elements[3])?,
                    ];

                    ctx.emit(LoweredInstr::PackQuad { dst, elems }, predicate)?;
                }
                (_, AstOperand::Vector(elements)) => {
                    return Err(LowerError::UnsupportedInstruction {
                        instruction: format!(
                            "mov.{:?} (vector pack with {} elements)",
                            mov.ty,
                            elements.len()
                        ),
                        reason: Some("only 2- and 4-element vector pack is supported".to_string()),
                    });
                }
                _ => {
                    // Normal scalar mov
                    let dst_typed = ctx.resolve_dst_typed(&mov.dst)?;
                    let src_typed = ctx.resolve_operand_typed(&mov.src)?;

                    ctx.check_dst_type(&dst_typed, mov.ty, "mov")?;
                    ctx.check_operand_type(&src_typed, mov.ty, "mov")?;

                    ctx.emit(
                        LoweredInstr::Mov {
                            dst: dst_typed.reg,
                            src: src_typed.operand,
                            ty: mov.ty,
                        },
                        predicate,
                    )?;
                }
            }
        }

        // =========================================================================
        // Data Movement - Load
        // =========================================================================
        ParsedInstruction::Ld(ld) => {
            lower_load(ctx, ld, predicate)?;
        }

        // =========================================================================
        // Data Movement - Store
        // =========================================================================
        ParsedInstruction::St(st) => {
            lower_store(ctx, st, predicate)?;
        }

        // =========================================================================
        // Data Movement - Async Copy (cp.async)
        // =========================================================================
        ParsedInstruction::CpAsync(cp) => {
            lower_cp_async(ctx, cp, predicate)?;
        }

        ParsedInstruction::CpAsyncCommitGroup => {
            ctx.emit(LoweredInstr::CpAsyncCommitGroup, predicate)?;
        }

        ParsedInstruction::CpAsyncWaitGroup(wg) => {
            let n = ctx.resolve_const_u32(
                &wg.n,
                "cp.async.wait_group",
                "n must be a compile-time integer immediate",
            )?;
            ctx.emit(LoweredInstr::CpAsyncWaitGroup { n }, predicate)?;
        }

        ParsedInstruction::CpAsyncWaitAll => {
            // cp.async.wait_all is exactly cp.async.commit_group followed
            // by cp.async.wait_group 0.
            ctx.emit(LoweredInstr::CpAsyncCommitGroup, predicate)?;
            ctx.emit(LoweredInstr::CpAsyncWaitGroup { n: 0 }, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::CpAsyncMbarrierArrive,
            modifiers,
            operands,
        } => {
            lower_cp_async_mbarrier_arrive(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Data Movement - Cvt (type conversion)
        // =========================================================================
        ParsedInstruction::Cvt(cvt) => {
            lower_cvt(ctx, cvt, predicate)?;
        }

        // =========================================================================
        // Data Movement - Cvta (address conversion)
        // =========================================================================
        ParsedInstruction::Cvta(cvta) => {
            let ast::CvtaInstr {
                to_generic,
                space,
                ty: _ty, // pointer width; the identity holds at either width
                dst,
                src,
            } = cvta;
            // Only `cvta.to.global` is accepted, as the identity (global is
            // identity-mapped in the generic window). Other forms would mint
            // wrong-space or arbitrary addresses (or are unused), so reject.
            if *to_generic || *space != StateSpace::Global {
                let form = format!(
                    "cvta{}.{}",
                    if *to_generic { "" } else { ".to" },
                    format!("{:?}", space).to_lowercase()
                );
                let reason = if *space == StateSpace::Global {
                    // Necessarily the to-generic direction here.
                    "cvta.global (global -> generic) would also be the identity, \
                     but the corpus never uses it; only cvta.to.global is modeled"
                } else {
                    "only cvta.to.global is modeled (as the identity); generic \
                     addresses have no per-space windows in this model"
                };
                return Err(LowerError::UnsupportedInstruction {
                    instruction: form,
                    reason: Some(reason.to_string()),
                });
            }
            let dst = ctx.resolve_dst(dst)?;
            let src = ctx.resolve_operand(src)?;
            ctx.emit(LoweredInstr::Cvta { dst, src }, predicate)?;
        }

        ParsedInstruction::Mapa(mapa) => {
            let ast::MapaInstr {
                space,
                ty: _ty, // pointer width; the identity holds at either width
                dst,
                src,
                cta,
            } = mapa;
            if *space == ast::MapaSpace::Generic {
                return Err(unsupported(
                    "mapa",
                    "generic addressing (only mapa.shared::cluster is modeled; generic \
                     addresses have no per-space windows in this model)",
                ));
            }
            let dst = ctx.resolve_dst(dst)?;
            let src = ctx.resolve_operand(src)?;
            let rank = ctx.resolve_operand(cta)?;
            ctx.emit(LoweredInstr::Mapa { dst, src, rank }, predicate)?;
        }

        ParsedInstruction::Prmt(prmt) => {
            if prmt.mode != ast::PrmtMode::None {
                return Err(unsupported("prmt", "mode modifiers"));
            }
            let dst = ctx.resolve_dst_typed(&prmt.dst)?;
            let src_a = ctx.resolve_operand_typed(&prmt.src_a)?;
            let src_b = ctx.resolve_operand_typed(&prmt.src_b)?;
            let selector = ctx.resolve_operand(&prmt.selector)?;
            ctx.check_dst_type(&dst, ScalarType::B32, "prmt")?;
            ctx.check_operand_type(&src_a, ScalarType::B32, "prmt")?;
            ctx.check_operand_type(&src_b, ScalarType::B32, "prmt")?;
            ctx.emit(
                LoweredInstr::Prmt {
                    dst: dst.reg,
                    src_a: src_a.operand,
                    src_b: src_b.operand,
                    selector,
                },
                predicate,
            )?;
        }

        ParsedInstruction::Lop3(lop3) => {
            if lop3.bool_op.is_some() || lop3.dst_pred.is_some() || lop3.pred_q.is_some() {
                return Err(unsupported("lop3", "boolean or predicate-output modifiers"));
            }
            let dst = ctx.resolve_dst_typed(&lop3.dst)?;
            let src_a = ctx.resolve_operand_typed(&lop3.src_a)?;
            let src_b = ctx.resolve_operand_typed(&lop3.src_b)?;
            let src_c = ctx.resolve_operand_typed(&lop3.src_c)?;
            ctx.check_dst_type(&dst, ScalarType::B32, "lop3")?;
            ctx.check_operand_type(&src_a, ScalarType::B32, "lop3")?;
            ctx.check_operand_type(&src_b, ScalarType::B32, "lop3")?;
            ctx.check_operand_type(&src_c, ScalarType::B32, "lop3")?;
            ctx.emit(
                LoweredInstr::Lop3 {
                    dst: dst.reg,
                    src_a: src_a.operand,
                    src_b: src_b.operand,
                    src_c: src_c.operand,
                    lut: ctx.resolve_operand(&lop3.lut)?,
                },
                predicate,
            )?;
        }

        // =========================================================================
        // Warp Shuffle - ShflSync
        // =========================================================================
        ParsedInstruction::ShflSync(shfl) => {
            lower_shfl_sync(ctx, shfl, predicate)?;
        }

        // =========================================================================
        // Warp Election - ElectSync
        // =========================================================================
        ParsedInstruction::ElectSync(elect) => {
            lower_elect_sync(ctx, elect, predicate)?;
        }

        // =========================================================================
        // Warp Reduction - ReduxSync
        // =========================================================================
        ParsedInstruction::ReduxSync(redux) => {
            lower_redux_sync(ctx, redux, predicate)?;
        }

        // =========================================================================
        // Control Flow - Branch
        // =========================================================================
        ParsedInstruction::Bra(bra) => {
            lower_branch(ctx, bra, predicate)?;
        }

        // =========================================================================
        // Control Flow - Return/Exit
        // =========================================================================
        ParsedInstruction::Ret(ast::RetInstr {
            // .uni is a divergence hint; it does not change what ret does.
            uniform: _uniform,
        }) => {
            ctx.emit(LoweredInstr::Ret, predicate)?;
        }
        ParsedInstruction::Exit => {
            ctx.emit(LoweredInstr::Exit, predicate)?;
        }

        // =========================================================================
        // Synchronization - Bar
        // =========================================================================
        ParsedInstruction::Bar(bar) => {
            lower_bar(ctx, bar.mode, &bar.operands, predicate)?;
        }

        // `barrier{.cta}.sync{.aligned}` is `bar{.cta}.sync` per the ISA;
        // dropping `.aligned` only drops the same-textual-barrier promise,
        // which the evaluator never relied on (it matches by id and count).
        ParsedInstruction::Barrier(ast::BarrierInstr {
            // .cta is the default scope, and .aligned only adds the
            // compile-time all-threads-reach-this-barrier promise (see
            // above); neither changes the runtime semantics modeled here.
            cta: _cta,
            aligned: _aligned,
            mode,
            operands,
        }) => {
            lower_bar(ctx, *mode, operands, predicate)?;
        }

        // =========================================================================
        // Synchronization - bar.warp.sync
        // =========================================================================
        ParsedInstruction::BarWarpSync(bws) => {
            // The membermask lowers exactly like shfl.sync's: any operand
            // form, required concrete at evaluation time.
            let mask = ctx.resolve_operand(&bws.membermask)?;
            ctx.emit(LoweredInstr::BarWarpSync { mask }, predicate)?;
        }

        // =========================================================================
        // Synchronization - Membar
        // =========================================================================
        ParsedInstruction::Membar(ast::MembarInstr::Level(_)) => {
            ctx.emit(LoweredInstr::Membar, predicate)?;
        }
        ParsedInstruction::Membar(ast::MembarInstr::Proxy(_)) => {
            // TODO: implement `membar.proxy`. On sm_70+ it is a synonym for
            // `fence.proxy` (PTX ISA 9.7.15.4), so it can lower like
            // `lower_fence`'s proxy arm; on sm_60 that is an approximation.
            return Err(unsupported(
                "membar.proxy",
                "membar.proxy is not implemented yet",
            ));
        }

        // =========================================================================
        // Synchronization - fence / fence.proxy
        // =========================================================================
        ParsedInstruction::Fence(fence) => {
            lower_fence(ctx, fence, predicate)?;
        }

        // =========================================================================
        // Function call (callseq idiom for __symexpf)
        // =========================================================================
        ParsedInstruction::Call(call) => {
            lower_call(ctx, call, predicate)?;
        }

        // =========================================================================
        // Warp query - activemask
        // =========================================================================
        ParsedInstruction::Activemask(am) => {
            let dst = ctx.resolve_dst(&am.dst)?;
            ctx.emit(LoweredInstr::Activemask { dst }, predicate)?;
        }

        // =========================================================================
        // Other - NOP placeholder
        // =========================================================================
        ParsedInstruction::Brkpt => {
            ctx.emit(LoweredInstr::Nop, predicate)?;
        }
        ParsedInstruction::Trap => {
            // Reaching a trap during evaluation is an analysis error
            ctx.emit(LoweredInstr::Trap, predicate)?;
        }

        // =========================================================================
        // Other - ld.global.nc: a regular global load (coherence not modeled)
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::LdGlobalNc,
            modifiers,
            operands,
        } => {
            lower_ld_global_nc(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Tensor Core - ldmatrix.sync
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::Ldmatrix,
            modifiers,
            operands,
        } => {
            lower_ldmatrix(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Tensor Core - mma.sync
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::Mma,
            modifiers,
            operands,
        } => {
            lower_mma(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Tensor Core - wmma.load
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::WmmaLoad,
            modifiers,
            operands,
        } => {
            lower_wmma_load(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Tensor Core - wmma.store
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::WmmaStore,
            modifiers,
            operands,
        } => {
            lower_wmma_store(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Tensor Core - wmma.mma
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::WmmaMma,
            modifiers,
            operands,
        } => {
            lower_wmma_mma(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // TensorCore 5th Generation - tcgen05.alloc / .dealloc / .relinquish_alloc_permit
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Alloc,
            modifiers,
            operands,
        } => {
            lower_tcgen05_alloc(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Dealloc,
            modifiers,
            operands,
        } => {
            lower_tcgen05_dealloc(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05RelinquishAllocPermit,
            modifiers,
            operands,
        } => {
            lower_tcgen05_relinquish_alloc_permit(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Ld,
            modifiers,
            operands,
        } => {
            lower_tcgen05_ld(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05St,
            modifiers,
            operands,
        } => {
            lower_tcgen05_st(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05WaitLd,
            modifiers,
            operands,
        } => {
            lower_tcgen05_wait(ctx, modifiers, operands, predicate, false)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05WaitSt,
            modifiers,
            operands,
        } => {
            lower_tcgen05_wait(ctx, modifiers, operands, predicate, true)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Mma,
            modifiers,
            operands,
        } => {
            lower_tcgen05_mma(ctx, modifiers, operands, predicate, false)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05MmaWs,
            modifiers,
            operands,
        } => {
            lower_tcgen05_mma(ctx, modifiers, operands, predicate, true)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Fence,
            modifiers,
            operands,
        } => {
            lower_tcgen05_fence(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::Tcgen05Commit,
            modifiers,
            operands,
        } => {
            lower_tcgen05_commit(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Asynchronous Warpgroup-Level MMA (PTX ISA 9.7.17.5-7)
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::WgmmaMmaAsync,
            modifiers,
            operands,
        } => {
            lower_wgmma_mma_async(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::WgmmaFence,
            modifiers,
            operands,
        } => {
            lower_wgmma_fence(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::WgmmaCommitGroup,
            modifiers,
            operands,
        } => {
            lower_wgmma_commit_group(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::WgmmaWaitGroup,
            modifiers,
            operands,
        } => {
            lower_wgmma_wait_group(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Tensor Core - stmatrix.sync (ldmatrix's store-direction mirror)
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::Stmatrix,
            modifiers,
            operands,
        } => {
            lower_stmatrix(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Tensor maps & TMA copy (PTX ISA 5.5.8, 9.7.9.27, 9.7.9.26.5.2, 9.7.14.17)
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::TensormapReplace,
            modifiers,
            operands,
        } => {
            lower_tensormap_replace(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::TensormapCpFenceproxy,
            modifiers,
            operands,
        } => {
            lower_tensormap_cp_fenceproxy(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::FenceProxyTensormap,
            modifiers,
            operands,
        } => {
            lower_fence_proxy_tensormap(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::CpAsyncBulkTensor,
            modifiers,
            operands,
        } => {
            lower_cp_async_bulk_tensor(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::CpAsyncBulk,
            modifiers,
            operands,
        } => {
            lower_cp_async_bulk(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // Cluster launch control (PTX ISA 9.7.19)
        // =========================================================================
        ParsedInstruction::Other {
            kind: InstrKind::ClusterlaunchcontrolTryCancel,
            modifiers,
            operands,
        } => {
            lower_clc_try_cancel(ctx, modifiers, operands, predicate)?;
        }

        ParsedInstruction::Other {
            kind: InstrKind::ClusterlaunchcontrolQueryCancel,
            modifiers,
            operands,
        } => {
            lower_clc_query_cancel(ctx, modifiers, operands, predicate)?;
        }

        // =========================================================================
        // mbarrier: phased arrive/wait barriers (PTX ISA 9.7.13.15)
        // =========================================================================
        ParsedInstruction::MbarrierInit(init) => {
            lower_mbarrier_init(ctx, init, predicate)?;
        }

        ParsedInstruction::MbarrierInval(inval) => {
            lower_mbarrier_inval(ctx, inval, predicate)?;
        }

        ParsedInstruction::MbarrierArrive(arrive) => {
            lower_mbarrier_arrive(ctx, arrive, predicate)?;
        }

        ParsedInstruction::MbarrierCompleteTx(complete_tx) => {
            lower_mbarrier_complete_tx(ctx, complete_tx, predicate)?;
        }

        ParsedInstruction::MbarrierTestWait(_) => {
            return Err(LowerError::MbarrierWaitOutsideRetryLoop {
                wait: MbarrierWaitKind::TestWait,
            });
        }

        ParsedInstruction::MbarrierTryWait(_) => {
            return Err(LowerError::MbarrierWaitOutsideRetryLoop {
                wait: MbarrierWaitKind::TryWait,
            });
        }

        // =========================================================================
        // Unsupported instructions
        // =========================================================================
        _ => {
            return Err(LowerError::UnsupportedInstruction {
                instruction: format!("{:?}", instr),
                reason: Some("Instruction not yet implemented".to_string()),
            });
        }
    }

    Ok(())
}
