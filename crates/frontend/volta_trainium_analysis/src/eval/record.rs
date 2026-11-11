//! The event graph of an NKI kernel: one graph thread per instruction (`ThreadUnit::Instruction`),
//! its accesses those of `footprints`, and a `Dependency` edge wherever the ordering policy
//! says the Neuron compiler orders two instructions. `MemoryConflict` reports the rest.

use std::collections::BTreeMap;
use std::ops::Range;

use id_collections::IdVec;
use volta_graph::{
    Assumption, Effect, EventGraph, Footprint, GenerationId, GraphBuilder, InstructionInfo,
    OperandRole, OrdinaryAccess, ProgramPoint, Provenance, Proxy, Space, StoredValue, Terminal,
    ThreadIx, ThreadUnit,
};

use crate::ir::{InstrId, LoopKind, LoweredKernel, Memory, Origin};

use super::footprint::{Location, Mode, footprints};

/// Which pairs of instructions the Neuron compiler is taken to order. The docs say only that
/// it synchronizes "based on data dependencies", so each policy is an [`Assumption`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OrderingPolicy {
    /// An instruction follows the latest earlier writer of each location it reads, unless the
    /// two are in different iterations of one `affine_range`; nothing else is ordered.
    DataFlowOnly,
}

impl OrderingPolicy {
    fn assumption(self) -> Assumption {
        match self {
            OrderingPolicy::DataFlowOnly => Assumption::NkiDataFlowOrderOnly,
        }
    }
}

/// The spacing of locations' address ranges: above any placed byte (`128 << 32`).
const LOCATION_STRIDE: u64 = 1 << 40;

/// The event graph of `kernel`'s instructions under `policy`, in program order.
pub fn record_graph(kernel: &LoweredKernel, policy: OrderingPolicy) -> EventGraph {
    let accesses = footprints(kernel);
    let instructions = kernel.instructions.len() as u32;
    let mut graph = GraphBuilder::new(Provenance {
        kernel: kernel.name.clone(),
        block_dim: (instructions, 1, 1),
        unit: ThreadUnit::Instruction,
        grid_dim: (1, 1, 1),
        targets: vec!["nki".to_string()],
        assumptions: vec![policy.assumption()],
        instructions: kernel
            .instructions
            .values()
            .map(|instruction| InstructionInfo {
                kind: instruction.kind(),
                span: None,
            })
            .collect(),
    });

    let mut locations = Locations::default();
    let mut writers: Vec<Writers> = Vec::new();
    let mut signals: IdVec<InstrId, GenerationId> = IdVec::new();
    for (instr, own) in accesses.iter() {
        let thread = ThreadIx(instr.0);
        let pc = ProgramPoint(instr.0);

        let mut producers: Vec<InstrId> = Vec::new();
        for access in own.iter().filter(|access| access.mode != Mode::Write) {
            let location = locations.index(access.location);
            if let Some(writers) = writers.get(location) {
                for run in &access.runs {
                    producers.extend(writers.overlapping(run));
                }
            }
        }
        producers.sort();
        producers.dedup();
        producers
            .retain(|&producer| ordered(policy, &kernel.origins[producer], &kernel.origins[instr]));
        for producer in producers {
            graph.resume(thread, pc, signals[producer]);
        }

        for access in own {
            let (space, base) = locations.place(kernel, access.location);
            for &effect in effects(access.mode) {
                for run in &access.runs {
                    let width = u32::try_from(run.end - run.start).expect("a run fits in u32");
                    let footprint = Footprint::Bytes {
                        addr: base + run.start,
                        width,
                    };
                    let access = OrdinaryAccess {
                        space,
                        footprint,
                        proxy: Proxy::Generic,
                        role: OperandRole::Plain,
                        effect,
                    };
                    graph.ordinary_thread_access(thread, pc, access);
                }
            }
        }

        for access in own.iter().filter(|access| access.mode != Mode::Read) {
            let location = locations.index(access.location);
            if writers.len() <= location {
                writers.resize_with(location + 1, Writers::default);
            }
            for run in &access.runs {
                writers[location].paint(run.clone(), instr);
            }
        }

        let signal = signals.push(graph.signal(thread, pc));
        debug_assert_eq!(signal, instr);
        graph.exit(thread, pc);
    }
    graph.finish(Terminal::Completed)
}

/// What an access of `mode` does to each of its locations: an accumulation reads, then writes.
fn effects(mode: Mode) -> &'static [Effect] {
    const WRITE: Effect = Effect::Write(StoredValue::Opaque);
    match mode {
        Mode::Read => &[Effect::Read],
        Mode::Write => &[WRITE],
        Mode::Accumulate => &[Effect::Read, WRITE],
    }
}

/// Whether `policy` orders an instruction at `later` after a dependency at `earlier`.
fn ordered(policy: OrderingPolicy, earlier: &Origin, later: &Origin) -> bool {
    match policy {
        OrderingPolicy::DataFlowOnly => !in_different_affine_iterations(earlier, later),
    }
}

/// Whether the outermost loop iteration the two origins differ in is an `affine_range`'s.
fn in_different_affine_iterations(a: &Origin, b: &Origin) -> bool {
    for (a, b) in a.loops.iter().zip(&b.loops) {
        if a.loop_id != b.loop_id {
            return false;
        }
        if a.index != b.index {
            return a.kind == LoopKind::Affine;
        }
    }
    false
}

/// Each location's address range in the graph, numbered in order of first use.
#[derive(Default)]
struct Locations(Vec<Location>);

impl Locations {
    fn index(&mut self, location: Location) -> usize {
        match self.0.iter().position(|&known| known == location) {
            Some(index) => index,
            None => {
                self.0.push(location);
                self.0.len() - 1
            }
        }
    }

    /// The space `location` is in and the address its offset 0 takes there.
    fn place(&mut self, kernel: &LoweredKernel, location: Location) -> (Space, u64) {
        let memory = match location {
            Location::Placed(memory) => memory,
            Location::Elements(tensor) => kernel.tensors[tensor].memory,
        };
        let space = match memory {
            Memory::Hbm => Space::Global,
            Memory::Sbuf | Memory::Psum => Space::Shared,
        };
        let index = self.index(location) as u64;
        (space, index * LOCATION_STRIDE)
    }
}

/// The latest instruction to write each offset of one location, as disjoint runs by start.
#[derive(Default)]
struct Writers(BTreeMap<u64, (u64, InstrId)>);

impl Writers {
    /// The writers of the offsets in `run`.
    fn overlapping(&self, run: &Range<u64>) -> impl Iterator<Item = InstrId> + '_ {
        let before = self
            .0
            .range(..run.start)
            .next_back()
            .filter(|(_, (end, _))| *end > run.start);
        before
            .into_iter()
            .chain(self.0.range(run.start..run.end))
            .map(|(_, &(_, writer))| writer)
    }

    /// `writer` writes every offset in `run`.
    fn paint(&mut self, run: Range<u64>, writer: InstrId) {
        let covered: Vec<(u64, (u64, InstrId))> = self
            .0
            .range(..run.end)
            .rev()
            .take_while(|(_, (end, _))| *end > run.start)
            .map(|(&start, &value)| (start, value))
            .collect();
        for (start, (end, previous)) in covered {
            self.0.remove(&start);
            if start < run.start {
                self.0.insert(start, (run.start, previous));
            }
            if end > run.end {
                self.0.insert(run.end, (end, previous));
            }
        }
        self.0.insert(run.start, (run.end, writer));
    }
}
