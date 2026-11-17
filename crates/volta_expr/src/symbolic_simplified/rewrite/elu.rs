//! PyTorch's ELU family as its `elu_kernel` computes it, `x > 0 ? scale * x : coefficient *
//! (exp(input_scale * x) - 1)` with `coefficient = alpha * scale`, into
//! `scale * max(x, 0) + coefficient * (exp(input_scale * min(x, 0)) - 1)`, the form a spec states
//! with `max` and `min`. Both pieces are 0 at 0, so the two agree everywhere. ELU, CELU
//! (`input_scale = 1 / alpha`) and SELU (its `alpha` and `scale`) each compile to this select.

use rug::Rational;

use super::patterns::{Matcher, constant_node, scaled_node};
use crate::{ExprArena, ExprId, ExprNode};

/// `scale * max(x, 0) + coefficient * (exp(input_scale * min(x, 0)) - 1)`.
pub(super) struct Elu {
    x: ExprId,
    scale: Rational,
    coefficient: Rational,
    input_scale: Rational,
}

/// `id` as ELU's select: a multiple of `x` above 0, a multiple of `exp(k * x) - 1` below.
pub(super) fn elu(arena: &ExprArena, id: ExprId) -> Option<Elu> {
    let m = Matcher::new(arena);
    let split = m.split(id)?;
    if split.threshold != 0 {
        return None;
    }

    let above = m.monomial(split.above, split.x)?;
    let (coefficient, expm1) = m.scaled(split.below);
    let argument = exp_minus_one(m, expm1)?;
    let input = m.monomial(argument, split.x)?;

    (above.degree == 1 && input.degree == 1).then_some(Elu {
        x: split.x,
        scale: above.coefficient,
        coefficient,
        input_scale: input.coefficient,
    })
}

/// The argument `a` of `exp(a) - 1`, an `add` of `-1` or a `sub` of 1.
fn exp_minus_one(m: Matcher, id: ExprId) -> Option<ExprId> {
    let exp = match *m.node(id) {
        ExprNode::Add(a, b) if m.is(a, -1) => b,
        ExprNode::Add(a, b) if m.is(b, -1) => a,
        ExprNode::Sub(a, b) if m.is(b, 1) => a,
        _ => return None,
    };

    match *m.node(exp) {
        ExprNode::Exp(argument) => Some(argument),
        _ => None,
    }
}

impl Elu {
    pub(super) fn build(self, arena: &mut ExprArena) -> ExprId {
        let zero = arena.int(0);
        let positive = arena.max(self.x, zero);
        let positive = scaled_node(arena, &self.scale, positive);

        let negative = arena.min(self.x, zero);
        let argument = scaled_node(arena, &self.input_scale, negative);
        let exp = arena.exp(argument);
        let one = constant_node(arena, &Rational::from(1));
        let expm1 = arena.sub(exp, one);
        let negative = scaled_node(arena, &self.coefficient, expm1);

        arena.add(positive, negative)
    }
}
