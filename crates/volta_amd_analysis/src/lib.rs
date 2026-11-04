//! AMD kernel analysis for Volta.

pub mod frontend;

mod analysis;
mod error;
mod eval;
mod ir;
mod lower;

pub use analysis::{AnalysisError, AnalysisResult, analyze};
pub use eval::{ArrayDef, ArrayKind, EvalError, OutputType, Terminal, WaveId, WorkgroupLaunch};
pub use ir::{
    Agpr, BinOp, BranchCondition, BufferAddress, BufferImmOffset, CmpOp, CndMaskSrc, GlobalAddress,
    InstrId, LaneMask, LaneReg, LaneRegs, LdsAccesses, LoweredInstr, LoweredKernel, MfmaSrcC,
    ScalarCmpOp, ScalarDst64, ScalarOp32, ScalarOp64, ScalarSrc, ScalarSrc64, Sgpr, Src0,
    TernaryOp, UnaryOp, Vgpr, Vop3Src,
};
pub use lower::{LowerError, lower_kernel};
