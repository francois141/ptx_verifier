//! CUDA's accurate `expf` (libdevice's, without fast math), `ex2(x * (H + L) - n) * 2^n`, into
//! `exp(x)`. Lowering spells `ex2(e)` as `exp(e / f32(log2 e))` and the exponent-bits scale `2^n`
//! as `exp(n * log 2)`; read as powers of two, their exponents add exactly, the clamped `n`
//! cancels, and the split `H + L` of `log2(e)` times ln 2 is 1 within 1e-15.

use rug::Rational;

use super::patterns::Matcher;
use crate::{ExprArena, ExprId, ExprNode};

/// How far `(H + L) * ln 2` may sit from 1 (and the cancelled terms from 0): the split is exact
/// to about 1e-15, while a single f32 rounding of `log2(e)` (1e-8 off) stays unmatched.
const TOLERANCE: f64 = 1e-9;

/// `exp(sign * y)`.
pub(super) struct AccurateExp {
    y: ExprId,
    negated: bool,
}

impl AccurateExp {
    pub(super) fn build(self, arena: &mut ExprArena) -> ExprId {
        let argument = if self.negated {
            arena.neg(self.y)
        } else {
            self.y
        };
        arena.exp(argument)
    }
}

/// `id` as `2^a * 2^b` whose exponents sum to `±y * log2(e)` once every other term cancels.
pub(super) fn accurate_exp(arena: &ExprArena, id: ExprId) -> Option<AccurateExp> {
    let m = Matcher::new(arena);
    let ExprNode::Mul(left, right) = *m.node(id) else {
        return None;
    };
    let (&ExprNode::Exp(a), &ExprNode::Exp(b)) = (m.node(left), m.node(right)) else {
        return None;
    };

    let mut form = Linear::default();
    form.add(m, power_of_two(m, a)?, 1.0)?;
    form.add(m, power_of_two(m, b)?, 1.0)?;

    if form.constant.abs() > TOLERANCE {
        return None;
    }
    let mut significant = form.terms.iter().filter(|(_, c)| c.abs() > TOLERANCE);
    let (y, c) = *significant.next()?;
    if significant.next().is_some() {
        return None;
    }
    let natural = c * std::f64::consts::LN_2;
    let negated = match natural {
        c if (c - 1.0).abs() <= TOLERANCE => false,
        c if (c + 1.0).abs() <= TOLERANCE => true,
        _ => return None,
    };
    Some(AccurateExp { y, negated })
}

/// `e` of an exponential argument `e * s` that is `2^e`: `s` is lowering's `ex2` scale
/// `1 / f32(log2 e)` exactly, or `log 2`.
fn power_of_two(m: Matcher, argument: ExprId) -> Option<ExprId> {
    let ExprNode::Mul(a, b) = *m.node(argument) else {
        return None;
    };
    let ex2_scale = Rational::from((8388608, 12102203));
    let is_log2 = |id: ExprId| matches!(*m.node(id), ExprNode::Log(two) if m.is(two, 2));
    [(a, b), (b, a)].into_iter().find_map(|(e, s)| {
        (m.constant(s).is_some_and(|k| k == ex2_scale) || is_log2(s)).then_some(e)
    })
}

/// A sum of `coefficient * term` plus a constant, terms merged by structural equality.
#[derive(Default)]
struct Linear {
    terms: Vec<(ExprId, f64)>,
    constant: f64,
}

impl Linear {
    /// Add `scale * id`; `None` when a product of two non-constants appears.
    fn add(&mut self, m: Matcher, id: ExprId, scale: f64) -> Option<()> {
        if let Some(k) = constant(m, id) {
            self.constant += scale * k;
            return Some(());
        }
        match *m.node(id) {
            ExprNode::Add(a, b) => {
                self.add(m, a, scale)?;
                self.add(m, b, scale)
            }
            ExprNode::Sub(a, b) => {
                self.add(m, a, scale)?;
                self.add(m, b, -scale)
            }
            ExprNode::Neg(a) => self.add(m, a, -scale),
            ExprNode::Mul(a, b) => match (constant(m, a), constant(m, b)) {
                (Some(k), _) => self.add(m, b, scale * k),
                (_, Some(k)) => self.add(m, a, scale * k),
                (None, None) => None,
            },
            _ => {
                self.term(m, id, scale);
                Some(())
            }
        }
    }

    fn term(&mut self, m: Matcher, id: ExprId, scale: f64) {
        match self.terms.iter_mut().find(|(t, _)| m.same(*t, id)) {
            Some((_, c)) => *c += scale,
            None => self.terms.push((id, scale)),
        }
    }
}

/// `id`'s value when it is a constant: a number, or `log` of a positive one (Volta's `2^n`).
fn constant(m: Matcher, id: ExprId) -> Option<f64> {
    if let Some(q) = m.constant(id) {
        return Some(q.to_f64());
    }
    match *m.node(id) {
        ExprNode::Log(a) => m
            .constant(a)
            .filter(|q| *q > Rational::new())
            .map(|q| q.to_f64().ln()),
        ExprNode::Mul(a, b) => Some(constant(m, a)? * constant(m, b)?),
        ExprNode::Neg(a) => constant(m, a).map(|k| -k),
        _ => None,
    }
}
