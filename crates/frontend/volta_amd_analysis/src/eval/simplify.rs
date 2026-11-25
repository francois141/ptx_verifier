//! Predicate operations that fold a concrete operand, a repeated operand and a complement at
//! once. The full arena's constructors fold nothing, so without this a lane mask combined with a
//! known one would wrap its comparison in a new node, and an if/else's EXEC would not return.

use volta_expr::symbolic_full::{ExprArena, ExprId, ExprNode, Type};

pub(super) fn not(arena: &mut ExprArena, a: ExprId) -> ExprId {
    if let ExprNode::Not(inner) = *arena.node(a) {
        return inner;
    }
    match arena.as_bool(a) {
        Some(a) => arena.bool_val(!a),
        None => arena.not(Type::Pred, a),
    }
}

pub(super) fn and(arena: &mut ExprArena, a: ExprId, b: ExprId) -> ExprId {
    match (arena.as_bool(a), arena.as_bool(b)) {
        (Some(false), _) | (_, Some(true)) => a,
        (_, Some(false)) | (Some(true), _) => b,
        _ if same(arena, a, b) => a,
        _ if complements(arena, a, b) => arena.bool_val(false),
        (None, None) => arena.and(Type::Pred, a, b),
    }
}

pub(super) fn or(arena: &mut ExprArena, a: ExprId, b: ExprId) -> ExprId {
    match (arena.as_bool(a), arena.as_bool(b)) {
        (Some(true), _) | (_, Some(false)) => a,
        (_, Some(true)) | (Some(false), _) => b,
        _ if same(arena, a, b) => a,
        _ if complements(arena, a, b) => arena.bool_val(true),
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
        _ if same(arena, a, b) => arena.bool_val(false),
        _ if complements(arena, a, b) => arena.bool_val(true),
        (None, None) => arena.ne(Type::Pred, a, b),
    }
}

/// Whether `a` and `b` are one predicate: the same node, or negations of one.
pub(super) fn same(arena: &ExprArena, a: ExprId, b: ExprId) -> bool {
    match (arena.node(a), arena.node(b)) {
        _ if a == b => true,
        (ExprNode::Not(x), ExprNode::Not(y)) => same(arena, *x, *y),
        _ => false,
    }
}

/// Whether one of `a` and `b` negates the other.
pub(super) fn complements(arena: &ExprArena, a: ExprId, b: ExprId) -> bool {
    let negates =
        |n: ExprId, p: ExprId| matches!(arena.node(n), ExprNode::Not(x) if same(arena, *x, p));
    negates(a, b) || negates(b, a)
}
