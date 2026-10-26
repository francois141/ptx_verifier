//! Regression tests for invalid PTX directives and ret, exit, brkpt, and trap syntax.

#[macro_use]
mod common;

use volta_analysis::frontend::ascii::AsAscii;
use volta_analysis::frontend::parse::{ParseErrorKind, Parser};
use volta_analysis::{AnalysisConfig, AnalysisError, EvalError, LowerError, OutputsUnavailable};
use volta_graph_check::GraphConclusion;

use common::parse_named;
use common::verify;

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
