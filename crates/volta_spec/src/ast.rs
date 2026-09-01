//! The parsed (but not yet instantiated) spec: `dim`/`array` declarations
//! plus output equations. Expression bodies are parsed directly into
//! `volta_analysis::spec::{SpecExpr, IndexExpr}` - there is no separate
//! expression AST in this crate, since that's exactly the type the parser
//! needs to produce.

use volta_analysis::spec::SpecExpr;
use volta_common::Span;

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

/// A `NAME[var, ...] = expr;` output equation. `vars` names the loop
/// variables bound over `NAME`'s declared shape, in order (so `vars.len()`
/// must equal the matching `ArrayDecl`'s `dims.len()` - checked at
/// instantiation, since `unfold` already validates exactly this via
/// `SpecError::ShapeVarMismatch`, no need to duplicate the check here).
#[derive(Debug, Clone)]
pub struct OutputDecl {
    pub array: String,
    pub vars: Vec<String>,
    pub body: SpecExpr,
    pub span: Span,
}

/// A fully parsed spec file: declarations plus equations, still in terms
/// of named dims - nothing here is concrete yet. See
/// [`crate::instantiate::instantiate`] for turning this into the
/// `(SpecEnv, Vec<OutputSpec>)` pair `volta_analysis::spec::unfold` needs.
#[derive(Debug, Clone, Default)]
pub struct ParsedSpec {
    pub dims: Vec<DimDecl>,
    pub arrays: Vec<ArrayDecl>,
    pub outputs: Vec<OutputDecl>,
}
