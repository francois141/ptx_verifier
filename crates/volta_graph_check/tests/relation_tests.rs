//! The typed edge projections `G0` and `G_HB` = `D` on their own: which edges order which
//! events, and `D`'s explicit successors. No check involved.

mod common;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpKind, BarrierArrivals, CollectiveSide, ContributionKind, EventGraph,
    EventId, ExecContext, GenerationEvidence, GenerationKind, Parity, Proxy, SyncObjectKind,
    ThreadIx,
};
use volta_graph_check::relation::{HbView, IndependentGraph, ValidatedGraph, thread_points};

/// Whether `a` reaches `b` (`a` a thread event or async effect) in the sweep `run` performs.
fn reaches(
    graph: &EventGraph,
    run: impl Fn(&mut dyn FnMut(EventId, &HbView)),
    a: EventId,
    b: EventId,
) -> bool {
    let point = thread_points(graph)[a.0 as usize];
    let op = match graph.event(a).ctx {
        ExecContext::Async(op) => Some(op),
        _ => None,
    };
    let mut answer = None;
    run(&mut |e, view| {
        if e == b {
            answer = Some(match (point, op) {
                (Some(p), _) => view.thread_hb(p),
                (None, Some(op)) => view.effects_hb(op),
                (None, None) => unreachable!("queries start at thread events or effects"),
            });
        }
    });
    answer.expect("b was visited")
}

fn in_g0(graph: &EventGraph, a: EventId, b: EventId) -> bool {
    let g0 = IndependentGraph::new(graph).unwrap();
    reaches(graph, |visit| g0.sweep(visit), a, b)
}

fn in_hb(graph: &EventGraph, a: EventId, b: EventId) -> bool {
    let h = ValidatedGraph::assuming_epochs(graph).unwrap();
    reaches(graph, |visit| h.sweep(visit), a, b)
}

#[test]
fn program_order_orders_a_thread_and_nothing_else() {
    let mut s = Scenario::new(2);
    let w0 = s.write(0, 0, 1);
    let r0 = s.read(0, 0);
    let r1 = s.read(1, 0);
    let (g, _) = s.completed(2);
    assert!(in_hb(&g, w0, r0) && in_g0(&g, w0, r0));
    assert!(!in_hb(&g, w0, r1));
}

#[test]
fn a_full_barrier_orders_both_directions_in_both_projections() {
    let mut s = Scenario::new(2);
    let w0 = s.write(0, 0, 1);
    let r1_before = s.read(1, 4);
    s.barrier(&[0, 1], &[]);
    let r1 = s.read(1, 0);
    let w0_after = s.write(0, 4, 2);
    let (g, _) = s.completed(2);
    for reach in [in_g0, in_hb] {
        assert!(reach(&g, w0, r1));
        assert!(reach(&g, r1_before, w0_after));
    }
}

#[test]
fn an_exited_thread_orders_only_under_the_sync_prime_assumption() {
    let build = |assume: bool| {
        let mut p = provenance(2);
        if !assume {
            p.assumptions
                .retain(|a| *a != volta_graph::Assumption::ExitedThreadsArrive);
        }
        let mut s = Scenario::with(p);
        let w1 = s.write(1, 0, 1);
        s.exit(1);
        s.barrier(&[0], &[1]);
        let r0 = s.read(0, 0);
        (s.completed(2).0, w1, r0)
    };
    let (g, w1, r0) = build(true);
    assert!(in_hb(&g, w1, r0));
    let (g, w1, r0) = build(false);
    assert!(!in_hb(&g, w1, r0));
}

#[test]
fn a_non_blocking_arrival_orders_only_what_precedes_it() {
    let mut s = Scenario::new(2);
    let bar = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let before = s.write(0, 0, 1);
    let g = s.b.open_generation(
        bar,
        0,
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::Count(2),
        },
    );
    s.arrive(0, g);
    let after = s.write(0, 4, 2);
    s.b.contribute(t(1), PC, g, ContributionKind::Blocking);
    s.complete(g);
    s.b.resume(t(1), PC, g);
    let r1 = s.read(1, 0);
    let (graph, _) = s.completed(2);
    assert!(in_hb(&graph, before, r1));
    assert!(!in_hb(&graph, after, r1));
}

#[test]
fn reachability_is_transitive_through_a_middle_thread() {
    let mut s = Scenario::new(3);
    let bar1 = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 1 });
    let bar2 = s.b.sync_object(SyncObjectKind::NamedBarrier { id: 2 });
    let w0 = s.write(0, 0, 1);
    s.counted_barrier(bar1, 0, 2, &[], &[0, 1]);
    s.counted_barrier(bar2, 0, 2, &[], &[1, 2]);
    let r2 = s.read(2, 0);
    let (g, _) = s.completed(3);
    assert!(in_hb(&g, w0, r2));
}

/// Thread 0 issues a bulk copy tracked by an mbarrier phase; `waiter` waits on the phase.
fn async_write_observed_by(waiter: u32) -> (EventGraph, EventId, [EventId; 3]) {
    let mut s = Scenario::new(3);
    let m = s.mbarrier(0, 1);
    let phase = s.phase(m, 0);
    let op = s.async_op(0, AsyncOpKind::BulkCopy, AccessMode::Write, 0, Proxy::Async);
    s.b.track(op, phase, 4);
    s.arrive(0, phase);
    let issuer_after = s.read(0, 0);
    s.complete(phase);
    s.wait(waiter, m, Parity::Even, phase);
    let waiter_after = s.read(waiter, 0);
    let bystander = s.read(2, 0);
    let effect = s.effect(op);
    let (g, _) = s.completed(3);
    (g, effect, [issuer_after, waiter_after, bystander])
}

#[test]
fn an_async_effect_is_ordered_only_through_its_observed_completion() {
    let (g, effect, [issuer_after, waiter_after, bystander]) = async_write_observed_by(1);
    assert!(in_hb(&g, effect, waiter_after));
    assert!(
        !in_hb(&g, effect, issuer_after),
        "issuance orders nothing after the effects"
    );
    assert!(!in_hb(&g, effect, bystander));
}

#[test]
fn g0_excludes_the_completion_joins_of_mbarrier_phases() {
    let (g, effect, [_, waiter_after, _]) = async_write_observed_by(1);
    assert!(!in_g0(&g, effect, waiter_after));
    assert!(in_hb(&g, effect, waiter_after));
}

#[test]
fn g0_keeps_the_completion_joins_of_a_warps_wait() {
    let mut s = Scenario::new(1);
    let warp = s.b.sync_object(SyncObjectKind::WarpCollective { warp: 0 });
    let (ld, effect) = s.tmem_ld(0, 0, (0, 8));
    let kind = |side| GenerationKind::Collective {
        pc: PC,
        mask: 1,
        side,
    };
    let entry = s.b.open_generation(warp, 0, kind(CollectiveSide::Entry));
    s.b.contribute(t(0), PC, entry, ContributionKind::Blocking);
    s.b.complete_generation(entry, GenerationEvidence::default());
    s.b.resume(t(0), PC, entry);
    let exit = s.b.open_generation(warp, 0, kind(CollectiveSide::Exit));
    s.b.track(ld, exit, 0);
    s.b.contribute(t(0), PC, exit, ContributionKind::Blocking);
    s.b.complete_generation(exit, GenerationEvidence::default());
    s.b.resume(t(0), PC, exit);
    let after = s.read(0, 0);
    let (g, _) = s.completed(1);
    assert!(in_g0(&g, effect, after));
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
    assert!(!in_hb(&g, w0, r1));
}

#[test]
fn d_lists_program_order_causal_and_synchronization_successors() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let phase = s.phase(m, 0);
    let op = s.async_op(0, AsyncOpKind::BulkCopy, AccessMode::Write, 0, Proxy::Async);
    s.b.track(op, phase, 4);
    let arrival = s.arrive(0, phase);
    let done = s.complete(phase);
    let release = s.wait(1, m, Parity::Even, phase);
    let effect = s.effect(op);
    let (g, _) = s.completed(2);
    let d = ValidatedGraph::assuming_epochs(&g).unwrap().successors();
    let issue = g.async_op(op).issue;
    let completion = g.async_op(op).completion.unwrap();
    assert_eq!(
        d.of(issue),
        [effect, arrival],
        "the effect (causal) and the next event (PO)"
    );
    assert_eq!(d.of(effect), [completion]);
    assert_eq!(d.of(completion), [done]);
    assert!(d.of(arrival).contains(&done));
    assert_eq!(d.of(done), [release]);
}

#[test]
fn thread_points_count_each_thread_from_one() {
    let mut s = Scenario::new(2);
    s.write(0, 0, 1);
    s.write(1, 0, 1);
    s.write(0, 0, 1);
    let (g, _) = s.completed(2);
    assert_eq!(
        thread_points(&g)[2],
        Some(volta_graph_check::relation::ThreadPoint {
            thread: ThreadIx(0),
            index: 2
        })
    );
}
