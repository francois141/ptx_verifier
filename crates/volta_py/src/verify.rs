//! Check a PTX kernel against a math spec (`volta verify`): instantiate the
//! spec under caller-supplied `dim` values, unfold it into an `AnalysisOutput`
//! standing in for a second kernel, then run the usual equivalence pipeline.

use std::collections::HashMap;
use std::num::NonZeroUsize;

use pyo3::prelude::*;

use volta_analysis::driver::analyze_kernel;
use volta_equivalence::equiv::DEFAULT_RECYCLE_TERMS;
use volta_equivalence::{
    CanonValueEquality, EquivCheckOptions, EquivOutcome, check_output_equivalence_with,
};
use volta_expr::spec::unfold;

use crate::analyze::{StatsPy, parse_module};
use crate::config::ConfigPy;
use crate::error::{VoltaError, analysis_error_to_py, other_error_to_py, spec_parse_error_to_py};

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

/// Check `kernel` against `spec` (grammar in `volta_spec`) given every `dim`.
/// Spec output arrays must be declared outputs of `config`. Raises
/// `DataRaceError`/`DeadlockError` for those findings, else `VoltaError`.
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

    let parsed_spec = volta_spec::parse_spec(spec).map_err(|e| spec_parse_error_to_py(spec, &e))?;

    let dims = dims.unwrap_or_default();
    let (env, specs) = volta_spec::instantiate(&parsed_spec, &dims).map_err(other_error_to_py)?;

    // Every array the spec defines an output equation for, in
    // declaration order - the arrays to check.
    let mut check_arrays: Vec<String> = Vec::new();
    for o in &parsed_spec.outputs {
        if !check_arrays.contains(&o.array) {
            check_arrays.push(o.array.clone());
        }
    }
    if check_arrays.is_empty() {
        return Err(VoltaError::new_err(
            "spec declares no output equations to check",
        ));
    }
    for name in &check_arrays {
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

    let mut kernel_output = analyze_kernel(&module, kernel, config.0.clone(), &CanonValueEquality)
        .map_err(analysis_error_to_py)?;

    // `sample` also caps generation: truncate the kernel's elements to the
    // ascending prefix `unfold` builds, so both sides pair (as in `cmd_verify`).
    if sample > 0 {
        for name in &check_arrays {
            if let Some((_, elems)) = kernel_output
                .exprs
                .outputs
                .iter_mut()
                .find(|(n, _)| n == name)
            {
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
        check_output_equivalence_with(&kernel_output.exprs, &spec_output, &check_arrays, &options)
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
