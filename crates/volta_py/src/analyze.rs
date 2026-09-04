use std::collections::BTreeMap;

use pyo3::prelude::*;

use volta_analysis::driver;
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

/// The result of symbolically executing one kernel: per-output-array
/// written elements (pretty-printed, since the underlying `ExprId`s are
/// only meaningful against an arena this binding does not expose in v0)
/// plus execution statistics.
#[pyclass(name = "AnalyzeResult")]
pub struct AnalyzeResultPy {
    #[pyo3(get)]
    pub stats: StatsPy,
    /// `[(array_name, [(index, pretty_printed_expr), ...]), ...]`
    #[pyo3(get)]
    pub outputs: Vec<(String, Vec<(u64, String)>)>,
    #[pyo3(get)]
    pub op_counts: BTreeMap<String, u64>,
}

/// Symbolically execute `kernel` (or the module's unique entry, if a
/// module has just one) under `config`, and return its output
/// expressions and execution statistics.
///
/// Raises `DataRaceError` / `DeadlockError` for those specific findings,
/// and `VoltaError` for any other analysis failure (kernel not found,
/// out-of-bounds access, ...).
#[pyfunction]
#[pyo3(signature = (source, config, kernel=None))]
pub fn analyze(source: &str, config: &ConfigPy, kernel: Option<&str>) -> PyResult<AnalyzeResultPy> {
    let module = parse_module(source)?;
    let output =
        driver::analyze_kernel(&module, kernel, config.0.clone()).map_err(analysis_error_to_py)?;

    let outputs = output
        .outputs
        .iter()
        .map(|(name, elems)| {
            let elems = elems
                .iter()
                .map(|(index, expr)| (*index, output.arena.display_expr(*expr)))
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
    })
}
