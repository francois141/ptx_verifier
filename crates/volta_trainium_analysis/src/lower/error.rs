//! Lowering error types: a kernel's parameters left without a shape, and the
//! errors of one body statement (shapes, instructions, operands).

use std::fmt;

use crate::frontend::ast::{Operand, TensorName};
use crate::ir::{Memory, Shape};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LowerError {
    // =========================================================================
    // Kernel Errors
    // =========================================================================
    /// A parameter whose shape no `assert` binds.
    UnassertedParam(TensorName),

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
    /// An operand used before an `assert` binds its shape.
    Unshaped(TensorName),

    /// An `assert` contradicting the shape the tensor was declared or asserted with.
    ShapeContradiction {
        tensor: TensorName,
        shape: Shape,
        asserted: Shape,
    },

    /// Two operands that must have one shape.
    ShapeMismatch([(TensorName, Shape); 2]),

    /// A matmul's `stationary` and `moving` tiles, whose partitions (the contraction) differ.
    ContractionMismatch([(TensorName, Shape); 2]),

    /// A destination whose shape is not the instruction's result's.
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

    UnsupportedArithOp(Operand),

    UnsupportedActivation(Operand),

    // =========================================================================
    // Operand Errors
    // =========================================================================
    NotATensor {
        keyword: &'static str,
    },

    /// An HBM tensor where an instruction takes on-chip tiles only.
    OffChip(TensorName),

    /// A tensor outside the one memory its operand must be in, e.g. a matmul's PSUM destination.
    WrongMemory {
        tensor: TensorName,
        expected: Memory,
    },
}

impl fmt::Display for LowerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::UnassertedParam(param) => {
                write!(f, "no `assert` binds the shape of parameter `{param}`")
            }
            Self::Statement { index, error } => write!(f, "statement {index}: {error}"),
        }
    }
}

impl fmt::Display for StatementError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Unshaped(tensor) => {
                write!(f, "`{tensor}` is used before an `assert` binds its shape")
            }
            Self::ShapeContradiction {
                tensor,
                shape,
                asserted,
            } => write!(
                f,
                "`{tensor}` has shape {shape}, not the asserted {asserted}"
            ),
            Self::ShapeMismatch([(left, left_shape), (right, right_shape)]) => write!(
                f,
                "`{left}` has shape {left_shape} but `{right}` has shape {right_shape}"
            ),
            Self::ContractionMismatch([(left, left_shape), (right, right_shape)]) => write!(
                f,
                "`{left}` has shape {left_shape} but `{right}` has shape {right_shape}: \
                 their partitions must match"
            ),
            Self::ResultShape {
                tensor,
                shape,
                expected,
            } => write!(
                f,
                "`{tensor}` has shape {shape}, not the result's {expected}"
            ),
            Self::UnsupportedInstruction(opcode) => {
                write!(f, "unsupported instruction `nki.isa.{opcode}`")
            }
            Self::Operands { opcode, keywords } => {
                write!(f, "`{opcode}` takes the operands {}", keywords.join(", "))
            }
            Self::UnsupportedArithOp(op) => write!(f, "unsupported arithmetic op `{op}`"),
            Self::UnsupportedActivation(op) => {
                write!(f, "unsupported activation function `{op}`")
            }
            Self::NotATensor { keyword } => write!(f, "operand `{keyword}` must be a tensor"),
            Self::OffChip(tensor) => {
                write!(f, "`{tensor}` is in HBM, not an SBUF or PSUM tile")
            }
            Self::WrongMemory { tensor, expected } => {
                write!(f, "`{tensor}` must be in {}", expected.name())
            }
        }
    }
}

impl std::error::Error for LowerError {}
