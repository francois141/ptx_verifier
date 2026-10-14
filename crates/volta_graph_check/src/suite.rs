//! Every property checker over one graph, in dependency order: each checker receives exactly
//! the certificates of its declared prerequisites ([`Property::prerequisites`]), so the suite
//! adds no reasoning of its own.

use volta_graph::EventGraph;

use crate::async_completion::{CompletionResult, check_async_completion};
use crate::barrier::{BarrierResult, check_barriers};
use crate::lifetime::{LifetimeResult, check_lifetimes};
use crate::pipeline::{PipelineResult, check_pipeline};
use crate::progress::{ProgressResult, check_progress};
use crate::proxy::{ProxyResult, check_proxy};
use crate::race::{RaceInputs, RaceResult, SymbolicFacts, check_races};
use crate::result::{Property, PropertyResult, Unresolved, Verdict};
use crate::scope::{ProofScope, proof_scope};
use crate::well_formed::{WellFormedResult, check_well_formed};

/// Every property's result for one graph, plus the scope its passes would justify.
#[derive(Debug, Clone)]
pub struct GraphReport {
    pub well_formed: WellFormedResult,
    pub barrier: BarrierResult,
    pub async_completion: CompletionResult,
    pub pipeline: PipelineResult,
    pub proxy: ProxyResult,
    pub memory_conflicts: RaceResult,
    pub lifetime: LifetimeResult,
    pub progress: ProgressResult,
    pub scope: ProofScope,
}

/// One property's outcome, without its typed payload.
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
    match u.event {
        Some(e) => format!("event {}: {}", e.0, u.reason),
        None => u.reason.clone(),
    }
}

impl GraphReport {
    pub fn summary(&self, property: Property) -> PropertySummary {
        match property {
            Property::WellFormed => summarize(property, &self.well_formed),
            Property::BarrierProtocol => summarize(property, &self.barrier),
            Property::AsyncCompletion => summarize(property, &self.async_completion),
            Property::PipelineOrder => summarize(property, &self.pipeline),
            Property::ProxyOrder => summarize(property, &self.proxy),
            Property::MemoryConflicts => summarize(property, &self.memory_conflicts),
            Property::ResourceLifetime => summarize(property, &self.lifetime),
            Property::Progress => summarize(property, &self.progress),
        }
    }

    /// Every property's summary, in dependency order.
    pub fn summaries(&self) -> Vec<PropertySummary> {
        Property::ALL.iter().map(|&p| self.summary(p)).collect()
    }

    pub fn verdict(&self, property: Property) -> Verdict {
        self.summary(property).verdict
    }

    /// `Fail` if any property fails, else `Unknown` if any is unknown, else `Pass`. Says
    /// nothing about schedule independence beyond the candidate execution: see `scope`.
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

/// Run every checker on `graph`. `facts` are the read-only symbolic facts the
/// memory-conflict checker's benign-store rule needs.
pub fn check_graph(graph: &EventGraph, facts: &SymbolicFacts) -> GraphReport {
    let well_formed = check_well_formed(graph);
    let (barrier, sync) = check_barriers(graph);
    let (async_completion, completion) = check_async_completion(graph, &sync);
    let (pipeline, pipeline_certificate) = check_pipeline(graph);
    let (proxy, proxy_certificate) = check_proxy(graph, &sync, &completion);
    let memory_conflicts = check_races(
        graph,
        facts,
        &RaceInputs {
            sync: &sync,
            completion: &completion,
            pipeline: &pipeline_certificate,
            proxy: &proxy_certificate,
        },
    );
    let lifetime = check_lifetimes(graph, &sync, &completion);
    let progress = check_progress(graph, &sync, &completion);
    GraphReport {
        well_formed,
        barrier,
        async_completion,
        pipeline,
        proxy,
        memory_conflicts,
        lifetime,
        progress,
        scope: proof_scope(graph),
    }
}
