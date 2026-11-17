//! NKI source parsing: Python tokens (`lex`), the Python subset's syntax tree
//! (`python`), and its reading as tensors and instructions (`parse`, `ast`); or a
//! kernel call traced under CPython (`trace`), into the same `ast`.

pub mod ast;
pub mod error;
mod lex;
pub mod parse;
mod python;
pub mod trace;
