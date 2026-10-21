//! The analysis stage's graph artifact on real test kernels: what the candidate execution
//! records, built and inspected without any property checker, and the symbolic outputs
//! consumed without graph verification.

#[macro_use]
#[allow(unused_macros)]
mod common;

use volta_analysis::{AnalysisConfig, AnalysisResult, OutputsUnavailable, analyze};
use volta_equivalence::EquivOutcome;
use volta_equivalence::check::check_output_equivalence;
use volta_frontend::ast::Module;
use volta_graph::{
    AccessMode, AsyncOpKind, BlockedOn, CollectiveSide, ContributionKind, EventGraph, EventKind,
    ExecContext, Footprint, GenerationKind, Space, SyncObjectKind, Terminal, ThreadIx,
};

use common::*;

fn run(module: &Module, config: AnalysisConfig) -> AnalysisResult {
    let result = analyze(module, None, config).expect("the execution starts");
    assert_eq!(result.graph.validate(), Ok(()), "{}", result.graph.dump());
    result
}

fn kinds(graph: &EventGraph, thread: u32) -> Vec<EventKind> {
    graph
        .program_order(ThreadIx(thread))
        .iter()
        .map(|&e| graph.event(e).kind)
        .collect()
}

#[test]
fn a_barrier_exchange_records_one_full_cta_generation() {
    let r = run(
        &ptx!(parse "success/shared_exchange_with_barrier"),
        in_out_config(2, 2),
    );
    let g = &r.graph;
    let barriers: Vec<_> = g
        .generations()
        .values()
        .filter(|generation| matches!(generation.kind, GenerationKind::Barrier { .. }))
        .collect();
    assert_eq!(barriers.len(), 1);
    assert_eq!(barriers[0].contributions.len(), 2);
    assert!(
        barriers[0]
            .contributions
            .iter()
            .all(|c| c.kind == ContributionKind::Blocking)
    );
    assert_eq!(barriers[0].releases.len(), 2);
    for t in 0..2 {
        assert!(matches!(
            kinds(g, t).as_slice(),
            [
                EventKind::Access(_),
                EventKind::Access(_),
                EventKind::Contribute(_),
                EventKind::Resume(_),
                EventKind::Access(_),
                EventKind::Access(_),
                EventKind::Exit
            ]
        ));
    }
    assert_eq!(g.terminal(), &Terminal::Completed);
}

#[test]
fn analyzing_twice_dumps_identical_graphs() {
    let module = ptx!(parse "success/cp_async_bulk_every_reader_waiting_is_accepted");
    let a = run(&module, bulk_copy_config()).graph.dump();
    let b = run(&module, bulk_copy_config()).graph.dump();
    assert_eq!(a, b);
}

#[test]
fn symbolic_outputs_are_consumed_without_graph_verification() {
    let module = ptx!(parse "success/shared_exchange_with_barrier");
    let a = run(&module, in_out_config(2, 2));
    let b = run(&module, in_out_config(2, 2));
    let outcome = check_output_equivalence(
        a.symbolic_outputs().unwrap(),
        b.symbolic_outputs().unwrap(),
        &["out".to_string()],
    )
    .unwrap();
    assert!(matches!(outcome, EquivOutcome::Equivalent));
}

#[test]
fn a_stuck_execution_records_every_blocked_thread() {
    let r = run(
        &ptx!(parse "failing/mbarrier_wait_never_satisfied_deadlocks"),
        AnalysisConfig::new((2, 1, 1)),
    );
    let Terminal::Stuck { blocked } = r.graph.terminal() else {
        panic!("expected a stuck terminal: {:?}", r.graph.terminal());
    };
    assert_eq!(blocked.len(), 2);
    for b in blocked {
        let BlockedOn::Mbarrier { state, .. } = &b.on else {
            panic!("blocked on {:?}", b.on);
        };
        assert_eq!((state.arrived, state.expected), (1, 2));
    }
    assert!(matches!(
        r.symbolic_outputs(),
        Err(OutputsUnavailable::Stuck { .. })
    ));
}

#[test]
fn an_aborted_execution_keeps_its_partial_graph() {
    let r = run(
        &ptx!(parse "failing/out_of_bounds_shared_access"),
        AnalysisConfig::new((1, 1, 1)),
    );
    let Terminal::Aborted { thread, reason, .. } = r.graph.terminal() else {
        panic!("expected an aborted terminal");
    };
    assert_eq!(*thread, Some(ThreadIx(0)));
    assert!(reason.contains("out-of-bounds"), "{reason}");
    assert!(matches!(
        r.symbolic_outputs(),
        Err(OutputsUnavailable::Aborted(_))
    ));
}

#[test]
fn a_bulk_copy_is_an_async_op_tracked_by_its_mbarrier_phase() {
    let r = run(
        &ptx!(parse "success/cp_async_bulk_every_reader_waiting_is_accepted"),
        bulk_copy_config(),
    );
    let g = &r.graph;
    let (op_id, op) = g
        .async_ops()
        .iter()
        .find(|(_, a)| a.kind == AsyncOpKind::BulkCopy)
        .expect("one bulk copy");
    assert_eq!(op.issuer, ThreadIx(0));
    assert_eq!(op.effects.len(), 8);
    let writes: Vec<_> = op
        .effects
        .iter()
        .map(|&a| g.access(a))
        .filter(|a| a.mode == AccessMode::Write)
        .collect();
    assert_eq!(writes.len(), 4);
    assert!(writes.iter().all(|a| a.space == Space::Shared));
    assert!(
        !g.program_order(ThreadIx(0))
            .iter()
            .any(|&e| { g.event(e).ctx == ExecContext::Async(op_id) })
    );
    let [phase] = op.tracking.as_slice() else {
        panic!("tracked by one phase: {:?}", op.tracking);
    };
    let phase = g.generation(*phase);
    assert_eq!(phase.kind, GenerationKind::MbarrierPhase);
    assert!(matches!(
        g.object(phase.object).kind,
        SyncObjectKind::Mbarrier { .. }
    ));
    assert!(phase.contributions.iter().any(|c| matches!(
        c.kind,
        ContributionKind::AsyncCompletion { tx_bytes: 16, .. }
    )));
    assert_eq!(phase.releases.len(), 64);
}

#[test]
fn cp_async_completes_into_its_issuers_wait_group() {
    let r = run(
        &ptx!(parse "success/cp_async_post_wait_cross_thread_read_with_sync_succeeds"),
        in_out_config(2, 1),
    );
    let g = &r.graph;
    let op = g.async_ops().values().next().expect("one cp.async");
    assert_eq!(op.kind, AsyncOpKind::CpAsync);
    let [wait] = op.tracking.as_slice() else {
        panic!("tracked by one wait: {:?}", op.tracking);
    };
    let wait = g.generation(*wait);
    assert!(matches!(
        wait.kind,
        GenerationKind::AsyncGroupWait { keep_pending: 0 }
    ));
    let releases: Vec<_> = wait.releases.iter().map(|&e| g.thread_of(e)).collect();
    assert_eq!(releases, vec![Some(op.issuer)]);
}

#[test]
fn tcgen05_mma_is_tracked_by_its_commit_phase() {
    let r = run(
        &ptx!(parse "success/tcgen05_mma_bar_sync_after_completion_orders_the_read"),
        AnalysisConfig::new((64, 1, 1)),
    );
    let g = &r.graph;
    let mma = g
        .async_ops()
        .values()
        .find(|a| a.kind == AsyncOpKind::Tcgen05Mma)
        .expect("one MMA");
    let d_write = mma
        .effects
        .iter()
        .map(|&a| g.access(a))
        .find(|a| a.space == Space::Tensor && a.mode == AccessMode::Write)
        .expect("D is written");
    assert!(matches!(
        d_write.footprint,
        Footprint::Tensor {
            lane: 0,
            lanes: 128,
            ..
        }
    ));
    let [phase] = mma.tracking.as_slice() else {
        panic!("tracked by one commit: {:?}", mma.tracking);
    };
    assert_eq!(g.generation(*phase).kind, GenerationKind::MbarrierPhase);
    let ld = g
        .async_ops()
        .values()
        .find(|a| a.kind == AsyncOpKind::Tcgen05Ld)
        .expect("one tcgen05.ld");
    let [wait] = ld.tracking.as_slice() else {
        panic!("tracked by one wait: {:?}", ld.tracking);
    };
    assert!(matches!(
        g.generation(*wait).kind,
        GenerationKind::Collective {
            side: CollectiveSide::Exit,
            ..
        }
    ));
}

#[test]
fn exited_lanes_count_as_arrived_at_warp_collectives() {
    let r = run(
        &ptx!(parse "success/tail_exit_warp_shfl_reduction"),
        in_out_config(32, 16),
    );
    let g = &r.graph;
    let entries: Vec<_> = g
        .generations()
        .values()
        .filter(|generation| {
            matches!(
                generation.kind,
                GenerationKind::Collective {
                    side: CollectiveSide::Entry,
                    ..
                }
            )
        })
        .collect();
    assert_eq!(entries.len(), 4);
    for entry in entries {
        let exited = entry
            .contributions
            .iter()
            .filter(|c| c.kind == ContributionKind::Exited)
            .count();
        assert_eq!(exited, 16);
        assert_eq!(entry.releases.len(), 16);
    }
}

#[test]
fn an_exited_thread_counts_as_arrived_at_a_full_cta_barrier() {
    let r = run(
        &ptx!(parse "success/exited_thread_releases_barrier"),
        AnalysisConfig::new((2, 1, 1)),
    );
    let barrier = r
        .graph
        .generations()
        .values()
        .find(|generation| matches!(generation.kind, GenerationKind::Barrier { .. }))
        .expect("one barrier generation");
    let kinds: Vec<ContributionKind> = barrier.contributions.iter().map(|c| c.kind).collect();
    assert!(kinds.contains(&ContributionKind::Exited));
    assert!(kinds.contains(&ContributionKind::Blocking));
}

#[test]
fn racy_accesses_are_recorded_without_a_verdict() {
    let r = run(
        &ptx!(parse "execution_error/shared_write_write_race"),
        AnalysisConfig::new((2, 1, 1)),
    );
    let g = &r.graph;
    assert_eq!(g.terminal(), &Terminal::Completed);
    let writers: Vec<_> = g
        .accesses()
        .values()
        .filter(|a| a.space == Space::Shared && a.mode == AccessMode::Write)
        .map(|a| (a.attributed, a.footprint))
        .collect();
    assert_eq!(writers.len(), 2);
    assert_ne!(writers[0].0, writers[1].0);
    assert!(writers[0].1.overlaps(&writers[1].1));
}
