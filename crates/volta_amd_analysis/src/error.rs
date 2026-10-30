//! Errors from executing AMD instructions.

use std::fmt;

use crate::ir::{Sgpr, Vgpr};

#[derive(Debug, PartialEq, Eq)]
pub(crate) enum EvalError {
    InvalidSgpr(Sgpr),
    InvalidLane(usize),
    UninitializedSgpr(Sgpr),
    UninitializedVgpr { lane: usize, reg: Vgpr },
    PendingSgpr(Sgpr),
    InvalidAddressRegister(Sgpr),
    AddressOverflow,
    KernargRead { address: u64 },
    UnsupportedInstruction,
    Launch { message: String },
}

// Stringify evaluation error types.
impl fmt::Display for EvalError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidSgpr(reg) => write!(f, "invalid scalar register s{}", reg.0),
            Self::InvalidLane(lane) => write!(f, "invalid wave lane {lane}"),
            Self::UninitializedSgpr(reg) => write!(f, "uninitialized scalar register s{}", reg.0),
            Self::UninitializedVgpr { lane, reg } => {
                write!(f, "uninitialized vector register v{} in lane {lane}", reg.0)
            }
            Self::PendingSgpr(reg) => write!(f, "scalar register s{} has a pending load", reg.0),
            Self::InvalidAddressRegister(reg) => {
                write!(
                    f,
                    "address register s{} must contain a concrete 32-bit word",
                    reg.0
                )
            }
            Self::AddressOverflow => write!(f, "scalar load address overflows 64 bits"),
            Self::KernargRead { address } => {
                write!(
                    f,
                    "16-byte read at {address:#x} is outside the kernel argument buffer"
                )
            }
            Self::UnsupportedInstruction => write!(f, "unsupported instruction"),
            Self::Launch { message } => write!(f, "invalid launch: {message}"),
        }
    }
}

impl std::error::Error for EvalError {}
