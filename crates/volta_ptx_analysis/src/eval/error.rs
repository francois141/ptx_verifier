//! Errors produced during symbolic evaluation. Program counters (`InstrId`) are carried so
//! front ends can map errors back to source spans via the `SourceMap`.

use std::fmt;

use crate::eval::ThreadId;
use crate::eval::memory::{GranuleKind, MemAccessError};
use crate::eval::tensor_memory::TensorMemError;
use crate::ir::{InstrId, MemSpace};

/// Why a `clusterlaunchcontrol` use is undefined behavior. Every response is
/// declined under Volta's never-steal assumption.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ClcMisuse {
    /// `get_first_ctaid` decoded a declined response.
    CtaidOfDeclinedResponse,
    /// A `try_cancel` issued after `observer`'s `is_canceled` at
    /// `observed_at` decoded a declined one.
    RequestAfterObservedDecline {
        observer: ThreadId,
        observed_at: InstrId,
    },
}

/// Errors of one candidate execution: structured-CTA violations or implementation limits, which
/// the paper models as raised exceptions. Data races, async hazards and deadlocks are not
/// errors here: they are graph check failures or the graph's stuck terminal state.
#[derive(Debug)]
pub enum EvalError {
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
    /// A memory access whose address is not a multiple of its required alignment. PTX ISA
    /// 6.4.1 makes misaligned access undefined behavior, so it is rejected rather than given
    /// well-defined symbolic semantics.
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
        /// The colliding granule: start, width, and kind, when known.
        found: Option<(u64, u64, GranuleKind)>,
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
    /// An ordinary (non-`mbarrier`) write clobbered a live `mbarrier`
    /// object's bytes without an intervening `mbarrier.inval`.
    MbarrierOverwrite {
        thread: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
    },
    /// An `mbarrier` operation other than `init` targeted an address with
    /// no live `mbarrier` object there.
    NoLiveMbarrier {
        thread: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
    },
    /// An `mbarrier.init` targeted the shared address of a live `mbarrier`
    /// object: undefined behavior without an intervening `mbarrier.inval`.
    MbarrierReinit {
        thread: ThreadId,
        pc: InstrId,
        addr: u64,
    },
    /// An `mbarrier.init` or `mbarrier.arrive` arrival count outside the
    /// ISA's `[1, 2^20 - 1]`.
    MbarrierCountOutOfRange {
        thread: ThreadId,
        pc: InstrId,
        what: &'static str,
        count: u64,
    },
    /// An mbarrier phase's tx-count left the ISA's `[-(2^20 - 1), 2^20 - 1]`.
    MbarrierTxCountOutOfRange {
        thread: ThreadId,
        pc: InstrId,
        tx_count: i64,
    },
    /// An output array element is (or was computed from) an uninitialized
    /// read that was never resolved.
    UndefinedOutput { array: String, index: u64 },
    /// A `trap` instruction was reached.
    TrapReached { thread: ThreadId, pc: InstrId },
    /// Threads participating in one warp-cooperative operation disagree
    /// (different masks, missing/exited lanes, non-uniform operands, ...).
    WarpMismatch { pc: InstrId, reason: String },
    /// A named-barrier arrival the ISA leaves undefined: an out-of-range id or count,
    /// arrivals disagreeing on the count, or more arrivals than the count (the released
    /// threads would then depend on the schedule).
    BarrierMismatch { pc: InstrId, reason: String },
    /// The instruction (or one of its modes) is not supported by the evaluator.
    Unsupported { pc: InstrId, what: String },
    /// A runtime operand encodes something the PTX ISA defines as invalid (a reserved
    /// descriptor bit, an invalid shape, ...) - unlike [`Self::Unsupported`], no hardware
    /// would accept it either.
    InvalidEncoding { pc: InstrId, what: String },
    /// A `clusterlaunchcontrol` use the ISA leaves undefined.
    ClusterLaunchControlMisuse {
        thread: ThreadId,
        pc: InstrId,
        misuse: ClcMisuse,
    },
    /// `mapa` named a CTA rank other than 0: clusters are assumed to hold
    /// exactly one CTA, so any other rank is outside the cluster.
    MapaRankOutsideCluster {
        thread: ThreadId,
        pc: InstrId,
        rank: i64,
    },
    /// The per-analysis instruction budget was exhausted (runaway loop guard).
    InstructionLimit { limit: u64 },
    /// Configuration problem detected before/while setting up execution.
    Config { message: String },
    /// `tcgen05.alloc`'s `nCols` violated the ISA's power-of-2-in-[32,512] rule.
    Tcgen05InvalidColumnCount {
        thread: ThreadId,
        pc: InstrId,
        num_cols: u32,
    },
    /// `tcgen05.alloc` requested more columns than the CTA's previous
    /// allocation (the ISA forbids the count increasing between any two).
    Tcgen05IncreasingColumnCount {
        thread: ThreadId,
        pc: InstrId,
        previous: u32,
        requested: u32,
    },
    /// `tcgen05.alloc` requested more Tensor Memory columns than remain
    /// unallocated.
    Tcgen05OutOfSpace {
        thread: ThreadId,
        pc: InstrId,
        requested: u32,
        available: u32,
    },
    /// `tcgen05.alloc` after this CTA already executed
    /// `tcgen05.relinquish_alloc_permit`.
    Tcgen05AllocAfterRelinquish { thread: ThreadId, pc: InstrId },
    /// `tcgen05.dealloc`'s `(taddr, nCols)` doesn't match any live
    /// allocation.
    Tcgen05DeallocMismatch {
        thread: ThreadId,
        pc: InstrId,
        taddr: u32,
        num_cols: u32,
    },
    /// A `tcgen05.ld`/`.st` touched a Tensor Memory column outside every
    /// live allocation.
    Tcgen05NotAllocated {
        thread: ThreadId,
        pc: InstrId,
        lane: u32,
        col: u32,
    },
    /// A `tcgen05` op read an allocated Tensor Memory cell that was never written.
    Tcgen05UninitializedRead {
        thread: ThreadId,
        pc: InstrId,
        lane: u32,
        col: u32,
    },
    /// A Tensor Memory access's column range is not inside one live
    /// allocation: it starts outside every allocation, or runs past the
    /// end of its own (possibly into an adjacent one).
    Tcgen05AccessOutsideAllocation {
        thread: ThreadId,
        pc: InstrId,
        start_col: u32,
        num_cols: u32,
    },
    /// A `tcgen05.ld`/`.st`'s `taddr` lane bits `[31:16]` (PTX ISA 9.7.17.1.1) name a 32-lane
    /// quadrant other than the issuing warp's own (9.7.17.8.1). A real kernel bug, so the lane
    /// is not silently re-derived from `ThreadId`.
    Tcgen05LaneRestrictionViolation {
        thread: ThreadId,
        pc: InstrId,
        lane_base: u32,
        expected_quadrant_base: u32,
    },
    /// `tensormap.cp_fenceproxy`/`cp.async.bulk.tensor` referenced a tensor map with no
    /// prior `tensormap.replace` write (there is no `tensormap.init`, so an entry exists
    /// only once some field is written).
    TensorMapNotFound {
        thread: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
    },
    /// `cp.async.bulk.tensor` used a tensor map missing a field the copy needs; PTX ISA
    /// 9.7.9.27 lets kernels set only some fields, so using an incomplete one is a real
    /// kernel bug, not a Volta gap.
    TensorMapFieldMissing {
        thread: ThreadId,
        pc: InstrId,
        field: String,
    },
}

impl fmt::Display for EvalError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
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
                found,
            } => {
                write!(
                    f,
                    "{}: unsupported reinterpretation of {:?} memory at {:#x} (width {}) at {}",
                    thread, space, addr, width, pc
                )?;
                if let Some((start, found_width, kind)) = found {
                    write!(
                        f,
                        "; the bytes belong to a {}-byte {} granule written at {:#x}",
                        found_width,
                        match kind {
                            GranuleKind::Pair => "packed-pair",
                            GranuleKind::Quad => "packed-quad",
                            GranuleKind::Scalar => "scalar",
                        },
                        start
                    )?;
                }
                Ok(())
            }
            Self::NotConcrete { thread, pc, what } => write!(
                f,
                "{}: {} is symbolic at {}; the kernel is not a structured-CTA under this configuration",
                thread, what, pc
            ),
            Self::ValueKindMismatch { thread, pc, what } => {
                write!(f, "{}: value kind mismatch ({}) at {}", thread, what, pc)
            }
            Self::MbarrierOverwrite {
                thread,
                pc,
                space,
                addr,
            } => write!(
                f,
                "{}: ordinary write to {:?} memory at {:#x} overwrote a live mbarrier \
                 object at {}; mbarrier.inval must run first",
                thread, space, addr, pc
            ),
            Self::NoLiveMbarrier {
                thread,
                pc,
                space,
                addr,
            } => write!(
                f,
                "{}: no live mbarrier object at {:?}[{:#x}] at {} (never initialized, \
                 already invalidated, or holding ordinary data)",
                thread, space, addr, pc
            ),
            Self::MbarrierReinit { thread, pc, addr } => write!(
                f,
                "{}: mbarrier.init of the live mbarrier object at Shared[{:#x}] at {}; \
                 mbarrier.inval must run first",
                thread, addr, pc
            ),
            Self::MbarrierCountOutOfRange {
                thread,
                pc,
                what,
                count,
            } => write!(
                f,
                "{}: {} {} at {} is outside [1, 2^20 - 1]",
                thread, what, count, pc
            ),
            Self::MbarrierTxCountOutOfRange {
                thread,
                pc,
                tx_count,
            } => write!(
                f,
                "{}: mbarrier tx-count {} at {} is outside [-(2^20 - 1), 2^20 - 1]",
                thread, tx_count, pc
            ),
            Self::UndefinedOutput { array, index } => write!(
                f,
                "output element {}[{}] is undefined (uninitialized read)",
                array, index
            ),
            Self::TrapReached { thread, pc } => write!(f, "{}: trap reached at {}", thread, pc),
            Self::WarpMismatch { pc, reason } => {
                write!(f, "warp-op mismatch at {}: {}", pc, reason)
            }
            Self::BarrierMismatch { pc, reason } => {
                write!(f, "barrier mismatch at {}: {}", pc, reason)
            }
            Self::Unsupported { pc, what } => write!(f, "unsupported at {}: {}", pc, what),
            Self::InvalidEncoding { pc, what } => write!(f, "invalid encoding at {}: {}", pc, what),
            Self::ClusterLaunchControlMisuse { thread, pc, misuse } => match misuse {
                ClcMisuse::CtaidOfDeclinedResponse => write!(
                    f,
                    "{}: clusterlaunchcontrol.query_cancel.get_first_ctaid at {} on a declined \
                     try_cancel response is undefined behavior (guard it with is_canceled)",
                    thread, pc
                ),
                ClcMisuse::RequestAfterObservedDecline {
                    observer,
                    observed_at,
                } => write!(
                    f,
                    "{}: clusterlaunchcontrol.try_cancel at {} after {} observed a declined \
                     request at {} is undefined behavior",
                    thread, pc, observer, observed_at
                ),
            },
            Self::InstructionLimit { limit } => {
                write!(f, "instruction limit exceeded ({} instructions)", limit)
            }
            Self::Config { message } => write!(f, "configuration error: {}", message),
            Self::MapaRankOutsideCluster { thread, pc, rank } => write!(
                f,
                "{}: mapa at {} names CTA rank {}, but clusters are assumed to hold a \
                 single CTA (rank 0)",
                thread, pc, rank
            ),
            Self::Tcgen05InvalidColumnCount {
                thread,
                pc,
                num_cols,
            } => write!(
                f,
                "{}: tcgen05.alloc nCols={} at {} must be a power of 2 in [32, 512]",
                thread, num_cols, pc
            ),
            Self::Tcgen05IncreasingColumnCount {
                thread,
                pc,
                previous,
                requested,
            } => write!(
                f,
                "{}: tcgen05.alloc nCols={} at {} exceeds the previous allocation's {} \
                 (the column count must not increase between allocations)",
                thread, requested, pc, previous
            ),
            Self::Tcgen05OutOfSpace {
                thread,
                pc,
                requested,
                available,
            } => write!(
                f,
                "{}: tcgen05.alloc requested {} tensor-memory column(s) at {} but only {} remain unallocated",
                thread, requested, pc, available
            ),
            Self::Tcgen05AllocAfterRelinquish { thread, pc } => write!(
                f,
                "{}: tcgen05.alloc at {} after this CTA relinquished its allocation permit",
                thread, pc
            ),
            Self::Tcgen05DeallocMismatch {
                thread,
                pc,
                taddr,
                num_cols,
            } => write!(
                f,
                "{}: tcgen05.dealloc at {} of (taddr={:#x}, nCols={}) does not match any live allocation",
                thread, pc, taddr, num_cols
            ),
            Self::Tcgen05NotAllocated {
                thread,
                pc,
                lane,
                col,
            } => write!(
                f,
                "{}: tcgen05.ld/.st at {} touched tensor-memory (lane={}, col={}) outside any live allocation",
                thread, pc, lane, col
            ),
            Self::Tcgen05UninitializedRead {
                thread,
                pc,
                lane,
                col,
            } => write!(
                f,
                "{}: read of uninitialized tensor memory (lane={}, col={}) ({})",
                thread, lane, col, pc
            ),
            Self::Tcgen05AccessOutsideAllocation {
                thread,
                pc,
                start_col,
                num_cols,
            } => write!(
                f,
                "{}: tensor-memory access at {} to cols [{}, {}) is not inside one live allocation",
                thread,
                pc,
                start_col,
                start_col + num_cols
            ),
            Self::Tcgen05LaneRestrictionViolation {
                thread,
                pc,
                lane_base,
                expected_quadrant_base,
            } => write!(
                f,
                "{}: tcgen05.ld/.st at {} addresses tensor-memory lane quadrant {} - the issuing \
                 warp may only access its own quadrant, starting at lane {}",
                thread, pc, lane_base, expected_quadrant_base
            ),
            Self::TensorMapNotFound {
                thread,
                pc,
                space,
                addr,
            } => write!(
                f,
                "{}: {} references a tensor-map object at {:?}[{:#x}] that was never written by tensormap.replace",
                thread, pc, space, addr
            ),
            Self::TensorMapFieldMissing { thread, pc, field } => write!(
                f,
                "{}: {} uses a tensor-map object missing its `.{}` field",
                thread, pc, field
            ),
        }
    }
}

impl std::error::Error for EvalError {}

pub type EvalResult<T> = Result<T, EvalError>;

impl EvalError {
    /// The thread and instruction the error arose at, where it names them.
    pub fn location(&self) -> (Option<ThreadId>, Option<InstrId>) {
        match self {
            Self::UninitializedMemory { thread, pc, .. }
            | Self::OutOfBounds { thread, pc, .. }
            | Self::Misaligned { thread, pc, .. }
            | Self::Reinterpretation { thread, pc, .. }
            | Self::NotConcrete { thread, pc, .. }
            | Self::ValueKindMismatch { thread, pc, .. }
            | Self::MbarrierOverwrite { thread, pc, .. }
            | Self::NoLiveMbarrier { thread, pc, .. }
            | Self::MbarrierReinit { thread, pc, .. }
            | Self::MbarrierCountOutOfRange { thread, pc, .. }
            | Self::MbarrierTxCountOutOfRange { thread, pc, .. }
            | Self::TrapReached { thread, pc }
            | Self::ClusterLaunchControlMisuse { thread, pc, .. }
            | Self::MapaRankOutsideCluster { thread, pc, .. }
            | Self::Tcgen05InvalidColumnCount { thread, pc, .. }
            | Self::Tcgen05IncreasingColumnCount { thread, pc, .. }
            | Self::Tcgen05OutOfSpace { thread, pc, .. }
            | Self::Tcgen05AllocAfterRelinquish { thread, pc }
            | Self::Tcgen05DeallocMismatch { thread, pc, .. }
            | Self::Tcgen05NotAllocated { thread, pc, .. }
            | Self::Tcgen05UninitializedRead { thread, pc, .. }
            | Self::Tcgen05AccessOutsideAllocation { thread, pc, .. }
            | Self::Tcgen05LaneRestrictionViolation { thread, pc, .. }
            | Self::TensorMapNotFound { thread, pc, .. }
            | Self::TensorMapFieldMissing { thread, pc, .. } => (Some(*thread), Some(*pc)),
            Self::WmmaStrideTooSmall { pc, .. }
            | Self::WarpMismatch { pc, .. }
            | Self::BarrierMismatch { pc, .. }
            | Self::Unsupported { pc, .. }
            | Self::InvalidEncoding { pc, .. } => (None, Some(*pc)),
            Self::UndefinedOutput { .. } | Self::InstructionLimit { .. } | Self::Config { .. } => {
                (None, None)
            }
        }
    }

    /// The error for a failed memory access by `t` at `pc`.
    pub(in crate::eval) fn from_mem_access(
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        e: MemAccessError,
    ) -> EvalError {
        match e {
            MemAccessError::Uninitialized { addr } => EvalError::UninitializedMemory {
                thread: t,
                pc,
                space,
                addr,
            },
            MemAccessError::Reinterpret { addr, width, found } => EvalError::Reinterpretation {
                thread: t,
                pc,
                space,
                addr,
                width,
                found,
            },
            MemAccessError::MbarrierOverwrite { addr } => EvalError::MbarrierOverwrite {
                thread: t,
                pc,
                space,
                addr,
            },
            MemAccessError::NoLiveMbarrier { addr } => EvalError::NoLiveMbarrier {
                thread: t,
                pc,
                space,
                addr,
            },
        }
    }

    /// The error for a failed Tensor Memory operation by `t` at `pc`.
    pub(in crate::eval) fn from_tensor_mem(
        t: ThreadId,
        pc: InstrId,
        e: TensorMemError,
    ) -> EvalError {
        match e {
            TensorMemError::InvalidColumnCount { num_cols } => {
                EvalError::Tcgen05InvalidColumnCount {
                    thread: t,
                    pc,
                    num_cols,
                }
            }
            TensorMemError::OutOfSpace {
                requested,
                available,
            } => EvalError::Tcgen05OutOfSpace {
                thread: t,
                pc,
                requested,
                available,
            },
            TensorMemError::IncreasingColumnCount {
                previous,
                requested,
            } => EvalError::Tcgen05IncreasingColumnCount {
                thread: t,
                pc,
                previous,
                requested,
            },
            TensorMemError::AllocAfterRelinquish => {
                EvalError::Tcgen05AllocAfterRelinquish { thread: t, pc }
            }
            TensorMemError::RangeOutsideAllocation {
                start_col,
                num_cols,
            } => EvalError::Tcgen05AccessOutsideAllocation {
                thread: t,
                pc,
                start_col,
                num_cols,
            },
            TensorMemError::DeallocMismatch { taddr, num_cols } => {
                EvalError::Tcgen05DeallocMismatch {
                    thread: t,
                    pc,
                    taddr,
                    num_cols,
                }
            }
            TensorMemError::NotAllocated { lane, col } => EvalError::Tcgen05NotAllocated {
                thread: t,
                pc,
                lane,
                col,
            },
        }
    }
}
