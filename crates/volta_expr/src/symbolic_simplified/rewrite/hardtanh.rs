//! PyTorch's Hardtanh (`torch.nn.Hardtanh`), `min(max(x, min_val), max_val)`, from the two
//! selects `std::max` and `std::min` compile to, so a spec's clamp matches it. Hardsigmoid and
//! Hardswish clamp `x + 3` the same way.

use rug::Rational;

use super::node::constant_node;
use super::patterns::Matcher;
use crate::{ExprArena, ExprId};

/// `min(max(x, low), high)`.
pub(super) struct Hardtanh {
    x: ExprId,
    low: Rational,
    high: Rational,
}

/// `id` as the select `y > high ? high : y` of a `y` that is `max(x, low)`, a `max` node or
/// its select.
pub(super) fn hardtanh(arena: &ExprArena, id: ExprId) -> Option<Hardtanh> {
    let m = Matcher::new(arena);
    m.split(id)?;

    let (y, high) = m.upper_bound(id)?;
    let (x, low) = m.lower_bound(y)?;
    Some(Hardtanh { x, low, high })
}

impl Hardtanh {
    pub(super) fn build(self, arena: &mut ExprArena) -> ExprId {
        let low = constant_node(arena, &self.low);
        let high = constant_node(arena, &self.high);
        let lower = arena.max(self.x, low);
        arena.min(lower, high)
    }
}
