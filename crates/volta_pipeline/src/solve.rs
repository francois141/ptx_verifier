//! A kernel's outputs against a spec, by the caller's solver. Both solvers first require the
//! kernel to write exactly the spec's elements; the canonical decision procedure then decides
//! each element, while the Lean solver states each one, and proves them if given a prover.

use std::collections::HashMap;
use std::fmt;
use std::path::PathBuf;

use rug::Rational;
use volta_common::logging::info;
use volta_equivalence::check::{EquivCheckOptions, EquivCheckReport};
use volta_expr::SymbolicOutputs;
use volta_lean::{Claim, ClaudeCode, LeanProof, ToolServer, to_lean};
use volta_spec::{InstantiateErrorKind, OutputSpec, ParsedSpec, SpecEnv, SpecError};

use crate::equivalence::{EquivalenceVerdict, check_equivalence};
use crate::frontend::SolveError;

/// The namespace of the Lean module the Lean solver writes, unless the caller names one.
pub const DEFAULT_LEAN_NAMESPACE: &str = "VoltaChallenge";

/// How a kernel's outputs are checked against a spec.
#[derive(Debug, Clone)]
pub enum Solver {
    /// The canonicalizing decision procedure of `volta_equivalence`, each claimed difference
    /// confirmed by the numeric oracle.
    Canonical(EquivCheckOptions),
    /// Lean 4 statements of `claim` for every element, in namespace `namespace`, proved by
    /// `prover` when given, else left to the caller.
    Lean {
        claim: Claim,
        namespace: String,
        prover: Option<LeanProver>,
    },
}

/// A Claude Code agent proving the statements, with Volta's final check as the verdict.
#[derive(Debug, Clone)]
pub struct LeanProver {
    /// Where `challenge.lean`, `proof.lean` and the agent's transcript go.
    pub directory: PathBuf,
    /// A Lake project with Mathlib built; `None` reads `$VOLTA_LEAN_PROJECT`.
    pub project: Option<PathBuf>,
    pub agent: ClaudeCode,
    /// The command serving the proving tools to the agent.
    pub server: ToolServer,
}

/// `Claim::Within` the rational `tolerance` (`1/1000`), or `Claim::Equal` without one.
pub fn claim(tolerance: Option<&str>) -> Result<Claim, String> {
    match tolerance {
        None => Ok(Claim::Equal),
        Some(text) => text
            .parse::<Rational>()
            .map(Claim::Within)
            .map_err(|_| format!("tolerance `{text}` is not a rational such as 1/1000")),
    }
}

/// A spec at concrete dims: for each array it defines, the value of every element.
#[derive(Debug)]
pub struct Spec {
    env: SpecEnv,
    outputs: Vec<OutputSpec>,
    arrays: Vec<String>,
}

#[derive(Debug)]
pub enum InvalidSpec {
    Instantiate(InstantiateErrorKind),
    /// The spec defines no output array, so there is nothing to check.
    NoOutputs,
}

impl fmt::Display for InvalidSpec {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Instantiate(e) => write!(f, "{e}"),
            Self::NoOutputs => write!(f, "spec declares no output equations to check"),
        }
    }
}

impl std::error::Error for InvalidSpec {}

impl Spec {
    pub fn new(parsed: &ParsedSpec, dims: &HashMap<String, u64>) -> Result<Self, InvalidSpec> {
        let (env, outputs) =
            volta_spec::instantiate(parsed, dims).map_err(InvalidSpec::Instantiate)?;
        let mut arrays: Vec<String> = Vec::new();
        for output in &parsed.outputs {
            if !arrays.contains(&output.array) {
                arrays.push(output.array.clone());
            }
        }
        if arrays.is_empty() {
            return Err(InvalidSpec::NoOutputs);
        }
        Ok(Self {
            env,
            outputs,
            arrays,
        })
    }

    /// The arrays the spec defines, in declaration order: the arrays a kernel is checked on.
    pub fn arrays(&self) -> &[String] {
        &self.arrays
    }

    /// The first array `kernel` does not write exactly the spec's indices of: each spec
    /// output defines every flat index of its shape.
    fn index_set_mismatch(&self, kernel: &SymbolicOutputs) -> Option<EquivalenceVerdict> {
        self.arrays.iter().find_map(|name| {
            let expected = self
                .outputs
                .iter()
                .filter(|s| &s.array == name)
                .map(|s| s.shape.size())
                .max()
                .unwrap_or(0);
            let written: Vec<u64> = kernel
                .outputs
                .iter()
                .find(|(n, _)| n == name)
                .map_or_else(Vec::new, |(_, elems)| {
                    elems.iter().map(|&(index, _)| index).collect()
                });
            let unwritten: Vec<u64> = (0..expected)
                .filter(|index| written.binary_search(index).is_err())
                .collect();
            let unexpected: Vec<u64> = written.iter().copied().filter(|&i| i >= expected).collect();
            (!unwritten.is_empty() || !unexpected.is_empty()).then(|| {
                EquivalenceVerdict::IndexSetMismatch {
                    array: name.clone(),
                    unwritten,
                    unexpected,
                }
            })
        })
    }
}

/// The canonical solver's verdict on `kernel` against `spec`, with its report when it ran.
/// `options.sample` also caps the spec's unfolding (a Sum-heavy spec over a big footprint is
/// impractical to unroll), so `kernel` is compared on that prefix of each array, then restored.
pub fn check_against_spec(
    kernel: &mut SymbolicOutputs,
    spec: &Spec,
    options: &EquivCheckOptions,
) -> Result<(EquivalenceVerdict, Option<EquivCheckReport>), SpecError> {
    // Before sampling truncates either side, so a sampled prefix cannot hide an unwritten element.
    if let Some(mismatch) = spec.index_set_mismatch(kernel) {
        return Ok((mismatch, None));
    }
    let untruncated: u64 = kernel
        .outputs
        .iter()
        .filter(|(n, _)| spec.arrays.contains(n))
        .map(|(_, elems)| elems.len() as u64)
        .sum();
    let baseline = volta_spec::unfold(&spec.outputs, &spec.env, options.sample)?;
    let written = (options.sample > 0).then(|| {
        let written = kernel.outputs.clone();
        for (name, elems) in &mut kernel.outputs {
            if spec.arrays.contains(name) {
                elems.truncate(options.sample as usize);
            }
        }
        written
    });
    let (mut verdict, mut report) = check_equivalence(kernel, &baseline, &spec.arrays, options);
    if let Some(written) = written {
        kernel.outputs = written;
    }
    if let Some(report) = &mut report {
        report.elements_total = untruncated;
    }
    if let EquivalenceVerdict::Equivalent { checked, total } = &mut verdict {
        *total = (*total).max(untruncated);
        *checked = (*checked).min(*total);
    }
    Ok((verdict, report))
}

/// Lean statements of `claim` comparing every element of `kernel` with `spec`'s.
pub fn state_against_spec(
    kernel: &SymbolicOutputs,
    spec: &Spec,
    claim: &Claim,
    namespace: &str,
) -> Result<LeanSolution, SpecError> {
    if let Some(mismatch) = spec.index_set_mismatch(kernel) {
        return Ok(LeanSolution::Stopped(mismatch));
    }
    let baseline = volta_spec::unfold(&spec.outputs, &spec.env, 0)?;
    Ok(
        match to_lean(kernel, &baseline, &spec.arrays, claim, namespace) {
            Ok(module) => LeanSolution::Stated(LeanChallenge {
                module,
                statements: baseline.outputs.iter().map(|(_, e)| e.len()).sum(),
            }),
            Err(e) => LeanSolution::Stopped(EquivalenceVerdict::Failed {
                reason: format!("no Lean statements: {e}"),
            }),
        },
    )
}

/// What a solver made of a kernel's outputs against a spec.
#[derive(Debug)]
pub enum Solution {
    /// The canonical solver's verdict, with its report when it ran.
    Canonical {
        verdict: EquivalenceVerdict,
        report: Option<EquivCheckReport>,
    },
    Lean(LeanSolution),
}

#[derive(Debug)]
pub enum LeanSolution {
    /// Statements for a prover: whether the kernel matches the spec rests on their proofs.
    Stated(LeanChallenge),
    /// Statements and the prover's attempt at them, which holds only if `proof.check.proved`.
    Attempted {
        challenge: LeanChallenge,
        proof: Box<LeanProof>,
    },
    /// No statements, for this verdict: no outputs, an index set mismatch, or an expression
    /// Lean cannot state.
    Stopped(EquivalenceVerdict),
}

/// A Lean 4 module of one `Prop` per output element.
#[derive(Debug)]
pub struct LeanChallenge {
    pub module: String,
    pub statements: usize,
}

impl Solution {
    /// The equivalence branch's verdict as `decide` weighs it: Lean statements leave
    /// equivalence undecided until a prover discharges them.
    pub fn verdict(&self) -> EquivalenceVerdict {
        match self {
            Solution::Canonical { verdict, .. } => verdict.clone(),
            Solution::Lean(LeanSolution::Stated(challenge)) => EquivalenceVerdict::Failed {
                reason: format!(
                    "left to Lean: {} statement(s) to prove",
                    challenge.statements
                ),
            },
            Solution::Lean(LeanSolution::Attempted { proof, .. }) => EquivalenceVerdict::Failed {
                reason: format!(
                    "left to Lean: {} of {} statement(s) proved, a proof decide does not weigh",
                    proof.check.proved_statements, proof.check.statements
                ),
            },
            Solution::Lean(LeanSolution::Stopped(verdict)) => verdict.clone(),
        }
    }
}

/// `outputs`, or why the kernel has none, against `spec` by `solver`.
pub(crate) fn solve(
    outputs: Result<&mut SymbolicOutputs, &str>,
    spec: &Spec,
    solver: &Solver,
) -> Result<Solution, SolveError> {
    let kernel = match outputs {
        Ok(kernel) => kernel,
        Err(why) => {
            let verdict = EquivalenceVerdict::Failed {
                reason: format!("kernel: {why}"),
            };
            return Ok(match solver {
                Solver::Canonical(_) => Solution::Canonical {
                    verdict,
                    report: None,
                },
                Solver::Lean { .. } => Solution::Lean(LeanSolution::Stopped(verdict)),
            });
        }
    };
    match solver {
        Solver::Canonical(options) => {
            let (verdict, report) =
                check_against_spec(kernel, spec, options).map_err(SolveError::Spec)?;
            Ok(Solution::Canonical { verdict, report })
        }
        Solver::Lean {
            claim,
            namespace,
            prover,
        } => {
            let stated =
                state_against_spec(kernel, spec, claim, namespace).map_err(SolveError::Spec)?;
            match (stated, prover) {
                (LeanSolution::Stated(challenge), Some(prover)) => {
                    prove(challenge, claim, prover).map(Solution::Lean)
                }
                (stated, _) => Ok(Solution::Lean(stated)),
            }
        }
    }
}

fn prove(
    challenge: LeanChallenge,
    claim: &Claim,
    prover: &LeanProver,
) -> Result<LeanSolution, SolveError> {
    let claimed = match claim {
        Claim::Equal => "equal to".to_string(),
        Claim::Within(tolerance) => format!("within {tolerance} of"),
    };
    info!(
        "[lean] challenge generated: {} proof obligations, each output {claimed} the spec",
        challenge.statements
    );
    // `prove` logs each step itself.
    let proof = volta_lean::prove(
        &challenge.module,
        &prover.directory,
        prover.project.as_deref(),
        &prover.agent,
        &prover.server,
        &|_| {},
    )
    .map_err(SolveError::Prover)?;
    Ok(LeanSolution::Attempted {
        challenge,
        proof: Box::new(proof),
    })
}
