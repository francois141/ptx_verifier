//! One kernel through the analysis stage and the graph branch.

use volta_analysis::analysis::{AnalysisError, AnalysisResult, analyze};
use volta_analysis::eval::AnalysisConfig;
use volta_expr::ValueEquality;
use volta_frontend::ast::Module;
use volta_graph_check::{GraphReport, SymbolicFacts, check_graph};

/// A kernel's analysis artifacts and its graph branch's report.
pub struct KernelVerification {
    pub analysis: AnalysisResult,
    pub graph: GraphReport,
}

/// Run the analysis stage, then the graph branch over its graph. `value_equality` is the
/// read-only query the memory-conflict checker's benign-store rule asks. An `Err` is a
/// failure to analyze at all (no kernel, a lowering error, an invalid configuration).
pub fn verify_kernel(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
    value_equality: &dyn ValueEquality,
) -> Result<KernelVerification, AnalysisError> {
    let analysis = analyze(module, kernel, config)?;
    let graph = check_graph(
        &analysis.graph,
        &SymbolicFacts {
            arena: analysis.arena(),
            value_equality,
        },
    );
    Ok(KernelVerification { analysis, graph })
}
