//! A lowered kernel's instructions, each over tensors of its kernel.

use id_collections::id_type;

use super::{ActivationFunc, ArithOp, ScalarStep, TensorId, TensorRegion};

/// An instruction's position in its kernel body.
#[id_type]
pub struct InstrId(pub u32);

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LoweredInstr {
    // =========================================================================
    // Data Movement
    // =========================================================================
    /// `dst = src` elementwise over regions of one shape.
    Mov {
        dst: TensorRegion,
        src: TensorRegion,
    },

    // =========================================================================
    // Elementwise
    // =========================================================================
    /// `dst = op(lhs, rhs)` elementwise, all three on-chip tiles of one shape.
    Arith {
        op: ArithOp,
        dst: TensorId,
        lhs: TensorId,
        rhs: TensorId,
    },
    /// `dst = func(data)` elementwise, both on-chip tiles of one shape.
    Activation {
        func: ActivationFunc,
        dst: TensorId,
        data: TensorId,
    },
    /// `dst = func(data)` elementwise, and each `reduce_res[p, 0]` the fold of
    /// `reduce_op` over `dst`'s partition `p`. `dst` and `data` are tiles of one
    /// shape; `reduce_res` has one free element per partition.
    ActivationReduce {
        func: ActivationFunc,
        dst: TensorId,
        data: TensorId,
        reduce_op: ArithOp,
        reduce_res: TensorId,
    },
    /// Each `dst[p, 0]` the fold of `op` over `data`'s partition `p`, seeded with its
    /// first element; `dst` has one free element per partition of the tile `data`.
    Reduce {
        op: ArithOp,
        dst: TensorId,
        data: TensorId,
    },
    /// `dst = data` with each step applied in turn (`acc = op(acc, operand)`),
    /// elementwise over on-chip tiles of one shape; a `[partitions, 1]` operand
    /// broadcasts its single free element across the free axis.
    TensorScalar {
        dst: TensorId,
        data: TensorId,
        first: ScalarStep,
        second: Option<ScalarStep>,
    },

    // =========================================================================
    // Tensor Engine
    // =========================================================================
    /// `dst = stationary.T @ moving` from SBUF tiles into a PSUM tile, contracting their
    /// partitions; a `dst` element written before accumulates the product instead.
    Matmul {
        dst: TensorId,
        stationary: TensorId,
        moving: TensorId,
    },
    /// `dst[f, p] = data[p, f]` over on-chip tiles.
    Transpose { dst: TensorId, data: TensorId },
}
