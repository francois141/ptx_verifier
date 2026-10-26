//! Specs: parses `.spec` source (`dim`/`array` declarations plus
//! `NAME[vars] = expr;` equations) via [`parse::parse_spec`],
//! [`instantiate::instantiate`] resolves dims into the mathematical form (`spec`),
//! and [`spec::unfold`] expands it into `volta_expr` expressions.

pub mod ast;
pub mod instantiate;
pub mod lex;
pub mod parse;
pub mod spec;

pub use ast::{ArrayDecl, DimDecl, OutputDecl, Padding, ParamDecl, ParsedSpec};
pub use instantiate::{InstantiateErrorKind, instantiate};
pub use parse::{ParseError, ParseErrorKind, parse_spec};
pub use spec::{
    Bound, IndexExpr, OutputSpec, ReduceOp, Shape, SpecEnv, SpecError, SpecExpr, unfold,
};
