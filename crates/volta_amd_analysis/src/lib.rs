//! AMD kernel analysis for Volta.

pub mod frontend;

mod analysis;
mod error;
mod eval;
mod ir;
mod lower;

pub use analysis::{AnalysisError, AnalysisResult, analyze};
pub use eval::{ArrayDef, ArrayKind, EvalError, Terminal, WaveId, WorkgroupLaunch};
pub use ir::{InstrId, LoweredInstr, LoweredKernel, Sgpr, Vgpr};
pub use lower::{LowerError, lower_kernel};
