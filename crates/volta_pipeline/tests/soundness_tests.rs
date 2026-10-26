//! Regression tests for invalid PTX directives, ldmatrix modifiers and operands, mbarrier
//! arrival counts, operands, semantics and scopes, ret, exit, brkpt, and trap syntax, address
//! offsets, and the unsupported redux.sync.

#[macro_use]
mod common;

use volta_graph_check::{GraphConclusion, Property, Verdict};
use volta_ptx_analysis::frontend::ascii::AsAscii;
use volta_ptx_analysis::frontend::parse::{ParseErrorKind, Parser};
use volta_ptx_analysis::{
    AnalysisConfig, AnalysisError, ArrayDef, ArrayKind, EvalError, LowerError, OutputsUnavailable,
    ParamValue,
};

use common::{Ptx, parse_named, verify};

fn out_config(threads: u32, elem_width: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// Invalid PTX may be rejected by the source parser or by instruction lowering. It must not
/// survive validation and reach execution. Keeping this distinction prevents a runtime trap or
/// a bad test configuration from satisfying a syntax regression by accident.
fn assert_rejected_during_validation(name: &'static str, source: &str, config: AnalysisConfig) {
    let ascii = source
        .as_bytes()
        .as_ascii_slice()
        .expect("ASCII PTX source");
    let module = match Parser::new(ascii).parse_module() {
        Ok(module) => module,
        Err(_) => return,
    };
    let module = Ptx {
        module,
        source: source.to_string(),
        file: Some(name),
    };
    match verify(&module, Some("k"), config) {
        Err(AnalysisError::Lower(_)) => {}
        Err(other) => panic!(
            "{name}.ptx reached execution instead of failing validation; runtime error: {other}"
        ),
        Ok(verified) => panic!(
            "{name}.ptx passed parsing and lowering; graph conclusion: {:?}",
            verified.graph.conclusion()
        ),
    }
}

/// An instruction whose declared PTX version, target, or immediate encoding is illegal may be
/// rejected at any validation stage, but it must not survive into a graph verdict.
fn assert_rejected_before_verdict(name: &'static str, source: &str, config: AnalysisConfig) {
    let ascii = source
        .as_bytes()
        .as_ascii_slice()
        .expect("ASCII PTX source");
    let module = match Parser::new(ascii).parse_module() {
        Ok(module) => module,
        Err(_) => return,
    };
    let module = Ptx {
        module,
        source: source.to_string(),
        file: Some(name),
    };
    match verify(&module, Some("k"), config) {
        Err(AnalysisError::KernelNotFound { .. }) => {
            panic!("{name}.ptx has no kernel named k")
        }
        Err(AnalysisError::Eval(EvalError::Config { message, .. })) => {
            panic!("{name}.ptx has an invalid test configuration: {message}")
        }
        Err(_) => {}
        Ok(verified) => panic!(
            "{name}.ptx was accepted; graph conclusion: {:?}",
            verified.graph.conclusion()
        ),
    }
}

#[test]
fn ret_must_reject_operands() {
    let source = ptx!("soundness/ret_extra_operand");
    for ret in ["ret", "ret.uni"] {
        let invalid = source.replace("ret 123;", &format!("{ret} 123;"));
        let module = parse_named("soundness/ret_extra_operand", &invalid);
        match verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1))) {
            Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
                instruction,
                reason,
            })) => {
                assert_eq!(instruction, "Ret");
                assert_eq!(
                    reason.as_deref(),
                    Some("Instruction parsing failed: WrongOperandCount { expected: 0, got: 1 }")
                );
            }
            Err(other) => panic!("expected a ret operand-count error, got {other:?}"),
            Ok(_) => panic!("{ret} 123; must fail validation: ret takes no operands"),
        }

        let valid = source.replace("ret 123;", &format!("{ret};"));
        let module = parse_named("soundness/ret_control", &valid);
        let verified = verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1)))
            .expect("ret without operands must remain valid");
        assert_eq!(verified.graph.conclusion(), GraphConclusion::Verified);
    }
}

#[test]
fn unknown_directives_must_be_rejected() {
    let source = ptx!("soundness/unknown_directive");
    let directive = ".this_is_not_a_ptx_directive";
    let statement = format!("{directive} arbitrary tokens;");
    assert_eq!(source.matches(&statement).count(), 1);

    for replacement in ["", ".pragma \"nounroll\";"] {
        let control = source.replacen(&statement, replacement, 1);
        let control = parse_named("soundness/unknown_directive_control", &control);
        let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
            .expect("removing the unknown directive or using a known pragma must be valid");
        assert_eq!(verified.graph.conclusion(), GraphConclusion::Verified);
    }

    let ascii = source
        .as_bytes()
        .as_ascii_slice()
        .expect("ASCII PTX source");
    let error = match Parser::new(ascii).parse_module() {
        Err(error) => error,
        Ok(_) => panic!("unknown directive {directive} was silently accepted by the parser"),
    };
    assert!(
        matches!(&error.error, ParseErrorKind::InvalidDirective(name)
            if name.as_str() == &directive[1..]),
        "expected InvalidDirective naming {directive}, got {error:?}"
    );
    let span = error
        .span
        .expect("the diagnostic must locate the directive");
    assert_eq!(span.0, source.find(directive).unwrap());
    assert!(source[span.0..span.1].starts_with(directive));
}

#[test]
fn ldmatrix_must_require_its_mandatory_modifiers() {
    assert_rejected_during_validation(
        "soundness/ldmatrix_missing_modifiers",
        &ptx!("soundness/ldmatrix_missing_modifiers"),
        AnalysisConfig::new((32, 1, 1)),
    );
}

#[test]
fn ldmatrix_must_reject_a_trailing_operand() {
    assert_rejected_during_validation(
        "soundness/ldmatrix_extra_operand",
        &ptx!("soundness/ldmatrix_extra_operand"),
        AnalysisConfig::new((32, 1, 1)),
    );
}

#[test]
fn mbarrier_init_must_reject_a_zero_count() {
    assert_rejected_before_verdict(
        "soundness/mbarrier_init_zero_count",
        &ptx!("soundness/mbarrier_init_zero_count"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_init_must_reject_a_count_above_the_ptx_limit() {
    assert_rejected_before_verdict(
        "soundness/mbarrier_init_count_out_of_range",
        &ptx!("soundness/mbarrier_init_count_out_of_range"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_arrive_must_reject_a_zero_count() {
    assert_rejected_before_verdict(
        "soundness/mbarrier_arrive_zero_count",
        &ptx!("soundness/mbarrier_arrive_zero_count"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_arrive_must_reject_a_trailing_operand() {
    assert_rejected_during_validation(
        "soundness/mbarrier_arrive_extra_operand",
        &ptx!("soundness/mbarrier_arrive_extra_operand"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn exit_must_reject_an_unknown_modifier() {
    let source = ptx!("soundness/exit_invalid_modifier");
    let control = source.replace("exit.not_a_modifier;", "exit;");
    let control = parse_named("soundness/exit_control", &control);
    let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("exit without a modifier must be valid");
    assert_eq!(verified.graph.conclusion(), GraphConclusion::Verified);

    let module = parse_named("soundness/exit_invalid_modifier", &source);
    match verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason: Some(reason),
        })) => {
            assert_eq!(instruction, "Exit");
            assert!(
                reason.starts_with("Instruction parsing failed: UnexpectedModifier("),
                "expected an unexpected-modifier error, got {reason}"
            );
        }
        Err(other) => panic!("expected an exit modifier error, got {other:?}"),
        Ok(_) => {
            panic!("exit.not_a_modifier; was accepted instead of rejecting the unknown modifier")
        }
    }
}

#[test]
fn exit_must_reject_operands() {
    let source = ptx!("soundness/exit_extra_operand");
    let control = source.replace("exit 123;", "exit;");
    let control = parse_named("soundness/exit_control", &control);
    let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("exit without operands must be valid");
    assert_eq!(verified.graph.conclusion(), GraphConclusion::Verified);

    let module = parse_named("soundness/exit_extra_operand", &source);
    match verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason,
        })) => {
            assert_eq!(instruction, "Exit");
            assert_eq!(
                reason.as_deref(),
                Some("Instruction parsing failed: WrongOperandCount { expected: 0, got: 1 }")
            );
        }
        Err(other) => panic!("expected an exit operand-count error, got {other:?}"),
        Ok(_) => panic!("exit 123; must fail validation: exit takes no operands"),
    }
}

#[test]
fn brkpt_must_reject_an_unknown_modifier() {
    let source = ptx!("soundness/brkpt_invalid_modifier");
    let control = source.replace("brkpt.not_a_modifier;", "brkpt;");
    let control = parse_named("soundness/brkpt_control", &control);
    let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("brkpt without a modifier must be valid");
    assert_eq!(verified.graph.conclusion(), GraphConclusion::Verified);

    let module = parse_named("soundness/brkpt_invalid_modifier", &source);
    match verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason: Some(reason),
        })) => {
            assert_eq!(instruction, "Brkpt");
            assert!(
                reason.starts_with("Instruction parsing failed: UnexpectedModifier("),
                "expected an unexpected-modifier error, got {reason}"
            );
        }
        Err(other) => panic!("expected a brkpt modifier error, got {other:?}"),
        Ok(_) => {
            panic!("brkpt.not_a_modifier; was accepted instead of rejecting the unknown modifier")
        }
    }
}

#[test]
fn brkpt_must_reject_operands() {
    let source = ptx!("soundness/brkpt_extra_operand");
    let control = source.replace("brkpt 123;", "brkpt;");
    let control = parse_named("soundness/brkpt_control", &control);
    let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("brkpt without operands must be valid");
    assert_eq!(verified.graph.conclusion(), GraphConclusion::Verified);

    let module = parse_named("soundness/brkpt_extra_operand", &source);
    match verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason,
        })) => {
            assert_eq!(instruction, "Brkpt");
            assert_eq!(
                reason.as_deref(),
                Some("Instruction parsing failed: WrongOperandCount { expected: 0, got: 1 }")
            );
        }
        Err(other) => panic!("expected a brkpt operand-count error, got {other:?}"),
        Ok(_) => panic!("brkpt 123; must fail validation: brkpt takes no operands"),
    }
}

#[test]
fn trap_must_reject_an_unknown_modifier() {
    let source = ptx!("soundness/trap_invalid_modifier");
    let control = source.replace("trap.not_a_modifier;", "trap;");
    let control = parse_named("soundness/trap_control", &control);
    let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("trap without a modifier must pass validation");
    assert!(matches!(
        verified.analysis.symbolic_outputs(),
        Err(OutputsUnavailable::Aborted(EvalError::TrapReached { .. }))
    ));

    let module = parse_named("soundness/trap_invalid_modifier", &source);
    match verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason: Some(reason),
        })) => {
            assert_eq!(instruction, "Trap");
            assert!(
                reason.starts_with("Instruction parsing failed: UnexpectedModifier("),
                "expected an unexpected-modifier error, got {reason}"
            );
        }
        Err(other) => panic!("expected a trap modifier error, got {other:?}"),
        Ok(_) => {
            panic!(
                "trap.not_a_modifier; reached execution instead of rejecting the unknown modifier"
            )
        }
    }
}

#[test]
fn trap_must_reject_operands() {
    let source = ptx!("soundness/trap_extra_operand");
    let control = source.replace("trap 123;", "trap;");
    let control = parse_named("soundness/trap_control", &control);
    let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("trap without operands must pass validation");
    assert!(matches!(
        verified.analysis.symbolic_outputs(),
        Err(OutputsUnavailable::Aborted(EvalError::TrapReached { .. }))
    ));

    let module = parse_named("soundness/trap_extra_operand", &source);
    match verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason,
        })) => {
            assert_eq!(instruction, "Trap");
            assert_eq!(
                reason.as_deref(),
                Some("Instruction parsing failed: WrongOperandCount { expected: 0, got: 1 }")
            );
        }
        Err(other) => panic!("expected a trap operand-count error, got {other:?}"),
        Ok(_) => panic!("trap 123; must fail validation: trap takes no operands"),
    }
}

#[test]
fn address_constant_expression_must_not_hide_a_write_write_race() {
    let mut config = AnalysisConfig::new((2, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let verified = verify(
        &ptx!(parse "soundness/address_constant_expression_race"),
        Some("k"),
        config,
    )
    .expect("the counterexample must execute");
    assert_eq!(
        verified.graph.verdict(Property::MemoryConflict),
        Verdict::Fail,
        "`[%ptr + (4 | 4)]` and `[%ptr + 4]` must conflict; report: {:#?}",
        verified.graph
    );
    assert!(
        matches!(
            verified.graph.conclusion(),
            GraphConclusion::Rejected { .. }
        ),
        "a memory conflict must reject the graph"
    );
}

#[test]
fn mbarrier_expect_tx_must_reject_invalid_semantics() {
    assert_rejected_during_validation(
        "soundness/mbarrier_expect_tx_invalid_semantics",
        &ptx!("soundness/mbarrier_expect_tx_invalid_semantics"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_expect_tx_must_reject_invalid_scope() {
    assert_rejected_during_validation(
        "soundness/mbarrier_expect_tx_invalid_scope",
        &ptx!("soundness/mbarrier_expect_tx_invalid_scope"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_complete_tx_must_reject_invalid_semantics() {
    assert_rejected_during_validation(
        "soundness/mbarrier_complete_tx_invalid_semantics",
        &ptx!("soundness/mbarrier_complete_tx_invalid_semantics"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_complete_tx_must_reject_invalid_scope() {
    assert_rejected_during_validation(
        "soundness/mbarrier_complete_tx_invalid_scope",
        &ptx!("soundness/mbarrier_complete_tx_invalid_scope"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_try_wait_must_reject_invalid_scope() {
    assert_rejected_during_validation(
        "soundness/mbarrier_try_wait_invalid_scope",
        &ptx!("soundness/mbarrier_try_wait_invalid_scope"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_test_wait_must_reject_an_extra_operand() {
    assert_rejected_during_validation(
        "soundness/mbarrier_test_wait_extra_operand",
        &ptx!("soundness/mbarrier_test_wait_extra_operand"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_try_wait_must_reject_an_operand_after_the_suspend_hint() {
    assert_rejected_during_validation(
        "soundness/mbarrier_try_wait_extra_operand",
        &ptx!("soundness/mbarrier_try_wait_extra_operand"),
        AnalysisConfig::new((1, 1, 1)),
    );
}

#[test]
fn mbarrier_tx_count_must_stay_in_the_isa_range() {
    let source = ptx!("soundness/mbarrier_tx_count_out_of_range");
    let control = source.replace("1048575;", "1048574;");
    let control = parse_named("soundness/mbarrier_tx_count_control", &control);
    let verified = verify(&control, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("a tx-count of 2^20 - 1 must execute");
    assert_eq!(verified.graph.conclusion(), GraphConclusion::Verified);

    let module = parse_named("soundness/mbarrier_tx_count_out_of_range", &source);
    let verified = verify(&module, Some("k"), AnalysisConfig::new((1, 1, 1)))
        .expect("a tx-count of 2^20 must pass validation");
    assert!(matches!(
        verified.analysis.symbolic_outputs(),
        Err(OutputsUnavailable::Aborted(
            EvalError::MbarrierTxCountOutOfRange {
                tx_count: 1048576,
                ..
            }
        ))
    ));
}

/// The fused sign-trick idiom once dropped its `setp` predicate write and verified this race;
/// `redux.sync` is now unsupported, so the kernel must not reach a verdict.
#[test]
fn redux_idiom_must_not_verify_its_predicate_side_effect_race() {
    let module = ptx!(parse "soundness/redux_predicate_side_effect_race");
    match verify(&module, Some("k"), out_config(2, 4)) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason: Some(reason),
        })) => {
            assert_eq!(instruction, "redux.sync");
            assert!(reason.contains("not supported"), "{reason}");
        }
        Err(other) => panic!("expected redux.sync to be unsupported, got {other:?}"),
        Ok(verified) => panic!(
            "expected redux.sync to be unsupported, got {:?}",
            verified.graph.conclusion()
        ),
    }
}
