//! The graph's node, edge and metadata types.

use volta_expr::ExprId;

use crate::ids::{
    AccessId, AsyncOpId, EventId, GenerationId, ProgramPoint, SyncObjectId, ThreadIx, ValueId,
};

// =========================================================================
// Events
// =========================================================================

/// Where an event happens. Only `Thread` events are in a program order.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum ExecContext {
    /// Issued by (or performed synchronously for) this thread, in its program order.
    Thread(ThreadIx),
    /// An effect or the completion of an asynchronous operation.
    Async(AsyncOpId),
    /// A synchronization generation's completion.
    Generation(GenerationId),
}

/// One event of the candidate trace.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Event {
    pub ctx: ExecContext,
    pub kind: EventKind,
    /// The instruction the event belongs to; `None` for generation completions.
    pub pc: Option<ProgramPoint>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EventKind {
    /// A memory effect: synchronous in a `Thread` context, an async op's in an `Async` one.
    Access(AccessId),
    /// The thread contributes to a generation; how is the generation's [`Contribution`].
    Contribute(GenerationId),
    /// The thread starts a wait on an mbarrier phase of parity `parity`, contributing nothing.
    WaitStart {
        object: SyncObjectId,
        parity: Parity,
    },
    /// The thread is released by a completed generation.
    Resume(GenerationId),
    /// A generation completes (a `Generation` context).
    GenerationComplete(GenerationId),
    /// The thread issues an asynchronous operation; the op's effects are `Async` events.
    AsyncIssue(AsyncOpId),
    /// An asynchronous operation completes (an `Async` context).
    AsyncComplete(AsyncOpId),
    /// The thread seals its uncommitted ops of `family` into a new group (`commit_group`).
    GroupCommit(GroupFamily),
    Fence(FenceKind),
    /// A synchronization object's lifetime begins (`mbarrier.init`).
    ObjectInit(SyncObjectId),
    /// A synchronization object's lifetime ends (`mbarrier.inval`).
    ObjectInval(SyncObjectId),
    /// Tensor Memory columns `[start_col, start_col + num_cols)` become allocated.
    TmemAlloc {
        start_col: u16,
        num_cols: u16,
    },
    /// Tensor Memory columns `[start_col, start_col + num_cols)` are freed.
    TmemDealloc {
        start_col: u16,
        num_cols: u16,
    },
    /// The thread exits; nothing follows it in its program order.
    Exit,
}

/// The commit-group mechanism a `GroupCommit` belongs to.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum GroupFamily {
    /// `cp.async.commit_group`, waited on by `cp.async.wait_group`.
    CpAsync,
    /// `wgmma.commit_group`, waited on by `wgmma.wait_group`.
    Wgmma,
}

/// An mbarrier phase parity.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Parity {
    Even,
    Odd,
}

impl Parity {
    pub fn of_phase(index: u32) -> Parity {
        if index.is_multiple_of(2) {
            Parity::Even
        } else {
            Parity::Odd
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FenceKind {
    /// `fence.proxy.async`: a generic/async proxy fence over `space` (`None` = every space).
    ProxyAsync { space: Option<Space> },
    /// `tcgen05.fence::before_thread_sync` / `::after_thread_sync`.
    Tcgen05,
}

// =========================================================================
// Memory effects
// =========================================================================

/// A memory space with cross-thread effects (local memory is thread-private).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Space {
    Global,
    Shared,
    /// Tensor Memory, addressed by (lane, column) cells of 32 bits.
    Tensor,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AccessMode {
    Read,
    Write,
}

/// The memory-model kind of an effect. The analysis rejects atomics and reductions, so it only
/// records `Ordinary`; checkers must not apply non-atomic rules to the others.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum OrderingKind {
    Ordinary,
    Atomic,
    Reduction,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Proxy {
    Generic,
    Async,
}

/// The canonical physical locations an effect touches.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Footprint {
    /// Bytes `[addr, addr + width)` of a byte-addressed space; never wraps.
    Bytes { addr: u64, width: u32 },
    /// Tensor Memory lanes `[lane, lane + lanes)` x columns `[col, col + cols)`.
    Tensor {
        lane: u8,
        lanes: u8,
        col: u16,
        cols: u16,
    },
}

impl Footprint {
    /// Whether two footprints share a location (callers compare effects of one space).
    pub fn overlaps(&self, other: &Footprint) -> bool {
        match (*self, *other) {
            (Footprint::Bytes { addr: a, width: aw }, Footprint::Bytes { addr: b, width: bw }) => {
                let (a, b) = (u128::from(a), u128::from(b));
                a < b + u128::from(bw) && b < a + u128::from(aw)
            }
            (
                Footprint::Tensor {
                    lane: al,
                    lanes: an,
                    col: ac,
                    cols: acn,
                },
                Footprint::Tensor {
                    lane: bl,
                    lanes: bn,
                    col: bc,
                    cols: bcn,
                },
            ) => {
                let lanes = u32::from(al) < u32::from(bl) + u32::from(bn)
                    && u32::from(bl) < u32::from(al) + u32::from(an);
                let cols = u32::from(ac) < u32::from(bc) + u32::from(bcn)
                    && u32::from(bc) < u32::from(ac) + u32::from(acn);
                lanes && cols
            }
            _ => false,
        }
    }
}

/// Which operand of its instruction an effect is.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum OperandRole {
    /// The memory operand of an ordinary load/store or warp-cooperative access.
    Plain,
    /// An async copy's source read.
    Source,
    /// An async copy's destination write.
    Destination,
    /// A matrix-multiply `A` operand read (shared memory or Tensor Memory).
    MmaA,
    /// A matrix-multiply `B` operand read.
    MmaB,
    /// A matrix-multiply accumulator (`D`) read or write in Tensor Memory.
    Accumulator,
    /// The Tensor Memory cells of a `tcgen05.ld`/`.st`.
    TmemData,
}

/// A value stored by a write, as expressions of the producer's arena.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StoredValue {
    Scalar(ExprId),
    /// Two packed lanes (low first).
    Pair(ExprId, ExprId),
    /// Four packed byte lanes (lowest first).
    Quad([ExprId; 4]),
    /// A value without an expression form (e.g. an mbarrier handle).
    Opaque,
}

/// One memory effect.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MemAccess {
    pub space: Space,
    pub mode: AccessMode,
    pub ordering: OrderingKind,
    pub proxy: Proxy,
    pub footprint: Footprint,
    pub role: OperandRole,
    /// The thread the effect is attributed to: the issuer, or the lane a collective op
    /// performs it for.
    pub attributed: ThreadIx,
    /// The stored value, for writes.
    pub value: Option<ValueId>,
}

// =========================================================================
// Synchronization objects and generations
// =========================================================================

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SyncObjectKind {
    /// One of the CTA's hardware named barriers (`bar.sync`, `bar.arrive`).
    NamedBarrier { id: u8 },
    /// One lifetime (`init` to `inval`) of an mbarrier object at a shared address; a
    /// re-initialization is a new object.
    Mbarrier { addr: u64, expected_arrivals: u64 },
    /// The warp-cooperative op instances of one warp.
    WarpCollective { warp: u32 },
    /// The warpgroup-cooperative op instances (`wgmma.mma_async`) of one warpgroup.
    WarpgroupCollective { warpgroup: u32 },
    /// One thread's `cp.async.wait_group` completions.
    AsyncGroupWait { thread: ThreadIx },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SyncObject {
    pub kind: SyncObjectKind,
    pub init: Option<EventId>,
    pub inval: Option<EventId>,
}

/// How many arrivals complete a named barrier's generation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum BarrierArrivals {
    /// Every live thread of the CTA (`bar.sync a`); exited threads count as arrived.
    FullCta,
    /// Exactly this many threads (`bar.sync a, b`, `bar.arrive a, b`).
    Count(u32),
}

/// Which end of a collective instance a generation is.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum CollectiveSide {
    /// Members arrive before the op's effects.
    Entry,
    /// Members leave after the op's effects.
    Exit,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GenerationKind {
    Barrier {
        arrivals: BarrierArrivals,
    },
    /// The phase whose index is the generation's `index`.
    MbarrierPhase,
    /// One side of a collective instance over the `mask` lanes, at `pc`.
    Collective {
        pc: ProgramPoint,
        mask: u32,
        side: CollectiveSide,
    },
    /// A `cp.async.wait_group n` (or `wait_all`, `n = 0`) completing the groups past `n`.
    AsyncGroupWait {
        keep_pending: u32,
    },
}

/// How a contribution takes part in its generation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ContributionKind {
    /// The thread waits at this generation until it completes (`bar.sync`, a collective).
    Blocking,
    /// A non-blocking arrival of `count` with release semantics (`bar.arrive`,
    /// `mbarrier.arrive`, `cp.async.mbarrier.arrive`, `tcgen05.commit`), raising the
    /// expected transaction bytes by `expect_tx`.
    Arrival { count: u64, expect_tx: u64 },
    /// An exited thread (its `Exit` event), counted as arrived.
    Exited,
    /// An asynchronous operation's completion (its `AsyncComplete` event), with the
    /// transaction bytes it completes on an mbarrier.
    AsyncCompletion { op: AsyncOpId, tx_bytes: u64 },
    /// An `mbarrier.complete_tx` of `bytes`: `.relaxed`, so it orders nothing.
    CompleteTx { bytes: u64 },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Contribution {
    pub event: EventId,
    pub kind: ContributionKind,
}

/// What the producer observed when a generation completed.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct GenerationEvidence {
    /// Named barriers: arrivals beyond the count present when the generation fired.
    pub surplus_arrivals: u32,
    /// mbarrier phases: net outstanding transaction bytes at completion.
    pub pending_tx: i64,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Generation {
    pub object: SyncObjectId,
    /// The logical generation number within the object, from 0.
    pub index: u32,
    pub kind: GenerationKind,
    pub contributions: Vec<Contribution>,
    /// `Resume` events of the threads it released.
    pub releases: Vec<EventId>,
    pub completion: Option<EventId>,
    pub evidence: GenerationEvidence,
}

// =========================================================================
// Asynchronous operations
// =========================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AsyncOpKind {
    /// `cp.async` (global to shared), completed by `wait_group` or `cp.async.mbarrier.arrive`.
    CpAsync,
    /// `cp.async.bulk` (global to shared), completed on an mbarrier.
    BulkCopy,
    /// `cp.async.bulk.tensor` (TMA), completed on an mbarrier.
    TensorCopy,
    /// A `clusterlaunchcontrol.try_cancel` response write, completed on an mbarrier.
    ClcResponse,
    /// `tcgen05.mma`, tracked by later `tcgen05.commit`s of its issuer.
    Tcgen05Mma,
    /// `tcgen05.ld`, completed by the warp's `tcgen05.wait::ld`.
    Tcgen05Ld,
    /// `tcgen05.st`, completed by the warp's `tcgen05.wait::st`.
    Tcgen05St,
    /// One member's share of a `wgmma.mma_async`; `instance` names the warpgroup op.
    WgmmaMma { instance: u32 },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AsyncOp {
    pub kind: AsyncOpKind,
    pub issuer: ThreadIx,
    pub pc: ProgramPoint,
    /// The `AsyncIssue` event, in the issuer's program order.
    pub issue: EventId,
    pub effects: Vec<AccessId>,
    pub completion: Option<EventId>,
    /// Generations listing this op's completion as a contribution (tentative tracking).
    pub tracking: Vec<GenerationId>,
}

// =========================================================================
// Terminal state and provenance
// =========================================================================

/// How the candidate execution ended.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Terminal {
    /// Every thread exited.
    Completed,
    /// No thread could proceed; every live thread is listed with its wait condition.
    Stuck { blocked: Vec<BlockedThread> },
    /// The producer stopped the execution (unsupported or invalid behavior, a budget).
    Aborted {
        thread: Option<ThreadIx>,
        pc: Option<ProgramPoint>,
        reason: String,
    },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BlockedThread {
    pub thread: ThreadIx,
    pub pc: ProgramPoint,
    pub on: BlockedOn,
}

/// A blocked thread's wait condition, with the state that disables it.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum BlockedOn {
    /// Waiting in a named barrier generation.
    Barrier { generation: GenerationId },
    /// Waiting at a collective instance's entry for the missing live lanes.
    Collective {
        generation: GenerationId,
        missing: Vec<ThreadIx>,
    },
    /// Waiting for an mbarrier phase of parity `parity` to complete.
    Mbarrier {
        object: SyncObjectId,
        parity: Parity,
        state: MbarrierState,
    },
}

/// An mbarrier's forming phase when the execution stopped.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MbarrierState {
    pub completed_phases: u32,
    pub arrived: u64,
    pub expected: u64,
    pub pending_tx: i64,
}

/// A modeling assumption the producer executed under, recorded so verdicts can cite it.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Assumption {
    /// Addresses, branch conditions and synchronization parameters are concrete: the
    /// kernel is a structured CTA under the launch configuration.
    StructuredCta,
    /// One CTA (block (0, 0, 0)) is analyzed; the others run the same code.
    SingleCtaAnalyzed,
    /// Every cluster holds exactly one CTA.
    SingleCtaCluster,
    /// No `clusterlaunchcontrol.try_cancel` request ever succeeds.
    NeverStealClusterLaunchControl,
    /// An exited thread counts as arrived at full-CTA barriers and warp collectives
    /// (the paper's Sync' rule).
    ExitedThreadsArrive,
    /// Asynchronous operations compute their data at issue; only their completion is
    /// asynchronous.
    EagerAsyncData,
    /// The target has an async proxy (sm_90+): generic writes need a proxy fence before an
    /// async-proxy read.
    AsyncProxy,
}

impl Assumption {
    pub fn describe(self) -> &'static str {
        match self {
            Assumption::StructuredCta => {
                "addresses, branch conditions and synchronization parameters are concrete"
            }
            Assumption::SingleCtaAnalyzed => {
                "CTA (0, 0, 0) is analyzed and stands for every CTA of the grid"
            }
            Assumption::SingleCtaCluster => "every cluster holds exactly one CTA",
            Assumption::NeverStealClusterLaunchControl => {
                "no clusterlaunchcontrol.try_cancel request succeeds"
            }
            Assumption::ExitedThreadsArrive => {
                "an exited thread counts as arrived at full-CTA barriers and warp collectives"
            }
            Assumption::EagerAsyncData => {
                "asynchronous operations compute their data at issue; only completion is \
                 asynchronous"
            }
            Assumption::AsyncProxy => {
                "the target has an async proxy (sm_90+): async-proxy reads of generic writes \
                 need a proxy fence"
            }
        }
    }
}

/// The launch, target and model the graph was produced under.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Provenance {
    pub kernel: String,
    pub block_dim: (u32, u32, u32),
    pub grid_dim: (u32, u32, u32),
    pub targets: Vec<String>,
    pub assumptions: Vec<Assumption>,
    /// Per [`ProgramPoint`]: the instruction kind and its source byte span.
    pub instructions: Vec<InstructionInfo>,
}

impl Provenance {
    pub fn threads(&self) -> u32 {
        self.block_dim.0 * self.block_dim.1 * self.block_dim.2
    }

    pub fn assumes(&self, assumption: Assumption) -> bool {
        self.assumptions.contains(&assumption)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InstructionInfo {
    pub kind: &'static str,
    pub span: Option<(usize, usize)>,
}
