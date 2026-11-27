//! CUDA's accurate `expf` (libdevice's, without fast math), `ex2(u * H + u * L - n) * 2^n`, into
//! `exp(u)`. Lowering spells `ex2(e)` as `exp(e / f32(log2 e))` and the exponent-bits scale `2^n`
//! as `exp(n * log 2)`; read as powers of two, their exponents add exactly (exact rationals), the
//! clamped `n` cancels, and every remaining coefficient is `q * (H + L)` for the argument's own
//! constant `q`: `2^(q (H + L) y) = exp(q y)` since `(H + L) ln 2` is 1 within 1e-16.

use rug::Rational;

use super::node::scaled_node;
use super::patterns::Matcher;
use crate::{ExprArena, ExprId, ExprNode};

/// `H + L`, libdevice's split of `log2(e)`: `f32(log2 e)` and the f32 rounding of the rest.
fn log2e_split() -> Rational {
    Rational::from((12102203, 8388608)) + Rational::from((338819, 17592186044416u64))
}

/// A coefficient `c` of the sequence carries `L`'s 2^-44 scale, so its denominator is at least
/// this long; a product of two plain `ex2`s (FlashInfer's online merge, `c = 1`) has a short one
/// and is no accurate `expf`, though `1 / (H + L)` is a short-enough rational itself.
const MIN_COEFFICIENT_DENOMINATOR_BITS: u32 = 40;

/// The longest denominator a recovered constant `q` may have: the argument's own constants (`-1`,
/// `1.702f`, an f64 launch parameter's 2^-49) fit, while a coefficient with only `H` (an
/// f32-rounded `log2(e)`, 1e-8 off), or an f64 constant not times `H + L`, divides into ~2^70+.
const MAX_DENOMINATOR_BITS: u32 = 64;

/// `exp(sum q_i y_i)`.
pub(super) struct AccurateExp {
    terms: Vec<(ExprId, Rational)>,
}

impl AccurateExp {
    pub(super) fn build(self, arena: &mut ExprArena) -> ExprId {
        let mut argument: Option<ExprId> = None;
        for (y, q) in &self.terms {
            let term = if *q == -1 {
                arena.neg(*y)
            } else {
                scaled_node(arena, q, *y)
            };
            argument = Some(match argument {
                Some(sum) => arena.add(sum, term),
                None => term,
            });
        }
        let argument = argument.expect("an accurate exp has a non-constant argument");
        arena.exp(argument)
    }
}

/// `id` as `2^a * 2^b` whose exponents sum to `sum q_i (H + L) y_i` exactly once the clamped
/// exponent cancels.
pub(super) fn accurate_exp(arena: &ExprArena, id: ExprId) -> Option<AccurateExp> {
    let m = Matcher::new(arena);
    let ExprNode::Mul(left, right) = *m.node(id) else {
        return None;
    };
    let (&ExprNode::Exp(a), &ExprNode::Exp(b)) = (m.node(left), m.node(right)) else {
        return None;
    };

    let mut form = Linear::default();
    form.add(m, power_of_two(m, a)?, &Rational::from(1))?;
    form.add(m, power_of_two(m, b)?, &Rational::from(1))?;

    if form.constant != 0 {
        return None;
    }
    let split = log2e_split();
    let mut terms = Vec::new();
    for (y, c) in form.terms {
        if c == 0 {
            continue;
        }
        if c.denom().significant_bits() < MIN_COEFFICIENT_DENOMINATOR_BITS {
            return None;
        }
        let q = c / &split;
        if q.denom().significant_bits() > MAX_DENOMINATOR_BITS {
            return None;
        }
        terms.push((y, q));
    }
    (!terms.is_empty()).then_some(AccurateExp { terms })
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

/// A sum of `coefficient * term` plus a constant, in exact rationals, terms merged by
/// structural equality.
#[derive(Default)]
struct Linear {
    terms: Vec<(ExprId, Rational)>,
    constant: Rational,
}

impl Linear {
    /// Add `scale * id`; `None` when a product of two non-constants appears.
    fn add(&mut self, m: Matcher, id: ExprId, scale: &Rational) -> Option<()> {
        if let Some(k) = m.constant(id) {
            self.constant += Rational::from(scale * k);
            return Some(());
        }
        match *m.node(id) {
            ExprNode::Add(a, b) => {
                self.add(m, a, scale)?;
                self.add(m, b, scale)
            }
            ExprNode::Sub(a, b) => {
                self.add(m, a, scale)?;
                self.add(m, b, &Rational::from(-scale))
            }
            ExprNode::Neg(a) => self.add(m, a, &Rational::from(-scale)),
            ExprNode::Mul(a, b) => match (m.constant(a), m.constant(b)) {
                (Some(k), _) => self.add(m, b, &Rational::from(scale * k)),
                (_, Some(k)) => self.add(m, a, &Rational::from(scale * k)),
                (None, None) => None,
            },
            _ => {
                self.term(m, id, scale);
                Some(())
            }
        }
    }

    fn term(&mut self, m: Matcher, id: ExprId, scale: &Rational) {
        match self.terms.iter_mut().find(|(t, _)| m.same(*t, id)) {
            Some((_, c)) => *c += scale,
            None => self.terms.push((id, scale.clone())),
        }
    }
}
