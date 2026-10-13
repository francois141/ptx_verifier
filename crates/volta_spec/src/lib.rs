//! Textual spec language: parses `.spec` source (`dim`/`array` declarations
//! plus `NAME[vars] = expr;` equations) via [`parse::parse_spec`], then
//! [`instantiate::instantiate`] resolves dims into the input `spec::unfold` takes.

pub mod ast;
pub mod instantiate;
pub mod lex;
pub mod parse;

pub use ast::{ArrayDecl, DimDecl, OutputDecl, ParamDecl, ParsedSpec};
pub use instantiate::{InstantiateErrorKind, instantiate};
pub use parse::{ParseError, ParseErrorKind, parse_spec};
