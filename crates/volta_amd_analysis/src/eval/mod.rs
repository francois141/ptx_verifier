//! Symbolic execution of AMD instructions.

mod launch;
mod scalar;
#[cfg(test)]
mod tests;
mod value;

use std::fmt;

use volta_expr::ExprArena;

use crate::ir::{LoweredInstr, Sgpr, Vgpr};

pub(crate) use value::WaveRegisters;

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

/// Execute one instruction for an active lane selected by the caller.
/// Register values must be integer expressions from `arena`.
pub(crate) fn execute_lane(
    instruction: &LoweredInstr,
    lane: usize,
    registers: &mut WaveRegisters,
    arena: &mut ExprArena,
) -> Result<(), EvalError> {
    match instruction {
        LoweredInstr::Shl32 { dst, src, shift } => {
            // Read before writing because the source and destination may be the same register.
            let value = registers.read_vgpr(lane, *src)?;

            // AMD uses only the low five bits of the shift count: 34 becomes 2, and 32 becomes 0.
            let amount = arena.int(i64::from(shift & 31));
            let shifted = arena.shl(value, amount);

            // For a known numeric value, keep only the low 32 bits of the result.
            // For symbolic values, follow PTX's model and keep the shift expression without truncation.
            // TODO: Should this be handled differently?
            let result = if arena.as_int_const(value).is_some() {
                let mask = arena.int(i64::from(u32::MAX));
                arena.bit_and(shifted, mask)
            } else {
                shifted
            };
            registers.write_vgpr(lane, *dst, result)
        }
        _ => Err(EvalError::UnsupportedInstruction),
    }
}
