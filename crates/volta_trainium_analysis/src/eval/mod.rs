//! Symbolic execution of NKI instructions.

mod alias;
mod error;
mod footprint;
mod interp;
mod tensor;

pub use error::EvalError;
pub use footprint::{Access, Location, Mode, PARTITION_STRIDE, footprints};
pub use interp::evaluate;
