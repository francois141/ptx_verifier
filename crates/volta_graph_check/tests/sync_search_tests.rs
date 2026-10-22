//! Algorithm 6, the three-state synchronization search, on its own: its fence predicates and
//! its states, over an assumed-validated `D`.

mod common;

use common::*;
use volta_graph::{AsyncOpId, EventGraph, Parity, SyncObjectKind};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::sync_search::{
    Origin, SearchGraph, after_on_target_thread, before_on_source_thread, search,
};

fn searched_from(graph: &EventGraph, source: AsyncOpId, target: AsyncOpId, origin: Origin) -> bool {
    let d = ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph");
    search(&SearchGraph::new(&d), source, target, origin)
}

/// The design's search, from the source's issue: the fence protocol alone.
fn searched(graph: &EventGraph, source: AsyncOpId, target: AsyncOpId) -> bool {
    searched_from(graph, source, target, Origin::Issue)
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
    assert!(
        searched_from(&g, mma, ld, Origin::Completion),
        "the commit supplies the before role of a path from the MMA's completion"
    );
}

/// t0's MMA committed to a phase, the barrier with t1 before anyone waits on it, then t1's
/// fenced load: the issues are ordered, the completion is not.
#[test]
fn a_completion_search_needs_a_release_observing_it() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.barrier(&[0, 1], &[]);
    let p0 = s.phase(m, 0);
    let (mma, _) = s.mma(0, (0, 8));
    s.commit(0, p0, &[mma]);
    s.complete(p0);
    s.barrier(&[0, 1], &[]);
    s.tcgen05_after(1);
    let (ld, _) = s.tmem_ld(1, 0, (0, 8));
    s.wait(0, m, Parity::Even, p0);
    let (g, _) = s.completed(2);
    assert!(searched(&g, mma, ld));
    assert!(!searched_from(&g, mma, ld, Origin::Completion));
}

#[test]
fn an_operation_never_completed_has_no_completion_origin() {
    let mut s = Scenario::new(2);
    let (mma, _) = s.mma(0, (0, 8));
    s.tcgen05_before(0);
    s.barrier(&[0, 1], &[]);
    s.tcgen05_after(1);
    let (ld, _) = s.tmem_ld(1, 0, (0, 8));
    let (g, _) = s.completed(2);
    assert!(searched(&g, mma, ld));
    assert!(!searched_from(&g, mma, ld, Origin::Completion));
}

/// t0's `tcgen05.ld` waited for, then (when `fenced`) a before fence, the barrier with t1 and
/// t1's fenced MMA over the same cells.
fn waited_load_then_mma(fenced: bool) -> (EventGraph, AsyncOpId, AsyncOpId) {
    let mut s = Scenario::new(2);
    let (ld, _) = s.tmem_ld(0, 0, (0, 8));
    s.warp_wait(0, &[0], &[ld]);
    if fenced {
        s.tcgen05_before(0);
    }
    s.barrier(&[0, 1], &[]);
    s.tcgen05_after(1);
    let (mma, _) = s.mma(1, (0, 8));
    (s.completed(2).0, ld, mma)
}

#[test]
fn a_loads_completion_still_needs_a_before_fence_after_its_wait() {
    let (g, ld, mma) = waited_load_then_mma(false);
    assert!(!searched_from(&g, ld, mma, Origin::Completion));
    let (g, ld, mma) = waited_load_then_mma(true);
    assert!(searched_from(&g, ld, mma, Origin::Completion));
}
