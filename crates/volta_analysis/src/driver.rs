//! High-level analysis driver: parse tree in, per-output-element symbolic
//! expressions (or a race/deadlock/structured-CTA error) out.

use std::fmt;

use volta_frontend::ast::{Function, Module, TopLevelItem, VarDecl};

use volta_expr::ValueEquality;

use crate::eval::{AnalysisConfig, AnalysisOutput, EvalError, Interpreter, TargetFeatures};
use crate::logging::info;
use crate::lower_error::LowerError;
use crate::lowering::lower_function;

/// Errors from the end-to-end analysis of one kernel.
#[derive(Debug)]
pub enum AnalysisError {
    KernelNotFound { name: Option<String> },
    Lower(LowerError),
    Eval(EvalError),
}

impl fmt::Display for AnalysisError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::KernelNotFound { name: Some(name) } => {
                write!(f, "no kernel named '{}' in module", name)
            }
            Self::KernelNotFound { name: None } => write!(f, "no kernel entry in module"),
            Self::Lower(e) => write!(f, "lowering failed: {}", e),
            Self::Eval(e) => write!(f, "{}", e),
        }
    }
}

impl std::error::Error for AnalysisError {}

impl From<LowerError> for AnalysisError {
    fn from(e: LowerError) -> Self {
        Self::Lower(e)
    }
}

impl From<EvalError> for AnalysisError {
    fn from(e: EvalError) -> Self {
        Self::Eval(e)
    }
}

/// Find a kernel entry point by name, or the unique entry if `name` is None.
pub fn find_kernel<'m>(
    module: &'m Module,
    name: Option<&str>,
) -> Result<&'m Function, AnalysisError> {
    let mut entries = module.items.iter().filter_map(|item| match item {
        TopLevelItem::Entry(f) => Some(f),
        _ => None,
    });
    match name {
        Some(name) => {
            entries
                .find(|f| f.name.to_string() == name)
                .ok_or(AnalysisError::KernelNotFound {
                    name: Some(name.to_string()),
                })
        }
        None => entries
            .next()
            .ok_or(AnalysisError::KernelNotFound { name: None }),
    }
}

/// Module-level variable declarations (extern shared memory, module globals).
pub fn module_vars(module: &Module) -> Vec<VarDecl> {
    module
        .items
        .iter()
        .filter_map(|item| match item {
            TopLevelItem::Variable(v) => Some(v.clone()),
            _ => None,
        })
        .collect()
}

/// Analyze one kernel: lower it and symbolically execute all threads of
/// CTA (0,0,0) under the given configuration. `value_equality` decides
/// benign same-value stores for the race detector.
pub fn analyze_kernel(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
    value_equality: &dyn ValueEquality,
) -> Result<AnalysisOutput, AnalysisError> {
    let func = find_kernel(module, kernel)?;
    let vars = module_vars(module);
    let program = lower_function(func, &vars)?;
    info!(
        "analyzing kernel {:?}: block={:?} grid={:?}",
        kernel, config.block_dim, config.grid_dim
    );
    let features = TargetFeatures::from_target(&module.target);
    let mut interp = Interpreter::new(&program, config, features, value_equality)?;
    interp.run()?;
    Ok(interp.into_output()?)
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
