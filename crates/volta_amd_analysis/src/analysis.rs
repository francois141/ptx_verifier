//! The analysis stage: one execution of workgroup 0 of one kernel, and how it ended.

use std::fmt;

use crate::eval::{EvalError, InputArray, Interpreter, Terminal, WorkgroupLaunch};
use crate::frontend::ast::Kernel;
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
}

/// Lower `kernel` and run workgroup 0 under `launch`, with `kernarg` as the argument buffer at
/// `launch.kernarg_address` and `inputs` in global memory.
pub fn analyze(
    kernel: &Kernel,
    launch: &WorkgroupLaunch,
    kernarg: &[u8],
    inputs: &[InputArray],
) -> Result<AnalysisResult, AnalysisError> {
    let lowered = lower_kernel(kernel)?;
    let mut interp = Interpreter::new(&lowered, launch, kernarg, inputs)?;
    Ok(AnalysisResult {
        terminal: interp.run(&lowered),
    })
}
