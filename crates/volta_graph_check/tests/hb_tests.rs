//! The happens-before view in isolation: which typed edges order which events.

mod common;

use std::collections::{HashMap, HashSet};

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, ContributionKind, EventGraph, EventId, Parity, Proxy, SyncObjectKind,
    ThreadIx,
};
use volta_graph_check::hb::{Admission, Point, ThreadPoint, Validated, sweep, thread_points};

/// Whether `a` happens before `b` under `admission` (`a` a thread event or async effect).
fn hb(graph: &EventGraph, admission: &Admission, a: EventId, b: EventId) -> bool {
    let points = thread_points(graph);
    let mut answer = None;
    let a_point = points[a.0 as usize];
    let a_op = match graph.event(a).ctx {
        volta_graph::ExecContext::Async(op) => Some(op),
        _ => None,
    };
    sweep(graph, admission, |e, view| {
        if e == b {
            answer = Some(match (a_point, a_op) {
                (Some(p), _) => {
                    if let Point::Thread(cur) = view.point() {
                        if cur.thread == p.thread {
                            assert!(p.index <= cur.index);
                        }
                    }
                    view.thread_hb(p)
                }
                (None, Some(op)) => view.effects_hb(op),
                (None, None) => unreachable!("queries start at thread events or effects"),
            });
        }
    });
    answer.expect("b was visited")
}

#[test]
fn program_order_orders_a_thread_and_nothing_else() {
    let mut s = Scenario::new(2);
    let w0 = s.write(0, 0, 1);
    let r0 = s.read(0, 0);
    let r1 = s.read(1, 0);
    let (g, _) = s.completed(2);
    let all = Admission::candidate();
    assert!(hb(&g, &all, w0, r0));
    assert!(!hb(&g, &all, w0, r1));
}

#[test]
fn a_full_barrier_orders_both_directions() {
    let mut s = Scenario::new(2);
    let w0 = s.write(0, 0, 1);
    let r1_before = s.read(1, 4);
    s.barrier(&[0, 1], &[]);
    let r1 = s.read(1, 0);
    let w0_after = s.write(0, 4, 2);
    let (g, _) = s.completed(2);
    let all = Admission::candidate();
    assert!(hb(&g, &all, w0, r1));
    assert!(hb(&g, &all, r1_before, w0_after));
}

#[test]
fn an_unadmitted_generation_orders_nothing() {
    let mut s = Scenario::new(2);
    let w0 = s.write(0, 0, 1);
    let bar = s.barrier(&[0, 1], &[]);
    let r1 = s.read(1, 0);
    let (g, _) = s.completed(2);
    let mut admitted = HashSet::new();
    admitted.insert(volta_graph::GenerationId(bar.0 + 1));
    let none = Admission {
        generations: Validated::Only(admitted),
        completions: Validated::All,
        exited_threads: true,
    };
    assert!(!hb(&g, &none, w0, r1));
    assert!(hb(&g, &Admission::candidate(), w0, r1));
}

#[test]
fn an_exited_thread_orders_only_when_admitted() {
    let mut s = Scenario::new(2);
    let w1 = s.write(1, 0, 1);
    s.exit(1);
    s.barrier(&[0], &[1]);
    let r0 = s.read(0, 0);
    let (g, _) = s.completed(2);
    assert!(hb(&g, &Admission::candidate(), w1, r0));
    let without = Admission {
        exited_threads: false,
        ..Admission::candidate()
    };
    assert!(!hb(&g, &without, w1, r0));
}

#[test]
fn a_non_blocking_arrival_orders_only_what_precedes_it() {
    let mut s = Scenario::new(2);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let before = s.write(0, 0, 1);
    let g = s.b.open_generation(
        bar,
        0,
        volta_graph::GenerationKind::Barrier {
            arrivals: volta_graph::BarrierArrivals::Count(2),
        },
    );
    s.arrive(0, g);
    let after = s.write(0, 4, 2);
    s.b.contribute(t(1), PC, g, ContributionKind::Blocking);
    s.complete(g);
    s.b.resume(t(1), PC, g);
    let r1 = s.read(1, 0);
    let (graph, _) = s.completed(2);
    let all = Admission::candidate();
    assert!(hb(&graph, &all, before, r1));
    assert!(!hb(&graph, &all, after, r1));
}

#[test]
fn happens_before_is_transitive_through_a_middle_thread() {
    let mut s = Scenario::new(3);
    let bar1 = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let bar2 = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 2 });
    let w0 = s.write(0, 0, 1);
    s.counted_barrier(bar1, 0, 2, &[], &[0, 1]);
    s.counted_barrier(bar2, 0, 2, &[], &[1, 2]);
    let r2 = s.read(2, 0);
    let (g, _) = s.completed(3);
    assert!(hb(&g, &Admission::candidate(), w0, r2));
}

/// Thread 0 issues an async write and arrives; `waiter` waits on the phase tracking it.
fn async_write_observed_by(waiter: u32) -> (EventGraph, EventId, HashMap<&'static str, EventId>) {
    let mut s = Scenario::new(3);
    let m = s.mbarrier(0, 1);
    let phase = s.phase(m, 0);
    let op = s.async_op(0, AsyncOpKind::BulkCopy, AccessMode::Write, 0, Proxy::Async);
    s.b.track(op, phase, 4);
    s.arrive(0, phase);
    let mut marks = HashMap::new();
    marks.insert("issuer_after", s.read(0, 0));
    s.complete(phase);
    s.wait(waiter, m, Parity::Even, phase);
    marks.insert("waiter_after", s.read(waiter, 0));
    marks.insert("bystander", s.read(2, 0));
    let effect =
        s.b.graph_so_far()
            .events()
            .iter()
            .find(|(_, e)| matches!(e.kind, volta_graph::EventKind::Access(_)))
            .unwrap()
            .0;
    let (g, _) = s.completed(3);
    (g, effect, marks)
}

#[test]
fn an_async_effect_is_ordered_only_through_its_observed_completion() {
    let (g, effect, marks) = async_write_observed_by(1);
    let all = Admission::candidate();
    assert!(hb(&g, &all, effect, marks["waiter_after"]));
    assert!(!hb(&g, &all, effect, marks["issuer_after"]));
    assert!(!hb(&g, &all, effect, marks["bystander"]));
    let unadmitted = Admission {
        completions: Validated::none(),
        ..Admission::candidate()
    };
    assert!(!hb(&g, &unadmitted, effect, marks["waiter_after"]));
}

#[test]
fn a_relaxed_complete_tx_orders_nothing() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let phase = s.phase(m, 0);
    let w0 = s.write(0, 0, 1);
    s.b.contribute(
        ThreadIx(0),
        PC,
        phase,
        ContributionKind::CompleteTx { bytes: 4 },
    );
    s.arrive(1, phase);
    s.complete(phase);
    s.wait(1, m, Parity::Even, phase);
    let r1 = s.read(1, 0);
    let (g, _) = s.completed(2);
    assert!(!hb(&g, &Admission::candidate(), w0, r1));
}

#[test]
fn thread_points_count_each_thread_from_one() {
    let mut s = Scenario::new(2);
    s.write(0, 0, 1);
    s.write(1, 0, 1);
    s.write(0, 0, 1);
    let (g, _) = s.completed(2);
    let points = thread_points(&g);
    assert_eq!(
        points[2],
        Some(ThreadPoint {
            thread: ThreadIx(0),
            index: 2
        })
    );
}
