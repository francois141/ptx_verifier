//! Check 1, the barrier-epoch check over named barriers (Algorithm 1), in isolation.

mod common;

use common::*;
use volta_graph::{
    BarrierArrivals, ContributionKind, EventGraph, GenerationKind, Parity, SyncObjectKind,
    Terminal, ThreadIx,
};
use volta_graph_check::Verdict;
use volta_graph_check::barrier_epoch::{EpochViolation, check_named_barrier_epochs};

#[test]
fn a_reused_full_cta_barrier_passes_and_is_certified() {
    let mut s = Scenario::new(2);
    s.write(0, 0, 1);
    s.barrier(&[0, 1], &[]);
    s.read(1, 0);
    s.barrier(&[0, 1], &[]);
    let (g, _) = s.completed(2);
    let (result, certificate) = check_named_barrier_epochs(&g);
    let volta_graph_check::PropertyResult::Pass(evidence) = &result else {
        panic!("{result:?}");
    };
    assert_eq!((evidence.barriers, evidence.generation_pairs), (1, 1));
    assert_eq!(
        evidence.separations, 4,
        "every s of generation 0 against every v of 1"
    );
    assert!(certificate.is_some());
}

#[test]
fn an_exited_thread_is_no_barrier_operation() {
    let mut s = Scenario::new(2);
    s.exit(1);
    s.barrier(&[0], &[1]);
    s.barrier(&[0], &[1]);
    let (g, _) = s.completed(2);
    assert_eq!(check_named_barrier_epochs(&g).0.verdict(), Verdict::Pass);
}

/// Weft's producer/consumer: the producer arrives, the consumer syncs, twice. With `separated`,
/// the producer waits on a second barrier (synced by the consumer) between its arrivals.
fn producer_consumer(separated: bool) -> EventGraph {
    let mut s = Scenario::new(2);
    let full = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let empty = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 2 });
    s.write(0, 0, 1);
    s.counted_barrier(full, 0, 2, &[0], &[1]);
    s.read(1, 0);
    if separated {
        s.counted_barrier(empty, 0, 2, &[1], &[0]);
    }
    s.write(0, 0, 2);
    s.counted_barrier(full, 1, 2, &[0], &[1]);
    s.read(1, 0);
    s.completed(2).0
}

#[test]
fn a_separated_producer_consumer_passes() {
    let graph = producer_consumer(true);
    let (result, certificate) = check_named_barrier_epochs(&graph);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(certificate.is_some());
}

#[test]
fn an_arrival_that_could_join_the_previous_generation_is_a_violation() {
    let graph = producer_consumer(false);
    let (result, certificate) = check_named_barrier_epochs(&graph);
    let [v] = result.violations() else {
        panic!("Algorithm 1 returns one VIOLATION: {result:?}");
    };
    assert_eq!(graph.thread_of(v.synchronization), Some(ThreadIx(1)));
    assert_eq!(graph.thread_of(v.operation), Some(ThreadIx(0)));
    assert_eq!(
        v.predecessor,
        volta_graph_check::barrier_epoch::predecessor(&graph, v.operation)
    );
    assert_eq!(
        graph.generation(v.generation).index + 1,
        graph.generation(v.next).index
    );
    assert!(
        certificate.is_none(),
        "a failed check issues no certificate"
    );
}

#[test]
fn s_equal_to_p_separates() {
    let mut s = Scenario::new(1);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    s.counted_barrier(bar, 0, 1, &[0], &[]);
    s.counted_barrier(bar, 1, 1, &[0], &[]);
    let (g, _) = s.completed(1);
    assert_eq!(check_named_barrier_epochs(&g).0.verdict(), Verdict::Pass);
}

#[test]
fn an_operation_beginning_its_thread_has_no_predecessor() {
    let mut s = Scenario::new(2);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    s.counted_barrier(bar, 0, 1, &[0], &[]);
    s.counted_barrier(bar, 1, 1, &[1], &[]);
    let (g, _) = s.completed(2);
    let (result, _) = check_named_barrier_epochs(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(v.predecessor, None);
    assert_eq!(g.thread_of(v.operation), Some(ThreadIx(1)));
}

#[test]
fn the_first_violation_in_iteration_order_is_returned() {
    let mut s = Scenario::new(2);
    let low = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let high = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 2 });
    s.counted_barrier(high, 0, 1, &[0], &[]);
    s.counted_barrier(high, 1, 1, &[1], &[]);
    s.counted_barrier(low, 0, 1, &[0], &[]);
    s.counted_barrier(low, 1, 1, &[1], &[]);
    let (g, _) = s.completed(2);
    let (result, _) = check_named_barrier_epochs(&g);
    let [EpochViolation { barrier, .. }] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(
        *barrier, low,
        "barriers are iterated by object, not by trace position"
    );
}

#[test]
fn a_forming_next_generation_is_still_checked() {
    let mut s = Scenario::new(2);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    s.counted_barrier(bar, 0, 2, &[0], &[1]);
    let forming = s.b.open_generation(
        bar,
        1,
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::Count(2),
        },
    );
    s.b.contribute(t(0), PC, forming, ContributionKind::Blocking);
    let (g, _) = s.finish(Terminal::Aborted {
        thread: None,
        pc: None,
        reason: "test".to_string(),
    });
    let (result, _) = check_named_barrier_epochs(&g);
    assert_eq!(result.verdict(), Verdict::Fail, "{result:?}");
}

#[test]
fn mbarrier_phases_are_not_named_barriers() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.complete(p0);
    let p1 = s.phase(m, 1);
    s.wait(1, m, Parity::Even, p0);
    s.arrive(0, p1);
    s.complete(p1);
    let (g, _) = s.completed(2);
    assert_eq!(check_named_barrier_epochs(&g).0.verdict(), Verdict::Pass);
}

#[test]
fn a_malformed_graph_is_unknown() {
    let mut s = Scenario::new(1);
    s.exit(0);
    s.read(0, 0);
    let (g, _) = s.finish(Terminal::Completed);
    let (result, certificate) = check_named_barrier_epochs(&g);
    assert_eq!(result.verdict(), Verdict::Unknown);
    assert!(certificate.is_none());
}
