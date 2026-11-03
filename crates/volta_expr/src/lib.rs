//! Volta's expression language: the arena-allocated symbolic expressions
//! (`symbolic`), one run's output footprint (`outputs`) and its text format
//! (`text`), and Lean 4 challenges over two outputs (`lean`).

pub mod lean;
pub mod outputs;
pub mod symbolic;
pub mod text;

pub use outputs::SymbolicOutputs;
pub use symbolic::*;
