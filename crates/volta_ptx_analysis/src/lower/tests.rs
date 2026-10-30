use crate::frontend::ascii::AsciiString;
use crate::frontend::ast::{self, Operand as AstOperand, ScalarType};
use id_collections::Id;

use crate::ir::symbols::SpecialRegKind;
use crate::ir::tcgen05::Tcgen05LdStShape;
use crate::ir::tensor_map::TensorLoadMode;
use crate::ir::{Clamp, CpAsyncSrcSize, InstrId, LoweredInstr, LoweredProgram, Operand};

use super::context::LoweringContext;
use super::error::{LowerError, LowerResult, MbarrierWaitKind};
use super::lower_function;

/// Helper to convert &str to AsciiString for tests
fn ascii(s: &str) -> AsciiString {
    AsciiString::try_from(s.to_string()).unwrap()
}

#[test]
fn test_lowering_context_creation() {
    let ctx = LoweringContext::new();
    assert_eq!(ctx.current_pc(), InstrId::from_index(0));
    assert!(ctx.instructions.is_empty());
}

#[test]
fn test_label_recording() {
    let mut ctx = LoweringContext::new();
    ctx.record_label("LOOP");
    ctx.emit(LoweredInstr::Nop, None).unwrap();

    assert_eq!(
        ctx.symbols.resolve_label("LOOP", ctx.label_scope),
        Some(InstrId::from_index(0))
    );
}

#[test]
fn test_special_register_from_name() {
    // Test that special registers can be resolved from their names
    assert_eq!(
        SpecialRegKind::from_name("%tid.x"),
        Some(SpecialRegKind::TidX)
    );
    assert_eq!(
        SpecialRegKind::from_name("tid.x"),
        Some(SpecialRegKind::TidX)
    );
    assert_eq!(
        SpecialRegKind::from_name("%laneid"),
        Some(SpecialRegKind::LaneId)
    );
    assert!(SpecialRegKind::from_name("unknown").is_none());
}

// =========================================================================
// Type Checking Tests
// =========================================================================

/// Helper to create a context with declared registers
fn ctx_with_registers(regs: &[(&str, ScalarType)]) -> LoweringContext {
    let mut ctx = LoweringContext::new();
    for (name, ty) in regs {
        ctx.symbols.declare_register(name, *ty, 1).unwrap();
    }
    ctx
}

#[test]
fn test_type_check_exact_match() {
    // Register declared as u32, used with add.u32 - should succeed
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U32)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type(&dst, ScalarType::U32, "add.u32");
    assert!(result.is_ok());
}

#[test]
fn test_type_check_signed_unsigned_compatible() {
    // Register declared as s32, used with add.u32 - should succeed (compatible)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::S32)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type(&dst, ScalarType::U32, "add.u32");
    assert!(
        result.is_ok(),
        "s32 should be compatible with u32 instruction"
    );
}

#[test]
fn test_type_check_bits_compatible_with_any() {
    // Register declared as b32, used with add.f32 - should succeed (bits compatible)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::B32)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type(&dst, ScalarType::F32, "add.f32");
    assert!(
        result.is_ok(),
        "b32 should be compatible with f32 instruction"
    );
}

#[test]
fn test_type_check_float_int_incompatible() {
    // Register declared as f32, used with add.u32 - should FAIL
    let ctx = ctx_with_registers(&[("%f0", ScalarType::F32)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%f0")))
        .unwrap();
    let result = ctx.check_dst_type(&dst, ScalarType::U32, "add.u32");
    assert!(
        result.is_err(),
        "f32 should NOT be compatible with u32 instruction"
    );

    // Verify error message contains useful information
    let err = result.unwrap_err();
    let msg = format!("{}", err);
    assert!(
        msg.contains("Type error"),
        "Error should mention type error"
    );
    assert!(msg.contains("%f0"), "Error should mention register name");
}

#[test]
fn test_type_check_size_mismatch() {
    // Register declared as u64, used with add.u32 - should FAIL (size mismatch)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U64)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type(&dst, ScalarType::U32, "add.u32");
    assert!(
        result.is_err(),
        "u64 should NOT be compatible with u32 instruction (size mismatch)"
    );
}

#[test]
fn test_type_check_immediates_are_polymorphic() {
    // Immediates should be compatible with any instruction type
    let ctx = ctx_with_registers(&[]);

    let imm = ctx.resolve_operand_typed(&AstOperand::ImmInt(42)).unwrap();

    // Should work with u32
    assert!(
        ctx.check_operand_type(&imm, ScalarType::U32, "add.u32")
            .is_ok()
    );
    // Should work with f32
    assert!(
        ctx.check_operand_type(&imm, ScalarType::F32, "add.f32")
            .is_ok()
    );
    // Should work with s64
    assert!(
        ctx.check_operand_type(&imm, ScalarType::S64, "add.s64")
            .is_ok()
    );
}

// =========================================================================
// Relaxed Type Checking Tests (PTX 9.4.1)
// =========================================================================

#[test]
fn test_relaxed_load_wider_dest_ok() {
    // ld.u8 into u32 register - should succeed (value is zero-extended)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U32)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type_relaxed(&dst, ScalarType::U8, "ld.u8");
    assert!(
        result.is_ok(),
        "Loading u8 into u32 register should be allowed"
    );
}

#[test]
fn test_relaxed_load_same_size_ok() {
    // ld.u32 into u32 register - should succeed
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U32)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type_relaxed(&dst, ScalarType::U32, "ld.u32");
    assert!(result.is_ok());
}

#[test]
fn test_relaxed_load_narrower_dest_fails() {
    // ld.u32 into u8 register - should FAIL (dest too narrow)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U8)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type_relaxed(&dst, ScalarType::U32, "ld.u32");
    assert!(result.is_err(), "Loading u32 into u8 register should fail");
}

#[test]
fn test_relaxed_load_float_int_still_incompatible() {
    // ld.f32 into u64 register - should FAIL (float/int mismatch)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U64)]);

    let dst = ctx
        .resolve_dst_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_dst_type_relaxed(&dst, ScalarType::F32, "ld.f32");
    assert!(
        result.is_err(),
        "Loading f32 into integer register should fail even with relaxed checking"
    );
}

#[test]
fn test_relaxed_store_wider_source_ok() {
    // st.u8 from u32 register - should succeed (value is truncated)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U32)]);

    let src = ctx
        .resolve_operand_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_operand_type_relaxed(&src, ScalarType::U8, "st.u8");
    assert!(
        result.is_ok(),
        "Storing from u32 register to u8 should be allowed (truncation)"
    );
}

#[test]
fn test_relaxed_store_narrower_source_fails() {
    // st.u32 from u8 register - should FAIL (source too narrow)
    let ctx = ctx_with_registers(&[("%r0", ScalarType::U8)]);

    let src = ctx
        .resolve_operand_typed(&AstOperand::Ident(ascii("%r0")))
        .unwrap();
    let result = ctx.check_operand_type_relaxed(&src, ScalarType::U32, "st.u32");
    assert!(
        result.is_err(),
        "Storing from u8 register to u32 should fail"
    );
}

// =========================================================================
// Special Register Type Tests
// =========================================================================

#[test]
fn test_special_reg_type_resolution() {
    let ctx = ctx_with_registers(&[]);

    // %tid.x is u32
    let tid = ctx
        .resolve_operand_typed(&AstOperand::Ident(ascii("%tid.x")))
        .unwrap();
    assert_eq!(tid.ty, Some(ScalarType::U32));

    // Should be compatible with u32 instruction
    assert!(
        ctx.check_operand_type(&tid, ScalarType::U32, "add.u32")
            .is_ok()
    );

    // Should NOT be compatible with f32 instruction
    assert!(
        ctx.check_operand_type(&tid, ScalarType::F32, "add.f32")
            .is_err()
    );
}

// =========================================================================
// Hint Generation Tests
// =========================================================================

#[test]
fn test_hint_for_float_to_int() {
    let ctx = ctx_with_registers(&[]);
    let hint = ctx.type_mismatch_hint(ScalarType::F32, ScalarType::U32);
    assert!(hint.contains("cvt"), "Hint should suggest cvt instruction");
}

#[test]
fn test_hint_for_int_to_float() {
    let ctx = ctx_with_registers(&[]);
    let hint = ctx.type_mismatch_hint(ScalarType::S32, ScalarType::F32);
    assert!(hint.contains("cvt"), "Hint should suggest cvt instruction");
}

#[test]
fn test_hint_for_size_mismatch() {
    let ctx = ctx_with_registers(&[]);
    let hint = ctx.type_mismatch_hint(ScalarType::U64, ScalarType::U32);
    assert!(
        hint.contains("bits") || hint.contains("size"),
        "Hint should mention size mismatch"
    );
}

// =========================================================================
// Exhaustive-lowering policy: unmodeled forms error naming the modifier.
// =========================================================================

// =========================================================================
// Shared memory layout: the extern window goes after all statics (CUDA ABI).
// =========================================================================

/// Parse `src` as a full module and lower its entry, passing module-level
/// variable declarations through as the driver does.
fn lower_module_src(src: &str) -> LoweredProgram {
    use crate::frontend::ascii::AsAscii;
    use crate::frontend::parse::Parser;

    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    let module = Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error));
    let vars: Vec<ast::VarDecl> = module
        .items
        .iter()
        .filter_map(|item| match item {
            ast::TopLevelItem::Variable(v) => Some(v.clone()),
            _ => None,
        })
        .collect();
    let func = module
        .items
        .iter()
        .find_map(|item| match item {
            ast::TopLevelItem::Entry(f) => Some(f),
            _ => None,
        })
        .expect("kernel not found");
    lower_function(func, &vars).expect("lowering failed")
}

#[test]
fn test_extern_shared_window_follows_static_shared() {
    let program = lower_module_src(
        ".version 8.6\n.target sm_100a\n.address_size 64\n\n\
         .extern .shared .align 16 .b8 buf[];\n\
         .visible .entry k()\n{\n\
         .reg .b32 %r<4>;\n\
         .shared .align 4 .f32 lut[64];\n\
         ret;\n}\n",
    );
    // The static packs from 0; the extern window is disjoint, after it.
    let lut = program.symbols.get_shared_var("lut").unwrap();
    assert_eq!((lut.offset, lut.size_bytes), (0, 256));
    let buf = program.symbols.get_shared_var("buf").unwrap();
    assert!(buf.is_extern);
    assert_eq!(buf.offset, 256);
    assert_eq!(program.symbols.extern_shared_base(), Some(256));
}

/// Extern-only modules (every extern-shared kernel in the corpus) keep
/// the window at offset 0: behavior identical to before the fix.
#[test]
fn test_extern_only_shared_window_at_zero() {
    let program = lower_module_src(
        ".version 8.6\n.target sm_100a\n.address_size 64\n\n\
         .extern .shared .align 16 .b8 buf[];\n\
         .visible .entry k()\n{\n\
         .reg .b32 %r<4>;\n\
         ret;\n}\n",
    );
    assert_eq!(program.symbols.get_shared_var("buf").unwrap().offset, 0);
    assert_eq!(program.symbols.extern_shared_base(), Some(0));
}

/// `%` is a conventional register prefix, not a requirement (`.reg .b64
/// xp;` then `[xp]`), so lowering must check the register table before
/// treating a bare name as an undefined symbol.
#[test]
fn test_address_base_register_without_percent_prefix() {
    let program = lower_module_src(
        ".version 8.6\n.target sm_100a\n.address_size 64\n\n\
         .visible .entry k(.param .u64 x_ptr)\n{\n\
         .reg .b64 xp;\n\
         .reg .f32 %f<2>;\n\
         ld.param.u64 xp, [x_ptr];\n\
         ld.global.f32 %f1, [xp];\n\
         ret;\n}\n",
    );
    let reg = program
        .symbols
        .get_register("xp")
        .expect("xp should resolve as a register, not an undefined symbol");
    // Both `ld` instructions should reference the same register id -
    // one written as a destination, the other read as an address base.
    assert!(program.instructions.values().any(|instr| matches!(
        instr,
        LoweredInstr::Load { base: Operand::Reg(id), .. } if *id == reg.id
    )));
}

/// Parse and lower a kernel whose body is `body`, with a standard set of
/// registers declared.
fn lower_body(body: &str) -> LowerResult<LoweredProgram> {
    use crate::frontend::ascii::AsAscii;
    use crate::frontend::parse::Parser;

    let src = format!(
        ".version 8.6\n.target sm_100a\n.address_size 64\n\n\
         .visible .entry k()\n{{\n\
         .reg .pred %p<4>;\n\
         .reg .b16 %rs<8>;\n\
         .reg .f32 %f<8>;\n\
         .reg .b32 %r<8>;\n\
         .reg .f64 %fd<4>;\n\
         .reg .b64 %rd<8>;\n\
         .reg .b128 %q<4>;\n\
         .shared .align 4 .b8 smem[64];\n\
         {}\n\
         ret;\n}}\n",
        body
    );
    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    let module = Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error));
    let func = module
        .items
        .iter()
        .find_map(|item| match item {
            ast::TopLevelItem::Entry(f) => Some(f),
            _ => None,
        })
        .expect("kernel not found");
    lower_function(func, &[])
}

/// Assert that `body` is rejected with an UnsupportedInstruction whose
/// reason mentions `needle`.
fn assert_rejected(body: &str, needle: &str) {
    match lower_body(body) {
        Err(LowerError::UnsupportedInstruction {
            instruction,
            reason,
        }) => {
            let text = format!("{} {}", instruction, reason.unwrap_or_default());
            assert!(
                text.contains(needle),
                "expected rejection of {:?} to mention {:?}, got {:?}",
                body,
                needle,
                text
            );
        }
        Err(other) => panic!(
            "expected UnsupportedInstruction for {:?}, got {:?}",
            body, other
        ),
        Ok(_) => panic!("expected {:?} to be rejected, but it lowered", body),
    }
}

fn assert_lowers(body: &str) {
    if let Err(e) = lower_body(body) {
        panic!("expected {:?} to lower, got {:?}", body, e);
    }
}

#[test]
fn test_clusterlaunchcontrol_try_cancel_forms() {
    assert_lowers(
        "clusterlaunchcontrol.try_cancel.async.shared::cta.mbarrier::complete_tx::bytes.b128 [%r1], [%r2];",
    );
    assert_rejected(
        "clusterlaunchcontrol.try_cancel.async.shared::cta.mbarrier::complete_tx::bytes.multicast::cluster::all.b128 [%r1], [%r2];",
        "only the executing CTA is modeled",
    );
    assert_rejected(
        "clusterlaunchcontrol.try_cancel.async.mbarrier::complete_tx::bytes.b128 [%r1], [%r2];",
        "only .async.shared::cta.mbarrier::complete_tx::bytes.b128 is modeled",
    );
}

#[test]
fn test_clusterlaunchcontrol_query_cancel_forms() {
    assert_lowers("clusterlaunchcontrol.query_cancel.is_canceled.pred.b128 %p1, %q1;");
    assert_lowers("clusterlaunchcontrol.query_cancel.get_first_ctaid::y.b32.b128 %r1, %q1;");
    assert_lowers(
        "clusterlaunchcontrol.query_cancel.get_first_ctaid.v4.b32.b128 {%r1, %r2, _, _}, %q1;",
    );
    for body in [
        "clusterlaunchcontrol.query_cancel.is_canceled.pred.b128 %r1, %q1;",
        "clusterlaunchcontrol.query_cancel.is_canceled.pred.b128 %p1, %rd1;",
        "clusterlaunchcontrol.query_cancel.get_first_ctaid::x.b32.b128 %rd1, %q1;",
        "clusterlaunchcontrol.query_cancel.get_first_ctaid.v4.b32.b128 {%r1, %r2}, %q1;",
    ] {
        assert!(
            matches!(lower_body(body), Err(LowerError::InvalidOperand { .. })),
            "expected {body:?} to be an invalid operand"
        );
    }
    assert_rejected(
        "clusterlaunchcontrol.query_cancel.get_first_ctaid::w.b32.b128 %r1, %q1;",
        "get_first_ctaid::w",
    );
}

#[test]
fn test_wgmma_is_not_supported() {
    for (mnemonic, body) in [
        ("wgmma.fence", "wgmma.fence.sync.aligned;"),
        ("wgmma.commit_group", "wgmma.commit_group.sync.aligned;"),
        ("wgmma.wait_group", "wgmma.wait_group.sync.aligned 0;"),
        (
            "wgmma.mma_async",
            "wgmma.mma_async.sync.aligned.m64n8k16.f32.f16.f16 \
             {%f1, %f2, %f3, %f4}, %rd1, %rd2, 1, 1, 1, 0, 0;",
        ),
        (
            "wgmma.mma_async.sp",
            "wgmma.mma_async.sp.sync.aligned.m64n8k32.f32.f16.f16 \
             {%f1, %f2, %f3, %f4}, %rd1, %rd2, %r1, 0, 1, 1, 1, 0, 0;",
        ),
    ] {
        assert_rejected(
            body,
            &format!("{mnemonic} wgmma is not supported by Volta at the moment"),
        );
    }
}

#[test]
fn test_redux_sync_is_not_supported() {
    for body in [
        "redux.sync.add.u32 %r1, %r2, 0xffffffff;",
        "mov.b32 %r2, {%rs1, %rs1};\n\
         redux.sync.max.s32 %r1, %r2, 0xffffffff;\n\
         setp.lt.s32 %p1, %r1, 0;\n\
         @%p1 redux.sync.min.s32 %r1, %r2, 0xffffffff;",
    ] {
        assert_rejected(
            body,
            "redux.sync redux.sync is not supported by Volta at the moment",
        );
    }
}

/// Lower `body` (which must contain exactly one clamp-capable
/// instruction - BinOp/Fma/Cvt) and return that instruction's clamp.
fn lowered_clamp(body: &str) -> Option<Clamp> {
    let prog =
        lower_body(body).unwrap_or_else(|e| panic!("expected {:?} to lower, got {:?}", body, e));
    let mut clamps = prog.instructions.values().filter_map(|instr| match instr {
        LoweredInstr::BinOp { clamp, .. }
        | LoweredInstr::Fma { clamp, .. }
        | LoweredInstr::Cvt { clamp, .. } => Some(*clamp),
        _ => None,
    });
    let clamp = clamps
        .next()
        .unwrap_or_else(|| panic!("no clamp-capable instruction lowered from {:?}", body));
    assert!(
        clamps.next().is_none(),
        "expected exactly one clamp-capable instruction in {:?}",
        body
    );
    clamp
}

#[test]
fn test_reject_setp_bool_combine_and_dual_dest() {
    assert_rejected("setp.lt.and.s32 %p1, %r1, %r2, %p2;", "boolean-combine");
    assert_rejected("setp.lt.s32 %p1|%p2, %r1, %r2;", "dual predicate");
    assert_lowers("setp.lt.s32 %p1, %r1, %r2;");
    assert_lowers("setp.leu.f32 %p1, %f1, %f2;");
}

#[test]
fn test_reject_integer_sat() {
    assert_rejected("add.sat.s32 %r1, %r2, %r3;", ".sat");
    assert_rejected("sub.sat.s32 %r1, %r2, %r3;", ".sat");
    assert_rejected("mad.hi.sat.s32 %r1, %r2, %r3, %r4;", ".sat");
    assert_lowers("add.s32 %r1, %r2, %r3;");
    assert_lowers("mad.lo.s32 %r1, %r2, %r3, %r4;");
}

#[test]
fn test_float_sat_lowers_with_clamp() {
    // Float `.sat` is the exact value clamp min(max(x, 0), 1) over the
    // reals; f32 and scalar f16 forms carry it through lowering.
    assert_eq!(
        lowered_clamp("add.sat.f32 %f1, %f2, %f3;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("sub.rn.ftz.sat.f32 %f1, %f2, %f3;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("mul.sat.f32 %f1, %f2, %f3;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("fma.rn.sat.f32 %f1, %f2, %f3, %f4;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("add.rn.sat.f16 %rs1, %rs2, %rs3;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("sub.rn.sat.f16 %rs1, %rs2, %rs3;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("mul.rn.sat.f16 %rs1, %rs2, %rs3;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("fma.rn.sat.f16 %rs1, %rs2, %rs3, %rs4;"),
        Some(Clamp::Sat)
    );
    // Rounding modes and ftz alone are ignorable under the reals model,
    // and unclamped forms stay unclamped.
    assert_eq!(lowered_clamp("add.rn.ftz.f32 %f1, %f2, %f3;"), None);
    assert_eq!(lowered_clamp("mul.rn.f32 %f1, %f2, %f3;"), None);
    assert_eq!(lowered_clamp("fma.rn.ftz.f32 %f1, %f2, %f3, %f4;"), None);
    assert_eq!(lowered_clamp("mul.f16 %rs1, %rs2, %rs3;"), None);
}

#[test]
fn test_float_sat_out_of_scope_forms_stay_rejected() {
    // mad.f and the mixed-precision (.f32.f16) arms are not modeled
    // with .sat.
    assert_rejected("mad.sat.f32 %f1, %f2, %f3, %f4;", ".sat");
    assert_rejected("add.rn.sat.f32.f16 %f1, %rs2, %rs3;", ".sat");
    assert_rejected("fma.rn.sat.f32.f16 %f1, %rs2, %rs3, %f4;", ".sat");
    // f16x2 .sat is a legal, modeled form (each lane clamped
    // independently) - not one of the out-of-scope forms this test
    // covers; see test_packed_f16x2_bf16x2_arithmetic_lowers.
    assert_lowers("add.rn.sat.f16x2 %r1, %r2, %r3;");
    // `.sat` on .f64 add/mul/fma is illegal PTX (the ISA allows it on
    // .f32/.f16 only); the instruction parser rejects it loudly.
    assert_rejected("add.rn.sat.f64 %fd1, %fd2, %fd3;", "parsing failed");
    assert_rejected("mul.rn.sat.f64 %fd1, %fd2, %fd3;", "parsing failed");
    assert_rejected("fma.rn.sat.f64 %fd1, %fd2, %fd3, %fd4;", "parsing failed");
}

#[test]
fn test_fma_half_relu_lowers_oob_rejected() {
    // fma.rn.relu.f16 is the exact value clamp max(x, 0).
    assert_eq!(
        lowered_clamp("fma.rn.relu.f16 %rs1, %rs2, %rs3, %rs4;"),
        Some(Clamp::Relu)
    );
    assert_eq!(lowered_clamp("fma.rn.f16 %rs1, %rs2, %rs3, %rs4;"), None);
    assert_rejected("fma.rn.oob.f16 %rs1, %rs2, %rs3, %rs4;", ".oob");
    assert_rejected("fma.rn.relu.bf16 %rs1, %rs2, %rs3, %rs4;", ".relu");
}

#[test]
fn test_reject_mad_hi_wide_widths_still_lower() {
    // mad.hi at 64 bits lowers but is rejected at evaluation (interp.rs);
    // mad.hi at 32 bits is fully supported.
    assert_lowers("mad.hi.u32 %r1, %r2, %r3, %r4;");
}

#[test]
fn test_reject_minmax_modifiers() {
    // `.NaN` is exact over the reals (no input is NaN), so it lowers.
    assert_lowers("min.NaN.f32 %f1, %f2, %f3;");
    assert_lowers("max.NaN.f32 %f1, %f2, %f3;");
    assert_lowers("max.ftz.NaN.f32 %f1, %f2, %f3;");
    assert_rejected("max.xorsign.abs.f32 %f1, %f2, %f3;", ".xorsign.abs");
    assert_rejected("min.abs.f32 %f1, %f2, %f3;", ".abs");
    assert_rejected("max.ftz.f32 %f1, %f2, %f3, %f4;", "3-input");
    assert_rejected("min.relu.s32 %r1, %r2, %r3;", ".relu");
    assert_lowers("min.f32 %f1, %f2, %f3;");
    assert_lowers("max.s32 %r1, %r2, %r3;");
    assert_lowers("min.ftz.f32 %f1, %f2, %f3;");
}

#[test]
fn test_cvt_float_sat_relu_lower_with_clamp() {
    // Float->float cvt `.sat`/`.relu` are exact value clamps; the
    // fused-ReLU epilogue nvcc emits is `cvt.rn.relu.f16.f32`.
    assert_eq!(
        lowered_clamp("cvt.rn.relu.f16.f32 %rs1, %f1;"),
        Some(Clamp::Relu)
    );
    assert_eq!(
        lowered_clamp("cvt.rn.relu.bf16.f32 %rs1, %f1;"),
        Some(Clamp::Relu)
    );
    assert_eq!(
        lowered_clamp("cvt.rn.sat.f16.f32 %rs1, %f1;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("cvt.rn.sat.f32.f64 %f1, %fd1;"),
        Some(Clamp::Sat)
    );
    assert_eq!(
        lowered_clamp("cvt.sat.f64.f32 %fd1, %f1;"),
        Some(Clamp::Sat)
    );
    assert_eq!(lowered_clamp("cvt.rn.f16.f32 %rs1, %f1;"), None);
}

#[test]
fn test_reject_cvt_modifiers_keep_plain_conversions() {
    // Integer-destination saturation is a different operation (clamp to
    // MININT..MAXINT) and stays rejected, as do non-float sources.
    assert_rejected("cvt.sat.u32.f32 %r1, %f1;", ".sat");
    assert_rejected("cvt.rn.sat.f16.s32 %rs1, %r1;", ".sat");
    // .sat/.relu destinations outside the ISA's legal lists are invalid.
    assert_rejected("cvt.rn.sat.bf16.f32 %rs1, %f1;", ".sat");
    assert_rejected("cvt.rn.relu.f32.f16 %f1, %rs1;", ".relu");
    // .satfinite clamps to the destination's finite range: not modeled.
    assert_rejected("cvt.rn.satfinite.f16.f32 %rs1, %f1;", ".satfinite");
    // Integer rounding stays rejected, including under an accepted clamp.
    assert_rejected("cvt.rmi.f32.f32 %f1, %f2;", "integer-rounding");
    assert_rejected("cvt.rzi.s32.f32 %r1, %f1;", "integer-rounding");
    assert_rejected("cvt.rzi.sat.f32.f32 %f1, %f2;", "integer-rounding");
    // cvt.pack has its own InstrKind (CvtPack) with no lowering: it hits
    // the already-loud whole-instruction catch-all. The CvtInstr::Pack
    // rejection in lower_cvt is fail-closed insurance behind it.
    assert_rejected("cvt.pack.sat.u16.s32 %r1, %r2, %r3;", "CvtPack");
    // The corpus-hot conversions must keep lowering.
    assert_lowers("cvt.rn.f16.f32 %rs1, %f1;");
    assert_lowers("cvt.f32.f16 %f1, %rs1;");
    assert_lowers("cvt.u64.u32 %rd1, %r1;");
    assert_lowers("cvt.s64.s32 %rd1, %r1;");
    assert_lowers("cvt.u32.u64 %r1, %rd1;");
}

#[test]
fn test_reject_packed_simd_arithmetic() {
    // Packed 16-bit integer arithmetic has no eval-side lane dispatch
    // (only f16x2/bf16x2 do - see test_packed_f16x2_bf16x2_arithmetic_lowers)
    // and stays rejected.
    assert_rejected("add.u16x2 %r1, %r2, %r3;", "packed SIMD");
    assert_rejected("min.s16x2 %r1, %r2, %r3;", "packed SIMD");
    assert_rejected("max.u16x2 %r1, %r2, %r3;", "packed SIMD");
}

#[test]
fn test_packed_f16x2_bf16x2_arithmetic_lowers() {
    // f16x2/bf16x2 arithmetic computes each Value::Pair lane at eval, so
    // these lower instead of hitting check_packed_arithmetic's rejection.
    assert_lowers("add.rn.f16x2 %r1, %r2, %r3;");
    assert_lowers("sub.rn.bf16x2 %r1, %r2, %r3;");
    assert_lowers("mul.rn.f16x2 %r1, %r2, %r3;");
    assert_lowers("min.f16x2 %r1, %r2, %r3;");
    assert_lowers("max.bf16x2 %r1, %r2, %r3;");
    assert_lowers("neg.ftz.f16x2 %r1, %r2;");
    assert_lowers("abs.f16x2 %r1, %r2;");
    assert_lowers("fma.rn.f16x2 %r1, %r2, %r3, %r4;");
    assert_lowers("fma.rn.relu.f16x2 %r1, %r2, %r3, %r4;");
    assert_lowers("fma.rn.bf16x2 %r1, %r2, %r3, %r4;");
    // Packed single precision (sm_100+) lives in 64-bit registers and
    // is evaluated per lane like the half-precision pairs.
    assert_lowers("add.f32x2 %rd1, %rd2, %rd3;");
    assert_lowers("add.rn.ftz.f32x2 %rd1, %rd2, %rd3;");
    assert_lowers("sub.f32x2 %rd1, %rd2, %rd3;");
    assert_lowers("mul.rn.f32x2 %rd1, %rd2, %rd3;");
    assert_lowers("fma.rn.f32x2 %rd1, %rd2, %rd3, %rd4;");
    assert_lowers("fma.rn.ftz.f32x2 %rd1, %rd2, %rd3, %rd4;");
}

#[test]
fn test_tanh_all_isa_types_lower() {
    // .f32/.f16/.bf16 (scalar) and .f16x2/.bf16x2 (packed) are all
    // the ISA offers for tanh.approx and all modeled.
    assert_lowers("tanh.approx.f32 %f1, %f2;");
    assert_lowers("tanh.approx.f16 %rs1, %rs2;");
    assert_lowers("tanh.approx.bf16 %rs1, %rs2;");
    assert_lowers("tanh.approx.f16x2 %r1, %r2;");
    assert_lowers("tanh.approx.bf16x2 %r1, %r2;");
    // Not a legal tanh type per the ISA - fail-closed insurance since
    // the parser itself doesn't restrict the type.
    assert_rejected("tanh.approx.f64 %fd1, %fd2;", "invalid PTX");
}

#[test]
fn test_mov_vector_destination_unpack() {
    // The unpack direction (vector destination): mov.b32 {lo, hi}, src -
    // the mirror image of the already-supported pack direction (vector
    // source) tested via test_mov_vector_source_pack below.
    assert_lowers("mov.b32 {%rs1, %rs2}, %r1;");
    assert_lowers("mov.b64 {%r1, %r2}, %rd1;");
    assert_lowers("mov.b128 {%f1, %f2, %f3, %f4}, %q1;");
    // Other arities and vector-to-vector mov stay unsupported - no
    // faithful model, and the corpus never emits either.
    assert_rejected(
        "mov.b32 {%rs1, %rs2, %rs3}, %r1;",
        "vector unpack with 3 elements",
    );
    assert_rejected(
        "mov.b32 {%rs1, %rs2}, {%rs3, %rs4};",
        "vector destination and vector source together",
    );
}

#[test]
fn test_mov_vector_source_pack() {
    // The pack direction (vector source): mov.b32 dst, {lo, hi}.
    assert_lowers("mov.b32 %r1, {%rs1, %rs2};");
    assert_lowers("mov.b64 %rd1, {%r1, %r2};");
    assert_lowers("mov.b128 %q1, {%r1, %r2, %r3, %r4};");
    assert_rejected(
        "mov.b32 %r1, {%rs1, %rs2, %rs3};",
        "vector pack with 3 elements",
    );
}

#[test]
fn test_cvt_pack_halves_lowers() {
    assert_lowers("cvt.rn.f16x2.f32 %r1, %f1, %f2;");
    assert_lowers("cvt.rn.bf16x2.f32 %r1, %f1, %f2;");
    // Integer/stochastic/rna rounding aren't compatible with the
    // identity-over-reals policy, same as the Standard cvt path.
    assert_rejected("cvt.rni.f16x2.f32 %r1, %f1, %f2;", "integer-rounding");
    assert_rejected("cvt.rs.f16x2.f32 %r1, %f1, %f2;", ".rs stochastic-rounding");
}

#[test]
fn test_bar_rejections() {
    assert_rejected("bar.red 0;", "bar.red");
    // The full bar.red form fails earlier, at instruction parsing (the
    // .popc reduction op modifier is not parsed) - also loud.
    assert_rejected("bar.red.popc.u32 %r1, 0, %p1;", "parsing failed");
    // An arrival that names no thread count has no meaning.
    assert_rejected("bar.arrive 0;", "missing thread-count");
    match lower_body("bar.sync;") {
        Err(LowerError::InvalidOperand { .. }) => {}
        other => panic!("expected InvalidOperand for a missing id, got {:?}", other),
    }
    assert_lowers("bar.sync 0;");
    assert_lowers("bar.sync 1;");
    // Counted barriers and a register id: the id's range is checked
    // at evaluation time, where a register's value is known (so an
    // out-of-range immediate id lowers here too).
    assert_lowers("bar.sync 0, 64;");
    assert_lowers("bar.arrive 0, 64;");
    assert_lowers("bar.sync %r1;");
    assert_lowers("bar.sync 16;");
    // One arrival count per barrier id, checked here so the evaluator
    // can take a barrier's count from any arrival at it.
    assert_lowers("bar.sync 0, 64;\n    bar.arrive 0, 64;\n    bar.sync 1, 128;");
    assert_rejected("bar.sync 0, 64;\n    bar.sync 0, 128;", "too restrictive");
    assert_rejected("bar.sync 0;\n    bar.sync 0, 64;", "too restrictive");
    assert_rejected(
        "bar.sync %r1, 64;\n    bar.sync %r2, 128;",
        "too restrictive",
    );
    // A register count is only known at eval, which pins it there.
    assert_lowers("bar.sync 0, %r1;");
    assert_lowers("bar.sync 0, 64;\n    bar.sync 0, %r1;\n    bar.arrive %r2, %r3;");
}

#[test]
fn test_reject_generic_ld_st() {
    assert_rejected("ld.u32 %r1, [%rd1];", "generic");
    assert_rejected("st.u32 [%rd1], %r1;", "generic");
    assert_lowers("ld.global.u32 %r1, [%rd1];");
    assert_lowers("ld.volatile.shared.f32 %f1, [%r1];");
    assert_lowers("st.volatile.shared.u32 [%r1], %r2;");
    assert_lowers("ld.global.nc.f32 %f1, [%rd1];");
    assert_lowers("ld.global.nc.v4.u32 {%r1, %r2, %r3, %r4}, [%rd1];");
}

#[test]
fn test_reject_ld_ordering_qualifiers() {
    assert_rejected("ld.acquire.gpu.global.u32 %r1, [%rd1];", "memory-ordering");
    assert_rejected("st.release.gpu.global.u32 [%rd1], %r1;", "memory-ordering");
}

#[test]
fn test_cache_perf_hints_accepted_cache_hint_rejected() {
    // Eviction-priority and prefetch-size qualifiers are pure
    // performance hints with no extra operand; they are accepted and
    // ignored on ld, st, and ld.global.nc alike.
    assert_lowers("ld.global.L2::128B.f32 %f1, [%rd1];");
    assert_lowers("ld.global.L1::evict_last.L2::evict_first.u32 %r1, [%rd1];");
    assert_lowers("ld.global.L1::no_allocate.L2::256B.f32 %f1, [%rd1];");
    assert_lowers("st.global.L1::evict_first.f32 [%rd1], %f1;");
    assert_lowers("st.global.L2::evict_last.u32 [%rd1], %r1;");
    assert_lowers("ld.global.nc.L1::evict_unchanged.L2::64B.f32 %f1, [%rd1];");
    // L2::cache_hint requires a cache-policy operand we do not parse;
    // it must stay rejected on every path, not be skipped as a hint.
    assert_rejected(
        "ld.global.L2::cache_hint.f32 %f1, [%rd1];",
        "QualifiedModifier",
    );
    assert_rejected(
        "st.global.L2::cache_hint.f32 [%rd1], %f1;",
        "QualifiedModifier",
    );
    assert_rejected("ld.global.nc.L2::cache_hint.f32 %f1, [%rd1];", "cache_hint");
    // Spellings outside the spec's exact ld/st enumeration (L2 has no
    // no_allocate) stay rejected too.
    assert_rejected(
        "ld.global.L2::no_allocate.f32 %f1, [%rd1];",
        "QualifiedModifier",
    );
    assert_rejected(
        "ld.global.nc.L2::no_allocate.f32 %f1, [%rd1];",
        "no_allocate",
    );
}

#[test]
fn test_ldmatrix_modifier_whitelist() {
    assert_rejected(
        "ldmatrix.sync.aligned.x4.m8n16.shared.b16 {%r1, %r2, %r3, %r4}, [%r5];",
        "m8n16",
    );
    assert_rejected(
        "ldmatrix.sync.aligned.x4.m8n8.shared.b8 {%r1, %r2, %r3, %r4}, [%r5];",
        "b8",
    );
    assert_lowers("ldmatrix.sync.aligned.x4.m8n8.shared.b16 {%r1, %r2, %r3, %r4}, [%r5];");
    assert_lowers("ldmatrix.sync.aligned.x2.m8n8.trans.shared.b16 {%r1, %r2}, [%r5];");
    // `::cta` lowers the same as unqualified `.shared`.
    assert_lowers("ldmatrix.sync.aligned.x4.m8n8.shared::cta.b16 {%r1, %r2, %r3, %r4}, [%r5];");
    // `::cluster` is not modeled and must be rejected loudly.
    assert_rejected(
        "ldmatrix.sync.aligned.x4.m8n8.shared::cluster.b16 {%r1, %r2, %r3, %r4}, [%r5];",
        "shared::cluster",
    );
}

#[test]
fn test_wmma_requires_space_and_f32_accumulators() {
    // No state space modifier -> generic addressing, rejected.
    assert_rejected(
        "wmma.load.a.sync.aligned.row.m16n16k16.f16 \
         {%r0, %r1, %r2, %r3, %r4, %r5, %r6, %r7}, [%r1], %r2;",
        "state space",
    );
    // .f16 accumulator fragments have a different layout.
    assert_rejected(
        "wmma.load.c.sync.aligned.row.m16n16k16.shared.f16 \
         {%r0, %r1, %r2, %r3}, [%r1], %r2;",
        "accumulator",
    );
    assert_rejected(
        "wmma.store.d.sync.aligned.row.m16n16k16.shared.f16 \
         [%r1], {%r0, %r1, %r2, %r3}, %r2;",
        "accumulator",
    );
    // The corpus forms still lower.
    assert_lowers(
        "wmma.load.a.sync.aligned.row.m16n16k16.shared.f16 \
         {%r0, %r1, %r2, %r3, %r4, %r5, %r6, %r7}, [%r1], %r2;",
    );
    assert_lowers(
        "wmma.store.d.sync.aligned.row.m16n16k16.shared.f32 \
         [%r1], {%f0, %f1, %f2, %f3, %f4, %f5, %f6, %f7}, %r2;",
    );
    assert_lowers(
        "wmma.mma.sync.aligned.row.col.m16n16k16.f32.f32 \
         {%f0, %f1, %f2, %f3, %f4, %f5, %f6, %f7}, \
         {%r0, %r1, %r2, %r3, %r4, %r5, %r6, %r7}, \
         {%r0, %r1, %r2, %r3, %r4, %r5, %r6, %r7}, \
         {%f0, %f1, %f2, %f3, %f4, %f5, %f6, %f7};",
    );
}

#[test]
fn test_mma_type_combination_checked() {
    assert_rejected(
        "mma.sync.aligned.m16n8k16.row.col.f32.f16.bf16.f32 \
         {%f0, %f1, %f2, %f3}, {%r0, %r1, %r2, %r3}, {%r0, %r1}, {%f0, %f1, %f2, %f3};",
        "f32.f16.f16.f32",
    );
    for types in ["f32.f16.f16.f32", "f32.bf16.bf16.f32"] {
        assert_lowers(&format!(
            "mma.sync.aligned.m16n8k16.row.col.{types} \
             {{%f0, %f1, %f2, %f3}}, {{%r0, %r1, %r2, %r3}}, {{%r0, %r1}}, {{%f0, %f1, %f2, %f3}};"
        ));
    }
}

#[test]
fn test_vector_arity_must_match_modifier() {
    match lower_body("ld.global.v4.u32 {%r1, %r2}, [%rd1];") {
        Err(LowerError::InvalidOperand { .. }) => {}
        other => panic!(
            "expected InvalidOperand for v4/2-reg mismatch, got {:?}",
            other
        ),
    }
    assert_lowers("ld.global.v2.u32 {%r1, %r2}, [%rd1];");
    assert_lowers("st.shared.v4.u32 [%r1], {%r2, %r3, %r4, %r5};");

    // Vectors of size 1 are allowed for scalar load/stores
    assert_lowers("ld.global.b32 {%r1}, [%rd1];");
    assert_lowers("st.global.b32 [%rd1], {%r1};");
}

#[test]
fn test_cp_async_lowering() {
    let prog = lower_body("cp.async.cg.shared.global [smem+4], [%rd0], 16;").expect("should lower");
    let smem_base = prog.symbols.get_shared_var("smem").unwrap().offset as u64;
    let mut found = false;
    for instr in prog.instructions.values() {
        if let LoweredInstr::CpAsync {
            dst_base,
            dst_offset,
            src_base,
            src_offset,
            cp_size,
            src_size,
        } = instr
        {
            assert_eq!(*dst_base, Operand::ImmU64(smem_base));
            assert_eq!(*dst_offset, 4);
            assert_eq!(*src_offset, 0);
            assert_eq!(*cp_size, 16);
            assert!(matches!(src_size, CpAsyncSrcSize::Full));
            let _ = src_base;
            found = true;
        }
    }
    assert!(found, "expected a lowered CpAsync instruction");

    // A general-purpose register 4th operand is `src-size`.
    let prog =
        lower_body("cp.async.ca.shared.global [smem], [%rd0], 16, %r0;").expect("should lower");
    let src_size = prog
        .instructions
        .values()
        .find_map(|i| match i {
            LoweredInstr::CpAsync { src_size, .. } => Some(src_size.clone()),
            _ => None,
        })
        .expect("expected a lowered CpAsync instruction");
    assert!(
        matches!(src_size, CpAsyncSrcSize::Sized(Operand::Reg(_))),
        "expected Sized(reg), got {:?}",
        src_size
    );

    // A predicate register 4th operand is `ignore-src`.
    let prog =
        lower_body("cp.async.ca.shared.global [smem], [%rd0], 16, %p0;").expect("should lower");
    let src_size = prog
        .instructions
        .values()
        .find_map(|i| match i {
            LoweredInstr::CpAsync { src_size, .. } => Some(src_size.clone()),
            _ => None,
        })
        .expect("expected a lowered CpAsync instruction");
    assert!(
        matches!(src_size, CpAsyncSrcSize::IgnoreSrc(Operand::Reg(_))),
        "expected IgnoreSrc(reg), got {:?}",
        src_size
    );

    match lower_body("cp.async.ca.shared.global [smem], [%rd0], 5;") {
        Err(LowerError::InvalidOperand { .. }) => {}
        other => panic!("expected InvalidOperand for cp-size=5, got {:?}", other),
    }

    let prog = lower_body("cp.async.commit_group;\ncp.async.wait_group 3;\ncp.async.wait_all;")
        .expect("should lower");
    let kinds: Vec<&LoweredInstr> = prog.instructions.values().collect();
    assert_eq!(
        kinds
            .iter()
            .filter(|i| matches!(i, LoweredInstr::CpAsyncCommitGroup))
            .count(),
        2,
        "expected one explicit commit_group plus one from wait_all: {:?}",
        kinds
    );
    assert!(
        kinds
            .iter()
            .any(|i| matches!(i, LoweredInstr::CpAsyncWaitGroup { n: 3 })),
        "missing CpAsyncWaitGroup{{n: 3}}: {:?}",
        kinds
    );
    assert!(
        kinds
            .iter()
            .any(|i| matches!(i, LoweredInstr::CpAsyncWaitGroup { n: 0 })),
        "missing CpAsyncWaitGroup{{n: 0}} from wait_all: {:?}",
        kinds
    );
}

#[test]
fn test_cp_async_shared_cta_qualifier() {
    // Unqualified `.shared` and `::cta` must lower identically.
    fn cp_async_dst(prog: &LoweredProgram) -> (Operand, i64) {
        prog.instructions
            .values()
            .find_map(|i| match i {
                LoweredInstr::CpAsync {
                    dst_base,
                    dst_offset,
                    ..
                } => Some((dst_base.clone(), *dst_offset)),
                _ => None,
            })
            .expect("expected a lowered CpAsync instruction")
    }
    let plain =
        lower_body("cp.async.cg.shared.global [smem+4], [%rd0], 16;").expect("should lower");
    let qualified = lower_body("cp.async.cg.shared::cta.global [smem+4], [%rd0], 16;")
        .expect("shared::cta should lower the same as shared");
    assert_eq!(cp_async_dst(&plain), cp_async_dst(&qualified));

    // `::cluster` parses fine but is rejected at lowering, not silently
    // misread as plain `.shared`.
    assert_rejected(
        "cp.async.cg.shared::cluster.global [smem+4], [%rd0], 16;",
        "shared::cluster",
    );
}

/// The retry loop becomes one unpredicated blocking wait: the retry `bra`
/// is gone.
#[test]
fn test_mbarrier_wait_loop_lowers_to_one_blocking_wait() {
    for wait in ["try_wait", "test_wait"] {
        let prog = lower_body(&format!(
            "WAIT:\n\
             mbarrier.{wait}.parity.acquire.cta.shared::cta.b64 %p1, [smem], %r1;\n\
             @!%p1 bra WAIT;"
        ))
        .unwrap_or_else(|e| panic!("{wait}: {e:?}"));
        let wait_pc = InstrId::from_index(0);
        assert!(
            matches!(
                prog.instructions.values().collect::<Vec<_>>().as_slice(),
                [LoweredInstr::MbarrierWaitParity { .. }, LoweredInstr::Ret]
            ),
            "{wait}: {:?}",
            prog.instructions
        );
        assert!(prog.predicate(wait_pc).is_none(), "{wait}");
    }
}

/// A bare `expect_tx` is an announcement of its own, in every spelling the ISA gives it.
#[test]
fn test_mbarrier_expect_tx_lowers_to_an_announcement() {
    for instr in [
        "mbarrier.expect_tx.shared::cta.b64 [smem], 16;",
        "mbarrier.expect_tx.relaxed.cta.shared.b64 [smem], %r1;",
    ] {
        let prog = lower_body(instr).unwrap_or_else(|e| panic!("{instr}: {e:?}"));
        assert!(
            matches!(
                prog.instructions.values().collect::<Vec<_>>().as_slice(),
                [LoweredInstr::MbarrierExpectTx { .. }, LoweredInstr::Ret]
            ),
            "{instr}: {:?}",
            prog.instructions
        );
    }
}

/// Any wait outside the exact `L: wait; @!p bra L;` window is rejected,
/// including CUTLASS's `@p bra DONE; bra L;` spelling of the same loop.
#[test]
fn test_mbarrier_wait_outside_the_retry_loop_is_rejected() {
    fn assert_rejected_wait(body: &str, expected: MbarrierWaitKind) {
        match lower_body(body) {
            Err(LowerError::MbarrierWaitOutsideRetryLoop { wait }) => {
                assert_eq!(wait, expected, "{body:?}")
            }
            other => panic!("expected {body:?} to be rejected as a wait, got {other:?}"),
        }
    }
    let wait = "mbarrier.try_wait.parity.shared::cta.b64 %p1, [smem], 0;";
    for body in [
        wait.to_string(),
        format!("WAIT:\nadd.u32 %r1, %r1, 1;\n{wait}\n@!%p1 bra WAIT;"),
        format!("WAIT:\n@%p0 {wait}\n@!%p1 bra WAIT;"),
        format!("WAIT:\n{wait}\n@%p1 bra WAIT;"),
        format!("WAIT:\n{wait}\n@!%p2 bra WAIT;"),
        format!("WAIT:\n{wait}\nbra WAIT;"),
        format!("OTHER:\nWAIT:\n{wait}\n@!%p1 bra OTHER;"),
        format!("WAIT:\n{wait}\n@!%p1 bra DONE;\nbra WAIT;\nDONE:"),
        format!("WAIT:\n{wait}\n@%p1 bra DONE;\nbra WAIT;\nOTHER:"),
        format!("WAIT:\n{wait}\nadd.u32 %r1, %r1, 1;\n@!%p1 bra WAIT;"),
    ] {
        assert_rejected_wait(&body, MbarrierWaitKind::TryWait);
    }
    assert_rejected_wait(
        "mbarrier.test_wait.parity.shared::cta.b64 %p1, [smem], 0;",
        MbarrierWaitKind::TestWait,
    );
}

/// Triton interleaves `.loc` directives with the retry loop; they lower to
/// nothing, so they do not split the loop's window.
#[test]
fn test_mbarrier_wait_loop_lowers_across_loc_directives() {
    let program = lower_body(
        "
        .loc 1 332 9
        WAIT:
        .loc 1 333 9
        mbarrier.try_wait.parity.shared::cta.b64 %p1, [smem], 0;
        .loc 1 333 9
        @!%p1 bra.uni WAIT;
        ",
    )
    .expect("the loop lowers across .loc directives");
    assert!(
        matches!(
            program.instructions.values().collect::<Vec<_>>().as_slice(),
            [LoweredInstr::MbarrierWaitParity { .. }, LoweredInstr::Ret]
        ),
        "{:?}",
        program.instructions
    );
}

/// ThunderKittens' retry loop leaves on the same condition as nvcc's
/// (`@!p bra L`), through an exit label: it lowers to the one blocking wait.
#[test]
fn test_mbarrier_wait_loop_with_an_exit_label_lowers_to_a_blocking_wait() {
    let program = lower_body(
        "WAIT:\nmbarrier.try_wait.parity.shared::cta.b64 %p1, [smem], 0;\n\
         @%p1 bra.uni DONE;\nbra.uni WAIT;\nDONE:\nret;",
    )
    .expect("the exit-label form lowers");
    let waits = program
        .instructions
        .iter()
        .filter(|(_, instr)| matches!(instr, LoweredInstr::MbarrierWaitParity { .. }))
        .count();
    let branches = program
        .instructions
        .iter()
        .filter(|(_, instr)| matches!(instr, LoweredInstr::Bra { .. }))
        .count();
    assert_eq!((waits, branches), (1, 0));
}

/// `.16x32bx2` takes its `immHalfSplitoff` operand (after the destination
/// vector of `tcgen05.ld`, before the source vector of `tcgen05.st`), and
/// only that shape takes one.
#[test]
fn test_tcgen05_16x32bx2_takes_a_half_split_offset() {
    let shape = |body: &str| {
        let program = lower_body(body).unwrap_or_else(|e| panic!("{body}: {e:?}"));
        match program.instructions.values().next() {
            Some(LoweredInstr::Tcgen05Ld { shape, .. } | LoweredInstr::Tcgen05St { shape, .. }) => {
                *shape
            }
            other => panic!("{body}: {other:?}"),
        }
    };
    let half_split = Tcgen05LdStShape::S16x32bx2 { half_split_off: 32 };

    assert_eq!(
        shape("tcgen05.ld.sync.aligned.16x32bx2.x2.b32 {%r1, %r2}, [%r3], 32;"),
        half_split
    );
    assert_eq!(
        shape("tcgen05.st.sync.aligned.16x32bx2.x2.b32 [%r3], 32, {%r1, %r2};"),
        half_split
    );

    for body in [
        "tcgen05.ld.sync.aligned.16x32bx2.x2.b32 {%r1, %r2}, [%r3];",
        "tcgen05.ld.sync.aligned.32x32b.x2.b32 {%r1, %r2}, [%r3], 32;",
    ] {
        assert!(
            matches!(lower_body(body), Err(LowerError::InvalidOperand { .. })),
            "{body}"
        );
    }
}

/// Threads 0-15 take the first `.16x32b` half, threads 16-31 the same lanes
/// `immHalfSplitoff` columns further (PTX ISA Figure 190).
#[test]
fn test_tcgen05_16x32bx2_cells() {
    let shape = Tcgen05LdStShape::S16x32bx2 { half_split_off: 32 };
    assert_eq!(shape.cell(5, 3), (5, 3));
    assert_eq!(shape.cell(21, 3), (5, 35));
    assert_eq!((shape.num_lanes(), shape.num_cols(32)), (16, 64));
}

/// TMA loads and stores share one `.dim` parser: every rank of the ISA lowers
/// in both directions.
#[test]
fn test_tma_every_rank_lowers_as_load_and_store() {
    for rank in 1..=5 {
        let coords = vec!["%r1"; rank].join(", ");
        assert_lowers(&format!(
            "cp.async.bulk.tensor.{rank}d.shared::cta.global.mbarrier::complete_tx::bytes \
             [smem], [%rd1, {{{coords}}}], [smem];"
        ));
        assert_lowers(&format!(
            "cp.async.bulk.tensor.{rank}d.global.shared::cta.bulk_group [%rd1, {{{coords}}}], [smem];"
        ));
    }
}

/// `.tile` is the TMA store's default load mode, so it may be omitted.
#[test]
fn test_tma_store_without_tile_lowers() {
    assert_lowers(
        "cp.async.bulk.tensor.2d.global.shared::cta.bulk_group [%rd1, {%r1, %r2}], [smem];",
    );
}

/// An `.im2col` load lowers for the ISA's 3-D to 5-D tensors with one 16-bit offset per
/// spatial dimension, innermost first; other ranks, offset lists and the W-only modes do not.
#[test]
fn test_tma_im2col_load_forms() {
    let load = |mode: &str, dim: usize, offsets: &str| {
        let coords = vec!["%r1"; dim].join(", ");
        format!(
            "cp.async.bulk.tensor.{dim}d.shared::cta.global.{mode}.mbarrier::complete_tx::bytes \
             [smem], [%rd1, {{{coords}}}], [smem]{offsets};"
        )
    };

    assert_lowers(&load("im2col", 3, ", {%rs1}"));
    assert_lowers(&load("im2col", 5, ", {%rs1, %rs2, 7}"));

    let prog = lower_body(&load("im2col", 4, ", {%rs1, 3}")).unwrap();
    let modes: Vec<_> = prog
        .instructions
        .values()
        .filter_map(|instr| match instr {
            LoweredInstr::CpAsyncBulkTensorLoad { mode, .. } => Some(mode.clone()),
            _ => None,
        })
        .collect();
    let [TensorLoadMode::Im2col { offsets }] = &modes[..] else {
        panic!("expected one im2col load, got {modes:?}");
    };
    assert_eq!(offsets.len(), 2);

    assert_rejected(&load("im2col", 2, ", {%rs1}"), ".im2col of a .2d tensor");
    assert_rejected(
        &load("tile.im2col", 4, ", {%rs1, %rs2}"),
        "more than one .load_mode",
    );
    assert_rejected(&load("im2col::w", 4, ", {%rs1, %rs2}"), "im2col::w");

    for (offsets, why) in [
        ("", "no im2colOffsets"),
        (", {%rs1}", "one offset for two spatial dims"),
        (", %rs1", "not a vector"),
    ] {
        let body = load("im2col", 4, offsets);
        assert!(
            matches!(lower_body(&body), Err(LowerError::InvalidOperand { .. })),
            "{why}: {body:?} must be rejected"
        );
    }

    assert!(matches!(
        lower_body(&load("im2col", 4, ", {%r1, %r2}")),
        Err(LowerError::TypeMismatch { .. })
    ));
}

/// `setmaxnreg`'s count is an integer constant in [24, 256], a multiple of 8 (PTX ISA
/// 9.7.21.5).
#[test]
fn test_setmaxnreg_count_must_be_a_valid_immediate() {
    for count in ["24", "232", "256"] {
        assert_lowers(&format!("setmaxnreg.inc.sync.aligned.u32 {count};"));
    }
    for count in ["16", "100", "264", "%r1"] {
        let body = format!("setmaxnreg.dec.sync.aligned.u32 {count};");
        assert!(
            matches!(lower_body(&body), Err(LowerError::InvalidOperand { .. })),
            "{body:?} must be rejected"
        );
    }
}
