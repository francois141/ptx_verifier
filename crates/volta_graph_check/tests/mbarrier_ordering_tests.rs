//! Check 3, the sufficient mbarrier ordering check (Algorithm 2), in isolation.

mod common;

use common::*;
use volta_graph::{EventGraph, Parity};
use volta_graph_check::mbarrier_ordering::{OrderingEvidence, check_mbarrier_ordering};
use volta_graph_check::{PropertyResult, Verdict};

fn evidence(g: &EventGraph) -> OrderingEvidence {
    let (result, certificate) = check_mbarrier_ordering(g);
    let PropertyResult::Pass(evidence) = result else {
        panic!("{result:?}");
    };
    assert!(certificate.is_some());
    evidence
}

/// t0 announces and issues two copies, then arrives; t1 waits. Program order protects both
/// announcements.
#[test]
fn announcements_before_the_same_threads_arrival_pass() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.expect_tx(0, p0, 16);
    s.bulk_copy(0, 0x10, p0, 16);
    s.expect_tx(0, p0, 16);
    s.bulk_copy(0, 0x20, p0, 16);
    s.arrive(0, p0);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    let (g, _) = s.completed(2);
    assert_eq!(
        evidence(&g),
        OrderingEvidence {
            completed_phases: 1,
            open_phases: 0,
            announcements: 2,
        }
    );
}

#[test]
fn a_combined_arrive_expect_tx_protects_itself() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive_expect_tx(0, p0, 16);
    s.bulk_copy(0, 0x10, p0, 16);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    let (g, _) = s.completed(2);
    assert_eq!(evidence(&g).announcements, 1);
}

/// The design's example: with the arrival between the announcements, B is unprotected: if
/// A's bytes land before B is announced, the phase completes too early.
#[test]
fn an_arrival_between_two_announcements_leaves_the_second_unprotected() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.expect_tx(0, p0, 16);
    s.bulk_copy(0, 0x10, p0, 16);
    let arrival = s.arrive(0, p0);
    let b = s.expect_tx(0, p0, 16);
    s.bulk_copy(0, 0x20, p0, 16);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    let (g, _) = s.completed(2);
    let (result, certificate) = check_mbarrier_ordering(&g);
    let [unresolved] = result.unresolved() else {
        panic!("{result:?}");
    };
    assert_eq!(unresolved.events, vec![arrival, b]);
    assert!(
        unresolved
            .reason
            .contains("can complete before it is announced"),
        "{}",
        unresolved.reason
    );
    assert!(certificate.is_none());
}

/// t0 announces, t1 arrives: with no synchronization from the announcement to the arrival the
/// check is inconclusive; a barrier between them orders the announcement first.
#[test]
fn an_arrival_on_another_thread_needs_a_path_from_the_announcement() {
    for synchronized in [false, true] {
        let mut s = Scenario::new(2);
        let m = s.mbarrier(0, 1);
        let p0 = s.phase(m, 0);
        let e = s.expect_tx(0, p0, 16);
        s.bulk_copy(0, 0x10, p0, 16);
        if synchronized {
            s.barrier(&[0, 1], &[]);
        }
        let a = s.arrive(1, p0);
        s.complete(p0);
        s.wait(0, m, Parity::Even, p0);
        s.wait(1, m, Parity::Even, p0);
        let (g, _) = s.completed(2);
        let (result, certificate) = check_mbarrier_ordering(&g);
        if synchronized {
            assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
            assert!(certificate.is_some());
        } else {
            let [unresolved] = result.unresolved() else {
                panic!("{result:?}");
            };
            assert_eq!(unresolved.events, vec![e, a]);
            assert!(certificate.is_none());
        }
    }
}

#[test]
fn a_completed_phase_whose_bytes_do_not_balance_fails() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.expect_tx(0, p0, 16);
    s.bulk_copy(0, 0x10, p0, 32);
    s.arrive(0, p0);
    s.complete(p0);
    let (g, _) = s.completed(1);
    let (result, certificate) = check_mbarrier_ordering(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((v.barrier, v.phase), (m, p0));
    assert_eq!((v.expected_arrivals, v.arrivals, v.net_tx), (1, 1, -16));
    assert!(certificate.is_none());
}

#[test]
fn a_completed_phase_with_surplus_arrivals_fails() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.arrive(1, p0);
    s.complete(p0);
    let (g, _) = s.completed(2);
    let (result, _) = check_mbarrier_ordering(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((v.expected_arrivals, v.arrivals, v.net_tx), (1, 2, 0));
}

/// An open phase is certified while arrivals remain; one with every arrival made and bytes
/// still outstanding is inconclusive.
#[test]
fn an_open_phase_is_certified_only_by_a_positive_remaining_arrival_count() {
    for (expected, verdict) in [(2, Verdict::Pass), (1, Verdict::Unknown)] {
        let mut s = Scenario::new(1);
        let m = s.mbarrier(0, expected);
        let p0 = s.phase(m, 0);
        s.arrive_expect_tx(0, p0, 16);
        let (g, _) = s.completed(1);
        let (result, _) = check_mbarrier_ordering(&g);
        assert_eq!(result.verdict(), verdict, "{result:?}");
        if let PropertyResult::Pass(evidence) = &result {
            assert_eq!(evidence.open_phases, 1);
        }
    }
}

#[test]
fn the_pre_init_phase_and_other_sync_objects_are_no_candidates() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.pre_init(m);
    s.barrier(&[0, 1], &[]);
    let (g, _) = s.completed(2);
    assert_eq!(
        evidence(&g),
        OrderingEvidence {
            completed_phases: 0,
            open_phases: 0,
            announcements: 0,
        }
    );
}

/// `tcgen05.commit` arrives without announcing bytes: its tracked completions count none.
#[test]
fn a_commit_tracking_an_mma_announces_no_bytes() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    let (op, _) = s.mma(0, (0, 32));
    s.commit(0, p0, &[op]);
    s.complete(p0);
    let (g, _) = s.completed(1);
    assert_eq!(
        evidence(&g),
        OrderingEvidence {
            completed_phases: 1,
            open_phases: 0,
            announcements: 0,
        }
    );
}
