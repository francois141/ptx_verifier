//! Matchers of general expression shapes a rewrite recognizes: constants, structural
//! equality, halving and constant scaling, monomials and cubics, the `tanh` form the analyses
//! build, and the selects piecewise activations compile to.

use std::collections::HashSet;

use rug::Rational;
use volta_common::commutative::either;
use volta_common::monomial::Monomial;

use crate::{ExprArena, ExprId, ExprNode, Real, RealRepr};

/// A select on `x` against a constant `threshold`: `above` where `x` is above it, `below` where
/// it is below. The comparison's strictness is dropped, so a rewrite of one must check that its
/// two pieces agree at `threshold`.
pub(super) struct Split {
    pub(super) x: ExprId,
    pub(super) threshold: Rational,
    pub(super) above: ExprId,
    pub(super) below: ExprId,
}

#[derive(Clone, Copy)]
pub(super) struct Matcher<'a> {
    arena: &'a ExprArena,
}

impl<'a> Matcher<'a> {
    pub(super) fn new(arena: &'a ExprArena) -> Self {
        Self { arena }
    }

    pub(super) fn node(self, id: ExprId) -> &'a ExprNode {
        self.arena.node(id)
    }

    /// The exponent `2w` of `tanh(w) = (e^{2w} - 1) / (e^{2w} + 1)`.
    pub(super) fn tanh(self, id: ExprId) -> Option<ExprId> {
        let ExprNode::Div(num, den) = *self.node(id) else {
            return None;
        };

        let (&ExprNode::Sub(e, one), &ExprNode::Add(a, b)) = (self.node(num), self.node(den))
        else {
            return None;
        };

        let ExprNode::Exp(exponent) = *self.node(e) else {
            return None;
        };

        let e_plus_one = |f: ExprId, one: ExprId| self.same(f, e) && self.is(one, 1);
        (self.is(one, 1) && (e_plus_one(a, b) || e_plus_one(b, a))).then_some(exponent)
    }

    /// `x` of `x * 0.5`.
    pub(super) fn halved(self, id: ExprId) -> Option<ExprId> {
        let ExprNode::Mul(a, b) = *self.node(id) else {
            return None;
        };

        either(a, b, |x, half| self.is(half, (1, 2)).then_some(x))
    }

    /// `id` as `s * rest`, `s` the product of the constant factors atop its `mul` chain.
    pub(super) fn scaled(self, mut id: ExprId) -> (Rational, ExprId) {
        let mut scale = Rational::from(1);

        while let ExprNode::Mul(a, b) = *self.node(id)
            && let Some((c, rest)) = either(a, b, |c, rest| Some((self.constant(c)?, rest)))
        {
            scale *= c;
            id = rest;
        }

        (scale, id)
    }

    /// `k` of `x + k*x^3`: an `add` of the two terms, or an `fma` adding `x` to their product.
    pub(super) fn cubic(self, id: ExprId, x: ExprId) -> Option<Rational> {
        let cube = match *self.node(id) {
            ExprNode::Add(a, b) => either(a, b, |linear, cube| {
                self.monomial(cube, x).filter(|_| self.same(linear, x))
            })?,
            ExprNode::Fma(a, b, c) if self.same(c, x) => {
                self.monomial(a, x)? * self.monomial(b, x)?
            }
            _ => return None,
        };

        (cube.degree == 3).then_some(cube.coefficient)
    }

    /// `id` as a product of constants and copies of `x`, in any association.
    pub(super) fn monomial(self, id: ExprId, x: ExprId) -> Option<Monomial<Rational>> {
        if self.same(id, x) {
            return Some(Monomial {
                coefficient: Rational::from(1),
                degree: 1,
            });
        }

        match *self.node(id) {
            ExprNode::Mul(a, b) => Some(self.monomial(a, x)? * self.monomial(b, x)?),
            _ => Some(Monomial {
                coefficient: self.constant(id)?,
                degree: 0,
            }),
        }
    }

    /// Whether `a` and `b` are one expression, shared or built twice: a spec's unfolding shares
    /// no node, so its `tanh` holds two equal exponentials and each `x` is a node of its own.
    /// Iterative, and each pair compared once, so deep or shared operands cost their size.
    pub(super) fn same(self, a: ExprId, b: ExprId) -> bool {
        let mut pending = vec![(a, b)];
        let mut compared = HashSet::new();

        while let Some((a, b)) = pending.pop() {
            if a == b || !compared.insert((a, b)) {
                continue;
            }

            let (na, nb) = (self.node(a), self.node(b));
            let shape = |node: &ExprNode| node.map_children(|_| a);
            if shape(na) != shape(nb) {
                return false;
            }

            pending.extend(children(na).into_iter().zip(children(nb)));
        }

        true
    }

    /// `id` as a select on one expression against a constant.
    pub(super) fn split(self, id: ExprId) -> Option<Split> {
        let ExprNode::Select(condition, then, otherwise) = *self.node(id) else {
            return None;
        };

        let (less, a, b) = match *self.node(condition) {
            ExprNode::Lt(a, b) | ExprNode::Le(a, b) => (true, a, b),
            ExprNode::Gt(a, b) | ExprNode::Ge(a, b) => (false, a, b),
            _ => return None,
        };

        let (x, threshold, holds_above) = match (self.constant(a), self.constant(b)) {
            (None, Some(c)) => (a, c, !less),
            (Some(c), None) => (b, c, less),
            _ => return None,
        };

        let (above, below) = if holds_above {
            (then, otherwise)
        } else {
            (otherwise, then)
        };

        Some(Split {
            x,
            threshold,
            above,
            below,
        })
    }

    pub(super) fn is<T>(self, id: ExprId, value: T) -> bool
    where
        Rational: From<T>,
    {
        self.constant(id)
            .is_some_and(|c| c == Rational::from(value))
    }

    pub(super) fn constant(self, id: ExprId) -> Option<Rational> {
        match self.node(id) {
            ExprNode::IntConst(v) => Some(Rational::from(*v)),
            ExprNode::RealConst(v) => match v.repr() {
                RealRepr::Rational(q) => Some(q.clone()),
                RealRepr::NegInf | RealRepr::PosInf => None,
            },
            _ => None,
        }
    }
}

fn children(node: &ExprNode) -> Vec<ExprId> {
    let mut children = Vec::new();
    node.for_each_child(|c| children.push(c));
    children
}

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
