//! The analysis stage: one execution of a selected workgroup of one kernel, and how it ended.

use std::fmt;

use volta_expr::{ExprArena, SymbolicOutputs};
use volta_graph::{
    AbortCause, Assumption, EventGraph, InstructionInfo, ProgramPoint, Provenance, ThreadIx,
    ThreadUnit,
};

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
    /// The execution's event graph, one thread per wave: its LDS accesses as DS operations that
    /// `s_waitcnt lgkmcnt` completes, its `s_barrier` generations and its exits. Global memory
    /// accesses are not recorded.
    pub graph: EventGraph,
    /// An aborted run's arena, which `symbolic_outputs` holds for a completed one.
    aborted_arena: Option<ExprArena>,
}

impl AnalysisResult {
    /// The arena holding the graph's stored values.
    pub fn arena(&self) -> &ExprArena {
        match (&self.symbolic_outputs, &self.aborted_arena) {
            (Some(outputs), _) => &outputs.arena,
            (None, Some(arena)) => arena,
            (None, None) => unreachable!("`analyze` keeps the arena of every run"),
        }
    }
}

/// Lower `kernel` and run the selected workgroup under `launch`, with `kernarg` at
/// `launch.kernarg_address` and `arrays` in global memory.
pub fn analyze(
    kernel: &Kernel,
    launch: &WorkgroupLaunch,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> Result<AnalysisResult, AnalysisError> {
    let lowered = lower_kernel(kernel)?;
    let provenance = provenance(kernel, &lowered, launch);
    let mut interp = Interpreter::new(&lowered, launch, kernarg, arrays, provenance)?;
    let terminal = interp.run(&lowered);
    let (graph, outputs) = interp.finish(graph_terminal(&terminal));
    let (symbolic_outputs, aborted_arena) = match terminal {
        Terminal::Completed => (Some(outputs), None),
        Terminal::Aborted { .. } => (None, Some(outputs.arena)),
    };
    Ok(AnalysisResult {
        terminal,
        symbolic_outputs,
        graph,
        aborted_arena,
    })
}

/// How the event graph's trace ends for an execution that ended in `terminal`.
fn graph_terminal(terminal: &Terminal) -> volta_graph::Terminal {
    match terminal {
        Terminal::Completed => volta_graph::Terminal::Completed,
        Terminal::Aborted { wave, pc, error } => volta_graph::Terminal::Aborted {
            thread: Some(ThreadIx(wave.0)),
            pc: Some(ProgramPoint(pc.0)),
            cause: match error {
                EvalError::UnsupportedInstruction => AbortCause::Unsupported,
                _ => AbortCause::Error,
            },
            reason: error.to_string(),
        },
    }
}

/// The launch and target this analysis executes under.
fn provenance(kernel: &Kernel, lowered: &LoweredKernel, launch: &WorkgroupLaunch) -> Provenance {
    let instructions = lowered
        .instructions
        .values()
        .zip(&kernel.spans)
        .map(|(instruction, &span)| InstructionInfo {
            kind: instruction.name(),
            span: Some(span),
        })
        .collect();
    Provenance {
        kernel: lowered.name.clone(),
        block_dim: launch.workgroup_size,
        unit: ThreadUnit::Wave { lanes: 64 },
        grid_dim: launch.grid_size,
        targets: vec![lowered.target.clone()],
        assumptions: vec![
            Assumption::StructuredCta,
            Assumption::SingleWorkgroupAnalyzed {
                id: launch.workgroup_id,
            },
            Assumption::ExitedThreadsArrive,
            Assumption::EagerAsyncData,
            Assumption::SharedMemoryOnly,
        ],
        instructions,
    }
}
