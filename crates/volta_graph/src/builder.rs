use std::collections::HashMap;

use id_collections::IdVec;

use crate::graph::EventGraph;
use crate::ids::{
    AccessId, AsyncOpId, EventId, GenerationId, ProgramPoint, SyncObjectId, ThreadIx, ValueId,
};
use crate::model::{
    AbortCause, AccessMode, ArrivalOrdering, AsyncOp, AsyncOpKind, BarrierArrivals, BulkWaitScope,
    Contribution, ContributionKind, Event, EventKind, ExecContext, FenceKind, Footprint,
    Generation, GenerationEvidence, GenerationKind, GroupFamily, MemAccess, OperandRole,
    OrderingKind, Parity, Provenance, Proxy, Space, StoredValue, SyncObject, SyncObjectKind,
    Terminal,
};

/// Append-only construction of an [`EventGraph`] in trace order. It records what the producer
/// reports and keeps the graph's indexes consistent, including the generations of named
/// barriers and group waits; when anything happens is the producer's decision.
#[derive(Debug)]
pub struct GraphBuilder {
    graph: EventGraph,
    /// The objects whose generations the builder numbers, with the index the next one takes.
    numbered: HashMap<SyncObjectKind, (SyncObjectId, u32)>,
    /// The generation each named barrier's arrivals form until it fires.
    forming_barriers: HashMap<u8, GenerationId>,
}

/// What an ordinary memory effect does at its footprint.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Effect {
    Read,
    Write(StoredValue),
}

/// An ordinary memory effect as the producer performs it: a [`MemAccess`] whose written value
/// the builder stores.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct OrdinaryAccess {
    pub space: Space,
    pub footprint: Footprint,
    pub proxy: Proxy,
    pub role: OperandRole,
    pub effect: Effect,
}

/// A thread's wait for its own asynchronous operations, past the `keep_pending` most recent.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GroupWait {
    /// `cp.async.wait_group n` (`wait_all`: `n = 0`); an AMD `s_waitcnt lgkmcnt(n)`.
    Async { keep_pending: u32 },
    /// `cp.async.bulk.wait_group{.read} n`.
    Bulk {
        keep_pending: u32,
        scope: BulkWaitScope,
    },
}

/// Whether a thread arriving at a named barrier waits there until the generation completes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BarrierWait {
    /// `bar.sync`, `s_barrier`: the thread blocks and resumes when the barrier fires.
    Blocking,
    /// `bar.arrive`: a release of the thread's prior effects; the thread continues.
    NonBlocking,
}

impl GraphBuilder {
    pub fn new(provenance: Provenance) -> Self {
        let threads = provenance.threads();
        GraphBuilder {
            graph: EventGraph {
                provenance,
                events: IdVec::new(),
                accesses: IdVec::new(),
                values: IdVec::new(),
                objects: IdVec::new(),
                generations: IdVec::new(),
                async_ops: IdVec::new(),
                program_order: IdVec::from_vec((0..threads).map(|_| Vec::new()).collect()),
                terminal: Terminal::Aborted {
                    thread: None,
                    pc: None,
                    cause: AbortCause::Error,
                    reason: "graph under construction".to_string(),
                },
            },
            numbered: HashMap::new(),
            forming_barriers: HashMap::new(),
        }
    }

    /// Events recorded so far: the position the next event will take.
    pub fn position(&self) -> EventId {
        EventId(self.graph.events.len() as u32)
    }

    pub fn graph_so_far(&self) -> &EventGraph {
        &self.graph
    }

    fn push(&mut self, ctx: ExecContext, kind: EventKind, pc: Option<ProgramPoint>) -> EventId {
        let id = self.graph.events.push(Event { ctx, kind, pc });
        if let ExecContext::Thread(t) = ctx {
            self.graph.program_order[t].push(id);
        }
        id
    }

    pub fn value(&mut self, value: StoredValue) -> ValueId {
        self.graph.values.push(value)
    }

    /// A synchronous memory effect of `thread` (its own access, `access.attributed == thread`).
    pub fn thread_access(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        access: MemAccess,
    ) -> EventId {
        let id = self.graph.accesses.push(access);
        self.push(ExecContext::Thread(thread), EventKind::Access(id), Some(pc))
    }

    /// `thread`'s own ordinary access at `pc`.
    pub fn ordinary_thread_access(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        access: OrdinaryAccess,
    ) -> EventId {
        let access = self.mem_access(thread, access);
        self.thread_access(thread, pc, access)
    }

    /// One ordinary memory effect of `op`, attributed to `attributed`.
    pub fn ordinary_async_effect(
        &mut self,
        op: AsyncOpId,
        attributed: ThreadIx,
        access: OrdinaryAccess,
    ) -> EventId {
        let access = self.mem_access(attributed, access);
        self.async_effect(op, access)
    }

    /// The [`MemAccess`] of `access`, storing the value it writes.
    fn mem_access(&mut self, attributed: ThreadIx, access: OrdinaryAccess) -> MemAccess {
        let (mode, value) = match access.effect {
            Effect::Read => (AccessMode::Read, None),
            Effect::Write(stored) => (AccessMode::Write, Some(self.value(stored))),
        };
        MemAccess {
            space: access.space,
            mode,
            ordering: OrderingKind::Ordinary,
            proxy: access.proxy,
            footprint: access.footprint,
            role: access.role,
            attributed,
            value,
        }
    }

    /// `issuer` issues an asynchronous operation at `pc`.
    pub fn async_issue(
        &mut self,
        issuer: ThreadIx,
        pc: ProgramPoint,
        kind: AsyncOpKind,
    ) -> AsyncOpId {
        let op = AsyncOpId(self.graph.async_ops.len() as u32);
        let issue = self.push(
            ExecContext::Thread(issuer),
            EventKind::AsyncIssue(op),
            Some(pc),
        );
        self.graph.async_ops.push(AsyncOp {
            kind,
            issuer,
            pc,
            issue,
            effects: Vec::new(),
            completion: None,
            tracking: Vec::new(),
        })
    }

    /// One memory effect of `op`.
    pub fn async_effect(&mut self, op: AsyncOpId, access: MemAccess) -> EventId {
        let id = self.graph.accesses.push(access);
        let pc = self.graph.async_ops[op].pc;
        self.graph.async_ops[op].effects.push(id);
        self.push(ExecContext::Async(op), EventKind::Access(id), Some(pc))
    }

    /// `op` completes now, unless it already did; returns its `AsyncComplete` event.
    pub fn async_complete(&mut self, op: AsyncOpId) -> EventId {
        if let Some(done) = self.graph.async_ops[op].completion {
            return done;
        }
        let pc = self.graph.async_ops[op].pc;
        let done = self.push(
            ExecContext::Async(op),
            EventKind::AsyncComplete(op),
            Some(pc),
        );
        self.graph.async_ops[op].completion = Some(done);
        done
    }

    /// `generation` waits for `op`'s completion (completing `op` now if it has not yet).
    pub fn track(&mut self, op: AsyncOpId, generation: GenerationId, tx_bytes: u64) {
        let done = self.async_complete(op);
        self.graph.async_ops[op].tracking.push(generation);
        self.graph.generations[generation]
            .contributions
            .push(Contribution {
                event: done,
                kind: ContributionKind::AsyncCompletion { op, tx_bytes },
            });
    }

    /// `thread`'s wait at `pc` completed `ops`: the next generation of its wait object tracks
    /// them, completes and releases `thread`. A wait that completed nothing records nothing.
    pub fn group_wait(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        wait: GroupWait,
        ops: &[AsyncOpId],
    ) -> Option<GenerationId> {
        if ops.is_empty() {
            return None;
        }
        let (object, kind) = match wait {
            GroupWait::Async { keep_pending } => (
                SyncObjectKind::AsyncGroupWait { thread },
                GenerationKind::AsyncGroupWait { keep_pending },
            ),
            GroupWait::Bulk {
                keep_pending,
                scope,
            } => (
                SyncObjectKind::BulkGroupWait { thread },
                GenerationKind::BulkGroupWait {
                    keep_pending,
                    scope,
                },
            ),
        };
        let generation = self.next_generation(object, kind);
        for &op in ops {
            self.track(op, generation, 0);
        }
        self.complete_generation(generation, GenerationEvidence::default());
        self.resume(thread, pc, generation);
        Some(generation)
    }

    pub fn sync_object(&mut self, kind: SyncObjectKind) -> SyncObjectId {
        self.graph.objects.push(SyncObject {
            kind,
            init: None,
            inval: None,
        })
    }

    pub fn object_init(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        object: SyncObjectId,
    ) -> EventId {
        let id = self.push(
            ExecContext::Thread(thread),
            EventKind::ObjectInit(object),
            Some(pc),
        );
        self.graph.objects[object].init = Some(id);
        id
    }

    pub fn object_inval(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        object: SyncObjectId,
    ) -> EventId {
        let id = self.push(
            ExecContext::Thread(thread),
            EventKind::ObjectInval(object),
            Some(pc),
        );
        self.graph.objects[object].inval = Some(id);
        id
    }

    pub fn open_generation(
        &mut self,
        object: SyncObjectId,
        index: u32,
        kind: GenerationKind,
    ) -> GenerationId {
        self.graph.generations.push(Generation {
            object,
            index,
            kind,
            contributions: Vec::new(),
            releases: Vec::new(),
            completion: None,
            evidence: GenerationEvidence::default(),
        })
    }

    /// `thread` contributes to `generation` at `pc`.
    pub fn contribute(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        generation: GenerationId,
        kind: ContributionKind,
    ) -> EventId {
        let id = self.push(
            ExecContext::Thread(thread),
            EventKind::Contribute(generation),
            Some(pc),
        );
        self.graph.generations[generation]
            .contributions
            .push(Contribution { event: id, kind });
        id
    }

    /// An exited thread (its `Exit` event `exit`) counts as arrived at `generation`.
    pub fn contribute_exited(&mut self, generation: GenerationId, exit: EventId) {
        self.graph.generations[generation]
            .contributions
            .push(Contribution {
                event: exit,
                kind: ContributionKind::Exited,
            });
    }

    /// Every thread among `threads` that has exited counts as arrived at `generation`.
    pub fn contribute_exited_threads(
        &mut self,
        generation: GenerationId,
        threads: impl IntoIterator<Item = ThreadIx>,
    ) {
        for thread in threads {
            if let Some(exit) = self.exit_event(thread) {
                self.contribute_exited(generation, exit);
            }
        }
    }

    /// The next generation of the object of kind `object`, which its first generation creates.
    fn next_generation(&mut self, object: SyncObjectKind, kind: GenerationKind) -> GenerationId {
        let (id, index) = match self.numbered.get(&object) {
            Some(&numbered) => numbered,
            None => (self.sync_object(object.clone()), 0),
        };
        self.numbered.insert(object, (id, index + 1));
        self.open_generation(id, index, kind)
    }

    /// `thread`, an NKI instruction, releases everything before it at `pc` to the instructions
    /// ordered after it: its `Dependency` generation, complete once it contributes.
    pub fn signal(&mut self, thread: ThreadIx, pc: ProgramPoint) -> GenerationId {
        let object = self.sync_object(SyncObjectKind::Dependency { producer: thread });
        let generation = self.open_generation(object, 0, GenerationKind::Dependency);
        let release = ContributionKind::Arrival {
            count: 1,
            expect_tx: 0,
            ordering: ArrivalOrdering::Release,
        };
        self.contribute(thread, pc, generation, release);
        self.complete_generation(generation, GenerationEvidence::default());
        generation
    }

    /// `thread` arrives at named barrier `id` at `pc`, joining the generation its arrivals form.
    /// The arrival that opens a generation gives the `arrivals` it fires on.
    pub fn barrier_arrive(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        id: u8,
        arrivals: BarrierArrivals,
        wait: BarrierWait,
    ) -> EventId {
        let generation = match self.forming_barrier(id) {
            Some(generation) => generation,
            None => {
                let object = SyncObjectKind::NamedBarrier { id };
                let kind = GenerationKind::Barrier { arrivals };
                let generation = self.next_generation(object, kind);
                self.forming_barriers.insert(id, generation);
                generation
            }
        };
        let kind = match wait {
            BarrierWait::Blocking => ContributionKind::Blocking,
            BarrierWait::NonBlocking => ContributionKind::Arrival {
                count: 1,
                expect_tx: 0,
                ordering: ArrivalOrdering::Release,
            },
        };
        self.contribute(thread, pc, generation, kind)
    }

    /// The generation named barrier `id`'s arrivals form, if one arrived since it last fired.
    pub fn forming_barrier(&self, id: u8) -> Option<GenerationId> {
        self.forming_barriers.get(&id).copied()
    }

    /// Named barrier `id` fires: a full-CTA generation counts every exited thread as arrived
    /// (the Sync' rule), the generation completes, and its blocked threads resume in thread
    /// order. Panics unless a thread arrived at `id` since it last fired.
    pub fn barrier_fire(&mut self, id: u8) -> GenerationId {
        let generation = self.forming_barriers.remove(&id);
        let generation = generation.expect("a firing barrier was arrived at");

        let kind = self.graph.generations[generation].kind;
        if kind
            == (GenerationKind::Barrier {
                arrivals: BarrierArrivals::FullCta,
            })
        {
            let threads = (0..self.graph.program_order.len() as u32).map(ThreadIx);
            self.contribute_exited_threads(generation, threads);
        }

        let blocked = self.blocked_arrivals(generation);
        self.complete_generation(generation, GenerationEvidence::default());
        for (thread, pc) in blocked {
            self.resume(thread, pc, generation);
        }
        generation
    }

    /// Each thread blocking in `generation`, in thread order, with the pc it arrived at.
    fn blocked_arrivals(&self, generation: GenerationId) -> Vec<(ThreadIx, ProgramPoint)> {
        let mut blocked: Vec<_> = self.graph.generations[generation]
            .contributions
            .iter()
            .filter(|c| c.kind == ContributionKind::Blocking)
            .map(|c| {
                let event = &self.graph.events[c.event];
                let ExecContext::Thread(thread) = event.ctx else {
                    unreachable!("a blocking contribution is its thread's event");
                };
                (
                    thread,
                    event.pc.expect("a contribution has its arrival's pc"),
                )
            })
            .collect();
        blocked.sort_by_key(|&(thread, _)| thread);
        blocked
    }

    pub fn wait_start(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        object: SyncObjectId,
        parity: Parity,
    ) -> EventId {
        self.push(
            ExecContext::Thread(thread),
            EventKind::WaitStart { object, parity },
            Some(pc),
        )
    }

    pub fn complete_generation(
        &mut self,
        generation: GenerationId,
        evidence: GenerationEvidence,
    ) -> EventId {
        let id = self.push(
            ExecContext::Generation(generation),
            EventKind::GenerationComplete(generation),
            None,
        );
        let g = &mut self.graph.generations[generation];
        g.completion = Some(id);
        g.evidence = evidence;
        id
    }

    /// `thread`, waiting at `pc`, is released by the completed `generation`.
    pub fn resume(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        generation: GenerationId,
    ) -> EventId {
        let id = self.push(
            ExecContext::Thread(thread),
            EventKind::Resume(generation),
            Some(pc),
        );
        self.graph.generations[generation].releases.push(id);
        id
    }

    pub fn group_commit(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        family: GroupFamily,
    ) -> EventId {
        self.push(
            ExecContext::Thread(thread),
            EventKind::GroupCommit(family),
            Some(pc),
        )
    }

    pub fn fence(&mut self, thread: ThreadIx, pc: ProgramPoint, kind: FenceKind) -> EventId {
        self.push(
            ExecContext::Thread(thread),
            EventKind::Fence(kind),
            Some(pc),
        )
    }

    pub fn tmem_alloc(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        start_col: u16,
        num_cols: u16,
    ) -> EventId {
        self.push(
            ExecContext::Thread(thread),
            EventKind::TmemAlloc {
                start_col,
                num_cols,
            },
            Some(pc),
        )
    }

    pub fn tmem_dealloc(
        &mut self,
        thread: ThreadIx,
        pc: ProgramPoint,
        start_col: u16,
        num_cols: u16,
    ) -> EventId {
        self.push(
            ExecContext::Thread(thread),
            EventKind::TmemDealloc {
                start_col,
                num_cols,
            },
            Some(pc),
        )
    }

    pub fn tmem_relinquish(&mut self, thread: ThreadIx, pc: ProgramPoint) -> EventId {
        self.push(
            ExecContext::Thread(thread),
            EventKind::TmemRelinquish,
            Some(pc),
        )
    }

    pub fn exit(&mut self, thread: ThreadIx, pc: ProgramPoint) -> EventId {
        self.push(ExecContext::Thread(thread), EventKind::Exit, Some(pc))
    }

    /// The `Exit` event of `thread`, if it exited.
    pub fn exit_event(&self, thread: ThreadIx) -> Option<EventId> {
        let last = *self.graph.program_order[thread].last()?;
        (self.graph.events[last].kind == EventKind::Exit).then_some(last)
    }

    pub fn access(&self, id: AccessId) -> &MemAccess {
        &self.graph.accesses[id]
    }

    pub fn finish(mut self, terminal: Terminal) -> EventGraph {
        self.graph.terminal = terminal;
        self.graph
    }
}
