//! Symbolic expressions for abstract interpretation, over the mathematical reals (the paper
//! treats floating-point values as reals for equivalence checking). Nodes live in an
//! `ExprArena` and are referred to by lightweight, copyable `ExprId` handles.

mod build;
mod display;
mod node;
pub mod text;

pub use node::*;
