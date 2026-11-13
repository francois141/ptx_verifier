//! Shared PTX loading and analysis artifacts.

use std::collections::BTreeMap;
use std::path::Path;
use std::process::ExitCode;

use volta_common::file_cache::FileCache;
use volta_common::report::{Report, locate_path, report_error};
use volta_expr::SymbolicOutputs;
use volta_graph::EventGraph;
use volta_graph_check::GraphReport;
use volta_pipeline::{GraphBranch, KernelEvidence, verify_kernel};
use volta_ptx_analysis::frontend::ascii::{AsAscii, AsciiChar};
use volta_ptx_analysis::frontend::ast::Module;
use volta_ptx_analysis::frontend::parse;
use volta_ptx_analysis::{AnalysisConfig, AnalysisParts, OutputsUnavailable, Stats};

/// One kernel after the analysis stage and the graph branch.
pub(crate) struct KernelSide {
    pub(crate) label: &'static str,
    pub(crate) graph: EventGraph,
    pub(crate) report: GraphReport,
}

impl KernelSide {
    pub(crate) fn evidence(&self) -> KernelEvidence<'_> {
        KernelEvidence {
            label: self.label,
            graph: GraphBranch::Checked(&self.report),
            assumptions: &self.graph.provenance().assumptions,
        }
    }
}

/// One kernel's analysis artifacts other than its graph.
pub(crate) struct KernelRun {
    pub(crate) outputs: Result<SymbolicOutputs, OutputsUnavailable>,
    pub(crate) stats: Stats,
    pub(crate) op_counts: BTreeMap<&'static str, u64>,
}

/// Analysis stage plus graph branch for one kernel, split into its owned parts.
pub(crate) fn run_kernel(
    label: &'static str,
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<(KernelRun, KernelSide), String> {
    let verified =
        verify_kernel(module, kernel, config).map_err(|e| format!("{} kernel: {}", label, e))?;
    let AnalysisParts {
        outputs,
        graph,
        stats,
        op_counts,
    } = verified.analysis.into_parts();
    Ok((
        KernelRun {
            outputs,
            stats,
            op_counts,
        },
        KernelSide {
            label,
            graph,
            report: verified.graph,
        },
    ))
}

/// Load and parse a module, reporting errors nicely.
/// The module in `file`, with its source text.
pub(crate) fn load_module(file: &Path) -> Result<(Module, String), ExitCode> {
    let mut files = FileCache::new();
    let contents = match files.read(file) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("error: failed to read {}: {}", file.display(), e);
            return Err(ExitCode::FAILURE);
        }
    };
    let ascii_src: &[AsciiChar] = match contents.as_bytes().as_ascii_slice() {
        Some(src) => src,
        None => {
            eprintln!("error: file contains non-ASCII character");
            return Err(ExitCode::FAILURE);
        }
    };
    let mut parser = parse::Parser::new(ascii_src);
    match parser.parse_module().map_err(locate_path(file)) {
        Ok(module) => Ok((module, contents.to_string())),
        Err(e) => {
            let _ = report_error(
                &mut std::io::stderr(),
                &files,
                Report {
                    path: e.path.as_deref(),
                    span: e.span,
                    title: e.error.title(),
                    message: e.error.message().as_deref(),
                },
            );
            Err(ExitCode::FAILURE)
        }
    }
}
