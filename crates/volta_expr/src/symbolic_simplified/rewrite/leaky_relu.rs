//! PyTorch's LeakyReLU (`torch.nn.LeakyReLU`), `max(x, 0) + negative_slope * min(x, 0)`, from
//! the select `x > 0 ? x : x * negative_slope` its kernel writes. Both pieces are 0 at 0, so the
//! two forms agree for every slope.

use rug::Rational;

use super::node::scaled_node;
use super::patterns::Matcher;
use crate::{ExprArena, ExprId};

/// `max(x, 0) + slope * min(x, 0)`.
pub(super) struct LeakyRelu {
    x: ExprId,
    slope: Rational,
}

/// `id` as LeakyReLU's select: `x` above 0, a constant multiple of `x` below.
pub(super) fn leaky_relu(arena: &ExprArena, id: ExprId) -> Option<LeakyRelu> {
    let m = Matcher::new(arena);
    let split = m.split(id)?;
    if split.threshold != 0 || !m.same(split.above, split.x) {
        return None;
    }

    let below = m.monomial(split.below, split.x)?;
    (below.degree == 1).then_some(LeakyRelu {
        x: split.x,
        slope: below.coefficient,
    })
}

impl LeakyRelu {
    pub(super) fn build(self, arena: &mut ExprArena) -> ExprId {
        let zero = arena.int(0);
        let positive = arena.max(self.x, zero);
        let negative = arena.min(self.x, zero);
        let negative = scaled_node(arena, &self.slope, negative);
        arena.add(positive, negative)
    }
}
