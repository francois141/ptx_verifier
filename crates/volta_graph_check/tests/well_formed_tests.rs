//! The well-formedness checker in isolation.

mod common;

use common::*;
use volta_graph::{
    AccessMode, Footprint, MemAccess, OperandRole, OrderingKind, Proxy, Space, Terminal, ThreadIx,
};
use volta_graph_check::Verdict;
use volta_graph_check::well_formed::check_well_formed;

#[test]
fn a_completed_execution_of_ordinary_effects_passes() {
    let mut s = Scenario::new(2);
    s.write(0, 0, 1);
    s.barrier(&[0, 1], &[]);
    s.read(1, 0);
    let (graph, _) = s.completed(2);
    let result = check_well_formed(&graph);
    assert_eq!(result.verdict(), Verdict::Pass, "{:?}", result);
}

#[test]
fn a_stuck_execution_is_still_well_formed() {
    let mut s = Scenario::new(1);
    s.write(0, 0, 1);
    let (graph, _) = s.finish(Terminal::Stuck {
        blocked: vec![volta_graph::BlockedThread {
            thread: ThreadIx(0),
            pc: PC,
            on: volta_graph::BlockedOn::Barrier {
                generation: volta_graph::GenerationId(0),
            },
        }],
    });
    assert_eq!(check_well_formed(&graph).verdict(), Verdict::Pass);
}

#[test]
fn an_aborted_execution_is_unknown() {
    let mut s = Scenario::new(1);
    s.write(0, 0, 1);
    let (graph, _) = s.finish(Terminal::Aborted {
        thread: Some(ThreadIx(0)),
        pc: Some(PC),
        reason: "symbolic address".to_string(),
    });
    let result = check_well_formed(&graph);
    assert_eq!(result.verdict(), Verdict::Unknown);
    assert!(result.unresolved()[0].reason.contains("symbolic address"));
}

#[test]
fn an_atomic_effect_is_unknown() {
    let mut s = Scenario::new(1);
    let access = MemAccess {
        space: Space::Global,
        mode: AccessMode::Read,
        ordering: OrderingKind::Atomic,
        proxy: Proxy::Generic,
        footprint: Footprint::Bytes { addr: 0, width: 4 },
        role: OperandRole::Plain,
        attributed: ThreadIx(0),
        value: None,
    };
    s.b.thread_access(ThreadIx(0), PC, access);
    let (graph, _) = s.completed(1);
    let result = check_well_formed(&graph);
    assert_eq!(result.verdict(), Verdict::Unknown);
    assert!(result.unresolved()[0].reason.contains("Atomic"));
}

#[test]
fn a_representation_defect_fails_with_the_defect() {
    let mut s = Scenario::new(1);
    s.exit(0);
    s.read(0, 0);
    let (graph, _) = s.finish(Terminal::Completed);
    let result = check_well_formed(&graph);
    assert_eq!(result.verdict(), Verdict::Fail);
    assert!(
        result
            .violations()
            .iter()
            .any(|d| d.message.contains("after its exit"))
    );
}

#[test]
fn a_producer_without_the_structured_cta_assumption_is_unknown() {
    let mut p = provenance(1);
    p.assumptions.clear();
    let s = Scenario::with(p);
    let (graph, _) = s.completed(1);
    assert_eq!(check_well_formed(&graph).verdict(), Verdict::Unknown);
}
