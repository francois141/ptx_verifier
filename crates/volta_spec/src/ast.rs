//! The parsed, not yet instantiated spec: declarations plus output equations,
//! with bodies parsed straight into `volta_expr::spec::{SpecExpr,
//! IndexExpr}`.

use volta_common::Span;
use volta_expr::spec::SpecExpr;

/// A `dim NAME;` declaration: a named integer bound, resolved to a
/// concrete `u64` at instantiation time (e.g. `--dim K=4096`).
#[derive(Debug, Clone)]
pub struct DimDecl {
    pub name: String,
    pub span: Span,
}

/// An `array NAME[dim, ...];` declaration: an array's shape, given as a
/// list of named dims (resolved to a concrete `Shape` at instantiation).
#[derive(Debug, Clone)]
pub struct ArrayDecl {
    pub name: String,
    pub dims: Vec<String>,
    pub span: Span,
}

/// A `NAME[var, ...] = expr;` output equation; `vars` are the loop variables
/// over `NAME`'s shape, in order (arity checked by `unfold`'s
/// `SpecError::ShapeVarMismatch`).
#[derive(Debug, Clone)]
pub struct OutputDecl {
    pub array: String,
    pub vars: Vec<String>,
    pub body: SpecExpr,
    pub span: Span,
}

/// A parsed spec file, still over named dims;
/// [`crate::instantiate::instantiate`] turns it into the `(SpecEnv,
/// Vec<OutputSpec>)` pair `unfold` needs.
#[derive(Debug, Clone, Default)]
pub struct ParsedSpec {
    pub dims: Vec<DimDecl>,
    pub arrays: Vec<ArrayDecl>,
    pub outputs: Vec<OutputDecl>,
}
