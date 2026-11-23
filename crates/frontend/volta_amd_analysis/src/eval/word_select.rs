//! Word selects: a select between two words under a symbolic condition, each branch a concrete
//! word or another word select. Every lane's bits are known, but only the instruction reading
//! them says whether they are a float or an integer, so readers handle them branch by branch.

use volta_expr::symbolic_full::{ExprArena, ExprId, ExprNode, Type, Width};

use super::EvalError;

const B32: Type = Type::Bits(Width(32));

/// The condition and branches of a word select.
pub(super) fn word_select(arena: &ExprArena, value: ExprId) -> Option<(ExprId, ExprId, ExprId)> {
    let ExprNode::Select(condition, then, otherwise) = *arena.value_node(value) else {
        return None;
    };
    (is_word(arena, then) && is_word(arena, otherwise)).then_some((condition, then, otherwise))
}

/// Whether `value` holds known bits: a concrete word or a word select, never a symbolic real.
pub(super) fn is_word(arena: &ExprArena, value: ExprId) -> bool {
    arena.as_int_const(value).is_some() || word_select(arena, value).is_some()
}

/// `condition ? b : a` for two words: the word when both are the same concrete word, else a
/// word select. `None` unless both are words.
pub(super) fn select_words(
    arena: &mut ExprArena,
    condition: ExprId,
    a: ExprId,
    b: ExprId,
) -> Option<ExprId> {
    if !is_word(arena, a) || !is_word(arena, b) {
        return None;
    }
    if let (Some(x), Some(y)) = (arena.as_int_const(a), arena.as_int_const(b))
        && x == y
    {
        return Some(a);
    }
    Some(arena.select(B32, condition, b, a))
}

/// `op` with a word select operand as the select of `op` over its branches, so the selected
/// words keep their bits: a sign-bit `xor` of `c ? 1.0 : 2.0` is `c ? -1.0 : -2.0`. `None`
/// when neither operand is a word select.
pub(super) fn distribute(
    arena: &mut ExprArena,
    a: ExprId,
    b: ExprId,
    mut op: impl FnMut(&mut ExprArena, ExprId, ExprId) -> Result<ExprId, EvalError>,
) -> Option<Result<ExprId, EvalError>> {
    let (condition, [(a0, b0), (a1, b1)]) = match (word_select(arena, a), word_select(arena, b)) {
        (Some((condition, then, otherwise)), _) => (condition, [(then, b), (otherwise, b)]),
        (None, Some((condition, then, otherwise))) => (condition, [(a, then), (a, otherwise)]),
        (None, None) => return None,
    };
    Some(op(arena, a0, b0).and_then(|then| {
        let otherwise = op(arena, a1, b1)?;
        Ok(arena.select(B32, condition, then, otherwise))
    }))
}
