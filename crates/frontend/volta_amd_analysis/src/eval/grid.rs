//! Copy one workgroup's output expressions into their own arena, retaining shared subexpressions.

use std::collections::HashMap;

use volta_expr::FullOutputs;
use volta_expr::symbolic_full::{ExprArena, ExprId, ExprNode, StringId};

/// Copy the written output elements and the expressions they reference into their own arena.
pub(crate) fn workgroup_outputs(
    arena: &ExprArena,
    outputs: &[(String, Vec<(u64, ExprId)>)],
) -> FullOutputs {
    let mut copier = Copier {
        source: arena,
        target: ExprArena::new(),
        copied: HashMap::new(),
        strings: HashMap::new(),
    };
    let mut arrays = Vec::with_capacity(outputs.len());
    for (name, elements) in outputs {
        let mut copied = Vec::with_capacity(elements.len());
        for &(index, value) in elements {
            copied.push((index, copier.expr(value)));
        }
        arrays.push((name.clone(), copied));
    }
    FullOutputs {
        arena: copier.target,
        outputs: arrays,
    }
}

/// Copies expressions of `source` into `target`, each shared subexpression once.
struct Copier<'a> {
    source: &'a ExprArena,
    target: ExprArena,
    copied: HashMap<ExprId, ExprId>,
    strings: HashMap<StringId, StringId>,
}

impl Copier<'_> {
    fn expr(&mut self, id: ExprId) -> ExprId {
        if let Some(&copied) = self.copied.get(&id) {
            return copied;
        }
        let copied = self.node(id);
        self.copied.insert(id, copied);
        copied
    }

    fn string(&mut self, id: StringId) -> StringId {
        if let Some(&copied) = self.strings.get(&id) {
            return copied;
        }
        let copied = self.target.intern_string(self.source.string(id));
        self.strings.insert(id, copied);
        copied
    }

    /// Rebuild a node in `target` from its copied children.
    fn node(&mut self, id: ExprId) -> ExprId {
        let source = self.source;
        let ty = || source.ty(id).expect("an operation has a type");
        match source.node(id).clone() {
            ExprNode::IntConst(value) => self.target.int(value),
            ExprNode::RealConst(value) => self.target.real(value),
            ExprNode::BoolConst(value) => self.target.bool_val(value),
            // Repeated uses of this node share one symbol in the copied arena.
            ExprNode::Symbol(_) => self.target.symbol(),
            ExprNode::ParamSymbol(name) => self.target.param_symbol(source.string(name)),
            ExprNode::InputElement { array, index } => {
                let array = self.string(array);
                self.target.input_element(array, index)
            }
            ExprNode::Add(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.add(ty(), a, b)
            }
            ExprNode::Sub(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.sub(ty(), a, b)
            }
            ExprNode::Mul(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.mul(ty(), a, b)
            }
            ExprNode::Div(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.div(ty(), a, b)
            }
            ExprNode::Rem(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.rem(ty(), a, b)
            }
            ExprNode::Neg(a) => {
                let a = self.expr(a);
                self.target.neg(ty(), a)
            }
            ExprNode::Exp(a) => {
                let a = self.expr(a);
                self.target.exp(ty(), a)
            }
            ExprNode::Exp2(a) => {
                let a = self.expr(a);
                self.target.exp2(ty(), a)
            }
            ExprNode::Log(a) => {
                let a = self.expr(a);
                self.target.log(ty(), a)
            }
            ExprNode::Log2(a) => {
                let a = self.expr(a);
                self.target.log2(ty(), a)
            }
            ExprNode::Sqrt(a) => {
                let a = self.expr(a);
                self.target.sqrt(ty(), a)
            }
            ExprNode::Rcp(a) => {
                let a = self.expr(a);
                self.target.rcp(ty(), a)
            }
            ExprNode::Max(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.max(ty(), a, b)
            }
            ExprNode::Min(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.min(ty(), a, b)
            }
            ExprNode::Abs(a) => {
                let a = self.expr(a);
                self.target.abs(ty(), a)
            }
            ExprNode::Sign(a) => {
                let a = self.expr(a);
                self.target.sign(ty(), a)
            }
            ExprNode::Erf(a) => {
                let a = self.expr(a);
                self.target.erf(ty(), a)
            }
            ExprNode::RoundEven(a) => {
                let a = self.expr(a);
                self.target.round_even(ty(), a)
            }
            ExprNode::Trunc(a) => {
                let a = self.expr(a);
                self.target.trunc(ty(), a)
            }
            ExprNode::BitAnd(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.bit_and(ty(), a, b)
            }
            ExprNode::BitOr(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.bit_or(ty(), a, b)
            }
            ExprNode::BitXor(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.bit_xor(ty(), a, b)
            }
            ExprNode::BitNot(a) => {
                let a = self.expr(a);
                self.target.bit_not(ty(), a)
            }
            ExprNode::Shl(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.shl(ty(), a, b)
            }
            ExprNode::Shr(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.shr(ty(), a, b)
            }
            ExprNode::LShr(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.lshr(ty(), a, b)
            }
            ExprNode::Eq(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.eq(ty(), a, b)
            }
            ExprNode::Ne(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.ne(ty(), a, b)
            }
            ExprNode::Lt(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.lt(ty(), a, b)
            }
            ExprNode::Le(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.le(ty(), a, b)
            }
            ExprNode::Gt(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.gt(ty(), a, b)
            }
            ExprNode::Ge(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.ge(ty(), a, b)
            }
            ExprNode::And(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.and(ty(), a, b)
            }
            ExprNode::Or(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.or(ty(), a, b)
            }
            ExprNode::Not(a) => {
                let a = self.expr(a);
                self.target.not(ty(), a)
            }
            ExprNode::Select(condition, then_value, else_value) => {
                let condition = self.expr(condition);
                let (then_value, else_value) = self.pair(then_value, else_value);
                self.target.select(ty(), condition, then_value, else_value)
            }
            ExprNode::ToFloat(a) => {
                let a = self.expr(a);
                self.target.to_float(ty(), a)
            }
            ExprNode::Fma(a, b, c) => {
                let (a, b) = self.pair(a, b);
                let c = self.expr(c);
                self.target.fma(ty(), a, b, c)
            }
            ExprNode::Tanh(a) => {
                let a = self.expr(a);
                self.target.tanh(ty(), a)
            }
            ExprNode::Rsqrt(a) => {
                let a = self.expr(a);
                self.target.rsqrt(ty(), a)
            }
            ExprNode::Sigmoid(a) => {
                let a = self.expr(a);
                self.target.sigmoid(ty(), a)
            }
            ExprNode::Median3(a, b, c) => {
                let (a, b) = self.pair(a, b);
                let c = self.expr(c);
                self.target.median3(ty(), a, b, c)
            }
            ExprNode::Copysign(magnitude, sign) => {
                let (magnitude, sign) = self.pair(magnitude, sign);
                self.target.copysign(ty(), magnitude, sign)
            }
            ExprNode::Gelu(x) => {
                let x = self.expr(x);
                self.target.gelu(ty(), x)
            }
            ExprNode::SymbolicRead { array, index } => {
                let index = self.expr(index);
                self.target.symbolic_read(ty(), source.string(array), index)
            }
            ExprNode::Discarded => self.target.discarded(),
            ExprNode::Undefined => self.target.undefined(),
        }
    }

    fn pair(&mut self, a: ExprId, b: ExprId) -> (ExprId, ExprId) {
        (self.expr(a), self.expr(b))
    }
}
