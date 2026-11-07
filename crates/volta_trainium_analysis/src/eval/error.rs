//! Execution error types: an instruction the interpreter cannot execute.

use std::fmt;

use crate::ir::{Index, InstrId};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum EvalError {
    // =========================================================================
    // Memory Errors
    // =========================================================================
    /// An element of a tile or of a kernel-allocated HBM tensor read before any
    /// instruction wrote it.
    UninitializedRead {
        instr: InstrId,
        tensor: String,
        index: Index,
    },

    /// An element read after a write through another tile placed over its bytes.
    ClobberedRead {
        instr: InstrId,
        tensor: String,
        index: Index,
        /// The instruction whose write clobbered it, and the tile it wrote.
        by: InstrId,
        through: String,
    },

    // =========================================================================
    // Shape Errors
    // =========================================================================
    /// A tensor whose element count overflows `u64`.
    ElementCountOverflow { instr: InstrId, tensor: String },
}

impl fmt::Display for EvalError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::UninitializedRead {
                instr,
                tensor,
                index,
            } => write!(
                f,
                "instruction {}: `{tensor}{index}` is read before it is written",
                instr.0
            ),
            Self::ClobberedRead {
                instr,
                tensor,
                index,
                by,
                through,
            } => write!(
                f,
                "instruction {}: `{tensor}{index}` is read after instruction {} wrote \
                 `{through}`, which `address=` places over its bytes",
                instr.0, by.0
            ),
            Self::ElementCountOverflow { instr, tensor } => write!(
                f,
                "instruction {}: the element count of `{tensor}` overflows u64",
                instr.0
            ),
        }
    }
}

impl std::error::Error for EvalError {}
