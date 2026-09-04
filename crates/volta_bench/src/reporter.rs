//! Result reporting: console tables and summaries. The machine-readable
//! results JSON lives in `crate::results`.

use std::io::Write;

use anyhow::Result;

use crate::config::BenchmarkCategory;
use crate::runner::{ActualOutcome, BenchmarkResult};
use crate::z3_phase::Z3PhaseOutcome;

/// Which of the pipeline's timed phases a run performed - decides the
/// table's timing columns. Everything else (status, Z3 sub-rows, failure
/// lines) is shared.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TableMode {
    /// The one-shot commands: generation and solve columns.
    Combined,
    /// `generate`: generation columns only (nothing was solved; Elems is
    /// the generated footprint size).
    GenerateOnly,
    /// `solve`: dump-load and solve columns only (nothing was generated).
    SolveOnly,
}

impl TableMode {
    /// The bracketed note after the table title, naming the timing
    /// columns that are medians.
    fn header_note(self, iterations: usize) -> String {
        match self {
            Self::Combined => format!("[Gen/Solve (s): median of {} iteration(s)]", iterations),
            Self::GenerateOnly => format!(
                "[Gen (s): median of {} iteration(s); VCs dumped, not solved]",
                iterations
            ),
            Self::SolveOnly => format!(
                "[Solve (s): median of {} iteration(s); VCs loaded from dumps]",
                iterations
            ),
        }
    }
}

/// Print one category's results as a table (paper-style columns per
/// [`TableMode`], plus Z3 columns when the run had a Z3 phase). "Gen (s)"
/// and "Solve (s)" (and "Z3 (s)") are *medians* across the run's
/// `iterations` (noted on the header line).
pub fn print_results_table(
    out: &mut impl Write,
    results: &[BenchmarkResult],
    category: BenchmarkCategory,
    iterations: usize,
    z3: bool,
    mode: TableMode,
) -> Result<()> {
    writeln!(
        out,
        "\n{} ({}) {}",
        category.name(),
        category.table_ref(),
        mode.header_note(iterations)
    )?;
    let mut width = 28 + 8;
    write!(out, "{:<28} {:>7}", "Benchmark", "Status")?;
    if mode != TableMode::SolveOnly {
        write!(out, " {:>9}", "Gen (s)")?;
        width += 10;
    }
    if mode == TableMode::SolveOnly {
        write!(out, " {:>9}", "Load (s)")?;
        width += 10;
    }
    if mode != TableMode::GenerateOnly {
        write!(out, " {:>9}", "Solve (s)")?;
        width += 10;
    }
    if mode != TableMode::SolveOnly {
        write!(out, " {:>11} {:>11}", "#BlockSync", "#WarpSync")?;
        width += 24;
    }
    write!(out, " {:>9}", "Elems")?;
    width += 10;
    // Everything before the Z3 columns - the `+exp-axiom` sub-rows pad
    // to here so their Z3 cells align with the main rows'.
    let pre_z3_width = width;
    if z3 {
        write!(
            out,
            " {:>9}  Z3: equiv/diff/unk/to/unsup/err",
            "Z3 (s)"
        )?;
        width += 43;
    }
    writeln!(out)?;
    writeln!(out, "{}", "-".repeat(width))?;
    for r in results.iter().filter(|r| r.category == category) {
        let elems = if mode == TableMode::GenerateOnly
            || r.stats.elements_checked == r.stats.elements_total
        {
            format!("{}", r.stats.elements_total)
        } else {
            format!("{}/{}", r.stats.elements_checked, r.stats.elements_total)
        };
        write!(out, "{:<28} {:>7}", r.name, r.outcome.status())?;
        if mode != TableMode::SolveOnly {
            write!(out, " {:>9.2}", r.stats.vc_gen_median_secs())?;
        }
        if mode == TableMode::SolveOnly {
            match r.stats.dump_load_secs {
                Some(secs) => write!(out, " {:>9.3}", secs)?,
                None => write!(out, " {:>9}", "-")?,
            }
        }
        if mode != TableMode::GenerateOnly {
            // A z3-only solve has no decision iterations: show a dash,
            // not a fabricated 0.000.
            if r.stats.solve_iters_secs.is_empty() && mode == TableMode::SolveOnly {
                write!(out, " {:>9}", "-")?;
            } else {
                write!(out, " {:>9.3}", r.stats.solve_median_secs())?;
            }
        }
        if mode != TableMode::SolveOnly {
            write!(
                out,
                " {:>11} {:>11}",
                r.stats.block_syncs, r.stats.warp_syncs
            )?;
        }
        write!(out, " {:>9}", elems)?;
        if z3 {
            match &r.z3 {
                Some(Z3PhaseOutcome::Ran(phase)) => write!(
                    out,
                    " {:>9.3}  {}",
                    phase.plain.median_secs(),
                    phase.plain.counts.compact()
                )?,
                // Failed phase: flagged on its own line below.
                // Race-check/rejected/errored benchmarks: no Z3 phase.
                Some(Z3PhaseOutcome::Failed(_)) | None => {}
            }
        }
        writeln!(out)?;
        if let Some(Z3PhaseOutcome::Ran(phase)) = &r.z3
            && let Some(axiom) = &phase.axiom
        {
            writeln!(
                out,
                "{:<pad$} {:>9.3}  {}",
                "  +exp-axiom",
                axiom.median_secs(),
                axiom.counts.compact(),
                pad = pre_z3_width,
            )?;
        }
        if let Some(Z3PhaseOutcome::Failed(message)) = &r.z3 {
            writeln!(out, "    Z3 PHASE FAILED: {}", message)?;
        }
        if !r.outcome_matched {
            writeln!(out, "    UNEXPECTED: {}", describe(&r.outcome))?;
        }
    }
    Ok(())
}

/// Print all results grouped by category.
pub fn print_all_results(
    out: &mut impl Write,
    results: &[BenchmarkResult],
    iterations: usize,
    z3: bool,
    mode: TableMode,
) -> Result<()> {
    for category in BenchmarkCategory::all() {
        if results.iter().any(|r| r.category == category) {
            print_results_table(out, results, category, iterations, z3, mode)?;
        }
    }
    print_summary(out, results)
}

pub fn print_summary(out: &mut impl Write, results: &[BenchmarkResult]) -> Result<()> {
    let passed = results.iter().filter(|r| r.passed).count();
    writeln!(out, "\n{}/{} benchmarks passed", passed, results.len())?;
    for r in results.iter().filter(|r| !r.passed) {
        // Name every reason: an unexpected outcome, a failed Z3 phase,
        // or both.
        let mut reasons = Vec::new();
        if !r.outcome_matched {
            reasons.push(describe(&r.outcome));
        }
        if let Some(Z3PhaseOutcome::Failed(message)) = &r.z3 {
            reasons.push(format!("z3 phase failed: {}", message));
        }
        writeln!(out, "  FAILED {}: {}", r.name, reasons.join("; "))?;
    }
    Ok(())
}

/// The `single` command's detailed report for one benchmark (also used
/// by `generate single`/`solve single` with the matching [`TableMode`]).
/// In `Combined` mode the generation lines (VC gen, Instrs, Syncs) print
/// unconditionally - zeros included - exactly as the one-shot report
/// always has, failed runs included; the phase-limited modes print no
/// line for a phase that didn't run.
pub fn print_single_result(
    out: &mut impl Write,
    result: &BenchmarkResult,
    mode: TableMode,
) -> Result<()> {
    writeln!(out, "Status:  {}", result.outcome.status())?;
    writeln!(out, "Detail:  {}", describe(&result.outcome))?;
    writeln!(out, "Passed:  {}", if result.passed { "yes" } else { "no" })?;
    // A `solve` run has no generation phase; don't print a "0.000s
    // median of 0 iteration(s)" line there. (Combined keeps the one-shot
    // report's historical all-lines shape even for failures.)
    let generation_lines =
        mode == TableMode::Combined || !result.stats.vc_gen_iters_secs.is_empty();
    if generation_lines {
        writeln!(
            out,
            "VC gen:  {:.3}s median of {} iteration(s) (lowering + exec + footprint pairing)",
            result.stats.vc_gen_median_secs(),
            result.stats.vc_gen_iters_secs.len(),
        )?;
    }
    if let Some(secs) = result.stats.dump_load_secs {
        writeln!(out, "VC load: {:.3}s (excluded from solve times)", secs)?;
    }
    // Race-check benchmarks (and failed or z3-only runs) have no
    // decision-solve phase - matching the pre-decoupling report, which
    // also skipped this line for them.
    if !result.stats.solve_iters_secs.is_empty() {
        writeln!(
            out,
            "Solve:   {:.3}s median of {} iteration(s)",
            result.stats.solve_median_secs(),
            result.stats.solve_iters_secs.len()
        )?;
    }
    match &result.z3 {
        None => {}
        Some(Z3PhaseOutcome::Failed(message)) => {
            writeln!(out, "Z3:      PHASE FAILED: {}", message)?
        }
        Some(Z3PhaseOutcome::Ran(phase)) => {
            writeln!(
                out,
                "Z3:      {:.3}s median of {} iteration(s)  [{}]",
                phase.plain.median_secs(),
                phase.plain.iters_secs.len(),
                phase.plain.counts.compact(),
            )?;
            if let Some(axiom) = &phase.axiom {
                writeln!(
                    out,
                    "Z3+ax:   {:.3}s median of {} iteration(s)  [{}]",
                    axiom.median_secs(),
                    axiom.iters_secs.len(),
                    axiom.counts.compact(),
                )?;
            }
        }
    }
    if let Some(path) = &result.dump_path {
        writeln!(out, "VC dump: {}", path.display())?;
    }
    if generation_lines {
        writeln!(out, "Instrs:  {}", result.stats.instructions)?;
        writeln!(
            out,
            "Syncs:   {} block, {} warp",
            result.stats.block_syncs, result.stats.warp_syncs
        )?;
    }
    match mode {
        // `generate` solves nothing: the footprint total is the number,
        // not a misleading "0 checked".
        TableMode::GenerateOnly => writeln!(
            out,
            "Elems:   {} generated (not solved)",
            result.stats.elements_total
        )?,
        TableMode::Combined | TableMode::SolveOnly => writeln!(
            out,
            "Elems:   {} checked of {}",
            result.stats.elements_checked, result.stats.elements_total
        )?,
    }
    Ok(())
}

pub fn describe(outcome: &ActualOutcome) -> String {
    match outcome {
        ActualOutcome::Equivalent => "equivalent".to_string(),
        ActualOutcome::NotEquivalent { mismatches, first } => {
            format!("{} mismatched elements (first: {})", mismatches, first)
        }
        ActualOutcome::Rejected { description, .. } => description.clone(),
        ActualOutcome::RaceFree => "race-free".to_string(),
        ActualOutcome::VcsGenerated => {
            "VCs generated and dumped (not solved; run `volta-bench solve`)".to_string()
        }
        ActualOutcome::Z3Only { refutations: 0 } => {
            "z3 comparison only (no decision-procedure verdict)".to_string()
        }
        ActualOutcome::Z3Only { refutations } => format!(
            "z3 reported not_equivalent for {} element(s) across its runs - an \
             affirmative refutation, and no decision-procedure verdict exists in \
             --backend z3 to weigh it against",
            refutations
        ),
        ActualOutcome::Error { message } => message.clone(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn failed_result() -> BenchmarkResult {
        BenchmarkResult {
            name: "x".to_string(),
            category: crate::config::BenchmarkCategory::Reduction,
            elapsed_secs: 0.0,
            outcome: ActualOutcome::Error {
                message: "boom".to_string(),
            },
            stats: Default::default(),
            outcome_matched: false,
            passed: false,
            dump_path: None,
            z3: None,
        }
    }

    /// The one-shot (`Combined`) single report prints its generation
    /// lines unconditionally - zeros included - even for a failed run
    /// with empty stats, exactly as it did before the phase-decoupled
    /// modes existed; the phase-limited modes keep gating them on the
    /// phase having run.
    #[test]
    fn combined_single_report_prints_generation_lines_unconditionally() {
        let result = failed_result();
        let mut combined = Vec::new();
        print_single_result(&mut combined, &result, TableMode::Combined).unwrap();
        let text = String::from_utf8(combined).unwrap();
        assert!(
            text.contains("VC gen:  0.000s median of 0 iteration(s)"),
            "{text}"
        );
        assert!(text.contains("Instrs:  0"), "{text}");
        assert!(text.contains("Syncs:   0 block, 0 warp"), "{text}");
        assert!(text.contains("Elems:   0 checked of 0"), "{text}");

        let mut solve_only = Vec::new();
        print_single_result(&mut solve_only, &result, TableMode::SolveOnly).unwrap();
        let text = String::from_utf8(solve_only).unwrap();
        assert!(!text.contains("VC gen:"), "{text}");
        assert!(!text.contains("Instrs:"), "{text}");
    }

    /// `generate single` reports the generated footprint total, not a
    /// misleading "0 checked of N" (nothing is solved by `generate`).
    #[test]
    fn generate_only_single_report_prints_totals_only_elems() {
        let mut result = failed_result();
        result.outcome = ActualOutcome::VcsGenerated;
        result.outcome_matched = true;
        result.passed = true;
        result.stats.vc_gen_iters_secs = vec![0.25];
        result.stats.elements_total = 42;
        let mut out = Vec::new();
        print_single_result(&mut out, &result, TableMode::GenerateOnly).unwrap();
        let text = String::from_utf8(out).unwrap();
        assert!(
            text.contains("Elems:   42 generated (not solved)"),
            "{text}"
        );
        assert!(!text.contains("checked of"), "{text}");
    }
}
