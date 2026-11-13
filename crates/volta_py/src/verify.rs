//! Check a PTX kernel against a math spec (`volta verify`): instantiate the
//! spec under caller-supplied `dim` values, unfold it into `SymbolicOutputs`
//! standing in for a second kernel, then run the usual equivalence pipeline.

use std::collections::HashMap;

use pyo3::prelude::*;

use volta_equivalence::{EquivCheckOptions, EquivOutcome};
use volta_pipeline::{EquivalenceVerdict, Spec, check_against_spec};

use crate::analyze::{StatsPy, check_kernel, parse_module};
use crate::config::ConfigPy;
use crate::error::{VoltaError, other_error_to_py, spec_parse_error_to_py};

#[pyclass(name = "VerifyResult")]
pub struct VerifyResultPy {
    #[pyo3(get)]
    pub equivalent: bool,
    /// `(array, index)` pairs where the kernel disagrees with the spec;
    /// empty when `equivalent` is true.
    #[pyo3(get)]
    pub mismatches: Vec<(String, u64)>,
    #[pyo3(get)]
    pub elements_checked: u64,
    #[pyo3(get)]
    pub elements_total: u64,
    /// The kernel's own execution statistics (the spec has none to report).
    #[pyo3(get)]
    pub stats: StatsPy,
    /// Whether the kernel's graph verification is complete (see `AnalyzeResult`).
    #[pyo3(get)]
    pub race_verified: bool,
}

/// Check `kernel` against `spec` (grammar in `volta_spec`) given every `dim`.
/// Spec output arrays must be declared outputs of `config`. Raises
/// `DataRaceError`/`DeadlockError` for those findings, else `VoltaError`.
#[pyfunction]
#[pyo3(signature = (source, spec, config, kernel=None, dims=None, sample=0, verify_numeric=false))]
#[allow(clippy::too_many_arguments)]
pub fn verify(
    py: Python<'_>,
    source: &str,
    spec: &str,
    config: &ConfigPy,
    kernel: Option<&str>,
    dims: Option<HashMap<String, u64>>,
    sample: u64,
    verify_numeric: bool,
) -> PyResult<VerifyResultPy> {
    let module = parse_module(source)?;

    let parsed_spec = volta_spec::parse_spec(spec).map_err(|e| spec_parse_error_to_py(spec, &e))?;

    let dims = dims.unwrap_or_default();
    let prepared_spec = Spec::new(&parsed_spec, &dims).map_err(other_error_to_py)?;
    for name in prepared_spec.arrays() {
        if !config
            .0
            .arrays
            .iter()
            .any(|a| a.kind.is_output() && &a.name == name)
        {
            return Err(VoltaError::new_err(format!(
                "verify requires a declared output array named '{}' (the spec defines it)",
                name
            )));
        }
    }

    let mut kernel_output = check_kernel(py, &module, kernel, config.0.clone())?;
    let race_verified = kernel_output.unresolved.is_empty();

    let options = EquivCheckOptions {
        sample,
        verify_numeric,
        ..EquivCheckOptions::default()
    };
    let (verdict, report) = check_against_spec(&mut kernel_output.exprs, &prepared_spec, &options)
        .map_err(other_error_to_py)?;
    let report = match (verdict, report) {
        (_, Some(report)) => report,
        (EquivalenceVerdict::Failed { reason }, None) => {
            return Err(VoltaError::new_err(reason));
        }
        (
            EquivalenceVerdict::IndexSetMismatch {
                array,
                unwritten,
                unexpected,
            },
            None,
        ) => {
            return Err(VoltaError::new_err(format!(
                "output shape mismatch: array '{array}': unwritten indices {unwritten:?}, unexpected indices {unexpected:?}"
            )));
        }
        (verdict, None) => {
            return Err(VoltaError::new_err(format!(
                "verification produced no report: {verdict:?}"
            )));
        }
    };

    let (equivalent, mismatches) = match report.outcome {
        EquivOutcome::Equivalent => (true, Vec::new()),
        EquivOutcome::NotEquivalent { mismatches } => (
            false,
            mismatches.into_iter().map(|m| (m.array, m.index)).collect(),
        ),
    };

    Ok(VerifyResultPy {
        equivalent,
        mismatches,
        elements_checked: report.elements_checked,
        elements_total: report.elements_total,
        stats: StatsPy {
            instructions: kernel_output.stats.instructions,
            block_syncs: kernel_output.stats.block_syncs,
            warp_syncs: kernel_output.stats.warp_syncs,
        },
        race_verified,
    })
}
