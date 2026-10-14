//! **Proof scope**: what passing every property establishes about schedules other than the
//! candidate execution.
//!
//! * Schedule-independent: the graph uses only ordinary effects, CTA-wide and named
//!   barriers, warp collectives and `cp.async` group waits. Weft's Theorem 1 (PLDI'15) makes
//!   the barrier checker's generation stability hold in every schedule, and with stable
//!   generations, deterministic control flow (the structured-CTA assumption) and no
//!   unordered conflict in the candidate execution, every schedule has the same reads-from
//!   relation, hence the same outputs: the argument of Weft's race checking and of the
//!   paper's soundness theorem for its `Sync'` semantics.
//! * Candidate-only otherwise: no theorem here covers the completion ordering of
//!   asynchronous operations or Volta's mbarrier generation-stability adaptation, so passes
//!   are facts about the candidate execution.

use std::collections::BTreeSet;

use volta_graph::{EventGraph, SyncObjectKind};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ProofScope {
    /// Passing every property implies the same verdicts and outputs in every schedule.
    ScheduleIndependent,
    /// Passing every property is a fact about the candidate execution only, for these
    /// reasons.
    CandidateOnly { reasons: Vec<String> },
}

impl ProofScope {
    pub fn is_schedule_independent(&self) -> bool {
        matches!(self, ProofScope::ScheduleIndependent)
    }
}

pub fn proof_scope(graph: &EventGraph) -> ProofScope {
    let mut reasons = Vec::new();
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
            "mbarrier phases: Volta's generation-stability adaptation has no published theorem"
                .to_string(),
        );
    }
    if reasons.is_empty() {
        ProofScope::ScheduleIndependent
    } else {
        ProofScope::CandidateOnly { reasons }
    }
}
