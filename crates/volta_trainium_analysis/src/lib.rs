//! Trainium kernel analysis for Volta: NKI kernels, parsed (`frontend`),
//! lowered (`lower`, `ir`) and symbolically executed (`eval`).

pub mod frontend;

mod eval;
mod ir;
mod lower;

pub use eval::{EvalError, evaluate};
pub use ir::{
    ActivationFunc, ArithOp, Index, InstrId, LoweredInstr, LoweredKernel, Memory, ScalarOperand,
    ScalarStep, Shape, Tensor, TensorId, TensorRegion,
};
pub use lower::{LowerError, StatementError, lower_kernel};
