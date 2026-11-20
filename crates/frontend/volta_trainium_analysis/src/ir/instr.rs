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
        mover: Mover,
    },
    /// `tensor_copy_predicated`: each element of `dst` set to `src`'s where `predicate`'s is
    /// `copied_where` (nonzero, or zero under `reverse_pred=True`), else left as it was.
    CopyPredicated {
        dst: TensorRegion,
        src: TensorRegion,
        predicate: TensorRegion,
        copied_where: Copied,
    },
    /// Every element of `dst` set to `value`.
    Memset { dst: TensorRegion, value: Scalar },
    /// `dst`, a square tile region, set to the identity matrix (`nl.shared_identity_matrix`).
    Identity { dst: TensorRegion },
    /// Tensor indirection: `dst[p, i] = data[p, index[i % 16, i // 16]]` for each of
    /// `dst`'s `count` columns, `index` holding free-dimension offsets of `data`, as the
    /// NKI docs state it, and the same offset from the rows of `p`'s 16-partition group.
    Gather {
        dst: TensorRegion,
        data: TensorRegion,
        index: TensorRegion,
    },

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
    /// `dst = func(data * scale + bias)` elementwise over regions of one shape, `scale`
    /// and `bias` broadcast like a `tensor_scalar` operand, then the result's `reduce`.
    Activation {
        func: ActivationFunc,
        dst: TensorRegion,
        data: TensorRegion,
        scale: Option<ScalarOperand>,
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
    /// Each `dst[0, f]` the fold of `op` over `data`'s partitions at `f`, seeded with
    /// partition 0's (`tensor_partition_reduce`; the docs give no output shape, and nkilib
    /// reduces `[P, 1]` into `[1, 1]`).
    PartitionReduce {
        op: ArithOp,
        dst: TensorRegion,
        data: TensorRegion,
    },
    /// `dst = op1(op0(data, operand0), operand1)` elementwise over regions of one shape,
    /// `operand0` broadcast like a `tensor_scalar` operand and each `Order` swapping its op's
    /// operands (`reverse0`, `reverse1`), then the result's `reduce`: `scalar_tensor_tensor`.
    ScalarTensorTensor {
        dst: TensorRegion,
        data: TensorRegion,
        op0: (ArithOp, Order),
        operand0: ScalarOperand,
        op1: (ArithOp, Order),
        operand1: TensorRegion,
        reduce: Option<Reduction>,
    },
    /// Along each partition's free elements in order, `acc = op1(op0(src[p, i], imm0), acc)`
    /// and `dst[p, i] = acc`, from `initial` (`reduce_cmd.load_reduce`'s `imm1`) or else
    /// `op1`'s identity (`reset_reduce`): `tensor_scalar_cumulative`.
    Cumulative {
        dst: TensorRegion,
        src: TensorRegion,
        op0: ArithOp,
        imm0: Scalar,
        op1: ArithOp,
        initial: Option<ScalarOperand>,
    },
    /// Along each partition, `dst[p, i] = op1(op0(data0[p, i], dst[p, i - 1]), data1[p, i])`
    /// over matrix regions of one shape, `initial` in place of `dst[p, -1]`; each
    /// `Order` says whether its data operand is the op's left operand as written.
    Scan {
        dst: TensorRegion,
        data0: TensorRegion,
        data1: TensorRegion,
        initial: ScalarOperand,
        op0: (ArithOp, Order),
        op1: (ArithOp, Order),
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
        pass: MatmulPass,
    },
    /// `dst[c, m, a] = data[a, m, c]`: the ends of a `[A, M, C]` region swapped, its middle
    /// dimensions (`middle` elements, flattened row-major) kept in place; a matrix's `middle`
    /// is 1, `dst[f, p] = data[p, f]`.
    Transpose {
        dst: TensorRegion,
        data: TensorRegion,
        middle: u64,
        mover: Mover,
    },
    /// `nc_stream_shuffle`, within one 32-partition quadrant: `dst[p, f] = src[mask[p], f]`
    /// for each of `dst`'s partitions whose `mask` entry is `Some`; a `None` (the docs' 255)
    /// leaves that partition unwritten.
    Shuffle {
        dst: TensorRegion,
        src: TensorRegion,
        mask: Vec<Option<u64>>,
    },
}

impl LoweredInstr {
    /// The `nki.isa` instruction it lowers from (`activation` and `reciprocal` alike).
    pub fn kind(&self) -> &'static str {
        match self {
            LoweredInstr::Mov {
                mover: Mover::Dma(_),
                ..
            } => "dma_copy",
            LoweredInstr::Mov {
                mover: Mover::Engine,
                ..
            } => "tensor_copy",
            LoweredInstr::Memset { .. } => "memset",
            LoweredInstr::Identity { .. } => "shared_identity_matrix",
            LoweredInstr::Gather { .. } => "tensor_copy (indirect)",
            LoweredInstr::Arith { .. } => "tensor_tensor",
            LoweredInstr::Activation { .. } => "activation",
            LoweredInstr::Reduce { .. } => "tensor_reduce",
            LoweredInstr::TensorScalar { .. } => "tensor_scalar",
            LoweredInstr::Scan { .. } => "tensor_tensor_scan",
            LoweredInstr::ScalarTensorTensor { .. } => "scalar_tensor_tensor",
            LoweredInstr::PartitionReduce { .. } => "tensor_partition_reduce",
            LoweredInstr::Cumulative { .. } => "tensor_scalar_cumulative",
            LoweredInstr::Matmul { .. } => "nc_matmul",
            LoweredInstr::Transpose {
                mover: Mover::Dma(_),
                ..
            } => "dma_transpose",
            LoweredInstr::Transpose {
                mover: Mover::Engine,
                ..
            } => "nc_transpose",
            LoweredInstr::Shuffle { .. } => "nc_stream_shuffle",
            LoweredInstr::CopyPredicated { .. } => "tensor_copy_predicated",
        }
    }
}

/// What moves a copy's or transpose's data: a DMA (`dma_copy`, `dma_transpose`, `nl.load`,
/// `nl.store`) or a compute engine (`tensor_copy`, `nc_transpose`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mover {
    Dma(Descriptors),
    Engine,
}

impl LoweredInstr {
    /// How its DMA's descriptors are generated, if it is a DMA.
    pub fn dma(&self) -> Option<Descriptors> {
        match self {
            LoweredInstr::Mov {
                mover: Mover::Dma(descriptors),
                ..
            }
            | LoweredInstr::Transpose {
                mover: Mover::Dma(descriptors),
                ..
            } => Some(*descriptors),
            _ => None,
        }
    }
}

/// Where `tensor_copy_predicated` copies, from its `reverse_pred=`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Copied {
    /// Where the predicate is nonzero, the default.
    Nonzero,
    /// Where it is zero (`reverse_pred=True`).
    Zero,
}

/// How a DMA's descriptors are generated, from its `dge_mode=`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Descriptors {
    /// `dge_mode.unknown`, the default: the compiler picks the mode.
    CompilerChosen,
    /// `dge_mode.none`: pre-generated out of band, off the engines that would order them.
    OutOfBand,
    /// `dge_mode.hwdge`: generated by the DMA hardware. Ordered like `CompilerChosen`: no
    /// evidence either way, so pass 1 credits the compiler.
    Hardware,
    /// `dge_mode.swdge`: generated at run time by software on an engine. Ordered like
    /// `Hardware`, for the same reason.
    Software,
}

/// A reduction of an instruction's elementwise result: each `res[p, 0]` the fold of
/// `op` over the result's partition `p`, seeded with its first element, so the
/// accumulator holds this instruction's result only (NKI's `reduce_cmd.reset_reduce`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Reduction {
    pub op: ArithOp,
    pub res: TensorRegion,
}

/// How `nc_matmul` runs, from `is_transpose=`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MatmulPass {
    Multiply,
    /// The Tensor Engine's transpose mode: `dst = stationary.T`, defined only when `moving`
    /// is the identity, where it is also the product.
    Transpose,
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

/// The operand order of one of a scan's ops: `Given` is `op0(data0, acc)` and
/// `op1(acc, data1)`, `Reversed` (`reverse0=True`, `reverse1=True`) swaps them.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Order {
    Given,
    Reversed,
}
