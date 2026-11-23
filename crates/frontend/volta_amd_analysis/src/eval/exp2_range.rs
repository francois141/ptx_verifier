//! LLVM's denormal-safe `exp2(x)`: an input below -126 is shifted up by `s` before `v_exp_f32`,
//! and `v_ldexp_f32` scales the result back by `2^k`, `s` and `k` both chosen by one condition.

use volta_expr::symbolic_full::{ExprArena, ExprId, ExprNode, Real, RealRepr, Type, Width};

const F32: Type = Type::Float(Width(32));

/// The two integers a select chooses between.
struct Choice {
    then: i64,
    otherwise: i64,
}

/// `exp2(rest + (c ? s1 : s0)) * 2^(c ? k1 : k0)` is `exp2(rest + s1 + k1)` when
/// `s1 + k1 = s0 + k0`, whichever way `c` goes. `None` unless `value` is such an `exp2` whose
/// shift selects on `condition`; `exponents` are `[k1, k0]`.
pub(super) fn undo_exp2_range_shift(
    arena: &mut ExprArena,
    value: ExprId,
    condition: ExprId,
    exponents: [i32; 2],
) -> Option<ExprId> {
    let ExprNode::Exp2(argument) = *arena.value_node(value) else {
        return None;
    };
    let (rest, shift) = split_shift(arena, argument, condition)?;
    let [then_exponent, otherwise_exponent] = exponents.map(i64::from);
    let total = shift.then.checked_add(then_exponent)?;
    if shift.otherwise.checked_add(otherwise_exponent)? != total {
        return None;
    }
    let argument = if total == 0 {
        rest
    } else {
        let total = arena.real(Real::from_i64(total));
        arena.add(F32, rest, total)
    };
    Some(arena.exp2(F32, argument))
}

/// `argument` as `rest + shift`: an add with a shift operand, or an fma whose addend is one.
fn split_shift(
    arena: &mut ExprArena,
    argument: ExprId,
    condition: ExprId,
) -> Option<(ExprId, Choice)> {
    match *arena.value_node(argument) {
        ExprNode::Add(a, b) => {
            if let Some(shift) = integer_choice(arena, a, condition) {
                Some((b, shift))
            } else {
                Some((a, integer_choice(arena, b, condition)?))
            }
        }
        ExprNode::Fma(a, b, addend) => {
            let shift = integer_choice(arena, addend, condition)?;
            Some((arena.mul(F32, a, b), shift))
        }
        _ => None,
    }
}

/// `id` as a select on `condition` between two integer constants, which keep the comparison of
/// the shifts with the exponents exact.
fn integer_choice(arena: &ExprArena, id: ExprId, condition: ExprId) -> Option<Choice> {
    let ExprNode::Select(selected, then, otherwise) = *arena.value_node(id) else {
        return None;
    };
    if selected != condition {
        return None;
    }
    Some(Choice {
        then: integer(arena, then)?,
        otherwise: integer(arena, otherwise)?,
    })
}

fn integer(arena: &ExprArena, id: ExprId) -> Option<i64> {
    let ExprNode::RealConst(real) = arena.value_node(id) else {
        return None;
    };
    let RealRepr::Rational(q) = real.repr() else {
        return None;
    };
    if *q.denom() != 1 {
        return None;
    }
    q.numer().to_i64()
}
