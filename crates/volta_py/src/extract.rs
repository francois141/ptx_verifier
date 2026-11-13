//! `volta.extract_lean`: graph checks first, then (optionally) the canonical equivalence
//! check against the spec, then Lean proof obligations, all over one run of the kernel.

use std::collections::HashMap;
use std::path::PathBuf;

use pyo3::prelude::*;
use volta_equivalence::EquivCheckOptions;
use volta_pipeline::{
    DEFAULT_LEAN_NAMESPACE, Isa, KernelRun, LeanProver, LeanSolution, Solution, SolveError, Solver,
    Spec, claim,
};

use crate::config::ConfigPy;
use crate::error::{VoltaError, graph_failure_to_py, other_error_to_py};
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
/// VoltaError for other failed or incomplete graph checks or extraction failures. NKI
/// extraction returns race_verified=None because its interpreter records no memory events.
#[pyfunction]
#[pyo3(signature = (
    path, config=None, *, spec, kernel=None, dims=None, tolerance=None, equivalence=false
))]
#[allow(clippy::too_many_arguments)]
pub fn extract_lean(
    py: Python<'_>,
    path: PathBuf,
    config: Option<&ConfigPy>,
    spec: &str,
    kernel: Option<&str>,
    dims: Option<HashMap<String, u64>>,
    tolerance: Option<&str>,
    equivalence: bool,
) -> PyResult<LeanExtractionPy> {
    let mut lean = LeanRun::new(path, config, spec, kernel, dims, equivalence)?;
    let LeanSolution::Stated(challenge) = lean.solve(py, tolerance, None)? else {
        unreachable!("the Lean solver proves nothing without a prover")
    };
    Ok(LeanExtractionPy {
        isa: lean.isa.name().to_string(),
        race_verified: race_verified(&lean.run),
        verdict: lean.verdict,
        evidence: lean.evidence,
        lean: challenge.module,
        statements: challenge.statements,
    })
}

/// One run of a kernel against a spec, and the canonical solver's verdict on it when asked for:
/// what `extract_lean` and `prove_lean` hand to the Lean solver.
pub(crate) struct LeanRun {
    pub isa: Isa,
    pub run: KernelRun,
    spec: Spec,
    /// `"ACCEPT"`, `"REJECT"` or `"UNKNOWN"` for exact equality, when `equivalence` asked for it.
    pub verdict: Option<String>,
    pub evidence: Vec<String>,
}

impl LeanRun {
    pub(crate) fn new(
        path: PathBuf,
        config: Option<&ConfigPy>,
        spec: &str,
        kernel: Option<&str>,
        dims: Option<HashMap<String, u64>>,
        equivalence: bool,
    ) -> PyResult<LeanRun> {
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
        Ok(LeanRun {
            isa,
            run,
            spec,
            verdict,
            evidence,
        })
    }

    /// The Lean solver's statements of the run, proved by `prover` when given; with the GIL
    /// released, so the Rust logs forwarded to Python's `logging` reach it meanwhile.
    pub(crate) fn solve(
        &mut self,
        py: Python<'_>,
        tolerance: Option<&str>,
        prover: Option<LeanProver>,
    ) -> PyResult<LeanSolution> {
        let solver = Solver::Lean {
            claim: claim(tolerance).map_err(VoltaError::new_err)?,
            namespace: DEFAULT_LEAN_NAMESPACE.to_string(),
            prover,
        };
        let (run, spec) = (&mut self.run, &self.spec);
        match py.detach(|| run.solve(spec, &solver)) {
            Ok(Solution::Lean(LeanSolution::Stopped(verdict))) => {
                let decision = self
                    .run
                    .decide(&Solution::Lean(LeanSolution::Stopped(verdict)));
                Err(VoltaError::new_err(format!(
                    "Lean extraction failed: {}",
                    decision.evidence.join("; ")
                )))
            }
            Ok(Solution::Lean(solution)) => Ok(solution),
            Ok(Solution::Canonical { .. }) => unreachable!("the Lean solver gives Lean solutions"),
            Err(SolveError::Rejected { failed, deadlock }) => {
                Err(graph_failure_to_py(&failed, deadlock.as_ref()))
            }
            Err(e) => Err(other_error_to_py(format!("Lean extraction failed: {e}"))),
        }
    }
}
