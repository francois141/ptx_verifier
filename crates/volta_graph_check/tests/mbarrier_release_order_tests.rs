//! Check 10, mbarrier release order, in isolation and through the suite.

mod common;

use common::*;
use volta_graph::{EventGraph, EventId, GenerationId, Parity};
use volta_graph_check::mbarrier_release_order::{
    ReleaseOrderEvidence, ReleaseOrderViolation, check_mbarrier_release_order,
};
use volta_graph_check::{GraphConclusion, Property, PropertyResult, Verdict, check_graph};

#[test]
fn one_waiter_observing_every_phase_from_phase_0_passes() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    for (index, parity) in [(0, Parity::Even), (1, Parity::Odd), (2, Parity::Even)] {
        let p = s.phase(m, index);
        s.arrive(0, p);
        s.complete(p);
        s.wait(1, m, parity, p);
    }
    assert_eq!(
        check_mbarrier_release_order(&s.completed(2).0),
        PropertyResult::Pass(ReleaseOrderEvidence {
            lifetimes: 1,
            released_phases: 3,
            releases: 3
        })
    );
}

/// t1 and t2 both wait on phases 0 and 1, never ordered with each other within a phase; a
/// barrier orders both phase-0 releases before t0's phase-1 arrival.
#[test]
fn the_waiters_of_one_phase_need_no_order_among_themselves() {
    let mut s = Scenario::new(3);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.wait(2, m, Parity::Even, p0);
    s.barrier(&[0, 1, 2], &[]);
    let p1 = s.phase(m, 1);
    s.arrive(0, p1);
    s.complete(p1);
    s.wait(2, m, Parity::Odd, p1);
    s.wait(1, m, Parity::Odd, p1);
    assert_eq!(
        check_mbarrier_release_order(&s.completed(3).0).verdict(),
        Verdict::Pass
    );
}

#[test]
fn every_lifetime_starts_from_its_own_phase_0() {
    let mut s = Scenario::new(2);
    for _ in 0..2 {
        let m = s.mbarrier(0, 1);
        let p0 = s.phase(m, 0);
        s.arrive(0, p0);
        s.complete(p0);
        s.wait(1, m, Parity::Even, p0);
    }
    let result = check_mbarrier_release_order(&s.completed(2).0);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

/// The shape of `inflight_complete_tx_lets_parity_wait_return_early`: nobody waits on phase 0
/// (an `arrive.expect_tx` and a bulk copy), and t1's first wait, of parity 1, is released by
/// phase 1. Had t1 started it while the copy was in flight, it returned through the pre-init
/// phase. Returns the graph and t1's release.
fn first_wait_of_phase_1() -> (EventGraph, EventId) {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive_expect_tx(0, p0, 16);
    s.bulk_copy(0, 0x40, p0, 16);
    s.complete(p0);
    s.barrier(&[0, 1], &[]);
    s.write(0, 0x10, 7);
    let p1 = s.phase(m, 1);
    s.arrive(0, p1);
    s.complete(p1);
    let release = s.wait(1, m, Parity::Odd, p1);
    s.read(1, 0x10);
    (s.completed(2).0, release)
}

#[test]
fn a_first_release_of_phase_1_fails() {
    let (g, release) = first_wait_of_phase_1();
    let [ReleaseOrderViolation::LateStart { phase, release: r }] =
        *check_mbarrier_release_order(&g).violations()
    else {
        panic!("{:?}", check_mbarrier_release_order(&g));
    };
    assert_eq!((g.generation(phase).index, r), (1, release));
}

/// The barrier-epoch, mbarrier-ordering and memory-conflict checks all pass on it: the new
/// check alone rejects it.
#[test]
fn a_first_release_of_phase_1_is_rejected_by_this_check_alone() {
    let r = check_graph(&first_wait_of_phase_1().0);
    let GraphConclusion::Rejected { failed, deadlock } = r.conclusion() else {
        panic!("{:?}", r.conclusion());
    };
    let failed: Vec<Property> = failed.iter().map(|s| s.property).collect();
    assert_eq!(failed, [Property::MbarrierReleaseOrder]);
    assert_eq!(deadlock, None);
}

/// The CUTLASS producer's first parity-1 wait on a fresh `empty` barrier returns through the
/// pre-init phase; with `phase_0_released`, its next wait is of phase 0, else of phase 1.
/// Returns the graph, the pre-init phase, phase 1 and the release of the second wait.
fn producer_through_pre_init(
    phase_0_released: bool,
) -> (EventGraph, GenerationId, GenerationId, EventId) {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let pre = s.pre_init(m);
    s.wait(0, m, Parity::Odd, pre);
    let p0 = s.phase(m, 0);
    s.arrive(1, p0);
    s.complete(p0);
    if phase_0_released {
        s.wait(0, m, Parity::Even, p0);
    }
    let p1 = s.phase(m, 1);
    s.arrive(1, p1);
    s.complete(p1);
    let release = s.wait(0, m, Parity::Odd, p1);
    (s.completed(2).0, pre, p1, release)
}

#[test]
fn a_lifetime_may_start_through_its_pre_init_phase() {
    let (g, ..) = producer_through_pre_init(true);
    let result = check_mbarrier_release_order(&g);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn a_pre_init_start_still_needs_a_release_of_phase_0() {
    let (g, pre, p1, release) = producer_through_pre_init(false);
    assert_eq!(
        check_mbarrier_release_order(&g).violations(),
        [ReleaseOrderViolation::SkippedPhase {
            previous: pre,
            phase: p1,
            release
        }]
    );
}

/// Phase 1 completes with nobody waiting, so t1's wait of phase 2 has no release of phase 1
/// to witness that phase complete when it starts.
#[test]
fn a_phase_released_after_a_phase_that_released_nobody_fails() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    let p1 = s.phase(m, 1);
    s.arrive(0, p1);
    s.complete(p1);
    let p2 = s.phase(m, 2);
    s.arrive(0, p2);
    s.complete(p2);
    let release = s.wait(1, m, Parity::Even, p2);
    assert_eq!(
        check_mbarrier_release_order(&s.completed(2).0).violations(),
        [ReleaseOrderViolation::SkippedPhase {
            previous: p0,
            phase: p2,
            release
        }]
    );
}

/// t1 waits on phase 0, t2 on phase 1; with `handoff`, a barrier between t1 and t2 orders
/// t1's release first. Returns the graph and both releases.
fn handoff_between_waiters(handoff: bool) -> (EventGraph, EventId, EventId) {
    let mut s = Scenario::new(3);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.complete(p0);
    let earlier = s.wait(1, m, Parity::Even, p0);
    if handoff {
        s.barrier(&[1, 2], &[]);
    }
    let p1 = s.phase(m, 1);
    s.arrive(0, p1);
    s.complete(p1);
    let later = s.wait(2, m, Parity::Odd, p1);
    (s.completed(3).0, earlier, later)
}

#[test]
fn a_release_handed_off_to_the_next_phases_waiter_passes() {
    let (g, ..) = handoff_between_waiters(true);
    let result = check_mbarrier_release_order(&g);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn releases_of_consecutive_phases_unordered_fail() {
    let (g, earlier, later) = handoff_between_waiters(false);
    assert_eq!(
        check_mbarrier_release_order(&g).violations(),
        [ReleaseOrderViolation::Unordered { earlier, later }]
    );
}
