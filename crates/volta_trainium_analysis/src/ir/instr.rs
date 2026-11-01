//! A lowered kernel's instructions, each over tensors of its kernel.

use id_collections::id_type;

use super::{ActivationFunc, ArithOp, TensorId};

/// An instruction's position in its kernel body.
#[id_type]
pub struct InstrId(pub u32);

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LoweredInstr {
    // =========================================================================
    // Data Movement
    // =========================================================================
    /// `dst = src` elementwise, both of one shape.
    Mov { dst: TensorId, src: TensorId },

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
