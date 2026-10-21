//! A same-value query over one arena, implemented outside this crate
//! (`volta_equivalence::CanonValueEquality`). The graph checks do not use it: the
//! memory-conflict check has no benign same-value store exception.

use crate::symbolic::{ExprArena, ExprId};

/// Decides whether two expressions of one arena denote the same real, beyond
/// the id and structural equality the interpreter checks itself. Injected by
/// the caller so the decision procedure can live in another crate.
pub trait ValueEquality {
    fn same_value(&self, arena: &ExprArena, a: ExprId, b: ExprId) -> bool;
}
