//! Kernels whose waits do not observe an mbarrier's phases one after another from its first: the
//! mbarrier release-order check must fail, with this violation.

#[macro_use]
mod common;

use volta_graph::{GenerationKind, ThreadIx};
use volta_graph_check::mbarrier_release_order::ReleaseOrderViolation;
use volta_ptx_analysis::AnalysisConfig;

use common::*;

/// The only violation for `module`'s execution; panics if the check did not fail with one.
fn violation(module: &Ptx, config: AnalysisConfig) -> (Checked, ReleaseOrderViolation) {
    let checked = check(module, None, config);
    let [v] = *checked.report.mbarrier_release_order.violations() else {
        panic!(
            "expected the mbarrier release-order check to fail once, got: {:?}",
            checked.report.mbarrier_release_order
        );
    };
    (checked, v)
}

/// Nobody waits on phase 0 (thread 0's `arrive.expect_tx` and bulk copy), so thread 1's
/// parity-1 wait, released by phase 1 in the trace, returns through the pre-init phase while
/// the copy is in flight and races thread 0's store.
#[test]
fn test_inflight_complete_tx_lets_parity_wait_return_early() {
    let (checked, v) = violation(
        &ptx!(parse "failing/inflight_complete_tx_lets_parity_wait_return_early"),
        in_out_config(2, 8),
    );
    let g = &checked.analysis.graph;
    let ReleaseOrderViolation::LateStart { phase, release } = v else {
        panic!("expected the first release after phase 0, got {v:?}");
    };
    assert_eq!(g.generation(phase).kind, GenerationKind::MbarrierPhase);
    assert_eq!(g.generation(phase).index, 1);
    assert_eq!(g.thread_of(release), Some(ThreadIx(1)));
}
