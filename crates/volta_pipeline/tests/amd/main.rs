//! AMD kernels end to end, one module per suite, over the kernels in this directory's
//! outcome folders (`success/`, `execution_error/`).

#[macro_use]
#[path = "../common/mod.rs"]
mod common;

mod accepted_tests;
mod equivalence_tests;
mod graph_tests;
mod grid_tests;
mod lean_tests;
mod rejected_tests;
