//! One kernel through the analysis stage and the graph branch.

use std::time::Instant;

use volta_analysis::frontend::ast::Module;
use volta_analysis::{AnalysisConfig, AnalysisError, AnalysisResult, analyze};
use volta_graph::Terminal;
use volta_graph_check::{GraphReport, check_graph};

use crate::logging::info;

/// A kernel's analysis artifacts and its graph branch's report.
pub struct KernelVerification {
    pub analysis: AnalysisResult,
    pub graph: GraphReport,
}

/// Run the analysis stage, then the graph branch's checks over its graph. An `Err` is a
/// failure to analyze at all (no kernel, a lowering error, an invalid configuration).
pub fn verify_kernel(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<KernelVerification, AnalysisError> {
    info!(
        "[analysis] kernel '{}': computing the candidate execution and extracting its event graph",
        kernel.unwrap_or("(first entry)")
    );
    let start = Instant::now();
    let analysis = analyze(module, kernel, config)?;
    info!(
        "[analysis] event graph extracted in {:.3}s: {} events, trace {}",
        start.elapsed().as_secs_f64(),
        analysis.graph.events().len(),
        describe_terminal(analysis.graph.terminal())
    );
    info!("[graph] running the graph checks");
    let start = Instant::now();
    let graph = check_graph(&analysis.graph);
    info!(
        "[graph] checks done in {:.3}s",
        start.elapsed().as_secs_f64()
    );
    Ok(KernelVerification { analysis, graph })
}

fn describe_terminal(terminal: &Terminal) -> String {
    match terminal {
        Terminal::Completed => "completed".to_string(),
        Terminal::Stuck { blocked } => format!("stuck ({} blocked thread(s))", blocked.len()),
        Terminal::Aborted { reason, .. } => format!("aborted: {reason}"),
    }
}
