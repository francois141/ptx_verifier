//! PyTorch's Softshrink (`torch.nn.Softshrink`), `x - lambd` above `lambd`, `x + lambd` below
//! `-lambd` and 0 between, from its select chain to `max(x - lambd, 0) + min(x + lambd, 0)`,
//! the form the decision procedure interprets. Equal for every constant `lambd >= 0`.

use rug::Rational;

use super::patterns::{Matcher, constant_node};
use crate::{ExprArena, ExprId};

/// `max(x - lambd, 0) + min(x + lambd, 0)`.
pub(super) struct Softshrink {
    x: ExprId,
    lambd: Rational,
}

/// `id` as Softshrink's two selects, either one outermost: `x - lambd` above `lambd`,
/// `x + lambd` below `-lambd`, 0 between.
pub(super) fn softshrink(arena: &ExprArena, id: ExprId) -> Option<Softshrink> {
    let m = Matcher::new(arena);
    let outer = m.split(id)?;

    let (upper, lower, middle) = match m.split(outer.below) {
        Some(inner) => {
            let middle = inner.above;
            (outer, inner, middle)
        }
        None => {
            let inner = m.split(outer.above)?;
            let middle = inner.below;
            (inner, outer, middle)
        }
    };

    let x = upper.x;
    let lambd = upper.threshold;
    let minus_lambd = Rational::from(-&lambd);

    let fits = m.same(lower.x, x)
        && lambd >= 0
        && lower.threshold == minus_lambd
        && m.offset(upper.above, x)? == minus_lambd
        && m.offset(lower.below, x)? == lambd
        && m.is(middle, 0);
    fits.then_some(Softshrink { x, lambd })
}

impl Softshrink {
    pub(super) fn build(self, arena: &mut ExprArena) -> ExprId {
        let lambd = constant_node(arena, &self.lambd);
        let zero = arena.int(0);

        let shifted_down = arena.sub(self.x, lambd);
        let upper = arena.max(shifted_down, zero);
        let shifted_up = arena.add(self.x, lambd);
        let lower = arena.min(shifted_up, zero);
        arena.add(upper, lower)
    }
}
