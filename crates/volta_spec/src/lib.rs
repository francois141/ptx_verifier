//! Specs: parses `.spec` source (`dim`/`array` declarations plus
//! `NAME[vars] = expr;` equations) via [`parse::parse_spec`],
//! [`instantiate::instantiate`] resolves dims into the mathematical form (`spec`),
//! and [`spec::unfold`] expands it into `volta_expr` expressions;
//! [`extract_expressions_from_spec`] runs all three.

use std::collections::HashMap;
use std::fmt;

use volta_expr::SymbolicOutputs;

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

/// Why a spec's source could not be turned into expressions, by stage.
#[derive(Debug)]
pub enum ExtractError {
    Parse(ParseError),
    Instantiate(InstantiateErrorKind),
    Unfold(SpecError),
}

impl fmt::Display for ExtractError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Parse(e) => write!(f, "parse error: {}", e.error),
            Self::Instantiate(e) => write!(f, "{e}"),
            Self::Unfold(e) => write!(f, "{e}"),
        }
    }
}

impl std::error::Error for ExtractError {}

/// Every output element of the spec `source` as a Volta expression, with each dim set from
/// `dims` (dim name -> value).
pub fn extract_expressions_from_spec(
    source: &str,
    dims: &HashMap<String, u64>,
) -> Result<SymbolicOutputs, ExtractError> {
    let parsed = parse_spec(source).map_err(ExtractError::Parse)?;
    let (env, specs) = instantiate(&parsed, dims).map_err(ExtractError::Instantiate)?;
    unfold(&specs, &env, 0).map_err(ExtractError::Unfold)
}
