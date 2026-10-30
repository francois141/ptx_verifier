//! AMD kernel analysis for Volta.

pub mod frontend;

mod error;
mod eval;
mod ir;
mod lower;

pub use ir::{LoweredInstr, LoweredKernel, Sgpr, Vgpr};
pub use lower::{LowerError, lower_kernel};
