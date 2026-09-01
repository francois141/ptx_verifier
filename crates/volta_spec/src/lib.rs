//! Textual spec language: parses `.spec` source (`dim`/`array`
//! declarations plus `NAME[vars] = expr;` output equations, e.g. matmul's
//! `C[i,j] = sum(k in 0..K, A[i,k] * B[k,j]);`) into the AST
//! `volta_analysis::spec::unfold` consumes.
//!
//! Two-stage, mirroring PTX's own lex/parse-then-lower split in this
//! codebase: [`parse::parse_spec`] turns source text into a
//! [`ast::ParsedSpec`] (declarations plus `SpecExpr` bodies, everything
//! still in terms of named dims); [`instantiate::instantiate`] then
//! resolves those names against a caller-supplied `dim -> u64` map into
//! the concrete `(SpecEnv, Vec<OutputSpec>)` pair ready for `unfold`. The
//! same parsed spec is reusable across dim values without re-parsing.

pub mod ast;
pub mod instantiate;
pub mod lex;
pub mod parse;

pub use ast::{ArrayDecl, DimDecl, OutputDecl, ParsedSpec};
pub use instantiate::{InstantiateErrorKind, instantiate};
pub use parse::{ParseError, ParseErrorKind, parse_spec};
