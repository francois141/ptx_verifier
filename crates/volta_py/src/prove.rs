//! `volta.prove_lean` and `volta.check_lean_proof`: `extract_lean`'s obligations proved in Lean
//! by a Claude Code agent, and the check that accepts a proof (`volta_lean`). The work runs
//! with the GIL released, so the Rust logs it forwards to Python's `logging` reach it meanwhile.

use std::collections::{BTreeMap, HashMap};
use std::path::PathBuf;
use std::time::{Duration, Instant};

use pyo3::prelude::*;
use volta_common::logging::info;
use volta_lean::{ClaudeCode, LeanCheck, Progress, ToolServer, Usage};

use crate::config::ConfigPy;
use crate::error::other_error_to_py;
use crate::extract::extract_lean;
use crate::logging::StderrEcho;

/// The Python that serves the proving tools to Claude Code, given a workspace file.
const SERVE_TOOLS: &str = "import sys, volta; volta._serve_lean_tools(sys.argv[1])";

/// Volta's verdict on a `proof.lean`; `report` is the text the proving agent reads.
#[pyclass(name = "LeanCheck")]
pub struct LeanCheckPy {
    #[pyo3(get)]
    pub proved: bool,
    #[pyo3(get)]
    pub statements: usize,
    #[pyo3(get)]
    pub proved_statements: usize,
    #[pyo3(get)]
    pub report: String,
}

impl From<LeanCheck> for LeanCheckPy {
    fn from(check: LeanCheck) -> LeanCheckPy {
        LeanCheckPy {
            proved: check.proved,
            statements: check.statements,
            proved_statements: check.proved_statements,
            report: check.report,
        }
    }
}

/// What `prove_lean` produced; `proved` only when the final check accepted `proof`.
/// `cost_usd` is Claude Code's own estimate of the run at API prices (on a subscription nothing
/// is billed per token).
#[pyclass(name = "LeanProof")]
pub struct LeanProofPy {
    #[pyo3(get)]
    pub proved: bool,
    #[pyo3(get)]
    pub statements: usize,
    #[pyo3(get)]
    pub proved_statements: usize,
    #[pyo3(get)]
    pub challenge: PathBuf,
    #[pyo3(get)]
    pub proof: PathBuf,
    #[pyo3(get)]
    pub report: String,
    #[pyo3(get)]
    pub summary: String,
    #[pyo3(get)]
    pub turns: u64,
    #[pyo3(get)]
    pub duration_seconds: f64,
    #[pyo3(get)]
    pub cost_usd: Option<f64>,
    /// Tokens: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`,
    /// `cache_read_input_tokens`.
    #[pyo3(get)]
    pub usage: BTreeMap<String, u64>,
    #[pyo3(get)]
    pub transcript: PathBuf,
    #[pyo3(get)]
    pub isa: String,
    #[pyo3(get)]
    pub race_verified: Option<bool>,
    #[pyo3(get)]
    pub equivalence: Option<String>,
    #[pyo3(get)]
    pub equivalence_evidence: Vec<String>,
}

/// `42s`, `5m07s` or `1h02m07s`.
fn spoken(duration: Duration) -> String {
    let seconds = duration.as_secs();
    let (hours, minutes, seconds) = (seconds / 3600, seconds / 60 % 60, seconds % 60);
    match (hours, minutes) {
        (0, 0) => format!("{seconds}s"),
        (0, _) => format!("{minutes}m{seconds:02}s"),
        _ => format!("{hours}h{minutes:02}m{seconds:02}s"),
    }
}

fn summary(proof: &volta_lean::LeanProof, total: Duration) -> [String; 2] {
    let check = &proof.check;
    let agent = &proof.agent;
    let outcome = if check.proved { "proved" } else { "NOT proved" };
    let cost = agent.cost_usd.map_or("unknown".to_string(), |usd| {
        format!("${usd:.2} (Claude Code's estimate at API prices)")
    });
    let usage = agent.usage;
    [
        format!(
            "[volta] {outcome}: {} of {} statements in {}; the agent took {} turns and {}; cost \
             {cost}",
            check.proved_statements,
            check.statements,
            spoken(total),
            agent.turns,
            spoken(proof.duration),
        ),
        format!(
            "[volta] tokens: {} input, {} output, {} cache read, {} cache written",
            usage.input_tokens,
            usage.output_tokens,
            usage.cache_read_input_tokens,
            usage.cache_creation_input_tokens,
        ),
    ]
}

fn usage_dict(usage: Usage) -> BTreeMap<String, u64> {
    [
        ("input_tokens", usage.input_tokens),
        ("output_tokens", usage.output_tokens),
        (
            "cache_creation_input_tokens",
            usage.cache_creation_input_tokens,
        ),
        ("cache_read_input_tokens", usage.cache_read_input_tokens),
    ]
    .into_iter()
    .map(|(key, tokens)| (key.to_string(), tokens))
    .collect()
}

/// Extract a kernel's Lean obligations and have a Claude Code agent prove them.
///
/// Writes `challenge.lean` (as `extract_lean` returns it, after the same graph checks),
/// `proof.lean` and the agent's `transcript.jsonl` to `output_dir`. With `equivalence`, the
/// canonical solver first checks the outputs' exact equality with the spec on the same run
/// (its verdict is `LeanProof.equivalence`; the Lean claim may be weaker, a `tolerance`).
/// An existing `proof.lean` is the agent's starting point, else one `sorry` per statement.
/// `lean_project` (default: `$VOLTA_LEAN_PROJECT`) is a Lake project with Mathlib built, whose
/// toolchain compiles both files. The agent is Claude Code's `claude -p` (`claude=`, else
/// `$VOLTA_CLAUDE`, `PATH`, then `$CLAUDE_CODE_EXECPATH`) on its own login, with no tools but
/// Volta's, which write `proof.lean` only; the result's `proved` is the final check's verdict,
/// never the agent's.
/// `verbose` prints Volta's log of the call to `sys.stderr` as it happens (each graph check, each
/// step of the proof), with the time, and a summary of the time, turns, cost and tokens at the end.
#[pyfunction]
#[pyo3(signature = (
    path, config=None, *, spec, output_dir, lean_project=None, kernel=None, dims=None,
    tolerance=None, equivalence=true, model=volta_lean::DEFAULT_MODEL, effort="high",
    max_turns=60, claude=None, verbose=false
))]
#[allow(clippy::too_many_arguments)]
pub fn prove_lean(
    py: Python<'_>,
    path: PathBuf,
    config: Option<&ConfigPy>,
    spec: &str,
    output_dir: PathBuf,
    lean_project: Option<PathBuf>,
    kernel: Option<&str>,
    dims: Option<HashMap<String, u64>>,
    tolerance: Option<&str>,
    equivalence: bool,
    model: &str,
    effort: &str,
    max_turns: u32,
    claude: Option<PathBuf>,
    verbose: bool,
) -> PyResult<LeanProofPy> {
    let started = Instant::now();
    let _echo = verbose.then(|| StderrEcho::since(started));
    let executable = volta_lean::find_claude(claude.as_deref()).map_err(other_error_to_py)?;
    let lean_project =
        volta_lean::lean_project(lean_project.as_deref()).map_err(other_error_to_py)?;
    info!(
        "[volta] {}: analysis, graph checks, equivalence check, Lean proof",
        path.display()
    );
    let extraction = extract_lean(path, config, spec, kernel, dims, tolerance, equivalence)?;
    info!("[analysis] {} kernel analyzed", extraction.isa);
    if extraction.race_verified == Some(true) {
        info!("[graph] verified: every graph check passed");
    }
    if let Some(verdict) = &extraction.verdict {
        info!("[equivalence] {verdict} against the spec (exact equality)");
        for line in &extraction.evidence {
            info!("[equivalence]   {line}");
        }
    }
    let claim = tolerance.map_or("equal to".to_string(), |t| format!("within {t} of"));
    info!(
        "[lean] challenge generated: {} proof obligations, each output {claim} the spec",
        extraction.statements
    );

    let server = ToolServer {
        program: py.import("sys")?.getattr("executable")?.extract()?,
        args: vec!["-c".to_string(), SERVE_TOOLS.to_string()],
    };
    let agent = ClaudeCode {
        executable,
        model: model.to_string(),
        effort: effort.to_string(),
        max_turns,
    };
    // `prove` logs each `Progress` itself, which the echo already prints.
    let observer = |_: &Progress| {};
    let proof = py
        .detach(|| {
            volta_lean::prove(
                &extraction.lean,
                &output_dir,
                Some(&lean_project),
                &agent,
                &server,
                &observer,
            )
        })
        .map_err(other_error_to_py)?;
    for line in summary(&proof, started.elapsed()) {
        info!("{line}");
    }
    Ok(LeanProofPy {
        proved: proof.check.proved,
        statements: proof.check.statements,
        proved_statements: proof.check.proved_statements,
        challenge: proof.challenge,
        proof: proof.proof,
        report: proof.check.report,
        summary: proof.agent.summary,
        turns: proof.agent.turns,
        duration_seconds: proof.duration.as_secs_f64(),
        cost_usd: proof.agent.cost_usd,
        usage: usage_dict(proof.agent.usage),
        transcript: proof.transcript,
        isa: extraction.isa,
        race_verified: extraction.race_verified,
        equivalence: extraction.verdict,
        equivalence_evidence: extraction.evidence,
    })
}

/// Check `directory`'s `proof.lean` against its `challenge.lean`, as `prove_lean` does.
#[pyfunction]
#[pyo3(signature = (directory, lean_project=None))]
pub fn check_lean_proof(
    py: Python<'_>,
    directory: PathBuf,
    lean_project: Option<PathBuf>,
) -> PyResult<LeanCheckPy> {
    py.detach(|| volta_lean::check_lean_proof(&directory, lean_project.as_deref()))
        .map(LeanCheckPy::from)
        .map_err(other_error_to_py)
}

/// Serve the proving tools on standard input and output for `prove_lean`'s Claude Code agent.
#[pyfunction(name = "_serve_lean_tools")]
pub fn serve_lean_tools(py: Python<'_>, config: PathBuf) -> PyResult<()> {
    py.detach(|| volta_lean::serve_stdio(&config))
        .map_err(other_error_to_py)
}
