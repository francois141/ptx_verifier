use id_collections::IdVec;

use crate::ids::{AccessId, AsyncOpId, EventId, GenerationId, SyncObjectId, ThreadIx, ValueId};
use crate::model::{
    AsyncOp, Event, ExecContext, Generation, MemAccess, Provenance, StoredValue, SyncObject,
    Terminal,
};

/// A finished candidate-execution graph. Immutable: built only by [`crate::GraphBuilder`].
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct EventGraph {
    pub(crate) provenance: Provenance,
    pub(crate) events: IdVec<EventId, Event>,
    pub(crate) accesses: IdVec<AccessId, MemAccess>,
    pub(crate) values: IdVec<ValueId, StoredValue>,
    pub(crate) objects: IdVec<SyncObjectId, SyncObject>,
    pub(crate) generations: IdVec<GenerationId, Generation>,
    pub(crate) async_ops: IdVec<AsyncOpId, AsyncOp>,
    /// Each thread's events in program order (an index over `events`).
    pub(crate) program_order: IdVec<ThreadIx, Vec<EventId>>,
    pub(crate) terminal: Terminal,
}

impl EventGraph {
    pub fn provenance(&self) -> &Provenance {
        &self.provenance
    }

    pub fn terminal(&self) -> &Terminal {
        &self.terminal
    }

    pub fn threads(&self) -> u32 {
        self.program_order.len() as u32
    }

    pub fn events(&self) -> &IdVec<EventId, Event> {
        &self.events
    }

    pub fn event(&self, id: EventId) -> &Event {
        &self.events[id]
    }

    pub fn accesses(&self) -> &IdVec<AccessId, MemAccess> {
        &self.accesses
    }

    pub fn access(&self, id: AccessId) -> &MemAccess {
        &self.accesses[id]
    }

    pub fn value(&self, id: ValueId) -> StoredValue {
        self.values[id]
    }

    pub fn objects(&self) -> &IdVec<SyncObjectId, SyncObject> {
        &self.objects
    }

    pub fn object(&self, id: SyncObjectId) -> &SyncObject {
        &self.objects[id]
    }

    pub fn generations(&self) -> &IdVec<GenerationId, Generation> {
        &self.generations
    }

    pub fn generation(&self, id: GenerationId) -> &Generation {
        &self.generations[id]
    }

    pub fn async_ops(&self) -> &IdVec<AsyncOpId, AsyncOp> {
        &self.async_ops
    }

    pub fn async_op(&self, id: AsyncOpId) -> &AsyncOp {
        &self.async_ops[id]
    }

    /// `thread`'s events in program order.
    pub fn program_order(&self, thread: ThreadIx) -> &[EventId] {
        &self.program_order[thread]
    }

    /// The thread whose program order `event` belongs to, if any.
    pub fn thread_of(&self, event: EventId) -> Option<ThreadIx> {
        match self.events[event].ctx {
            ExecContext::Thread(t) => Some(t),
            ExecContext::Async(_) | ExecContext::Generation(_) => None,
        }
    }

    /// The thread an event acts for: its own thread, an async effect's attributed lane, or
    /// an async completion's issuer. `None` for generation completions.
    pub fn acting_thread(&self, event: EventId) -> Option<ThreadIx> {
        let ev = &self.events[event];
        match ev.ctx {
            ExecContext::Thread(t) => Some(t),
            ExecContext::Async(op) => match ev.kind {
                crate::model::EventKind::Access(a) => Some(self.accesses[a].attributed),
                _ => Some(self.async_ops[op].issuer),
            },
            ExecContext::Generation(_) => None,
        }
    }
}
