//! AMD kernels the analysis must reject: invalid launches, unsupported instructions and
//! values it does not model, each with its expected lowering or execution error.

use crate::common;

use common::amd::{array, array_of};
use volta_amd_analysis::OutputType::{F32, U32};
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    AnalysisError, AnalysisResult, ArrayKind, EvalError, InstrId, LdsLaneAccess, LdsRace,
    LowerError, Terminal, WaveId, WorkgroupLaunch, analyze, analyze_grid,
};

// Test rejection of empty or overflowing grids and selected workgroups outside the grid.
#[test]
fn invalid_workgroup_launches_are_rejected() {
    let kernel = parse_kernel(include_str!("success/workgroup_ids.s"), "workgroup_xyz").unwrap();
    let out = array_of("out", 0x10000, 192, ArrayKind::Output(U32));
    for (grid_size, workgroup_id) in [
        ((0, 1, 1), (0, 0, 0)),
        ((1, 0, 1), (0, 0, 0)),
        ((1, 1, 0), (0, 0, 0)),
        ((3, 4, 6), (3, 0, 0)),
        ((3, 4, 6), (0, 4, 0)),
        ((3, 4, 6), (0, 0, 6)),
    ] {
        let launch = WorkgroupLaunch {
            kernarg_address: 0x1000,
            workgroup_size: (64, 1, 1),
            workgroup_id,
            grid_size,
        };
        let result = analyze(
            &kernel,
            &launch,
            &out.base.to_le_bytes(),
            std::slice::from_ref(&out),
        );
        assert!(
            matches!(result, Err(AnalysisError::Eval(EvalError::Launch { .. }))),
            "expected launch rejection for grid {grid_size:?}, workgroup {workgroup_id:?}"
        );
    }
    for grid_size in [(0, 1, 1), (1, 0, 1), (1, 1, 0), (1 << 31, 1 << 31, 4)] {
        let launch = WorkgroupLaunch {
            kernarg_address: 0x1000,
            workgroup_size: (64, 1, 1),
            workgroup_id: (0, 0, 0),
            grid_size,
        };
        let result = analyze_grid(
            &kernel,
            &launch,
            &out.base.to_le_bytes(),
            std::slice::from_ref(&out),
        );
        assert!(
            matches!(result, Err(AnalysisError::Eval(EvalError::Launch { .. }))),
            "expected launch rejection for grid {grid_size:?}"
        );
    }
}
// Test that individually valid workgroups cannot share one LDS graph when their addresses differ.
#[test]
fn grid_runs_reject_different_lds_addresses() {
    let kernel = parse_kernel(
        include_str!("success/workgroup_ids.s"),
        "grid_lds_addresses",
    )
    .unwrap();
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (64, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (2, 1, 1),
    };
    let out = array_of("out", 0x10000, 128, ArrayKind::Output(U32));
    let arrays = std::slice::from_ref(&out);
    let kernarg = out.base.to_le_bytes();
    for group in 0..2 {
        let selected = WorkgroupLaunch {
            workgroup_id: (group, 0, 0),
            ..launch
        };
        let alone = analyze(&kernel, &selected, &kernarg, arrays).unwrap();
        assert_eq!(alone.terminal, Terminal::Completed);
    }
    let grid = analyze_grid(&kernel, &launch, &kernarg, arrays).unwrap();
    assert!(matches!(
        grid.terminal,
        Terminal::Aborted {
            error: EvalError::DependsOnWorkgroup,
            ..
        }
    ));
    assert!(grid.workgroups.is_empty());
}
// Test that a later workgroup's NaN source is rejected before multiplication by zero can fold.
#[test]
fn grid_runs_do_not_hide_nan_sources_in_later_workgroups() {
    let kernel = parse_kernel(include_str!("success/workgroup_ids.s"), "grid_lds_nan").unwrap();
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (64, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (2, 1, 1),
    };
    let out = array_of("out", 0x10000, 128, ArrayKind::Output(F32));
    let arrays = std::slice::from_ref(&out);
    let kernarg = out.base.to_le_bytes();
    let first = analyze(&kernel, &launch, &kernarg, arrays).unwrap();
    assert_eq!(first.terminal, Terminal::Completed);
    let second = analyze(
        &kernel,
        &WorkgroupLaunch {
            workgroup_id: (1, 0, 0),
            ..launch
        },
        &kernarg,
        arrays,
    )
    .unwrap();
    assert!(matches!(
        second.terminal,
        Terminal::Aborted {
            error: EvalError::InvalidFloatVgpr { .. },
            ..
        }
    ));
    let grid = analyze_grid(&kernel, &launch, &kernarg, arrays).unwrap();
    assert!(matches!(
        grid.terminal,
        Terminal::Aborted {
            error: EvalError::InvalidFloatVgpr { .. },
            ..
        }
    ));
    assert!(grid.workgroups.is_empty());
}
// Test that a register pair is not an f64 once a half is read as a word or overwritten, or when
// it holds two symbolic words, and that a constant encoding a NaN is rejected.
#[test]
fn invalid_f64_sources_are_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output(F32)),
    ];
    type ErrorCheck = fn(&EvalError) -> bool;
    let cases: [(&str, ErrorCheck); 4] = [
        ("f64_half_as_word", |error| {
            matches!(error, EvalError::F64Half { .. })
        }),
        ("f64_overwritten_half", |error| {
            matches!(error, EvalError::F64Half { .. })
        }),
        ("f64_from_symbolic_words", |error| {
            matches!(error, EvalError::InvalidF64Vgpr { .. })
        }),
        ("f64_nan_constant", |error| {
            matches!(error, EvalError::InvalidF64Bits(_))
        }),
    ];
    for (kernel, expected) in cases {
        common::amd::check_rejected_kernel(
            "execution_error/unsupported",
            kernel,
            &arrays,
            |result| {
                matches!(
                    result,
                    Ok(AnalysisResult {
                        terminal: Terminal::Aborted { error, .. },
                        symbolic_outputs: None,
                        ..
                    }) if expected(error)
                )
            },
        );
    }
}
// Test that a symbolic input cannot be exported as a concrete integer word.
#[test]
fn symbolic_integer_outputs_are_rejected() {
    let arrays = [
        array("in", 0x10000, ArrayKind::Input),
        array("out", 0x20000, ArrayKind::Output(U32)),
    ];
    common::amd::check_rejected_kernel("success/copy", "copy", &arrays, |result| {
        matches!(
            result,
            Ok(AnalysisResult {
                terminal: Terminal::Aborted {
                    error: EvalError::InvalidIntegerOutput { address: 0x20000 },
                    ..
                },
                symbolic_outputs: None,
                ..
            })
        )
    });
}
// Test that storing a NaN bit pattern to a float output aborts instead of exporting a real value.
#[test]
fn nan_float_outputs_are_rejected() {
    let arrays = [array("out", 0x10000, ArrayKind::Output(F32))];
    common::amd::check_rejected_kernel(
        "success/output_constants",
        "nan_output",
        &arrays,
        |result| {
            matches!(
                result,
                Ok(AnalysisResult {
                    terminal: Terminal::Aborted {
                        error: EvalError::InvalidFloatOutput { address: 0x10000 },
                        ..
                    },
                    symbolic_outputs: None,
                    ..
                })
            )
        },
    );
}
// Test that integer arithmetic and bitwise operations reject symbolic inputs,
// because symbolic values are floats without known bits.
#[test]
fn integer_operations_on_symbolic_values_are_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output(F32)),
    ];
    for kernel in [
        "symbolic_shift",
        "symbolic_negation",
        "symbolic_add",
        "symbolic_not",
    ] {
        common::amd::check_rejected_kernel(
            "execution_error/unsupported",
            kernel,
            &arrays,
            |result| {
                matches!(
                    result,
                    Ok(AnalysisResult {
                        terminal: Terminal::Aborted {
                            error: EvalError::SymbolicWord { lane: 0 },
                            ..
                        },
                        symbolic_outputs: None,
                        ..
                    })
                )
            },
        );
    }
}
// Test that a scalar AND rejects the symbolic lane mask produced by a float comparison.
#[test]
fn scalar_operations_on_symbolic_masks_are_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output(U32)),
    ];
    common::amd::check_rejected_kernel(
        "execution_error/unsupported",
        "symbolic_mask",
        &arrays,
        |result| {
            matches!(
                result,
                Ok(AnalysisResult {
                    terminal: Terminal::Aborted {
                        error: EvalError::SymbolicSgpr(_),
                        ..
                    },
                    symbolic_outputs: None,
                    ..
                })
            )
        },
    );
}
// Test that a float comparison choosing between two constants is rejected, because the
// chosen words could encode floats or integers.
#[test]
fn selecting_between_constants_under_a_symbolic_condition_is_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output(F32)),
    ];
    common::amd::check_rejected_kernel(
        "execution_error/unsupported",
        "symbolic_select",
        &arrays,
        |result| {
            matches!(
                result,
                Ok(AnalysisResult {
                    terminal: Terminal::Aborted {
                        error: EvalError::AmbiguousSelect { lane: 0 },
                        ..
                    },
                    symbolic_outputs: None,
                    ..
                })
            )
        },
    );
}
// Test that a store executed by only the odd lanes is rejected for changing EXEC.
#[test]
fn intra_wave_divergence_is_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output(F32)),
    ];
    common::amd::check_rejected_kernel(
        "execution_error/unsupported",
        "divergent_store",
        &arrays,
        |result| {
            matches!(
                result,
                Err(AnalysisError::Lower(LowerError::Instruction { opcode, reason, .. }))
                    if opcode == "s_and_saveexec_b64"
                        && *reason == "EXEC changes are unsupported: intra-wave divergence is not modeled"
            )
        },
    );
}
// Test that lanes 0 and 32 writing word 0 in one ds_write_b32 (instruction 7) is rejected.
#[test]
fn two_lds_writes_in_the_same_wave_are_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output(F32)),
    ];
    let ds_write_lane = |lane| LdsLaneAccess {
        wave: WaveId(0),
        lane,
        pc: InstrId(7),
    };
    let expected = Terminal::Aborted {
        wave: WaveId(0),
        pc: InstrId(7),
        error: EvalError::LdsRace(LdsRace {
            address: 0,
            earlier: ds_write_lane(0),
            later: ds_write_lane(32),
        }),
    };
    common::amd::check_rejected_kernel(
        "execution_error/lds_race",
        "write_write_race",
        &arrays,
        |result| result.as_ref().is_ok_and(|run| run.terminal == expected),
    );
}
