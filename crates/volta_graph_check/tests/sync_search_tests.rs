//! Algorithm 5, the three-state synchronization search, on its own: its fence predicates and
//! its states, over an assumed-validated `D`.

mod common;

use common::*;
use volta_graph::{AsyncOpId, EventGraph, Parity, SyncObjectKind};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::sync_search::{
    SearchGraph, after_on_target_thread, before_on_source_thread, search,
};

fn searched(graph: &EventGraph, source: AsyncOpId, target: AsyncOpId) -> bool {
    let d = ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph");
    search(&SearchGraph::new(&d), source, target)
}

#[test]
fn the_before_role_is_a_source_thread_before_fence_or_tracking_commit() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    let early_commit = s.arrive(0, p0);
    let (mma, _) = s.mma(0, (0, 8));
    let other_thread = s.tcgen05_before(1);
    let after = s.tcgen05_after(0);
    let before = s.tcgen05_before(0);
    let commit = s.commit(0, p0, &[mma]);
    s.complete(p0);
    let (g, _) = s.completed(2);
    assert!(before_on_source_thread(&g, before, mma));
    assert!(before_on_source_thread(&g, commit, mma));
    assert!(
        !before_on_source_thread(&g, early_commit, mma),
        "an arrival before the issue"
    );
    assert!(!before_on_source_thread(&g, other_thread, mma));
    assert!(!before_on_source_thread(&g, after, mma));
}

#[test]
fn an_arrival_on_a_phase_not_tracking_the_operation_is_no_commit() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    let (mma, _) = s.mma(0, (0, 8));
    let arrival = s.arrive(0, p0);
    s.complete(p0);
    let (g, _) = s.completed(1);
    assert!(!before_on_source_thread(&g, arrival, mma));
}

#[test]
fn the_after_role_is_only_the_target_threads_after_fence() {
    let mut s = Scenario::new(2);
    let mine = s.tcgen05_after(1);
    let theirs = s.tcgen05_after(0);
    let before = s.tcgen05_before(1);
    let (ld, _) = s.tmem_ld(1, 0, (0, 8));
    let (g, _) = s.completed(2);
    assert!(after_on_target_thread(&g, mine, ld));
    assert!(!after_on_target_thread(&g, theirs, ld));
    assert!(!after_on_target_thread(&g, before, ld));
}

#[test]
fn the_search_accepts_only_at_t_in_state_2() {
    let mut s = Scenario::new(1);
    let (first, _) = s.mma(0, (0, 8));
    s.tcgen05_before(0);
    s.tcgen05_after(0);
    let (second, _) = s.tmem_ld(0, 0, (0, 8));
    let (g, _) = s.completed(1);
    assert!(searched(&g, first, second));

    let mut s = Scenario::new(1);
    let (first, _) = s.mma(0, (0, 8));
    s.tcgen05_before(0);
    let (second, _) = s.tmem_ld(0, 0, (0, 8));
    let (g, _) = s.completed(1);
    assert!(
        !searched(&g, first, second),
        "reaching t in state 1 is not acceptance"
    );
}

#[test]
fn the_states_advance_only_in_order() {
    let mut s = Scenario::new(1);
    let (first, _) = s.mma(0, (0, 8));
    s.tcgen05_after(0);
    s.tcgen05_before(0);
    let (second, _) = s.tmem_ld(0, 0, (0, 8));
    let (g, _) = s.completed(1);
    assert!(!searched(&g, first, second));
}

#[test]
fn fences_before_the_source_issue_are_not_on_any_path() {
    let mut s = Scenario::new(1);
    s.tcgen05_before(0);
    s.tcgen05_after(0);
    let (first, _) = s.mma(0, (0, 8));
    let (second, _) = s.tmem_ld(0, 0, (0, 8));
    let (g, _) = s.completed(1);
    assert!(!searched(&g, first, second));
}

#[test]
fn the_witness_path_may_cross_threads_through_validated_joins() {
    let mut s = Scenario::new(3);
    let near = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let far = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 2 });
    let (first, _) = s.mma(0, (0, 8));
    s.tcgen05_before(0);
    s.counted_barrier(near, 0, 2, &[0], &[1]);
    s.counted_barrier(far, 0, 2, &[1], &[2]);
    s.tcgen05_after(2);
    let (second, _) = s.tmem_ld(2, 0, (0, 8));
    let (g, _) = s.completed(3);
    assert!(searched(&g, first, second));
}

#[test]
fn a_commit_then_a_wait_on_its_phase_is_a_witness() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.barrier(&[0, 1], &[]);
    let p0 = s.phase(m, 0);
    let (mma, _) = s.mma(0, (0, 8));
    s.commit(0, p0, &[mma]);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.tcgen05_after(1);
    let (ld, _) = s.tmem_ld(1, 0, (0, 8));
    let (g, _) = s.completed(2);
    assert!(searched(&g, mma, ld));
}
