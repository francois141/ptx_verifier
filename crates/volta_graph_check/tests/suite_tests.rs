//! The checker suite: dependency order, verdict roll-up and proof scope.

mod common;

use common::*;
use volta_expr::{ExprArena, ExprId, ValueEquality};
use volta_graph::{
    AccessMode, AsyncOpKind, BlockedOn, BlockedThread, EventGraph, Parity, Proxy, Terminal,
};
use volta_graph_check::{GraphReport, ProofScope, Property, SymbolicFacts, Verdict, check_graph};

struct NeverEqual;

impl ValueEquality for NeverEqual {
    fn same_value(&self, _: &ExprArena, _: ExprId, _: ExprId) -> bool {
        false
    }
}

fn report(graph: &EventGraph, arena: &ExprArena) -> GraphReport {
    check_graph(
        graph,
        &SymbolicFacts {
            arena,
            value_equality: &NeverEqual,
        },
    )
}

fn verdicts(r: &GraphReport) -> Vec<(Property, Verdict)> {
    Property::ALL.iter().map(|&p| (p, r.verdict(p))).collect()
}

#[test]
fn every_property_follows_its_prerequisites() {
    for (i, p) in Property::ALL.iter().enumerate() {
        for q in p.prerequisites() {
            let at = Property::ALL.iter().position(|x| x == q).unwrap();
            assert!(at < i, "{p:?} runs before its prerequisite {q:?}");
        }
    }
}

#[test]
fn a_synchronized_exchange_passes_every_property_in_every_schedule() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.barrier(&[0, 1], &[]);
    s.read(1, 0x10);
    let (g, arena) = s.completed(2);
    let r = report(&g, &arena);
    assert_eq!(r.verdict_overall(), Verdict::Pass, "{:?}", verdicts(&r));
    assert_eq!(r.scope, ProofScope::ScheduleIndependent);
}

#[test]
fn a_race_fails_memory_conflicts_alone() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.read(1, 0x10);
    let (g, arena) = s.completed(2);
    let r = report(&g, &arena);
    for (p, v) in verdicts(&r) {
        let expected = if p == Property::MemoryConflicts {
            Verdict::Fail
        } else {
            Verdict::Pass
        };
        assert_eq!(v, expected, "{p:?}");
    }
    assert_eq!(r.verdict_overall(), Verdict::Fail);
    assert_eq!(r.summary(Property::MemoryConflicts).findings.len(), 1);
}

#[test]
fn asynchronous_operations_make_passes_candidate_only() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.barrier(&[0, 1], &[]);
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
    s.read(1, 0x10);
    let (g, arena) = s.completed(2);
    let r = report(&g, &arena);
    let ProofScope::CandidateOnly { reasons } = &r.scope else {
        panic!("{:?}", r.scope);
    };
    assert!(reasons[0].contains("cp.async.bulk"), "{reasons:?}");
    assert!(reasons[1].contains("mbarrier"), "{reasons:?}");
}

#[test]
fn a_stuck_execution_fails_progress() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 1);
    s.b.wait_start(t(0), PC, m, Parity::Even);
    let (g, arena) = s.finish(Terminal::Stuck {
        blocked: vec![BlockedThread {
            thread: t(0),
            pc: PC,
            on: BlockedOn::Mbarrier {
                object: m,
                parity: Parity::Even,
                state: volta_graph::MbarrierState {
                    completed_phases: 0,
                    arrived: 0,
                    expected: 1,
                    pending_tx: 0,
                },
            },
        }],
    });
    let r = report(&g, &arena);
    assert_eq!(r.verdict(Property::Progress), Verdict::Fail);
    assert_eq!(r.verdict_overall(), Verdict::Fail);
}
