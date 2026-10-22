//! Check 2, the barrier-epoch check over mbarrier phases (Algorithm 1), in isolation.

mod common;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, ContributionKind, EventGraph, EventKind, Parity, Proxy,
    SyncObjectKind, ThreadIx,
};
use volta_graph_check::Verdict;
use volta_graph_check::barrier_epoch::check_mbarrier_epochs;

#[test]
fn a_single_phase_mbarrier_passes_and_is_certified() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.write(0, 0, 1);
    s.arrive(0, p0);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.read(1, 0);
    let (g, _) = s.completed(2);
    let (result, certificate) = check_mbarrier_epochs(&g);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(certificate.is_some());
}

/// Two phases of `full` (expected 1): t0 arrives on each, t1 waits on each. With
/// `handshake`, t1 arrives on `empty` after its first wait and t0 waits on it before its
/// second arrival.
fn two_phase_pipeline(handshake: bool) -> EventGraph {
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
fn a_handshaked_pipeline_passes() {
    let graph = two_phase_pipeline(true);
    let (result, certificate) = check_mbarrier_epochs(&graph);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(certificate.is_some());
}

#[test]
fn an_arrival_unseparated_from_the_previous_phases_wait_is_a_violation() {
    let graph = two_phase_pipeline(false);
    let (result, certificate) = check_mbarrier_epochs(&graph);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(graph.thread_of(v.synchronization), Some(ThreadIx(1)));
    assert!(
        matches!(graph.event(v.synchronization).kind, EventKind::Resume(_)),
        "a wait takes part in its phase through its release"
    );
    assert_eq!(graph.thread_of(v.operation), Some(ThreadIx(0)));
    assert!(matches!(
        graph.event(v.operation).kind,
        EventKind::Contribute(_)
    ));
    assert!(certificate.is_none());
}

#[test]
fn a_wait_begins_at_its_wait_start() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.complete(p0);
    let p1 = s.phase(m, 1);
    s.arrive(0, p1);
    s.complete(p1);
    s.wait(1, m, Parity::Odd, p1);
    let (g, _) = s.completed(2);
    let (result, _) = check_mbarrier_epochs(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert!(matches!(
        g.event(v.operation).kind,
        EventKind::WaitStart { .. }
    ));
    assert_eq!(v.predecessor, None, "the wait begins thread 1");
}

#[test]
fn a_wait_through_the_pre_init_phase_before_phase_0s_arrival_passes() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 1);
    let pre = s.pre_init(m);
    let p0 = s.phase(m, 0);
    s.wait(0, m, Parity::Odd, pre);
    s.arrive(0, p0);
    s.complete(p0);
    let (g, _) = s.completed(1);
    let (result, _) = check_mbarrier_epochs(&g);
    let volta_graph_check::PropertyResult::Pass(evidence) = &result else {
        panic!("{result:?}");
    };
    assert_eq!(
        evidence.generation_pairs, 1,
        "the pre-init phase pairs with phase 0"
    );
}

/// t0 and t1 both return through the pre-init phase, then t1 arrives: had t1 arrived before
/// t0 waited, t0's odd-parity wait would bind phase 1 instead.
#[test]
fn an_arrival_unseparated_from_a_pre_init_wait_is_a_violation() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let pre = s.pre_init(m);
    let p0 = s.phase(m, 0);
    s.barrier(&[0, 1], &[]);
    let early = s.wait(0, m, Parity::Odd, pre);
    s.wait(1, m, Parity::Odd, pre);
    let arrival = s.arrive(1, p0);
    s.complete(p0);
    let (g, _) = s.completed(2);
    let (result, certificate) = check_mbarrier_epochs(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((v.generation, v.next), (pre, p0));
    assert_eq!((v.synchronization, v.operation), (early, arrival));
    assert!(certificate.is_none());
}

/// t1 arrives with nothing ordering t0's init first: on a schedule where t1 runs first, its
/// arrive operates on an uninitialized object.
#[test]
fn an_arrival_unordered_after_the_init_is_a_violation() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let pre = s.pre_init(m);
    let p0 = s.phase(m, 0);
    let arrival = s.arrive(1, p0);
    s.complete(p0);
    s.wait(0, m, Parity::Even, p0);
    let (g, _) = s.completed(2);
    let (result, _) = check_mbarrier_epochs(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((v.generation, v.next), (pre, p0));
    assert_eq!(
        (Some(v.synchronization), v.operation),
        (g.object(m).init, arrival)
    );
}

#[test]
fn a_complete_tx_is_a_barrier_operation() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.b.contribute(t(1), PC, p0, ContributionKind::CompleteTx { bytes: 4 });
    s.arrive(0, p0);
    s.complete(p0);
    let p1 = s.phase(m, 1);
    s.b.contribute(t(0), PC, p1, ContributionKind::CompleteTx { bytes: 4 });
    s.arrive(0, p1);
    s.complete(p1);
    let (g, _) = s.completed(2);
    let (result, _) = check_mbarrier_epochs(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(g.thread_of(v.synchronization), Some(ThreadIx(1)));
}

#[test]
fn an_async_completion_is_no_barrier_operation() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.complete(p0);
    let p1 = s.phase(m, 1);
    let op = s.async_op(
        0,
        AsyncOpKind::BulkCopy,
        AccessMode::Write,
        0x40,
        Proxy::Async,
    );
    s.b.track(op, p1, 4);
    s.arrive(0, p1);
    s.complete(p1);
    let (g, _) = s.completed(1);
    assert_eq!(check_mbarrier_epochs(&g).0.verdict(), Verdict::Pass);
}

#[test]
fn each_mbarrier_lifetime_is_its_own_barrier() {
    let mut s = Scenario::new(2);
    let first = s.mbarrier(0, 1);
    let p0 = s.phase(first, 0);
    s.arrive(0, p0);
    s.complete(p0);
    let second = s.mbarrier(1, 1);
    let q0 = s.phase(second, 0);
    s.arrive(1, q0);
    s.complete(q0);
    let (g, _) = s.completed(2);
    let (result, _) = check_mbarrier_epochs(&g);
    let volta_graph_check::PropertyResult::Pass(evidence) = &result else {
        panic!("{result:?}");
    };
    assert_eq!((evidence.barriers, evidence.generation_pairs), (2, 0));
}

#[test]
fn named_barriers_are_not_mbarriers() {
    let mut s = Scenario::new(2);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    s.counted_barrier(bar, 0, 1, &[0], &[]);
    s.counted_barrier(bar, 1, 1, &[1], &[]);
    let (g, _) = s.completed(2);
    assert_eq!(check_mbarrier_epochs(&g).0.verdict(), Verdict::Pass);
}

/// `full` (expected 1) is waited on by t1 and t2 each phase; both arrive on `empty`
/// (expected 2), which t0 waits on before its second `full` arrival. Nothing orders t1's
/// release from a phase before t2's next wait, which the completion rule does not need.
#[test]
fn a_phases_waiters_need_no_order_among_themselves() {
    let mut s = Scenario::new(3);
    let full = s.mbarrier(0, 1);
    let empty = s.mbarrier(0, 2);
    let f0 = s.phase(full, 0);
    let e0 = s.phase(empty, 0);
    s.arrive(0, f0);
    s.complete(f0);
    s.wait(1, full, Parity::Even, f0);
    s.wait(2, full, Parity::Even, f0);
    s.arrive(1, e0);
    s.arrive(2, e0);
    s.complete(e0);
    s.wait(0, empty, Parity::Even, e0);
    let f1 = s.phase(full, 1);
    s.arrive(0, f1);
    s.complete(f1);
    s.wait(1, full, Parity::Odd, f1);
    s.wait(2, full, Parity::Odd, f1);
    let (g, _) = s.completed(3);
    let (result, certificate) = check_mbarrier_epochs(&g);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(certificate.is_some());
}

/// Phase 0 of `m` released only t1, who then hands off to t0 and t2 through `h`: t2's
/// phase-1 wait follows phase 0's completion through t1's release, not one of its own.
#[test]
fn a_wait_after_another_waiters_release_passes() {
    let mut s = Scenario::new(3);
    let m = s.mbarrier(0, 1);
    let h = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    let h0 = s.phase(h, 0);
    s.arrive(0, p0);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.arrive(1, h0);
    s.complete(h0);
    s.wait(0, h, Parity::Even, h0);
    s.wait(2, h, Parity::Even, h0);
    let p1 = s.phase(m, 1);
    s.arrive(0, p1);
    s.complete(p1);
    s.wait(2, m, Parity::Odd, p1);
    let (g, _) = s.completed(3);
    let (result, certificate) = check_mbarrier_epochs(&g);
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(certificate.is_some());
}

/// t1's release handed off to t0 orders t0's second arrival, but t2's phase-1 wait follows
/// no release of phase 0: started before phase 0 completes, it returns through the pre-init
/// phase. The violation names the release phase 0's completion had to reach t2 through.
#[test]
fn a_wait_unordered_after_the_previous_phases_completion_is_a_violation() {
    let mut s = Scenario::new(3);
    let full = s.mbarrier(0, 1);
    let empty = s.mbarrier(0, 1);
    let f0 = s.phase(full, 0);
    let e0 = s.phase(empty, 0);
    s.arrive(0, f0);
    s.complete(f0);
    let released = s.wait(1, full, Parity::Even, f0);
    s.arrive(1, e0);
    s.complete(e0);
    s.wait(0, empty, Parity::Even, e0);
    let f1 = s.phase(full, 1);
    s.arrive(0, f1);
    s.complete(f1);
    let before = s.read(2, 0);
    s.wait(2, full, Parity::Odd, f1);
    let (g, _) = s.completed(3);
    let (result, certificate) = check_mbarrier_epochs(&g);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((v.generation, v.next), (f0, f1));
    assert_eq!(v.synchronization, released);
    assert!(matches!(
        g.event(v.operation).kind,
        EventKind::WaitStart { .. }
    ));
    assert_eq!(v.predecessor, Some(before));
    assert!(certificate.is_none());
}
