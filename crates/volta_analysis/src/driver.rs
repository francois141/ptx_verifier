//! The legacy single-kernel entry point: the analysis stage plus a conversion of its result
//! to the original `Result<AnalysisOutput, AnalysisError>` contract. Race verification is not
//! performed here (see `AnalysisOutput::race_verification`).

use volta_frontend::ast::Module;

use volta_expr::ValueEquality;

pub use crate::analysis::{AnalysisError, find_kernel, module_vars};
use crate::analysis::{AnalysisParts, analyze};
use crate::eval::{
    AnalysisConfig, AnalysisOutput, EvalError, OutputsUnavailable, RaceVerification,
};

/// Analyze one kernel: lower it and symbolically execute all threads of
/// CTA (0,0,0) under the given configuration. No data-race or async-hazard
/// verdict is produced (`AnalysisOutput::race_verification` says so), so
/// `_value_equality`, the benign same-value store oracle, is unused.
pub fn analyze_kernel(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
    _value_equality: &dyn ValueEquality,
) -> Result<AnalysisOutput, AnalysisError> {
    legacy_output(analyze(module, kernel, config)?.into_parts())
}

/// The original contract's view of the analysis stage's artifacts.
pub fn legacy_output(parts: AnalysisParts) -> Result<AnalysisOutput, AnalysisError> {
    let AnalysisParts {
        outputs,
        stats,
        op_counts,
        ..
    } = parts;
    match outputs {
        Ok(exprs) => Ok(AnalysisOutput {
            exprs,
            stats,
            op_counts,
            race_verification: RaceVerification::Unavailable,
        }),
        Err(OutputsUnavailable::Aborted(e) | OutputsUnavailable::Extraction(e)) => {
            Err(AnalysisError::Eval(e))
        }
        Err(OutputsUnavailable::Stuck { blocked }) => {
            Err(AnalysisError::Eval(EvalError::Deadlock { blocked }))
        }
    }
}

/// Write a per-instruction-kind execution profile, most-executed first.
/// The one formatter for `AnalysisOutput::op_counts`, shared by `volta`
/// and `volta-bench` so their profile tables cannot drift.
pub fn write_op_counts(
    out: &mut dyn std::io::Write,
    label: &str,
    counts: &std::collections::BTreeMap<&'static str, u64>,
) -> std::io::Result<()> {
    if counts.is_empty() {
        return Ok(());
    }
    let total: u64 = counts.values().sum();
    let mut entries: Vec<_> = counts.iter().collect();
    entries.sort_by(|a, b| b.1.cmp(a.1).then(a.0.cmp(b.0)));
    writeln!(out, "{} profile:", label)?;
    for (kind, count) in entries {
        let pct = 100.0 * *count as f64 / total as f64;
        writeln!(out, "  {:<16} {:>10}  ({:>5.1}%)", kind, count, pct)?;
    }
    Ok(())
}
