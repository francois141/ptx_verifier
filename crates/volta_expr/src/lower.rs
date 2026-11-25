//! Lowering from the full language to `symbolic_simplified`: every node rebuilt with the
//! simplified constructors, which fold constants exactly and apply their simplifications.

mod bit_delta_pattern;
mod bitfield_pattern;
mod word_bits;

use std::collections::HashMap;
use std::fmt;

use id_collections::{Count, IdVec};

use crate::outputs::{FullOutputs, SymbolicOutputs};
use crate::symbolic_full as full;
use crate::symbolic_simplified as simplified;

/// Why outputs cannot be lowered.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LowerError {
    /// A bitwise operation that stays bitwise, and so opaque to the decision procedure, of a
    /// type other than a 32-bit word: one opaque atom denotes one function only at one width.
    BitwiseWidth {
        operation: &'static str,
        ty: full::Type,
    },
}

impl fmt::Display for LowerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            LowerError::BitwiseWidth { operation, ty } => write!(
                f,
                "the bitwise operation {operation} has type {ty:?}, but only 32-bit words are \
                 supported"
            ),
        }
    }
}

impl std::error::Error for LowerError {}

/// `outputs` in the simplified language: the nodes reachable from an output, lowered
/// children first, each node the full arena already evaluated taking its value's lowering.
/// Each machine symbol becomes a fresh simplified one and each input array keeps one string.
pub fn lower(outputs: &FullOutputs) -> Result<SymbolicOutputs, LowerError> {
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
                let ty = source.ty(id).expect("an operation has a type");
                let lowered = bitfield_pattern::standard_form(source, id, &mut target, child)
                    .unwrap_or_else(|| {
                        lower_operation(&mut target, node, ty, child, &source.strings)
                            .expect("a node is an atom or an operation")
                    });
                if let Some(operation) = bitwise_operation(target.node(lowered))
                    && !is_word32(ty)
                {
                    return Err(LowerError::BitwiseWidth { operation, ty });
                }
                lowered
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

    Ok(SymbolicOutputs {
        arena: target,
        outputs: lowered_outputs,
    })
}

/// The name of `node`'s operation when the decision procedure keeps it opaque as a word
/// operation.
fn bitwise_operation(node: &simplified::ExprNode) -> Option<&'static str> {
    use simplified::ExprNode::*;
    Some(match node {
        BitAnd(..) => "and",
        BitOr(..) => "or",
        BitXor(..) => "xor",
        BitNot(_) => "not",
        Shl(..) => "shl",
        Shr(..) => "shr",
        LShr(..) => "lshr",
        Popc(_) => "popc",
        _ => return None,
    })
}

/// Whether `ty` is a 32-bit word: `.b32`, or a 32-bit integer (`shr.u32`, `shr.s32`).
fn is_word32(ty: full::Type) -> bool {
    matches!(
        ty,
        full::Type::Bits(full::Width(32)) | full::Type::Int(_, full::Width(32))
    )
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
    ty: full::Type,
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
        Mul(a, b) => lower_mul(target, child(a), child(b)),
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
        Tanh(a) => lower_tanh(target, child(a)),
        Rsqrt(a) => {
            let root = target.sqrt(child(a));
            lower_rcp(target, root)
        }
        Sigmoid(a) => lower_sigmoid(target, child(a)),
        Median3(a, b, c) => lower_median3(target, child(a), child(b), child(c)),
        Copysign(magnitude, sign) => lower_copysign(target, child(magnitude), child(sign)),
        Max(a, b) => target.max(child(a), child(b)),
        Min(a, b) => target.min(child(a), child(b)),
        Abs(a) => target.abs(child(a)),
        Sign(a) => target.sign(child(a)),
        RoundEven(a) => target.round_even(child(a)),
        Trunc(a) => target.trunc(child(a)),
        Floor(a) => target.floor(child(a)),
        BitAnd(a, b) => {
            let (a, b) = (child(a), child(b));
            match float_under_mask(target, ty, a, b, SignMask::Clear) {
                Some(x) => target.abs(x),
                None => target.bit_and(a, b),
            }
        }
        BitOr(a, b) => target.bit_or(child(a), child(b)),
        BitXor(a, b) => {
            let (a, b) = (child(a), child(b));
            match float_under_mask(target, ty, a, b, SignMask::Flip) {
                Some(x) => target.neg(x),
                None => target.bit_xor(a, b),
            }
        }
        BitNot(a) => target.bit_not(child(a)),
        Popc(a) => target.popc(child(a)),
        Shl(a, b) => target.shl(child(a), child(b)),
        Shr(a, b) => target.shr(child(a), child(b)),
        LShr(a, b) => target.lshr(child(a), child(b)),
        Prmt { a, b, selector } => lower_prmt(target, child(a), child(b), selector),
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

/// The `width` bits of `word` from bit `offset` up, `(word >> offset) & (2^width - 1)`.
fn extract_bitfield(
    target: &mut simplified::ExprArena,
    word: simplified::ExprId,
    offset: u32,
    width: u32,
) -> simplified::ExprId {
    let offset = target.int(i64::from(offset));
    let shifted = target.lshr(word, offset);
    let mask = target.int((1 << width) - 1);
    target.bit_and(shifted, mask)
}

/// `prmt` as the or of its four result bytes, each moved into place. A sign-filled byte is
/// its source byte's top bit times `0xff`.
fn lower_prmt(
    target: &mut simplified::ExprArena,
    a: simplified::ExprId,
    b: simplified::ExprId,
    selector: full::PrmtSelector,
) -> simplified::ExprId {
    let mut word = target.int(0);
    for (result_byte, from) in (0..).zip(selector.bytes()) {
        let operand = from.operand.of(a, b);
        let byte = match from.take {
            full::ByteTake::Value => extract_bitfield(target, operand, 8 * from.byte, 8),
            full::ByteTake::Sign => {
                let sign = extract_bitfield(target, operand, 8 * from.byte + 7, 1);
                let ones = target.int(0xff);
                target.mul(sign, ones)
            }
        };
        let place = target.int(8 * result_byte);
        let placed = target.shl(byte, place);
        word = target.bit_or(word, placed);
    }
    word
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

/// `tanh(a)` as `(e^{2a} - 1) / (e^{2a} + 1)`, which the decision procedure reasons about
/// where it would see an opaque `tanh` atom.
fn lower_tanh(target: &mut simplified::ExprArena, a: simplified::ExprId) -> simplified::ExprId {
    let two = target.int(2);
    let one = target.int(1);
    let two_a = target.mul(a, two);
    let e2a = target.exp(two_a);
    let numerator = target.sub(e2a, one);
    let denominator = target.add(e2a, one);
    target.div(numerator, denominator)
}

/// `sigmoid(a)` as `1 / (1 + e^-a)`.
fn lower_sigmoid(target: &mut simplified::ExprArena, a: simplified::ExprId) -> simplified::ExprId {
    let one = target.real(simplified::Real::one());
    let negated = target.neg(a);
    let exp = target.exp(negated);
    let denominator = target.add(one, exp);
    lower_rcp(target, denominator)
}

/// The median of three as `max(min(a, b), min(max(a, b), c))`, or, between two constants, the
/// clamp `min(max(x, low), high)` a spec states (the `v_med3_f32` a clamp compiles to).
fn lower_median3(
    target: &mut simplified::ExprArena,
    a: simplified::ExprId,
    b: simplified::ExprId,
    c: simplified::ExprId,
) -> simplified::ExprId {
    let is_constant = |target: &simplified::ExprArena, id| {
        matches!(
            target.node(id),
            simplified::ExprNode::RealConst(_) | simplified::ExprNode::IntConst(_)
        )
    };
    let operands = [a, b, c];
    let constants: Vec<usize> = (0..3).filter(|&i| is_constant(target, operands[i])).collect();
    if let [p, q] = constants[..] {
        let x = operands[3 - p - q];
        let low = target.min(operands[p], operands[q]);
        let high = target.max(operands[p], operands[q]);
        let floored = target.max(x, low);
        return target.min(floored, high);
    }
    let low = target.min(a, b);
    let high = target.max(a, b);
    let capped = target.min(high, c);
    target.max(low, capped)
}

/// `copysign(magnitude, sign)` as `sign >= 0 ? |magnitude| : -|magnitude|`.
fn lower_copysign(
    target: &mut simplified::ExprArena,
    magnitude: simplified::ExprId,
    sign: simplified::ExprId,
) -> simplified::ExprId {
    let zero = target.real(simplified::Real::zero());
    let non_negative = target.ge(sign, zero);
    let absolute = target.abs(magnitude);
    let negated = target.neg(absolute);
    target.select(non_negative, absolute, negated)
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

/// `a * b`, or `log(v)` for the compilers' `log(v)` idiom `log2(v) * ln 2`, which kernels spell
/// with a float32 `ln 2` (a `log(v) * 0.99999...` over the reals) and is folded to the exact
/// `log(v)` it approximates: the mirror of [`lower_exp2`]'s fold over [`lower_log2`]'s quotient.
fn lower_mul(
    target: &mut simplified::ExprArena,
    a: simplified::ExprId,
    b: simplified::ExprId,
) -> simplified::ExprId {
    for (log2, constant) in [(a, b), (b, a)] {
        if is_near(target, constant, std::f64::consts::LN_2)
            && let simplified::ExprNode::Div(log, ln2) = *target.node(log2)
            && is_near(target, ln2, std::f64::consts::LN_2)
            && matches!(target.node(log), simplified::ExprNode::Log(_))
        {
            return log;
        }
    }
    target.mul(a, b)
}

/// Whether `id` is a real constant within float32 rounding (1e-6, relative) of `value`.
fn is_near(target: &simplified::ExprArena, id: simplified::ExprId, value: f64) -> bool {
    matches!(target.node(id), simplified::ExprNode::RealConst(real)
        if (real.to_f64() - value).abs() <= value * 1e-6)
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

/// The two masks that touch only a float's sign bit: `x ^ sign` flips it (`-x`) and
/// `x & !sign` clears it (`|x|`).
#[derive(Clone, Copy)]
enum SignMask {
    Flip,
    Clear,
}

impl SignMask {
    /// The mask for a float of `bits` bits: its sign bit alone, or every bit but it.
    fn word(self, bits: u16) -> u64 {
        let sign = 1u64 << (bits - 1);
        match self {
            SignMask::Flip => sign,
            SignMask::Clear => sign - 1,
        }
    }
}

/// The `x` of `x ^ sign` or `x & !sign` when `ty` is a float type and the other operand is
/// that mask for its width.
fn float_under_mask(
    target: &simplified::ExprArena,
    ty: full::Type,
    a: simplified::ExprId,
    b: simplified::ExprId,
    mask: SignMask,
) -> Option<simplified::ExprId> {
    let full::Type::Float(full::Width(bits @ 1..=64)) = ty else {
        return None;
    };
    let is_mask = |id| low_bits(target, id, bits) == Some(mask.word(bits));

    if is_mask(b) && is_float_value(target, a) {
        Some(a)
    } else if is_mask(a) && is_float_value(target, b) {
        Some(b)
    } else {
        None
    }
}

/// The low `bits` bits of `id` when it is an integer constant.
fn low_bits(target: &simplified::ExprArena, id: simplified::ExprId, bits: u16) -> Option<u64> {
    let simplified::ExprNode::IntConst(c) = *target.node(id) else {
        return None;
    };
    Some(c as u64 & (u64::MAX >> (64 - bits)))
}

/// Whether `id` can be a float's value: not a concrete word, whose bits are not a real's, nor
/// a predicate or an undefined value.
fn is_float_value(target: &simplified::ExprArena, id: simplified::ExprId) -> bool {
    !matches!(
        target.node(id),
        simplified::ExprNode::IntConst(_)
            | simplified::ExprNode::BoolConst(_)
            | simplified::ExprNode::Undefined
    )
}
