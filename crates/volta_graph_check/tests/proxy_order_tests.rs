//! Check 5, proxy ordering (Algorithm 4), in isolation over an assumed-validated `G_HB` and an
//! assumed memory-conflict pass.

mod common;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, EventGraph, FenceKind, Footprint, MemAccess, OperandRole,
    OrderingKind, Parity, Proxy, Space, StoredValue,
};
use volta_graph_check::domain::ConflictKind;
use volta_graph_check::memory_conflict::MemoryConflictFree;
use volta_graph_check::proxy_order::{MissingFence, ProxyOrderResult, check_proxy_order};
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
    let mut s = Scenario::new(3);
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
    let mut s = Scenario::new(2);
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
    let mut s = Scenario::new(2);
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

/// Only a read of bytes the other proxy wrote needs a fence: a generic read
/// the synchronization orders before an async overwrite passes, fenced or not.
#[test]
fn a_generic_read_before_an_async_overwrite_needs_no_fence() {
    for fenced in [false, true] {
        assert_eq!(
            check(&generic_read_then_async_overwrite(fenced)).verdict(),
            Verdict::Pass
        );
    }
}

#[test]
fn an_async_write_read_generically_is_covered_by_its_observed_completion() {
    let mut s = Scenario::new(2);
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

/// t0's async op of `kind` writes 0x40 through the async proxy, tracked by an mbarrier phase t1
/// waits on before reading 0x40 generically, with an optional fence by t1 after the wait.
fn observed_async_write_then_generic_read(kind: AsyncOpKind, fenced: bool) -> EventGraph {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    let op = s.async_op(0, kind, AccessMode::Write, 0x40, Proxy::Async);
    s.b.track(op, p0, 4);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    if fenced {
        s.proxy_fence(1, Some(Space::Shared));
    }
    s.read(1, 0x40);
    s.completed(2).0
}

#[test]
fn only_a_bulk_copys_completion_fences_its_async_writes() {
    let unfenced = check(&observed_async_write_then_generic_read(
        AsyncOpKind::Tcgen05St,
        false,
    ));
    let [v] = unfenced.violations() else {
        panic!("{unfenced:?}");
    };
    assert_eq!(v.kind, ConflictKind::WriteRead);
    assert_eq!(v.missing, MissingFence::ProxyAsync);
    for (kind, fenced) in [
        (AsyncOpKind::Tcgen05St, true),
        (AsyncOpKind::BulkCopy, false),
    ] {
        let graph = observed_async_write_then_generic_read(kind, fenced);
        assert_eq!(check(&graph).verdict(), Verdict::Pass, "{kind:?}");
    }
}

#[test]
fn same_proxy_pairs_need_no_fence() {
    let mut s = Scenario::new(1);
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
        PropertyResult::Pass(ref e) if e.covered_pairs == 0
    ));
}

#[test]
fn a_generic_async_copy_needs_a_fence_before_an_async_proxy_read() {
    let mut s = Scenario::new(1);
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
fn the_declared_target_does_not_gate_the_check() {
    let mut p = provenance(2);
    p.targets = vec!["Sm80".to_string()];
    let mut s = Scenario::with(p);
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
    assert_eq!(check(&g).verdict(), Verdict::Fail);
}

/// The global address of the tensor map in [`tensor_map_write_then_copy`].
const MAP: u64 = 0x1000;

/// Where t0's tensor-map release goes.
#[derive(Clone, Copy, PartialEq)]
enum ReleaseAt {
    None,
    AfterWrite,
    BeforeWrite,
    AfterBarrier,
}

/// Which acquire precedes t1's copy.
#[derive(Clone, Copy, PartialEq)]
enum AcquireAt {
    None,
    Map,
    OtherMap,
    Bystander,
    ProxyAsync,
}

/// A 128-byte access of `thread` to the tensor map at `MAP`.
fn map_access(s: &mut Scenario, thread: u32, mode: AccessMode, proxy: Proxy) -> MemAccess {
    let (role, value) = match mode {
        AccessMode::Write => (OperandRole::Plain, Some(s.b.value(StoredValue::Opaque))),
        AccessMode::Read => (OperandRole::TensorMap, None),
    };
    MemAccess {
        space: Space::Global,
        mode,
        ordering: OrderingKind::Ordinary,
        proxy,
        footprint: Footprint::Bytes {
            addr: MAP,
            width: 128,
        },
        role,
        attributed: t(thread),
        value,
    }
}

/// t0 writes the tensor map generically; t1's `cp.async.bulk.tensor` reads it through the
/// tensor-map proxy after a barrier of all three threads.
fn tensor_map_write_then_copy(release: ReleaseAt, acquire: AcquireAt) -> EventGraph {
    let mut s = Scenario::new(3);
    if release == ReleaseAt::BeforeWrite {
        s.b.fence(t(0), PC, FenceKind::TensormapRelease);
    }
    let write = map_access(&mut s, 0, AccessMode::Write, Proxy::Generic);
    s.b.thread_access(t(0), PC, write);
    if release == ReleaseAt::AfterWrite {
        s.b.fence(t(0), PC, FenceKind::TensormapRelease);
    }
    s.barrier(&[0, 1, 2], &[]);
    if release == ReleaseAt::AfterBarrier {
        s.b.fence(t(0), PC, FenceKind::TensormapRelease);
    }
    match acquire {
        AcquireAt::None => {}
        AcquireAt::Map => {
            s.b.fence(t(1), PC, FenceKind::TensormapAcquire { addr: MAP });
        }
        AcquireAt::OtherMap => {
            s.b.fence(t(1), PC, FenceKind::TensormapAcquire { addr: MAP + 128 });
        }
        AcquireAt::Bystander => {
            s.b.fence(t(2), PC, FenceKind::TensormapAcquire { addr: MAP });
            s.barrier(&[0, 1, 2], &[]);
        }
        AcquireAt::ProxyAsync => {
            s.proxy_fence(1, None);
        }
    }
    let op = s.b.async_issue(t(1), PC, AsyncOpKind::TensorCopy);
    let read = map_access(&mut s, 1, AccessMode::Read, Proxy::TensorMap);
    s.b.async_effect(op, read);
    s.completed(3).0
}

fn missing(release: ReleaseAt, acquire: AcquireAt) -> Option<MissingFence> {
    let graph = tensor_map_write_then_copy(release, acquire);
    match check(&graph) {
        PropertyResult::Pass(_) => None,
        PropertyResult::Fail(v) => {
            let [v] = v.as_slice() else {
                panic!("one violation: {v:?}");
            };
            assert_eq!(v.kind, ConflictKind::WriteRead);
            assert_eq!(graph.acting_thread(v.generic), Some(t(0)));
            assert_eq!(graph.acting_thread(v.asynchronous), Some(t(1)));
            Some(v.missing)
        }
        unknown => panic!("{unknown:?}"),
    }
}

/// The PTX ISA's pairing: the writer releases, a barrier orders the release before the
/// reader's acquire of the map, and the acquire precedes the copy.
#[test]
fn a_release_ordered_before_the_readers_acquire_covers_a_tensor_map_read() {
    let result = check(&tensor_map_write_then_copy(
        ReleaseAt::AfterWrite,
        AcquireAt::Map,
    ));
    assert!(
        matches!(result, PropertyResult::Pass(ref e) if e.covered_pairs == 1),
        "{result:?}"
    );
}

#[test]
fn a_tensor_map_read_needs_an_acquire_on_the_copys_thread() {
    use AcquireAt::*;
    for acquire in [None, OtherMap, Bystander, ProxyAsync] {
        assert_eq!(
            missing(ReleaseAt::AfterWrite, acquire),
            Some(MissingFence::TensormapAcquire)
        );
    }
}

#[test]
fn a_tensor_map_read_needs_a_release_after_the_write_ordered_before_the_acquire() {
    use ReleaseAt::*;
    for release in [None, BeforeWrite, AfterBarrier] {
        assert_eq!(
            missing(release, AcquireAt::Map),
            Some(MissingFence::TensormapRelease)
        );
    }
}
