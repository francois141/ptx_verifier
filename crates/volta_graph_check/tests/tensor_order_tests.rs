//! Check 6, tensor-operation ordering (Algorithm 5), in isolation over an assumed-validated
//! `D`. Algorithm 6's search on its own is `sync_search_tests.rs`.

mod common;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, EventGraph, Footprint, MemAccess, OperandRole, OrderingKind, Parity,
    Proxy, Space,
};
use volta_graph_check::domain::{ConflictKind, TmemCell};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::tensor_order::{TensorOrderResult, check_tensor_order};
use volta_graph_check::{PropertyResult, Verdict};

fn check(graph: &EventGraph) -> TensorOrderResult {
    check_tensor_order(&ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph"))
}

fn evidence(result: &TensorOrderResult) -> (u64, u64, u64) {
    match result {
        PropertyResult::Pass(e) => (e.conflicts, e.pipelined, e.synchronized),
        other => panic!("{other:?}"),
    }
}

#[test]
fn a_pipelined_accumulator_chain_needs_no_fence() {
    let mut s = Scenario::new(1);
    s.mma(0, (0, 8));
    s.mma(0, (0, 8));
    s.mma(0, (0, 8));
    let (g, _) = s.completed(1);
    assert_eq!(evidence(&check(&g)), (3, 3, 0));
}

#[test]
fn mmas_of_two_threads_on_one_accumulator_need_the_fence_protocol() {
    let mut s = Scenario::new(2);
    let (_, first) = s.mma(0, (0, 8));
    s.barrier(&[0, 1], &[]);
    let (_, second) = s.mma(1, (0, 8));
    let (g, _) = s.completed(2);
    let result = check(&g);
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((c.earlier, c.later), (first, second));
    assert_eq!(c.kind, ConflictKind::WriteWrite);
    assert_eq!(c.cell, TmemCell { lane: 0, col: 0 });
}

/// t0's MMA, then a barrier, then t1's MMA on the same accumulator, with the given fences.
fn fenced_handoff(before: bool, after: bool) -> EventGraph {
    let mut s = Scenario::new(2);
    s.mma(0, (0, 8));
    if before {
        s.tcgen05_before(0);
    }
    s.barrier(&[0, 1], &[]);
    if after {
        s.tcgen05_after(1);
    }
    s.mma(1, (0, 8));
    s.completed(2).0
}

#[test]
fn both_fences_around_a_thread_sync_order_the_pair() {
    assert_eq!(evidence(&check(&fenced_handoff(true, true))), (1, 0, 1));
}

#[test]
fn either_fence_alone_leaves_the_pair_unproved() {
    for (before, after) in [(true, false), (false, true), (false, false)] {
        assert_eq!(
            check(&fenced_handoff(before, after)).verdict(),
            Verdict::Fail,
            "before={before} after={after}"
        );
    }
}

#[test]
fn an_after_fence_before_the_sync_does_not_count() {
    let mut s = Scenario::new(2);
    s.mma(0, (0, 8));
    s.tcgen05_before(0);
    s.tcgen05_after(1);
    s.barrier(&[0, 1], &[]);
    s.mma(1, (0, 8));
    let (g, _) = s.completed(2);
    assert_eq!(check(&g).verdict(), Verdict::Fail);
}

/// t0's MMA committed to an mbarrier phase t1 waits on, then t1's `tcgen05.ld` of the
/// accumulator, after an after-fence when `fenced`.
fn commit_then_load(fenced: bool) -> EventGraph {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.barrier(&[0, 1], &[]);
    let p0 = s.phase(m, 0);
    let (mma, _) = s.mma(0, (0, 8));
    s.commit(0, p0, &[mma]);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    if fenced {
        s.tcgen05_after(1);
    }
    s.tmem_ld(1, 0, (0, 8));
    s.completed(2).0
}

#[test]
fn a_tracking_commit_supplies_the_before_role() {
    assert_eq!(evidence(&check(&commit_then_load(true))), (1, 0, 1));
}

/// t1's wait on the commit's phase is an acquire (the ISA's default `.sem`): it pairs with the
/// commit's release and supplies the after role without the fence.
#[test]
fn a_waiters_acquire_supplies_the_after_role() {
    assert_eq!(evidence(&check(&commit_then_load(false))), (1, 0, 1));
}

/// t0's MMA committed to a phase, then a barrier with t1 and t1's fenced load of the
/// accumulator; t0 observes the completion before the barrier when `waited`, else after.
fn committed_mma_then_barrier_load(waited: bool) -> EventGraph {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.barrier(&[0, 1], &[]);
    let p0 = s.phase(m, 0);
    let (mma, _) = s.mma(0, (0, 8));
    s.commit(0, p0, &[mma]);
    s.complete(p0);
    if waited {
        s.wait(0, m, Parity::Even, p0);
    }
    s.barrier(&[0, 1], &[]);
    s.tcgen05_after(1);
    s.tmem_ld(1, 0, (0, 8));
    if !waited {
        s.wait(0, m, Parity::Even, p0);
    }
    s.completed(2).0
}

/// An MMA and a load are not pipelined: fences around a barrier order their issues only, so
/// the MMA's completion must be observed before the barrier (PTX ISA 9.7.18.6.4.4).
#[test]
fn a_barrier_before_the_mmas_completion_is_observed_orders_no_load() {
    let result = check(&committed_mma_then_barrier_load(false));
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(c.kind, ConflictKind::WriteRead);
    assert_eq!(
        evidence(&check(&committed_mma_then_barrier_load(true))),
        (1, 0, 1)
    );
}

/// t0 observes the MMA's completion and a barrier carries it to t1, whose after fence comes
/// before that barrier: it orders nothing, and a `bar.sync` is no acquire.
#[test]
fn an_after_fence_before_the_synchronization_does_not_count() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.barrier(&[0, 1], &[]);
    let p0 = s.phase(m, 0);
    let (mma, _) = s.mma(0, (0, 8));
    s.commit(0, p0, &[mma]);
    s.complete(p0);
    s.wait(0, m, Parity::Even, p0);
    s.tcgen05_after(1);
    s.barrier(&[0, 1], &[]);
    s.tmem_ld(1, 0, (0, 8));
    let (g, _) = s.completed(2);
    assert_eq!(check(&g).verdict(), Verdict::Fail);
}

/// A barrier carries the MMA's completion to t1, which then waits on a phase t0 completed
/// before observing the MMA: that acquire pairs with no release after the MMA, so the
/// barrier's order still needs the after fence.
#[test]
fn an_acquire_of_a_phase_the_mma_does_not_reach_does_not_count() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let other = s.mbarrier(0, 1);
    s.barrier(&[0, 1], &[]);
    let p0 = s.phase(m, 0);
    let q0 = s.phase(other, 0);
    let (mma, _) = s.mma(0, (0, 8));
    s.commit(0, p0, &[mma]);
    s.arrive(0, q0);
    s.complete(q0);
    s.complete(p0);
    s.wait(0, m, Parity::Even, p0);
    s.barrier(&[0, 1], &[]);
    s.wait(1, other, Parity::Even, q0);
    s.tmem_ld(1, 0, (0, 8));
    let (g, _) = s.completed(2);
    assert_eq!(check(&g).verdict(), Verdict::Fail);
}

/// Warp 0's store, then a before fence, a barrier with thread 32 and its fenced load of the
/// stored cells; warp 0 waits for the store before the fence when `waited`, else after.
fn store_then_other_warps_load(waited: bool) -> EventGraph {
    let mut s = Scenario::new(33);
    let (st, _) = s.tmem_st(0, 0, (0, 8));
    if waited {
        s.warp_wait(0, &[0], &[st]);
    }
    s.tcgen05_before(0);
    s.barrier(&[0, 32], &[]);
    s.tcgen05_after(32);
    s.tmem_ld(32, 0, (0, 8));
    if !waited {
        s.warp_wait(0, &[0], &[st]);
    }
    s.completed(33).0
}

/// Operations of different warps are never pipelined (PTX ISA 9.7.18.6.2).
#[test]
fn a_store_and_another_warps_load_need_the_wait_before_the_sync() {
    let result = check(&store_then_other_warps_load(false));
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(c.kind, ConflictKind::WriteRead);
    assert_eq!(
        evidence(&check(&store_then_other_warps_load(true))),
        (1, 0, 1)
    );
}

#[test]
fn a_waited_store_then_load_of_one_warp_is_pipelined() {
    let mut s = Scenario::new(1);
    let (st, _) = s.tmem_st(0, 0, (0, 1));
    s.warp_wait(0, &[0], &[st]);
    s.tmem_ld(0, 0, (0, 1));
    let (g, _) = s.completed(1);
    assert_eq!(evidence(&check(&g)), (1, 1, 0));
}

#[test]
fn an_unwaited_store_then_load_needs_the_fence_protocol() {
    let mut s = Scenario::new(1);
    s.tmem_st(0, 0, (0, 1));
    s.tmem_ld(0, 0, (0, 1));
    let (g, _) = s.completed(1);
    let result = check(&g);
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(c.kind, ConflictKind::WriteRead);
}

#[test]
fn a_waited_store_then_an_mma_still_needs_the_fence_protocol() {
    let mut s = Scenario::new(1);
    let (st, _) = s.tmem_st(0, 0, (0, 8));
    s.warp_wait(0, &[0], &[st]);
    s.mma(0, (0, 8));
    let (g, _) = s.completed(1);
    assert_eq!(check(&g).verdict(), Verdict::Fail);
}

#[test]
fn pairs_are_oriented_by_issue_order() {
    let mut s = Scenario::new(2);
    let (_, read) = s.tmem_ld(0, 0, (0, 8));
    let (_, write) = s.mma(1, (0, 8));
    let (g, _) = s.completed(2);
    let result = check(&g);
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((c.earlier, c.later), (read, write));
    assert_eq!(c.kind, ConflictKind::ReadWrite);
}

#[test]
fn reads_and_one_operations_effects_never_conflict() {
    let mut s = Scenario::new(2);
    s.tmem_ld(0, 0, (0, 8));
    s.tmem_ld(1, 0, (0, 8));
    s.tmem_op(
        0,
        AsyncOpKind::Tcgen05Mma,
        &[
            Cells::accumulator(AccessMode::Read, (16, 8)),
            Cells::accumulator(AccessMode::Write, (16, 8)),
        ],
    );
    let (g, _) = s.completed(2);
    assert_eq!(evidence(&check(&g)), (0, 0, 0));
}

#[test]
fn disjoint_lanes_or_columns_never_conflict() {
    let mut s = Scenario::new(2);
    s.tmem_op(
        0,
        AsyncOpKind::Tcgen05St,
        &[Cells::quadrant(AccessMode::Write, 0, (0, 8))],
    );
    s.tmem_op(
        1,
        AsyncOpKind::Tcgen05St,
        &[Cells::quadrant(AccessMode::Write, 1, (0, 8))],
    );
    s.tmem_op(
        1,
        AsyncOpKind::Tcgen05St,
        &[Cells::quadrant(AccessMode::Write, 0, (8, 8))],
    );
    let (g, _) = s.completed(2);
    assert_eq!(evidence(&check(&g)).0, 0);
}

#[test]
fn shared_memory_tcgen05_effects_are_not_in_a() {
    let mut s = Scenario::new(2);
    s.async_op_as(
        0,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x40,
        (Proxy::Async, OperandRole::MmaA),
    );
    s.write(1, 0x40, 1);
    let (g, _) = s.completed(2);
    assert_eq!(evidence(&check(&g)).0, 0, "M is Algorithm 3's");
}

#[test]
fn a_tensor_memory_effect_of_another_operation_is_unknown() {
    let mut s = Scenario::new(1);
    let op = s.b.async_issue(t(0), PC, AsyncOpKind::BulkCopy);
    s.b.async_effect(
        op,
        MemAccess {
            space: Space::Tensor,
            mode: AccessMode::Read,
            ordering: OrderingKind::Ordinary,
            proxy: Proxy::Async,
            footprint: Footprint::Tensor {
                lane: 0,
                lanes: 32,
                col: 0,
                cols: 1,
            },
            role: OperandRole::Source,
            attributed: t(0),
            value: None,
        },
    );
    let (g, _) = s.completed(1);
    assert_eq!(check(&g).verdict(), Verdict::Unknown);
}
