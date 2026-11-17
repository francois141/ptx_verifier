//! `ExprArena`'s constructors: each pushes its node as given, folding nothing.

use super::node::{ExprArena, ExprId, ExprNode, NanError, Real, StringId, SymbolId};

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

    pub fn add(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Add(a, b))
    }

    pub fn sub(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Sub(a, b))
    }

    pub fn mul(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Mul(a, b))
    }

    pub fn div(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Div(a, b))
    }

    pub fn rem(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Rem(a, b))
    }

    pub fn neg(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Neg(a))
    }

    pub fn exp(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Exp(a))
    }

    pub fn exp2(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Exp2(a))
    }

    pub fn log(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Log(a))
    }

    pub fn log2(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Log2(a))
    }

    pub fn sqrt(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Sqrt(a))
    }

    pub fn rcp(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Rcp(a))
    }

    pub fn erf(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Erf(a))
    }

    pub fn gelu(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Gelu(a))
    }

    pub fn max(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Max(a, b))
    }

    pub fn min(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Min(a, b))
    }

    pub fn abs(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Abs(a))
    }

    pub fn sign(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Sign(a))
    }

    pub fn round_even(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::RoundEven(a))
    }

    pub fn trunc(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Trunc(a))
    }

    pub fn fma(&mut self, a: ExprId, b: ExprId, c: ExprId) -> ExprId {
        self.operation(ExprNode::Fma(a, b, c))
    }

    /// `array_name[index]` of a launch-config input array.
    pub fn symbolic_read(&mut self, array_name: &str, index: ExprId) -> ExprId {
        let array = self.strings.push(array_name.to_string());
        self.operation(ExprNode::SymbolicRead { array, index })
    }

    pub fn bit_and(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::BitAnd(a, b))
    }

    pub fn bit_or(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::BitOr(a, b))
    }

    pub fn bit_xor(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::BitXor(a, b))
    }

    pub fn bit_not(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::BitNot(a))
    }

    pub fn shl(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Shl(a, b))
    }

    pub fn shr(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Shr(a, b))
    }

    pub fn lshr(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::LShr(a, b))
    }

    pub fn eq(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Eq(a, b))
    }

    pub fn ne(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Ne(a, b))
    }

    pub fn lt(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Lt(a, b))
    }

    pub fn le(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Le(a, b))
    }

    pub fn gt(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Gt(a, b))
    }

    pub fn ge(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Ge(a, b))
    }

    pub fn and(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::And(a, b))
    }

    pub fn or(&mut self, a: ExprId, b: ExprId) -> ExprId {
        self.operation(ExprNode::Or(a, b))
    }

    pub fn not(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::Not(a))
    }

    pub fn select(&mut self, cond: ExprId, then_val: ExprId, else_val: ExprId) -> ExprId {
        self.operation(ExprNode::Select(cond, then_val, else_val))
    }

    pub fn to_float(&mut self, a: ExprId) -> ExprId {
        self.operation(ExprNode::ToFloat(a))
    }
}
