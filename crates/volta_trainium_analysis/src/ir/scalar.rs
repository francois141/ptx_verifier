//! `tensor_scalar`'s scalar operands and the steps it applies.

use crate::frontend::ast::Scalar;

use super::{ArithOp, TensorRegion};

/// A scalar operand: a literal, or a `[partitions, 1]` region whose single free
/// element broadcasts across the destination's free axis.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ScalarOperand {
    Constant(Scalar),
    Broadcast(TensorRegion),
}

/// One step of a `tensor_scalar`: `acc = op(acc, operand)`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ScalarStep {
    pub op: ArithOp,
    pub operand: ScalarOperand,
}
