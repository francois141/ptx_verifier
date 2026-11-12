//! The event graph of an NKI kernel: one graph thread per instruction (`ThreadUnit::Instruction`),
//! its accesses those of `footprints`, and a `Dependency` edge wherever the ordering policy
//! says the Neuron compiler orders two instructions. `MemoryConflict` reports the rest.

use std::collections::{BTreeMap, HashMap};
use std::ops::Range;

use id_collections::IdVec;
use volta_graph::{
    Assumption, Effect, EventGraph, Footprint, GenerationId, GraphBuilder, InstructionInfo,
    OperandRole, OrdinaryAccess, ProgramPoint, Provenance, Proxy, Space, StoredValue, Terminal,
    ThreadIx, ThreadUnit,
};

use crate::ir::{
    InstrId, LoopKind, LoweredKernel, Memory, NoReorderId, Origin, Reordering, TensorId,
};

use super::footprint::{Access, Location, Mode, footprints};

/// Which pairs of instructions the Neuron compiler is taken to order. The docs say only that
/// it synchronizes "based on data dependencies", so each policy records its [`Assumption`]s.
/// Read after write and write after read are always ordered, except across iterations of
/// one `affine_range`, which declares them independent.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct OrderingPolicy {
    pub write_after_write: WriteAfterWrite,
    pub placed_tiles: PlacedTiles,
    pub no_reorder: NoReorder,
}

/// Whether a write follows the latest earlier writer of what it writes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WriteAfterWrite {
    Unordered,
    Ordered,
}

/// What the compiler's hazard tracking sees of `address=` tiles placed over the same bytes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PlacedTiles {
    /// Only accesses through the same tensor are ordered.
    ByTensor,
    /// Accesses through any tensors over the same bytes are ordered.
    ByAddress,
}

/// Whether a `no_reorder` block's instructions follow one another: the API page's "execute in
/// program order", which the scheduling guide leaves open to be a scheduling hint only.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NoReorder {
    Unordered,
    ProgramOrder,
}

impl OrderingPolicy {
    /// The pipeline's policy: read after write and write after read within a tensor.
    pub const BASELINE: OrderingPolicy = OrderingPolicy {
        write_after_write: WriteAfterWrite::Unordered,
        placed_tiles: PlacedTiles::ByTensor,
        no_reorder: NoReorder::Unordered,
    };

    /// Every combination of the three choices, `BASELINE` first.
    pub const ALL: [OrderingPolicy; 8] = {
        let mut all = [OrderingPolicy::BASELINE; 8];
        let mut i = 0;
        while i < 8 {
            all[i] = OrderingPolicy {
                write_after_write: if i & 1 == 0 {
                    WriteAfterWrite::Unordered
                } else {
                    WriteAfterWrite::Ordered
                },
                placed_tiles: if i & 2 == 0 {
                    PlacedTiles::ByTensor
                } else {
                    PlacedTiles::ByAddress
                },
                no_reorder: if i & 4 == 0 {
                    NoReorder::Unordered
                } else {
                    NoReorder::ProgramOrder
                },
            };
            i += 1;
        }
        all
    };

    pub fn assumptions(self) -> Vec<Assumption> {
        let mut assumptions = vec![
            Assumption::NkiReadAfterWriteOrder,
            Assumption::NkiWriteAfterReadOrder,
        ];
        if self.write_after_write == WriteAfterWrite::Ordered {
            assumptions.push(Assumption::NkiWriteAfterWriteOrder);
        }
        if self.placed_tiles == PlacedTiles::ByAddress {
            assumptions.push(Assumption::NkiHazardsByPlacedAddress);
        }
        if self.no_reorder == NoReorder::ProgramOrder {
            assumptions.push(Assumption::NkiNoReorderInProgramOrder);
        }
        assumptions
    }

    /// The `no_reorder` block whose program order the policy keeps for an instruction at `origin`.
    fn ordering_block(self, origin: &Origin) -> Option<NoReorderId> {
        match (self.no_reorder, origin.reordering) {
            (NoReorder::ProgramOrder, Reordering::Forbidden { block }) => Some(block),
            (NoReorder::Unordered, _) | (_, Reordering::Allowed) => None,
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
        assumptions: policy.assumptions(),
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
    let mut hazards = Hazards::default();
    let mut signals: IdVec<InstrId, GenerationId> = IdVec::new();
    let mut block_tails: HashMap<NoReorderId, InstrId> = HashMap::new();
    for (instr, own) in accesses.iter() {
        let thread = ThreadIx(instr.0);
        let pc = ProgramPoint(instr.0);

        let mut producers: Vec<InstrId> = Vec::new();
        for access in own {
            let history = hazards.of(policy, access);
            for run in &access.runs {
                if access.mode != Mode::Write {
                    producers.extend(history.writers.overlapping(run));
                }
                if access.mode != Mode::Read {
                    producers.extend(history.readers.overlapping(run));
                    if policy.write_after_write == WriteAfterWrite::Ordered {
                        producers.extend(history.writers.overlapping(run));
                    }
                }
            }
        }
        let origin = &kernel.origins[instr];
        producers
            .retain(|&producer| !in_different_affine_iterations(&kernel.origins[producer], origin));
        if let Some(block) = policy.ordering_block(origin) {
            producers.extend(block_tails.insert(block, instr));
        }
        producers.sort();
        producers.dedup();
        for &producer in &producers {
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

        for access in own {
            let history = hazards.of(policy, access);
            for run in &access.runs {
                if access.mode != Mode::Read {
                    if policy.write_after_write == WriteAfterWrite::Ordered {
                        history
                            .readers
                            .forget(run, |reader| producers.binary_search(&reader).is_ok());
                    }
                    history.writers.paint(run.clone(), instr);
                }
                if access.mode != Mode::Write {
                    history.readers.add(run, instr);
                }
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

/// What the compiler tracks hazards on: a location, and under `PlacedTiles::ByTensor` the
/// tensor a placed tile's access goes through.
type HazardKey = (Location, Option<TensorId>);

/// Each hazard key's writers and readers so far.
#[derive(Default)]
struct Hazards {
    keys: Vec<HazardKey>,
    histories: Vec<History>,
}

#[derive(Default)]
struct History {
    writers: Writers,
    readers: Readers,
}

impl Hazards {
    fn of(&mut self, policy: OrderingPolicy, access: &Access) -> &mut History {
        let tensor = match (access.location, policy.placed_tiles) {
            (Location::Placed(_), PlacedTiles::ByTensor) => Some(access.tensor),
            (Location::Placed(_), PlacedTiles::ByAddress) | (Location::Elements(_), _) => None,
        };
        let key = (access.location, tensor);
        let index = match self.keys.iter().position(|&known| known == key) {
            Some(index) => index,
            None => {
                self.keys.push(key);
                self.histories.push(History::default());
                self.keys.len() - 1
            }
        };
        &mut self.histories[index]
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

/// The instructions to read each offset of one location that a later write must follow, as
/// disjoint segments by start.
#[derive(Default)]
struct Readers(BTreeMap<u64, (u64, Vec<InstrId>)>);

impl Readers {
    /// The readers of the offsets in `run`.
    fn overlapping(&self, run: &Range<u64>) -> impl Iterator<Item = InstrId> + '_ {
        let before = self
            .0
            .range(..run.start)
            .next_back()
            .filter(|(_, (end, _))| *end > run.start);
        before
            .into_iter()
            .chain(self.0.range(run.start..run.end))
            .flat_map(|(_, (_, readers))| readers.iter().copied())
    }

    /// `reader` reads every offset in `run`.
    fn add(&mut self, run: &Range<u64>, reader: InstrId) {
        self.split(run.start);
        self.split(run.end);
        let mut gaps = Vec::new();
        let mut cursor = run.start;
        for (&start, (end, readers)) in self.0.range_mut(run.start..run.end) {
            if start > cursor {
                gaps.push(cursor..start);
            }
            if readers.last() != Some(&reader) {
                readers.push(reader);
            }
            cursor = *end;
        }
        if cursor < run.end {
            gaps.push(cursor..run.end);
        }
        for gap in gaps {
            self.0.insert(gap.start, (gap.end, vec![reader]));
        }
    }

    /// Drops the readers of `run` that `ordered` says a write of it follows.
    fn forget(&mut self, run: &Range<u64>, ordered: impl Fn(InstrId) -> bool) {
        self.split(run.start);
        self.split(run.end);
        let mut emptied = Vec::new();
        for (&start, (_, readers)) in self.0.range_mut(run.start..run.end) {
            readers.retain(|&reader| !ordered(reader));
            if readers.is_empty() {
                emptied.push(start);
            }
        }
        for start in emptied {
            self.0.remove(&start);
        }
    }

    /// Makes a segment start at `at` if one covers it.
    fn split(&mut self, at: u64) {
        let covering = self
            .0
            .range(..at)
            .next_back()
            .filter(|(_, (end, _))| *end > at)
            .map(|(&start, (end, readers))| (start, *end, readers.clone()));
        if let Some((start, end, readers)) = covering {
            self.0.insert(start, (at, readers.clone()));
            self.0.insert(at, (end, readers));
        }
    }
}
