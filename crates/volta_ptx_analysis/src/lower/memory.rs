//! Lowering of data movement: `mov`, loads, stores, parameter accesses,
//! `cvta`, `mapa` and `cp.async`.

use crate::frontend::ascii::AsciiSliceExt;
use crate::frontend::ast::{
    self, AddressBase, CpAsyncInstr, CpAsyncWaitGroupInstr, CvtaInstr, FromAscii, LdInstr,
    MapaInstr, MemSemantics, MovInstr, Operand as AstOperand, ScalarType,
    SharedStateSpaceQualifier, StInstr, StateSpace, VecWidth,
};
use crate::frontend::instr_parse::is_cache_perf_hint;
use crate::frontend::lex::DottedIdent;

use crate::ir::symbols::{PARAM_GENERIC_BASE, ParamLayout, RegId, SHARED_GENERIC_BASE};
use crate::ir::{BinOp, CpAsyncSrcSize, LoweredInstr, MemSpace, Operand, Predicate, UnaryOp};

use super::context::{LocalParamSlot, LoweringContext, unsupported};
use super::error::{LowerError, LowerResult};

/// Check `ld`/`st` ordering/system qualifiers. `.weak` (default) is modeled;
/// `.volatile` (morally strong, ISA §8.4.2) is treated as weak too, which can
/// only add reported races, never hide one. Anything else is rejected.
fn check_mem_access_qualifiers(
    instruction: &str,
    semantics: MemSemantics,
    scope: Option<ast::MemScope>,
    space_qualifier: Option<ast::StateSpaceQualifier>,
    mmio: bool,
) -> LowerResult<()> {
    match semantics {
        MemSemantics::Weak | MemSemantics::Volatile => {}
        MemSemantics::Relaxed | MemSemantics::Acquire | MemSemantics::Release => {
            return Err(unsupported(
                instruction,
                format!(
                    "memory-ordering qualifier {:?} (atomic protocols are not modeled)",
                    semantics
                ),
            ));
        }
    }
    if let Some(scope) = scope {
        return Err(unsupported(
            instruction,
            format!("memory scope qualifier {:?}", scope),
        ));
    }
    if let Some(q) = space_qualifier {
        return Err(unsupported(
            instruction,
            format!("::-qualified state space ({:?})", q),
        ));
    }
    if mmio {
        return Err(unsupported(instruction, ".mmio modifier"));
    }
    Ok(())
}

/// Check that the `.vN` width modifier and the operand shape agree; the
/// emitted access width is taken from the operand's register list, so a
/// mismatch would silently access the wrong number of elements.
fn check_vec_arity(
    instruction: &str,
    vec: Option<VecWidth>,
    operand: &AstOperand,
) -> LowerResult<()> {
    let ok = match (vec, operand) {
        (Some(v), AstOperand::Vector(elements)) => v.count() as usize == elements.len(),
        (Some(_), _) => false,
        (None, AstOperand::Vector(elements)) => elements.len() == 1,
        (None, _) => true,
    };
    if ok {
        Ok(())
    } else {
        Err(LowerError::InvalidOperand {
            instruction: instruction.to_string(),
            operand: format!("{:?}", operand),
            reason: "the .vN width modifier must match the vector operand's register count",
        })
    }
}

pub(super) fn lower_mov(
    ctx: &mut LoweringContext,
    mov: &MovInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    match (&mov.dst, &mov.src) {
        (AstOperand::Vector(_), AstOperand::Vector(_)) => {
            return Err(LowerError::UnsupportedInstruction {
                instruction: format!("mov.{:?} (vector-to-vector)", mov.ty),
                reason: Some(
                    "vector destination and vector source together are not supported".to_string(),
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
                reason: Some("only 2- and 4-element vector unpack is supported".to_string()),
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
                // Exact for real and integer halves (see PackHalves): b32
                // packs f16x2/bf16x2, b64 packs f32x2, two 32-bit integer
                // halves or two f16x2 words.
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
    Ok(())
}

pub(super) fn lower_load(
    ctx: &mut LoweringContext,
    ld: &LdInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // Destructure exhaustively so a new field cannot be dropped silently.
    let LdInstr {
        semantics,
        scope,
        space,
        space_qualifier,
        // Cache-behavior hints only; the loaded value is unaffected.
        cache_op: _cache_op,
        vec,
        // ld.global.nc: hardware may return stale data if the kernel breaks
        // the read-only contract; Volta returns the fresh value (a kernel
        // that breaks the contract is garbage-in).
        nc: _nc,
        mmio,
        unified,
        ty,
        dst,
        addr,
    } = ld;
    check_mem_access_qualifiers("ld", *semantics, *scope, *space_qualifier, *mmio)?;
    if *unified {
        return Err(unsupported("ld", ".unified modifier"));
    }

    // A block-scope `.param` slot (the callseq idiom) or a scalar kernel
    // parameter read by name is a value binding; any other param-space load
    // (an aggregate's bytes, or through a register) reads param memory.
    if *space == Some(StateSpace::Param) && reads_param_by_value(ctx, addr) {
        return lower_param_load(ctx, ld, predicate);
    }

    // Resolve the address operand
    let (base, offset) = match addr {
        AstOperand::Address(addr) => {
            let base = ctx.resolve_address(addr)?;
            let offset = ctx.get_address_offset(addr);
            (base, offset)
        }
        _ => {
            let base = ctx.resolve_operand(addr)?;
            (base, 0)
        }
    };

    let space = ctx.convert_space(*space, "ld")?;
    let instr_name = format!("ld.{:?}", ty);
    check_vec_arity("ld", *vec, dst)?;

    // Check if destination is a vector (e.g., {%f1, %f2, %f3, %f4})
    match dst {
        AstOperand::Vector(_) => {
            // Vector load - emit LoadVec
            // For vectors, we'd need to check each element, but for now just resolve
            let dst_regs = ctx.resolve_dst_vector(dst)?;
            ctx.emit(
                LoweredInstr::LoadVec {
                    dst: dst_regs,
                    space,
                    base,
                    offset,
                    ty: *ty,
                },
                predicate,
            )?;
        }
        _ => {
            // Single register load - use relaxed type checking (PTX 9.4.1)
            // Destination can be wider than instruction type (value is extended)
            let dst_typed = ctx.resolve_dst_typed(dst)?;
            ctx.check_dst_type_relaxed(&dst_typed, *ty, &instr_name)?;

            ctx.emit(
                LoweredInstr::Load {
                    dst: dst_typed.reg,
                    space,
                    base,
                    offset,
                    ty: *ty,
                },
                predicate,
            )?;
        }
    }
    Ok(())
}

pub(super) fn lower_store(
    ctx: &mut LoweringContext,
    st: &StInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // Destructure exhaustively so a new field cannot be dropped silently.
    let StInstr {
        semantics,
        scope,
        space,
        space_qualifier,
        // Cache-behavior hints only; the stored value is unaffected.
        cache_op: _cache_op,
        vec,
        mmio,
        ty,
        addr,
        src,
    } = st;
    check_mem_access_qualifiers("st", *semantics, *scope, *space_qualifier, *mmio)?;

    // Param-space stores write a block-scope `.param` slot (callseq idiom)
    if *space == Some(StateSpace::Param) {
        return lower_param_store(ctx, st, predicate);
    }

    // Resolve the address operand
    let (base, offset) = match addr {
        AstOperand::Address(addr) => {
            let base = ctx.resolve_address(addr)?;
            let offset = ctx.get_address_offset(addr);
            (base, offset)
        }
        _ => {
            let base = ctx.resolve_operand(addr)?;
            (base, 0)
        }
    };

    let space = ctx.convert_space(*space, "st")?;
    let instr_name = format!("st.{:?}", ty);
    check_vec_arity("st", *vec, src)?;

    // Check if source is a vector (e.g., {%f1, %f2, %f3, %f4})
    if let AstOperand::Vector(_) = src {
        let src_ops = ctx.resolve_operand_vector(src)?;
        ctx.emit(
            LoweredInstr::StoreVec {
                space,
                base,
                offset,
                src: src_ops,
                ty: *ty,
            },
            predicate,
        )?;
        return Ok(());
    }

    // Single register store - use relaxed type checking (PTX 9.4.1)
    // Source can be wider than instruction type (value is truncated)
    let src_typed = ctx.resolve_operand_typed(src)?;
    ctx.check_operand_type_relaxed(&src_typed, *ty, &instr_name)?;

    ctx.emit(
        LoweredInstr::Store {
            space,
            base,
            offset,
            src: src_typed.operand,
            ty: *ty,
        },
        predicate,
    )?;
    Ok(())
}

/// Lower `cp.async`: `dst` is always `.shared` and `src` always `.global`
/// (checked by the parser), so `LoweredInstr::CpAsync` carries no `MemSpace`
/// and eval hardcodes the two spaces.
pub(super) fn lower_cp_async(
    ctx: &mut LoweringContext,
    cp: &CpAsyncInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let CpAsyncInstr {
        cache_op: _cache_op,
        dst_qualifier,
        dst,
        src,
        cp_size,
        extra,
    } = cp;

    // `::cluster` (distributed shared memory) is not modeled.
    if *dst_qualifier != SharedStateSpaceQualifier::Cta {
        return Err(unsupported(
            "cp.async",
            format!(
                "shared::{dst_qualifier} (only the executing CTA's own shared memory is modeled)"
            ),
        ));
    }

    let (dst_base, dst_offset) = match dst {
        AstOperand::Address(addr) => (ctx.resolve_address(addr)?, ctx.get_address_offset(addr)),
        _ => (ctx.resolve_operand(dst)?, 0),
    };
    let (src_base, src_offset) = match src {
        AstOperand::Address(addr) => (ctx.resolve_address(addr)?, ctx.get_address_offset(addr)),
        _ => (ctx.resolve_operand(src)?, 0),
    };

    let cp_size = ctx.resolve_const_u32(
        cp_size,
        "cp.async",
        "cp-size must be a compile-time immediate (4, 8, or 16)",
    )?;
    if !matches!(cp_size, 4 | 8 | 16) {
        return Err(LowerError::InvalidOperand {
            instruction: "cp.async".to_string(),
            operand: format!("{}", cp_size),
            reason: "cp-size must be 4, 8, or 16",
        });
    }

    // The optional 4th operand is `src-size` (integer: partial real bytes, rest
    // zero-filled) or `ignore-src` (predicate: all zero-filled); like the ISA,
    // tell them apart by the resolved operand's register class, not position.
    let src_size = match extra {
        None => CpAsyncSrcSize::Full,
        Some(op) => {
            let resolved = ctx.resolve_operand_typed(op)?;
            if resolved.ty == Some(ScalarType::Pred) {
                CpAsyncSrcSize::IgnoreSrc(resolved.operand)
            } else {
                CpAsyncSrcSize::Sized(resolved.operand)
            }
        }
    };

    ctx.emit(
        LoweredInstr::CpAsync {
            dst_base,
            dst_offset,
            src_base,
            src_offset,
            cp_size,
            src_size,
        },
        predicate,
    )
}

pub(super) fn lower_cp_async_wait_group(
    ctx: &mut LoweringContext,
    wg: &CpAsyncWaitGroupInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let n = ctx.resolve_const_u32(
        &wg.n,
        "cp.async.wait_group",
        "n must be a compile-time integer immediate",
    )?;
    ctx.emit(LoweredInstr::CpAsyncWaitGroup { n }, predicate)?;
    Ok(())
}

pub(super) fn lower_cp_async_wait_all(
    ctx: &mut LoweringContext,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // cp.async.wait_all is exactly cp.async.commit_group followed
    // by cp.async.wait_group 0.
    ctx.emit(LoweredInstr::CpAsyncCommitGroup, predicate)?;
    ctx.emit(LoweredInstr::CpAsyncWaitGroup { n: 0 }, predicate)?;
    Ok(())
}

/// Extract the `(symbol, offset)` of a param-space address like `[param0+0]`.
fn param_addr_symbol(ctx: &LoweringContext, addr: &AstOperand) -> LowerResult<(String, i64)> {
    if let AstOperand::Address(addr) = addr
        && let AddressBase::Symbol(name) = &addr.base
    {
        return Ok((name.to_string(), ctx.get_address_offset(addr)));
    }
    Err(LowerError::UnsupportedInstruction {
        instruction: "param-space access".to_string(),
        reason: Some("param accesses must use a symbol base address".to_string()),
    })
}

/// Whether `ld.param [addr]` names a callseq `.param` slot or a scalar kernel parameter.
fn reads_param_by_value(ctx: &LoweringContext, addr: &AstOperand) -> bool {
    let AstOperand::Address(address) = addr else {
        return false;
    };
    let AddressBase::Symbol(name) = &address.base else {
        return false;
    };
    let name = name.to_string();
    ctx.local_params.contains_key(&name)
        || ctx
            .symbols
            .get_param(&name)
            .is_some_and(|id| ctx.symbols.param_slot(id).layout == ParamLayout::Scalar)
}

/// Lower `ld.param`: kernel parameters become `LoadParam`; block-scope
/// `.param` slots (callseq idiom) collapse to the deferred call result.
fn lower_param_load(
    ctx: &mut LoweringContext,
    ld: &LdInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let (name, offset) = param_addr_symbol(ctx, &ld.addr)?;
    let dst = ctx.resolve_dst(&ld.dst)?;

    // Block-scope `.param` slot (callseq idiom)?
    if let Some(slot) = ctx.local_params.get(&name).copied() {
        if offset != 0 {
            return Err(LowerError::UnsupportedInstruction {
                instruction: format!("ld.param [{}+{}]", name, offset),
                reason: Some(".param slots are scalar; nonzero offsets unsupported".to_string()),
            });
        }
        if predicate.is_some() {
            return Err(LowerError::UnsupportedInstruction {
                instruction: format!("ld.param [{}]", name),
                reason: Some("predicated callseq accesses are not supported".to_string()),
            });
        }
        return match slot {
            LocalParamSlot::PendingExp(src) => ctx.emit(
                LoweredInstr::UnaryOp {
                    op: UnaryOp::Exp,
                    dst,
                    src,
                    ty: ld.ty,
                },
                None,
            ),
            LocalParamSlot::Stored(src) => ctx.emit(
                LoweredInstr::Mov {
                    dst,
                    src,
                    ty: ld.ty,
                },
                None,
            ),
            LocalParamSlot::Empty => Err(LowerError::UnsupportedInstruction {
                instruction: format!("ld.param [{}]", name),
                reason: Some("read of a .param slot that was never written".to_string()),
            }),
        };
    }

    // Kernel parameter
    let Some(param_id) = ctx.symbols.get_param(&name) else {
        return Err(LowerError::UndefinedSymbol { name });
    };
    if offset != 0 {
        return Err(LowerError::UnsupportedInstruction {
            instruction: format!("ld.param [{}+{}]", name, offset),
            reason: Some("param loads with nonzero offsets are not supported".to_string()),
        });
    }
    ctx.emit(LoweredInstr::LoadParam { dst, param_id }, predicate)
}

/// Lower `st.param`: records the stored operand in a block-scope `.param`
/// slot for the following `call`. Emits no instruction.
fn lower_param_store(
    ctx: &mut LoweringContext,
    st: &StInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    if predicate.is_some() {
        return Err(LowerError::UnsupportedInstruction {
            instruction: "st.param".to_string(),
            reason: Some("predicated callseq accesses are not supported".to_string()),
        });
    }
    let (name, offset) = param_addr_symbol(ctx, &st.addr)?;
    if offset != 0 {
        return Err(LowerError::UnsupportedInstruction {
            instruction: format!("st.param [{}+{}]", name, offset),
            reason: Some(".param slots are scalar; nonzero offsets unsupported".to_string()),
        });
    }
    if !ctx.local_params.contains_key(&name) {
        return Err(LowerError::UndefinedSymbol { name });
    }
    let src = ctx.resolve_operand(&st.src)?;
    ctx.local_params.insert(name, LocalParamSlot::Stored(src));
    Ok(())
}

pub(super) fn lower_cvta(
    ctx: &mut LoweringContext,
    cvta: &CvtaInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    let ast::CvtaInstr {
        to_generic,
        space,
        ty,
        dst,
        src,
    } = cvta;
    // Generic loads and stores stay rejected, so a generic shared or param
    // address is only arithmetic between conversions (or a TMA tensor-map
    // operand); its window keeps that exact.
    let window = match space {
        StateSpace::Shared if *ty == ScalarType::U64 => Some(SHARED_GENERIC_BASE),
        StateSpace::Param if *ty == ScalarType::U64 => Some(PARAM_GENERIC_BASE),
        _ => None,
    };
    if let Some(window) = window {
        let dst = ctx.resolve_dst(dst)?;
        let src = ctx.resolve_operand(src)?;
        // Each window starts above the 32 bits of its space's offsets, shifted to
        // its base: to generic adds the base, back to the space subtracts it.
        let op = if *to_generic { BinOp::Add } else { BinOp::Sub };
        let instr = LoweredInstr::BinOp {
            op,
            dst,
            src_a: src,
            src_b: Operand::ImmU64(window),
            ty: ScalarType::U64,
            clamp: None,
        };
        return ctx.emit(instr, predicate);
    }
    // Otherwise only `cvta.to.global` is accepted, as the identity (global
    // is identity-mapped in the generic window). Other forms would mint
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
            "only cvta.to.global (the identity) and cvta{.to}.{shared,param}.u64 \
             (generic windows at `SHARED_GENERIC_BASE`, `PARAM_GENERIC_BASE`) are modeled"
        };
        return Err(LowerError::UnsupportedInstruction {
            instruction: form,
            reason: Some(reason.to_string()),
        });
    }
    let dst = ctx.resolve_dst(dst)?;
    let src = ctx.resolve_operand(src)?;
    ctx.emit(LoweredInstr::Cvta { dst, src }, predicate)?;
    Ok(())
}

pub(super) fn lower_mapa(
    ctx: &mut LoweringContext,
    mapa: &MapaInstr,
    predicate: Option<Predicate>,
) -> LowerResult<()> {
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
    Ok(())
}

/// Lower ld.global.nc (non-coherent global load)
/// Treat as regular global load - we don't model cache coherence
pub(super) fn lower_ld_global_nc(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    // Exhaustive modifier handling: anything we don't recognize is rejected
    // by name rather than skipped.
    let mut elem_type: Option<ScalarType> = None;
    let mut vec: Option<VecWidth> = None;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier {
            // Cache performance hints are accepted and ignored, like plain
            // ld/st; anything else qualified (notably L2::cache_hint, which
            // needs an unparsed cache-policy operand) is rejected by name.
            if is_cache_perf_hint(parts) {
                continue;
            }
            return Err(unsupported(
                "ld.global.nc",
                format!("modifier .{}", modifier),
            ));
        }
        let mod_ascii = modifier.to_ascii_string();
        match mod_ascii.as_bytes() {
            // Cache-operation hints: cache behavior only.
            b"ca" | b"cg" | b"cs" | b"lu" | b"cv" => {}
            _ => {
                if let Some(v) = VecWidth::from_ascii(&mod_ascii) {
                    vec = Some(v);
                } else if let Some(ty) = ScalarType::from_ascii(&mod_ascii) {
                    elem_type = Some(ty);
                } else {
                    return Err(unsupported(
                        "ld.global.nc",
                        format!("modifier .{}", modifier),
                    ));
                }
            }
        }
    }

    let elem_type =
        elem_type.ok_or_else(|| unsupported("ld.global.nc", "missing type modifier"))?;

    // Operands: [destination, address]
    if operands.len() != 2 {
        return Err(LowerError::InvalidOperand {
            instruction: "ld.global.nc".to_string(),
            operand: format!("{:?}", operands),
            reason: "expected destination and address operands",
        });
    }

    let dst_operand = &operands[0];
    let addr_operand = &operands[1];
    check_vec_arity("ld.global.nc", vec, dst_operand)?;

    // Resolve address
    let (base, offset) = match addr_operand {
        AstOperand::Address(addr) => {
            let base = ctx.resolve_address(addr)?;
            let offset = ctx.get_address_offset(addr);
            (base, offset)
        }
        _ => {
            let base = ctx.resolve_operand(addr_operand)?;
            (base, 0)
        }
    };

    // Check if destination is a vector
    match dst_operand {
        AstOperand::Vector(_) => {
            // Vector load
            let dst_regs = ctx.resolve_dst_vector(dst_operand)?;
            ctx.emit(
                LoweredInstr::LoadVec {
                    dst: dst_regs,
                    space: MemSpace::Global,
                    base,
                    offset,
                    ty: elem_type,
                },
                predicate,
            )?;
        }
        _ => {
            // Single register load
            let dst = ctx.resolve_dst(dst_operand)?;
            ctx.emit(
                LoweredInstr::Load {
                    dst,
                    space: MemSpace::Global,
                    base,
                    offset,
                    ty: elem_type,
                },
                predicate,
            )?;
        }
    }

    Ok(())
}

/// Lower `cp.async.mbarrier.arrive{.noinc}{.shared{::cta}}.b64 [addr]` (PTX
/// ISA 9.7.9.24.5): make the `mbarrier` at `addr` track completion of all
/// prior `cp.async` operations of the executing thread.
pub(super) fn lower_cp_async_mbarrier_arrive(
    ctx: &mut LoweringContext,
    modifiers: &[DottedIdent],
    operands: &[AstOperand],
    predicate: Option<Predicate>,
) -> LowerResult<()> {
    const NAME: &str = "cp.async.mbarrier.arrive";
    let mut noinc = false;
    let mut saw_b64 = false;

    for modifier in modifiers {
        if let DottedIdent::Qualified(parts) = modifier
            && let [base, sub] = parts.as_slice()
            && base.as_slice().as_bytes() == b"shared"
        {
            match SharedStateSpaceQualifier::from_ascii(sub.as_slice()) {
                Some(SharedStateSpaceQualifier::Cta) => continue,
                _ => return Err(unsupported(NAME, format!("modifier .shared::{sub}"))),
            }
        }
        match modifier.to_string().as_str() {
            "noinc" => noinc = true,
            "shared" => {}
            "b64" => saw_b64 = true,
            other => return Err(unsupported(NAME, format!("modifier .{other}"))),
        }
    }
    if !saw_b64 {
        return Err(unsupported(NAME, "missing .b64 modifier"));
    }

    let [AstOperand::Address(addr)] = operands else {
        return Err(LowerError::InvalidOperand {
            instruction: NAME.to_string(),
            operand: format!("{:?}", operands),
            reason: "expected a single [addr] operand",
        });
    };
    let addr_base = ctx.resolve_address(addr)?;
    let addr_offset = ctx.get_address_offset(addr);

    ctx.emit(
        LoweredInstr::CpAsyncMbarrierArrive {
            addr_base,
            addr_offset,
            noinc,
        },
        predicate,
    )?;
    Ok(())
}
