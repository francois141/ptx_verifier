//! The event graph on its own: hand-built graphs, their representation invariants, the
//! deterministic dump, and footprint overlap. No producer and no property checker involved.

use volta_expr::{ExprArena, ExprId};
use volta_graph::{
    AbortCause, AccessMode, ArrivalOrdering, AsyncOpKind, BarrierArrivals, ContributionKind,
    EventKind, ExecContext, Footprint, GenerationEvidence, GenerationKind, GraphBuilder,
    InstructionInfo, MemAccess, OperandRole, OrderingKind, ProgramPoint, Provenance, Proxy, Space,
    StoredValue, SyncObjectKind, Terminal, ThreadIx,
};

fn provenance(threads: u32, instructions: usize) -> Provenance {
    Provenance {
        kernel: "k".to_string(),
        block_dim: (threads, 1, 1),
        grid_dim: (1, 1, 1),
        targets: vec!["Sm100a".to_string()],
        assumptions: Vec::new(),
        instructions: vec![
            InstructionInfo {
                kind: "test",
                span: None,
            };
            instructions
        ],
    }
}

fn expr() -> ExprId {
    ExprArena::new().int(7)
}

fn shared(thread: u32, mode: AccessMode, addr: u64, b: &mut GraphBuilder) -> MemAccess {
    let value = (mode == AccessMode::Write).then(|| b.value(StoredValue::Scalar(expr())));
    MemAccess {
        space: Space::Shared,
        mode,
        ordering: OrderingKind::Ordinary,
        proxy: Proxy::Generic,
        footprint: Footprint::Bytes { addr, width: 4 },
        role: OperandRole::Plain,
        attributed: ThreadIx(thread),
        value,
    }
}

const PC: ProgramPoint = ProgramPoint(0);

/// Two threads exchange through shared memory around one full-CTA barrier.
fn barrier_exchange() -> volta_graph::EventGraph {
    let mut b = GraphBuilder::new(provenance(2, 1));
    let bar = b.sync_object(SyncObjectKind::NamedBarrier { id: 0 });
    let g = b.open_generation(
        bar,
        0,
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::FullCta,
        },
    );
    for t in 0..2 {
        let w = shared(t, AccessMode::Write, 4 * u64::from(t), &mut b);
        b.thread_access(ThreadIx(t), PC, w);
        b.contribute(ThreadIx(t), PC, g, ContributionKind::Blocking);
    }
    b.complete_generation(g, GenerationEvidence::default());
    for t in 0..2 {
        b.resume(ThreadIx(t), PC, g);
    }
    for t in 0..2 {
        let r = shared(t, AccessMode::Read, 4 * u64::from(1 - t), &mut b);
        b.thread_access(ThreadIx(t), PC, r);
        b.exit(ThreadIx(t), PC);
    }
    b.finish(Terminal::Completed)
}

#[test]
fn a_well_formed_graph_validates_and_indexes_program_order() {
    let graph = barrier_exchange();
    assert_eq!(graph.validate(), Ok(()));
    let order: Vec<EventKind> = graph
        .program_order(ThreadIx(0))
        .iter()
        .map(|&e| graph.event(e).kind)
        .collect();
    assert!(matches!(
        order.as_slice(),
        [
            EventKind::Access(_),
            EventKind::Contribute(_),
            EventKind::Resume(_),
            EventKind::Access(_),
            EventKind::Exit
        ]
    ));
    let g = &graph.generations().values().next().unwrap();
    assert_eq!(g.contributions.len(), 2);
    assert_eq!(g.releases.len(), 2);
}

#[test]
fn the_dump_is_deterministic_and_names_every_edge() {
    let a = barrier_exchange().dump();
    let b = barrier_exchange().dump();
    assert_eq!(a, b);
    assert!(a.starts_with("volta-graph 1\n"));
    assert!(a.contains("generation g0 o0#0 barrier full-cta complete=e4"));
    assert!(a.contains("  contrib e1 blocking"));
    assert!(a.contains("  release e5 e6"));
    assert!(a.contains("e0 t0 pc0 write ordinary generic shared Plain by t0 [0x0,+4) = n0"));
    assert!(a.ends_with("terminal completed\n"));
}

#[test]
fn async_effects_stay_out_of_program_order() {
    let mut b = GraphBuilder::new(provenance(1, 1));
    let waits = b.sync_object(SyncObjectKind::AsyncGroupWait {
        thread: ThreadIx(0),
    });
    let op = b.async_issue(ThreadIx(0), PC, AsyncOpKind::CpAsync);
    let w = shared(0, AccessMode::Write, 0, &mut b);
    b.async_effect(op, w);
    let g = b.open_generation(waits, 0, GenerationKind::AsyncGroupWait { keep_pending: 0 });
    b.track(op, g, 0);
    b.complete_generation(g, GenerationEvidence::default());
    b.resume(ThreadIx(0), PC, g);
    b.exit(ThreadIx(0), PC);
    let graph = b.finish(Terminal::Completed);
    assert_eq!(graph.validate(), Ok(()));
    let a = graph.async_op(op);
    assert_eq!(a.tracking, vec![g]);
    assert!(graph.program_order(ThreadIx(0)).iter().all(|&e| {
        !matches!(
            graph.event(e).kind,
            EventKind::Access(_) | EventKind::AsyncComplete(_)
        )
    }));
    let effect = graph
        .events()
        .iter()
        .find(|(_, e)| matches!(e.kind, EventKind::Access(_)))
        .unwrap();
    assert_eq!(effect.1.ctx, ExecContext::Async(op));
    assert_eq!(graph.acting_thread(effect.0), Some(ThreadIx(0)));
}

fn defects(graph: &volta_graph::EventGraph) -> Vec<String> {
    graph
        .validate()
        .err()
        .unwrap_or_default()
        .into_iter()
        .map(|d| d.message)
        .collect()
}

#[test]
fn a_release_without_completion_is_a_defect() {
    let mut b = GraphBuilder::new(provenance(1, 1));
    let bar = b.sync_object(SyncObjectKind::NamedBarrier { id: 0 });
    let g = b.open_generation(
        bar,
        0,
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::Count(32),
        },
    );
    b.resume(ThreadIx(0), PC, g);
    let found = defects(&b.finish(Terminal::Aborted {
        thread: None,
        pc: None,
        cause: AbortCause::Error,
        reason: "test".to_string(),
    }));
    assert!(
        found.iter().any(|m| m.contains("never completed")),
        "{found:?}"
    );
}

#[test]
fn a_contributed_pre_init_phase_is_a_defect() {
    let mut b = GraphBuilder::new(provenance(1, 1));
    let m = b.sync_object(SyncObjectKind::Mbarrier {
        addr: 0,
        expected_arrivals: 1,
    });
    b.object_init(ThreadIx(0), PC, m);
    let pre_init = b.open_generation(m, 0, GenerationKind::MbarrierPreInit);
    b.contribute(
        ThreadIx(0),
        PC,
        pre_init,
        ContributionKind::Arrival {
            count: 1,
            expect_tx: 0,
            ordering: ArrivalOrdering::Release,
        },
    );
    b.complete_generation(pre_init, GenerationEvidence::default());
    b.open_generation(m, 0, GenerationKind::MbarrierPhase);
    let found = defects(&b.finish(Terminal::Aborted {
        thread: None,
        pc: None,
        cause: AbortCause::Error,
        reason: "test".to_string(),
    }));
    assert_eq!(
        found,
        vec![format!(
            "pre-init generation {} is not an uncontributed, completed index 0",
            pre_init.0
        )]
    );
}

#[test]
fn a_contribution_after_completion_is_a_defect() {
    let mut b = GraphBuilder::new(provenance(1, 1));
    let bar = b.sync_object(SyncObjectKind::NamedBarrier { id: 0 });
    let g = b.open_generation(
        bar,
        0,
        GenerationKind::Barrier {
            arrivals: BarrierArrivals::FullCta,
        },
    );
    b.complete_generation(g, GenerationEvidence::default());
    b.contribute(ThreadIx(0), PC, g, ContributionKind::Blocking);
    let found = defects(&b.finish(Terminal::Aborted {
        thread: None,
        pc: None,
        cause: AbortCause::Error,
        reason: "test".to_string(),
    }));
    assert!(
        found.iter().any(|m| m.contains("after its completion")),
        "{found:?}"
    );
}

#[test]
fn an_event_after_exit_is_a_defect() {
    let mut b = GraphBuilder::new(provenance(1, 1));
    b.exit(ThreadIx(0), PC);
    let r = shared(0, AccessMode::Read, 0, &mut b);
    b.thread_access(ThreadIx(0), PC, r);
    let found = defects(&b.finish(Terminal::Completed));
    assert!(
        found.iter().any(|m| m.contains("after its exit")),
        "{found:?}"
    );
}

#[test]
fn terminal_states_must_agree_with_the_threads() {
    let mut b = GraphBuilder::new(provenance(2, 1));
    b.exit(ThreadIx(0), PC);
    let found = defects(&b.finish(Terminal::Completed));
    assert!(
        found.iter().any(|m| m.contains("never exited")),
        "{found:?}"
    );

    let mut b = GraphBuilder::new(provenance(1, 1));
    b.exit(ThreadIx(0), PC);
    let found = defects(&b.finish(Terminal::Stuck {
        blocked: vec![volta_graph::BlockedThread {
            thread: ThreadIx(0),
            pc: PC,
            on: volta_graph::BlockedOn::Barrier {
                generation: volta_graph::GenerationId(0),
            },
        }],
    }));
    assert!(
        found.iter().any(|m| m.contains("listed as blocked")),
        "{found:?}"
    );
}

#[test]
fn malformed_effects_are_defects() {
    let mut b = GraphBuilder::new(provenance(1, 1));
    let mut w = shared(0, AccessMode::Write, 0, &mut b);
    w.value = None;
    b.thread_access(ThreadIx(0), PC, w);
    let mut r = shared(0, AccessMode::Read, 0, &mut b);
    r.footprint = Footprint::Bytes { addr: 0, width: 0 };
    b.thread_access(ThreadIx(0), PC, r);
    let mut other = shared(0, AccessMode::Read, 0, &mut b);
    other.attributed = ThreadIx(1);
    b.thread_access(ThreadIx(0), PC, other);
    b.exit(ThreadIx(0), PC);
    let found = defects(&b.finish(Terminal::Completed));
    assert!(
        found.iter().any(|m| m.contains("without a stored value")),
        "{found:?}"
    );
    assert!(
        found.iter().any(|m| m.contains("malformed footprint")),
        "{found:?}"
    );
    assert!(
        found
            .iter()
            .any(|m| m.contains("attributed to another thread")),
        "{found:?}"
    );
}

#[test]
fn footprints_overlap_only_on_shared_locations() {
    let bytes = |addr, width| Footprint::Bytes { addr, width };
    assert!(bytes(0x10, 4).overlaps(&bytes(0x12, 4)));
    assert!(!bytes(0x10, 4).overlaps(&bytes(0x14, 4)));
    assert!(bytes(u64::MAX - 3, 4).overlaps(&bytes(u64::MAX, 1)));
    let tmem = |lane, lanes, col, cols| Footprint::Tensor {
        lane,
        lanes,
        col,
        cols,
    };
    assert!(tmem(0, 128, 0, 8).overlaps(&tmem(32, 1, 7, 1)));
    assert!(!tmem(0, 32, 0, 8).overlaps(&tmem(32, 32, 0, 8)));
    assert!(!tmem(0, 128, 0, 8).overlaps(&tmem(0, 128, 8, 8)));
    assert!(!bytes(0, 4).overlaps(&tmem(0, 1, 0, 1)));
}
