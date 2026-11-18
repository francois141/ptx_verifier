//! Bitfield patterns. A kernel reaches a field of bits through whatever operations its
//! compiler chose, where a spec states the field directly, and the decision procedure keeps
//! bitwise operations opaque. Lowering writes each pattern it detects in one standard form.

use super::bit_delta_pattern::BitDeltaPattern;
use crate::symbolic_full as full;
use crate::symbolic_simplified as simplified;

/// A shape of full-IR bit operations that has one standard form in the simplified IR.
pub(super) trait BitfieldPattern: Sized {
    /// The instance of the pattern that the node `id` computes, if it computes one.
    fn detect(arena: &full::ExprArena, id: full::ExprId) -> Option<Self>;

    /// The instance in its standard form, each full-IR operand lowered by `child`.
    fn lower(
        self,
        target: &mut simplified::ExprArena,
        child: impl Fn(full::ExprId) -> simplified::ExprId,
    ) -> simplified::ExprId;
}

/// The standard form of the node `id`, when it is an instance of a known pattern.
pub(super) fn standard_form(
    arena: &full::ExprArena,
    id: full::ExprId,
    target: &mut simplified::ExprArena,
    child: impl Fn(full::ExprId) -> simplified::ExprId,
) -> Option<simplified::ExprId> {
    lower_as::<BitDeltaPattern>(arena, id, target, child)
}

fn lower_as<P: BitfieldPattern>(
    arena: &full::ExprArena,
    id: full::ExprId,
    target: &mut simplified::ExprArena,
    child: impl Fn(full::ExprId) -> simplified::ExprId,
) -> Option<simplified::ExprId> {
    Some(P::detect(arena, id)?.lower(target, child))
}
