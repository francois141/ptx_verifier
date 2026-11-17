//! Builders of the constant nodes a rewrite's replacement needs.

use rug::Rational;

use crate::{ExprArena, ExprId, Real};

/// `q` as a node: an integer constant when it is one, else a real.
pub(super) fn constant_node(arena: &mut ExprArena, q: &Rational) -> ExprId {
    match q.is_integer().then(|| q.numer().to_i64()).flatten() {
        Some(i) => arena.int(i),
        None => arena.real(Real::from_rational(q.clone())),
    }
}

/// `c * e`, or `e` itself when `c` is 1.
pub(super) fn scaled_node(arena: &mut ExprArena, c: &Rational, e: ExprId) -> ExprId {
    if *c == 1 {
        return e;
    }
    let c = constant_node(arena, c);
    arena.mul(c, e)
}
