//! Predicate operations that fold a concrete operand at once. The full arena's constructors
//! fold nothing, so without this a lane mask combined with a known one would wrap the comparison
//! it holds in a new node, and the selects that read the mask would no longer recognize it.

use volta_expr::symbolic_full::{ExprArena, ExprId, Type};

pub(super) fn not(arena: &mut ExprArena, a: ExprId) -> ExprId {
    match arena.as_bool(a) {
        Some(a) => arena.bool_val(!a),
        None => arena.not(Type::Pred, a),
    }
}

pub(super) fn and(arena: &mut ExprArena, a: ExprId, b: ExprId) -> ExprId {
    match (arena.as_bool(a), arena.as_bool(b)) {
        (Some(false), _) | (_, Some(true)) => a,
        (_, Some(false)) | (Some(true), _) => b,
        (None, None) => arena.and(Type::Pred, a, b),
    }
}

pub(super) fn or(arena: &mut ExprArena, a: ExprId, b: ExprId) -> ExprId {
    match (arena.as_bool(a), arena.as_bool(b)) {
        (Some(true), _) | (_, Some(false)) => a,
        (_, Some(true)) | (Some(false), _) => b,
        (None, None) => arena.or(Type::Pred, a, b),
    }
}

/// Boolean xor, built as inequality.
pub(super) fn xor(arena: &mut ExprArena, a: ExprId, b: ExprId) -> ExprId {
    match (arena.as_bool(a), arena.as_bool(b)) {
        (Some(false), _) => b,
        (_, Some(false)) => a,
        (Some(true), _) => not(arena, b),
        (_, Some(true)) => not(arena, a),
        (None, None) => arena.ne(Type::Pred, a, b),
    }
}
