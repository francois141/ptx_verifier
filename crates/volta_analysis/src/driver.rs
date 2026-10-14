//! The legacy single-kernel entry point: the analysis stage, then the graph-verification
//! branch, its first failure reported as the removed embedded detector reported it (see
//! `legacy`), packaged as the original `Result<AnalysisOutput, AnalysisError>` contract.

use volta_frontend::ast::Module;

use volta_expr::ValueEquality;
use volta_graph_check::{SymbolicFacts, check_graph};

pub use crate::analysis::{AnalysisError, find_kernel, module_vars};
use crate::analysis::{AnalysisParts, analyze};
use crate::eval::{
    AnalysisConfig, AnalysisOutput, EvalError, OutputsUnavailable, RaceVerification,
};
use crate::legacy;

/// Analyze one kernel: lower it, symbolically execute all threads of CTA (0,0,0) under the
/// given configuration, and check every graph property of the execution. A failed property
/// is the error (a data race, an async hazard, a deadlock, ...); otherwise
/// `AnalysisOutput::race_verification` says whether verification is complete.
/// `value_equality` decides benign same-value stores.
pub fn analyze_kernel(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
    value_equality: &dyn ValueEquality,
) -> Result<AnalysisOutput, AnalysisError> {
    let result = analyze(module, kernel, config)?;
    let report = check_graph(
        &result.graph,
        &SymbolicFacts {
            arena: result.arena(),
            value_equality,
        },
    );
    if let Some(e) = legacy::first_failure(&result.graph, &report) {
        return Err(AnalysisError::Eval(e));
    }
    legacy_output(result.into_parts(), legacy::race_verification(&report))
}

/// The first failure of `report` (over `graph`) in the error format `analyze_kernel` returns,
/// for front ends that run the graph branch themselves.
pub fn first_failure(
    graph: &volta_graph::EventGraph,
    report: &volta_graph_check::GraphReport,
) -> Option<EvalError> {
    legacy::first_failure(graph, report)
}

/// The original contract's view of the analysis stage's artifacts, given what graph
/// verification established.
pub fn legacy_output(
    parts: AnalysisParts,
    race_verification: RaceVerification,
) -> Result<AnalysisOutput, AnalysisError> {
    let AnalysisParts {
        outputs,
        stats,
        op_counts,
        ..
    } = parts;
    match outputs {
        Ok(exprs) => Ok(AnalysisOutput {
            exprs,
            stats,
            op_counts,
            race_verification,
        }),
        Err(OutputsUnavailable::Aborted(e) | OutputsUnavailable::Extraction(e)) => {
            Err(AnalysisError::Eval(e))
        }
        Err(OutputsUnavailable::Stuck { blocked }) => {
            Err(AnalysisError::Eval(EvalError::Deadlock { blocked }))
        }
    }
}

/// Write a per-instruction-kind execution profile, most-executed first.
/// The one formatter for `AnalysisOutput::op_counts`, shared by `volta`
/// and `volta-bench` so their profile tables cannot drift.
pub fn write_op_counts(
    out: &mut dyn std::io::Write,
    label: &str,
    counts: &std::collections::BTreeMap<&'static str, u64>,
) -> std::io::Result<()> {
    if counts.is_empty() {
        return Ok(());
    }
    let total: u64 = counts.values().sum();
    let mut entries: Vec<_> = counts.iter().collect();
    entries.sort_by(|a, b| b.1.cmp(a.1).then(a.0.cmp(b.0)));
    writeln!(out, "{} profile:", label)?;
    for (kind, count) in entries {
        let pct = 100.0 * *count as f64 / total as f64;
        writeln!(out, "  {:<16} {:>10}  ({:>5.1}%)", kind, count, pct)?;
    }
    Ok(())
}
