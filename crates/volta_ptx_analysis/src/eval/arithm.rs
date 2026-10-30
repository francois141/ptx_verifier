//! Arithmetic evaluation: binary and unary ops, comparisons, `cvt`, and
//! the canonicalization of integer operands and of values crossing a
//! register or memory width.

use crate::frontend::ast::{ClampWrapMode, ScalarType, ShiftDir};

use crate::eval::ThreadId;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::float_bits;
use crate::eval::interp::{Interpreter, reg_bits};
use crate::eval::value::Value;
use crate::ir::symbols::RegId;
use crate::ir::types::ScalarTypeExt;
use crate::ir::{BinOp, Clamp, CmpOp, InstrId, Operand, UnaryOp};
use crate::logging::warn;
use volta_expr::{ExprId, ExprNode, Real};

/// `log2(e)` rounded to float32 - the constant PTX kernels actually
/// multiply by before `ex2`, and the one Volta's base conversion is
/// anchored to (see [`Interpreter::ln2_constant`]).
const LOG2_E_F32: f64 = std::f64::consts::LOG2_E as f32 as f64;

/// Which 16-bit half of a `.b32` funnel-shift operand to read.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum LaneHalf {
    Low,
    High,
}

impl<'p> Interpreter<'p> {
    /// Evaluate a binary op: exact width/signedness semantics on concrete
    /// integers, real-valued nodes for symbolic values.
    pub(in crate::eval) fn eval_binop(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        a: ExprId,
        b: ExprId,
    ) -> EvalResult<ExprId> {
        if ty.is_predicate() {
            return self.eval_pred_binop(pc, op, a, b);
        }

        if !ty.is_float()
            && let (Some(ca), Some(cb)) = (self.arena.as_i64(a), self.arena.as_i64(b))
        {
            let r = self.concrete_int_binop(t, pc, op, ty, ca, cb)?;
            return Ok(self.arena.int(r));
        }

        // Reinterpret a concrete side at `ty`, except for integer add/sub/mul,
        // which only see it mod 2^N: `add.u32 %r, %sym, -1` keeps its `-1`.
        let (a, b) = if ty.is_integer() && matches!(op, BinOp::Add | BinOp::Sub | BinOp::Mul) {
            (a, b)
        } else {
            (
                self.canon_operand(pc, ty, a)?,
                self.canon_operand(pc, ty, b)?,
            )
        };

        // Symbolic integer div is unsupported: PTX truncates and wraps, but `Div` is exact rational
        // division, so `(x / 2) * 2` would be proved equal to `x` (concrete operands folded above).
        if op == BinOp::Div && !ty.is_float() {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "div.{} on a symbolic operand: integer division truncates and wraps, \
                     which the rational Div node cannot model",
                    format!("{ty:?}").to_lowercase()
                ),
            });
        }

        Ok(match op {
            BinOp::Add => self.arena.add(a, b),
            BinOp::Sub => self.arena.sub(a, b),
            BinOp::Mul => self.arena.mul(a, b),
            BinOp::Div => self.arena.div(a, b),
            BinOp::Rem => self.arena.rem(a, b),
            BinOp::And => self.arena.bit_and(a, b),
            BinOp::Or => self.arena.bit_or(a, b),
            BinOp::Xor => self.eval_xor(ty, a, b),
            BinOp::Shl => self.arena.shl(a, b),
            BinOp::Shr => {
                if ty.is_signed_int() {
                    self.arena.shr(a, b)
                } else {
                    self.arena.lshr(a, b)
                }
            }
            BinOp::Min => self.arena.min(a, b),
            BinOp::Max => self.arena.max(a, b),
        })
    }

    /// A symbolic `xor`, always an opaque `bit_xor`: a sign-bit flip negates floats but not
    /// integers, and untyped `.b*` data can't tell them apart, so it warns to use `neg` instead.
    fn eval_xor(&mut self, ty: ScalarType, a: ExprId, b: ExprId) -> ExprId {
        let sign_bit: Option<i64> = match ty.bits() {
            16 => Some(0x8000),
            32 => Some(0x8000_0000),
            64 => Some(0x8000_0000_0000_0000u64 as i64),
            _ => None,
        };
        let mask = self.arena.as_int_const(a).or(self.arena.as_int_const(b));
        if let Some(bits) = sign_bit
            && mask == Some(bits)
        {
            warn!(
                "xor.b{} with the sign-bit mask {:#x} is kept as an opaque bitwise op, \
                 not a negation; to negate a float, use a neg.f{} instruction instead",
                ty.bits(),
                bits as u64,
                ty.bits()
            );
        }
        self.arena.bit_xor(a, b)
    }

    /// `lop3.b32` over operands not all concrete (`symbolic` positions; `words`
    /// the rest): each symbolic `x` is Shannon-expanded as `low ^ (x & (low ^ high))`,
    /// exact bitwise, folding to one masked xor for the f16 sign-decode idiom.
    pub(in crate::eval) fn lop3_expand(
        &mut self,
        lut: u32,
        sources: [ExprId; 3],
        words: [u32; 3],
        symbolic: &[usize],
    ) -> ExprId {
        const ALL_ONES: i64 = u32::MAX as i64;
        let Some((&position, rest)) = symbolic.split_first() else {
            return self.arena.int(i64::from(lop3_truth_table(lut, words)));
        };
        let mut low_words = words;
        low_words[position] = 0;
        let mut high_words = words;
        high_words[position] = u32::MAX;
        let low = self.lop3_expand(lut, sources, low_words, rest);
        let high = self.lop3_expand(lut, sources, high_words, rest);
        let difference = self.b32_xor(low, high);
        let selected = match self.arena.as_int_const(difference) {
            Some(0) => return low,
            Some(ALL_ONES) => sources[position],
            _ => self.arena.bit_and(sources[position], difference),
        };
        self.b32_xor(low, selected)
    }

    /// `a ^ b` over 32-bit bit patterns, applying `x ^ 0 = x` here since the
    /// arena's folding is width-agnostic; a symbolic side goes through
    /// [`Self::eval_xor`].
    fn b32_xor(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.arena.as_int_const(a), self.arena.as_int_const(b)) {
            (Some(x), Some(y)) => self.arena.int(x ^ y),
            (Some(0), _) => b,
            (_, Some(0)) => a,
            _ => self.eval_xor(ScalarType::B32, a, b),
        }
    }

    /// Exact concrete integer semantics for `ty`.
    fn concrete_int_binop(
        &self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        a: i64,
        b: i64,
    ) -> EvalResult<i64> {
        let bits = ty.bits().min(64);
        let signed = ty.is_signed_int();
        let ua = mask_to(a, bits);
        let ub = mask_to(b, bits);
        let sa = canon_int(a, bits, true);
        let sb = canon_int(b, bits, true);

        let raw: u64 = match op {
            BinOp::Add => ua.wrapping_add(ub),
            BinOp::Sub => ua.wrapping_sub(ub),
            BinOp::Mul => ua.wrapping_mul(ub),
            BinOp::Div => {
                if ub == 0 {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("division by zero (thread {})", t),
                    });
                }
                if signed {
                    sa.wrapping_div(sb) as u64
                } else {
                    ua / ub
                }
            }
            BinOp::Rem => {
                if ub == 0 {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("remainder by zero (thread {})", t),
                    });
                }
                if signed {
                    sa.wrapping_rem(sb) as u64
                } else {
                    ua % ub
                }
            }
            BinOp::And => ua & ub,
            BinOp::Or => ua | ub,
            BinOp::Xor => ua ^ ub,
            // PTX shifts clamp: shifting by >= width produces 0 (or the sign
            // fill for arithmetic right shift).
            BinOp::Shl => {
                let amount = mask_to(b, 32);
                if amount >= bits as u64 {
                    0
                } else {
                    ua << amount
                }
            }
            BinOp::Shr => {
                let amount = mask_to(b, 32);
                if signed {
                    let sh = amount.min(bits as u64 - 1);
                    (sa >> sh) as u64
                } else if amount >= bits as u64 {
                    0
                } else {
                    ua >> amount
                }
            }
            BinOp::Min => {
                if signed {
                    sa.min(sb) as u64
                } else {
                    ua.min(ub)
                }
            }
            BinOp::Max => {
                if signed {
                    sa.max(sb) as u64
                } else {
                    ua.max(ub)
                }
            }
        };
        Ok(canon_int(raw as i64, bits, signed))
    }

    /// Boolean (predicate) binary ops.
    fn eval_pred_binop(
        &mut self,
        pc: InstrId,
        op: BinOp,
        a: ExprId,
        b: ExprId,
    ) -> EvalResult<ExprId> {
        if let (Some(ca), Some(cb)) = (self.arena.as_bool(a), self.arena.as_bool(b)) {
            let r = match op {
                BinOp::And => ca && cb,
                BinOp::Or => ca || cb,
                BinOp::Xor => ca != cb,
                _ => {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("{} on predicates", op.as_str()),
                    });
                }
            };
            return Ok(self.arena.bool_val(r));
        }
        Ok(match op {
            BinOp::And => self.arena.and(a, b),
            BinOp::Or => self.arena.or(a, b),
            // Boolean xor is inequality.
            BinOp::Xor => self.arena.ne(a, b),
            _ => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!("{} on predicates", op.as_str()),
                });
            }
        })
    }

    /// `2^a` as Volta models PTX `ex2`: `exp(a * ln 2)`, or `exp(v)` for the
    /// `ex2(v * log2(e))` idiom.
    pub(in crate::eval) fn ex2(&mut self, pc: InstrId, a: ExprId) -> EvalResult<ExprId> {
        if let Some(folded) = self.fold_exp_idiom(a) {
            return Ok(folded);
        }
        let ln2 = self.ln2_constant(pc)?;
        let scaled = self.arena.mul(a, ln2);
        Ok(self.arena.exp(scaled))
    }

    /// Folds the PTX `exp(v)` idiom `ex2(v * c)`, `c` within float32 rounding of
    /// ±log2(e) (possibly spread per term over an `Fma`/`Add` chain, see
    /// [`Self::factor_log2e`]), to an exact `exp(...)`; `None` if `a` doesn't factor.
    fn fold_exp_idiom(&mut self, a: ExprId) -> Option<ExprId> {
        let argument = self.factor_log2e(a)?;
        Some(self.arena.exp(argument))
    }

    /// `ln 2` as the exact reciprocal of float32's `log2(e)`, read by `ex2` and
    /// `lg2`: scaled exponentials then canonicalize exactly to a spec's `exp` form
    /// and `ex2(lg2(x))` cancels, where an f64 `ln 2` would leave ~1e-8 error.
    fn ln2_constant(&mut self, pc: InstrId) -> EvalResult<ExprId> {
        let unsupported = |what: String| EvalError::Unsupported { pc, what };
        let log2e = Real::from_f64(LOG2_E_F32)
            .map_err(|e| unsupported(format!("ex2/lg2 log2(e) constant: {e}")))?;
        let ln2 = log2e
            .try_recip()
            .ok_or_else(|| unsupported("ex2/lg2 log2(e) constant is zero".to_string()))?;
        Ok(self.arena.real(ln2))
    }

    /// Pulls a `log2(e)`-ish constant (within float32 rounding) out of a
    /// `Mul`/`Fma`/`Add` chain, folding in each term's sign, so that
    /// `a == log2e * factor_log2e(a)`; `None` when no such factor exists.
    fn factor_log2e(&mut self, a: ExprId) -> Option<ExprId> {
        let log2e = std::f64::consts::LOG2_E;
        let is_log2e_like = |value: f64| (value.abs() - log2e).abs() <= log2e * 1e-6;
        match self.arena.node(a).clone() {
            ExprNode::Mul(l, r) => {
                for (constant, other) in [(l, r), (r, l)] {
                    let value = match self.arena.node(constant) {
                        ExprNode::RealConst(real) => real.to_f64(),
                        _ => continue,
                    };
                    if !is_log2e_like(value) {
                        continue;
                    }
                    return Some(if value < 0.0 {
                        self.arena.neg(other)
                    } else {
                        other
                    });
                }
                None
            }
            ExprNode::Fma(x, c, rest) => {
                let value = match self.arena.node(c) {
                    ExprNode::RealConst(real) => real.to_f64(),
                    _ => return None,
                };
                if !is_log2e_like(value) {
                    return None;
                }
                let x_signed = if value < 0.0 { self.arena.neg(x) } else { x };
                let rest_factored = self.factor_log2e(rest)?;
                Some(self.arena.add(x_signed, rest_factored))
            }
            ExprNode::Add(l, r) => {
                let l_factored = self.factor_log2e(l)?;
                let r_factored = self.factor_log2e(r)?;
                Some(self.arena.add(l_factored, r_factored))
            }
            _ => None,
        }
    }

    pub(in crate::eval) fn eval_unop(
        &mut self,
        pc: InstrId,
        op: UnaryOp,
        ty: ScalarType,
        a: ExprId,
    ) -> EvalResult<ExprId> {
        // Re-read the operand as `ty` (signed width, float bits decoded) -
        // except for `not`, a pure bit operation.
        let a = if matches!(op, UnaryOp::Not) {
            a
        } else {
            self.canon_operand(pc, ty, a)?
        };
        Ok(match op {
            // Wrap the result back to `ty`: `neg.s32`/`abs.s32` of i32::MIN
            // is i32::MIN.
            UnaryOp::Neg => {
                let r = self.arena.neg(a);
                self.canon_operand(pc, ty, r)?
            }
            UnaryOp::Abs => {
                let r = self.arena.abs(a);
                self.canon_operand(pc, ty, r)?
            }
            UnaryOp::Not => {
                if ty.is_predicate() {
                    if let Some(c) = self.arena.as_bool(a) {
                        self.arena.bool_val(!c)
                    } else {
                        self.arena.not(a)
                    }
                } else {
                    // Bitwise not; folds when concrete (via canonical i64).
                    let bits = ty.bits().min(64);
                    if let Some(c) = self.arena.as_i64(a) {
                        let r = canon_int(!c, bits, ty.is_signed_int());
                        self.arena.int(r)
                    } else {
                        self.arena.bit_not(a)
                    }
                }
            }
            UnaryOp::Rcp => self.arena.rcp(a),
            UnaryOp::Sqrt => self.arena.sqrt(a),
            UnaryOp::Rsqrt => {
                let s = self.arena.sqrt(a);
                self.arena.rcp(s)
            }
            UnaryOp::Exp => self.arena.exp(a),
            // 2^x = e^(x*ln2) keeps this in the exp fragment. The `ex2(v * log2e)`
            // exp idiom (a float32 log2e, so exp(v * 0.99999999...) over the
            // reals) is first folded to an exact exp(v), like ex2.approx as 2^x.
            UnaryOp::Ex2 => self.ex2(pc, a)?,
            // tanh(x) = (e^2x - 1) / (e^2x + 1), so this too stays in the
            // interpreted exp fragment rather than becoming an opaque atom
            // (same approach as `Ex2` above).
            UnaryOp::Tanh => {
                let two = self.arena.int(2);
                let one = self.arena.int(1);
                let two_x = self.arena.mul(a, two);
                let e2x = self.arena.exp(two_x);
                let num = self.arena.sub(e2x, one);
                let den = self.arena.add(e2x, one);
                self.arena.div(num, den)
            }
            // PTX has no natural log: `lg2.approx` is how one is spelled,
            // so it is read as an exact log(a) / ln2 rather than an opaque
            // atom - the mirror of `Ex2` above.
            UnaryOp::Lg2 => {
                let log = self.arena.log(a);
                let ln2 = self.ln2_constant(pc)?;
                self.arena.div(log, ln2)
            }
        })
    }

    /// Reinterpret a concrete integer operand as canonical for `ty`, since values
    /// are canonicalized by their producer (`mul.wide.u16 %r, %rs, -17873` means
    /// 47663); a float `ty` decodes its bits. Symbolic values and `Real`s pass through.
    pub(in crate::eval) fn canon_operand(
        &mut self,
        pc: InstrId,
        ty: ScalarType,
        e: ExprId,
    ) -> EvalResult<ExprId> {
        if ty.is_float() {
            return float_bits::decode_float_bits(&mut self.arena, pc, ty, e);
        }
        Ok(self.canon_int_operand(ty, e))
    }

    /// [`Self::canon_operand`] for an integer, bits or predicate `ty`.
    fn canon_int_operand(&mut self, ty: ScalarType, e: ExprId) -> ExprId {
        if ty.is_predicate() {
            return e;
        }
        if let Some(c) = self.arena.as_int_const(e) {
            let canon = canon_int(c, ty.bits().min(64), ty.is_signed_int());
            if canon != c {
                return self.arena.int(canon);
            }
        }
        e
    }

    /// Canonicalize a value crossing a store: concrete integers keep the store
    /// type's unsigned low bits (`st.u8` of 300 stores 44). A symbolic value or pair
    /// stored below its source register's width is a loud error (no truncation node).
    pub(in crate::eval) fn canon_stored(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        ty: ScalarType,
        src_reg_bits: Option<u32>,
        v: Value,
    ) -> EvalResult<Value> {
        // PTX ISA 9.4.1: "When a source operand has a size that exceeds the instruction-type
        // size, the source data is truncated (chopped) to the appropriate number of bits
        // specified by the instruction type-size": a half-width store keeps a pair's low lane.
        if let Value::Pair(lo, _) = v
            && src_reg_bits == Some(2 * ty.bits())
        {
            return Ok(Value::Scalar(lo));
        }
        if matches!(v, Value::Pair(..)) && src_reg_bits.is_none_or(|reg_bits| ty.bits() < reg_bits)
        {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "packed pair stored at sub-register width \
                     ({}-bit store, thread {})",
                    ty.bits(),
                    t
                ),
            });
        }
        if matches!(v, Value::Mbarrier(_)) {
            return Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "mbarrier handle stored as ordinary program data",
            });
        }
        if ty.is_float() || ty.is_predicate() {
            return Ok(v);
        }
        let Value::Scalar(e) = v else {
            return Ok(v); // packed f16 pairs at full width
        };
        if let Some(c) = self.arena.as_int_const(e) {
            let canon = canon_int(c, ty.bits().min(64), false);
            return Ok(if canon == c {
                v
            } else {
                Value::Scalar(self.arena.int(canon))
            });
        }
        if let Some(reg_bits) = src_reg_bits
            && ty.bits() < reg_bits
            && !self.arena.is_undefined(e)
            && !self.arena.is_concrete(e)
        {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "symbolic value stored at sub-register width \
                     ({}-bit store of a {}-bit register, thread {})",
                    ty.bits(),
                    reg_bits,
                    t
                ),
            });
        }
        Ok(v)
    }

    /// Zero-extending a symbolic 32-bit value into 64 bits is exactly the pair
    /// (value, 0): how nvcc/Triton feed an f32 into an `f32x2` lane (load or
    /// `cvt.u64.u32`). `None` when the shape doesn't match.
    pub(in crate::eval) fn zero_extend_to_pair(
        &mut self,
        src_bits: u32,
        src_signed: bool,
        dst_bits: u32,
        e: ExprId,
    ) -> Option<Value> {
        if src_bits == 32
            && dst_bits == 64
            && !src_signed
            && !self.arena.is_undefined(e)
            && !self.arena.is_concrete(e)
        {
            let zero = self.arena.int(0);
            Some(Value::Pair(e, zero))
        } else {
            None
        }
    }

    /// Canonicalize a value crossing a load: extend per the load type's ISA rule
    /// (`ld.s8` of 0xFF is -1, `ld.u8` 255). A symbolic narrow *signed* load is a
    /// loud error (no sign-extension node); zero-extension is exact and passes through.
    pub(in crate::eval) fn canon_loaded(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        ty: ScalarType,
        dst: RegId,
        v: Value,
    ) -> EvalResult<Value> {
        if matches!(v, Value::Mbarrier(_)) {
            return Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "mbarrier handle loaded as ordinary program data",
            });
        }
        if ty.is_float() || ty.is_predicate() {
            return Ok(v);
        }
        // A 64-bit load's quad is the 4x16 one `Memory::read` builds from two f16x2 words.
        if let Value::Quad(l0, l1, l2, l3) = v
            && ty.bits() == 64
        {
            return Ok(self.pack_b64_lanes([l0, l1, l2, l3]));
        }
        let Value::Scalar(e) = v else {
            return Ok(v); // packed f16 pairs
        };
        if let Some(c) = self.arena.as_int_const(e) {
            let canon = canon_int(c, ty.bits().min(64), ty.is_signed_int());
            return Ok(if canon == c {
                v
            } else {
                Value::Scalar(self.arena.int(canon))
            });
        }
        let dst_bits = reg_bits(dst);
        if let Some(pair) = self.zero_extend_to_pair(ty.bits(), ty.is_signed_int(), dst_bits, e) {
            return Ok(pair);
        }
        if ty.bits() < dst_bits
            && ty.is_signed_int()
            && !self.arena.is_undefined(e)
            && !self.arena.is_concrete(e)
        {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "symbolic value loaded at sub-register width \
                     ({}-bit load into a {}-bit register, thread {})",
                    ty.bits(),
                    dst_bits,
                    t
                ),
            });
        }
        Ok(v)
    }

    /// Widening product: operands are reinterpreted at the source type, and
    /// the product is exact in the 2x-wide destination type.
    pub(in crate::eval) fn mul_wide(&mut self, src_ty: ScalarType, a: ExprId, b: ExprId) -> ExprId {
        let a = self.canon_int_operand(src_ty, a);
        let b = self.canon_int_operand(src_ty, b);
        self.arena.mul(a, b)
    }

    /// High half of the widening product (nvcc's divide-by-constant idiom).
    /// Composed from existing nodes so it works symbolically and folds when
    /// concrete: `(a * b) >> bits`.
    pub(in crate::eval) fn mul_hi(&mut self, ty: ScalarType, a: ExprId, b: ExprId) -> ExprId {
        let a = self.canon_int_operand(ty, a);
        let b = self.canon_int_operand(ty, b);
        let bits = self.arena.int(ty.bits().min(64) as i64);
        let product = self.arena.mul(a, b);
        if ty.is_signed_int() {
            self.arena.shr(product, bits)
        } else {
            self.arena.lshr(product, bits)
        }
    }

    /// The high half of a 64-bit product: exact on concrete operands (in 128
    /// bits), `None` on a symbolic one, whose high half no expression represents.
    pub(in crate::eval) fn mul_hi_64(
        &mut self,
        ty: ScalarType,
        a: ExprId,
        b: ExprId,
    ) -> Option<ExprId> {
        let (a, b) = (self.arena.as_i64(a)?, self.arena.as_i64(b)?);
        let hi = if ty.is_signed_int() {
            ((a as i128 * b as i128) >> 64) as i64
        } else {
            ((a as u64 as u128 * b as u64 as u128) >> 64) as u64 as i64
        };
        Some(self.arena.int(hi))
    }

    pub(in crate::eval) fn eval_cmp(
        &mut self,
        pc: InstrId,
        cmp: CmpOp,
        ty: ScalarType,
        a: ExprId,
        b: ExprId,
    ) -> EvalResult<ExprId> {
        // Concrete integer comparisons need width/signedness care
        // (`setp.lt.u32` on canonical values would misorder negatives).
        if !ty.is_float()
            && let (Some(ca), Some(cb)) = (self.arena.as_i64(a), self.arena.as_i64(b))
        {
            let bits = ty.bits().min(64);
            let unsigned_cmp = matches!(cmp, CmpOp::Lo | CmpOp::Ls | CmpOp::Hi | CmpOp::Hs)
                || ty.is_unsigned_int()
                || ty.is_bits_type();
            let r = if unsigned_cmp {
                let (ua, ub) = (mask_to(ca, bits), mask_to(cb, bits));
                match cmp {
                    CmpOp::Eq | CmpOp::Equ => ua == ub,
                    CmpOp::Ne | CmpOp::Neu => ua != ub,
                    CmpOp::Lt | CmpOp::Lo | CmpOp::Ltu => ua < ub,
                    CmpOp::Le | CmpOp::Ls | CmpOp::Leu => ua <= ub,
                    CmpOp::Gt | CmpOp::Hi | CmpOp::Gtu => ua > ub,
                    CmpOp::Ge | CmpOp::Hs | CmpOp::Geu => ua >= ub,
                    CmpOp::Num => true,
                    CmpOp::Nan => false,
                }
            } else {
                let (sa, sb) = (canon_int(ca, bits, true), canon_int(cb, bits, true));
                match cmp {
                    CmpOp::Eq | CmpOp::Equ => sa == sb,
                    CmpOp::Ne | CmpOp::Neu => sa != sb,
                    CmpOp::Lt | CmpOp::Ltu => sa < sb,
                    CmpOp::Le | CmpOp::Leu => sa <= sb,
                    CmpOp::Gt | CmpOp::Gtu => sa > sb,
                    CmpOp::Ge | CmpOp::Geu => sa >= sb,
                    CmpOp::Lo | CmpOp::Ls | CmpOp::Hi | CmpOp::Hs => {
                        unreachable!("unsigned comparisons handled above")
                    }
                    CmpOp::Num => true,
                    CmpOp::Nan => false,
                }
            };
            return Ok(self.arena.bool_val(r));
        }

        // Symbolic: reinterpret a concrete side at the instruction type (like
        // eval_binop) so equal values build identical nodes; with no NaNs over
        // the reals, unordered comparisons equal their ordered counterparts.
        let a = self.canon_operand(pc, ty, a)?;
        let b = self.canon_operand(pc, ty, b)?;
        Ok(match cmp {
            CmpOp::Eq | CmpOp::Equ => self.arena.eq(a, b),
            CmpOp::Ne | CmpOp::Neu => self.arena.ne(a, b),
            CmpOp::Lt | CmpOp::Lo | CmpOp::Ltu => self.arena.lt(a, b),
            CmpOp::Le | CmpOp::Ls | CmpOp::Leu => self.arena.le(a, b),
            CmpOp::Gt | CmpOp::Hi | CmpOp::Gtu => self.arena.gt(a, b),
            CmpOp::Ge | CmpOp::Hs | CmpOp::Geu => self.arena.ge(a, b),
            CmpOp::Num => self.arena.bool_val(true),
            CmpOp::Nan => self.arena.bool_val(false),
        })
    }

    /// Decode a concrete fp8 byte via an `eval::float_bits` decoder into an exact
    /// real, erroring loudly on NaN encodings (out of Volta's real-valued model).
    /// `what` names the consuming instruction and format for the message.
    pub(in crate::eval) fn decode_fp8_byte(
        &mut self,
        pc: InstrId,
        what: &str,
        byte: u8,
        decode: fn(u8) -> Option<f64>,
    ) -> EvalResult<ExprId> {
        let value = decode(byte).ok_or_else(|| EvalError::Unsupported {
            pc,
            what: format!(
                "{what}: source byte {byte:#x} encodes NaN, which Volta's real-valued model \
                 cannot represent"
            ),
        })?;
        self.arena
            .float_from_f64(value)
            .map_err(|e| EvalError::Unsupported {
                pc,
                what: format!("{what} decoded constant: {e}"),
            })
    }

    /// Apply a float clamp, exact over the reals: `.relu` is `max(r, 0)`, `.sat`
    /// is `min(max(r, 0), 1)` (the spec's NaN flushing is out of model).
    pub(in crate::eval) fn apply_clamp(&mut self, clamp: Option<Clamp>, r: ExprId) -> ExprId {
        match clamp {
            None => r,
            Some(Clamp::Relu) => {
                let zero = self.arena.real(Real::zero());
                self.arena.max(r, zero)
            }
            Some(Clamp::Sat) => {
                let zero = self.arena.real(Real::zero());
                let one = self.arena.real(Real::one());
                let low_clamped = self.arena.max(r, zero);
                self.arena.min(low_clamped, one)
            }
        }
    }

    pub(in crate::eval) fn eval_cvt(
        &mut self,
        pc: InstrId,
        dst_ty: ScalarType,
        src_ty: ScalarType,
        a: ExprId,
    ) -> EvalResult<ExprId> {
        // Float-to-float conversions are the identity over the reals (rounding
        // deliberately not modeled, per the paper), but the source is still read
        // at its own format: `cvt.f32.f16` of `mov.b16 %h, 0x3C00` is 1.0.
        if dst_ty.is_float() && src_ty.is_float() {
            return float_bits::decode_float_bits(&mut self.arena, pc, src_ty, a);
        }
        if src_ty.is_float() {
            return Err(EvalError::Unsupported {
                pc,
                what: format!("cvt float->int ({:?} -> {:?})", src_ty, dst_ty),
            });
        }
        // Integer source: read at the *source* format first (ISA Table 15), so
        // `and.b32`'s 4294967288 is -8 under `cvt.s64.s32`. Symbolic integers
        // pass through (data, not addresses, in a structured-CTA).
        let a = self.canon_int_operand(src_ty, a);
        if dst_ty.is_float() {
            return Ok(self.arena.to_float(a));
        }
        // ... then the result is renormalized at the destination width.
        if let Some(c) = self.arena.as_int_const(a) {
            let bits = dst_ty.bits().min(64);
            let r = canon_int(c, bits, dst_ty.is_signed_int());
            return Ok(self.arena.int(r));
        }
        Ok(a)
    }

    /// 64-bit bitwise ops with a packed-pair operand, evaluated lane-wise with
    /// exact bit semantics (the nvcc/Triton `f32x2` assembly idiom), and 32-bit
    /// shifts of an `f16x2` pair by one half (Triton's split of a 4-byte load).
    /// `None` if no operand is a pair; errors on inexact patterns.
    pub(in crate::eval) fn pair_bitwise_binop(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        src_a: &Operand,
        src_b: &Operand,
    ) -> EvalResult<Option<Value>> {
        let shift = matches!(op, BinOp::Shl | BinOp::Shr);
        let supported = match ty.bits() {
            64 => shift || matches!(op, BinOp::And | BinOp::Or),
            32 => shift,
            _ => false,
        };
        if !supported {
            return Ok(None);
        }
        let a = self.operand_value(t, pc, src_a)?;
        let b = self.operand_value(t, pc, src_b)?;
        if !matches!(a, Value::Pair(_, _)) && !matches!(b, Value::Pair(_, _)) {
            return Ok(None);
        }
        let unsupported = |what: String| EvalError::Unsupported { pc, what };
        // A concrete 64-bit scalar splits into two concrete lanes; anything
        // else alongside a pair has no lane reading.
        let lanes = |this: &mut Self, v: Value| -> EvalResult<(ExprId, ExprId)> {
            match v {
                Value::Pair(lo, hi) => Ok((lo, hi)),
                Value::Scalar(e) => match this.arena.as_int_const(e) {
                    Some(c) => {
                        let lo = this.arena.int(c & 0xFFFF_FFFF);
                        let hi = this.arena.int((c >> 32) & 0xFFFF_FFFF);
                        Ok((lo, hi))
                    }
                    None => Err(unsupported(
                        "symbolic 64-bit scalar combined bitwise with a packed pair".to_string(),
                    )),
                },
                Value::Quad(..) => Err(unsupported(
                    "packed byte-quad combined bitwise with a packed pair".to_string(),
                )),
                Value::Mbarrier(_) => Err(unsupported(
                    "mbarrier handle combined bitwise with a packed pair".to_string(),
                )),
            }
        };
        let is_zero = |this: &Self, e: ExprId| this.arena.as_int_const(e) == Some(0);
        let is_all_ones = |this: &Self, e: ExprId| this.arena.as_int_const(e) == Some(0xFFFF_FFFF);
        match op {
            BinOp::Shl | BinOp::Shr => {
                let Value::Pair(lo, hi) = a else {
                    return Err(unsupported(
                        "shift amount given as a packed pair".to_string(),
                    ));
                };
                let Value::Scalar(amount) = b else {
                    return Err(unsupported(
                        "packed pair shifted by a packed pair".to_string(),
                    ));
                };
                let half_bits = i64::from(ty.bits() / 2);
                if self.arena.as_int_const(amount) != Some(half_bits) || ty.is_signed_int() {
                    return Err(unsupported(format!(
                        "packed pair shifted by other than a logical {half_bits} ({:?} on {:?})",
                        op, ty
                    )));
                }
                let zero = self.arena.int(0);
                Ok(Some(if op == BinOp::Shl {
                    Value::Pair(zero, lo)
                } else {
                    Value::Pair(hi, zero)
                }))
            }
            BinOp::Or => {
                let (a_lo, a_hi) = lanes(self, a)?;
                let (b_lo, b_hi) = lanes(self, b)?;
                let mut merge = |x: ExprId, y: ExprId| -> EvalResult<ExprId> {
                    if is_zero(self, y) {
                        Ok(x)
                    } else if is_zero(self, x) {
                        Ok(y)
                    } else {
                        match (self.arena.as_int_const(x), self.arena.as_int_const(y)) {
                            (Some(_), Some(_)) => {
                                self.eval_binop(t, pc, BinOp::Or, ScalarType::U32, x, y)
                            }
                            _ => Err(unsupported(
                                "or.b64 of two packed pairs with overlapping symbolic lanes"
                                    .to_string(),
                            )),
                        }
                    }
                };
                let lo = merge(a_lo, b_lo)?;
                let hi = merge(a_hi, b_hi)?;
                Ok(Some(Value::Pair(lo, hi)))
            }
            BinOp::And => {
                let (a_lo, a_hi) = lanes(self, a)?;
                let (b_lo, b_hi) = lanes(self, b)?;
                let mut keep = |x: ExprId, y: ExprId| -> EvalResult<ExprId> {
                    if is_all_ones(self, y) {
                        Ok(x)
                    } else if is_all_ones(self, x) {
                        Ok(y)
                    } else if is_zero(self, x) || is_zero(self, y) {
                        Ok(self.arena.int(0))
                    } else {
                        match (self.arena.as_int_const(x), self.arena.as_int_const(y)) {
                            (Some(_), Some(_)) => {
                                self.eval_binop(t, pc, BinOp::And, ScalarType::U32, x, y)
                            }
                            _ => Err(unsupported(
                                "and.b64 masking inside a packed pair's lane".to_string(),
                            )),
                        }
                    }
                };
                let lo = keep(a_lo, b_lo)?;
                let hi = keep(a_hi, b_hi)?;
                Ok(Some(Value::Pair(lo, hi)))
            }
            _ => Ok(None),
        }
    }

    /// `shf.{l,r}.{clamp,wrap}.b32 dst, lo, hi, shift` (PTX ISA 9.7.9.7):
    /// shift the 64-bit concatenation of `hi`:`lo` and keep one 32-bit end
    /// of it. See `LoweredInstr::Shf` for the bit-level definition.
    #[allow(clippy::too_many_arguments)] // internal helper; the args are the instruction's operands
    pub(in crate::eval) fn eval_shf(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        lo: &Operand,
        hi: &Operand,
        shift: &Operand,
        dir: ShiftDir,
        mode: ClampWrapMode,
    ) -> EvalResult<Value> {
        const WIDTH: i64 = 32;
        const HALF_WIDTH: i64 = WIDTH / 2;
        // Shift the 64-bit value formed by concatenating operands a and b left or right by the amount specified by the unsigned 32-bit value in c
        // https://docs.nvidia.com/cuda/parallel-thread-execution/index.html?utm_source=chatgpt.com#logic-and-shift-instructions-shf
        let raw = i64::from(self.concrete_operand(t, pc, shift, "shf shift amount")? as u32);
        let n = match mode {
            ClampWrapMode::Clamp => raw.clamp(0, WIDTH),
            ClampWrapMode::Wrap => raw & 0x1f,
        };
        let lo_v = self.operand_value(t, pc, lo)?;
        let hi_v = self.operand_value(t, pc, hi)?;

        // Packed f16 lanes have no bit pattern: shifting by 0 or 32 selects
        // one operand, by 16 the middle lanes `Pair(lo.high, hi.low)`.
        if matches!(lo_v, Value::Pair(..)) || matches!(hi_v, Value::Pair(..)) {
            match (dir, n) {
                (ShiftDir::Right, 0) | (ShiftDir::Left, WIDTH) => return Ok(lo_v),
                (ShiftDir::Left, 0) | (ShiftDir::Right, WIDTH) => return Ok(hi_v),
                (_, HALF_WIDTH) => {
                    let result_lo = self.shf_lane(t, pc, lo_v, LaneHalf::High)?;
                    let result_hi = self.shf_lane(t, pc, hi_v, LaneHalf::Low)?;
                    return Ok(Value::Pair(result_lo, result_hi));
                }
                _ => {}
            }
        }

        // Ordinary bit-vector path. The ISA's `(x << (32 - n))` is a
        // 64-bit-concatenation shift, so a 32-bit displacement contributes
        // nothing rather than being an over-wide shift.
        let a = self.scalar_operand(t, pc, lo)?;
        let b = self.scalar_operand(t, pc, hi)?;
        let (hi_shift, lo_shift) = match dir {
            ShiftDir::Left => (n, WIDTH - n),
            ShiftDir::Right => (WIDTH - n, n),
        };

        let zero = self.arena.int(0);
        let hi_part = if hi_shift >= WIDTH {
            zero
        } else {
            let amount = self.arena.int(hi_shift);
            self.eval_binop(t, pc, BinOp::Shl, ScalarType::U32, b, amount)?
        };

        let lo_part = if lo_shift >= WIDTH {
            zero
        } else {
            let amount = self.arena.int(lo_shift);
            self.eval_binop(t, pc, BinOp::Shr, ScalarType::U32, a, amount)?
        };

        let d = self.eval_binop(t, pc, BinOp::Or, ScalarType::U32, hi_part, lo_part)?;

        Ok(Value::Scalar(d))
    }

    /// One 16-bit lane of a `.b32` funnel-shift operand for [`Self::eval_shf`].
    /// A symbolic scalar is accepted for its low lane only (the zero-extended
    /// narrow-load idiom); its high lane is a loud error.
    fn shf_lane(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        v: Value,
        half: LaneHalf,
    ) -> EvalResult<ExprId> {
        const LANE_BITS: u32 = 16;
        const LANE_MASK: i64 = 0xFFFF;
        let e = match v {
            Value::Pair(lo, hi) => {
                return Ok(match half {
                    LaneHalf::Low => lo,
                    LaneHalf::High => hi,
                });
            }
            Value::Scalar(e) => e,
            Value::Quad(..) => {
                return Err(EvalError::ValueKindMismatch {
                    thread: t,
                    pc,
                    what: "shf operand holds a packed byte quad",
                });
            }
            Value::Mbarrier(_) => {
                return Err(EvalError::ValueKindMismatch {
                    thread: t,
                    pc,
                    what: "mbarrier handle used as a shf operand",
                });
            }
        };
        match (self.arena.as_int_const(e), half) {
            (Some(c), LaneHalf::Low) => Ok(self.arena.int(c & LANE_MASK)),
            (Some(c), LaneHalf::High) => Ok(self.arena.int((c >> LANE_BITS) & LANE_MASK)),
            (None, LaneHalf::Low) => Ok(e),
            (None, LaneHalf::High) => Err(EvalError::Unsupported {
                pc,
                what: "shf reading the high 16-bit lane of a symbolic 32-bit operand".to_string(),
            }),
        }
    }

    /// Apply a byte-wise FP8 sign-bit XOR to a packed byte quad. This is the
    /// `xor.b32 value, value, 0x80808080` idiom used before RoPE's FP8
    /// conversion; each quad lane already represents its decoded real value.
    pub(in crate::eval) fn quad_bitwise_binop(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        src_a: &Operand,
        src_b: &Operand,
    ) -> EvalResult<Option<Value>> {
        if ty.bits() != 32 || op != BinOp::Xor {
            return Ok(None);
        }
        let a = self.operand_value(t, pc, src_a)?;
        let b = self.operand_value(t, pc, src_b)?;
        let (lanes, mask) = match (a, b) {
            (Value::Quad(b0, b1, b2, b3), Value::Scalar(mask))
            | (Value::Scalar(mask), Value::Quad(b0, b1, b2, b3)) => ((b0, b1, b2, b3), mask),
            (Value::Quad(..), Value::Quad(..)) => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: "xor.b32 of two packed byte quads".to_string(),
                });
            }
            _ => return Ok(None),
        };
        let mask = self
            .arena
            .as_int_const(mask)
            .ok_or(EvalError::NotConcrete {
                thread: t,
                pc,
                what: "packed byte-quad xor mask",
            })? as u32;
        let apply = |this: &mut Self, lane: ExprId, byte_mask: u32| match byte_mask {
            0 => Ok(lane),
            0x80 => Ok(this.arena.neg(lane)),
            _ => Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "packed byte-quad xor mask {mask:#010x} changes more than an FP8 sign bit"
                ),
            }),
        };
        let b0 = apply(self, lanes.0, mask & 0xff)?;
        let b1 = apply(self, lanes.1, (mask >> 8) & 0xff)?;
        let b2 = apply(self, lanes.2, (mask >> 16) & 0xff)?;
        let b3 = apply(self, lanes.3, (mask >> 24) & 0xff)?;
        Ok(Some(Value::Quad(b0, b1, b2, b3)))
    }

    /// A logical `shr.b64`/`shl.b64` of a 4x16 quad by whole lanes moves the
    /// lanes, zero-filling the vacated ones (TileLang's `shr.u64 %rd, %rd, 16`
    /// before `cvt.u16.u64`). `None` unless the shifted operand is a quad.
    pub(in crate::eval) fn quad_shift_binop(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        src_a: &Operand,
        src_b: &Operand,
    ) -> EvalResult<Option<Value>> {
        if ty.bits() != 64 || !matches!(op, BinOp::Shl | BinOp::Shr) {
            return Ok(None);
        }
        let Value::Quad(l0, l1, l2, l3) = self.operand_value(t, pc, src_a)? else {
            return Ok(None);
        };

        let amount = self.concrete_operand(t, pc, src_b, "packed quad shift amount")?;
        let unsupported = || EvalError::Unsupported {
            pc,
            what: format!(
                "packed quad shifted by other than a logical 16, 32 or 48 ({op:?} by {amount} on {ty:?})"
            ),
        };
        if ty.is_signed_int() {
            return Err(unsupported());
        }

        // Lane 0 is the lowest: a right shift moves the lanes down, a left shift up.
        let zero = self.arena.int(0);
        let shifted = match (op, amount) {
            (BinOp::Shr, 16) => Value::Quad(l1, l2, l3, zero),
            (BinOp::Shr, 32) => Value::Quad(l2, l3, zero, zero),
            (BinOp::Shr, 48) => Value::Quad(l3, zero, zero, zero),
            (BinOp::Shl, 16) => Value::Quad(zero, l0, l1, l2),
            (BinOp::Shl, 32) => Value::Quad(zero, zero, l0, l1),
            (BinOp::Shl, 48) => Value::Quad(zero, zero, zero, l0),
            _ => return Err(unsupported()),
        };
        Ok(Some(shifted))
    }
}

/// `lop3.b32` over three concrete 32-bit sources: result bit `i` is bit
/// `(a_i << 2) | (b_i << 1) | c_i` of the 8-entry truth table.
fn lop3_truth_table(lut: u32, [a, b, c]: [u32; 3]) -> u32 {
    (0..32).fold(0, |result, i| {
        let index = (((a >> i) & 1) << 2) | (((b >> i) & 1) << 1) | ((c >> i) & 1);
        result | (((lut >> index) & 1) << i)
    })
}

/// Zero-extend the low `bits` of `v` into a u64.
fn mask_to(v: i64, bits: u32) -> u64 {
    if bits >= 64 {
        v as u64
    } else {
        (v as u64) & ((1u64 << bits) - 1)
    }
}

/// Canonicalize the low `bits` of `v`: sign-extended if `signed`, else
/// zero-extended.
fn canon_int(v: i64, bits: u32, signed: bool) -> i64 {
    if bits >= 64 {
        return v;
    }
    let masked = mask_to(v, bits);
    if signed {
        let shift = 64 - bits;
        ((masked << shift) as i64) >> shift
    } else {
        masked as i64
    }
}
