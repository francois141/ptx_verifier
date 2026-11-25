//! Integer arithmetic on an f32's bits, read as the reals it computes: libdevice's `logf` splits
//! `v` into `k = floor(log2(v / c))` (`(bits(v) - bits(c)) & 0xff800000`) and `v * 2^-k`, and its
//! accurate `expf` builds `2^n` by shifting a magic-number-rounded integer into the exponent.

use crate::frontend::ast::ScalarType;
use volta_expr::symbolic_full::{ExprId, ExprNode, Signedness, Type, Width};

use crate::eval::interp::Interpreter;
use crate::ir::CmpOp;
use crate::ir::types::ScalarTypeExt;

const EXPONENT_MASK: u32 = 0xff80_0000;
const MANTISSA_UNIT: i64 = 1 << 23;
const POSITIVE_INFINITY: u32 = 0x7f80_0000;
const MANTISSA_BITS: i64 = 23;
/// `1.5 * 2^23`, the f32 whose mantissa's low bits hold the integer added to it.
const MAGIC_INTEGER: f64 = 12_582_912.0;
const EXPONENT_BIAS: f64 = 127.0;
const MAX_NORMAL_EXPONENT: f64 = 254.0;
const F32: Type = Type::Float(Width(32));

impl Interpreter<'_> {
    /// `(v - bits(c)) & 0xff800000` for a float `v`: its exponent field `k * 2^23` below `c`.
    pub(in crate::eval) fn exponent_field(
        &mut self,
        ty: ScalarType,
        a: ExprId,
        b: ExprId,
    ) -> Option<ExprId> {
        if ty.bits() != 32 {
            return None;
        }

        let is_mask = |e: ExprId| {
            self.arena
                .as_int_const(e)
                .is_some_and(|m| m as u32 == EXPONENT_MASK)
        };
        let shifted = if is_mask(b) {
            a
        } else if is_mask(a) {
            b
        } else {
            return None;
        };

        let (v, c) = self.offset_float(shifted)?;
        let k = self.exponent_below(v, c);
        let unit = self.arena.int(MANTISSA_UNIT);

        Some(
            self.arena
                .mul(Type::Int(Signedness::Signed, Width(32)), unit, k),
        )
    }

    /// `v - field` for the exponent field of the same float `v`: its mantissa `v * 2^-k`.
    pub(in crate::eval) fn mantissa(
        &mut self,
        ty: ScalarType,
        v: ExprId,
        field: ExprId,
    ) -> Option<ExprId> {
        if ty.bits() != 32 {
            return None;
        }

        let ExprNode::Mul(p, q) = *self.arena.node(field) else {
            return None;
        };
        let k = if self.arena.as_int_const(p) == Some(MANTISSA_UNIT) {
            q
        } else if self.arena.as_int_const(q) == Some(MANTISSA_UNIT) {
            p
        } else {
            return None;
        };

        let ExprNode::Floor(log2) = *self.arena.node(k) else {
            return None;
        };
        let ExprNode::Div(log, _) = *self.arena.node(log2) else {
            return None;
        };
        let ExprNode::Log(ratio) = *self.arena.node(log) else {
            return None;
        };
        let ExprNode::Div(numerator, _) = *self.arena.node(ratio) else {
            return None;
        };
        if numerator != v {
            return None;
        }

        let ln2 = self.ln2();
        let negated = self.arena.neg(F32, k);
        let exponent = self.arena.mul(F32, negated, ln2);
        let scale = self.arena.exp(F32, exponent);

        Some(self.arena.mul(F32, v, scale))
    }

    /// `v <u bits(f)` for a float `v` and a positive float or infinity `f`: a float's bits are
    /// below `f`'s exactly when it is non-negative and below `f`.
    pub(in crate::eval) fn below_bits(
        &mut self,
        cmp: CmpOp,
        ty: ScalarType,
        a: ExprId,
        b: ExprId,
    ) -> Option<ExprId> {
        let unsigned = matches!(cmp, CmpOp::Lo) || ty.is_unsigned_int() || ty.is_bits_type();
        if ty.bits() != 32 || !unsigned || !matches!(cmp, CmpOp::Lt | CmpOp::Lo) {
            return None;
        }
        if !self.is_float_value(a) {
            return None;
        }

        let bound = self.arena.as_int_const(b)? as u32;
        if bound == 0 || bound > POSITIVE_INFINITY {
            return None;
        }

        let zero = self.arena.int(0);
        let non_negative = self.arena.ge(Type::Pred, a, zero);
        if bound == POSITIVE_INFINITY {
            return Some(non_negative);
        }

        let limit = self
            .arena
            .float_from_f64(f32::from_bits(bound) as f64)
            .ok()?;
        let below = self.arena.lt(Type::Pred, a, limit);

        Some(self.arena.and(Type::Pred, non_negative, below))
    }

    /// `bits(j) << 23` for `j = fma(t, c, 1.5 * 2^23 + b)`, `t` saturated to `[0, 1]`: the low
    /// bits of `j`'s mantissa hold the integer `b + c * t`, so the shift makes the f32 `2^(j -
    /// 12583039)`, normal and positive while `1 <= b` and `b + c <= 254`.
    pub(in crate::eval) fn exponent_scale(
        &mut self,
        ty: ScalarType,
        j: ExprId,
        amount: ExprId,
    ) -> Option<ExprId> {
        if ty.bits() != 32 || self.arena.as_int_const(amount) != Some(MANTISSA_BITS) {
            return None;
        }

        let ExprNode::Fma(p, q, addend) = *self.arena.node(j) else {
            return None;
        };
        let (saturated, factor) = if self.is_saturated(p) { (p, q) } else { (q, p) };
        if !self.is_saturated(saturated) {
            return None;
        }

        let integer = |x: f64| (x.fract() == 0.0).then_some(x);
        let factor = integer(self.arena.as_f64(factor)?)?;
        let offset = integer(self.arena.as_f64(addend)?)? - MAGIC_INTEGER;
        if offset < 1.0 || factor < 0.0 || offset + factor > MAX_NORMAL_EXPONENT {
            return None;
        }

        let bias = self
            .arena
            .float_from_f64(MAGIC_INTEGER + EXPONENT_BIAS)
            .ok()?;
        let exponent = self.arena.sub(F32, j, bias);
        let ln2 = self.ln2();
        let scaled = self.arena.mul(F32, exponent, ln2);

        Some(self.arena.exp(F32, scaled))
    }

    /// Whether `e` is `min(max(x, 0), 1)`, a `.sat` result.
    fn is_saturated(&self, e: ExprId) -> bool {
        let is = |e: ExprId, c: f64| self.arena.as_f64(e) == Some(c);
        let ExprNode::Min(p, q) = *self.arena.node(e) else {
            return false;
        };
        let low = match (is(p, 1.0), is(q, 1.0)) {
            (true, _) => q,
            (_, true) => p,
            _ => return false,
        };
        matches!(*self.arena.node(low), ExprNode::Max(a, b) if is(a, 0.0) || is(b, 0.0))
    }

    /// `(v, c)` of `v - bits(c)`, an `add` or `sub` of a float and a constant whose negation or
    /// value is a positive normal f32's bits.
    fn offset_float(&mut self, id: ExprId) -> Option<(ExprId, f32)> {
        let (v, subtracted) = match *self.arena.node(id) {
            ExprNode::Add(p, q) => {
                if let Some(k) = self.arena.as_int_const(q) {
                    (p, k.wrapping_neg())
                } else {
                    (q, self.arena.as_int_const(p)?.wrapping_neg())
                }
            }
            ExprNode::Sub(p, q) => (p, self.arena.as_int_const(q)?),
            _ => return None,
        };

        let c = f32::from_bits(subtracted as u32);
        (self.is_float_value(v) && c.is_normal() && c > 0.0).then_some((v, c))
    }

    /// `floor(log(v / c) / log 2)`.
    fn exponent_below(&mut self, v: ExprId, c: f32) -> ExprId {
        let c = self
            .arena
            .float_from_f64(c as f64)
            .expect("a normal f32 is not NaN");
        let ratio = self.arena.div(F32, v, c);
        let log = self.arena.log(F32, ratio);
        let ln2 = self.ln2();
        let log2 = self.arena.div(F32, log, ln2);

        self.arena.floor(F32, log2)
    }

    fn ln2(&mut self) -> ExprId {
        let two = self.arena.int(2);
        self.arena.log(F32, two)
    }
}
