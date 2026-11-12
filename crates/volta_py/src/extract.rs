//! `volta.extract_lean`: graph checks first, then (optionally) the canonical equivalence
//! check against the spec, then Lean proof obligations, all over one run of the kernel.

use std::collections::HashMap;
use std::path::PathBuf;

use pyo3::prelude::*;
use volta_equivalence::EquivCheckOptions;
use volta_pipeline::{LeanExtractionError, Solver};

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
    /// The canonical solver's `"ACCEPT"`, `"REJECT"` or `"UNKNOWN"` for exact equality with the
    /// spec; None unless `equivalence=True` asked for it.
    #[pyo3(get)]
    pub verdict: Option<String>,
    /// What that verdict rests on, its witnesses or what is missing.
    #[pyo3(get)]
    pub evidence: Vec<String>,
    /// A Lean module of proof obligations, not completed proofs.
    #[pyo3(get)]
    pub lean: String,
    #[pyo3(get)]
    pub statements: usize,
}

/// Extract Lean proof obligations for a kernel against `spec`. `tolerance` is an optional
/// absolute error bound such as "1/1000"; without it, propositions state exact equality.
/// `equivalence=True` first checks exact equality with the canonical solver, as `solve` does,
/// on the same run. Raises DataRaceError for detected races, DeadlockError for deadlocks, and
/// VoltaError for other failed or incomplete graph checks or extraction failures. A kernel
/// whose run records no graph returns race_verified=None.
#[pyfunction]
#[pyo3(signature = (
    path, config=None, *, spec, kernel=None, dims=None, tolerance=None, equivalence=false
))]
#[allow(clippy::too_many_arguments)]
pub fn extract_lean(
    path: PathBuf,
    config: Option<&ConfigPy>,
    spec: &str,
    kernel: Option<&str>,
    dims: Option<HashMap<String, u64>>,
    tolerance: Option<&str>,
    equivalence: bool,
) -> PyResult<LeanExtractionPy> {
    let spec = parse_spec(spec, dims)?;
    let (isa, mut run) = load_kernel(&path, config, kernel)?;
    let (verdict, evidence) = if equivalence {
        let solver = Solver::Canonical(EquivCheckOptions::default());
        let solution = run.solve(&spec, &solver).map_err(other_error_to_py)?;
        let decision = run.decide(&solution);
        (Some(decision.verdict.name().to_string()), decision.evidence)
    } else {
        (None, Vec::new())
    };
    let challenge = run.extract_lean(&spec, tolerance).map_err(|e| match e {
        LeanExtractionError::Rejected { failed, deadlock } => {
            graph_failure_to_py(&failed, deadlock.as_ref())
        }
        other => other_error_to_py(other),
    })?;
    Ok(LeanExtractionPy {
        isa: isa.name().to_string(),
        race_verified: race_verified(&run),
        verdict,
        evidence,
        lean: challenge.module,
        statements: challenge.statements,
    })
}
