//! Volta's expression language: the arena-allocated symbolic expressions
//! (`symbolic`), one run's output footprint (`outputs`) and its text format
//! (`text`).

pub mod outputs;
pub mod symbolic;
pub mod text;

pub use outputs::SymbolicOutputs;
pub use symbolic::*;
