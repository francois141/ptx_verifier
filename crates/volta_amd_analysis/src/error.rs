//! Errors from executing AMD instructions.

use std::fmt;

use crate::ir::{Sgpr, Vgpr};

#[derive(Debug, PartialEq, Eq)]
pub enum EvalError {
    InvalidSgpr(Sgpr),
    InvalidLane(usize),
    UninitializedSgpr(Sgpr),
    UninitializedVgpr { lane: usize, reg: Vgpr },
    PendingSgpr(Sgpr),
    PendingVgpr { lane: usize, reg: Vgpr },
    InvalidAddressRegister(Sgpr),
    InvalidAddressVgpr { lane: usize, reg: Vgpr },
    InvalidFloatVgpr { lane: usize, reg: Vgpr },
    AddressOverflow,
    KernargRead { address: u64 },
    GlobalRead { address: u64 },
    GlobalWrite { address: u64 },
    UnsupportedInstruction,
    MissingEndPgm,
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
            Self::PendingVgpr { lane, reg } => {
                write!(
                    f,
                    "vector register v{} in lane {lane} has a pending load",
                    reg.0
                )
            }
            Self::InvalidAddressRegister(reg) => {
                write!(
                    f,
                    "address register s{} must contain a concrete 32-bit word",
                    reg.0
                )
            }
            Self::InvalidAddressVgpr { lane, reg } => {
                write!(
                    f,
                    "address register v{} in lane {lane} must contain a concrete 32-bit word",
                    reg.0
                )
            }
            Self::InvalidFloatVgpr { lane, reg } => {
                write!(
                    f,
                    "f32 operand v{} in lane {lane} must not be a NaN or wider than 32 bits",
                    reg.0
                )
            }
            Self::AddressOverflow => write!(f, "memory address overflows 64 bits"),
            Self::KernargRead { address } => {
                write!(
                    f,
                    "16-byte read at {address:#x} is outside the kernel argument buffer"
                )
            }
            Self::GlobalRead { address } => {
                write!(
                    f,
                    "4-byte read at {address:#x} is not an element of an input array"
                )
            }
            Self::GlobalWrite { address } => {
                write!(
                    f,
                    "4-byte write at {address:#x} is not an element of an output array"
                )
            }
            Self::UnsupportedInstruction => write!(f, "unsupported instruction"),
            Self::MissingEndPgm => {
                write!(
                    f,
                    "execution ran past the last instruction without s_endpgm"
                )
            }
            Self::Launch { message } => write!(f, "invalid launch: {message}"),
        }
    }
}

impl std::error::Error for EvalError {}
