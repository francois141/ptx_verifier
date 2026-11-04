//! Aligned named barriers match their PC and exact enclosing-loop context. Predication and
//! branches cannot merge different iterations; unaligned barriers retain thread-count semantics.

#[macro_use]
mod common;

use volta_graph_check::GraphConclusion;
use volta_ptx_analysis::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};

use common::*;

/// One output array `out`, passed as the only parameter.
fn out_config(threads: u32, elem_width: u64, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width,
        len,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// Lanes 0-15 and 16-31 reach the `.aligned` `bar.sync` on different loop iterations (UB).
#[test]
fn test_aligned_bar_sync_reached_on_different_iterations() {
    for barrier in [
        "bar.sync 0",
        "bar.sync 0, 32",
        "barrier.sync.aligned 0",
        "barrier.sync.aligned 0, 32",
    ] {
        let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
            .replace("bar.sync 0", barrier);
        let checked = check(&parse(&source), None, out_config(32, 4, 1));
        let deadlock = checked.report.deadlock().unwrap_or_else(|| {
            panic!(
                "{barrier}: expected a deadlock, got {:?}",
                checked.report.terminal
            )
        });
        let blocked: Vec<_> = deadlock.blocked.iter().map(|t| t.thread.0).collect();
        assert_eq!(blocked, (0..32).collect::<Vec<_>>(), "{barrier}");
        assert!(matches!(
            checked.report.conclusion(),
            GraphConclusion::Rejected { .. }
        ));
        assert!(checked.analysis.symbolic_outputs().is_err());
    }
}

#[test]
fn test_aligned_bar_arrive_reached_on_different_iterations() {
    for barrier in ["bar.arrive 0, 64", "barrier.arrive.aligned 0, 64"] {
        let source = ptx!("failing/aligned_bar_arrive_reached_on_different_iterations")
            .replace("bar.arrive 0, 64", barrier);
        let checked = check(&parse(&source), None, AnalysisConfig::new((64, 1, 1)));
        let deadlock = checked
            .report
            .deadlock()
            .expect("consumer warp must stay blocked");
        let blocked: Vec<_> = deadlock.blocked.iter().map(|t| t.thread.0).collect();
        assert_eq!(blocked, (32..64).collect::<Vec<_>>(), "{barrier}");
        assert!(matches!(
            checked.report.conclusion(),
            GraphConclusion::Rejected { .. }
        ));
        assert!(checked.analysis.symbolic_outputs().is_err());
    }
}

/// Both skipped and repeated aligned visits remain valid when the warp agrees on them.
#[test]
fn test_aligned_bar_sync_uniform_loop_visits() {
    for barrier in [
        "bar.sync 0",
        "bar.sync 0, 32",
        "barrier.sync.aligned 0",
        "barrier.sync.aligned 0, 32",
    ] {
        for (condition, syncs) in [("0", 32), ("1", 32), ("%r7", 64)] {
            let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
                .replace("bar.sync 0", barrier)
                .replace(
                    "setp.eq.u32 %p3, %r7, %r6",
                    &format!("setp.eq.u32 %p3, %r7, {condition}"),
                );
            let output = run_kernel(&parse(&source), None, out_config(32, 4, 1)).unwrap();
            assert_eq!(
                render_outputs(&output),
                "out[0] = 42\n",
                "{barrier}/{condition}"
            );
            assert_eq!(output.stats.block_syncs, syncs, "{barrier}/{condition}");
        }
    }
}

/// Counted producers and consumers may use different PCs when each warp agrees on its visits.
#[test]
fn test_aligned_bar_arrive_uniform_loop_visits() {
    for barrier in ["bar.arrive 0, 64", "barrier.arrive.aligned 0, 64"] {
        for condition in ["0", "1"] {
            let source = ptx!("failing/aligned_bar_arrive_reached_on_different_iterations")
                .replace("bar.arrive 0, 64", barrier)
                .replace(
                    "setp.eq.u32 %p2, %r2, %r1",
                    &format!("setp.eq.u32 %p2, %r2, {condition}"),
                );
            run_kernel(&parse(&source), None, AnalysisConfig::new((64, 1, 1))).unwrap();
        }
    }
}

#[test]
fn test_unaligned_barrier_arrive_can_join_different_loop_visits() {
    let source = ptx!("failing/aligned_bar_arrive_reached_on_different_iterations")
        .replace("bar.arrive 0, 64", "barrier.arrive 0, 64");
    run_kernel(&parse(&source), None, AnalysisConfig::new((64, 1, 1))).unwrap();
}

#[test]
fn test_unaligned_barrier_sync_can_join_different_loop_visits() {
    for barrier in ["barrier.sync 0", "barrier.sync 0, 32"] {
        let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
            .replace("bar.sync 0", barrier);
        let output = run_kernel(&parse(&source), None, out_config(32, 4, 1)).unwrap();
        assert_eq!(render_outputs(&output), "out[0] = 42\n");
    }
}

#[test]
fn test_aligned_bar_sync_branch_around_reached_on_different_iterations() {
    let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations").replace(
        "@%p3 bar.sync 0;",
        "@!%p3 bra SKIP_BAR;\n    bar.sync 0;\nSKIP_BAR:",
    );
    let checked = check(&parse(&source), None, out_config(32, 4, 1));
    assert!(matches!(
        checked.report.conclusion(),
        GraphConclusion::Rejected { .. }
    ));
    assert!(checked.analysis.symbolic_outputs().is_err());
}

#[test]
fn test_aligned_bar_sync_branch_around_uniform_loop_visits() {
    for (condition, syncs) in [("0", 32), ("1", 32), ("%r7", 64)] {
        let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
            .replace(
                "setp.eq.u32 %p3, %r7, %r6",
                &format!("setp.eq.u32 %p3, %r7, {condition}"),
            )
            .replace(
                "@%p3 bar.sync 0;",
                "@!%p3 bra SKIP_BAR;\n    bar.sync 0;\nSKIP_BAR:",
            );
        let output = run_kernel(&parse(&source), None, out_config(32, 4, 1)).unwrap();
        assert_eq!(render_outputs(&output), "out[0] = 42\n");
        assert_eq!(output.stats.block_syncs, syncs);
    }
}

#[test]
fn test_aligned_bar_sync_nested_uniform_loop_visits() {
    let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
        .replace("mov.u32 %r7, 0;\nLOOP:", "mov.u32 %r8, 0;\nOUTER_LOOP:\n    mov.u32 %r7, 0;\nLOOP:")
        .replace("setp.eq.u32 %p3, %r7, %r6", "setp.eq.u32 %p3, %r7, 0")
        .replace("@%p3 bar.sync 0;", "@!%p3 bra SKIP_BAR;\n    bar.sync 0;\nSKIP_BAR:")
        .replace("@%p4 bra LOOP;", "@%p4 bra LOOP;\n    add.u32 %r8, %r8, 1;\n    setp.lt.u32 %p5, %r8, 2;\n    @%p5 bra OUTER_LOOP;");
    let output = run_kernel(&parse(&source), None, out_config(32, 4, 1)).unwrap();
    assert_eq!(render_outputs(&output), "out[0] = 42\n");
    assert_eq!(output.stats.block_syncs, 64);
}

fn reactivated_loop_source(branch_around: bool) -> String {
    let mut source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
        .replace("shr.u32 %r6, %r0, 4;", "shr.u32 %r6, %r0, 4;\n    add.u32 %r6, %r6, 1;")
        .replace("mov.u32 %r7, 0;\nLOOP:", "mov.u32 %r8, 0;\nOUTER_LOOP:\n    setp.eq.u32 %p0, %r8, 1;\n    selp.u32 %r5, 0, 99, %p0;\n    selp.u32 %r9, 2, %r6, %p0;\n    mov.u32 %r7, 0;\nLOOP:")
        .replace("setp.eq.u32 %p3, %r7, %r6", "setp.eq.u32 %p3, %r7, %r5")
        .replace("setp.lt.u32 %p4, %r7, 2", "setp.lt.u32 %p4, %r7, %r9")
        .replace("@%p4 bra LOOP;", "@%p4 bra LOOP;\n    add.u32 %r8, %r8, 1;\n    setp.lt.u32 %p5, %r8, 2;\n    @%p5 bra OUTER_LOOP;");
    if branch_around {
        source = source.replace(
            "@%p3 bar.sync 0;",
            "@!%p3 bra SKIP_BAR;\n    bar.sync 0;\nSKIP_BAR:",
        );
    }
    source
}

#[test]
fn test_aligned_bar_sync_reactivated_loop_after_divergent_skipped_visits() {
    for branch_around in [true, false] {
        let output = run_kernel(
            &parse(&reactivated_loop_source(branch_around)),
            None,
            out_config(32, 4, 1),
        )
        .unwrap_or_else(|error| panic!("branch_around={branch_around}: {error}"));
        assert_eq!(render_outputs(&output), "out[0] = 42\n");
        assert_eq!(output.stats.block_syncs, 32);
    }
}

#[test]
fn test_aligned_bar_arrive_branch_around_different_iterations() {
    for barrier in ["bar.arrive 0, 64", "barrier.arrive.aligned 0, 64"] {
        let source = ptx!("failing/aligned_bar_arrive_reached_on_different_iterations").replace(
            "@%p2 bar.arrive 0, 64;",
            &format!("@!%p2 bra SKIP_ARRIVE;\n    {barrier};\nSKIP_ARRIVE:"),
        );
        let checked = check(&parse(&source), None, AnalysisConfig::new((64, 1, 1)));
        let blocked: Vec<_> = checked
            .report
            .deadlock()
            .expect("consumer must stay blocked")
            .blocked
            .iter()
            .map(|t| t.thread.0)
            .collect();
        assert_eq!(blocked, (32..64).collect::<Vec<_>>());
        assert!(checked.analysis.symbolic_outputs().is_err());
    }
}

#[test]
fn test_predicated_return_and_exit_preserve_loop_cfg_edges() {
    for terminator in ["ret", "exit"] {
        let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
            .replace(
                "LOOP:",
                &format!("LOOP:\n    setp.eq.u32 %p0, %r0, 999;\n    @%p0 {terminator};"),
            );
        let checked = check(&parse(&source), None, out_config(32, 4, 1));
        assert!(checked.report.deadlock().is_some());
        assert!(checked.analysis.symbolic_outputs().is_err());
        let uniform = source.replace("setp.eq.u32 %p3, %r7, %r6", "setp.eq.u32 %p3, %r7, 0");
        let output = run_kernel(&parse(&uniform), None, out_config(32, 4, 1)).unwrap();
        assert_eq!(render_outputs(&output), "out[0] = 42\n");
    }
}

#[test]
fn test_irreducible_aligned_context_is_unsupported_not_a_deadlock() {
    let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
        .replace("mov.u32 %r7, 0;", "mov.u32 %r7, 0;\n    setp.eq.u32 %p0, %r0, 999;\n    @%p0 bra IRR_B;\nIRR_A:\n    @%p0 bra IRR_B;\n    bra IRR_JOIN;\nIRR_B:\n    @%p0 bra IRR_A;\nIRR_JOIN:")
        .replace("setp.eq.u32 %p3, %r7, %r6", "setp.eq.u32 %p3, %r7, 0");
    let Err(error) = verify(&parse(&source), None, out_config(32, 4, 1)) else {
        panic!("irreducible aligned context unexpectedly started");
    };
    assert!(
        matches!(error, volta_ptx_analysis::AnalysisError::Eval(volta_ptx_analysis::EvalError::Unsupported { what, .. }) if what.contains("aligned barrier loop context: irreducible"))
    );
    let unaligned = source.replace("bar.sync 0", "barrier.sync 0");
    let output = run_kernel(&parse(&unaligned), None, out_config(32, 4, 1)).unwrap();
    assert_eq!(render_outputs(&output), "out[0] = 42\n");
    let unreachable = source.replace("@%p0 bra IRR_B;\nIRR_A:", "bra IRR_JOIN;\nIRR_A:");
    let output = run_kernel(&parse(&unreachable), None, out_config(32, 4, 1)).unwrap();
    assert_eq!(render_outputs(&output), "out[0] = 42\n");
}

#[test]
fn test_aligned_barrier_with_actual_exited_lanes_preserves_full_output() {
    for terminator in ["ret", "exit"] {
        let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
            .replace(
                "LOOP:",
                &format!("LOOP:\n    setp.ge.u32 %p0, %r0, 24;\n    @%p0 {terminator};"),
            )
            .replace("setp.eq.u32 %p3, %r7, %r6", "setp.eq.u32 %p3, %r7, 0");
        let output = run_kernel(&parse(&source), None, out_config(32, 4, 1)).unwrap();
        assert_eq!(render_outputs(&output), "out[0] = 42\n");
        assert_eq!(output.stats.block_syncs, 24);
    }
}

#[test]
fn test_nested_continue_to_outer_header_resets_inner_context() {
    let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
        .replace("mov.u32 %r7, 0;\nLOOP:", "mov.u32 %r8, 0;\nOUTER_LOOP:\n    setp.eq.u32 %p0, %r8, 0;\n    mov.u32 %r7, 0;\nLOOP:\n    @%p0 add.u32 %r8, %r8, 1;\n    @%p0 bra OUTER_LOOP;")
        .replace("setp.eq.u32 %p3, %r7, %r6", "setp.eq.u32 %p3, %r7, 0")
        .replace("@%p4 bra LOOP;", "@%p4 bra LOOP;\n    add.u32 %r8, %r8, 1;\n    setp.lt.u32 %p5, %r8, 2;\n    @%p5 bra OUTER_LOOP;");
    for branch_around in [false, true] {
        let variant = if branch_around {
            source.replace(
                "@%p3 bar.sync 0;",
                "@!%p3 bra SKIP_BAR;\n    bar.sync 0;\nSKIP_BAR:",
            )
        } else {
            source.clone()
        };
        let output = run_kernel(&parse(&variant), None, out_config(32, 4, 1)).unwrap();
        assert_eq!(render_outputs(&output), "out[0] = 42\n");
        assert_eq!(output.stats.block_syncs, 32);
    }
}

#[test]
fn test_sibling_loops_do_not_pollute_an_outside_barrier_context() {
    let source = ptx!("false_positive/aligned_bar_sync_reached_on_different_iterations")
        .replace("shr.u32 %r6, %r0, 4;", "shr.u32 %r6, %r0, 4;\n    add.u32 %r6, %r6, 1;\n    setp.eq.u32 %p0, %r0, 999;")
        .replace("@%p3 bar.sync 0;", "@%p0 bar.sync 0;")
        .replace("setp.lt.u32 %p4, %r7, 2", "setp.lt.u32 %p4, %r7, %r6")
        .replace("@%p4 bra LOOP;", "@%p4 bra LOOP;\n    mov.u32 %r7, 0;\nSIBLING:\n    @%p0 bar.sync 0;\n    add.u32 %r7, %r7, 1;\n    setp.lt.u32 %p4, %r7, %r6;\n    @%p4 bra SIBLING;\n    bar.sync 0;");
    let output = run_kernel(&parse(&source), None, out_config(32, 4, 1)).unwrap();
    assert_eq!(render_outputs(&output), "out[0] = 42\n");
    assert_eq!(output.stats.block_syncs, 32);
}
