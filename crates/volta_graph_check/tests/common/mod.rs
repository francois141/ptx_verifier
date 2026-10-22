//! Builders for small, purpose-made event graphs, shared by the check test crates.

#![allow(dead_code)]

use volta_expr::{ExprArena, ExprId};
use volta_graph::{
    AbortCause, AccessMode, ArrivalOrdering, Assumption, AsyncOpId, AsyncOpKind, BarrierArrivals,
    CollectiveSide, ContributionKind, EventGraph, EventId, FenceKind, Footprint,
    GenerationEvidence, GenerationId, GenerationKind, GraphBuilder, InstructionInfo, MemAccess,
    MemberOrdering, OperandRole, OrderingKind, Parity, ProgramPoint, Provenance, Proxy, Space,
    StoredValue, SyncObjectId, SyncObjectKind, Terminal, ThreadIx,
};

pub const PC: ProgramPoint = ProgramPoint(0);

pub fn provenance(threads: u32) -> Provenance {
    Provenance {
        kernel: "k".to_string(),
        block_dim: (threads, 1, 1),
        grid_dim: (1, 1, 1),
        targets: vec!["Sm100a".to_string()],
        assumptions: vec![Assumption::StructuredCta, Assumption::ExitedThreadsArrive],
        instructions: vec![
            InstructionInfo {
                kind: "test",
                span: None,
            };
            4
        ],
    }
}

/// A graph under construction plus the arena its stored values live in.
pub struct Scenario {
    pub b: GraphBuilder,
    pub arena: ExprArena,
    barrier: Option<SyncObjectId>,
    barrier_index: u32,
    next_mbarrier: u64,
}

pub fn t(i: u32) -> ThreadIx {
    ThreadIx(i)
}

/// One Tensor Memory effect of a `tcgen05` op: mode, role, lanes `[l, l + n)`, columns
/// `[c, c + m)`.
#[derive(Debug, Clone, Copy)]
pub struct Cells {
    pub mode: AccessMode,
    pub role: OperandRole,
    pub lanes: (u8, u8),
    pub cols: (u16, u16),
}

impl Cells {
    /// An MMA accumulator effect over all 128 lanes.
    pub fn accumulator(mode: AccessMode, cols: (u16, u16)) -> Cells {
        Cells {
            mode,
            role: OperandRole::Accumulator,
            lanes: (0, 128),
            cols,
        }
    }

    /// A `tcgen05.ld`/`.st` effect of one warp's 32-lane quadrant.
    pub fn quadrant(mode: AccessMode, warp: u8, cols: (u16, u16)) -> Cells {
        Cells {
            mode,
            role: OperandRole::TmemData,
            lanes: (warp * 32, 32),
            cols,
        }
    }
}

impl Scenario {
    pub fn new(threads: u32) -> Self {
        Self::with(provenance(threads))
    }

    pub fn with(provenance: Provenance) -> Self {
        Scenario {
            b: GraphBuilder::new(provenance),
            arena: ExprArena::new(),
            barrier: None,
            barrier_index: 0,
            next_mbarrier: 0x1000,
        }
    }

    pub fn value(&mut self, v: i64) -> ExprId {
        self.arena.int(v)
    }

    fn access(
        &mut self,
        thread: u32,
        (space, mode): (Space, AccessMode),
        (addr, width): (u64, u32),
        value: Option<ExprId>,
        (proxy, role): (Proxy, OperandRole),
    ) -> MemAccess {
        let value = value.map(|v| self.b.value(StoredValue::Scalar(v)));
        MemAccess {
            space,
            mode,
            ordering: OrderingKind::Ordinary,
            proxy,
            footprint: Footprint::Bytes { addr, width },
            role,
            attributed: t(thread),
            value,
        }
    }

    /// `thread` reads 4 shared bytes at `addr`.
    pub fn read(&mut self, thread: u32, addr: u64) -> EventId {
        self.read_bytes(thread, addr, 4)
    }

    pub fn read_bytes(&mut self, thread: u32, addr: u64, width: u32) -> EventId {
        let a = self.access(
            thread,
            (Space::Shared, AccessMode::Read),
            (addr, width),
            None,
            (Proxy::Generic, OperandRole::Plain),
        );
        self.b.thread_access(t(thread), PC, a)
    }

    /// `thread` writes `value` to 4 shared bytes at `addr`.
    pub fn write(&mut self, thread: u32, addr: u64, value: i64) -> EventId {
        let v = self.value(value);
        self.write_expr(thread, addr, v)
    }

    pub fn write_expr(&mut self, thread: u32, addr: u64, value: ExprId) -> EventId {
        let a = self.access(
            thread,
            (Space::Shared, AccessMode::Write),
            (addr, 4),
            Some(value),
            (Proxy::Generic, OperandRole::Plain),
        );
        self.b.thread_access(t(thread), PC, a)
    }

    /// A full-CTA barrier generation every listed thread blocks at; `exited` threads count as
    /// arrived through their exits.
    pub fn barrier(&mut self, threads: &[u32], exited: &[u32]) -> GenerationId {
        let object = *self
            .barrier
            .get_or_insert_with(|| self.b.sync_object(SyncObjectKind::NamedBarrier { id: 0 }));
        let g = self.b.open_generation(
            object,
            self.barrier_index,
            GenerationKind::Barrier {
                arrivals: BarrierArrivals::FullCta,
            },
        );
        self.barrier_index += 1;
        for &th in threads {
            self.b.contribute(t(th), PC, g, ContributionKind::Blocking);
        }
        for &th in exited {
            let exit = self.b.exit_event(t(th)).expect("an exited thread");
            self.b.contribute_exited(g, exit);
        }
        self.b.complete_generation(g, GenerationEvidence::default());
        for &th in threads {
            self.b.resume(t(th), PC, g);
        }
        g
    }

    /// A counted named-barrier generation `index` of barrier object `object`: `arrive` threads
    /// arrive without blocking, `sync` threads block.
    pub fn counted_barrier(
        &mut self,
        object: SyncObjectId,
        index: u32,
        count: u32,
        arrive: &[u32],
        sync: &[u32],
    ) -> GenerationId {
        let g = self.b.open_generation(
            object,
            index,
            GenerationKind::Barrier {
                arrivals: BarrierArrivals::Count(count),
            },
        );
        for &th in arrive {
            self.arrive(th, g);
        }
        for &th in sync {
            self.b.contribute(t(th), PC, g, ContributionKind::Blocking);
        }
        self.b.complete_generation(g, GenerationEvidence::default());
        for &th in sync {
            self.b.resume(t(th), PC, g);
        }
        g
    }

    /// A new mbarrier, initialized by `initializer`, at its own shared address.
    pub fn mbarrier(&mut self, initializer: u32, expected: u64) -> SyncObjectId {
        let o = self.b.sync_object(SyncObjectKind::Mbarrier {
            addr: self.next_mbarrier,
            expected_arrivals: expected,
        });
        self.next_mbarrier += 8;
        self.b.object_init(t(initializer), PC, o);
        o
    }

    pub fn phase(&mut self, object: SyncObjectId, index: u32) -> GenerationId {
        self.b
            .open_generation(object, index, GenerationKind::MbarrierPhase)
    }

    /// `object`'s phase before phase 0, complete at once.
    pub fn pre_init(&mut self, object: SyncObjectId) -> GenerationId {
        let g = self
            .b
            .open_generation(object, 0, GenerationKind::MbarrierPreInit);
        self.complete(g);
        g
    }

    pub fn arrive(&mut self, thread: u32, g: GenerationId) -> EventId {
        self.b.contribute(
            t(thread),
            PC,
            g,
            ContributionKind::Arrival {
                count: 1,
                expect_tx: 0,
                ordering: ArrivalOrdering::Release,
            },
        )
    }

    /// `thread` announces `bytes` on `g` without arriving (`mbarrier.expect_tx`).
    pub fn expect_tx(&mut self, thread: u32, g: GenerationId, bytes: u64) -> EventId {
        self.b
            .contribute(t(thread), PC, g, ContributionKind::ExpectTx { bytes })
    }

    /// `thread`'s `mbarrier.arrive.expect_tx` of `bytes` on `g`.
    pub fn arrive_expect_tx(&mut self, thread: u32, g: GenerationId, bytes: u64) -> EventId {
        self.b.contribute(
            t(thread),
            PC,
            g,
            ContributionKind::Arrival {
                count: 1,
                expect_tx: bytes,
                ordering: ArrivalOrdering::Release,
            },
        )
    }

    /// A bulk copy by `issuer` into 4 shared bytes at `addr` whose completion counts `bytes`
    /// on phase `g`.
    pub fn bulk_copy(&mut self, issuer: u32, addr: u64, g: GenerationId, bytes: u64) -> AsyncOpId {
        let op = self.async_op(
            issuer,
            AsyncOpKind::BulkCopy,
            AccessMode::Write,
            addr,
            Proxy::Async,
        );
        self.b.track(op, g, bytes);
        op
    }

    pub fn complete(&mut self, g: GenerationId) -> EventId {
        self.b.complete_generation(g, GenerationEvidence::default())
    }

    /// `thread` waits on `object` for `parity` and is released by `g`; returns the release.
    pub fn wait(
        &mut self,
        thread: u32,
        object: SyncObjectId,
        parity: Parity,
        g: GenerationId,
    ) -> EventId {
        self.b.wait_start(t(thread), PC, object, parity);
        self.b.resume(t(thread), PC, g)
    }

    /// An async op of `kind` by `issuer` writing (or reading) 4 shared bytes at `addr`.
    pub fn async_op(
        &mut self,
        issuer: u32,
        kind: AsyncOpKind,
        mode: AccessMode,
        addr: u64,
        proxy: Proxy,
    ) -> AsyncOpId {
        let role = match mode {
            AccessMode::Read => OperandRole::Source,
            AccessMode::Write => OperandRole::Destination,
        };
        self.async_op_as(issuer, kind, mode, addr, (proxy, role))
    }

    /// [`Self::async_op`] with an explicit operand role.
    pub fn async_op_as(
        &mut self,
        issuer: u32,
        kind: AsyncOpKind,
        mode: AccessMode,
        addr: u64,
        (proxy, role): (Proxy, OperandRole),
    ) -> AsyncOpId {
        let op = self.b.async_issue(t(issuer), PC, kind);
        let value = (mode == AccessMode::Write).then(|| self.arena.int(99));
        let a = self.access(
            issuer,
            (Space::Shared, mode),
            (addr, 4),
            value,
            (proxy, role),
        );
        self.b.async_effect(op, a);
        op
    }

    /// The single effect event of an op built by [`Self::async_op`].
    pub fn effect(&self, op: AsyncOpId) -> EventId {
        self.b
            .graph_so_far()
            .events()
            .iter()
            .find(|(_, ev)| {
                ev.ctx == volta_graph::ExecContext::Async(op)
                    && matches!(ev.kind, volta_graph::EventKind::Access(_))
            })
            .expect("the op has an effect")
            .0
    }

    /// A `tcgen05` op of `kind` by `issuer` with the Tensor Memory effects `cells`; returns
    /// the op and its effect events.
    pub fn tmem_op(
        &mut self,
        issuer: u32,
        kind: AsyncOpKind,
        cells: &[Cells],
    ) -> (AsyncOpId, Vec<EventId>) {
        let op = self.b.async_issue(t(issuer), PC, kind);
        let effects = cells
            .iter()
            .map(|c| {
                let value =
                    (c.mode == AccessMode::Write).then(|| self.b.value(StoredValue::Opaque));
                self.b.async_effect(
                    op,
                    MemAccess {
                        space: Space::Tensor,
                        mode: c.mode,
                        ordering: OrderingKind::Ordinary,
                        proxy: Proxy::Async,
                        footprint: Footprint::Tensor {
                            lane: c.lanes.0,
                            lanes: c.lanes.1,
                            col: c.cols.0,
                            cols: c.cols.1,
                        },
                        role: c.role,
                        attributed: t(issuer),
                        value,
                    },
                )
            })
            .collect();
        (op, effects)
    }

    /// A `tcgen05.mma` by `issuer` writing accumulator columns `cols` of every lane: the op
    /// and its write effect.
    pub fn mma(&mut self, issuer: u32, cols: (u16, u16)) -> (AsyncOpId, EventId) {
        let (op, effects) = self.tmem_op(
            issuer,
            AsyncOpKind::Tcgen05Mma,
            &[Cells::accumulator(AccessMode::Write, cols)],
        );
        (op, effects[0])
    }

    /// A `tcgen05.ld` by `issuer` reading columns `cols` of warp `warp`'s lanes.
    pub fn tmem_ld(&mut self, issuer: u32, warp: u8, cols: (u16, u16)) -> (AsyncOpId, EventId) {
        let (op, effects) = self.tmem_op(
            issuer,
            AsyncOpKind::Tcgen05Ld,
            &[Cells::quadrant(AccessMode::Read, warp, cols)],
        );
        (op, effects[0])
    }

    /// A `tcgen05.st` by `issuer` writing columns `cols` of warp `warp`'s lanes.
    pub fn tmem_st(&mut self, issuer: u32, warp: u8, cols: (u16, u16)) -> (AsyncOpId, EventId) {
        let (op, effects) = self.tmem_op(
            issuer,
            AsyncOpKind::Tcgen05St,
            &[Cells::quadrant(AccessMode::Write, warp, cols)],
        );
        (op, effects[0])
    }

    /// A `tcgen05.wait` of warp `warp` by `lanes`: a warp collective whose exit completes
    /// `ops`, as the interpreter records `tcgen05.wait::ld`/`::st`. Returns the exit.
    pub fn warp_wait(&mut self, warp: u32, lanes: &[u32], ops: &[AsyncOpId]) -> GenerationId {
        let known = self
            .b
            .graph_so_far()
            .objects()
            .iter()
            .find(|(_, o)| o.kind == SyncObjectKind::WarpCollective { warp })
            .map(|(id, _)| id);
        let object =
            known.unwrap_or_else(|| self.b.sync_object(SyncObjectKind::WarpCollective { warp }));
        let index = self
            .b
            .graph_so_far()
            .generations()
            .values()
            .filter(|g| g.object == object)
            .count() as u32
            / 2;
        let mask = lanes.iter().fold(0u32, |m, &l| m | 1 << (l % 32));
        let kind = |side| GenerationKind::Collective {
            pc: PC,
            mask,
            side,
            ordering: MemberOrdering::ExecutionOnly,
        };
        let entry = self
            .b
            .open_generation(object, index, kind(CollectiveSide::Entry));
        for &l in lanes {
            self.b
                .contribute(t(l), PC, entry, ContributionKind::Blocking);
        }
        self.b
            .complete_generation(entry, GenerationEvidence::default());
        for &l in lanes {
            self.b.resume(t(l), PC, entry);
        }
        let exit = self
            .b
            .open_generation(object, index, kind(CollectiveSide::Exit));
        for &op in ops {
            self.b.track(op, exit, 0);
        }
        for &l in lanes {
            self.b
                .contribute(t(l), PC, exit, ContributionKind::Blocking);
        }
        self.b
            .complete_generation(exit, GenerationEvidence::default());
        for &l in lanes {
            self.b.resume(t(l), PC, exit);
        }
        exit
    }

    /// `thread`'s `tcgen05.commit` of `ops` to phase `g`: the phase tracks them, then the
    /// thread's async-tracked arrive-on. Returns the arrival.
    pub fn commit(&mut self, thread: u32, g: GenerationId, ops: &[AsyncOpId]) -> EventId {
        for &op in ops {
            self.b.track(op, g, 0);
        }
        self.b.contribute(
            t(thread),
            PC,
            g,
            ContributionKind::Arrival {
                count: 1,
                expect_tx: 0,
                ordering: ArrivalOrdering::AsyncTracked,
            },
        )
    }

    pub fn tcgen05_before(&mut self, thread: u32) -> EventId {
        self.b
            .fence(t(thread), PC, FenceKind::Tcgen05BeforeThreadSync)
    }

    pub fn tcgen05_after(&mut self, thread: u32) -> EventId {
        self.b
            .fence(t(thread), PC, FenceKind::Tcgen05AfterThreadSync)
    }

    /// `fence.proxy.async` over `space` (`None`: every space).
    pub fn proxy_fence(&mut self, thread: u32, space: Option<Space>) -> EventId {
        self.b.fence(t(thread), PC, FenceKind::ProxyAsync { space })
    }

    pub fn exit(&mut self, thread: u32) -> EventId {
        self.b.exit(t(thread), PC)
    }

    pub fn exit_all(&mut self, threads: u32) {
        for th in 0..threads {
            if self.b.exit_event(t(th)).is_none() {
                self.b.exit(t(th), PC);
            }
        }
    }

    pub fn finish(self, terminal: Terminal) -> (EventGraph, ExprArena) {
        (self.b.finish(terminal), self.arena)
    }

    pub fn completed(mut self, threads: u32) -> (EventGraph, ExprArena) {
        self.exit_all(threads);
        self.finish(Terminal::Completed)
    }

    /// The graph so far, as an aborted (partial) trace.
    pub fn aborted(self) -> (EventGraph, ExprArena) {
        self.finish(Terminal::Aborted {
            thread: None,
            pc: None,
            cause: AbortCause::Error,
            reason: "test".to_string(),
        })
    }
}
