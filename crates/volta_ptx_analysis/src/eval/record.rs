//! Recording the candidate execution into its event graph (`volta_graph`). The interpreter
//! calls these at the points where it performs an effect or a synchronization; nothing here
//! feeds back into execution, and no property of the trace is checked.

use std::collections::HashMap;

use volta_graph::{
    AccessMode, ArrivalOrdering, AsyncOpId, AsyncOpKind, BarrierArrivals as GraphArrivals,
    BlockedOn, BlockedThread, BulkWaitScope, CollectiveSide, ContributionKind, EventId, Footprint,
    GenerationEvidence, GenerationId, GenerationKind, GroupFamily, MbarrierState, MemAccess,
    MemberOrdering, OperandRole, OrderingKind, Parity, ProgramPoint, Proxy, Space, StoredValue,
    SyncObjectId, SyncObjectKind, ThreadIx,
};

use crate::eval::interp::{BarrierArrivals, Interpreter, Status};
use crate::eval::value::{MbarrierId, Value};
use crate::eval::{ThreadId, WARP_SIZE};
use crate::ir::{InstrId, LoweredInstr, MemSpace};

/// Who performs a memory access.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(in crate::eval) enum AccessOrigin {
    /// The thread's own synchronous access.
    Thread,
    /// An effect of asynchronous operation `op` on its `role` operand, through `proxy`.
    Async {
        op: AsyncOpId,
        proxy: Proxy,
        role: OperandRole,
    },
    /// The deferred application of an effect recorded at issue (a landing `cp.async`).
    Applied,
}

/// Which `tcgen05.wait` completes an async Tensor Memory op.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub(in crate::eval) enum Tcgen05Wait {
    Ld,
    St,
}

/// An mbarrier object's graph identity: one lifetime, the phase before its phase 0, and its
/// phases by index.
#[derive(Debug)]
struct MbarrierRecord {
    object: SyncObjectId,
    pre_init: GenerationId,
    phases: Vec<GenerationId>,
}

/// One warp's collective object and its next instance number.
#[derive(Debug, Clone, Copy)]
struct CollectiveObject {
    object: SyncObjectId,
    next: u32,
}

/// A collective instance whose entry generation is forming.
#[derive(Debug, Clone, Copy)]
struct FormingCollective {
    entry: GenerationId,
    index: u32,
    object: SyncObjectId,
    ordering: MemberOrdering,
}

/// Producer-side graph bookkeeping: the forming generation of every synchronization object and
/// the async ops awaiting a completion association. Execution never reads it.
#[derive(Debug, Default)]
pub(in crate::eval) struct Recording {
    named_barriers: HashMap<u32, (SyncObjectId, u32)>,
    forming_barriers: HashMap<u32, GenerationId>,
    warps: HashMap<u32, CollectiveObject>,
    forming_warp_ops: HashMap<(u32, InstrId, u32), FormingCollective>,
    mbarriers: HashMap<MbarrierId, MbarrierRecord>,
    group_waits: HashMap<(ThreadId, GroupFamily), (SyncObjectId, u32)>,
    unobserved_mmas: HashMap<ThreadId, Vec<AsyncOpId>>,
    tcgen05_pending: HashMap<(u32, Tcgen05Wait), Vec<AsyncOpId>>,
}

pub(in crate::eval) fn tix(t: ThreadId) -> ThreadIx {
    ThreadIx(t.0)
}

pub(in crate::eval) fn point(pc: InstrId) -> ProgramPoint {
    ProgramPoint(pc.0)
}

/// The graph space of a recorded access; local memory is thread-private and not recorded.
fn graph_space(space: MemSpace) -> Option<Space> {
    match space {
        MemSpace::Global => Some(Space::Global),
        MemSpace::Shared => Some(Space::Shared),
        MemSpace::Local | MemSpace::Param | MemSpace::Const => None,
    }
}

fn stored(value: Value) -> StoredValue {
    match value {
        Value::Scalar(e) => StoredValue::Scalar(e),
        Value::Pair(lo, hi) => StoredValue::Pair(lo, hi),
        Value::Quad(b0, b1, b2, b3) => StoredValue::Quad([b0, b1, b2, b3]),
        Value::Mbarrier(_) => StoredValue::Opaque,
    }
}

fn graph_arrivals(arrivals: BarrierArrivals) -> GraphArrivals {
    match arrivals {
        BarrierArrivals::FullCta => GraphArrivals::FullCta,
        BarrierArrivals::Count(n) => GraphArrivals::Count(n),
    }
}

impl Interpreter<'_> {
    /// Record a byte-addressed memory effect (`value` for writes).
    #[allow(clippy::too_many_arguments)]
    pub(in crate::eval) fn record_mem_access(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
        value: Option<Value>,
        origin: AccessOrigin,
    ) {
        let value = value.map(stored);
        self.record_access(t, pc, space, addr, width, value, origin);
    }

    /// Record `t`'s write of an object Volta keeps outside the byte memory (a tensor map)
    /// over its bytes `[addr, addr + width)`.
    pub(in crate::eval) fn record_opaque_write(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
    ) {
        let value = Some(StoredValue::Opaque);
        self.record_access(t, pc, space, addr, width, value, AccessOrigin::Thread);
    }

    #[allow(clippy::too_many_arguments)]
    fn record_access(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
        value: Option<StoredValue>,
        origin: AccessOrigin,
    ) {
        let Some(space) = graph_space(space) else {
            return;
        };
        let (mode, value) = match value {
            Some(v) => (AccessMode::Write, Some(self.graph.value(v))),
            None => (AccessMode::Read, None),
        };
        let (proxy, role) = match origin {
            AccessOrigin::Thread => (Proxy::Generic, OperandRole::Plain),
            AccessOrigin::Async { proxy, role, .. } => (proxy, role),
            AccessOrigin::Applied => return,
        };
        let access = MemAccess {
            space,
            mode,
            ordering: OrderingKind::Ordinary,
            proxy,
            footprint: Footprint::Bytes {
                addr,
                width: width as u32,
            },
            role,
            attributed: tix(t),
            value,
        };
        match origin {
            AccessOrigin::Thread => {
                self.graph.thread_access(tix(t), point(pc), access);
            }
            AccessOrigin::Async { op, .. } => {
                self.graph.async_effect(op, access);
            }
            AccessOrigin::Applied => {}
        }
    }

    /// Record one Tensor Memory effect of `op`: lanes `[lane, lane + lanes)` x columns
    /// `[col, col + cols)`, attributed to `t`.
    #[allow(clippy::too_many_arguments)]
    pub(in crate::eval) fn record_tmem_effect(
        &mut self,
        op: AsyncOpId,
        t: ThreadId,
        (mode, role): (AccessMode, OperandRole),
        lane: u32,
        lanes: u32,
        col: u32,
        cols: u32,
    ) {
        let value = (mode == AccessMode::Write).then(|| self.graph.value(StoredValue::Opaque));
        self.graph.async_effect(
            op,
            MemAccess {
                space: Space::Tensor,
                mode,
                ordering: OrderingKind::Ordinary,
                proxy: Proxy::Async,
                footprint: Footprint::Tensor {
                    lane: lane as u8,
                    lanes: lanes as u8,
                    col: col as u16,
                    cols: cols as u16,
                },
                role,
                attributed: tix(t),
                value,
            },
        );
    }

    /// Record `op`'s effect on the cells `(lane_base + lane, col_base + col)` of `cells`, merging
    /// runs of consecutive columns of one lane into one rectangle.
    pub(in crate::eval) fn record_tmem_cells(
        &mut self,
        op: AsyncOpId,
        t: ThreadId,
        effect: (AccessMode, OperandRole),
        lane_base: u32,
        col_base: u32,
        cells: impl Iterator<Item = (u32, u32)>,
    ) {
        let mut run: Option<(u32, u32, u32)> = None;
        for (lane, col) in cells {
            let (lane, col) = (lane_base + lane, col_base + col);
            run = match run {
                Some((l, c, n)) if l == lane && c + n == col => Some((l, c, n + 1)),
                Some((l, c, n)) => {
                    self.record_tmem_effect(op, t, effect, l, 1, c, n);
                    Some((lane, col, 1))
                }
                None => Some((lane, col, 1)),
            };
        }
        if let Some((l, c, n)) = run {
            self.record_tmem_effect(op, t, effect, l, 1, c, n);
        }
    }

    /// Record `op`'s effect over lanes `lanes` (ascending) x columns `[col, col + cols)`, as
    /// one rectangle per run of consecutive lanes.
    pub(in crate::eval) fn record_tmem_lanes(
        &mut self,
        op: AsyncOpId,
        t: ThreadId,
        effect: (AccessMode, OperandRole),
        lanes: &[u32],
        (col, cols): (u32, u32),
    ) {
        let mut i = 0;
        while i < lanes.len() {
            let start = lanes[i];
            let mut end = i + 1;
            while end < lanes.len() && lanes[end] == lanes[end - 1] + 1 {
                end += 1;
            }
            self.record_tmem_effect(op, t, effect, start, (end - i) as u32, col, cols);
            i = end;
        }
    }

    // =====================================================================
    // Named barriers
    // =====================================================================

    /// `t` arrives at named barrier `id` (`blocking` for `bar.sync`).
    pub(in crate::eval) fn record_barrier_arrival(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        id: u32,
        arrivals: BarrierArrivals,
        blocking: bool,
    ) {
        let generation = match self.rec.forming_barriers.get(&id) {
            Some(&g) => g,
            None => {
                let (object, index) = match self.rec.named_barriers.get(&id) {
                    Some(&known) => known,
                    None => {
                        let object = self
                            .graph
                            .sync_object(SyncObjectKind::NamedBarrier { id: id as u8 });
                        (object, 0)
                    }
                };
                let g = self.graph.open_generation(
                    object,
                    index,
                    GenerationKind::Barrier {
                        arrivals: graph_arrivals(arrivals),
                    },
                );
                self.rec.named_barriers.insert(id, (object, index + 1));
                self.rec.forming_barriers.insert(id, g);
                g
            }
        };
        let kind = if blocking {
            ContributionKind::Blocking
        } else {
            ContributionKind::Arrival {
                count: 1,
                expect_tx: 0,
                ordering: ArrivalOrdering::Release,
            }
        };
        self.graph.contribute(tix(t), point(pc), generation, kind);
    }

    /// Named barrier `id` fires, releasing `waiting` (each blocked at its own pc); a full-CTA
    /// barrier also counts every exited thread.
    pub(in crate::eval) fn record_barrier_fire(
        &mut self,
        id: u32,
        arrivals: BarrierArrivals,
        waiting: &[ThreadId],
    ) {
        let Some(generation) = self.rec.forming_barriers.remove(&id) else {
            return;
        };
        if arrivals == BarrierArrivals::FullCta {
            self.record_exited_contributions(generation, 0..self.threads.len() as u32);
        }
        self.graph
            .complete_generation(generation, GenerationEvidence::default());
        for &w in waiting {
            let pc = self.threads[w].pc;
            self.graph.resume(tix(w), point(pc), generation);
        }
    }

    /// Every exited thread among `candidates` counts as arrived at `generation`.
    fn record_exited_contributions(
        &mut self,
        generation: GenerationId,
        candidates: impl Iterator<Item = u32>,
    ) {
        for t in candidates {
            let t = ThreadId(t);
            if self.threads[t].status == Status::Exited
                && let Some(exit) = self.graph.exit_event(tix(t))
            {
                self.graph.contribute_exited(generation, exit);
            }
        }
    }

    // =====================================================================
    // Warp collectives
    // =====================================================================

    /// `t` arrives at the warp op at `pc` over `mask`.
    pub(in crate::eval) fn record_warp_op_arrival(&mut self, t: ThreadId, pc: InstrId, mask: u32) {
        let warp = t.0 / WARP_SIZE;
        let key = (warp, pc, mask);
        let forming = match self.rec.forming_warp_ops.get(&key) {
            Some(&f) => f,
            None => {
                let collective = self
                    .rec
                    .warps
                    .entry(warp)
                    .or_insert_with(|| CollectiveObject {
                        object: self
                            .graph
                            .sync_object(SyncObjectKind::WarpCollective { warp }),
                        next: 0,
                    });
                let index = collective.next;
                collective.next += 1;
                let object = collective.object;
                let ordering = match self.program.instruction(pc) {
                    Some(LoweredInstr::BarWarpSync { .. }) => MemberOrdering::Synchronizing,
                    _ => MemberOrdering::ExecutionOnly,
                };
                let entry = self.graph.open_generation(
                    object,
                    index,
                    GenerationKind::Collective {
                        pc: point(pc),
                        mask,
                        side: CollectiveSide::Entry,
                        ordering,
                    },
                );
                let f = FormingCollective {
                    entry,
                    index,
                    object,
                    ordering,
                };
                self.rec.forming_warp_ops.insert(key, f);
                f
            }
        };
        self.graph
            .contribute(tix(t), point(pc), forming.entry, ContributionKind::Blocking);
    }

    /// A collective fires: its entry completes (exited `lanes` counted), its live `members`
    /// resume into the op, and its exit generation opens for the op's completions.
    fn record_collective_entry(
        &mut self,
        forming: FormingCollective,
        (pc, mask): (InstrId, u32),
        members: &[ThreadId],
        lanes: impl Iterator<Item = u32>,
    ) -> GenerationId {
        self.record_exited_contributions(forming.entry, lanes);
        self.graph
            .complete_generation(forming.entry, GenerationEvidence::default());
        for &m in members {
            self.graph.resume(tix(m), point(pc), forming.entry);
        }
        self.graph.open_generation(
            forming.object,
            forming.index,
            GenerationKind::Collective {
                pc: point(pc),
                mask,
                side: CollectiveSide::Exit,
                ordering: forming.ordering,
            },
        )
    }

    /// The warp op at `pc` over `mask` fires for its live `members`; returns its exit
    /// generation.
    pub(in crate::eval) fn record_warp_op_entry(
        &mut self,
        pc: InstrId,
        mask: u32,
        members: &[ThreadId],
    ) -> GenerationId {
        let warp = members[0].0 / WARP_SIZE;
        let forming = self
            .rec
            .forming_warp_ops
            .remove(&(warp, pc, mask))
            .expect("a firing warp op was arrived at");
        let base = warp * WARP_SIZE;
        let lanes = (0..WARP_SIZE)
            .filter(move |lane| mask & (1 << lane) != 0)
            .map(move |lane| base + lane);
        self.record_collective_entry(forming, (pc, mask), members, lanes)
    }

    /// The op's live `members` leave through its `exit` generation.
    pub(in crate::eval) fn record_collective_exit(
        &mut self,
        exit: GenerationId,
        pc: InstrId,
        members: &[ThreadId],
    ) {
        for &m in members {
            self.graph
                .contribute(tix(m), point(pc), exit, ContributionKind::Blocking);
        }
        self.graph
            .complete_generation(exit, GenerationEvidence::default());
        for &m in members {
            self.graph.resume(tix(m), point(pc), exit);
        }
    }

    // =====================================================================
    // mbarriers
    // =====================================================================

    /// `mbarrier.init` created object `id` at `addr`: a new lifetime, its pre-init phase
    /// complete and phase 0 forming.
    pub(in crate::eval) fn record_mbarrier_init(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        id: MbarrierId,
        addr: u64,
        expected_arrivals: u64,
    ) {
        let object = self.graph.sync_object(SyncObjectKind::Mbarrier {
            addr,
            expected_arrivals,
        });
        self.graph.object_init(tix(t), point(pc), object);
        let pre_init = self
            .graph
            .open_generation(object, 0, GenerationKind::MbarrierPreInit);
        self.graph
            .complete_generation(pre_init, GenerationEvidence::default());
        let phase0 = self
            .graph
            .open_generation(object, 0, GenerationKind::MbarrierPhase);
        self.rec.mbarriers.insert(
            id,
            MbarrierRecord {
                object,
                pre_init,
                phases: vec![phase0],
            },
        );
    }

    /// The forming phase of mbarrier `id`.
    pub(in crate::eval) fn forming_phase(&self, id: MbarrierId) -> GenerationId {
        *self.rec.mbarriers[&id]
            .phases
            .last()
            .expect("an mbarrier always has a forming phase")
    }

    /// After an arrival or transaction update on `id`, close every phase the table completed
    /// since `phases_before` and open the next one.
    pub(in crate::eval) fn record_mbarrier_progress(&mut self, id: MbarrierId, phases_before: u64) {
        let now = self.mbarriers.completed_phases(id);
        for _ in phases_before..now {
            let record = &self.rec.mbarriers[&id];
            let (object, forming) = (record.object, *record.phases.last().unwrap());
            let index = record.phases.len() as u32;
            let pending_tx = self.mbarriers.pending_tx(id);
            self.graph.complete_generation(
                forming,
                GenerationEvidence {
                    surplus_arrivals: 0,
                    pending_tx,
                },
            );
            let next = self
                .graph
                .open_generation(object, index, GenerationKind::MbarrierPhase);
            self.rec.mbarriers.get_mut(&id).unwrap().phases.push(next);
        }
    }

    /// `t` arrives on `id` with `count` arrivals and `expect_tx` expected bytes, releasing what
    /// `ordering` says.
    pub(in crate::eval) fn record_mbarrier_arrival(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        id: MbarrierId,
        (count, expect_tx): (u64, u64),
        ordering: ArrivalOrdering,
    ) {
        let phase = self.forming_phase(id);
        self.graph.contribute(
            tix(t),
            point(pc),
            phase,
            ContributionKind::Arrival {
                count,
                expect_tx,
                ordering,
            },
        );
    }

    /// `t`'s `mbarrier.expect_tx` of `bytes`: an announcement without an arrival.
    pub(in crate::eval) fn record_mbarrier_expect_tx(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        id: MbarrierId,
        bytes: u64,
    ) {
        let phase = self.forming_phase(id);
        self.graph.contribute(
            tix(t),
            point(pc),
            phase,
            ContributionKind::ExpectTx { bytes },
        );
    }

    /// `t`'s explicit `mbarrier.complete_tx` of `bytes`.
    pub(in crate::eval) fn record_mbarrier_complete_tx(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        id: MbarrierId,
        bytes: u64,
    ) {
        let phase = self.forming_phase(id);
        self.graph.contribute(
            tix(t),
            point(pc),
            phase,
            ContributionKind::CompleteTx { bytes },
        );
    }

    /// `t` starts waiting on `id` for parity `phase_parity`.
    pub(in crate::eval) fn record_mbarrier_wait(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        id: MbarrierId,
        phase_parity: bool,
    ) {
        let object = self.rec.mbarriers[&id].object;
        let parity = if phase_parity {
            Parity::Odd
        } else {
            Parity::Even
        };
        self.graph.wait_start(tix(t), point(pc), object, parity);
    }

    /// `t`'s wait on `id` returns, bound to the latest completed phase (the pre-init phase
    /// before phase 0 completes); ops that phase tracks are thereby observed.
    pub(in crate::eval) fn record_mbarrier_wake(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        id: MbarrierId,
    ) {
        let record = &self.rec.mbarriers[&id];
        let phase = match self.mbarriers.completed_phases(id) {
            0 => record.pre_init,
            completed => record.phases[completed as usize - 1],
        };
        self.graph.resume(tix(t), point(pc), phase);
        let observed: Vec<AsyncOpId> = self
            .graph
            .graph_so_far()
            .generation(phase)
            .contributions
            .iter()
            .filter_map(|c| match c.kind {
                ContributionKind::AsyncCompletion { op, .. } => Some(op),
                _ => None,
            })
            .collect();
        for list in self.rec.unobserved_mmas.values_mut() {
            list.retain(|op| !observed.contains(op));
        }
    }

    /// The blocked-thread record of `t` for a stuck terminal state.
    pub(in crate::eval) fn blocked_record(&self, t: ThreadId) -> BlockedThread {
        let state = &self.threads[t];
        let on = match state.status {
            Status::AtBarrier { id, .. } => BlockedOn::Barrier {
                generation: self.rec.forming_barriers[&id],
            },
            Status::AtWarpOp { mask } => {
                let warp = t.0 / WARP_SIZE;
                let forming = self.rec.forming_warp_ops[&(warp, state.pc, mask)];
                let base = warp * WARP_SIZE;
                let missing = (0..WARP_SIZE)
                    .filter(|lane| mask & (1 << lane) != 0)
                    .map(|lane| ThreadId(base + lane))
                    .filter(|&m| {
                        (m.0 as usize) < self.threads.len()
                            && !matches!(self.threads[m].status, Status::Exited)
                            && !(self.threads[m].status == state.status
                                && self.threads[m].pc == state.pc)
                    })
                    .map(tix)
                    .collect();
                BlockedOn::Collective {
                    generation: forming.entry,
                    missing,
                }
            }
            Status::AtMbarrier { id, phase_parity } => {
                let (completed_phases, arrived, expected, pending_tx) =
                    self.mbarriers.forming_state(id);
                BlockedOn::Mbarrier {
                    object: self.rec.mbarriers[&id].object,
                    parity: if phase_parity {
                        Parity::Odd
                    } else {
                        Parity::Even
                    },
                    state: MbarrierState {
                        completed_phases: completed_phases as u32,
                        arrived,
                        expected,
                        pending_tx,
                    },
                }
            }
            Status::Ready | Status::Exited => unreachable!("only blocked threads are recorded"),
        };
        BlockedThread {
            thread: tix(t),
            pc: point(state.pc),
            on,
        }
    }

    // =====================================================================
    // Asynchronous operations
    // =====================================================================

    pub(in crate::eval) fn record_async_issue(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        kind: AsyncOpKind,
    ) -> AsyncOpId {
        self.graph.async_issue(tix(t), point(pc), kind)
    }

    /// `op`'s completion counts `tx_bytes` on mbarrier `id`'s forming phase.
    pub(in crate::eval) fn record_tracked_by_mbarrier(
        &mut self,
        op: AsyncOpId,
        id: MbarrierId,
        tx_bytes: u64,
    ) {
        let phase = self.forming_phase(id);
        self.graph.track(op, phase, tx_bytes);
    }

    /// A new `tcgen05.mma` of `t` awaits a commit.
    pub(in crate::eval) fn record_mma_issued(&mut self, t: ThreadId, op: AsyncOpId) {
        self.rec.unobserved_mmas.entry(t).or_default().push(op);
    }

    /// `tcgen05.commit` by `t` on `id`: the phase forming now tracks `t`'s unobserved MMAs.
    pub(in crate::eval) fn record_mma_commit(&mut self, t: ThreadId, id: MbarrierId) {
        let phase = self.forming_phase(id);
        let ops = self
            .rec
            .unobserved_mmas
            .get(&t)
            .cloned()
            .unwrap_or_default();
        for op in ops {
            self.graph.track(op, phase, 0);
        }
    }

    /// A `tcgen05.ld`/`.st` of `warp` awaits that warp's matching `tcgen05.wait`.
    pub(in crate::eval) fn record_tcgen05_pending(
        &mut self,
        warp: u32,
        wait: Tcgen05Wait,
        op: AsyncOpId,
    ) {
        self.rec
            .tcgen05_pending
            .entry((warp, wait))
            .or_default()
            .push(op);
    }

    /// `warp`'s `tcgen05.wait` completes its pending ops of that kind into `exit`.
    pub(in crate::eval) fn record_tcgen05_wait(
        &mut self,
        warp: u32,
        wait: Tcgen05Wait,
        exit: GenerationId,
    ) {
        let ops = self
            .rec
            .tcgen05_pending
            .remove(&(warp, wait))
            .unwrap_or_default();
        for op in ops {
            self.graph.track(op, exit, 0);
        }
    }

    /// `t`'s `cp.async.wait_group` keeping `keep_pending` groups completed `ops`.
    pub(in crate::eval) fn record_group_wait(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        keep_pending: u32,
        ops: &[AsyncOpId],
    ) {
        let kind = GenerationKind::AsyncGroupWait { keep_pending };
        self.record_wait_generation(t, pc, GroupFamily::CpAsync, kind, ops);
    }

    /// `t`'s `cp.async.bulk.wait_group{.read}` keeping `keep_pending` groups completed `ops`.
    pub(in crate::eval) fn record_bulk_group_wait(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        keep_pending: u32,
        scope: BulkWaitScope,
        ops: &[AsyncOpId],
    ) {
        let kind = GenerationKind::BulkGroupWait {
            keep_pending,
            scope,
        };
        self.record_wait_generation(t, pc, GroupFamily::Bulk, kind, ops);
    }

    /// One generation of `t`'s waits on its `family` groups, completing `ops` and releasing `t`.
    fn record_wait_generation(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        family: GroupFamily,
        kind: GenerationKind,
        ops: &[AsyncOpId],
    ) {
        if ops.is_empty() {
            return;
        }
        let (object, index) = match self.rec.group_waits.get(&(t, family)) {
            Some(&known) => known,
            None => {
                let thread = tix(t);
                let object = match family {
                    GroupFamily::Bulk => SyncObjectKind::BulkGroupWait { thread },
                    GroupFamily::CpAsync | GroupFamily::Wgmma => {
                        SyncObjectKind::AsyncGroupWait { thread }
                    }
                };
                (self.graph.sync_object(object), 0)
            }
        };
        self.rec
            .group_waits
            .insert((t, family), (object, index + 1));
        let generation = self.graph.open_generation(object, index, kind);
        for &op in ops {
            self.graph.track(op, generation, 0);
        }
        self.graph
            .complete_generation(generation, GenerationEvidence::default());
        self.graph.resume(tix(t), point(pc), generation);
    }

    pub(in crate::eval) fn record_exit(&mut self, t: ThreadId, pc: InstrId) -> EventId {
        self.graph.exit(tix(t), point(pc))
    }
}
