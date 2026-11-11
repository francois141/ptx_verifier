//! The lowered kernel between lowering and execution: a set of tensors, each
//! with its memory and shape, and the instructions over them.

mod activation;
mod arith;
mod instr;
mod kernel;
mod scalar;
mod tensor;

pub use activation::ActivationFunc;
pub use arith::ArithOp;
pub use instr::{Accumulation, InstrId, LoweredInstr, Order, Reduction, Sign};
pub use kernel::LoweredKernel;
pub use scalar::{ScalarOperand, ScalarStep};
pub use tensor::{
    Address, Index, Initial, Layout, Memory, Selection, Shape, Tensor, TensorId, TensorRegion,
};
