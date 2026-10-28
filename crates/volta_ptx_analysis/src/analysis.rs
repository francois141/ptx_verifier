//! The analysis stage: one candidate execution of one kernel, producing the two artifacts the
//! downstream branches consume and no verdict. The symbolic outputs go to equivalence checking;
//! the typed event graph goes to the graph checks. Neither is checked here.

use std::collections::BTreeMap;
use std::fmt;

use crate::frontend::ast::{Function, Module, TopLevelItem, VarDecl};
use volta_expr::{ExprArena, SymbolicOutputs};
use volta_graph::{Assumption, EventGraph, InstructionInfo, Provenance};

use crate::config::AnalysisConfig;
use crate::eval::{EvalError, Interpreter, OutputsUnavailable, RunArtifacts, Stats};
use crate::ir::LoweredProgram;
use crate::logging::info;
use crate::lower::{LowerError, lower_function};

/// Errors that prevent the candidate execution from starting at all.
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

/// The analysis stage's result. The event graph is always present (partial when the execution
/// stopped early); the symbolic outputs only when the execution completed and its outputs read
/// back. Both index the same expression arena.
#[derive(Debug)]
pub struct AnalysisResult {
    /// Holds the arena always; its outputs are empty unless `outputs` is `Ok`.
    symbolic: SymbolicOutputs,
    outputs: Result<(), OutputsUnavailable>,
    pub graph: EventGraph,
    pub stats: Stats,
    pub op_counts: BTreeMap<&'static str, u64>,
}

impl AnalysisResult {
    fn from_run(run: RunArtifacts) -> Self {
        let (outputs, status) = match run.outputs {
            Ok(outputs) => (outputs, Ok(())),
            Err(why) => (Vec::new(), Err(why)),
        };
        AnalysisResult {
            symbolic: SymbolicOutputs {
                arena: run.arena,
                outputs,
            },
            outputs: status,
            graph: run.graph,
            stats: run.stats,
            op_counts: run.op_counts,
        }
    }

    /// The equivalence-facing artifact, or why the execution produced none.
    pub fn symbolic_outputs(&self) -> Result<&SymbolicOutputs, &OutputsUnavailable> {
        match &self.outputs {
            Ok(()) => Ok(&self.symbolic),
            Err(why) => Err(why),
        }
    }

    /// The arena the graph's stored values are expressions of, also when the execution
    /// produced no outputs.
    pub fn arena(&self) -> &ExprArena {
        &self.symbolic.arena
    }

    /// Split into the two artifacts.
    pub fn into_parts(self) -> AnalysisParts {
        AnalysisParts {
            outputs: match self.outputs {
                Ok(()) => Ok(self.symbolic),
                Err(why) => Err(why),
            },
            graph: self.graph,
            stats: self.stats,
            op_counts: self.op_counts,
        }
    }
}

/// An [`AnalysisResult`] taken apart.
#[derive(Debug)]
pub struct AnalysisParts {
    pub outputs: Result<SymbolicOutputs, OutputsUnavailable>,
    pub graph: EventGraph,
    pub stats: Stats,
    pub op_counts: BTreeMap<&'static str, u64>,
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

/// Lower one kernel and run one candidate execution of CTA (0,0,0) under `config`.
pub fn analyze(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<AnalysisResult, AnalysisError> {
    let func = find_kernel(module, kernel)?;
    let vars = module_vars(module);
    let program = lower_function(func, &vars)?;
    info!(
        "analyzing kernel {:?}: block={:?} grid={:?}",
        kernel, config.block_dim, config.grid_dim
    );
    let provenance = provenance(module, func, &config, &program);
    analyze_lowered(&program, config, provenance).map_err(AnalysisError::from)
}

/// Run one candidate execution of an already-lowered program. The caller supplies
/// well-formed IR that preserves the source semantics, a `provenance` describing this
/// program and `config`, and a symbol table whose `finalize_shared_layout` has run.
pub fn analyze_lowered(
    program: &LoweredProgram,
    config: AnalysisConfig,
    provenance: Provenance,
) -> Result<AnalysisResult, EvalError> {
    let mut interp = Interpreter::new(program, config, provenance)?;
    let end = interp.run();
    Ok(AnalysisResult::from_run(interp.finish(end)))
}

/// The launch, target and modeling assumptions this analysis executes under.
fn provenance(
    module: &Module,
    func: &Function,
    config: &AnalysisConfig,
    program: &LoweredProgram,
) -> Provenance {
    let assumptions = vec![
        Assumption::StructuredCta,
        Assumption::SingleCtaAnalyzed,
        Assumption::SingleCtaCluster,
        Assumption::NeverStealClusterLaunchControl,
        Assumption::ExitedThreadsArrive,
        Assumption::EagerAsyncData,
    ];
    let instructions = program
        .instructions
        .iter()
        .map(|(id, instr)| InstructionInfo {
            kind: instr.kind_name(),
            span: program
                .source_map
                .instruction_span(id)
                .map(|span| (span.0, span.1)),
        })
        .collect();
    Provenance {
        kernel: func.name.to_string(),
        block_dim: config.block_dim,
        grid_dim: config.grid_dim,
        targets: module
            .target
            .archs
            .iter()
            .map(|a| format!("{:?}", a))
            .collect(),
        assumptions,
        instructions,
    }
}

/// Write a per-instruction-kind execution profile (`AnalysisResult::op_counts`),
/// most-executed first.
pub fn write_op_counts(
    out: &mut dyn std::io::Write,
    label: &str,
    counts: &BTreeMap<&'static str, u64>,
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
