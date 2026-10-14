//! The memory-conflict (race) checker in isolation, on purpose-built graphs.

mod common;

use std::collections::HashSet;

use common::*;
use volta_expr::{ExprArena, ExprId, ValueEquality};
use volta_graph::{
    AccessMode, Assumption, AsyncOpId, AsyncOpKind, EventGraph, Footprint, MemAccess, OperandRole,
    OrderingKind, Parity, Proxy, Space, StoredValue,
};
use volta_graph_check::Verdict;
use volta_graph_check::async_completion::CompletionCertificate;
use volta_graph_check::barrier::SyncCertificate;
use volta_graph_check::hb::Validated;
use volta_graph_check::pipeline::{PipelineCertificate, check_pipeline};
use volta_graph_check::proxy::ProxyCertificate;
use volta_graph_check::race::{
    ConflictKind, Location, RaceInputs, RaceResult, SymbolicFacts, check_races,
};

struct Oracle(bool);

impl ValueEquality for Oracle {
    fn same_value(&self, _: &ExprArena, _: ExprId, _: ExprId) -> bool {
        self.0
    }
}

fn check_with(
    graph: &EventGraph,
    arena: &ExprArena,
    sync: &SyncCertificate,
    pipeline: &PipelineCertificate,
    proxy: &ProxyCertificate,
    oracle: bool,
) -> RaceResult {
    check_races(
        graph,
        &SymbolicFacts {
            arena,
            value_equality: &Oracle(oracle),
        },
        &RaceInputs {
            sync,
            completion: &CompletionCertificate::assume_all(),
            pipeline,
            proxy,
        },
    )
}

fn check(graph: &EventGraph, arena: &ExprArena) -> RaceResult {
    check_with(
        graph,
        arena,
        &SyncCertificate::assume_all(),
        &PipelineCertificate::none(),
        &ProxyCertificate::default(),
        false,
    )
}

#[test]
fn unsynchronized_writes_of_different_values_race() {
    let mut s = Scenario::new(2);
    let w0 = s.write(0, 0x10, 1);
    let w1 = s.write(1, 0x10, 2);
    let (g, arena) = s.completed(2);
    let result = check(&g, &arena);
    let first = result.violations()[0];
    assert_eq!(first.kind, ConflictKind::WriteWrite);
    assert_eq!((first.prior, first.current), (w0, w1));
    assert_eq!(first.location, Location::Byte(Space::Shared, 0x10));
}

#[test]
fn an_unsynchronized_read_after_a_write_races() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.read(1, 0x12);
    let (g, arena) = s.completed(2);
    let result = check(&g, &arena);
    assert_eq!(result.violations()[0].kind, ConflictKind::WriteRead);
    assert_eq!(
        result.violations()[0].location,
        Location::Byte(Space::Shared, 0x12)
    );
}

#[test]
fn a_write_reusing_an_unsynchronized_read_buffer_races() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.barrier(&[0, 1], &[]);
    s.read(0, 0x10);
    s.write(1, 0x10, 2);
    let (g, arena) = s.completed(2);
    let result = check(&g, &arena);
    assert_eq!(result.violations()[0].kind, ConflictKind::ReadWrite);
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
    let (g, arena) = s.completed(2);
    assert_eq!(check(&g, &arena).verdict(), Verdict::Pass);
}

#[test]
fn equal_concurrent_stores_are_benign() {
    let mut s = Scenario::new(2);
    let v = s.value(42);
    s.write_expr(0, 0x10, v);
    s.write_expr(1, 0x10, v);
    s.barrier(&[0, 1], &[]);
    s.read(0, 0x10);
    let (g, arena) = s.completed(2);
    let result = check(&g, &arena);
    assert!(
        matches!(&result, volta_graph_check::PropertyResult::Pass(e) if e.benign_equal_stores == 4),
        "{result:?}"
    );
}

#[test]
fn the_value_oracle_decides_stores_of_distinct_expressions() {
    let build = || {
        let mut s = Scenario::new(2);
        s.write(0, 0x10, 1);
        s.write(1, 0x10, 2);
        s.completed(2)
    };
    let (g, arena) = build();
    let sync = SyncCertificate::assume_all();
    let none = PipelineCertificate::none();
    let proxy = ProxyCertificate::default();
    assert_eq!(
        check_with(&g, &arena, &sync, &none, &proxy, true).verdict(),
        Verdict::Pass
    );
    assert_eq!(
        check_with(&g, &arena, &sync, &none, &proxy, false).verdict(),
        Verdict::Fail
    );
}

/// t0 issues a bulk copy into 0x10 tracked by a phase t1 waits on; `reader` then reads it.
fn bulk_copy_read_by(reader: u32) -> (EventGraph, ExprArena) {
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
    s.completed(2)
}

#[test]
fn a_waiter_is_ordered_after_an_async_write() {
    let (g, arena) = bulk_copy_read_by(1);
    assert_eq!(check(&g, &arena).verdict(), Verdict::Pass);
}

#[test]
fn the_issuer_is_not_ordered_after_its_own_async_write() {
    let (g, arena) = bulk_copy_read_by(0);
    let result = check(&g, &arena);
    let first = result.violations()[0];
    assert_eq!(first.kind, ConflictKind::WriteRead);
    assert!(matches!(
        g.event(first.prior).ctx,
        volta_graph::ExecContext::Async(_)
    ));
}

#[test]
fn overwriting_an_in_flight_async_read_is_a_reuse_race() {
    let mut s = Scenario::new(2);
    s.async_op(
        0,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x20,
        Proxy::Async,
    );
    s.barrier(&[0, 1], &[]);
    s.write(1, 0x20, 5);
    let (g, arena) = s.completed(2);
    let result = check(&g, &arena);
    assert_eq!(result.violations()[0].kind, ConflictKind::ReadWrite);
}

fn tmem_mma(s: &mut Scenario, issuer: u32) -> AsyncOpId {
    let op = s.b.async_issue(t(issuer), PC, AsyncOpKind::Tcgen05Mma);
    let value = Some(s.b.value(StoredValue::Opaque));
    for (mode, value) in [(AccessMode::Read, None), (AccessMode::Write, value)] {
        s.b.async_effect(
            op,
            MemAccess {
                space: Space::Tensor,
                mode,
                ordering: OrderingKind::Ordinary,
                proxy: Proxy::Async,
                footprint: Footprint::Tensor {
                    lane: 0,
                    lanes: 128,
                    col: 0,
                    cols: 2,
                },
                role: OperandRole::Accumulator,
                attributed: t(issuer),
                value,
            },
        );
    }
    op
}

#[test]
fn a_certified_accumulator_chain_needs_no_wait() {
    let mut s = Scenario::new(1);
    tmem_mma(&mut s, 0);
    tmem_mma(&mut s, 0);
    let (g, arena) = s.completed(1);
    let (_, pipeline) = check_pipeline(&g);
    let sync = SyncCertificate::assume_all();
    let proxy = ProxyCertificate::default();
    assert_eq!(
        check_with(&g, &arena, &sync, &pipeline, &proxy, false).verdict(),
        Verdict::Pass
    );
    let without = check_with(
        &g,
        &arena,
        &sync,
        &PipelineCertificate::none(),
        &proxy,
        false,
    );
    let first = without.violations()[0];
    assert_eq!(first.location, Location::Cell { lane: 0, col: 0 });
}

#[test]
fn an_uncovered_cross_proxy_read_defers_to_the_proxy_checker() {
    let mut p = provenance(2);
    p.assumptions.push(Assumption::AsyncProxy);
    let mut s = Scenario::with(p);
    s.write(0, 0x40, 1);
    s.barrier(&[0, 1], &[]);
    s.async_op(
        1,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x40,
        Proxy::Async,
    );
    let (g, arena) = s.completed(2);
    let result = check(&g, &arena);
    assert_eq!(result.verdict(), Verdict::Unknown, "{result:?}");
    assert!(result.unresolved()[0].reason.contains("proxy"));
}

fn check_unvalidated(graph: &EventGraph, arena: &ExprArena) -> RaceResult {
    let unvalidated = SyncCertificate {
        generations: Validated::Only(HashSet::new()),
    };
    check_with(
        graph,
        arena,
        &unvalidated,
        &PipelineCertificate::none(),
        &ProxyCertificate::default(),
        false,
    )
}

#[test]
fn ordering_only_through_an_unvalidated_barrier_is_unknown() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.barrier(&[0, 1], &[]);
    s.read(1, 0x10);
    let (g, arena) = s.completed(2);
    assert_eq!(check(&g, &arena).verdict(), Verdict::Pass);
    let result = check_unvalidated(&g, &arena);
    let [u] = result.unresolved() else {
        panic!("{result:?}");
    };
    assert!(u.reason.contains("unvalidated"), "{u:?}");
}

#[test]
fn a_conflict_unordered_through_every_candidate_edge_fails_regardless() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.barrier(&[0, 1], &[]);
    s.read(1, 0x10);
    let w = s.write(1, 0x20, 1);
    let r = s.read(0, 0x20);
    let (g, arena) = s.completed(2);
    let result = check_unvalidated(&g, &arena);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!((v.prior, v.current), (w, r));
    assert_eq!(v.location, Location::Byte(Space::Shared, 0x20));
}

#[test]
fn one_conflict_is_reported_per_effect_pair_at_its_first_location() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.read(1, 0x11);
    s.read(1, 0x12);
    let (g, arena) = s.completed(2);
    let result = check(&g, &arena);
    let locations: Vec<Location> = result.violations().iter().map(|c| c.location).collect();
    assert_eq!(
        locations,
        [
            Location::Byte(Space::Shared, 0x11),
            Location::Byte(Space::Shared, 0x12)
        ]
    );
}

#[test]
fn atomic_effects_are_unknown() {
    let mut s = Scenario::new(1);
    let mut access = MemAccess {
        space: Space::Global,
        mode: AccessMode::Write,
        ordering: OrderingKind::Atomic,
        proxy: Proxy::Generic,
        footprint: Footprint::Bytes { addr: 0, width: 4 },
        role: OperandRole::Plain,
        attributed: t(0),
        value: None,
    };
    s.b.thread_access(t(0), PC, access);
    access.ordering = OrderingKind::Ordinary;
    s.b.thread_access(t(0), PC, access);
    let (g, arena) = s.completed(1);
    let result = check(&g, &arena);
    assert_eq!(result.verdict(), Verdict::Unknown, "{result:?}");
    assert_eq!(result.unresolved().len(), 1);
}

#[test]
fn an_exited_writer_is_ordered_only_under_the_sync_prime_assumption() {
    let build = |assume: bool| {
        let mut p = provenance(2);
        if !assume {
            p.assumptions
                .retain(|a| *a != Assumption::ExitedThreadsArrive);
        }
        let mut s = Scenario::with(p);
        s.write(1, 0x10, 1);
        s.exit(1);
        s.barrier(&[0], &[1]);
        s.read(0, 0x10);
        s.completed(2)
    };
    let (g, arena) = build(true);
    assert_eq!(check(&g, &arena).verdict(), Verdict::Pass);
    let (g, arena) = build(false);
    assert_eq!(check(&g, &arena).verdict(), Verdict::Fail);
}
