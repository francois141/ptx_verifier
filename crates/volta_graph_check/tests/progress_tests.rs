//! The progress checker in isolation.

mod common;

use std::collections::HashSet;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, BlockedOn, BlockedThread, EventGraph, GenerationId, Parity, Proxy,
    Terminal,
};
use volta_graph_check::async_completion::CompletionCertificate;
use volta_graph_check::barrier::SyncCertificate;
use volta_graph_check::hb::Validated;
use volta_graph_check::progress::{Deadlock, ProgressResult, check_progress};
use volta_graph_check::{PropertyResult, Verdict};

fn check(graph: &EventGraph) -> ProgressResult {
    check_progress(
        graph,
        &SyncCertificate::assume_all(),
        &CompletionCertificate::assume_all(),
    )
}

#[test]
fn a_completed_execution_through_validated_generations_passes() {
    let mut s = Scenario::new(2);
    s.barrier(&[0, 1], &[]);
    let (g, _) = s.completed(2);
    assert!(
        matches!(check(&g), PropertyResult::Pass(e) if e.threads == 2 && e.releasing_generations == 1)
    );
}

#[test]
fn a_stuck_execution_is_a_deadlock_with_every_blocked_thread() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 2);
    let p0 = s.phase(m, 0);
    s.arrive(0, p0);
    s.b.wait_start(t(1), PC, m, Parity::Even);
    s.exit(0);
    let blocked = vec![BlockedThread {
        thread: t(1),
        pc: PC,
        on: BlockedOn::Mbarrier {
            object: m,
            parity: Parity::Even,
            state: volta_graph::MbarrierState {
                completed_phases: 0,
                arrived: 1,
                expected: 2,
                pending_tx: 0,
            },
        },
    }];
    let (g, _) = s.finish(Terminal::Stuck {
        blocked: blocked.clone(),
    });
    assert_eq!(check(&g).violations(), [Deadlock { blocked }]);
}

#[test]
fn an_aborted_execution_is_unknown_not_a_deadlock() {
    let mut s = Scenario::new(1);
    s.write(0, 0x10, 1);
    let (g, _) = s.finish(Terminal::Aborted {
        thread: Some(t(0)),
        pc: Some(PC),
        reason: "unsupported instruction".to_string(),
    });
    let result = check(&g);
    let [u] = result.unresolved() else {
        panic!("{result:?}");
    };
    assert!(u.reason.contains("unsupported instruction"), "{u:?}");
}

#[test]
fn completing_through_an_unvalidated_generation_is_unknown() {
    let mut s = Scenario::new(2);
    let first = s.barrier(&[0, 1], &[]);
    s.barrier(&[0, 1], &[]);
    let (g, _) = s.completed(2);
    let only_first: HashSet<GenerationId> = [first].into();
    let result = check_progress(
        &g,
        &SyncCertificate {
            generations: Validated::Only(only_first),
        },
        &CompletionCertificate::assume_all(),
    );
    assert_eq!(result.verdict(), Verdict::Unknown);
    assert_eq!(result.unresolved().len(), 1, "{result:?}");
}

#[test]
fn a_release_counting_an_unvalidated_completion_is_unknown() {
    let mut s = Scenario::new(1);
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
    s.wait(0, m, Parity::Even, p0);
    let (g, _) = s.completed(1);
    assert_eq!(check(&g).verdict(), Verdict::Pass);
    let result = check_progress(
        &g,
        &SyncCertificate::assume_all(),
        &CompletionCertificate {
            completions: Validated::Only(HashSet::new()),
        },
    );
    let [u] = result.unresolved() else {
        panic!("{result:?}");
    };
    assert_eq!(u.event, Some(g.async_op(op).issue));
}
