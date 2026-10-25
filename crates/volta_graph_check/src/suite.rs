//! The checks over one graph, in [`Property::ALL`]'s order, each receiving exactly the
//! certificates of its prerequisites ([`Property::prerequisites`]); the suite adds no reasoning
//! of its own beyond reading the trace generator's terminal state.
//!
//! The trace generator, not a check, reports a deadlock (`¬Terminal(S) ∧ Enabled(S) = ∅`) or
//! an abort on invalid or unsupported behavior (§1.2): a stuck trace is a diagnostic, an
//! aborted one inconclusive, and the checks still run on the partial graph either way.

use std::time::Instant;

use volta_graph::{BlockedThread, EventGraph, Terminal};

use crate::allocation_order::{AllocationOrderResult, check_allocation_order};
use crate::allocation_permit::{AllocationPermitResult, check_allocation_permit};
use crate::barrier_epoch::{EpochResult, check_mbarrier_epochs, check_named_barrier_epochs};
use crate::logging::info;
use crate::mbarrier_ordering::{MbarrierOrderingResult, check_mbarrier_ordering};
use crate::mbarrier_release_order::{ReleaseOrderResult, check_mbarrier_release_order};
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
    pub mbarrier_ordering: MbarrierOrderingResult,
    pub memory_conflict: MemoryConflictResult,
    pub proxy_order: ProxyOrderResult,
    pub tensor_order: TensorOrderResult,
    pub resource_lifetime: LifetimeResult,
    pub allocation_order: AllocationOrderResult,
    pub allocation_permit: AllocationPermitResult,
    pub mbarrier_release_order: ReleaseOrderResult,
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
            Property::MbarrierOrdering => summarize(property, &self.mbarrier_ordering),
            Property::MemoryConflict => summarize(property, &self.memory_conflict),
            Property::ProxyOrder => summarize(property, &self.proxy_order),
            Property::TensorOrder => summarize(property, &self.tensor_order),
            Property::ResourceLifetime => summarize(property, &self.resource_lifetime),
            Property::AllocationOrder => summarize(property, &self.allocation_order),
            Property::AllocationPermit => summarize(property, &self.allocation_permit),
            Property::MbarrierReleaseOrder => summarize(property, &self.mbarrier_release_order),
        }
    }

    /// Every check's summary, in [`Property::ALL`]'s order.
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

/// One check's progress log: announced when it starts, its verdict and duration when done.
struct CheckLog {
    property: Property,
    start: Instant,
}

impl CheckLog {
    fn start(property: Property) -> Self {
        info!(
            "[graph] check {}/{}: {} ({})",
            Self::position(property),
            Property::ALL.len(),
            property.name(),
            property.algorithm()
        );
        CheckLog {
            property,
            start: Instant::now(),
        }
    }

    fn finish<E, V>(self, result: &PropertyResult<E, V>) {
        info!(
            "[graph] check {}/{}: {} in {:.3}s",
            Self::position(self.property),
            Property::ALL.len(),
            result.verdict().name(),
            self.start.elapsed().as_secs_f64()
        );
    }

    fn position(property: Property) -> usize {
        Property::ALL.iter().position(|&p| p == property).unwrap() + 1
    }
}

/// Run every check on `graph`.
pub fn check_graph(graph: &EventGraph) -> GraphReport {
    let log = CheckLog::start(Property::NamedBarrierEpoch);
    let (named_barrier_epoch, named) = check_named_barrier_epochs(graph);
    log.finish(&named_barrier_epoch);
    let log = CheckLog::start(Property::MbarrierEpoch);
    let (mbarrier_epoch, mbarrier) = check_mbarrier_epochs(graph);
    log.finish(&mbarrier_epoch);
    let log = CheckLog::start(Property::MbarrierOrdering);
    let (mbarrier_ordering, ordering) = check_mbarrier_ordering(graph);
    log.finish(&mbarrier_ordering);
    let validated = named
        .zip(mbarrier)
        .zip(ordering)
        .map(|((named, mbarrier), ordering)| {
            ValidatedGraph::from_certificates(named, mbarrier, ordering)
        });
    let log = CheckLog::start(Property::MemoryConflict);
    let (memory_conflict, conflict_free) = match &validated {
        Some(h) => check_memory_conflicts(h),
        None => (not_run(Property::MemoryConflict), None),
    };
    log.finish(&memory_conflict);
    let log = CheckLog::start(Property::ProxyOrder);
    let proxy_order = match (&validated, &conflict_free) {
        (Some(h), Some(free)) => check_proxy_order(h, free),
        _ => not_run(Property::ProxyOrder),
    };
    log.finish(&proxy_order);
    let log = CheckLog::start(Property::TensorOrder);
    let tensor_order = match &validated {
        Some(d) => check_tensor_order(d),
        None => not_run(Property::TensorOrder),
    };
    log.finish(&tensor_order);
    let log = CheckLog::start(Property::ResourceLifetime);
    let resource_lifetime = match &validated {
        Some(h) => check_resource_lifetimes(h),
        None => not_run(Property::ResourceLifetime),
    };
    log.finish(&resource_lifetime);
    let log = CheckLog::start(Property::AllocationOrder);
    let allocation_order = match &validated {
        Some(h) => check_allocation_order(h),
        None => not_run(Property::AllocationOrder),
    };
    log.finish(&allocation_order);
    let log = CheckLog::start(Property::AllocationPermit);
    let allocation_permit = match &validated {
        Some(h) => check_allocation_permit(h),
        None => not_run(Property::AllocationPermit),
    };
    log.finish(&allocation_permit);
    let log = CheckLog::start(Property::MbarrierReleaseOrder);
    let mbarrier_release_order = check_mbarrier_release_order(graph);
    log.finish(&mbarrier_release_order);
    GraphReport {
        terminal: graph.terminal().clone(),
        named_barrier_epoch,
        mbarrier_epoch,
        mbarrier_ordering,
        memory_conflict,
        proxy_order,
        tensor_order,
        resource_lifetime,
        allocation_order,
        allocation_permit,
        mbarrier_release_order,
    }
}
