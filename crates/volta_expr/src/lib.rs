//! Volta's expression language: the arena-allocated symbolic expressions
//! (`symbolic`), one run's output footprint (`outputs`), its text format
//! (`text`), and mathematical specs unfolded into expressions (`spec`).

pub mod outputs;
pub mod spec;
pub mod symbolic;
pub mod text;

pub use outputs::SymbolicOutputs;
pub use symbolic::*;
