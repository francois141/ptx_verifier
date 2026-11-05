//! Records one run into an event graph, with one graph thread per wave. Each global, buffer and
//! LDS instruction is an async operation with one effect per lane and access, completed by the
//! wave's `vmcnt` or `lgkmcnt` waits. Scalar loads read only kernel arguments, so they are left out.

use id_collections::IdVec;
use volta_expr::ExprId;
use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, BarrierArrivals, BulkWaitScope, ContributionKind,
    EventGraph, Footprint, GenerationEvidence, GenerationId, GenerationKind, GraphBuilder,
    InstructionInfo, MemAccess, OperandRole, OrderingKind, ProgramPoint, Provenance, Proxy, Space,
    StoredValue, SyncObjectId, SyncObjectKind, Terminal, ThreadIx, ValueId,
};

use crate::ir::{InstrId, LoweredInstr, LoweredKernel};

use super::wave::{LoadCounter, WaveId};

/// One wave's waits on one counter, and the operations those waits have not completed yet.
struct CounterWaits {
    object: SyncObjectId,
    next_wait: u32,
    outstanding: Vec<AsyncOpId>,
}

impl CounterWaits {
    fn new(object: SyncObjectId) -> Self {
        Self {
            object,
            next_wait: 0,
            outstanding: Vec::new(),
        }
    }
}

struct WaveRecord {
    vm: CounterWaits,
    lgkm: CounterWaits,
}

impl WaveRecord {
    fn waits(&mut self, counter: LoadCounter) -> &mut CounterWaits {
        match counter {
            LoadCounter::Vm => &mut self.vm,
            LoadCounter::Lgkm => &mut self.lgkm,
        }
    }
}

pub(super) struct EventRecorder {
    graph: GraphBuilder,
    waves: IdVec<WaveId, WaveRecord>,
    /// The operation of the memory instruction being executed, which its lanes add effects to.
    current_op: Option<AsyncOpId>,
    barrier: SyncObjectId,
    next_barrier: u32,
    open_barrier: Option<GenerationId>,
    arrived: Vec<(ThreadIx, ProgramPoint)>,
}

impl EventRecorder {
    pub(super) fn new(kernel: &LoweredKernel, wave_count: usize) -> Self {
        let mut graph = GraphBuilder::new(provenance(kernel, wave_count as u32));
        let waves: Vec<WaveRecord> = (0..wave_count as u32)
            .map(|wave| {
                let thread = ThreadIx(wave);
                let lgkm = graph.sync_object(SyncObjectKind::AsyncGroupWait { thread });
                let vm = graph.sync_object(SyncObjectKind::BulkGroupWait { thread });
                WaveRecord {
                    vm: CounterWaits::new(vm),
                    lgkm: CounterWaits::new(lgkm),
                }
            })
            .collect();
        let barrier = graph.sync_object(SyncObjectKind::NamedBarrier { id: 0 });
        Self {
            graph,
            waves: IdVec::from_vec(waves),
            current_op: None,
            barrier,
            next_barrier: 0,
            open_barrier: None,
            arrived: Vec::new(),
        }
    }

    /// Start the operation of `wave`'s memory instruction at `pc`, which `counter` tracks.
    pub(super) fn memory_issue(&mut self, wave: WaveId, pc: InstrId, counter: LoadCounter) {
        let op = self
            .graph
            .async_issue(thread(wave), point(pc), AsyncOpKind::CpAsync);
        self.current_op = Some(op);
        self.waves[wave].waits(counter).outstanding.push(op);
    }

    /// One lane's read of `width` bytes at `address`.
    pub(super) fn memory_read(&mut self, wave: WaveId, space: Space, address: u64, width: u32) {
        self.memory_effect(wave, space, AccessMode::Read, address, width, None);
    }

    /// One lane's write of the 32-bit `values` starting at `address`.
    pub(super) fn memory_write(
        &mut self,
        wave: WaveId,
        space: Space,
        address: u64,
        values: &[ExprId],
    ) {
        let stored = match *values {
            [value] => StoredValue::Scalar(value),
            [low, high] => StoredValue::Pair(low, high),
            [a, b, c, d] => StoredValue::Quad([a, b, c, d]),
            _ => StoredValue::Opaque,
        };
        let value = Some(self.graph.value(stored));
        let width = 4 * values.len() as u32;
        self.memory_effect(wave, space, AccessMode::Write, address, width, value);
    }

    fn memory_effect(
        &mut self,
        wave: WaveId,
        space: Space,
        mode: AccessMode,
        addr: u64,
        width: u32,
        value: Option<ValueId>,
    ) {
        let Some(op) = self.current_op else {
            return;
        };
        self.graph.async_effect(
            op,
            MemAccess {
                space,
                mode,
                ordering: OrderingKind::Ordinary,
                proxy: Proxy::Generic,
                footprint: Footprint::Bytes { addr, width },
                role: OperandRole::Plain,
                attributed: thread(wave),
                value,
            },
        );
    }

    /// A wait until `counter` is at most `n` completes all but the wave's newest `n` operations,
    /// as `finish_vector_loads` assumes for the loads it tracks.
    pub(super) fn wait(&mut self, wave: WaveId, pc: InstrId, counter: LoadCounter, n: usize) {
        let waits = self.waves[wave].waits(counter);
        let finished = waits.outstanding.len().saturating_sub(n);
        if finished == 0 {
            return;
        }
        let keep_pending = n as u32;
        let kind = match counter {
            LoadCounter::Vm => GenerationKind::BulkGroupWait {
                keep_pending,
                scope: BulkWaitScope::Complete,
            },
            LoadCounter::Lgkm => GenerationKind::AsyncGroupWait { keep_pending },
        };
        let generation = self
            .graph
            .open_generation(waits.object, waits.next_wait, kind);
        waits.next_wait += 1;
        for op in waits.outstanding.drain(..finished) {
            self.graph.track(op, generation, 0);
        }
        self.graph
            .complete_generation(generation, GenerationEvidence::default());
        self.graph.resume(thread(wave), point(pc), generation);
    }

    pub(super) fn barrier_arrival(&mut self, wave: WaveId, pc: InstrId) {
        let generation = match self.open_barrier {
            Some(generation) => generation,
            None => {
                let kind = GenerationKind::Barrier {
                    arrivals: BarrierArrivals::FullCta,
                };
                let generation = self
                    .graph
                    .open_generation(self.barrier, self.next_barrier, kind);
                self.next_barrier += 1;
                self.open_barrier = Some(generation);
                generation
            }
        };
        self.graph.contribute(
            thread(wave),
            point(pc),
            generation,
            ContributionKind::Blocking,
        );
        self.arrived.push((thread(wave), point(pc)));
    }

    /// Every wave that has not exited has arrived, so the barrier releases them.
    pub(super) fn barrier_release(&mut self) {
        if let Some(generation) = self.open_barrier.take() {
            self.graph
                .complete_generation(generation, GenerationEvidence::default());
            for (thread, pc) in self.arrived.drain(..) {
                self.graph.resume(thread, pc, generation);
            }
        }
    }

    pub(super) fn exit(&mut self, wave: WaveId, pc: InstrId) {
        self.graph.exit(thread(wave), point(pc));
    }

    pub(super) fn finish(self, terminal: Terminal) -> EventGraph {
        self.graph.finish(terminal)
    }
}

/// The counter whose waits complete `instruction`, if it accesses global memory or LDS.
pub(super) fn memory_counter(instruction: &LoweredInstr) -> Option<LoadCounter> {
    match instruction {
        LoweredInstr::GlobalLoad { .. }
        | LoweredInstr::GlobalStore { .. }
        | LoweredInstr::BufferLoad { .. }
        | LoweredInstr::BufferStore { .. } => Some(LoadCounter::Vm),
        LoweredInstr::DsRead { .. } | LoweredInstr::DsWrite { .. } => Some(LoadCounter::Lgkm),
        _ => None,
    }
}

fn thread(wave: WaveId) -> ThreadIx {
    ThreadIx(wave.0)
}

fn point(pc: InstrId) -> ProgramPoint {
    ProgramPoint(pc.0)
}

/// The kernel and launch the graph records, with one graph thread per wave.
fn provenance(kernel: &LoweredKernel, wave_count: u32) -> Provenance {
    Provenance {
        kernel: kernel.name.clone(),
        block_dim: (wave_count, 1, 1),
        // Workgroup 0 runs alone, and no supported instruction reads the grid size.
        grid_dim: (1, 1, 1),
        targets: vec![kernel.target.clone()],
        assumptions: Vec::new(),
        instructions: kernel
            .instructions
            .values()
            .map(|instruction| InstructionInfo {
                kind: instruction_kind(instruction),
                span: None,
            })
            .collect(),
    }
}

/// The instruction names the viewer shows; only the recorded instructions need one.
fn instruction_kind(instruction: &LoweredInstr) -> &'static str {
    match instruction {
        LoweredInstr::GlobalLoad { .. } => "global_load",
        LoweredInstr::GlobalStore { .. } => "global_store",
        LoweredInstr::BufferLoad { .. } => "buffer_load",
        LoweredInstr::BufferStore { .. } => "buffer_store",
        LoweredInstr::DsRead { .. } => "ds_read",
        LoweredInstr::DsWrite { .. } => "ds_write",
        LoweredInstr::WaitCnt { .. } => "s_waitcnt",
        LoweredInstr::Barrier => "s_barrier",
        LoweredInstr::EndPgm => "s_endpgm",
        _ => "other",
    }
}
