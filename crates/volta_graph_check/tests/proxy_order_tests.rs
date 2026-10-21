//! Check 4, proxy ordering (Algorithm 3), in isolation over an assumed-validated `G_HB` and an
//! assumed memory-conflict pass.

mod common;

use common::*;
use volta_graph::{AccessMode, AsyncOpKind, EventGraph, OperandRole, Parity, Proxy, Space};
use volta_graph_check::domain::ConflictKind;
use volta_graph_check::memory_conflict::MemoryConflictFree;
use volta_graph_check::proxy_order::{ProxyOrderResult, check_proxy_order};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::{PropertyResult, Verdict};

fn check(graph: &EventGraph) -> ProxyOrderResult {
    let h = ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph");
    check_proxy_order(&h, &MemoryConflictFree::assuming(&h))
}

/// Where the fence of [`generic_write_then_async_read`] goes.
#[derive(Clone, Copy, PartialEq)]
enum FenceAt {
    None,
    WriterBeforeBarrier,
    ReaderAfterBarrier,
    WriterBeforeWrite,
    BystanderAfterBarrier,
}

/// t0 writes 0x40 generically; t1 reads it through the async proxy (an MMA operand) after a
/// barrier of all three threads.
fn generic_write_then_async_read(fence_at: FenceAt) -> EventGraph {
    let mut s = Scenario::with(async_proxy_provenance(3));
    if fence_at == FenceAt::WriterBeforeWrite {
        s.proxy_fence(0, Some(Space::Shared));
    }
    s.write(0, 0x40, 7);
    if fence_at == FenceAt::WriterBeforeBarrier {
        s.proxy_fence(0, Some(Space::Shared));
    }
    s.barrier(&[0, 1, 2], &[]);
    match fence_at {
        FenceAt::ReaderAfterBarrier => {
            s.proxy_fence(1, None);
        }
        FenceAt::BystanderAfterBarrier => {
            s.proxy_fence(2, None);
            s.barrier(&[0, 1, 2], &[]);
        }
        _ => {}
    }
    s.async_op_as(
        1,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x40,
        (Proxy::Async, OperandRole::MmaA),
    );
    s.completed(3).0
}

#[test]
fn a_writer_fence_before_the_publishing_barrier_covers_the_pair() {
    let result = check(&generic_write_then_async_read(FenceAt::WriterBeforeBarrier));
    assert!(
        matches!(result, PropertyResult::Pass(ref e) if e.covered_pairs == 1),
        "{result:?}"
    );
}

#[test]
fn a_reader_fence_after_synchronizing_covers_the_pair() {
    let result = check(&generic_write_then_async_read(FenceAt::ReaderAfterBarrier));
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn a_missing_fence_is_a_violation() {
    let graph = generic_write_then_async_read(FenceAt::None);
    let result = check(&graph);
    let [v] = result.violations() else {
        panic!("UNPROVEDPROXYORDER(a, b) is a race: {result:?}");
    };
    assert_eq!(v.kind, ConflictKind::WriteRead);
    assert_eq!(v.location.addr, 0x40);
    assert_eq!(graph.acting_thread(v.generic), Some(t(0)));
    assert_eq!(graph.acting_thread(v.asynchronous), Some(t(1)));
    assert!(result.unresolved().is_empty());
}

#[test]
fn a_fence_before_the_write_does_not_cover_it() {
    let result = check(&generic_write_then_async_read(FenceAt::WriterBeforeWrite));
    assert_eq!(result.verdict(), Verdict::Fail);
}

#[test]
fn a_third_threads_fence_does_not_cover_the_pair() {
    let result = check(&generic_write_then_async_read(
        FenceAt::BystanderAfterBarrier,
    ));
    assert_eq!(result.verdict(), Verdict::Fail, "{result:?}");
}

#[test]
fn a_fence_over_another_space_does_not_cover_the_pair() {
    let mut s = Scenario::with(async_proxy_provenance(2));
    s.write(0, 0x40, 7);
    s.proxy_fence(0, Some(Space::Global));
    s.barrier(&[0, 1], &[]);
    s.async_op(
        1,
        AsyncOpKind::TensorCopy,
        AccessMode::Read,
        0x40,
        Proxy::Async,
    );
    let (g, _) = s.completed(2);
    assert_eq!(check(&g).verdict(), Verdict::Fail);
}

/// t0 reads 0x40 generically, then (after a barrier) t1's bulk copy overwrites it, with an
/// optional fence by t1 before the issue.
fn generic_read_then_async_overwrite(fenced: bool) -> EventGraph {
    let mut s = Scenario::with(async_proxy_provenance(2));
    s.read(0, 0x40);
    s.barrier(&[0, 1], &[]);
    if fenced {
        s.proxy_fence(1, Some(Space::Shared));
    }
    s.async_op(
        1,
        AsyncOpKind::BulkCopy,
        AccessMode::Write,
        0x40,
        Proxy::Async,
    );
    s.completed(2).0
}

#[test]
fn a_generic_read_before_an_async_overwrite_needs_a_fence_too() {
    let unfenced = check(&generic_read_then_async_overwrite(false));
    let [v] = unfenced.violations() else {
        panic!("{unfenced:?}");
    };
    assert_eq!(v.kind, ConflictKind::ReadWrite);
    assert_eq!(
        check(&generic_read_then_async_overwrite(true)).verdict(),
        Verdict::Pass
    );
}

#[test]
fn an_async_write_read_generically_is_covered_by_its_observed_completion() {
    let mut s = Scenario::with(async_proxy_provenance(2));
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    let op = s.async_op(
        0,
        AsyncOpKind::BulkCopy,
        AccessMode::Write,
        0x40,
        Proxy::Async,
    );
    s.b.track(op, p0, 4);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.read(1, 0x40);
    s.write(1, 0x40, 3);
    let (g, _) = s.completed(2);
    assert_eq!(check(&g).verdict(), Verdict::Pass);
}

#[test]
fn same_proxy_pairs_need_no_fence() {
    let mut s = Scenario::with(async_proxy_provenance(1));
    s.async_op(
        0,
        AsyncOpKind::BulkCopy,
        AccessMode::Write,
        0x40,
        Proxy::Async,
    );
    s.async_op_as(
        0,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x40,
        (Proxy::Async, OperandRole::MmaA),
    );
    s.write(0, 0x80, 1);
    s.read(0, 0x80);
    let (g, _) = s.aborted();
    assert!(matches!(
        check(&g),
        PropertyResult::Pass(ref e) if e.covered_pairs == 0 && !e.vacuous
    ));
}

#[test]
fn a_generic_async_copy_needs_a_fence_before_an_async_proxy_read() {
    let mut s = Scenario::with(async_proxy_provenance(1));
    let group =
        s.b.sync_object(volta_graph::SyncObjectKind::AsyncGroupWait { thread: t(0) });
    let copy = s.async_op(
        0,
        AsyncOpKind::CpAsync,
        AccessMode::Write,
        0x40,
        Proxy::Generic,
    );
    s.b.group_commit(t(0), PC, volta_graph::GroupFamily::CpAsync);
    let wait = s.b.open_generation(
        group,
        0,
        volta_graph::GenerationKind::AsyncGroupWait { keep_pending: 0 },
    );
    s.b.track(copy, wait, 0);
    s.complete(wait);
    s.b.resume(t(0), PC, wait);
    s.proxy_fence(0, Some(Space::Shared));
    s.async_op(
        0,
        AsyncOpKind::TensorCopy,
        AccessMode::Read,
        0x40,
        Proxy::Async,
    );
    let (g, _) = s.completed(1);
    assert_eq!(check(&g).verdict(), Verdict::Pass);
}

#[test]
fn without_an_async_proxy_every_pair_is_same_proxy() {
    let mut s = Scenario::new(2);
    s.write(0, 0x40, 7);
    s.barrier(&[0, 1], &[]);
    s.async_op(
        1,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x40,
        Proxy::Async,
    );
    let (g, _) = s.completed(2);
    assert!(matches!(check(&g), PropertyResult::Pass(ref e) if e.vacuous));
}
