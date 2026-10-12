//! The optional Z3 phase (`--z3`): re-solve the decision procedure's sampled
//! elements with Z3 (Table 8 / section 6.5), plus a `+exp-axiom` rerun for VCs
//! with `Exp`. Solve times count in-worker libz3 time only (deciding work).

use std::num::NonZeroUsize;
use std::time::Duration;

use volta_analysis::eval::AnalysisOutput;
use volta_analysis::symbolic::{ExprId, ExprNode};
use volta_z3::{ElementOutcome, ElementResult, ExpMode, Z3Counts};

use crate::results::median;

/// Configuration for the Z3 phase, carried inside `RunnerConfig` (`Some`
/// exactly when `--z3` was passed).
#[derive(Debug, Clone)]
pub struct Z3Options {
    /// Per-query Z3 time budget (`None` = no limit).
    pub timeout: Option<Duration>,
}

/// One Z3 run over a benchmark's sampled elements under a single exp
/// encoding: per-iteration solve totals, iteration 1's verdict counts,
/// and iteration 1's per-element results.
#[derive(Debug, Clone)]
pub struct Z3ModeRun {
    /// Z3 solve time per iteration, summed over elements (in-worker only;
    /// timeouts count their budget). Carved-out elements are solved in
    /// iteration 1 only and that time is charged to every entry.
    pub iters_secs: Vec<f64>,
    /// Per-outcome element counts (iteration 1's verdicts).
    pub counts: Z3Counts,
    /// Iteration 1's per-element outcomes and solve times, in
    /// `driver::sampled_elements` order - positionally aligned with the
    /// decision procedure's per-element results.
    pub elements: Vec<ElementResult>,
}

impl Z3ModeRun {
    /// Median solve time across iterations (the table's Z3 column).
    pub fn median_secs(&self) -> f64 {
        median(&self.iters_secs).unwrap_or(0.0)
    }
}

/// The full Z3 phase for one benchmark: the default exp encoding, plus
/// the `+exp-axiom` rerun for benchmarks whose VCs contain exponentials
/// (the axiom is vacuous otherwise).
#[derive(Debug, Clone)]
pub struct Z3Phase {
    /// The default `ExpMode::PowerBounded` encoding.
    pub plain: Z3ModeRun,
    /// The same elements rerun under `ExpMode::AdditionAxiom`; `None`
    /// when the VCs contain no `Exp` node.
    pub axiom: Option<Z3ModeRun>,
}

/// Whether the Z3 phase ran to completion. `Failed` leaves the decision
/// verdict intact but fails the benchmark: the requested comparison is missing.
#[derive(Debug, Clone)]
pub enum Z3PhaseOutcome {
    Ran(Z3Phase),
    Failed(String),
}

/// Does any expression reachable from the outputs contain `Exp` (deciding
/// the `+exp-axiom` rerun)? Iterative DFS from output roots only.
fn vc_uses_exp(output: &AnalysisOutput) -> bool {
    let mut visited = vec![false; output.arena.node_count()];
    let mut stack: Vec<_> = output
        .outputs
        .iter()
        .flat_map(|(_, elems)| elems.iter().map(|&(_, root)| root))
        .collect();
    while let Some(id) = stack.pop() {
        let index = id_collections::Id::to_index(id) as usize;
        if std::mem::replace(&mut visited[index], true) {
            continue;
        }
        let node = output.arena.node(id);
        if matches!(node, ExprNode::Exp(_)) {
            return true;
        }
        node.for_each_child(|child| stack.push(child));
    }
    false
}

/// The carve-out: outcomes solved in iteration 1 only (re-solving a timeout
/// multiplies its budget; unsupported/error never reach the solver). Exhaustive
/// so a new `ElementOutcome` variant is a compile error, not a silent choice.
fn carved_out(outcome: &ElementOutcome) -> bool {
    match outcome {
        ElementOutcome::Timeout | ElementOutcome::Unsupported(_) | ElementOutcome::Error(_) => true,
        ElementOutcome::Equivalent | ElementOutcome::NotEquivalent | ElementOutcome::Unknown => {
            false
        }
    }
}

/// One element's Z3 solve time for a re-solve iteration. Later verdicts aren't
/// compared (z3's unknown/timeout boundary is budget-dependent); elements that
/// never reach the solver contribute zero, as in iteration 1.
fn z3_resolve_time(
    reference: &AnalysisOutput,
    r: ExprId,
    optimized: &AnalysisOutput,
    o: ExprId,
    timeout: Option<Duration>,
    mode: ExpMode,
) -> Duration {
    match volta_z3::check_equivalent(&reference.arena, r, &optimized.arena, o, timeout, mode) {
        Ok(res) => res.solve,
        Err(_) => Duration::ZERO,
    }
}

/// Run Z3 `iterations` times over `sampled` (the caller's
/// `driver::sampled_elements` list), applying the carve-out on re-solves.
fn z3_iterations(
    reference: &AnalysisOutput,
    optimized: &AnalysisOutput,
    arrays: &[String],
    sampled: &[(&str, u64, ExprId, ExprId)],
    sample: u64,
    iterations: NonZeroUsize,
    timeout: Option<Duration>,
    mode: ExpMode,
) -> Result<Z3ModeRun, String> {
    // Iteration 1: the ordinary full run - per-element verdicts and times.
    let report =
        volta_z3::check_output_equivalence(reference, optimized, arrays, sample, timeout, mode)
            .map_err(|e| format!("z3: {}", e))?;
    let counts = report.counts();
    // The re-solve loop pairs `report.elements` with `sampled` positionally;
    // both derive from `driver::sampled_elements`, so check (in release too)
    // that they agree - a silent mispairing would re-solve the wrong exprs.
    if report.elements.len() != sampled.len()
        || report
            .elements
            .iter()
            .zip(sampled)
            .any(|(e, &(name, index, _, _))| e.array != name || e.index != index)
    {
        return Err(format!(
            "z3 element list ({} elements) does not match the sampled VC list ({}): \
             volta_z3::check_output_equivalence and driver::sampled_elements must \
             sample identically",
            report.elements.len(),
            sampled.len(),
        ));
    }

    // Iteration-1 time of the carved-out elements, charged to every
    // iteration's total (timeouts report their budget - see
    // `volta_z3::Z3CheckResult`).
    let carved_secs: f64 = report
        .elements
        .iter()
        .filter(|e| carved_out(&e.outcome))
        .map(|e| e.solve.as_secs_f64())
        .sum();

    let mut iters_secs = vec![report.total_solve_secs()];
    for _ in 1..iterations.get() {
        let mut total = carved_secs;
        for (element, &(_, _, r, o)) in report.elements.iter().zip(sampled) {
            if !carved_out(&element.outcome) {
                total += z3_resolve_time(reference, r, optimized, o, timeout, mode).as_secs_f64();
            }
        }
        iters_secs.push(total);
    }
    Ok(Z3ModeRun {
        iters_secs,
        counts,
        elements: report.elements,
    })
}

/// Run one benchmark's Z3 phase (default exp encoding, plus `+exp-axiom` when
/// the VCs use exp) over `driver::sampled_elements`. Never panics: failures
/// become [`Z3PhaseOutcome::Failed`] so a batch run keeps going.
#[allow(clippy::too_many_arguments)]
pub(crate) fn run_z3_phase(
    reference: &AnalysisOutput,
    optimized: &AnalysisOutput,
    arrays: &[String],
    sampled: &[(&str, u64, ExprId, ExprId)],
    sample: u64,
    iterations: NonZeroUsize,
    options: &Z3Options,
) -> Z3PhaseOutcome {
    let run = |mode: ExpMode| {
        z3_iterations(
            reference,
            optimized,
            arrays,
            sampled,
            sample,
            iterations,
            options.timeout,
            mode,
        )
    };
    let plain = match run(ExpMode::PowerBounded) {
        Ok(run) => run,
        Err(e) => return Z3PhaseOutcome::Failed(e),
    };
    let axiom = if vc_uses_exp(reference) || vc_uses_exp(optimized) {
        match run(ExpMode::AdditionAxiom) {
            Ok(run) => Some(run),
            Err(e) => return Z3PhaseOutcome::Failed(format!("+exp-axiom rerun: {}", e)),
        }
    } else {
        None
    };
    Z3PhaseOutcome::Ran(Z3Phase { plain, axiom })
}
