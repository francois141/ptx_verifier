//! Lowering of loads, stores, parameter accesses and `cp.async`.

use volta_frontend::ascii::AsciiSliceExt;
use volta_frontend::ast::{
    self, AddressBase, CpAsyncInstr, FromAscii, LdInstr, MemSemantics, Operand as AstOperand,
    ScalarType, SharedStateSpaceQualifier, StInstr, StateSpace, VecWidth,
};
use volta_frontend::instr_parse::is_cache_perf_hint;
use volta_frontend::lex::DottedIdent;

use crate::lowered::{CpAsyncSrcSize, LoweredInstr, MemSpace, Predicate, UnaryOp};

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

    // Param-space loads read either a kernel parameter or a block-scope
    // `.param` slot (the callseq idiom); both are handled symbolically
    // rather than as memory accesses.
    if *space == Some(StateSpace::Param) {
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
