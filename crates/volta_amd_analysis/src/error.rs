//! Errors from executing AMD instructions.

use std::fmt;

use crate::eval::LdsRace;
use crate::ir::{Agpr, Sgpr, Vgpr};

#[derive(Debug, PartialEq, Eq)]
pub enum EvalError {
    InvalidSgpr(Sgpr),
    InvalidLane(usize),
    UninitializedSgpr(Sgpr),
    UninitializedVgpr { lane: usize, reg: Vgpr },
    UninitializedAgpr { lane: usize, reg: Agpr },
    UninitializedVcc { lane: usize },
    UninitializedScc,
    SymbolicSgpr(Sgpr),
    SymbolicVcc { lane: usize },
    SymbolicWord { lane: usize },
    AmbiguousSelect { lane: usize },
    UnsupportedBufferResource { reason: &'static str },
    PartialBufferAccess { buffer_offset: u64 },
    LdsAccess { address: u64, size: u32 },
    UninitializedLds { address: u32 },
    LdsRace(LdsRace),
    PendingSgpr(Sgpr),
    PendingVgpr { lane: usize, reg: Vgpr },
    InvalidAddressRegister(Sgpr),
    InvalidAddressVgpr { lane: usize, reg: Vgpr },
    InvalidFloatVgpr { lane: usize, reg: Vgpr },
    InvalidFloatAgpr { lane: usize, reg: Agpr },
    InvalidFloatSgpr(Sgpr),
    InvalidFloatConstant(u32),
    /// A word instruction read one half of an f64 held across a register pair.
    F64Half { lane: usize, reg: Vgpr },
    /// A VGPR pair read as an f64 holds neither one f64 value nor two concrete words.
    InvalidF64Vgpr { lane: usize, reg: Vgpr },
    /// The bits of an f64 source encode a NaN.
    InvalidF64Bits(u64),
    AddressOverflow,
    KernargRead { address: u64 },
    GlobalRead { address: u64 },
    GlobalWrite { address: u64 },
    InvalidFloatOutput { address: u64 },
    InvalidIntegerOutput { address: u64 },
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
            Self::UninitializedAgpr { lane, reg } => {
                write!(
                    f,
                    "uninitialized accumulation register a{} in lane {lane}",
                    reg.0
                )
            }
            Self::UninitializedVcc { lane } => write!(f, "uninitialized VCC bit in lane {lane}"),
            Self::UninitializedScc => write!(f, "uninitialized SCC"),
            Self::SymbolicSgpr(reg) => {
                write!(
                    f,
                    "scalar register s{} must contain a concrete 32-bit word",
                    reg.0
                )
            }
            Self::SymbolicVcc { lane } => {
                write!(
                    f,
                    "VCC bit in lane {lane} must be concrete to form a lane mask"
                )
            }
            Self::SymbolicWord { lane } => {
                write!(
                    f,
                    "integer operand in lane {lane} must be a concrete 32-bit word"
                )
            }
            Self::AmbiguousSelect { lane } => {
                write!(
                    f,
                    "lane {lane} selects between two constant words under a symbolic condition, \
                     which may encode floats or integers"
                )
            }
            Self::UnsupportedBufferResource { reason } => {
                write!(f, "unsupported buffer resource: {reason}")
            }
            Self::PartialBufferAccess { buffer_offset } => {
                write!(
                    f,
                    "buffer access at byte offset {buffer_offset:#x} is partially out of range"
                )
            }
            Self::LdsAccess { address, size } => {
                write!(
                    f,
                    "LDS access at {address:#x} is misaligned or outside the {size}-byte allocation"
                )
            }
            Self::UninitializedLds { address } => {
                write!(f, "LDS read at {address:#x} of a word no wave has written")
            }
            Self::LdsRace(race) => write!(f, "{race}"),
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
            Self::InvalidFloatAgpr { lane, reg } => {
                write!(
                    f,
                    "f32 operand a{} in lane {lane} must not be a NaN or wider than 32 bits",
                    reg.0
                )
            }
            Self::InvalidFloatSgpr(reg) => {
                write!(
                    f,
                    "scalar register s{} must hold an f32 other than a NaN",
                    reg.0
                )
            }
            Self::F64Half { lane, reg } => {
                write!(f, "v{} in lane {lane} holds one half of an f64", reg.0)
            }
            Self::InvalidF64Vgpr { lane, reg } => write!(
                f,
                "VGPR pair at v{} in lane {lane} holds neither an f64 value nor two concrete words",
                reg.0
            ),
            Self::InvalidF64Bits(bits) => write!(f, "f64 source {bits:#x} is a NaN"),
            Self::InvalidFloatConstant(bits) => {
                write!(f, "f32 constant {bits:#x} must not be a NaN")
            }
            Self::AddressOverflow => write!(f, "memory address overflows 64 bits"),
            Self::KernargRead { address } => {
                write!(
                    f,
                    "scalar read at {address:#x} is outside the kernel argument buffer"
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
            Self::InvalidFloatOutput { address } => {
                write!(
                    f,
                    "f32 output at {address:#x} must not be a NaN or wider than 32 bits"
                )
            }
            Self::InvalidIntegerOutput { address } => {
                write!(
                    f,
                    "u32 output at {address:#x} must be a concrete 32-bit word"
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
