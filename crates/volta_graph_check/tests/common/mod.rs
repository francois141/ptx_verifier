//! Builders for small, purpose-made event graphs, shared by the checker test crates.

#![allow(dead_code)]

use volta_expr::{ExprArena, ExprId};
use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, BarrierArrivals, ContributionKind, EventGraph, EventId,
    Footprint, GenerationEvidence, GenerationId, GenerationKind, GraphBuilder, InstructionInfo,
    MemAccess, OrderingKind, Parity, ProgramPoint, Provenance, Proxy, Space, StoredValue,
    SyncObjectId, SyncObjectKind, Terminal, ThreadIx,
};

pub const PC: ProgramPoint = ProgramPoint(0);

pub fn provenance(threads: u32) -> Provenance {
    Provenance {
        kernel: "k".to_string(),
        block_dim: (threads, 1, 1),
        grid_dim: (1, 1, 1),
        targets: vec!["Sm90a".to_string()],
        assumptions: vec![
            volta_graph::Assumption::StructuredCta,
            volta_graph::Assumption::ExitedThreadsArrive,
        ],
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
}

pub fn t(i: u32) -> ThreadIx {
    ThreadIx(i)
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
        }
    }

    pub fn value(&mut self, v: i64) -> ExprId {
        self.arena.int(v)
    }

    fn access(
        &mut self,
        thread: u32,
        space: Space,
        mode: AccessMode,
        addr: u64,
        width: u32,
        value: Option<ExprId>,
        proxy: Proxy,
    ) -> MemAccess {
        let value = value.map(|v| self.b.value(StoredValue::Scalar(v)));
        MemAccess {
            space,
            mode,
            ordering: OrderingKind::Ordinary,
            proxy,
            footprint: Footprint::Bytes { addr, width },
            attributed: t(thread),
            value,
        }
    }

    pub fn read(&mut self, thread: u32, addr: u64) -> EventId {
        let a = self.access(
            thread,
            Space::Shared,
            AccessMode::Read,
            addr,
            4,
            None,
            Proxy::Generic,
        );
        self.b.thread_access(t(thread), PC, a)
    }

    pub fn write(&mut self, thread: u32, addr: u64, value: i64) -> EventId {
        let v = self.value(value);
        let a = self.access(
            thread,
            Space::Shared,
            AccessMode::Write,
            addr,
            4,
            Some(v),
            Proxy::Generic,
        );
        self.b.thread_access(t(thread), PC, a)
    }

    pub fn write_expr(&mut self, thread: u32, addr: u64, value: ExprId) -> EventId {
        let a = self.access(
            thread,
            Space::Shared,
            AccessMode::Write,
            addr,
            4,
            Some(value),
            Proxy::Generic,
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
            self.b.contribute(
                t(th),
                PC,
                g,
                ContributionKind::Arrival {
                    count: 1,
                    expect_tx: 0,
                },
            );
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

    pub fn mbarrier(&mut self, initializer: u32, expected: u64) -> SyncObjectId {
        let o = self.b.sync_object(SyncObjectKind::Mbarrier {
            addr: 0x1000,
            expected_arrivals: expected,
        });
        self.b.object_init(t(initializer), PC, o);
        o
    }

    pub fn phase(&mut self, object: SyncObjectId, index: u32) -> GenerationId {
        self.b
            .open_generation(object, index, GenerationKind::MbarrierPhase)
    }

    pub fn arrive(&mut self, thread: u32, g: GenerationId) -> EventId {
        self.b.contribute(
            t(thread),
            PC,
            g,
            ContributionKind::Arrival {
                count: 1,
                expect_tx: 0,
            },
        )
    }

    pub fn complete(&mut self, g: GenerationId) -> EventId {
        self.b.complete_generation(g, GenerationEvidence::default())
    }

    /// `thread` waits on `object` for `parity` and is released by `g`.
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
        let op = self.b.async_issue(t(issuer), PC, kind);
        let value = (mode == AccessMode::Write).then(|| self.arena.int(99));
        let a = self.access(issuer, Space::Shared, mode, addr, 4, value, proxy);
        self.b.async_effect(op, a);
        op
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
}
