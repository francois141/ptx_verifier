//! Copy one workgroup's output expressions into their own arena, retaining shared subexpressions.

use std::collections::HashMap;

use volta_expr::{ExprArena, ExprId, ExprNode, StringId, SymbolicOutputs};

/// Copy the written output elements and the expressions they reference into their own arena.
pub(crate) fn workgroup_outputs(
    arena: &ExprArena,
    outputs: &[(String, Vec<(u64, ExprId)>)],
) -> SymbolicOutputs {
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
    SymbolicOutputs {
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
                self.target.add(a, b)
            }
            ExprNode::Sub(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.sub(a, b)
            }
            ExprNode::Mul(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.mul(a, b)
            }
            ExprNode::Div(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.div(a, b)
            }
            ExprNode::Rem(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.rem(a, b)
            }
            ExprNode::Neg(a) => {
                let a = self.expr(a);
                self.target.neg(a)
            }
            ExprNode::Exp(a) => {
                let a = self.expr(a);
                self.target.exp(a)
            }
            ExprNode::Log(a) => {
                let a = self.expr(a);
                self.target.log(a)
            }
            ExprNode::Sqrt(a) => {
                let a = self.expr(a);
                self.target.sqrt(a)
            }
            ExprNode::Rcp(a) => {
                let a = self.expr(a);
                self.target.rcp(a)
            }
            ExprNode::Max(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.max(a, b)
            }
            ExprNode::Min(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.min(a, b)
            }
            ExprNode::Abs(a) => {
                let a = self.expr(a);
                self.target.abs(a)
            }
            ExprNode::Sign(a) => {
                let a = self.expr(a);
                self.target.sign(a)
            }
            ExprNode::RoundEven(a) => {
                let a = self.expr(a);
                self.target.round_even(a)
            }
            ExprNode::Trunc(a) => {
                let a = self.expr(a);
                self.target.trunc(a)
            }
            ExprNode::BitAnd(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.bit_and(a, b)
            }
            ExprNode::BitOr(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.bit_or(a, b)
            }
            ExprNode::BitXor(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.bit_xor(a, b)
            }
            ExprNode::BitNot(a) => {
                let a = self.expr(a);
                self.target.bit_not(a)
            }
            ExprNode::Shl(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.shl(a, b)
            }
            ExprNode::Shr(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.shr(a, b)
            }
            ExprNode::LShr(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.lshr(a, b)
            }
            ExprNode::Eq(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.eq(a, b)
            }
            ExprNode::Ne(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.ne(a, b)
            }
            ExprNode::Lt(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.lt(a, b)
            }
            ExprNode::Le(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.le(a, b)
            }
            ExprNode::Gt(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.gt(a, b)
            }
            ExprNode::Ge(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.ge(a, b)
            }
            ExprNode::And(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.and(a, b)
            }
            ExprNode::Or(a, b) => {
                let (a, b) = self.pair(a, b);
                self.target.or(a, b)
            }
            ExprNode::Not(a) => {
                let a = self.expr(a);
                self.target.not(a)
            }
            ExprNode::Select(condition, then_value, else_value) => {
                let condition = self.expr(condition);
                let (then_value, else_value) = self.pair(then_value, else_value);
                self.target.select(condition, then_value, else_value)
            }
            ExprNode::ToFloat(a) => {
                let a = self.expr(a);
                self.target.to_float(a)
            }
            ExprNode::Fma(a, b, c) => {
                let (a, b) = self.pair(a, b);
                let c = self.expr(c);
                self.target.fma(a, b, c)
            }
            ExprNode::SymbolicRead { array, index } => {
                let index = self.expr(index);
                self.target.symbolic_read(source.string(array), index)
            }
            ExprNode::Discarded => self.target.discarded(),
            ExprNode::Undefined => self.target.undefined(),
        }
    }

    fn pair(&mut self, a: ExprId, b: ExprId) -> (ExprId, ExprId) {
        (self.expr(a), self.expr(b))
    }
}
