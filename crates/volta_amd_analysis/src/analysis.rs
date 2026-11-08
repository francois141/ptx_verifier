//! The analysis stage: one execution of a selected workgroup of one kernel, or of every
//! workgroup of its launch grid at once, and how it ended.

use std::fmt;

use volta_expr::{ExprArena, SymbolicOutputs};
use volta_graph::{
    AbortCause, Assumption, EventGraph, InstructionInfo, ProgramPoint, Provenance, ThreadIx,
    ThreadUnit,
};

use crate::eval::{
    ArrayDef, EvalError, Interpreter, Terminal, WorkgroupLaunch, workgroup_coordinates,
    workgroup_outputs,
};
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
    let mut interp = Interpreter::new(&lowered, launch, kernarg, arrays, provenance, false)?;
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

/// A run of the launch grid with separate values for each workgroup. Instructions reading
/// differing values run once per workgroup. Branch decisions and LDS addresses must agree
/// so one control flow and event graph describe them all; otherwise the run aborts.
#[derive(Debug)]
pub struct GridAnalysis {
    pub terminal: Terminal,
    /// The run's event graph, which every workgroup shares.
    pub graph: EventGraph,
    /// Each workgroup's coordinates and outputs, numbering X fastest; empty if the run aborted.
    pub workgroups: Vec<((u32, u32, u32), SymbolicOutputs)>,
    /// Every output element a later workgroup stores after an earlier one stored it.
    pub conflicts: Vec<StoreConflict>,
    /// The run's arena, which holds the graph's stored values.
    arena: ExprArena,
}

impl GridAnalysis {
    /// The arena holding the graph's stored values.
    pub fn arena(&self) -> &ExprArena {
        &self.arena
    }
}

/// An output element that two workgroups both store.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct StoreConflict {
    pub array: String,
    pub index: u64,
    /// The first workgroup to store the element and a later one that stores it too.
    pub workgroups: [(u32, u32, u32); 2],
}

/// Lower `kernel` and run every workgroup of `launch.grid_size` at once, with `kernarg` at
/// `launch.kernarg_address` and `arrays` in global memory. `launch.workgroup_id` is ignored:
/// workgroup (0, 0, 0) represents the grid in the launch registers and the graph.
pub fn analyze_grid(
    kernel: &Kernel,
    launch: &WorkgroupLaunch,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> Result<GridAnalysis, AnalysisError> {
    let launch = &WorkgroupLaunch {
        workgroup_id: (0, 0, 0),
        ..*launch
    };
    let lowered = lower_kernel(kernel)?;
    let provenance = provenance(kernel, &lowered, launch);
    let mut interp = Interpreter::new(&lowered, launch, kernarg, arrays, provenance, true)?;
    let terminal = interp.run(&lowered);
    let run = interp.finish_grid(graph_terminal(&terminal));

    // Give each workgroup an arena containing its output expressions after execution completes.
    let mut workgroups = Vec::new();
    let mut conflicts = Vec::new();
    if terminal == Terminal::Completed {
        for (index, outputs) in run.outputs.iter().enumerate() {
            let outputs = workgroup_outputs(&run.arena, outputs);
            workgroups.push((workgroup_coordinates(launch.grid_size, index), outputs));
        }
        conflicts = run
            .conflicts
            .iter()
            .map(|conflict| StoreConflict {
                array: conflict.array.clone(),
                index: conflict.index,
                workgroups: conflict
                    .workgroups
                    .map(|index| workgroup_coordinates(launch.grid_size, index)),
            })
            .collect();
    }
    Ok(GridAnalysis {
        terminal,
        graph: run.graph,
        workgroups,
        conflicts,
        arena: run.arena,
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
