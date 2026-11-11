//! Trainium kernel analysis for Volta: NKI kernels, parsed (`frontend`),
//! lowered (`lower`, `ir`) and symbolically executed (`eval`).

pub mod frontend;

mod eval;
mod ir;
mod lower;

pub use eval::{
    Access, EvalError, Location, Mode, OrderingPolicy, PARTITION_STRIDE, evaluate, footprints,
    record_graph,
};
pub use ir::{
    ActivationFunc, ArithOp, Index, Initial, InstrId, LoopId, LoopIteration, LoopKind,
    LoweredInstr, LoweredKernel, Memory, Mover, Origin, Reordering, ScalarOperand, ScalarStep,
    Shape, Tensor, TensorId, TensorRegion,
};
pub use lower::{LowerError, PatternProblem, StatementError, lower_kernel};
