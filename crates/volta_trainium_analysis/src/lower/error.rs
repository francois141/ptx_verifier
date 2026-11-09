//! Lowering error types: a returned tensor the kernel did not allocate, tiles placed
//! both by `address=` and by the compiler, and the errors of one body statement
//! (shapes, instructions, operands).

use std::fmt;

use crate::frontend::ast::{Operand, TensorName};
use crate::ir::{Memory, Shape};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LowerError {
    // =========================================================================
    // Kernel Errors
    // =========================================================================
    /// A returned tensor other than one the kernel allocates in `nl.shared_hbm`.
    ReturnsUnallocated(TensorName),

    /// A kernel placing some tiles by `address=` and leaving others to the compiler,
    /// which could place them over the placed ones.
    MixedAllocation {
        placed: TensorName,
        unplaced: TensorName,
    },

    // =========================================================================
    // Statement Errors
    // =========================================================================
    /// Statement `index` (zero-based) of the kernel body.
    Statement { index: usize, error: StatementError },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum StatementError {
    // =========================================================================
    // Shape Errors
    // =========================================================================
    /// Two operands that must have one shape, each a tensor and its region's shape.
    ShapeMismatch([(TensorName, Shape); 2]),

    /// A matmul's `stationary` and `moving` regions, whose partitions (the contraction) differ.
    ContractionMismatch([(TensorName, Shape); 2]),

    /// An instruction over tiles of one free dimension given a region of another rank,
    /// its indexed dimensions dropped.
    NotAMatrix {
        tensor: TensorName,
        shape: Shape,
    },

    /// A tile whose element count overflows `u64`.
    ElementCountOverflow(TensorName),

    /// A destination region whose shape is not the instruction's result's.
    ResultShape {
        tensor: TensorName,
        shape: Shape,
        expected: Shape,
    },

    // =========================================================================
    // Instruction Errors
    // =========================================================================
    UnsupportedInstruction(String),

    /// The instruction's operand keywords are not exactly `keywords`.
    Operands {
        opcode: String,
        keywords: &'static [&'static str],
    },

    /// An instruction's paired optional operands given only in part.
    UnpairedOperands {
        opcode: String,
        keywords: &'static [&'static str],
    },

    UnsupportedArithOp(Operand),

    UnsupportedActivation(Operand),

    /// A reduction `axis` other than a tile's free axis.
    UnsupportedAxis(Operand),

    /// A `reduce_cmd` other than `reset_reduce`, which would carry an accumulator
    /// across instructions.
    UnsupportedReduceCmd(Operand),

    /// An `engine` other than one of `nki.isa`'s compute engines.
    UnsupportedEngine(Operand),

    /// A `dma_transpose` `axes` other than `(1, 0)`, a 2-D transpose.
    UnsupportedTransposeAxes(Operand),

    // =========================================================================
    // Operand Errors
    // =========================================================================
    NotATensor {
        keyword: &'static str,
    },

    /// An operand that must be a number literal.
    NotAScalar {
        keyword: &'static str,
    },

    /// An operand that must be `True` or `False`.
    NotABool {
        keyword: &'static str,
    },

    /// An HBM tensor where an instruction takes on-chip tiles only.
    OffChip(TensorName),

    /// A tensor outside the one memory its operand must be in, e.g. a matmul's PSUM destination.
    WrongMemory {
        tensor: TensorName,
        expected: Memory,
    },

    /// A scalar operand that is not a one-free-element region of its destination's partitions.
    NotBroadcastable {
        tensor: TensorName,
        shape: Shape,
        expected: Shape,
    },

    /// A subscript with more indices than its tensor has dimensions.
    RegionRank {
        tensor: TensorName,
        shape: Shape,
        indices: usize,
    },

    /// A tile region indexing the partition dimension, which every tile operand keeps.
    PartitionIndexed(TensorName),

    /// A `tensor.ap(...)` view that does not name elements of its tensor as a view must.
    AccessPattern {
        tensor: TensorName,
        problem: PatternProblem,
    },

    /// An `nl.broadcast_to` whose `target` is not `tensor`'s shape with some
    /// extents of 1 widened, at the same rank.
    BroadcastShape {
        tensor: TensorName,
        shape: Shape,
        target: Shape,
    },

    /// An index outside its tensor's dimension, or a slice reaching outside it or
    /// selecting no elements.
    RegionBounds {
        tensor: TensorName,
        dimension: usize,
        extent: u64,
    },
}

impl fmt::Display for LowerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ReturnsUnallocated(tensor) => write!(
                f,
                "`{tensor}` is returned, but only an HBM tensor the kernel allocates \
                 with `nl.shared_hbm` can be"
            ),
            Self::MixedAllocation { placed, unplaced } => write!(
                f,
                "`{placed}` is placed by `address=` but `{unplaced}` is not: a kernel places \
                 all of its tiles or none"
            ),
            Self::Statement { index, error } => write!(f, "statement {index}: {error}"),
        }
    }
}

impl fmt::Display for StatementError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ShapeMismatch([(left, left_shape), (right, right_shape)]) => write!(
                f,
                "the `{left}` operand has shape {left_shape} but the `{right}` operand has \
                 shape {right_shape}"
            ),
            Self::ContractionMismatch([(left, left_shape), (right, right_shape)]) => write!(
                f,
                "the `{left}` operand has shape {left_shape} but the `{right}` operand has \
                 shape {right_shape}: their partitions must match"
            ),
            Self::ResultShape {
                tensor,
                shape,
                expected,
            } => write!(
                f,
                "the `{tensor}` operand has shape {shape}, not the result's {expected}"
            ),
            Self::UnsupportedInstruction(opcode) => {
                write!(f, "unsupported instruction `nki.isa.{opcode}`")
            }
            Self::Operands { opcode, keywords } => {
                write!(f, "`{opcode}` takes the operands {}", keywords.join(", "))
            }
            Self::UnpairedOperands { opcode, keywords } => write!(
                f,
                "`{opcode}` takes the operands {} together or not at all",
                keywords.join(", ")
            ),
            Self::UnsupportedArithOp(op) => write!(f, "unsupported arithmetic op `{op}`"),
            Self::UnsupportedActivation(op) => {
                write!(f, "unsupported activation function `{op}`")
            }
            Self::UnsupportedAxis(axis) => write!(
                f,
                "unsupported reduction axis `{axis}`: only a region's trailing free axes, \
                 e.g. `1`, `(1,)` or `[3, 4]`"
            ),
            Self::NotATensor { keyword } => write!(f, "operand `{keyword}` must be a tensor"),
            Self::NotAScalar { keyword } => write!(f, "operand `{keyword}` must be a number"),
            Self::NotABool { keyword } => {
                write!(f, "operand `{keyword}` must be `True` or `False`")
            }
            Self::UnsupportedReduceCmd(cmd) => write!(
                f,
                "unsupported `reduce_cmd` `{cmd}`: only `nisa.reduce_cmd.reset_reduce`"
            ),
            Self::UnsupportedEngine(engine) => write!(
                f,
                "unsupported `engine` `{engine}`: only `nisa.vector_engine`, \
                 `nisa.scalar_engine` or `nisa.gpsimd_engine`"
            ),
            Self::UnsupportedTransposeAxes(axes) => write!(
                f,
                "unsupported `axes` `{axes}`: only `(1, 0)`, a 2-D transpose"
            ),
            Self::OffChip(tensor) => {
                write!(f, "`{tensor}` is in HBM, not an SBUF or PSUM tile")
            }
            Self::WrongMemory { tensor, expected } => {
                write!(f, "`{tensor}` must be in {}", expected.name())
            }
            Self::NotBroadcastable {
                tensor,
                shape,
                expected,
            } => write!(
                f,
                "the scalar operand on `{tensor}` has shape {shape}, not the broadcast {expected}"
            ),
            Self::RegionRank {
                tensor,
                shape,
                indices,
            } => write!(
                f,
                "a subscript of `{tensor}{shape}` takes at most {} indices, not {indices}",
                shape.0.len()
            ),
            Self::PartitionIndexed(tensor) => write!(
                f,
                "a region of the tile `{tensor}` must slice its partition dimension, \
                 not index it"
            ),
            Self::NotAMatrix { tensor, shape } => write!(
                f,
                "the `{tensor}` operand has shape {shape}, but the instruction takes \
                 tiles of one free dimension"
            ),
            Self::ElementCountOverflow(tensor) => {
                write!(f, "the element count of `{tensor}` overflows u64")
            }
            Self::RegionBounds {
                tensor,
                dimension,
                extent,
            } => write!(
                f,
                "`{tensor}`'s index in dimension {dimension} is empty or outside its extent {extent}"
            ),
            Self::BroadcastShape {
                tensor,
                shape,
                target,
            } => write!(
                f,
                "`{tensor}{shape}` cannot broadcast to {target}: each extent must match or be 1"
            ),
            Self::AccessPattern { tensor, problem } => {
                write!(f, "access pattern of `{tensor}`: {problem}")
            }
        }
    }
}

/// How an access pattern fails to name elements of its tensor.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PatternProblem {
    /// No `[step, count]` pair.
    Empty,
    /// A pair counting no elements.
    ZeroCount,
    /// An element past the tensor's end.
    OutOfBounds,
    /// A tile's first pair, its partitions, stepping other than its `free` size.
    PartitionStep { free: u64 },
    /// An element of a tile outside the partition its pattern starts in.
    CrossesPartition { free: u64 },
}

impl fmt::Display for PatternProblem {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Empty => write!(f, "it has no `[step, count]` pair"),
            Self::ZeroCount => write!(f, "a pair counts no elements"),
            Self::OutOfBounds => write!(f, "an element lies past the tensor's end"),
            Self::PartitionStep { free } => write!(
                f,
                "a tile's first pair steps over its partitions, so its step must be the \
                 free size {free}"
            ),
            Self::CrossesPartition { free } => write!(
                f,
                "an element lies outside its partition's {free} free elements"
            ),
        }
    }
}

impl std::error::Error for LowerError {}
