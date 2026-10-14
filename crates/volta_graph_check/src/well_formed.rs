//! **Graph/model well-formedness and extraction fidelity.**
//!
//! * Property: the graph satisfies its representation invariants and is a complete candidate
//!   execution under Volta's supported model.
//! * Uses: [`volta_graph::EventGraph::validate`], the terminal state, every effect's
//!   ordering kind, the provenance's assumptions and launch.
//! * Prerequisites: none.
//! * `Pass`: the graph validates (so every typed edge runs forward and the relation it
//!   generates is acyclic), the execution reached a terminal state (completed or stuck) under
//!   the structured-CTA assumption, and every effect is an ordinary access.
//! * `Fail`: a representation invariant is violated (a producer defect), with each defect.
//! * `Unknown`: the execution was aborted (the graph is a prefix), the producer did not
//!   record the structured-CTA assumption, or an effect is atomic or a reduction (no
//!   checker models those).

use volta_graph::{Assumption, EventGraph, GraphDefect, OrderingKind, Terminal};

use crate::result::{PropertyResult, Unresolved};

/// What a passing graph established.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct WellFormedEvidence {
    pub events: usize,
    pub effects: usize,
    pub threads: u32,
}

pub type WellFormedResult = PropertyResult<WellFormedEvidence, GraphDefect>;

pub fn check_well_formed(graph: &EventGraph) -> WellFormedResult {
    if let Err(defects) = graph.validate() {
        return PropertyResult::Fail(defects);
    }
    let mut unresolved = Vec::new();
    if let Terminal::Aborted { reason, .. } = graph.terminal() {
        unresolved.push(Unresolved::global(format!(
            "the candidate execution was aborted, so the graph is only a prefix: {}",
            reason
        )));
    }
    if !graph.provenance().assumes(Assumption::StructuredCta) {
        unresolved.push(Unresolved::global(
            "the producer did not establish concrete addresses and control flow",
        ));
    }
    if graph.provenance().threads() != graph.threads() {
        unresolved.push(Unresolved::global(format!(
            "the launch has {} threads but the graph records {}",
            graph.provenance().threads(),
            graph.threads()
        )));
    }
    for (id, ev) in graph.events().iter() {
        if let volta_graph::EventKind::Access(a) = ev.kind
            && graph.access(a).ordering != OrderingKind::Ordinary
        {
            unresolved.push(Unresolved::at(
                id,
                format!("{:?} effects are not modeled", graph.access(a).ordering),
            ));
        }
    }
    PropertyResult::from_findings(
        WellFormedEvidence {
            events: graph.events().len(),
            effects: graph.accesses().len(),
            threads: graph.threads(),
        },
        Vec::new(),
        unresolved,
    )
}
