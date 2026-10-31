//! NKI source parsing: Python tokens (`lex`), the Python subset's syntax tree
//! (`python`), and its reading as tensors and instructions (`parse`, `ast`).

pub mod ast;
pub mod error;
mod lex;
pub mod parse;
mod python;
