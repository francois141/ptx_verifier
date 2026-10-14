//! The cross-proxy-ordering checker in isolation.

mod common;

use std::collections::HashSet;

use common::*;
use volta_graph::{AccessMode, Assumption, AsyncOpKind, FenceKind, Proxy, Space, Terminal};
use volta_graph_check::Verdict;
use volta_graph_check::async_completion::CompletionCertificate;
use volta_graph_check::barrier::SyncCertificate;
use volta_graph_check::hb::Validated;
use volta_graph_check::proxy::check_proxy;

fn sm90(threads: u32) -> Scenario {
    let mut p = provenance(threads);
    p.assumptions.push(Assumption::AsyncProxy);
    Scenario::with(p)
}

fn fence(s: &mut Scenario, thread: u32) {
    s.b.fence(
        t(thread),
        PC,
        FenceKind::ProxyAsync {
            space: Some(Space::Shared),
        },
    );
}

/// t0 writes `A` generically; t1 reads it through the async proxy (an MMA operand) after a
/// barrier, with the fence placed per `fence_at`.
#[derive(Clone, Copy, PartialEq)]
enum FenceAt {
    None,
    WriterBeforeBarrier,
    ReaderAfterBarrier,
    WriterBeforeWrite,
}

fn generic_write_then_async_read(fence_at: FenceAt) -> volta_graph::EventGraph {
    let mut s = sm90(2);
    if fence_at == FenceAt::WriterBeforeWrite {
        fence(&mut s, 0);
    }
    s.write(0, 0x40, 7);
    if fence_at == FenceAt::WriterBeforeBarrier {
        fence(&mut s, 0);
    }
    s.barrier(&[0, 1], &[]);
    if fence_at == FenceAt::ReaderAfterBarrier {
        fence(&mut s, 1);
    }
    s.async_op(
        1,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x40,
        Proxy::Async,
    );
    s.completed(2).0
}

fn check(graph: &volta_graph::EventGraph) -> volta_graph_check::proxy::ProxyResult {
    check_proxy(
        graph,
        &SyncCertificate::assume_all(),
        &CompletionCertificate::assume_all(),
    )
    .0
}

#[test]
fn a_writer_fence_before_the_publishing_barrier_covers_the_read() {
    let result = check(&generic_write_then_async_read(FenceAt::WriterBeforeBarrier));
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn a_reader_fence_after_synchronizing_covers_the_read() {
    let result = check(&generic_write_then_async_read(FenceAt::ReaderAfterBarrier));
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn a_missing_fence_fails_with_the_write_and_the_read() {
    let graph = generic_write_then_async_read(FenceAt::None);
    let result = check(&graph);
    let [v] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(v.addr, 0x40);
    assert_eq!(graph.acting_thread(v.write), Some(t(0)));
    assert_eq!(graph.acting_thread(v.read), Some(t(1)));
}

#[test]
fn a_fence_before_the_write_does_not_cover_it() {
    let result = check(&generic_write_then_async_read(FenceAt::WriterBeforeWrite));
    assert_eq!(result.verdict(), Verdict::Fail);
}

#[test]
fn without_an_async_proxy_there_is_no_obligation() {
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
    let (graph, _) = s.completed(2);
    let result = check(&graph);
    assert!(matches!(
        result,
        volta_graph_check::PropertyResult::Pass(ref e) if e.vacuous
    ));
}

#[test]
fn an_async_write_read_by_the_async_proxy_needs_no_fence() {
    let mut s = sm90(1);
    s.async_op(
        0,
        AsyncOpKind::BulkCopy,
        AccessMode::Write,
        0x40,
        Proxy::Async,
    );
    s.async_op(
        0,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0x40,
        Proxy::Async,
    );
    let (graph, _) = s.finish(Terminal::Aborted {
        thread: None,
        pc: None,
        reason: "test".to_string(),
    });
    let result = check(&graph);
    assert!(matches!(
        result,
        volta_graph_check::PropertyResult::Pass(ref e) if e.obligations == 0
    ));
}

#[test]
fn coverage_only_through_an_unvalidated_barrier_is_unknown() {
    let graph = generic_write_then_async_read(FenceAt::WriterBeforeBarrier);
    let result = check_proxy(
        &graph,
        &SyncCertificate {
            generations: Validated::Only(HashSet::new()),
        },
        &CompletionCertificate::assume_all(),
    )
    .0;
    assert_eq!(result.verdict(), Verdict::Unknown, "{result:?}");
}
