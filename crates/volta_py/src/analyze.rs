use std::collections::BTreeMap;

use pyo3::exceptions::PyRuntimeWarning;
use pyo3::prelude::*;

use volta_analysis::eval::{AnalysisConfig, Stats};
use volta_equivalence::CanonValueEquality;
use volta_expr::SymbolicOutputs;
use volta_frontend::ascii::{AsAscii, AsciiChar};
use volta_frontend::ast::Module;
use volta_frontend::parse as ptx_parse;
use volta_graph_check::GraphConclusion;
use volta_pipeline::verify_kernel;

use crate::config::ConfigPy;
use crate::error::{VoltaError, analysis_error_to_py, graph_failure_to_py, parse_error_to_py};

pub(crate) fn parse_module(source: &str) -> PyResult<Module> {
    let ascii_src: &[AsciiChar] = source
        .as_bytes()
        .as_ascii_slice()
        .ok_or_else(|| VoltaError::new_err("source contains non-ASCII characters"))?;
    let mut parser = ptx_parse::Parser::new(ascii_src);
    parser
        .parse_module()
        .map_err(|e| parse_error_to_py(source, &e))
}

/// Parse PTX source and raise `VoltaError` on a syntax error.
#[pyfunction]
pub fn parse(source: &str) -> PyResult<()> {
    parse_module(source)?;
    Ok(())
}

#[pyclass(name = "Stats", from_py_object)]
#[derive(Clone)]
pub struct StatsPy {
    #[pyo3(get)]
    pub instructions: u64,
    #[pyo3(get)]
    pub block_syncs: u64,
    #[pyo3(get)]
    pub warp_syncs: u64,
}

/// The result of symbolically executing one kernel: per-output-array written
/// elements (pretty-printed; the arena is not exposed) plus statistics.
#[pyclass(name = "AnalyzeResult")]
pub struct AnalyzeResultPy {
    #[pyo3(get)]
    pub stats: StatsPy,
    /// `[(array_name, [(index, pretty_printed_expr), ...]), ...]`
    #[pyo3(get)]
    pub outputs: Vec<(String, Vec<(u64, String)>)>,
    #[pyo3(get)]
    pub op_counts: BTreeMap<String, u64>,
    /// Whether graph verification is complete: every property (data races, async hazards,
    /// synchronization protocol, resource lifetime, progress) passed in a
    /// schedule-independent scope. A failed property raises instead.
    #[pyo3(get)]
    pub race_verified: bool,
    /// Why verification is incomplete; empty when `race_verified`.
    #[pyo3(get)]
    pub unresolved: Vec<String>,
}

/// One kernel that ran to completion with no failed graph property.
pub(crate) struct CheckedKernel {
    pub exprs: SymbolicOutputs,
    pub stats: Stats,
    pub op_counts: BTreeMap<&'static str, u64>,
    /// Why graph verification is incomplete; empty when it is verified.
    pub unresolved: Vec<String>,
}

/// Run the analysis stage and the graph branch. A failed graph property raises (see
/// `graph_failure_to_py`), before an execution that produced no outputs raises `VoltaError`;
/// incomplete verification emits a `RuntimeWarning`, so a returned result never silently
/// stands for a race-freedom proof.
pub(crate) fn check_kernel(
    py: Python<'_>,
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> PyResult<CheckedKernel> {
    let verified =
        verify_kernel(module, kernel, config, &CanonValueEquality).map_err(analysis_error_to_py)?;
    let unresolved = match verified.graph.conclusion() {
        GraphConclusion::Rejected { failed } => return Err(graph_failure_to_py(&failed)),
        GraphConclusion::Verified => Vec::new(),
        GraphConclusion::Unknown { reasons } => {
            let message = format!(
                "graph verification is UNKNOWN, race freedom is not established: {}",
                reasons.join("; ")
            );
            let message = std::ffi::CString::new(message.replace('\0', " "))
                .expect("NUL bytes were replaced");
            PyErr::warn(py, &py.get_type::<PyRuntimeWarning>(), &message, 1)?;
            reasons
        }
    };
    let parts = verified.analysis.into_parts();
    let exprs = parts
        .outputs
        .map_err(|why| VoltaError::new_err(why.to_string()))?;
    Ok(CheckedKernel {
        exprs,
        stats: parts.stats,
        op_counts: parts.op_counts,
        unresolved,
    })
}

/// Symbolically execute `kernel` (or the module's unique entry) under
/// `config`. Raises `DataRaceError` / `DeadlockError` for those findings and
/// `VoltaError` for any other analysis failure.
#[pyfunction]
#[pyo3(signature = (source, config, kernel=None))]
pub fn analyze(
    py: Python<'_>,
    source: &str,
    config: &ConfigPy,
    kernel: Option<&str>,
) -> PyResult<AnalyzeResultPy> {
    let module = parse_module(source)?;
    let output = check_kernel(py, &module, kernel, config.0.clone())?;

    let outputs = output
        .exprs
        .outputs
        .iter()
        .map(|(name, elems)| {
            let elems = elems
                .iter()
                .map(|(index, expr)| (*index, output.exprs.arena.display_expr(*expr)))
                .collect();
            (name.clone(), elems)
        })
        .collect();

    Ok(AnalyzeResultPy {
        stats: StatsPy {
            instructions: output.stats.instructions,
            block_syncs: output.stats.block_syncs,
            warp_syncs: output.stats.warp_syncs,
        },
        outputs,
        op_counts: output
            .op_counts
            .iter()
            .map(|(k, v)| (k.to_string(), *v))
            .collect(),
        race_verified: output.unresolved.is_empty(),
        unresolved: output.unresolved,
    })
}
