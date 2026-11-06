//! A lowered kernel's instructions, each over tensors of its kernel.

use id_collections::id_type;

use crate::frontend::ast::Scalar;

use super::{ActivationFunc, ArithOp, ScalarStep, TensorRegion};

/// An instruction's position in its kernel body.
#[id_type]
pub struct InstrId(pub u32);

/// Every tile operand is a region of an on-chip tile, `[partitions, free]` like the
/// tile itself; the whole tile is one region. An instruction reads all its operands
/// before it writes, so regions of one tile may overlap.
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
    /// Every element of `dst` set to `value`.
    Memset { dst: TensorRegion, value: Scalar },

    // =========================================================================
    // Elementwise
    // =========================================================================
    /// `dst = op(lhs, rhs)` elementwise over regions of one shape.
    Arith {
        op: ArithOp,
        dst: TensorRegion,
        lhs: TensorRegion,
        rhs: TensorRegion,
    },
    /// `dst = func(data)` elementwise over regions of one shape.
    Activation {
        func: ActivationFunc,
        dst: TensorRegion,
        data: TensorRegion,
    },
    /// `dst = func(data)` elementwise, and each `reduce_res[p, 0]` the fold of
    /// `reduce_op` over `dst`'s partition `p`. `dst` and `data` have one shape;
    /// `reduce_res` has one free element per partition.
    ActivationReduce {
        func: ActivationFunc,
        dst: TensorRegion,
        data: TensorRegion,
        reduce_op: ArithOp,
        reduce_res: TensorRegion,
    },
    /// Each `dst[p, 0]` the fold of `op` over `data`'s partition `p`, seeded with its
    /// first element; `dst` has one free element per partition of `data`.
    Reduce {
        op: ArithOp,
        dst: TensorRegion,
        data: TensorRegion,
    },
    /// `dst = data` with each step applied in turn (`acc = op(acc, operand)`),
    /// elementwise over regions of one shape; a `[partitions, 1]` operand
    /// broadcasts its single free element across the free axis.
    TensorScalar {
        dst: TensorRegion,
        data: TensorRegion,
        first: ScalarStep,
        second: Option<ScalarStep>,
    },

    // =========================================================================
    // Tensor Engine
    // =========================================================================
    /// `dst = stationary.T @ moving` from SBUF regions into a PSUM region, contracting
    /// their partitions; a `dst` element written before accumulates the product instead.
    Matmul {
        dst: TensorRegion,
        stationary: TensorRegion,
        moving: TensorRegion,
    },
    /// `dst[f, p] = data[p, f]` over on-chip regions.
    Transpose {
        dst: TensorRegion,
        data: TensorRegion,
    },
}
