//! LLVM's denormal guard of an approximate `exp`, `c ? K * exp(u + d) : exp(u)`, into `exp(u)`:
//! with f32 denormals kept, `v_exp_f32` would flush a tiny result, so past a bound clang shifts
//! the argument by `d` (64) and scales the result back by `K`, `e^{-d}` rounded to f32.

use rug::Rational;

use super::node::scaled_node;
use super::patterns::Matcher;
use crate::{ExprArena, ExprId, ExprNode};

/// How far `K * e^d` may sit from 1: `K` is `e^{-d}` rounded to f32.
const RELATIVE_TOLERANCE: f64 = 1e-6;

/// The guarded exponential, `exp(scale * y)`.
pub(super) struct GuardedExp {
    y: ExprId,
    scale: Rational,
}

impl GuardedExp {
    pub(super) fn build(self, arena: &mut ExprArena) -> ExprId {
        let argument = scaled_node(arena, &self.scale, self.y);

        arena.exp(argument)
    }
}

/// Which branch of a select holds the guard's rescaled piece.
#[derive(Clone, Copy)]
enum Side {
    Then,
    Otherwise,
}

impl Side {
    /// The branch on this side, then the other one.
    fn pick(self, then: ExprId, otherwise: ExprId) -> (ExprId, ExprId) {
        match self {
            Side::Then => (then, otherwise),
            Side::Otherwise => (otherwise, then),
        }
    }
}

/// `scale * base + offset`.
struct Affine {
    scale: Rational,
    base: ExprId,
    offset: Rational,
}

impl Affine {
    fn plus(self, k: Rational) -> Self {
        Affine {
            offset: self.offset + k,
            ..self
        }
    }

    fn negated(self) -> Self {
        Affine {
            scale: -self.scale,
            base: self.base,
            offset: -self.offset,
        }
    }
}

/// `id` as the guard, its rescaled piece in either branch.
pub(super) fn denormal_exp(arena: &ExprArena, id: ExprId) -> Option<GuardedExp> {
    let m = Matcher::new(arena);

    let ExprNode::Select(condition, then, otherwise) = *m.node(id) else {
        return None;
    };

    guarded(m, condition, then, otherwise, Side::Then)
        .or_else(|| guarded(m, condition, then, otherwise, Side::Otherwise))
}

/// The select `condition ? then : otherwise` as the guard, its rescaled piece on `side`:
/// `K * exp(e)` there and `exp(e)` on the other side, where `e` is a multiple of a select on
/// the same condition of `s * y + d` (on `side`) and `s * y`.
fn guarded(
    m: Matcher,
    condition: ExprId,
    then: ExprId,
    otherwise: ExprId,
    side: Side,
) -> Option<GuardedExp> {
    let (rescaled, plain) = side.pick(then, otherwise);

    let (k, rescaled_exp) = m.scaled(rescaled);
    let argument = exp_argument(m, rescaled_exp)?;
    let plain_argument = exp_argument(m, plain)?;

    if !m.same(argument, plain_argument) {
        return None;
    }

    let (outer, inner) = signed_scaled(m, argument);

    let ExprNode::Select(inner_condition, inner_then, inner_otherwise) = *m.node(inner) else {
        return None;
    };

    if !m.same(inner_condition, condition) {
        return None;
    }

    let (shifted, unshifted) = side.pick(inner_then, inner_otherwise);
    let shifted = affine(m, shifted);
    let unshifted = affine(m, unshifted);

    let same_line = m.same(shifted.base, unshifted.base) && shifted.scale == unshifted.scale;
    let shifted_on_side_only = shifted.offset != 0 && unshifted.offset == 0;

    if !same_line || !shifted_on_side_only {
        return None;
    }

    let shift = outer.clone() * shifted.offset;

    if !undoes_shift(&k, &shift) {
        return None;
    }

    Some(GuardedExp {
        y: unshifted.base,
        scale: outer * unshifted.scale,
    })
}

/// The argument `e` of `exp(e)`.
fn exp_argument(m: Matcher, id: ExprId) -> Option<ExprId> {
    match *m.node(id) {
        ExprNode::Exp(argument) => Some(argument),
        _ => None,
    }
}

/// `id` as `s * rest`, as [`Matcher::scaled`] reads it, a `neg` counting -1.
fn signed_scaled(m: Matcher, id: ExprId) -> (Rational, ExprId) {
    let (scale, rest) = m.scaled(id);

    match *m.node(rest) {
        ExprNode::Neg(inner) => {
            let (inner_scale, rest) = signed_scaled(m, inner);
            (-scale * inner_scale, rest)
        }
        _ => (scale, rest),
    }
}

/// `id` as `s * base + d`: constants added or subtracted atop a signed multiple.
fn affine(m: Matcher, id: ExprId) -> Affine {
    match *m.node(id) {
        ExprNode::Add(a, b) => {
            if let Some(k) = m.constant(a) {
                return affine(m, b).plus(k);
            }
            if let Some(k) = m.constant(b) {
                return affine(m, a).plus(k);
            }
        }

        ExprNode::Sub(a, b) => {
            if let Some(k) = m.constant(b) {
                return affine(m, a).plus(-k);
            }
            if let Some(k) = m.constant(a) {
                return affine(m, b).negated().plus(k);
            }
        }

        _ => {}
    }

    let (scale, base) = signed_scaled(m, id);

    Affine {
        scale,
        base,
        offset: Rational::new(),
    }
}

/// Whether multiplying by `k` undoes adding `shift` to an exponent: `k * e^shift` is 1 within
/// `RELATIVE_TOLERANCE`.
fn undoes_shift(k: &Rational, shift: &Rational) -> bool {
    let k = k.to_f64();

    k > 0.0 && (k.ln() + shift.to_f64()).abs() <= RELATIVE_TOLERANCE
}
