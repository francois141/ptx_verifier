//! Check 4, memory-conflict obligations (Algorithm 3), in isolation over an assumed-validated
//! `G_HB`.

mod common;

use std::collections::BTreeSet;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, EventGraph, EventId, ExecContext, Footprint, MemAccess, OperandRole,
    OrderingKind, Parity, Proxy, Space, SyncObjectKind,
};
use volta_graph_check::domain::{ByteLocation, ConflictKind};
use volta_graph_check::memory_conflict::{MemoryConflictResult, check_memory_conflicts};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::{PropertyResult, Verdict};

fn check(graph: &EventGraph) -> MemoryConflictResult {
    let h = ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph");
    check_memory_conflicts(&h).0
}

fn pairs(result: &MemoryConflictResult) -> BTreeSet<(EventId, EventId)> {
    result
        .violations()
        .iter()
        .map(|c| (c.earlier, c.later))
        .collect()
}

fn shared(addr: u64) -> ByteLocation {
    ByteLocation {
        space: Space::Shared,
        addr,
    }
}

#[test]
fn unsynchronized_writes_conflict() {
    let mut s = Scenario::new(2);
    let w0 = s.write(0, 0x10, 1);
    let w1 = s.write(1, 0x10, 2);
    let (g, _) = s.completed(2);
    let result = check(&g);
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(c.kind, ConflictKind::WriteWrite);
    assert_eq!((c.earlier, c.later), (w0, w1));
    assert_eq!(c.location, shared(0x10));
}

#[test]
fn an_unsynchronized_read_after_a_write_conflicts_at_the_first_shared_byte() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.read(1, 0x12);
    let (g, _) = s.completed(2);
    let result = check(&g);
    assert_eq!(result.violations()[0].kind, ConflictKind::WriteRead);
    assert_eq!(result.violations()[0].location, shared(0x12));
}

#[test]
fn a_write_reusing_an_unsynchronized_read_buffer_conflicts() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.barrier(&[0, 1], &[]);
    s.read(0, 0x10);
    s.write(1, 0x10, 2);
    let (g, _) = s.completed(2);
    let result = check(&g);
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(c.kind, ConflictKind::ReadWrite);
}

#[test]
fn reads_never_conflict_and_a_barrier_orders_writes() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.barrier(&[0, 1], &[]);
    s.read(0, 0x10);
    s.read(1, 0x10);
    s.barrier(&[0, 1], &[]);
    s.write(1, 0x10, 2);
    let (g, _) = s.completed(2);
    let (result, certificate) =
        check_memory_conflicts(&ValidatedGraph::assuming_epochs(&g).unwrap());
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(
        certificate.is_some(),
        "a pass certifies Algorithm 4's prerequisite"
    );
}

#[test]
fn equal_concurrent_stores_still_conflict() {
    let mut s = Scenario::new(2);
    let v = s.value(42);
    s.write_expr(0, 0x10, v);
    s.write_expr(1, 0x10, v);
    let (g, _) = s.completed(2);
    let (result, certificate) =
        check_memory_conflicts(&ValidatedGraph::assuming_epochs(&g).unwrap());
    assert_eq!(result.violations()[0].kind, ConflictKind::WriteWrite);
    assert!(certificate.is_none());
}

#[test]
fn every_unordered_pair_is_in_b_once() {
    let mut s = Scenario::new(3);
    let w: Vec<EventId> = (0..3).map(|th| s.write(th, 0x10, i64::from(th))).collect();
    let (g, _) = s.completed(3);
    let result = check(&g);
    assert_eq!(
        pairs(&result),
        BTreeSet::from([(w[0], w[1]), (w[0], w[2]), (w[1], w[2])])
    );
    assert_eq!(result.violations().len(), 3);
}

/// `w0` is ordered before `w1` by a barrier of threads 0 and 1 only; thread 2's read is
/// unordered with both, though only `w1` is the latest write.
#[test]
fn an_unordered_pair_behind_an_ordered_one_is_still_in_b() {
    let mut s = Scenario::new(3);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let w0 = s.write(0, 0x10, 1);
    s.counted_barrier(bar, 0, 2, &[], &[0, 1]);
    let w1 = s.write(1, 0x10, 2);
    let r2 = s.read(2, 0x10);
    let (g, _) = s.completed(3);
    assert_eq!(pairs(&check(&g)), BTreeSet::from([(w0, r2), (w1, r2)]));
}

#[test]
fn the_pairs_are_ordered_by_their_later_effect() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.write(0, 0x20, 1);
    s.read(1, 0x20);
    s.read(1, 0x10);
    let (g, _) = s.completed(2);
    let later: Vec<EventId> = check(&g).violations().iter().map(|c| c.later).collect();
    assert!(later.is_sorted(), "{later:?}");
}

/// t0 issues a bulk copy into 0x10 tracked by a phase t1 waits on; `reader` then reads it.
fn bulk_copy_read_by(reader: u32) -> EventGraph {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    let op = s.async_op(
        0,
        AsyncOpKind::BulkCopy,
        AccessMode::Write,
        0x10,
        Proxy::Async,
    );
    s.b.track(op, p0, 4);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.read(reader, 0x10);
    s.completed(2).0
}

#[test]
fn a_waiter_is_ordered_after_an_async_write() {
    assert_eq!(check(&bulk_copy_read_by(1)).verdict(), Verdict::Pass);
}

#[test]
fn the_issuer_is_not_ordered_after_its_own_async_write() {
    let g = bulk_copy_read_by(0);
    let result = check(&g);
    let [c] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(c.kind, ConflictKind::WriteRead);
    assert!(matches!(g.event(c.earlier).ctx, ExecContext::Async(_)));
}

#[test]
fn an_in_flight_async_read_is_overwritten_by_a_reuse() {
    let mut s = Scenario::new(2);
    s.async_op_as(
        0,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x20,
        (Proxy::Async, OperandRole::MmaA),
    );
    s.barrier(&[0, 1], &[]);
    s.write(1, 0x20, 5);
    let (g, _) = s.completed(2);
    let result = check(&g);
    assert_eq!(
        result.violations()[0].kind,
        ConflictKind::ReadWrite,
        "shared-memory tcgen05 effects belong to M"
    );
}

#[test]
fn tensor_memory_effects_are_not_in_m() {
    let mut s = Scenario::new(2);
    s.mma(0, (0, 8));
    s.mma(1, (0, 8));
    let (g, _) = s.completed(2);
    assert_eq!(check(&g).verdict(), Verdict::Pass, "A is Algorithm 5's");
}

#[test]
fn global_and_shared_bytes_never_overlap() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    let a = MemAccess {
        space: Space::Global,
        mode: AccessMode::Read,
        ordering: OrderingKind::Ordinary,
        proxy: Proxy::Generic,
        footprint: Footprint::Bytes {
            addr: 0x10,
            width: 4,
        },
        role: OperandRole::Plain,
        attributed: t(1),
        value: None,
    };
    s.b.thread_access(t(1), PC, a);
    let (g, _) = s.completed(2);
    assert_eq!(check(&g).verdict(), Verdict::Pass);
}

#[test]
fn atomic_effects_are_outside_the_contract() {
    let mut s = Scenario::new(1);
    let access = MemAccess {
        space: Space::Global,
        mode: AccessMode::Read,
        ordering: OrderingKind::Atomic,
        proxy: Proxy::Generic,
        footprint: Footprint::Bytes { addr: 0, width: 4 },
        role: OperandRole::Plain,
        attributed: t(0),
        value: None,
    };
    s.b.thread_access(t(0), PC, access);
    let (g, _) = s.completed(1);
    let result = check(&g);
    let [u] = result.unresolved() else {
        panic!("{result:?}");
    };
    assert!(u.reason.contains("contract"), "{u:?}");
}

#[test]
fn an_exited_writer_is_unordered_by_the_barrier_that_fires_without_it() {
    let mut s = Scenario::new(2);
    s.write(1, 0x10, 1);
    s.exit(1);
    s.barrier(&[0], &[1]);
    s.read(0, 0x10);
    assert_eq!(check(&s.completed(2).0).verdict(), Verdict::Fail);
}

#[test]
fn without_effects_the_check_is_vacuous() {
    let s = Scenario::new(1);
    let (g, _) = s.completed(1);
    assert!(matches!(
        check(&g),
        PropertyResult::Pass(ref e) if e.effects == 0 && e.written_bytes == 0
    ));
}
