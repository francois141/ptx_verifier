//! `volta.extract_lean`: graph checks first, then Lean proof obligations.

use std::collections::HashMap;
use std::path::PathBuf;

use pyo3::prelude::*;
use volta_pipeline::LeanExtractionError;

use crate::config::ConfigPy;
use crate::error::{graph_failure_to_py, other_error_to_py};
use crate::solve::{load_kernel, parse_spec, race_verified};

#[pyclass(name = "LeanExtraction")]
pub struct LeanExtractionPy {
    #[pyo3(get)]
    pub isa: String,
    /// True when graph checks passed; None for an ISA without graph checks.
    #[pyo3(get)]
    pub race_verified: Option<bool>,
    /// A Lean module of proof obligations, not completed proofs.
    #[pyo3(get)]
    pub lean: String,
    #[pyo3(get)]
    pub statements: usize,
}

/// Extract Lean proof obligations for a kernel against `spec`. `tolerance` is an optional
/// absolute error bound such as "1/1000"; without it, propositions state exact equality.
/// Raises DataRaceError for detected races, DeadlockError for deadlocks, and VoltaError for
/// other failed or incomplete graph checks or extraction failures. AMD and NKI extraction
/// returns race_verified=None because their interpreters do not record memory events.
#[pyfunction]
#[pyo3(signature = (path, config=None, *, spec, kernel=None, dims=None, tolerance=None))]
pub fn extract_lean(
    path: PathBuf,
    config: Option<&ConfigPy>,
    spec: &str,
    kernel: Option<&str>,
    dims: Option<HashMap<String, u64>>,
    tolerance: Option<&str>,
) -> PyResult<LeanExtractionPy> {
    let spec = parse_spec(spec, dims)?;
    let (isa, run) = load_kernel(&path, config, kernel)?;
    let challenge = run.extract_lean(&spec, tolerance).map_err(|e| match e {
        LeanExtractionError::Rejected { failed, deadlock } => {
            graph_failure_to_py(&failed, deadlock.as_ref())
        }
        other => other_error_to_py(other),
    })?;
    Ok(LeanExtractionPy {
        isa: isa.name().to_string(),
        race_verified: race_verified(&run),
        lean: challenge.module,
        statements: challenge.statements,
    })
}
