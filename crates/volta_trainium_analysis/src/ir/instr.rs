//! A lowered kernel's instructions, each over tensors of its kernel.

use id_collections::id_type;

use crate::frontend::ast::Scalar;

use super::{ActivationFunc, ArithOp, ScalarOperand, ScalarStep, TensorRegion};

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
    /// `dst = func(data + bias)` elementwise over regions of one shape, `bias`
    /// broadcast like a `tensor_scalar` operand, then the result's `reduce`.
    Activation {
        func: ActivationFunc,
        dst: TensorRegion,
        data: TensorRegion,
        bias: Option<ScalarOperand>,
        reduce: Option<Reduction>,
    },
    /// Each `dst[p, r]` the fold of `op` over the `r`th of `dst`'s free count of equal,
    /// consecutive runs of `data`'s partition `p` (its reduced trailing axes), seeded
    /// with the run's first element, then `sign` applied.
    Reduce {
        op: ArithOp,
        dst: TensorRegion,
        data: TensorRegion,
        sign: Sign,
    },
    /// `dst = data` with each step applied in turn (`acc = op(acc, operand)`),
    /// elementwise over regions of one shape; a `[partitions, 1]` operand
    /// broadcasts its single free element across the free axis.
    TensorScalar {
        dst: TensorRegion,
        data: TensorRegion,
        first: ScalarStep,
        second: Option<ScalarStep>,
        reduce: Option<Reduction>,
    },

    // =========================================================================
    // Tensor Engine
    // =========================================================================
    /// `dst = stationary.T @ moving` from SBUF regions into a PSUM region, contracting
    /// their partitions, or `dst += ...` as `accumulation` says.
    Matmul {
        dst: TensorRegion,
        stationary: TensorRegion,
        moving: TensorRegion,
        accumulation: Accumulation,
    },
    /// `dst[f, p] = data[p, f]` over on-chip regions.
    Transpose {
        dst: TensorRegion,
        data: TensorRegion,
    },
}

/// A reduction of an instruction's elementwise result: each `res[p, 0]` the fold of
/// `op` over the result's partition `p`, seeded with its first element, so the
/// accumulator holds this instruction's result only (NKI's `reduce_cmd.reset_reduce`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Reduction {
    pub op: ArithOp,
    pub res: TensorRegion,
}

/// Whether `nc_matmul` adds its product to `dst` or overwrites it, from `accumulate=`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Accumulation {
    /// `None`, the default: an element's first write overwrites it, later ones add.
    FirstOverwrites,
    /// `False`.
    Overwrite,
    /// `True`: every element must hold a value already.
    Accumulate,
}

/// Whether a reduction's result is written as folded or negated (`negate=True`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Sign {
    Kept,
    Negated,
}
