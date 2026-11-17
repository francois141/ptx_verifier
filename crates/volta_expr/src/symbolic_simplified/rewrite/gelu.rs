//! PyTorch's tanh approximation of GELU (`torch.nn.GELU(approximate='tanh')`),
//! `0.5*x*(1 + tanh(sqrt(2/pi)*(x + 0.044715*x^3)))`, as one [`ExprNode::Gelu`] node. A kernel
//! spells the constants rounded, so the rewrite equates reals within `RELATIVE_TOLERANCE`.

use rug::Rational;
use volta_common::commutative::either;

use super::patterns::Matcher;
use crate::{ExprArena, ExprId, ExprNode};

const SQRT_2_OVER_PI: f64 = 0.797_884_560_802_865_4;
const CUBIC_COEFFICIENT: f64 = 0.044_715;

/// How far a kernel's constants may sit from PyTorch's: f32 rounding, products folded by hand.
const RELATIVE_TOLERANCE: f64 = 1e-5;

/// `x*0.5 * (tanh(w) + 1)` or `x*0.5 * tanh(w) + x*0.5`, with `tanh` in the
/// `(e^{2w} - 1) / (e^{2w} + 1)` form the analyses build and `2w = s * (x + k*x^3)`, `s/2`
/// and `k` PyTorch's coefficients up to rounding: `Gelu(x)`. Returns that `x`.
pub fn torch_gelu(arena: &ExprArena, id: ExprId) -> Option<ExprId> {
    let m = Matcher::new(arena);

    let (half_x, exponent) = match *m.node(id) {
        ExprNode::Mul(a, b) => either(a, b, |half_x, sum| Some((half_x, one_plus_tanh(m, sum)?)))?,
        ExprNode::Add(a, b) => either(a, b, |product, c| {
            let ExprNode::Mul(p, q) = *m.node(product) else {
                return None;
            };
            either(p, q, |half_x, t| {
                m.same(half_x, c).then_some((half_x, m.tanh(t)?))
            })
        })?,
        _ => return None,
    };

    let x = m.halved(half_x)?;
    let (scale, inner) = m.scaled(exponent);
    let cubic = m.cubic(inner, x)?;

    (near(scale / 2u32, SQRT_2_OVER_PI) && near(cubic, CUBIC_COEFFICIENT)).then_some(x)
}

fn near(value: Rational, target: f64) -> bool {
    ((value.to_f64() - target) / target).abs() <= RELATIVE_TOLERANCE
}

/// The exponent `2w` of `tanh(w) + 1`.
fn one_plus_tanh(m: Matcher, id: ExprId) -> Option<ExprId> {
    let ExprNode::Add(a, b) = *m.node(id) else {
        return None;
    };

    either(a, b, |t, one| m.tanh(t).filter(|_| m.is(one, 1)))
}
