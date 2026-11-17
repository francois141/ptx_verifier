//! Each operation's value, computed as it is built by lowering it over placeholders.

use super::node::{ExprArena, ExprId, ExprNode};
use crate::lower::{lower_operation, raise_real};
use crate::symbolic_simplified as simplified;

impl ExprArena {
    /// Push `node` and record its value.
    pub(super) fn operation(&mut self, node: ExprNode) -> ExprId {
        let value = self.evaluate(&node);
        self.push(node, value)
    }

    /// What lowering makes of `node` when that is a constant, an operand or an input element.
    /// Each operand stands in as its constant value, or else as an opaque symbol: lowering's
    /// folds yield those three from no other property of their operands.
    fn evaluate(&mut self, node: &ExprNode) -> Option<ExprId> {
        let Self {
            nodes,
            strings,
            values,
            lowered_reals,
            scratch,
        } = self;
        let value_of = |id: ExprId| values[id];

        let mut children = [ExprId(0); 3];
        let mut child_count = 0;
        node.for_each_child(|child| {
            children[child_count] = value_of(child);
            child_count += 1;
        });
        let children = &children[..child_count];

        scratch.clear();
        let mut placeholders = [(ExprId(0), simplified::ExprId(0)); 3];
        let mut placeholder_count = 0;
        for &value in children {
            if placeholders[..placeholder_count]
                .iter()
                .all(|&(seen, _)| seen != value)
            {
                let lowered_real = lowered_reals[value].as_ref();
                placeholders[placeholder_count] =
                    (value, placeholder(scratch, &nodes[value], lowered_real));
                placeholder_count += 1;
            }
        }
        let placeholders = &placeholders[..placeholder_count];

        let placeholder_of = |child: ExprId| {
            let value = value_of(child);
            placeholders
                .iter()
                .find(|&&(seen, _)| seen == value)
                .map(|&(_, placeholder)| placeholder)
                .expect("every child has a placeholder")
        };
        let result = lower_operation(scratch, node, placeholder_of, strings)?;

        if let Some(&(operand, _)) = placeholders.iter().find(|&&(_, p)| p == result) {
            return Some(operand);
        }
        let value = match self.scratch.node(result) {
            simplified::ExprNode::IntConst(v) => ExprNode::IntConst(*v),
            simplified::ExprNode::RealConst(v) => {
                let lowered = v.clone();
                let real = ExprNode::RealConst(raise_real(&lowered));
                return Some(self.push_lowered(real, None, Some(lowered)));
            }
            simplified::ExprNode::BoolConst(v) => ExprNode::BoolConst(*v),
            simplified::ExprNode::InputElement { index, .. } => {
                let ExprNode::SymbolicRead { array, .. } = node else {
                    unreachable!("only a symbolic read lowers to an input element")
                };
                ExprNode::InputElement {
                    array: *array,
                    index: *index,
                }
            }
            _ => return None,
        };
        Some(self.atom(value))
    }
}

/// The scratch node an operand with value node `value` (a real constant's counterpart being
/// `lowered_real`) stands in as. An integer-valued operation keeps its kind, since rounding
/// one is the identity.
fn placeholder(
    scratch: &mut simplified::ExprArena,
    value: &ExprNode,
    lowered_real: Option<&simplified::Real>,
) -> simplified::ExprId {
    let opaque = |scratch: &mut simplified::ExprArena| {
        let index = scratch.node_count() as u64;
        scratch.push(simplified::ExprNode::Symbol(simplified::SymbolId(index)))
    };
    match value {
        ExprNode::IntConst(v) => scratch.push(simplified::ExprNode::IntConst(*v)),
        ExprNode::RealConst(_) => {
            let real = lowered_real
                .expect("a real constant has its counterpart")
                .clone();
            scratch.push(simplified::ExprNode::RealConst(real))
        }
        ExprNode::BoolConst(v) => scratch.push(simplified::ExprNode::BoolConst(*v)),
        ExprNode::RoundEven(_) | ExprNode::Trunc(_) | ExprNode::ToFloat(_) => {
            let symbol = opaque(scratch);
            scratch.push(simplified::ExprNode::ToFloat(symbol))
        }
        _ => opaque(scratch),
    }
}
