use std::collections::BTreeMap;

use pyo3::exceptions::PyRuntimeWarning;
use pyo3::prelude::*;

use volta_analysis::driver;
use volta_analysis::eval::{AnalysisOutput, RaceVerification};
use volta_equivalence::CanonValueEquality;
use volta_frontend::ascii::{AsAscii, AsciiChar};
use volta_frontend::ast::Module;
use volta_frontend::parse as ptx_parse;

use crate::config::ConfigPy;
use crate::error::{VoltaError, analysis_error_to_py, parse_error_to_py};

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
    /// Whether data races and async-operation hazards were checked.
    #[pyo3(get)]
    pub race_verified: bool,
}

/// Emit a `RuntimeWarning` when `output` carries no race-freedom guarantee, so
/// a returned result never silently stands for a race check.
pub(crate) fn warn_unverified(py: Python<'_>, output: &AnalysisOutput) -> PyResult<bool> {
    match output.race_verification {
        RaceVerification::Unavailable => {
            PyErr::warn(
                py,
                &py.get_type::<PyRuntimeWarning>(),
                c"data-race and async-hazard verification is unavailable: race freedom was NOT checked",
                1,
            )?;
            Ok(false)
        }
    }
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
    let output = driver::analyze_kernel(&module, kernel, config.0.clone(), &CanonValueEquality)
        .map_err(analysis_error_to_py)?;
    let race_verified = warn_unverified(py, &output)?;

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
        race_verified,
    })
}
