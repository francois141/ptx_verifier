//! Aggregation: the only place the two branches' results meet.

use volta_graph::Assumption;
use volta_graph_check::{GraphConclusion, GraphReport};

use crate::equivalence::EquivalenceVerdict;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Verdict {
    /// Equivalent, with every graph check passed on a completed trace.
    Accept,
    /// A refutation, a failed graph check or a deadlock, with its witness.
    Reject,
    /// Nothing refuted, but something is not established.
    Unknown,
}

impl Verdict {
    pub fn name(self) -> &'static str {
        match self {
            Verdict::Accept => "ACCEPT",
            Verdict::Reject => "REJECT",
            Verdict::Unknown => "UNKNOWN",
        }
    }
}

/// One kernel's graph-branch report and the assumptions its analysis made.
pub struct KernelEvidence<'a> {
    pub label: &'a str,
    pub graph: &'a GraphReport,
    pub assumptions: &'a [Assumption],
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Decision {
    pub verdict: Verdict,
    /// `Accept`: what was established; `Reject`: the witnesses; `Unknown`: what is missing.
    pub evidence: Vec<String>,
    /// The modeling assumptions every verdict here is relative to.
    pub assumptions: Vec<Assumption>,
}

/// Combine the equivalence branch's verdict with each kernel's graph report. ACCEPT needs a
/// complete equivalence proof and every kernel `Verified` (a completed trace, every check
/// passed); any refutation, index-set mismatch, failed check or deadlock is a REJECT;
/// anything else is UNKNOWN.
pub fn decide(equivalence: &EquivalenceVerdict, kernels: &[KernelEvidence]) -> Decision {
    let mut established = Vec::new();
    let mut rejected = Vec::new();
    let mut missing = Vec::new();
    match equivalence {
        EquivalenceVerdict::Equivalent { checked, total } if checked == total => established.push(
            format!("equivalence: all {total} compared elements proved equivalent"),
        ),
        EquivalenceVerdict::Equivalent { checked, total } => missing.push(format!(
            "equivalence: only {checked} of {total} elements were compared (sampled)"
        )),
        EquivalenceVerdict::Refuted { elements } => rejected.push(format!(
            "equivalence: {} element(s) refuted by a numeric counterexample{}",
            elements.len(),
            first(elements)
        )),
        EquivalenceVerdict::Unproven { elements } => missing.push(format!(
            "equivalence: {} element(s) not proved equivalent and not refuted{}",
            elements.len(),
            first(elements)
        )),
        EquivalenceVerdict::Failed { reason } => {
            missing.push(format!("equivalence: not decided: {reason}"))
        }
        EquivalenceVerdict::IndexSetMismatch {
            array,
            unwritten,
            unexpected,
        } => rejected.push(format!(
            "equivalence: {array} does not have the same set of indices ({} never written{}, \
             {} written outside it{})",
            unwritten.len(),
            first_index(array, unwritten),
            unexpected.len(),
            first_index(array, unexpected)
        )),
    }
    for k in kernels {
        match k.graph.conclusion() {
            GraphConclusion::Verified => {
                established.push(format!("{}: every graph check passed", k.label))
            }
            GraphConclusion::Rejected { failed, deadlock } => {
                if let Some(d) = deadlock {
                    rejected.push(format!(
                        "{}: the trace deadlocked with {} blocked thread(s)",
                        k.label,
                        d.blocked.len()
                    ));
                }
                for s in failed {
                    rejected.push(format!(
                        "{}: {} failed: {}",
                        k.label,
                        s.property.name(),
                        s.findings.first().map_or("", |f| f.text.as_str())
                    ));
                }
            }
            GraphConclusion::Unknown { reasons } => {
                missing.extend(reasons.into_iter().map(|r| format!("{}: {r}", k.label)));
            }
        }
    }
    let mut assumptions: Vec<Assumption> = kernels
        .iter()
        .flat_map(|k| k.assumptions.iter().copied())
        .collect();
    assumptions.sort();
    assumptions.dedup();
    let (verdict, evidence) = if !rejected.is_empty() {
        (Verdict::Reject, rejected)
    } else if !missing.is_empty() {
        (Verdict::Unknown, missing)
    } else {
        (Verdict::Accept, established)
    };
    Decision {
        verdict,
        evidence,
        assumptions,
    }
}

fn first(elements: &[crate::Element]) -> String {
    elements.first().map_or(String::new(), |(array, index)| {
        format!(", first {array}[{index}]")
    })
}

fn first_index(array: &str, indices: &[u64]) -> String {
    indices
        .first()
        .map_or(String::new(), |index| format!(", first {array}[{index}]"))
}
