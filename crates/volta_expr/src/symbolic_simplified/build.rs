//! `ExprArena`'s constructors, each folding constants eagerly and exactly.

use super::node::{ExprArena, ExprId, ExprNode, NanError, Real, StringId, SymbolId};

impl ExprArena {
    // -----------------------------------------------------------------
    // Atom constructors
    // -----------------------------------------------------------------

    /// Create an integer constant node.
    pub fn int(&mut self, v: i64) -> ExprId {
        self.push(ExprNode::IntConst(v))
    }

    /// Create an exact real constant node.
    pub fn real(&mut self, v: Real) -> ExprId {
        self.push(ExprNode::RealConst(v))
    }

    /// Create a real constant node from an f64, converting exactly. Fallible: NaN has no place in
    /// the reals model (see [`NanError`]), so every f64 ingestion point propagates the error.
    pub fn float_from_f64(&mut self, v: f64) -> Result<ExprId, NanError> {
        Ok(self.real(Real::from_f64(v)?))
    }

    /// Create a boolean constant node.
    pub fn bool_val(&mut self, v: bool) -> ExprId {
        self.push(ExprNode::BoolConst(v))
    }

    /// Create a fresh machine symbolic variable - the constructor for any
    /// value without a launch-config identity (see [`SymbolRef`]).
    pub fn symbol(&mut self) -> ExprId {
        self.push(ExprNode::Symbol(SymbolId::fresh()))
    }

    /// Intern a string, returning its id. Does not deduplicate; callers
    /// creating many nodes that share a string (e.g. one array's elements)
    /// should intern once and reuse the id.
    pub fn intern_string(&mut self, s: impl Into<String>) -> StringId {
        self.strings.push(s.into())
    }

    /// Create a launch-config symbolic parameter (`sym:NAME`); the name
    /// must come from the launch config (see [`SymbolRef`]).
    pub fn param_symbol(&mut self, name: impl Into<String>) -> ExprId {
        let sid = self.strings.push(name.into());
        self.push(ExprNode::ParamSymbol(sid))
    }

    /// Create the symbol for element `index` of the launch-config input
    /// array whose name is interned at `array`.
    pub fn input_element(&mut self, array: StringId, index: u64) -> ExprId {
        self.push(ExprNode::InputElement { array, index })
    }

    /// Create an undefined-value node.
    pub fn undefined(&mut self) -> ExprId {
        self.push(ExprNode::Undefined)
    }

    // =================================================================
    // Arithmetic builders (with eager constant folding)
    // =================================================================

    /// Addition with constant folding (exact on rationals; `inf + -inf` builds the node so canon
    /// fails loudly). An infinite constant also absorbs a *non-constant* (real) operand, keeping
    /// a `-INFINITY` seed out of live expressions.
    pub fn add(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_add(*y);
                return self.int(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_add(y) {
                    return self.real(r);
                }
            }
            (ExprNode::IntConst(0), _) => return b,
            (_, ExprNode::IntConst(0)) => return a,
            // A negative integer constant reads as a subtraction: `x - 1`,
            // not `x + -1` (the same polynomial to the canonicalizer).
            (_, &ExprNode::IntConst(y)) if y < 0 && y != i64::MIN => {
                let magnitude = self.int(-y);
                return self.sub(a, magnitude);
            }
            (&ExprNode::IntConst(x), _) if x < 0 && x != i64::MIN => {
                let magnitude = self.int(-x);
                return self.sub(b, magnitude);
            }
            (ExprNode::RealConst(x), _) if x.is_zero() => return b,
            (_, ExprNode::RealConst(y)) if y.is_zero() => return a,
            (ExprNode::RealConst(x), other) if x.is_infinite() && !other.is_real_const() => {
                return a;
            }
            (other, ExprNode::RealConst(y)) if y.is_infinite() && !other.is_real_const() => {
                return b;
            }
            _ => {}
        }
        self.push(ExprNode::Add(a, b))
    }

    /// Subtraction with constant folding (exact; see [`ExprArena::add`],
    /// including its infinity-absorption rule - here `-inf - x = -inf` and
    /// `x - inf = -inf` for a non-constant, hence real, `x`).
    pub fn sub(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_sub(*y);
                return self.int(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_sub(y) {
                    return self.real(r);
                }
            }
            (_, ExprNode::IntConst(0)) => return a,
            // `x - -7` reads as `x + 7` (see `add`).
            (_, &ExprNode::IntConst(y)) if y < 0 && y != i64::MIN => {
                let magnitude = self.int(-y);
                return self.add(a, magnitude);
            }
            (_, ExprNode::RealConst(y)) if y.is_zero() => return a,
            (ExprNode::RealConst(x), other) if x.is_infinite() && !other.is_real_const() => {
                return a;
            }
            (other, ExprNode::RealConst(y)) if y.is_infinite() && !other.is_real_const() => {
                let r = y.neg();
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Sub(a, b))
    }

    /// Multiplication with constant folding: `0.0 * x = 0` and `1.0 * x = x` over the reals (no
    /// IEEE `0 * inf`). Annihilation keeps `-INFINITY` running-max seeds out of live terms
    /// (`d * e^{m_0 - m_1}` with `d = 0.0` on FlashAttention's first iteration).
    pub fn mul(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_mul(*y);
                return self.int(r);
            }
            // Exact on rationals and the signed inf * nonzero forms;
            // a concrete 0 * inf builds the node unfolded (the arms below
            // must not annihilate it to 0).
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_mul(y) {
                    return self.real(r);
                }
            }
            // An integer zero annihilates like a real zero, except against a concrete
            // infinity: 0 * inf is undefined and builds the node unfolded (as `try_mul`).
            (ExprNode::IntConst(0), other) | (other, ExprNode::IntConst(0)) if !matches!(other, ExprNode::RealConst(r) if r.is_infinite()) =>
            {
                return self.int(0);
            }
            (ExprNode::RealConst(x), _) if x.is_zero() => return self.real(Real::zero()),
            (_, ExprNode::RealConst(y)) if y.is_zero() => return self.real(Real::zero()),
            (ExprNode::IntConst(1), _) => return b,
            (_, ExprNode::IntConst(1)) => return a,
            (ExprNode::RealConst(x), _) if x.is_one() => return b,
            (_, ExprNode::RealConst(y)) if y.is_one() => return a,
            _ => {}
        }
        self.push(ExprNode::Mul(a, b))
    }

    /// Division with constant folding: exact for a nonzero concrete divisor (`1.0 / 3.0` is exactly
    /// 1/3, as `rcp` and canon). `x / 0` and `0 / symbolic` stay unfolded, so a formally-zero
    /// denominator always reaches canon's loud division error.
    pub fn div(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) if *y != 0 => {
                let r = x.wrapping_div(*y);
                return self.int(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                if let Some(r) = x.try_div(y) {
                    return self.real(r);
                }
            }
            (_, ExprNode::IntConst(1)) => return a,
            _ => {}
        }
        self.push(ExprNode::Div(a, b))
    }

    /// Remainder with constant folding (i64 semantics when concrete).
    pub fn rem(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) if *y != 0 => {
                let r = x.wrapping_rem(*y);
                return self.int(r);
            }
            _ => {}
        }
        self.push(ExprNode::Rem(a, b))
    }

    /// Negation with constant folding (total on the extended reals).
    pub fn neg(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::IntConst(x) => {
                let r = x.wrapping_neg();
                return self.int(r);
            }
            ExprNode::RealConst(x) => {
                let r = x.neg();
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Neg(a))
    }

    /// Exponential: e^a. The infinite limits fold (`e^{-inf} = 0`, `e^{inf} = inf`): a running max
    /// seeded at `-INFINITY` reaches here via `ex2`, and the zero keeps the seed out of live terms.
    pub fn exp(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::RealConst(x) = self.node(a) {
            if x.is_neg_inf() {
                return self.real(Real::zero());
            }
            if x.is_pos_inf() {
                return self.real(Real::pos_inf());
            }
        }
        self.push(ExprNode::Exp(a))
    }

    /// Natural logarithm: ln(a)
    pub fn log(&mut self, a: ExprId) -> ExprId {
        self.push(ExprNode::Log(a))
    }

    /// `2^a` over the reals: `exp(a * ln 2)`, or `exp(v)` for the compilers' `exp(v)` idiom
    /// `2^(v * log2(e))`, which kernels spell with a float32 `log2(e)` (an `exp(v * 0.99999...)`
    /// over the reals) and is folded to the exact `exp(v)` it approximates.
    pub fn exp2(&mut self, a: ExprId) -> ExprId {
        if let Some(argument) = self.factor_log2e(a) {
            return self.exp(argument);
        }
        let ln2 = self.ln2_f32();
        let scaled = self.mul(a, ln2);
        self.exp(scaled)
    }

    /// `log2(a)` over the reals, as `log(a) / ln 2`, the mirror of [`Self::exp2`].
    pub fn log2(&mut self, a: ExprId) -> ExprId {
        let log = self.log(a);
        let ln2 = self.ln2_f32();
        self.div(log, ln2)
    }

    /// `ln 2` as the exact reciprocal of float32's `log2(e)`: scaled exponentials then
    /// canonicalize exactly to a spec's `exp` form and `exp2(log2(x))` cancels, where an f64
    /// `ln 2` would leave ~1e-8 error.
    fn ln2_f32(&mut self) -> ExprId {
        let log2e =
            Real::from_f64(f64::from(std::f64::consts::LOG2_E as f32)).expect("log2(e) is not NaN");
        self.real(log2e.try_recip().expect("log2(e) is nonzero"))
    }

    /// Pulls a `log2(e)`-ish constant (within float32 rounding) out of a `Mul`/`Fma`/`Add`
    /// chain, folding in each term's sign, so that `a == log2e * factor_log2e(a)`; `None` when
    /// no such factor exists.
    fn factor_log2e(&mut self, a: ExprId) -> Option<ExprId> {
        let log2e = std::f64::consts::LOG2_E;
        let is_log2e_like = |value: f64| (value.abs() - log2e).abs() <= log2e * 1e-6;
        match self.node(a).clone() {
            ExprNode::Mul(l, r) => {
                for (constant, other) in [(l, r), (r, l)] {
                    let value = match self.node(constant) {
                        ExprNode::RealConst(real) => real.to_f64(),
                        _ => continue,
                    };
                    if !is_log2e_like(value) {
                        continue;
                    }
                    return Some(if value < 0.0 { self.neg(other) } else { other });
                }
                None
            }
            ExprNode::Fma(x, c, rest) => {
                let value = match self.node(c) {
                    ExprNode::RealConst(real) => real.to_f64(),
                    _ => return None,
                };
                if !is_log2e_like(value) {
                    return None;
                }
                let x_signed = if value < 0.0 { self.neg(x) } else { x };
                let rest_factored = self.factor_log2e(rest)?;
                Some(self.add(x_signed, rest_factored))
            }
            ExprNode::Add(l, r) => {
                let l_factored = self.factor_log2e(l)?;
                let r_factored = self.factor_log2e(r)?;
                Some(self.add(l_factored, r_factored))
            }
            _ => None,
        }
    }

    /// Square root: sqrt(a)
    pub fn sqrt(&mut self, a: ExprId) -> ExprId {
        self.push(ExprNode::Sqrt(a))
    }

    /// Reciprocal: 1/a. A nonzero concrete rational folds to its exact reciprocal (consistent with
    /// `div` and canon's field model); `rcp(0)` and the infinities stay symbolic.
    pub fn rcp(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::RealConst(x) = self.node(a)
            && let Some(r) = x.try_recip()
        {
            return self.real(r);
        }
        self.push(ExprNode::Rcp(a))
    }

    /// Maximum with constant folding (exact and total on the extended
    /// reals). `max(-inf, x) = x`: running-max chains start at -INFINITY.
    pub fn max(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x.max(y);
                return self.int(r);
            }
            // Hand back the winning operand's existing node: no clone of
            // the rational, no new node (ties keep the left operand,
            // like `Real::max`).
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                return if x >= y { a } else { b };
            }
            (ExprNode::RealConst(x), _) if x.is_neg_inf() => return b,
            (_, ExprNode::RealConst(y)) if y.is_neg_inf() => return a,
            _ => {}
        }
        if a == b {
            return a;
        }
        self.push(ExprNode::Max(a, b))
    }

    /// Minimum with constant folding (exact and total on the extended
    /// reals). `min(inf, x) = x`: running-min chains start at INFINITY.
    pub fn min(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x.min(y);
                return self.int(r);
            }
            // See `max`: the winning operand's node, cloned from no one.
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                return if x <= y { a } else { b };
            }
            (ExprNode::RealConst(x), _) if x.is_pos_inf() => return b,
            (_, ExprNode::RealConst(y)) if y.is_pos_inf() => return a,
            _ => {}
        }
        if a == b {
            return a;
        }
        self.push(ExprNode::Min(a, b))
    }

    /// Absolute value with constant folding (exact; `abs(+-inf) = inf`).
    pub fn abs(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::IntConst(x) => {
                let r = x.wrapping_abs();
                return self.int(r);
            }
            ExprNode::RealConst(x) => {
                let r = x.abs();
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Abs(a))
    }

    /// Sign: always +1 or -1 (zero counts as non-positive, so `sign(0) =
    /// -1`), with constant folding on a concrete argument.
    pub fn sign(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::IntConst(x) => {
                let r = if *x > 0 { 1 } else { -1 };
                return self.int(r);
            }
            ExprNode::RealConst(x) => {
                let r = Real::from_i64(if x > &Real::zero() { 1 } else { -1 });
                return self.real(r);
            }
            _ => {}
        }
        self.push(ExprNode::Sign(a))
    }

    /// The error function; `erf(0)` folds to 0, the one value it takes exactly at a rational.
    pub fn erf(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::RealConst(x) = self.node(a)
            && x.is_zero()
        {
            return a;
        }
        self.push(ExprNode::Erf(a))
    }

    /// The integer nearest `a`, ties to even: exact on a constant, the identity on an
    /// integer-valued node.
    pub fn round_even(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::RealConst(x) => {
                let rounded = x.round_even();
                self.real(rounded)
            }
            _ if self.is_integer_valued(a) => a,
            _ => self.push(ExprNode::RoundEven(a)),
        }
    }

    /// `a` rounded toward zero: exact on a constant, the identity on an integer-valued node.
    pub fn trunc(&mut self, a: ExprId) -> ExprId {
        match self.node(a) {
            ExprNode::RealConst(x) => {
                let rounded = x.trunc();
                self.real(rounded)
            }
            _ if self.is_integer_valued(a) => a,
            _ => self.push(ExprNode::Trunc(a)),
        }
    }

    fn is_integer_valued(&self, a: ExprId) -> bool {
        matches!(
            self.node(a),
            ExprNode::IntConst(_)
                | ExprNode::RoundEven(_)
                | ExprNode::Trunc(_)
                | ExprNode::ToFloat(_)
        )
    }

    /// Fused multiply-add with constant folding: a * b + c, exact in the rationals. Folds iff
    /// `mul` then `add` would, to the same value, so fused and written-out forms cannot diverge.
    pub fn fma(&mut self, a: ExprId, b: ExprId, c: ExprId) -> ExprId {
        if let (ExprNode::RealConst(x), ExprNode::RealConst(y), ExprNode::RealConst(z)) =
            (self.node(a), self.node(b), self.node(c))
        {
            return match x.try_fma(y, z) {
                Some(r) => self.real(r),
                // An undefined extended-real form (0 * inf, inf - inf):
                // build the node unfolded, skipping the zero identity below.
                None => self.push(ExprNode::Fma(a, b, c)),
            };
        }
        let zero_a = matches!(self.node(a), ExprNode::IntConst(0))
            || matches!(self.node(a), ExprNode::RealConst(x) if x.is_zero());
        let zero_b = matches!(self.node(b), ExprNode::IntConst(0))
            || matches!(self.node(b), ExprNode::RealConst(y) if y.is_zero());
        let inf_a = matches!(self.node(a), ExprNode::RealConst(x) if x.is_infinite());
        let inf_b = matches!(self.node(b), ExprNode::RealConst(y) if y.is_infinite());
        // The zero identity must not swallow an undefined 0 * inf: mixed forms (integer
        // zero, or a non-real addend) skip `try_fma` and must stay unfolded (see `mul`).
        if (zero_a && !inf_b) || (zero_b && !inf_a) {
            return c;
        }
        self.push(ExprNode::Fma(a, b, c))
    }

    /// Symbolic read `array_name[index]` from a launch-config input array: a concrete index
    /// resolves at once to its `InputElement`, else a `SymbolicRead` resolves on TID substitution.
    /// Negative concrete indices wrap into `u64` uniformly (they can't collide with real elements).
    pub fn symbolic_read(&mut self, array_name: &str, index: ExprId) -> ExprId {
        let sid = self.strings.push(array_name.to_string());
        // Eagerly resolve if index is concrete
        if let Some(i) = self.as_i64(index) {
            return self.input_element(sid, i as u64);
        }
        self.push(ExprNode::SymbolicRead { array: sid, index })
    }

    // =================================================================
    // Bitwise builders (with eager constant folding)
    // =================================================================

    /// Bitwise AND with constant folding.
    pub fn bit_and(&mut self, a: ExprId, b: ExprId) -> ExprId {
        if let (ExprNode::IntConst(x), ExprNode::IntConst(y)) = (self.node(a), self.node(b)) {
            let r = *x & *y;
            return self.int(r);
        }
        self.push(ExprNode::BitAnd(a, b))
    }

    /// Bitwise OR with constant folding.
    pub fn bit_or(&mut self, a: ExprId, b: ExprId) -> ExprId {
        if let (ExprNode::IntConst(x), ExprNode::IntConst(y)) = (self.node(a), self.node(b)) {
            let r = *x | *y;
            return self.int(r);
        }
        self.push(ExprNode::BitOr(a, b))
    }

    /// Bitwise XOR with constant folding.
    pub fn bit_xor(&mut self, a: ExprId, b: ExprId) -> ExprId {
        if let (ExprNode::IntConst(x), ExprNode::IntConst(y)) = (self.node(a), self.node(b)) {
            let r = *x ^ *y;
            return self.int(r);
        }
        self.push(ExprNode::BitXor(a, b))
    }

    /// Bitwise NOT with constant folding.
    pub fn bit_not(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::IntConst(x) = *self.node(a) {
            return self.int(!x);
        }
        self.push(ExprNode::BitNot(a))
    }

    /// Left shift with constant folding.
    pub fn shl(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_shl(*y as u32);
                return self.int(r);
            }
            (_, ExprNode::IntConst(0)) => return a,
            _ => {}
        }
        self.push(ExprNode::Shl(a, b))
    }

    /// Arithmetic right shift with constant folding.
    pub fn shr(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = x.wrapping_shr(*y as u32);
                return self.int(r);
            }
            (_, ExprNode::IntConst(0)) => return a,
            _ => {}
        }
        self.push(ExprNode::Shr(a, b))
    }

    /// Logical right shift with constant folding.
    pub fn lshr(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = (*x as u64).wrapping_shr(*y as u32) as i64;
                return self.int(r);
            }
            (_, ExprNode::IntConst(0)) => return a,
            (ExprNode::IntConst(0), _) => return self.int(0),
            _ => {}
        }
        self.push(ExprNode::LShr(a, b))
    }

    // =================================================================
    // Comparison builders (with eager constant folding)
    // =================================================================

    /// Equal with constant folding (exact rational comparison; over the
    /// extended reals equality of concrete constants is decidable, unlike
    /// IEEE where `-0.0 == 0.0` and NaN muddy it - both are out of model).
    pub fn eq(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x == *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = x == y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Eq(a, b))
    }

    /// Not-equal with constant folding (exact; see [`ExprArena::eq`]).
    pub fn ne(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x != *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = x != y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Ne(a, b))
    }

    /// Less-than with constant folding (exact extended-real order).
    pub fn lt(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x < *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x < *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Lt(a, b))
    }

    /// Less-or-equal with constant folding (exact extended-real order).
    pub fn le(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x <= *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x <= *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Le(a, b))
    }

    /// Greater-than with constant folding (exact extended-real order).
    pub fn gt(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x > *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x > *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Gt(a, b))
    }

    /// Greater-or-equal with constant folding (exact extended-real order).
    pub fn ge(&mut self, a: ExprId, b: ExprId) -> ExprId {
        match (self.node(a), self.node(b)) {
            (ExprNode::IntConst(x), ExprNode::IntConst(y)) => {
                let r = *x >= *y;
                return self.bool_val(r);
            }
            (ExprNode::RealConst(x), ExprNode::RealConst(y)) => {
                let r = *x >= *y;
                return self.bool_val(r);
            }
            _ => {}
        }
        self.push(ExprNode::Ge(a, b))
    }

    // =================================================================
    // Boolean builders
    // =================================================================

    /// Logical AND.
    pub fn and(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.push(ExprNode::And(a, b))
    }

    /// Logical OR.
    pub fn or(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.push(ExprNode::Or(a, b))
    }

    /// Logical NOT.
    pub fn not(&mut self, a: ExprId) -> ExprId {
        self.push(ExprNode::Not(a))
    }

    // =================================================================
    // Conditional (with eager folding on concrete condition)
    // =================================================================

    /// Select: cond ? then_val : else_val
    pub fn select(&mut self, cond: ExprId, then_val: ExprId, else_val: ExprId) -> ExprId {
        match self.as_bool(cond) {
            Some(true) => return then_val,
            Some(false) => return else_val,
            None => {}
        }
        if let Some(id) = self.try_fold_sign_select(cond, then_val, else_val) {
            return id;
        }
        self.push(ExprNode::Select(cond, then_val, else_val))
    }

    /// Fold the `setp.{gt,neu}` + `selp` + `selp` signed-step idiom `(v != 0) ? ((v > 0) ? c : -c)
    /// : 0` (same `v` by `ExprId`) to `sign(v) * c`, so a `.spec` file's `sign()` and the compiled
    /// branch canonicalize to one atom rather than unmatchable opaque `Select`s.
    fn try_fold_sign_select(
        &mut self,
        cond: ExprId,
        then_val: ExprId,
        else_val: ExprId,
    ) -> Option<ExprId> {
        let &ExprNode::Ne(v, zero_v) = self.node(cond) else {
            return None;
        };
        if !self.is_zero_const(zero_v) || !self.is_zero_const(else_val) {
            return None;
        }
        let &ExprNode::Select(inner_cond, a, b) = self.node(then_val) else {
            return None;
        };
        let &ExprNode::Gt(v2, zero2) = self.node(inner_cond) else {
            return None;
        };
        if v2 != v || !self.is_zero_const(zero2) {
            return None;
        }
        let (ExprNode::RealConst(ca), ExprNode::RealConst(cb)) = (self.node(a), self.node(b))
        else {
            return None;
        };
        if ca.is_zero() || ca.neg() != cb.clone() {
            return None;
        }
        let c = ca.clone();
        let sign_v = self.sign(v);
        let c_id = self.real(c);
        Some(self.mul(sign_v, c_id))
    }

    /// Whether `id` is the exact constant zero (int or real).
    fn is_zero_const(&self, id: ExprId) -> bool {
        match self.node(id) {
            ExprNode::IntConst(0) => true,
            ExprNode::RealConst(x) => x.is_zero(),
            _ => false,
        }
    }

    // =================================================================
    // Conversions
    // =================================================================

    /// Convert to float (from int), with constant folding. The fold is
    /// exact (an i64 converts to the rational it denotes, not to the
    /// nearest f64), matching canon's identity treatment of `ToFloat`.
    pub fn to_float(&mut self, a: ExprId) -> ExprId {
        if let ExprNode::IntConst(v) = *self.node(a) {
            return self.real(Real::from_i64(v));
        }
        self.push(ExprNode::ToFloat(a))
    }

    /// Create a discarded-value node.
    pub fn discarded(&mut self) -> ExprId {
        self.push(ExprNode::Discarded)
    }
}
