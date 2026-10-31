//! Execution error types: an instruction the interpreter cannot execute.

use std::fmt;

use crate::ir::{Index, InstrId};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum EvalError {
    // =========================================================================
    // Memory Errors
    // =========================================================================
    /// An SBUF or PSUM tile element read before any instruction wrote it.
    UninitializedRead {
        instr: InstrId,
        tensor: String,
        index: Index,
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
            Self::ElementCountOverflow { instr, tensor } => write!(
                f,
                "instruction {}: the element count of `{tensor}` overflows u64",
                instr.0
            ),
        }
    }
}

impl std::error::Error for EvalError {}
