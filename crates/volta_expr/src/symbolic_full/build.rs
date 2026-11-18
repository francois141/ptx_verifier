//! `ExprArena`'s constructors: each pushes its node as given, folding nothing.

use super::node::{ExprArena, ExprId, ExprNode, NanError, Real, StringId, SymbolId, Type, Width};
use super::prmt::PrmtSelector;

impl ExprArena {
    pub fn int(&mut self, v: i64) -> ExprId {
        self.atom(ExprNode::IntConst(v))
    }

    pub fn real(&mut self, v: Real) -> ExprId {
        self.atom(ExprNode::RealConst(v))
    }

    /// A real constant from an f64, converted exactly; NaN is outside the model.
    pub fn float_from_f64(&mut self, v: f64) -> Result<ExprId, NanError> {
        Ok(self.real(Real::from_f64(v)?))
    }

    pub fn bool_val(&mut self, v: bool) -> ExprId {
        self.atom(ExprNode::BoolConst(v))
    }

    /// A fresh machine symbol: the value of anything without a launch-config identity.
    pub fn symbol(&mut self) -> ExprId {
        self.atom(ExprNode::Symbol(SymbolId::fresh()))
    }

    /// Intern a string, without deduplicating.
    pub fn intern_string(&mut self, s: impl Into<String>) -> StringId {
        self.strings.push(s.into())
    }

    /// A launch-config symbolic parameter (`sym:NAME`).
    pub fn param_symbol(&mut self, name: impl Into<String>) -> ExprId {
        let sid = self.strings.push(name.into());
        self.atom(ExprNode::ParamSymbol(sid))
    }

    /// Element `index` of the launch-config input array interned at `array`.
    pub fn input_element(&mut self, array: StringId, index: u64) -> ExprId {
        self.atom(ExprNode::InputElement { array, index })
    }

    pub fn undefined(&mut self) -> ExprId {
        self.atom(ExprNode::Undefined)
    }

    pub fn discarded(&mut self) -> ExprId {
        self.atom(ExprNode::Discarded)
    }

    pub fn add(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Add(a, b))
    }

    pub fn sub(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Sub(a, b))
    }

    pub fn mul(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Mul(a, b))
    }

    pub fn div(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Div(a, b))
    }

    pub fn rem(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Rem(a, b))
    }

    pub fn neg(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Neg(a))
    }

    pub fn exp(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Exp(a))
    }

    pub fn exp2(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Exp2(a))
    }

    pub fn log(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Log(a))
    }

    pub fn log2(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Log2(a))
    }

    pub fn sqrt(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Sqrt(a))
    }

    pub fn rcp(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Rcp(a))
    }

    pub fn erf(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Erf(a))
    }

    pub fn gelu(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Gelu(a))
    }

    pub fn tanh(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Tanh(a))
    }

    /// `1 / sqrt(a)`.
    pub fn rsqrt(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Rsqrt(a))
    }

    /// `1 / (1 + e^-a)`.
    pub fn sigmoid(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Sigmoid(a))
    }

    /// The median of `a`, `b` and `c`.
    pub fn median3(&mut self, ty: Type, a: ExprId, b: ExprId, c: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Median3(a, b, c))
    }

    /// `magnitude`'s magnitude with `sign`'s sign.
    pub fn copysign(&mut self, ty: Type, magnitude: ExprId, sign: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Copysign(magnitude, sign))
    }

    pub fn max(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Max(a, b))
    }

    pub fn min(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Min(a, b))
    }

    pub fn abs(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Abs(a))
    }

    pub fn sign(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Sign(a))
    }

    pub fn round_even(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::RoundEven(a))
    }

    pub fn trunc(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Trunc(a))
    }

    pub fn fma(&mut self, ty: Type, a: ExprId, b: ExprId, c: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Fma(a, b, c))
    }

    /// `array_name[index]` of a launch-config input array.
    pub fn symbolic_read(&mut self, ty: Type, array_name: &str, index: ExprId) -> ExprId {
        let array = self.strings.push(array_name.to_string());
        self.operation(ty, ExprNode::SymbolicRead { array, index })
    }

    pub fn bit_and(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::BitAnd(a, b))
    }

    pub fn bit_or(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::BitOr(a, b))
    }

    pub fn bit_xor(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::BitXor(a, b))
    }

    pub fn bit_not(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::BitNot(a))
    }

    pub fn popc(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Popc(a))
    }

    /// `prmt` of the words `a` and `b`: a 32-bit operation, as the instruction is.
    pub fn prmt(&mut self, a: ExprId, b: ExprId, selector: PrmtSelector) -> ExprId {
        self.operation(Type::Bits(Width(32)), ExprNode::Prmt { a, b, selector })
    }

    pub fn shl(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Shl(a, b))
    }

    pub fn shr(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Shr(a, b))
    }

    pub fn lshr(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::LShr(a, b))
    }

    pub fn eq(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Eq(a, b))
    }

    pub fn ne(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Ne(a, b))
    }

    pub fn lt(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Lt(a, b))
    }

    pub fn le(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Le(a, b))
    }

    pub fn gt(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Gt(a, b))
    }

    pub fn ge(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Ge(a, b))
    }

    pub fn and(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::And(a, b))
    }

    pub fn or(&mut self, ty: Type, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Or(a, b))
    }

    pub fn not(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Not(a))
    }

    pub fn select(&mut self, ty: Type, cond: ExprId, then_val: ExprId, else_val: ExprId) -> ExprId {
        self.operation(ty, ExprNode::Select(cond, then_val, else_val))
    }

    pub fn to_float(&mut self, ty: Type, a: ExprId) -> ExprId {
        self.operation(ty, ExprNode::ToFloat(a))
    }
}
