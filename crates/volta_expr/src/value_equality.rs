//! The race detector's hook for recognizing a benign same-value store,
//! implemented outside the interpreter (`volta_equivalence::CanonValueEquality`).

use crate::symbolic::{ExprArena, ExprId};

/// Decides whether two expressions of one arena denote the same real, beyond
/// the id and structural equality the interpreter checks itself. Injected by
/// the caller so the decision procedure can live in another crate.
pub trait ValueEquality {
    fn same_value(&self, arena: &ExprArena, a: ExprId, b: ExprId) -> bool;
}
