//! The lowered kernel between lowering and execution: a set of tensors, each
//! with its memory and shape, and the instructions over them.

mod activation;
mod arith;
mod instr;
mod kernel;
mod tensor;

pub use activation::ActivationFunc;
pub use arith::ArithOp;
pub use instr::{InstrId, LoweredInstr};
pub use kernel::LoweredKernel;
pub use tensor::{Index, Memory, Shape, Tensor, TensorId};
