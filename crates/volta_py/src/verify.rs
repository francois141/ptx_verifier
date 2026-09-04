//! Check a PTX kernel against a math spec (`volta verify` in the CLI):
//! parse the spec, instantiate it under caller-supplied `dim` values,
//! unfold it into an `AnalysisOutput` standing in for a second kernel,
//! and run it through the same equivalence pipeline `analyze`'s sibling
//! `compare` command will eventually use.

use std::collections::HashMap;
use std::num::NonZeroUsize;

use pyo3::prelude::*;

use volta_analysis::driver::{
    analyze_kernel, check_output_equivalence_with, EquivCheckOptions, EquivOutcome,
};
use volta_analysis::equiv::DEFAULT_RECYCLE_TERMS;
use volta_analysis::spec::unfold;

use crate::analyze::{parse_module, StatsPy};
use crate::config::ConfigPy;
use crate::error::{analysis_error_to_py, other_error_to_py, spec_parse_error_to_py, VoltaError};

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
}

/// Check `kernel` (in `source`, under `config`) against `spec` (spec
/// language source text - see `volta_spec` for the grammar), given a
/// concrete value for every `dim` the spec declares.
///
/// Every array the spec defines an output equation for must be a
/// declared output array of `config` - checked before symbolic
/// execution. Raises `DataRaceError`/`DeadlockError` for those specific
/// findings, `VoltaError` for any other failure (spec parse/instantiate
/// error, missing dim value, shape mismatch, ...).
#[pyfunction]
#[pyo3(signature = (source, spec, config, kernel=None, dims=None, sample=0, verify_numeric=false))]
#[allow(clippy::too_many_arguments)]
pub fn verify(
    source: &str,
    spec: &str,
    config: &ConfigPy,
    kernel: Option<&str>,
    dims: Option<HashMap<String, u64>>,
    sample: u64,
    verify_numeric: bool,
) -> PyResult<VerifyResultPy> {
    let module = parse_module(source)?;

    let parsed_spec =
        volta_spec::parse_spec(spec).map_err(|e| spec_parse_error_to_py(spec, &e))?;

    let dims = dims.unwrap_or_default();
    let (env, specs) =
        volta_spec::instantiate(&parsed_spec, &dims).map_err(other_error_to_py)?;

    // Every array the spec defines an output equation for, in
    // declaration order - the arrays to check.
    let mut check_arrays: Vec<String> = Vec::new();
    for o in &parsed_spec.outputs {
        if !check_arrays.contains(&o.array) {
            check_arrays.push(o.array.clone());
        }
    }
    if check_arrays.is_empty() {
        return Err(VoltaError::new_err("spec declares no output equations to check"));
    }
    for name in &check_arrays {
        if !config.0.arrays.iter().any(|a| a.kind.is_output() && &a.name == name) {
            return Err(VoltaError::new_err(format!(
                "verify requires a declared output array named '{}' (the spec defines it)",
                name
            )));
        }
    }

    let mut kernel_output =
        analyze_kernel(&module, kernel, config.0.clone()).map_err(analysis_error_to_py)?;

    // A real kernel's written footprint can be far larger than is
    // practical to unroll a Sum-heavy spec over, so `sample` also caps
    // generation: truncate the kernel's own elements to the same
    // ascending-order prefix `unfold` builds, so the two sides still
    // pair up (mirrors `volta_cli`'s `cmd_verify`).
    if sample > 0 {
        for name in &check_arrays {
            if let Some((_, elems)) = kernel_output.outputs.iter_mut().find(|(n, _)| n == name) {
                elems.truncate(sample as usize);
            }
        }
    }

    let spec_output = unfold(&specs, &env, sample).map_err(other_error_to_py)?;

    let options = EquivCheckOptions {
        sample,
        verify_numeric,
        recycle_terms: DEFAULT_RECYCLE_TERMS,
        iterations: NonZeroUsize::MIN,
    };
    let report =
        check_output_equivalence_with(&kernel_output, &spec_output, &check_arrays, &options)
            .map_err(other_error_to_py)?;

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
    })
}
