//! Lowering from the full language to `symbolic_simplified`: every node rebuilt with the
//! simplified constructors, which fold constants exactly and apply their simplifications.

use std::collections::HashMap;

use id_collections::{Count, IdVec};

use crate::outputs::{FullOutputs, SymbolicOutputs};
use crate::symbolic_full as full;
use crate::symbolic_simplified as simplified;

/// `outputs` in the simplified language: the nodes reachable from an output, lowered
/// children first, each node the full arena already evaluated taking its value's lowering.
/// Each machine symbol becomes a fresh simplified one and each input array keeps one string.
pub fn lower(outputs: &FullOutputs) -> SymbolicOutputs {
    let source = &outputs.arena;
    let reachable = reachable(outputs);
    let mut target = simplified::ExprArena::new();
    let mut atoms = Atoms::default();
    let mut lowered: IdVec<full::ExprId, Option<simplified::ExprId>> =
        IdVec::from_count_with(reachable.count(), |_| None);

    for id in reachable.count() {
        if !reachable[id] {
            continue;
        }
        let value = source.value(id);
        if value != id {
            lowered[id] = lowered[value];
            continue;
        }
        let node = source.node(id);
        let lowered_id = match atoms.lower(&mut target, id, source) {
            Some(atom) => atom,
            None => {
                let child = |c: full::ExprId| lowered[c].expect("children precede their parents");
                lower_operation(&mut target, node, child, &source.strings)
                    .expect("a node is an atom or an operation")
            }
        };
        lowered[id] = Some(lowered_id);
    }

    let lowered_root = |root: full::ExprId| lowered[root].expect("every root is reachable");
    let mut lowered_outputs = Vec::with_capacity(outputs.outputs.len());
    for (array, elements) in &outputs.outputs {
        let roots = elements
            .iter()
            .map(|&(index, root)| (index, lowered_root(root)))
            .collect();
        lowered_outputs.push((array.clone(), roots));
    }

    SymbolicOutputs {
        arena: target,
        outputs: lowered_outputs,
    }
}

/// Which nodes an output reaches through values, in one descending sweep: a node's children
/// and its value precede it.
fn reachable(outputs: &FullOutputs) -> IdVec<full::ExprId, bool> {
    let count = u32::try_from(outputs.arena.node_count()).expect("an arena's ids are u32");
    let mut reachable = IdVec::from_count_with(Count::from_value(count), |_| false);
    for &(_, root) in outputs.outputs.iter().flat_map(|(_, elements)| elements) {
        reachable[root] = true;
    }
    for id in reachable.count().into_iter().rev() {
        if !reachable[id] {
            continue;
        }
        let value = outputs.arena.value(id);
        if value == id {
            outputs
                .arena
                .node(id)
                .for_each_child(|c| reachable[c] = true);
        } else {
            reachable[value] = true;
        }
    }
    reachable
}

/// The simplified counterparts of the strings and machine symbols lowered so far.
#[derive(Default)]
struct Atoms {
    strings: HashMap<full::StringId, simplified::StringId>,
    symbols: HashMap<full::SymbolId, simplified::SymbolId>,
}

impl Atoms {
    /// An atom's simplified node; `None` for an operation.
    fn lower(
        &mut self,
        target: &mut simplified::ExprArena,
        id: full::ExprId,
        source: &full::ExprArena,
    ) -> Option<simplified::ExprId> {
        let mut string = |target: &mut simplified::ExprArena, sid: full::StringId| {
            *self
                .strings
                .entry(sid)
                .or_insert_with(|| target.intern_string(source.string(sid)))
        };
        Some(match source.node(id) {
            full::ExprNode::IntConst(v) => target.int(*v),
            full::ExprNode::RealConst(_) => {
                let real = source
                    .lowered_real(id)
                    .expect("a real constant has its counterpart");
                target.real(real.clone())
            }
            full::ExprNode::BoolConst(v) => target.bool_val(*v),
            full::ExprNode::Symbol(sym) => {
                let sym = *self
                    .symbols
                    .entry(*sym)
                    .or_insert_with(simplified::SymbolId::fresh);
                target.push(simplified::ExprNode::Symbol(sym))
            }
            full::ExprNode::ParamSymbol(sid) => {
                let sid = string(target, *sid);
                target.push(simplified::ExprNode::ParamSymbol(sid))
            }
            full::ExprNode::InputElement { array, index } => {
                let array = string(target, *array);
                target.input_element(array, *index)
            }
            full::ExprNode::Discarded => target.discarded(),
            full::ExprNode::Undefined => target.undefined(),
            _ => return None,
        })
    }
}

/// A full constant as a simplified one.
pub(crate) fn lower_real(real: &full::Real) -> simplified::Real {
    match real.repr() {
        full::RealRepr::NegInf => simplified::Real::from_f64(f64::NEG_INFINITY),
        full::RealRepr::PosInf => simplified::Real::from_f64(f64::INFINITY),
        full::RealRepr::Rational(q) => Ok(simplified::Real::from_rational(q.clone())),
    }
    .expect("an infinity is not a NaN")
}

/// A simplified constant, the result of a fold, as a full one.
pub(crate) fn raise_real(real: &simplified::Real) -> full::Real {
    match real.repr() {
        simplified::RealRepr::NegInf => full::Real::from_f64(f64::NEG_INFINITY),
        simplified::RealRepr::PosInf => full::Real::from_f64(f64::INFINITY),
        simplified::RealRepr::Rational(q) => Ok(full::Real::from_rational(q.clone())),
    }
    .expect("an infinity is not a NaN")
}

/// An operation rebuilt in `target` with its simplified constructor over `child`'s lowering
/// of each operand; `None` for an atom, whose strings belong to the caller.
pub(crate) fn lower_operation(
    target: &mut simplified::ExprArena,
    node: &full::ExprNode,
    child: impl Fn(full::ExprId) -> simplified::ExprId,
    strings: &IdVec<full::StringId, String>,
) -> Option<simplified::ExprId> {
    use full::ExprNode::*;
    Some(match *node {
        IntConst(_)
        | RealConst(_)
        | BoolConst(_)
        | Symbol(_)
        | ParamSymbol(_)
        | InputElement { .. }
        | Discarded
        | Undefined => return None,

        Add(a, b) => target.add(child(a), child(b)),
        Sub(a, b) => target.sub(child(a), child(b)),
        Mul(a, b) => target.mul(child(a), child(b)),
        Div(a, b) => target.div(child(a), child(b)),
        Rem(a, b) => target.rem(child(a), child(b)),
        Neg(a) => target.neg(child(a)),
        Exp(a) => target.exp(child(a)),
        Exp2(a) => lower_exp2(target, child(a)),
        Log(a) => target.log(child(a)),
        Log2(a) => lower_log2(target, child(a)),
        Sqrt(a) => target.sqrt(child(a)),
        Rcp(a) => lower_rcp(target, child(a)),
        Erf(a) => target.erf(child(a)),
        Gelu(a) => target.gelu(child(a)),
        Max(a, b) => target.max(child(a), child(b)),
        Min(a, b) => target.min(child(a), child(b)),
        Abs(a) => target.abs(child(a)),
        Sign(a) => target.sign(child(a)),
        RoundEven(a) => target.round_even(child(a)),
        Trunc(a) => target.trunc(child(a)),
        BitAnd(a, b) => target.bit_and(child(a), child(b)),
        BitOr(a, b) => target.bit_or(child(a), child(b)),
        BitXor(a, b) => target.bit_xor(child(a), child(b)),
        BitNot(a) => target.bit_not(child(a)),
        Shl(a, b) => target.shl(child(a), child(b)),
        Shr(a, b) => target.shr(child(a), child(b)),
        LShr(a, b) => target.lshr(child(a), child(b)),
        Eq(a, b) => target.eq(child(a), child(b)),
        Ne(a, b) => target.ne(child(a), child(b)),
        Lt(a, b) => target.lt(child(a), child(b)),
        Le(a, b) => target.le(child(a), child(b)),
        Gt(a, b) => target.gt(child(a), child(b)),
        Ge(a, b) => target.ge(child(a), child(b)),
        And(a, b) => target.and(child(a), child(b)),
        Or(a, b) => target.or(child(a), child(b)),
        Not(a) => target.not(child(a)),
        Select(c, t, e) => target.select(child(c), child(t), child(e)),
        ToFloat(a) => target.to_float(child(a)),
        Fma(a, b, c) => lower_fma(target, child(a), child(b), child(c)),
        SymbolicRead { array, index } => target.symbolic_read(&strings[array], child(index)),
    })
}

/// `1 / a`, folding exactly as `div` does.
fn lower_rcp(target: &mut simplified::ExprArena, a: simplified::ExprId) -> simplified::ExprId {
    let one = target.real(simplified::Real::one());
    target.div(one, a)
}

/// `a * b + c`, folding exactly as the product then the sum do.
fn lower_fma(
    target: &mut simplified::ExprArena,
    a: simplified::ExprId,
    b: simplified::ExprId,
    c: simplified::ExprId,
) -> simplified::ExprId {
    let product = target.mul(a, b);
    target.add(product, c)
}

/// `2^a` over the reals: `exp(a * ln 2)`, or `exp(v)` for the compilers' `exp(v)` idiom
/// `2^(v * log2(e))`, which kernels spell with a float32 `log2(e)` (an `exp(v * 0.99999...)`
/// over the reals) and is folded to the exact `exp(v)` it approximates.
fn lower_exp2(target: &mut simplified::ExprArena, a: simplified::ExprId) -> simplified::ExprId {
    if let Some(argument) = factor_log2e(target, a) {
        return target.exp(argument);
    }
    let ln2 = ln2_f32(target);
    let scaled = target.mul(a, ln2);
    target.exp(scaled)
}

/// `log2(a)` over the reals, as `log(a) / ln 2`, the mirror of [`lower_exp2`].
fn lower_log2(target: &mut simplified::ExprArena, a: simplified::ExprId) -> simplified::ExprId {
    let log = target.log(a);
    let ln2 = ln2_f32(target);
    target.div(log, ln2)
}

/// `ln 2` as the exact reciprocal of float32's `log2(e)`: scaled exponentials then
/// canonicalize exactly to a spec's `exp` form and `exp2(log2(x))` cancels, where an f64
/// `ln 2` would leave ~1e-8 error.
fn ln2_f32(target: &mut simplified::ExprArena) -> simplified::ExprId {
    let log2e = simplified::Real::from_f64(f64::from(std::f64::consts::LOG2_E as f32))
        .expect("log2(e) is not NaN");
    target.real(log2e.try_recip().expect("log2(e) is nonzero"))
}

/// Pulls a `log2(e)`-ish constant (within float32 rounding) out of a `Mul`/`Add` chain,
/// folding in each term's sign, so that `a == log2e * factor_log2e(a)`; `None` when no such
/// factor exists.
fn factor_log2e(
    target: &mut simplified::ExprArena,
    a: simplified::ExprId,
) -> Option<simplified::ExprId> {
    let log2e = std::f64::consts::LOG2_E;
    let is_log2e_like = |value: f64| (value.abs() - log2e).abs() <= log2e * 1e-6;
    match target.node(a).clone() {
        simplified::ExprNode::Mul(l, r) => {
            for (constant, other) in [(l, r), (r, l)] {
                let simplified::ExprNode::RealConst(real) = target.node(constant) else {
                    continue;
                };
                let value = real.to_f64();
                if is_log2e_like(value) {
                    return Some(if value < 0.0 {
                        target.neg(other)
                    } else {
                        other
                    });
                }
            }
            None
        }
        simplified::ExprNode::Add(l, r) => {
            let l_factored = factor_log2e(target, l)?;
            let r_factored = factor_log2e(target, r)?;
            Some(target.add(l_factored, r_factored))
        }
        _ => None,
    }
}
