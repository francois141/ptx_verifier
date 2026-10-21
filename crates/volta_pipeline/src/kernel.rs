//! One kernel through the analysis stage and the graph branch.

use volta_analysis::{AnalysisConfig, AnalysisError, AnalysisResult, analyze};
use volta_frontend::ast::Module;
use volta_graph_check::{GraphReport, check_graph};

/// A kernel's analysis artifacts and its graph branch's report.
pub struct KernelVerification {
    pub analysis: AnalysisResult,
    pub graph: GraphReport,
}

/// Run the analysis stage, then the graph branch's six checks over its graph. An `Err` is a
/// failure to analyze at all (no kernel, a lowering error, an invalid configuration).
pub fn verify_kernel(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<KernelVerification, AnalysisError> {
    let analysis = analyze(module, kernel, config)?;
    let graph = check_graph(&analysis.graph);
    Ok(KernelVerification { analysis, graph })
}
