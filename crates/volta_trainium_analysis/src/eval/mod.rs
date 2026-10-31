//! Symbolic execution of NKI instructions.

mod error;
mod interp;
mod tensor;

pub use error::EvalError;
pub use interp::evaluate;
