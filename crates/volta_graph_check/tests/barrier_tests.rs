//! The barrier-protocol checker in isolation, on purpose-built graphs.

mod common;

use common::*;
use volta_graph::{
    BarrierArrivals, CollectiveSide, ContributionKind, GenerationEvidence, GenerationKind, Parity,
    SyncObjectKind, Terminal, ThreadIx,
};
use volta_graph_check::Verdict;
use volta_graph_check::barrier::{BarrierViolation, check_barriers};

#[test]
fn a_reused_full_cta_barrier_passes() {
    let mut s = Scenario::new(2);
    s.write(0, 0, 1);
    s.barrier(&[0, 1], &[]);
    s.read(1, 0);
    s.barrier(&[0, 1], &[]);
    let (g, _) = s.completed(2);
    let (result, cert) = check_barriers(&g);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(cert.generations.is_all());
}

#[test]
fn an_exited_thread_completes_a_full_cta_barrier() {
    let mut s = Scenario::new(2);
    s.exit(1);
    s.barrier(&[0], &[1]);
    let (g, _) = s.completed(2);
    assert_eq!(check_barriers(&g).0.verdict(), Verdict::Pass);
}

#[test]
fn a_full_cta_barrier_missing_a_thread_is_miscounted() {
    let mut s = Scenario::new(2);
    s.barrier(&[0], &[]);
    let (g, _) = s.completed(2);
    let (result, cert) = check_barriers(&g);
    assert_eq!(result.verdict(), Verdict::Fail);
    assert!(matches!(
        result.violations()[0],
        BarrierViolation::Miscounted { .. }
    ));
    assert!(!cert.generations.is_all());
}

/// Weft's producer/consumer: the producer arrives, the consumer syncs, twice. With `separated`,
/// the producer waits on a second barrier (synced by the consumer) between its arrivals.
fn producer_consumer(separated: bool) -> volta_graph::EventGraph {
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
    let (result, _) = check_barriers(&producer_consumer(true));
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn an_arrival_that_could_join_the_previous_generation_fails() {
    let graph = producer_consumer(false);
    let (result, cert) = check_barriers(&graph);
    assert_eq!(result.verdict(), Verdict::Fail);
    let BarrierViolation::Unseparated { op, .. } = result.violations()[0] else {
        panic!("{result:?}");
    };
    assert_eq!(graph.thread_of(op), Some(ThreadIx(0)));
    assert!(!cert.generations.is_all());
}

#[test]
fn an_over_subscribed_generation_fails() {
    let mut s = Scenario::new(3);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let g = s.b.open_generation(
        bar,
        0,
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::Count(2),
        },
    );
    for th in 0..3 {
        s.b.contribute(t(th), PC, g, ContributionKind::Blocking);
    }
    let (graph, _) = s.finish(Terminal::Aborted {
        thread: None,
        pc: Some(PC),
        reason: "3 threads arrived at barrier 1, which fires on 2".to_string(),
    });
    let (result, _) = check_barriers(&graph);
    assert!(matches!(
        result.violations(),
        [BarrierViolation::OverSubscribed {
            arrivals: 3,
            count: 2,
            ..
        }]
    ));
}

#[test]
fn a_single_phase_mbarrier_passes() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.write(0, 0, 1);
    s.arrive(0, p0);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.read(1, 0);
    let (g, _) = s.completed(2);
    assert_eq!(check_barriers(&g).0.verdict(), Verdict::Pass);
}

/// Two phases of `full` (expected 1): t0 arrives on each, t1 waits on each. With
/// `handshake`, t1 arrives on `empty` after its first wait and t0 waits on it before its
/// second arrival.
fn two_phase_pipeline(handshake: bool) -> volta_graph::EventGraph {
    let mut s = Scenario::new(2);
    let full = s.mbarrier(0, 1);
    let empty = s.mbarrier(0, 1);
    let f0 = s.phase(full, 0);
    let e0 = s.phase(empty, 0);
    s.arrive(0, f0);
    s.complete(f0);
    let f1 = s.phase(full, 1);
    s.wait(1, full, Parity::Even, f0);
    if handshake {
        s.arrive(1, e0);
        s.complete(e0);
        s.wait(0, empty, Parity::Even, e0);
    }
    s.arrive(0, f1);
    s.complete(f1);
    s.wait(1, full, Parity::Odd, f1);
    s.completed(2).0
}

#[test]
fn a_handshaked_mbarrier_pipeline_passes() {
    let (result, cert) = check_barriers(&two_phase_pipeline(true));
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(cert.generations.is_all());
}

#[test]
fn an_unordered_next_phase_arrival_is_unknown() {
    let (result, cert) = check_barriers(&two_phase_pipeline(false));
    assert_eq!(result.verdict(), Verdict::Unknown, "{result:?}");
    assert!(
        result
            .unresolved()
            .iter()
            .any(|u| u.reason.contains("previous phase"))
    );
    assert!(!cert.generations.is_all());
}

#[test]
fn an_arrival_after_inval_is_outside_the_lifetime() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 2);
    let p0 = s.phase(m, 0);
    s.b.object_inval(t(0), PC, m);
    s.arrive(0, p0);
    let (g, _) = s.completed(1);
    let (result, _) = check_barriers(&g);
    assert!(matches!(
        result.violations(),
        [BarrierViolation::OutsideLifetime { .. }]
    ));
}

#[test]
fn a_collective_whose_exit_releases_a_non_member_fails() {
    let mut s = Scenario::new(2);
    let warp = s.b.sync_object(SyncObjectKind::WarpCollective { warp: 0 });
    let kind = |side| GenerationKind::Collective {
        pc: PC,
        mask: 0b11,
        side,
    };
    let entry = s.b.open_generation(warp, 0, kind(CollectiveSide::Entry));
    for th in 0..2 {
        s.b.contribute(t(th), PC, entry, ContributionKind::Blocking);
    }
    s.b.complete_generation(entry, GenerationEvidence::default());
    for th in 0..2 {
        s.b.resume(t(th), PC, entry);
    }
    let exit = s.b.open_generation(warp, 0, kind(CollectiveSide::Exit));
    s.b.contribute(t(0), PC, exit, ContributionKind::Blocking);
    s.b.complete_generation(exit, GenerationEvidence::default());
    s.b.resume(t(0), PC, exit);
    s.b.resume(t(1), PC, exit);
    let (g, _) = s.completed(2);
    let (result, _) = check_barriers(&g);
    assert_eq!(result.verdict(), Verdict::Fail, "{result:?}");
}
