//! Lean extraction checks the execution's graph evidence before stating any propositions.

use std::fmt;

use volta_graph_check::{Deadlock, GraphConclusion, PropertySummary};

use crate::{
    DEFAULT_LEAN_NAMESPACE, EquivalenceVerdict, GraphEvidence, KernelRun, LeanChallenge,
    LeanSolution, Spec, claim, decide, state_against_spec,
};

#[derive(Debug)]
pub enum LeanExtractionError {
    Rejected {
        failed: Vec<PropertySummary>,
        deadlock: Option<Deadlock>,
    },
    Incomplete(Vec<String>),
    NoOutputs(String),
    InvalidClaim(String),
    Spec(volta_spec::SpecError),
    NoStatements(EquivalenceVerdict),
}

impl fmt::Display for LeanExtractionError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Lean extraction failed: ")?;
        match self {
            Self::Rejected { failed, deadlock } => {
                let reasons = deadlock
                    .iter()
                    .map(|d| {
                        format!(
                            "trace deadlocked with {} blocked thread(s)",
                            d.blocked.len()
                        )
                    })
                    .chain(failed.iter().map(|s| match s.findings.first() {
                        Some(witness) => format!("{} failed: {witness}", s.property.name()),
                        None => format!("{} failed", s.property.name()),
                    }))
                    .collect::<Vec<_>>();
                write!(f, "{}", reasons.join("; "))
            }
            Self::Incomplete(reasons) => {
                write!(f, "graph verification is UNKNOWN: {}", reasons.join("; "))
            }
            Self::NoOutputs(why) | Self::InvalidClaim(why) => write!(f, "{why}"),
            Self::Spec(e) => write!(f, "building spec: {e}"),
            Self::NoStatements(verdict) => {
                write!(f, "{}", decide(verdict, &[]).evidence.join("; "))
            }
        }
    }
}

impl std::error::Error for LeanExtractionError {}

impl KernelRun {
    /// Extract a Lean module after every available graph check passes. Interpreters that
    /// record no graph (AMD and NKI) can extract, but establish no race-freedom claim.
    /// The resulting propositions remain proof obligations, not equivalence proofs.
    pub fn extract_lean(
        &self,
        spec: &Spec,
        tolerance: Option<&str>,
    ) -> Result<LeanChallenge, LeanExtractionError> {
        if let GraphEvidence::Checked { report, .. } = &self.graph {
            match report.conclusion() {
                GraphConclusion::Rejected { failed, deadlock } => {
                    return Err(LeanExtractionError::Rejected { failed, deadlock });
                }
                GraphConclusion::Unknown { reasons } => {
                    return Err(LeanExtractionError::Incomplete(reasons));
                }
                GraphConclusion::Verified => {}
            }
        }
        let outputs = self
            .outputs
            .as_ref()
            .map_err(|why| LeanExtractionError::NoOutputs(why.clone()))?;
        let claim = claim(tolerance).map_err(LeanExtractionError::InvalidClaim)?;
        match state_against_spec(outputs, spec, &claim, DEFAULT_LEAN_NAMESPACE)
            .map_err(LeanExtractionError::Spec)?
        {
            LeanSolution::Stated(challenge) => Ok(challenge),
            LeanSolution::Stopped(verdict) => Err(LeanExtractionError::NoStatements(verdict)),
        }
    }
}
