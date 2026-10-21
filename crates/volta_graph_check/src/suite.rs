//! The six checks over one graph, in the design's order, each receiving exactly the
//! certificates of its prerequisites ([`Property::prerequisites`]); the suite adds no reasoning
//! of its own beyond reading the trace generator's terminal state.
//!
//! The trace generator, not a check, reports a deadlock (`¬Terminal(S) ∧ Enabled(S) = ∅`) or
//! an abort on invalid or unsupported behavior (§1.2): a stuck trace is a diagnostic, an
//! aborted one inconclusive, and the checks still run on the partial graph either way.

use volta_graph::{BlockedThread, EventGraph, Terminal};

use crate::barrier_epoch::{EpochResult, check_mbarrier_epochs, check_named_barrier_epochs};
use crate::memory_conflict::{MemoryConflictResult, check_memory_conflicts};
use crate::proxy_order::{ProxyOrderResult, check_proxy_order};
use crate::relation::ValidatedGraph;
use crate::resource_lifetime::{LifetimeResult, check_resource_lifetimes};
use crate::result::{Property, PropertyResult, Unresolved, Verdict};
use crate::tensor_order::{TensorOrderResult, check_tensor_order};

/// Every check's result for one graph, and how the trace ended.
#[derive(Debug, Clone)]
pub struct GraphReport {
    pub terminal: Terminal,
    pub named_barrier_epoch: EpochResult,
    pub mbarrier_epoch: EpochResult,
    pub memory_conflict: MemoryConflictResult,
    pub proxy_order: ProxyOrderResult,
    pub tensor_order: TensorOrderResult,
    pub resource_lifetime: LifetimeResult,
}

/// The trace generator's deadlock: no thread can proceed.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Deadlock {
    pub blocked: Vec<BlockedThread>,
}

/// The graph branch's conclusion for one kernel.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GraphConclusion {
    /// The trace completed and every check passed.
    Verified,
    /// Some check failed (those checks, with their witnesses), or the trace deadlocked.
    Rejected {
        failed: Vec<PropertySummary>,
        deadlock: Option<Deadlock>,
    },
    /// Nothing failed, but these obligations are unresolved or the trace was aborted.
    Unknown { reasons: Vec<String> },
}

/// One check's outcome, without its typed payload.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PropertySummary {
    pub property: Property,
    pub verdict: Verdict,
    /// The violations (`Fail`) or unresolved obligations (`Unknown`), rendered; empty on
    /// `Pass`.
    pub findings: Vec<String>,
    /// The `Pass` evidence, rendered.
    pub evidence: Option<String>,
}

fn summarize<E: std::fmt::Debug, V: std::fmt::Debug>(
    property: Property,
    result: &PropertyResult<E, V>,
) -> PropertySummary {
    let (evidence, findings) = match result {
        PropertyResult::Pass(e) => (Some(format!("{e:?}")), Vec::new()),
        PropertyResult::Fail(v) => (None, v.iter().map(|v| format!("{v:?}")).collect()),
        PropertyResult::Unknown(u) => (None, u.iter().map(render_unresolved).collect()),
    };
    PropertySummary {
        property,
        verdict: result.verdict(),
        findings,
        evidence,
    }
}

fn render_unresolved(u: &Unresolved) -> String {
    match u.events.as_slice() {
        [] => u.reason.clone(),
        [e] => format!("event {}: {}", e.0, u.reason),
        events => {
            let events: Vec<String> = events.iter().map(|e| e.0.to_string()).collect();
            format!("events {}: {}", events.join(", "), u.reason)
        }
    }
}

impl GraphReport {
    pub fn summary(&self, property: Property) -> PropertySummary {
        match property {
            Property::NamedBarrierEpoch => summarize(property, &self.named_barrier_epoch),
            Property::MbarrierEpoch => summarize(property, &self.mbarrier_epoch),
            Property::MemoryConflict => summarize(property, &self.memory_conflict),
            Property::ProxyOrder => summarize(property, &self.proxy_order),
            Property::TensorOrder => summarize(property, &self.tensor_order),
            Property::ResourceLifetime => summarize(property, &self.resource_lifetime),
        }
    }

    /// Every check's summary, in the design's order.
    pub fn summaries(&self) -> Vec<PropertySummary> {
        Property::ALL.iter().map(|&p| self.summary(p)).collect()
    }

    pub fn verdict(&self, property: Property) -> Verdict {
        self.summary(property).verdict
    }

    /// The trace generator's deadlock, if the trace is stuck with blocked threads.
    pub fn deadlock(&self) -> Option<Deadlock> {
        match &self.terminal {
            Terminal::Stuck { blocked } if !blocked.is_empty() => Some(Deadlock {
                blocked: blocked.clone(),
            }),
            _ => None,
        }
    }

    pub fn conclusion(&self) -> GraphConclusion {
        let summaries = self.summaries();
        let failed: Vec<PropertySummary> = summaries
            .iter()
            .filter(|s| s.verdict == Verdict::Fail)
            .cloned()
            .collect();
        let deadlock = self.deadlock();
        if !failed.is_empty() || deadlock.is_some() {
            return GraphConclusion::Rejected { failed, deadlock };
        }
        let mut reasons = Vec::new();
        match &self.terminal {
            Terminal::Completed => {}
            Terminal::Stuck { .. } => {
                reasons.push("the trace is stuck without a blocked thread".to_string())
            }
            Terminal::Aborted { reason, .. } => reasons.push(format!(
                "the trace generator aborted, so the graph is only a prefix: {reason}"
            )),
        }
        reasons.extend(
            summaries
                .iter()
                .filter(|s| s.verdict == Verdict::Unknown)
                .map(|s| match s.findings.len() {
                    0 => format!("{}: unknown", s.property.name()),
                    1 => format!("{}: {}", s.property.name(), s.findings[0]),
                    n => format!(
                        "{}: {} (and {} more)",
                        s.property.name(),
                        s.findings[0],
                        n - 1
                    ),
                }),
        );
        if reasons.is_empty() {
            GraphConclusion::Verified
        } else {
            GraphConclusion::Unknown { reasons }
        }
    }

    /// `Fail` if any check fails, else `Unknown` if any is unknown, else `Pass`. Says nothing
    /// about the trace's end: see `conclusion`.
    pub fn verdict_overall(&self) -> Verdict {
        let verdicts: Vec<Verdict> = Property::ALL.iter().map(|&p| self.verdict(p)).collect();
        if verdicts.contains(&Verdict::Fail) {
            Verdict::Fail
        } else if verdicts.contains(&Verdict::Unknown) {
            Verdict::Unknown
        } else {
            Verdict::Pass
        }
    }
}

/// A check whose prerequisites did not all pass.
fn not_run<E, V>(property: Property) -> PropertyResult<E, V> {
    let missing: Vec<&str> = property.prerequisites().iter().map(|p| p.name()).collect();
    PropertyResult::Unknown(vec![Unresolved::global(format!(
        "not checked: its prerequisites ({}) did not all pass",
        missing.join(", ")
    ))])
}

/// Run the six checks on `graph`.
pub fn check_graph(graph: &EventGraph) -> GraphReport {
    let (named_barrier_epoch, named) = check_named_barrier_epochs(graph);
    let (mbarrier_epoch, mbarrier) = check_mbarrier_epochs(graph);
    let validated = named
        .zip(mbarrier)
        .map(|(named, mbarrier)| ValidatedGraph::from_epochs(named, mbarrier));
    let (memory_conflict, conflict_free) = match &validated {
        Some(h) => check_memory_conflicts(h),
        None => (not_run(Property::MemoryConflict), None),
    };
    let proxy_order = match (&validated, &conflict_free) {
        (Some(h), Some(free)) => check_proxy_order(h, free),
        _ => not_run(Property::ProxyOrder),
    };
    let tensor_order = match &validated {
        Some(d) => check_tensor_order(d),
        None => not_run(Property::TensorOrder),
    };
    let resource_lifetime = match &validated {
        Some(h) => check_resource_lifetimes(h),
        None => not_run(Property::ResourceLifetime),
    };
    GraphReport {
        terminal: graph.terminal().clone(),
        named_barrier_epoch,
        mbarrier_epoch,
        memory_conflict,
        proxy_order,
        tensor_order,
        resource_lifetime,
    }
}
