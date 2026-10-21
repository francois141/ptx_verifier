//! The suite: the six checks in order, their prerequisites, the trace generator's terminal
//! state and the proof scope.

mod common;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, BlockedOn, BlockedThread, EventGraph, MbarrierState, Parity, Proxy,
    SyncObjectKind, Terminal,
};
use volta_graph_check::{GraphConclusion, GraphReport, ProofScope, Property, Verdict, check_graph};

fn verdicts(r: &GraphReport) -> Vec<(Property, Verdict)> {
    Property::ALL.iter().map(|&p| (p, r.verdict(p))).collect()
}

#[test]
fn exactly_the_six_checks_of_the_design_in_its_order() {
    let algorithms: Vec<&str> = Property::ALL.iter().map(|p| p.algorithm()).collect();
    assert_eq!(
        algorithms,
        [
            "Algorithm 1",
            "Algorithm 1",
            "Algorithm 2",
            "Algorithm 3",
            "Algorithms 4 and 5",
            "Algorithm 6"
        ]
    );
}

#[test]
fn every_check_follows_its_prerequisites() {
    for (i, p) in Property::ALL.iter().enumerate() {
        for q in p.prerequisites() {
            let at = Property::ALL.iter().position(|x| x == q).unwrap();
            assert!(at < i, "{p:?} runs before its prerequisite {q:?}");
        }
    }
}

#[test]
fn a_synchronized_exchange_is_verified_in_every_schedule() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.barrier(&[0, 1], &[]);
    s.read(1, 0x10);
    let (g, _) = s.completed(2);
    let r = check_graph(&g);
    assert_eq!(r.verdict_overall(), Verdict::Pass, "{:?}", verdicts(&r));
    assert_eq!(r.scope, ProofScope::ScheduleIndependent);
    assert_eq!(r.conclusion(), GraphConclusion::Verified);
}

#[test]
fn a_race_fails_memory_conflict_and_leaves_proxy_ordering_unchecked() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.read(1, 0x10);
    let (g, _) = s.completed(2);
    let r = check_graph(&g);
    for (p, v) in verdicts(&r) {
        let expected = match p {
            Property::MemoryConflict => Verdict::Fail,
            Property::ProxyOrder => Verdict::Unknown,
            _ => Verdict::Pass,
        };
        assert_eq!(v, expected, "{p:?}");
    }
    assert!(r.summary(Property::ProxyOrder).findings[0].contains("not checked"));
    let GraphConclusion::Rejected { failed, deadlock } = r.conclusion() else {
        panic!("{:?}", r.conclusion());
    };
    assert_eq!(failed.len(), 1);
    assert_eq!(failed[0].property, Property::MemoryConflict);
    assert_eq!(deadlock, None);
}

/// Weft's unseparated producer/consumer on a named barrier.
fn unseparated_producer_consumer() -> EventGraph {
    let mut s = Scenario::new(2);
    let full = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    s.counted_barrier(full, 0, 2, &[0], &[1]);
    s.counted_barrier(full, 1, 2, &[0], &[1]);
    s.completed(2).0
}

#[test]
fn a_barrier_epoch_violation_leaves_every_check_needing_g_hb_unchecked() {
    let r = check_graph(&unseparated_producer_consumer());
    for (p, v) in verdicts(&r) {
        let expected = match p {
            Property::NamedBarrierEpoch => Verdict::Fail,
            Property::MbarrierEpoch => Verdict::Pass,
            _ => Verdict::Unknown,
        };
        assert_eq!(v, expected, "{p:?}");
    }
    assert!(matches!(r.conclusion(), GraphConclusion::Rejected { .. }));
}

#[test]
fn asynchronous_operations_and_mbarriers_make_passes_candidate_only() {
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
    let (g, _) = s.completed(2);
    let r = check_graph(&g);
    assert_eq!(r.verdict_overall(), Verdict::Pass, "{:?}", verdicts(&r));
    let ProofScope::CandidateOnly { reasons } = &r.scope else {
        panic!("{:?}", r.scope);
    };
    assert!(reasons[0].contains("cp.async.bulk"), "{reasons:?}");
    assert!(reasons[1].contains("mbarrier"), "{reasons:?}");
    assert!(matches!(r.conclusion(), GraphConclusion::Unknown { .. }));
}

#[test]
fn a_deadlocked_trace_is_rejected_by_the_trace_generator() {
    let mut s = Scenario::new(1);
    let m = s.mbarrier(0, 1);
    s.b.wait_start(t(0), PC, m, Parity::Even);
    let blocked = vec![BlockedThread {
        thread: t(0),
        pc: PC,
        on: BlockedOn::Mbarrier {
            object: m,
            parity: Parity::Even,
            state: MbarrierState {
                completed_phases: 0,
                arrived: 0,
                expected: 1,
                pending_tx: 0,
            },
        },
    }];
    let (g, _) = s.finish(Terminal::Stuck {
        blocked: blocked.clone(),
    });
    let r = check_graph(&g);
    assert_eq!(
        r.verdict_overall(),
        Verdict::Pass,
        "no check reports a deadlock"
    );
    let GraphConclusion::Rejected { failed, deadlock } = r.conclusion() else {
        panic!("{:?}", r.conclusion());
    };
    assert!(failed.is_empty());
    assert_eq!(deadlock.expect("the trace deadlocked").blocked, blocked);
}

#[test]
fn an_aborted_trace_is_inconclusive() {
    let mut s = Scenario::new(1);
    s.write(0, 0x10, 1);
    let (g, _) = s.aborted();
    let GraphConclusion::Unknown { reasons } = check_graph(&g).conclusion() else {
        panic!("an aborted trace is never verified");
    };
    assert!(reasons[0].contains("aborted"), "{reasons:?}");
}
