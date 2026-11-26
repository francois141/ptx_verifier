//! PyTorch's tanh approximation of GELU (`torch.nn.GELU(approximate='tanh')`),
//! `0.5*x*(1 + tanh(sqrt(2/pi)*(x + 0.044715*x^3)))`, as one [`ExprNode::Gelu`] node, from the
//! arrangements kernels compile it to: PyTorch's `x*0.5 * (tanh(w) + 1)` and `x*0.5*tanh(w) +
//! x*0.5`, CUTLASS's `GELU_taylor` `0.5 * (x*tanh(w) + x)`, and the sigmoid form `x / (1 + e^{-2w})`
//! of CK's `FastGelu`. A kernel spells the constants rounded, so the rewrite equates reals within
//! `RELATIVE_TOLERANCE`.

use rug::Rational;
use volta_common::commutative::either;

use super::patterns::Matcher;
use crate::{ExprArena, ExprId, ExprNode};

const SQRT_2_OVER_PI: f64 = 0.797_884_560_802_865_4;
const CUBIC_COEFFICIENT: f64 = 0.044_715;

/// How far a kernel's constants may sit from PyTorch's: f32 rounding, products folded by hand
/// (CK's FastGelu writes 0.797885 * 0.044715 as 0.035677, 1.2e-5 off).
const RELATIVE_TOLERANCE: f64 = 2e-5;

/// One of the forms of `0.5*x*(1 + tanh(w))` above, with `2w = s * (x + k*x^3)`, `s/2` and `k`
/// PyTorch's coefficients up to rounding, as `Gelu(x)`. Returns that `x`.
pub fn torch_gelu(arena: &ExprArena, id: ExprId) -> Option<ExprId> {
    let m = Matcher::new(arena);

    let (x, exponent, sign) = tanh_form(m, id).or_else(|| sigmoid_form(m, id))?;
    let (scale, inner) = m.scaled(exponent);
    let (factor, cubic) = m.cubic(inner, x)?;
    let scale = scale * factor * sign;

    (near(scale / 2u32, SQRT_2_OVER_PI) && near(cubic, CUBIC_COEFFICIENT)).then_some(x)
}

fn near(value: Rational, target: f64) -> bool {
    ((value.to_f64() - target) / target).abs() <= RELATIVE_TOLERANCE
}

/// `x` and the exponent `2w` of `0.5*x*(1 + tanh(w))` written with a `tanh`: `x*0.5 * (tanh(w) +
/// 1)`, `x*0.5 * tanh(w) + x*0.5` or `0.5 * (x*tanh(w) + x)`; the sign is 1.
fn tanh_form(m: Matcher, id: ExprId) -> Option<(ExprId, ExprId, i32)> {
    let (x, exponent) = match *m.node(id) {
        ExprNode::Mul(a, b) => either(a, b, |p, q| {
            if let Some(exponent) = one_plus_tanh(m, q) {
                return Some((m.halved(p)?, exponent));
            }
            m.is(p, (1, 2)).then(|| x_tanh_plus_x(m, q)).flatten()
        })?,
        ExprNode::Add(a, b) => either(a, b, |product, c| {
            let ExprNode::Mul(p, q) = *m.node(product) else {
                return None;
            };
            either(p, q, |half_x, t| {
                m.same(half_x, c).then_some((m.halved(half_x)?, m.tanh(t)?))
            })
        })?,
        _ => return None,
    };
    Some((x, exponent, 1))
}

/// `x` and the exponent `u` of `x / (1 + e^u)` or `x * (1 / (1 + e^u))`, which is
/// `0.5*x*(1 + tanh(w))` for `u = -2w`; the sign is -1.
fn sigmoid_form(m: Matcher, id: ExprId) -> Option<(ExprId, ExprId, i32)> {
    let (x, denominator) = match *m.node(id) {
        ExprNode::Div(x, denominator) => (x, denominator),
        ExprNode::Mul(a, b) => either(a, b, |x, reciprocal| match *m.node(reciprocal) {
            ExprNode::Div(one, denominator) if m.is(one, 1) => Some((x, denominator)),
            _ => None,
        })?,
        _ => return None,
    };
    let ExprNode::Add(a, b) = *m.node(denominator) else {
        return None;
    };
    let exponent = either(a, b, |one, e| match *m.node(e) {
        ExprNode::Exp(exponent) if m.is(one, 1) => Some(exponent),
        _ => None,
    })?;
    Some((x, exponent, -1))
}

/// The exponent `2w` of `tanh(w) + 1`.
fn one_plus_tanh(m: Matcher, id: ExprId) -> Option<ExprId> {
    let ExprNode::Add(a, b) = *m.node(id) else {
        return None;
    };

    either(a, b, |t, one| m.tanh(t).filter(|_| m.is(one, 1)))
}

/// `x` and the exponent `2w` of `x*tanh(w) + x`.
fn x_tanh_plus_x(m: Matcher, id: ExprId) -> Option<(ExprId, ExprId)> {
    let ExprNode::Add(a, b) = *m.node(id) else {
        return None;
    };

    either(a, b, |product, x| {
        let ExprNode::Mul(p, q) = *m.node(product) else {
            return None;
        };
        either(p, q, |same_x, t| {
            m.same(same_x, x).then_some((x, m.tanh(t)?))
        })
    })
}
