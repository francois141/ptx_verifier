//! Errors produced during symbolic evaluation. Program counters (`InstrId`) are carried so
//! the driver can map errors back to source spans via the `SourceMap`.

use std::fmt;

use crate::eval::ThreadId;
use crate::eval::memory::{GranuleKind, MemAccessError};
use crate::eval::race::{MemHazard, TensorMemRaceInfo};
use crate::eval::tensor_memory::TensorMemError;
use crate::lowered::{InstrId, MemSpace};
use crate::symbols::RegId;
use crate::tensor_core::MmaShape;

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

/// Errors detected by the symbolic evaluator. `DataRace` and `Deadlock` are the analysis
/// *results* the paper proves sound and complete; the rest are structured-CTA violations or
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
    /// An access conflicted with a still-in-flight async operation (`cp.async`, or a
    /// `tcgen05.mma` reading shared operands): its destination was touched or its source
    /// modified before completion.
    AsyncCopyHazard {
        space: MemSpace,
        addr: u64,
        prior: AccessSite,
        current: AccessSite,
    },
    /// An async-proxy read (a `tcgen05.mma` operand) observed a generic-proxy write whose
    /// *writer* has not executed `fence.proxy.async` since: the ISA only makes generic writes
    /// visible to the async proxy via the writer's own fence, ordered before the reader by a sync.
    GenericProxyFenceHazard {
        space: MemSpace,
        addr: u64,
        prior: AccessSite,
        current: AccessSite,
    },
    /// A `wgmma.mma_async` accessed an accumulator register without an intervening
    /// `wgmma.fence` (PTX ISA 9.7.17.7.1): no fence ever ran (`prior_write: None`), or an access
    /// other than a same-shape `wgmma.mma_async` chain link touched it since the last fence.
    WgmmaFenceHazard {
        thread: ThreadId,
        pc: InstrId,
        reg: RegId,
        shape: MmaShape,
        prior_write: Option<AccessSite>,
    },
    /// An access other than the same chain's next same-shape seed-read or writeback reached
    /// an in-flight `wgmma.mma_async` accumulator register before the writer's covering
    /// `wgmma.wait_group` (PTX ISA 9.7.17.7.3).
    WgmmaWaitGroupHazard {
        thread: ThreadId,
        pc: InstrId,
        reg: RegId,
        prior_write: AccessSite,
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
    /// A Tensor Memory access's column range is not inside one live
    /// allocation: it starts outside every allocation, or runs past the
    /// end of its own (possibly into an adjacent one).
    Tcgen05AccessOutsideAllocation {
        thread: ThreadId,
        pc: InstrId,
        start_col: u32,
        num_cols: u32,
    },
    /// A Tensor Memory access or `tcgen05.dealloc` overlapped an outstanding async op: an
    /// un-`tcgen05.wait`-ed `.ld`/`.st` (see `RaceTracker::tcgen05_begin`) or a
    /// `tcgen05.mma` whose completion no thread has observed.
    Tcgen05AsyncHazard {
        quadrant: u32,
        start_col: u32,
        num_cols: u32,
        prior: AccessSite,
        current: AccessSite,
    },
    /// `thread` arrived at a sync point (`bar.*`, mbarrier arrive, `tcgen05.commit`) at `pc`
    /// with a `pending` un-`tcgen05.wait`-ed `.ld`/`.st`: the wait must precede the arrival
    /// for the sync to order the op for other participants (`RaceTracker::tcgen05_unwaited`).
    Tcgen05UnwaitedAtSync {
        thread: ThreadId,
        pc: InstrId,
        pending: AccessSite,
    },
    /// Two unsynchronized conflicting accesses to one Tensor Memory cell - e.g. a
    /// `tcgen05.ld` of a `tcgen05.mma` result without syncing with the MMA's issuer
    /// (normally via the mbarrier its `tcgen05.commit` arrives on).
    TensorMemoryRace {
        lane: u32,
        col: u32,
        prior: AccessSite,
        current: AccessSite,
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
                "async-operation hazard on {:?}[{:#x}]: {} conflicts with in-flight {}",
                space, addr, current, prior
            ),
            Self::GenericProxyFenceHazard {
                space,
                addr,
                prior,
                current,
            } => write!(
                f,
                "missing fence.proxy.async on {:?}[{:#x}]: async-proxy {} (tcgen05.mma operand) \
                 observed the generic-proxy {} whose writer has not executed fence.proxy.async \
                 since (the writer must fence before the sync that orders its write ahead of \
                 the tensor-core read)",
                space, addr, current, prior
            ),
            Self::WgmmaFenceHazard {
                thread,
                pc,
                reg,
                shape,
                prior_write: Some(prior),
            } => write!(
                f,
                "missing wgmma.fence on {reg}: {thread} at {pc} accesses {reg} as a \
                 wgmma.mma_async .{shape} accumulator, but it was last written by {prior} with \
                 no intervening wgmma.fence (PTX ISA 9.7.17.7.1 requires a fence between a \
                 register access and any wgmma.mma_async that accesses the same register, \
                 except when both accesses are accumulator accesses of the same shape)"
            ),
            Self::WgmmaFenceHazard {
                thread,
                pc,
                reg,
                shape,
                prior_write: None,
            } => write!(
                f,
                "missing wgmma.fence on {reg}: {thread} at {pc} is this warpgroup's first \
                 wgmma.mma_async access to {reg} (.{shape}), but no wgmma.fence has been \
                 executed yet (PTX ISA 9.7.17.7.1 requires a wgmma.fence before the first \
                 wgmma.mma_async operation in a warpgroup)"
            ),
            Self::WgmmaWaitGroupHazard {
                thread,
                pc,
                reg,
                prior_write,
            } => write!(
                f,
                "missing wgmma.wait_group on {reg}: {thread} at {pc} accesses {reg}, which \
                 {prior_write} wrote as a wgmma.mma_async accumulator not yet released by a \
                 covering wgmma.wait_group (PTX ISA 9.7.17.7.3 makes this undefined behavior \
                 unless the access is that same wgmma.mma_async chain's own next same-shape \
                 accumulator seed-read or writeback)"
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
            Self::InstructionLimit { limit } => {
                write!(f, "instruction limit exceeded ({} instructions)", limit)
            }
            Self::Config { message } => write!(f, "configuration error: {}", message),
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
            Self::Tcgen05AsyncHazard {
                quadrant,
                start_col,
                num_cols,
                prior,
                current,
            } => write!(
                f,
                "tcgen05 async hazard on tensor-memory quadrant {} cols [{}, {}): {} conflicts with in-flight {}",
                quadrant,
                start_col,
                start_col + num_cols,
                current,
                prior
            ),
            Self::Tcgen05UnwaitedAtSync {
                thread,
                pc,
                pending,
            } => {
                let kind = if pending.is_write { "st" } else { "ld" };
                write!(
                    f,
                    "{}: synchronization at {} with tcgen05.{} ({}) still in flight - \
                     tcgen05.wait::{} must precede the arrival",
                    thread, pc, kind, pending, kind
                )
            }
            Self::TensorMemoryRace {
                lane,
                col,
                prior,
                current,
            } => write!(
                f,
                "data race on tensor-memory (lane={}, col={}): {} conflicts with {}",
                lane, col, current, prior
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

impl From<MemHazard> for EvalError {
    fn from(hazard: MemHazard) -> Self {
        match hazard {
            MemHazard::Race(race) => EvalError::DataRace {
                space: race.space,
                addr: race.addr,
                prior: race.prior,
                current: race.current,
            },
            MemHazard::AsyncCopy(h) => EvalError::AsyncCopyHazard {
                space: h.space,
                addr: h.addr,
                prior: h.prior,
                current: h.current,
            },
            MemHazard::GenericProxyUnfenced(h) => EvalError::GenericProxyFenceHazard {
                space: h.space,
                addr: h.addr,
                prior: h.prior,
                current: h.current,
            },
        }
    }
}

impl From<TensorMemRaceInfo> for EvalError {
    fn from(race: TensorMemRaceInfo) -> Self {
        EvalError::TensorMemoryRace {
            lane: race.lane,
            col: race.col,
            prior: race.prior,
            current: race.current,
        }
    }
}
