//! The analysis stage: one execution of workgroup 0 of one kernel, and how it ended.

use std::fmt;

use volta_expr::SymbolicOutputs;
use volta_graph::{AbortCause, EventGraph, GraphBuilder, Provenance};

use crate::eval::{ArrayDef, EvalError, Interpreter, Terminal, WorkgroupLaunch};
use crate::frontend::ast::Kernel;
use crate::ir::LoweredKernel;
use crate::lower::{LowerError, lower_kernel};

/// Errors that prevent the execution from starting at all.
#[derive(Debug)]
pub enum AnalysisError {
    Lower(LowerError),
    Eval(EvalError),
}

impl fmt::Display for AnalysisError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Lower(e) => write!(f, "lowering failed: {e}"),
            Self::Eval(e) => write!(f, "{e}"),
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

/// The analysis stage's result.
#[derive(Debug)]
pub struct AnalysisResult {
    pub terminal: Terminal,
    /// Written output values; absent if execution aborted.
    pub symbolic_outputs: Option<SymbolicOutputs>,
    /// The execution's event graph. It records no events yet and ends as the execution did,
    /// so a completed run's graph passes every graph check vacuously.
    pub graph: EventGraph,
}

/// Lower `kernel` and run workgroup 0 under `launch`, with `kernarg` as the argument buffer at
/// `launch.kernarg_address` and `arrays` in global memory.
pub fn analyze(
    kernel: &Kernel,
    launch: &WorkgroupLaunch,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> Result<AnalysisResult, AnalysisError> {
    let lowered = lower_kernel(kernel)?;
    let mut interp = Interpreter::new(&lowered, launch, kernarg, arrays)?;
    let terminal = interp.run(&lowered);
    let symbolic_outputs = (terminal == Terminal::Completed).then(|| interp.into_outputs());
    let graph = GraphBuilder::new(provenance(&lowered, launch)).finish(graph_terminal(&terminal));
    Ok(AnalysisResult {
        terminal,
        symbolic_outputs,
        graph,
    })
}

/// How the event graph's trace ends for an execution that ended in `terminal`.
fn graph_terminal(terminal: &Terminal) -> volta_graph::Terminal {
    match terminal {
        Terminal::Completed => volta_graph::Terminal::Completed,
        Terminal::Aborted { error, .. } => volta_graph::Terminal::Aborted {
            thread: None,
            pc: None,
            cause: match error {
                EvalError::UnsupportedInstruction => AbortCause::Unsupported,
                _ => AbortCause::Error,
            },
            reason: error.to_string(),
        },
    }
}

/// The launch and target this analysis executes under.
fn provenance(kernel: &LoweredKernel, launch: &WorkgroupLaunch) -> Provenance {
    Provenance {
        kernel: kernel.name.clone(),
        block_dim: launch.workgroup_size,
        // Workgroup 0 runs alone, and no supported instruction reads the grid size.
        grid_dim: (1, 1, 1),
        targets: vec![kernel.target.clone()],
        assumptions: Vec::new(),
        instructions: Vec::new(),
    }
}
