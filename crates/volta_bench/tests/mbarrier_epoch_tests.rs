//! Kernels whose mbarrier operations are not separated from the next phase's: the barrier-epoch
//! check over mbarrier phases (Algorithm 1) must fail, with this violation.

#[macro_use]
mod common;

use volta_analysis::AnalysisConfig;
use volta_graph::{EventKind, GenerationKind, ThreadIx};
use volta_graph_check::barrier_epoch::EpochViolation;

use common::*;

/// The first violation for `module`'s execution; panics if the check did not fail.
fn violation(module: &Ptx, config: AnalysisConfig) -> (Checked, EpochViolation) {
    let checked = check(module, None, config);
    let [v] = *checked.report.mbarrier_epoch.violations() else {
        panic!(
            "expected the mbarrier epoch check to fail, got: {:?}",
            checked.report.mbarrier_epoch
        );
    };
    (checked, v)
}

/// Both threads return through the fresh barrier's pre-init phase before thread 1's arrival
/// completes phase 0, which nothing orders after thread 0's wait: on another schedule that
/// wait binds phase 1 and never returns.
#[test]
fn test_mbarrier_pre_init_wait_unseparated_from_the_first_arrival() {
    let (checked, v) = violation(
        &ptx!(parse "failing/mbarrier_pre_init_wait_unseparated_from_the_first_arrival"),
        in_out_config(2, 2),
    );
    let g = &checked.analysis.graph;
    assert_eq!(
        g.generation(v.generation).kind,
        GenerationKind::MbarrierPreInit
    );
    assert_eq!(g.generation(v.next).kind, GenerationKind::MbarrierPhase);
    assert_eq!(g.generation(v.next).index, 0);
    assert_eq!(
        g.event(v.synchronization).kind,
        EventKind::Resume(v.generation)
    );
    assert_eq!(g.thread_of(v.synchronization), Some(ThreadIx(0)));
    assert_eq!(g.event(v.operation).kind, EventKind::Contribute(v.next));
    assert_eq!(g.thread_of(v.operation), Some(ThreadIx(1)));
}

/// Thread 1 arrives on `mbar` with nothing ordering thread 0's `mbarrier.init` first (in the
/// second kernel, a re-init of the live object): on a schedule where thread 1 runs first, its
/// arrive lands on an uninitialized object, or on one the re-init then wipes.
#[test]
fn test_mbarrier_arrival_unordered_after_the_init() {
    for (name, src) in [
        ptx_case!("failing/mbarrier_init_unordered_with_other_threads_arrive"),
        ptx_case!("failing/mbarrier_reinit_of_live_object_races_arrive"),
    ] {
        let (checked, v) = violation(&parse(&src), in_out_config(2, 8));
        let g = &checked.analysis.graph;
        assert_eq!(
            g.event(v.synchronization).kind,
            EventKind::ObjectInit(v.barrier),
            "{name}"
        );
        assert_eq!(g.thread_of(v.synchronization), Some(ThreadIx(0)), "{name}");
        assert_eq!(
            g.event(v.operation).kind,
            EventKind::Contribute(v.next),
            "{name}"
        );
        assert_eq!(g.thread_of(v.operation), Some(ThreadIx(1)), "{name}");
    }
}
