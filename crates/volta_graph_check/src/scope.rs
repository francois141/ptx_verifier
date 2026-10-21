//! **Proof scope**: what passing the six checks establishes about schedules other than the
//! candidate execution. Not a check: "a program-level certificate additionally requires a
//! schedule-coverage argument" (§1.1, Figure 1), and this is Volta's.
//!
//! * Schedule-independent: the kernel has a fixed computation structure (the structured-CTA
//!   assumption) and the graph uses only ordinary effects, named barriers, warp collectives
//!   and no asynchronous operation. Weft's Theorem 1 (PLDI'15) makes generations that pass
//!   the barrier-epoch check the same in every schedule; with them, deterministic control
//!   flow and no unordered conflict, every schedule has the same reads-from relation, hence
//!   the same outputs.
//! * Candidate-only otherwise: no theorem here covers the completion ordering of
//!   asynchronous operations, nor mbarrier phases (the design applies Algorithm 1 to them "for
//!   now"), so passes are facts about the candidate execution.

use std::collections::BTreeSet;

use volta_graph::{Assumption, EventGraph, SyncObjectKind};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ProofScope {
    /// Passing every check implies the same verdicts and outputs in every schedule.
    ScheduleIndependent,
    /// Passing every check is a fact about the candidate execution only, for these reasons.
    CandidateOnly { reasons: Vec<String> },
}

impl ProofScope {
    pub fn is_schedule_independent(&self) -> bool {
        matches!(self, ProofScope::ScheduleIndependent)
    }
}

pub fn proof_scope(graph: &EventGraph) -> ProofScope {
    let mut reasons = Vec::new();
    if !graph.provenance().assumes(Assumption::StructuredCta) {
        reasons
            .push("the producer did not establish concrete addresses and control flow".to_string());
    }
    let kinds: BTreeSet<&str> = graph
        .async_ops()
        .values()
        .map(|op| op.kind.name())
        .collect();
    if !kinds.is_empty() {
        reasons.push(format!(
            "asynchronous operations ({}): no schedule-independence theorem covers their \
             completion ordering",
            kinds.into_iter().collect::<Vec<_>>().join(", ")
        ));
    }
    if graph
        .objects()
        .values()
        .any(|o| matches!(o.kind, SyncObjectKind::Mbarrier { .. }))
    {
        reasons.push(
            "mbarrier phases: Algorithm 1 is applied to them without a schedule-independence \
             theorem"
                .to_string(),
        );
    }
    if reasons.is_empty() {
        ProofScope::ScheduleIndependent
    } else {
        ProofScope::CandidateOnly { reasons }
    }
}
