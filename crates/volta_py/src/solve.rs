//! `volta.solve` (`volta solve`): a kernel file through the interpreter its extension names
//! (`.ptx`, `.s`, `.py`) and, given a spec, its outputs checked by the canonical solver.
//! Verdicts are returned, not raised. Lean extraction uses `volta.extract_lean`.

use std::collections::HashMap;
use std::path::{Path, PathBuf};

use pyo3::prelude::*;

use volta_equivalence::EquivCheckOptions;
use volta_graph_check::GraphConclusion;
use volta_pipeline::{GraphEvidence, Isa, KernelRun, Solver, Spec};
use volta_ptx_analysis::AnalysisConfig;

use crate::config::ConfigPy;
use crate::error::{VoltaError, frontend_error_to_py, other_error_to_py, spec_parse_error_to_py};

#[pyclass(name = "SolveResult")]
pub struct SolveResultPy {
    /// The interpreter the file's extension chose: `"NVIDIA PTX"`, `"AMD gfx950"` or
    /// `"AWS Trainium NKI"`.
    #[pyo3(get)]
    pub isa: String,
    /// `[(array_name, [(index, pretty_printed_expr), ...]), ...]`; empty when the run wrote none.
    #[pyo3(get)]
    pub outputs: Vec<(String, Vec<(u64, String)>)>,
    /// Whether every graph check passed on a completed trace; `None` when the ISA's
    /// interpreter records no memory events, so race freedom is not checked.
    #[pyo3(get)]
    pub race_verified: Option<bool>,
    /// `"ACCEPT"`, `"REJECT"` or `"UNKNOWN"` against the spec; `None` without a spec.
    #[pyo3(get)]
    pub verdict: Option<String>,
    /// What the verdict rests on (ACCEPT), its witnesses (REJECT) or what is missing (UNKNOWN).
    #[pyo3(get)]
    pub evidence: Vec<String>,
}

/// Run the kernel in `path` (its ISA chosen by extension) under `config` (none for NKI) and,
/// with a `spec`, check its outputs with the canonical solver. Use `extract_lean` to
/// generate Lean proof obligations. Raises `VoltaError` when the kernel cannot run at all.
#[pyfunction]
#[pyo3(signature = (
    path, config=None, kernel=None, spec=None, dims=None, sample=0,
    verify_numeric=false
))]
#[allow(clippy::too_many_arguments)]
pub fn solve(
    path: PathBuf,
    config: Option<&ConfigPy>,
    kernel: Option<&str>,
    spec: Option<&str>,
    dims: Option<HashMap<String, u64>>,
    sample: u64,
    verify_numeric: bool,
) -> PyResult<SolveResultPy> {
    let solver = Solver::Canonical(EquivCheckOptions {
        sample,
        verify_numeric,
        ..EquivCheckOptions::default()
    });
    let spec = spec.map(|text| parse_spec(text, dims)).transpose()?;
    let (isa, mut run) = load_kernel(&path, config, kernel)?;

    let outputs = match &run.outputs {
        Ok(exprs) => exprs
            .outputs
            .iter()
            .map(|(name, elems)| {
                let elems = elems
                    .iter()
                    .map(|(index, expr)| (*index, exprs.arena.display_expr(*expr)))
                    .collect();
                (name.clone(), elems)
            })
            .collect(),
        Err(why) if spec.is_none() => return Err(VoltaError::new_err(why.clone())),
        Err(_) => Vec::new(),
    };
    let race_verified = race_verified(&run);

    let (verdict, evidence) = match &spec {
        None => (None, Vec::new()),
        Some(spec) => {
            let solution = run.solve(spec, &solver).map_err(other_error_to_py)?;
            let decision = run.decide(&solution);
            (Some(decision.verdict.name().to_string()), decision.evidence)
        }
    };

    Ok(SolveResultPy {
        isa: isa.name().to_string(),
        outputs,
        race_verified,
        verdict,
        evidence,
    })
}

pub(crate) fn parse_spec(text: &str, dims: Option<HashMap<String, u64>>) -> PyResult<Spec> {
    let parsed = volta_spec::parse_spec(text).map_err(|e| spec_parse_error_to_py(text, &e))?;
    Spec::new(&parsed, &dims.unwrap_or_default()).map_err(other_error_to_py)
}

pub(crate) fn load_kernel(
    path: &Path,
    config: Option<&ConfigPy>,
    kernel: Option<&str>,
) -> PyResult<(Isa, KernelRun)> {
    let isa = Isa::of_path(path).ok_or_else(|| {
        VoltaError::new_err(format!(
            "{} is not a kernel file Volta reads (.ptx, .s or .py)",
            path.display()
        ))
    })?;
    let source = std::fs::read_to_string(path)
        .map_err(|e| VoltaError::new_err(format!("read {}: {e}", path.display())))?;
    let launch = config.map_or_else(|| AnalysisConfig::new((1, 1, 1)), |c| c.0.clone());
    let run = isa
        .frontend()
        .analyze(&source, kernel, launch)
        .map_err(|e| frontend_error_to_py(&source, &e))?;
    Ok((isa, run))
}

pub(crate) fn race_verified(run: &KernelRun) -> Option<bool> {
    match &run.graph {
        GraphEvidence::Checked { report, .. } => {
            Some(report.conclusion() == GraphConclusion::Verified)
        }
        GraphEvidence::NotRecorded => None,
    }
}
