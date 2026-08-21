//! Errors produced during symbolic evaluation.
//!
//! Program counters (`InstrId`) are carried so the driver can map errors back
//! to source spans via the `SourceMap`.

use std::fmt;

use crate::eval::ThreadId;
use crate::lowered::{InstrId, MemSpace};
use crate::symbols::RegId;

/// One side of a conflicting memory access pair.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct AccessSite {
    pub thread: ThreadId,
    pub pc: InstrId,
    pub is_write: bool,
}

impl fmt::Display for AccessSite {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{} by {} at {}",
            if self.is_write { "write" } else { "read" },
            self.thread,
            self.pc
        )
    }
}

/// Errors detected by the symbolic evaluator.
///
/// `DataRace` and `Deadlock` are the analysis *results* the paper proves sound
/// and complete; the remaining variants are structured-CTA violations or
/// implementation limits, which the paper models as raised exceptions.
#[derive(Debug)]
pub enum EvalError {
    /// Two unsynchronized conflicting accesses to the same address.
    DataRace {
        space: MemSpace,
        addr: u64,
        prior: AccessSite,
        current: AccessSite,
    },
    /// An access conflicted with a still-in-flight `cp.async` copy: its
    /// destination was touched before completion, or its source was
    /// modified before completion.
    AsyncCopyHazard {
        space: MemSpace,
        addr: u64,
        prior: AccessSite,
        current: AccessSite,
    },
    /// All live threads are blocked and no barrier or warp group can fire.
    Deadlock {
        /// (thread, pc it is blocked at) for every blocked thread
        blocked: Vec<(ThreadId, InstrId)>,
    },
    /// A register was read before ever being written.
    UninitializedRegister {
        thread: ThreadId,
        pc: InstrId,
        reg: RegId,
    },
    /// Memory was read at an address that was never written/initialized.
    UninitializedMemory {
        thread: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
    },
    /// An access fell outside every declared array/variable region.
    OutOfBounds {
        thread: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
    },
    /// A memory access whose address is not a multiple of its required
    /// alignment. PTX ISA 6.4.1: "The address must be naturally aligned to
    /// a multiple of the access size. If an address is not properly
    /// aligned, the resulting behavior is undefined" - the undefined
    /// behavior is rejected rather than silently given well-defined
    /// symbolic semantics.
    Misaligned {
        thread: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        /// Required alignment in bytes: the instruction's access size
        /// (total bytes for a vector access), or the row/base/stride
        /// alignment for the tensor-core cooperative loads/stores.
        required: u64,
    },
    /// A `wmma.load`/`wmma.store` stride below the stride's default value
    /// (the matrix's leading dimension). PTX ISA 9.7.14.4.3: "Specifying a
    /// value lower than the default value results in undefined behavior".
    WmmaStrideTooSmall {
        pc: InstrId,
        /// The stride operand's value, in matrix elements.
        stride: i64,
        /// The smallest legal stride (the leading dimension), in elements.
        minimum: u64,
    },
    /// An access reinterpreted bytes at an incompatible width
    /// (e.g. reading half of an f32).
    Reinterpretation {
        thread: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
    },
    /// A value that must be concrete (address, branch predicate, shuffle
    /// lane, sync mask, ...) was symbolic: the program is not a
    /// structured-CTA under this configuration.
    NotConcrete {
        thread: ThreadId,
        pc: InstrId,
        what: &'static str,
    },
    /// A scalar was required but a packed pair was found (or vice versa).
    ValueKindMismatch {
        thread: ThreadId,
        pc: InstrId,
        what: &'static str,
    },
    /// An output array element is (or was computed from) an uninitialized
    /// read that was never resolved.
    UndefinedOutput { array: String, index: u64 },
    /// A `trap` instruction was reached.
    TrapReached { thread: ThreadId, pc: InstrId },
    /// Threads participating in one warp-cooperative operation disagree
    /// (different masks, missing/exited lanes, non-uniform operands, ...).
    WarpMismatch { pc: InstrId, reason: String },
    /// The instruction (or one of its modes) is not supported by the evaluator.
    Unsupported { pc: InstrId, what: String },
    /// The per-analysis instruction budget was exhausted (runaway loop guard).
    InstructionLimit { limit: u64 },
    /// Configuration problem detected before/while setting up execution.
    Config { message: String },
}

impl fmt::Display for EvalError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::DataRace {
                space,
                addr,
                prior,
                current,
            } => write!(
                f,
                "data race on {:?}[{:#x}]: {} conflicts with {}",
                space, addr, current, prior
            ),
            Self::AsyncCopyHazard {
                space,
                addr,
                prior,
                current,
            } => write!(
                f,
                "cp.async hazard on {:?}[{:#x}]: {} conflicts with in-flight {}",
                space, addr, current, prior
            ),
            Self::Deadlock { blocked } => {
                write!(f, "deadlock: {} thread(s) blocked", blocked.len())
            }
            Self::UninitializedRegister { thread, pc, reg } => {
                write!(
                    f,
                    "{}: read of uninitialized register {} at {}",
                    thread, reg, pc
                )
            }
            Self::UninitializedMemory {
                thread,
                pc,
                space,
                addr,
            } => write!(
                f,
                "{}: read of uninitialized {:?} memory at {:#x} ({})",
                thread, space, addr, pc
            ),
            Self::OutOfBounds {
                thread,
                pc,
                space,
                addr,
                width,
            } => write!(
                f,
                "{}: out-of-bounds {:?} access at {:#x} (width {}) at {}",
                thread, space, addr, width, pc
            ),
            Self::Misaligned {
                thread,
                pc,
                space,
                addr,
                required,
            } => write!(
                f,
                "{}: misaligned {:?} access at {:#x} (must be {}-byte aligned) at {}; \
                 PTX requires natural alignment, so hardware behavior is undefined",
                thread, space, addr, required, pc
            ),
            Self::WmmaStrideTooSmall {
                pc,
                stride,
                minimum,
            } => write!(
                f,
                "wmma stride {} is below the matrix leading dimension {} at {}; \
                 PTX defines strides below the default as undefined behavior",
                stride, minimum, pc
            ),
            Self::Reinterpretation {
                thread,
                pc,
                space,
                addr,
                width,
            } => write!(
                f,
                "{}: unsupported reinterpretation of {:?} memory at {:#x} (width {}) at {}",
                thread, space, addr, width, pc
            ),
            Self::NotConcrete { thread, pc, what } => write!(
                f,
                "{}: {} is symbolic at {}; the kernel is not a structured-CTA under this configuration",
                thread, what, pc
            ),
            Self::ValueKindMismatch { thread, pc, what } => {
                write!(f, "{}: value kind mismatch ({}) at {}", thread, what, pc)
            }
            Self::UndefinedOutput { array, index } => write!(
                f,
                "output element {}[{}] is undefined (uninitialized read)",
                array, index
            ),
            Self::TrapReached { thread, pc } => write!(f, "{}: trap reached at {}", thread, pc),
            Self::WarpMismatch { pc, reason } => {
                write!(f, "warp-op mismatch at {}: {}", pc, reason)
            }
            Self::Unsupported { pc, what } => write!(f, "unsupported at {}: {}", pc, what),
            Self::InstructionLimit { limit } => {
                write!(f, "instruction limit exceeded ({} instructions)", limit)
            }
            Self::Config { message } => write!(f, "configuration error: {}", message),
        }
    }
}

impl std::error::Error for EvalError {}

pub type EvalResult<T> = Result<T, EvalError>;
