//! The event graph of an NKI kernel: one graph thread per instruction (`ThreadUnit::Instruction`),
//! its accesses those of `footprints`, and a `Dependency` edge wherever the ordering policy
//! says the Neuron compiler orders two instructions. `MemoryConflict` reports the rest.

use std::collections::{BTreeMap, HashMap};
use std::ops::Range;

use id_collections::IdVec;
use volta_graph::{
    AbortCause, Assumption, Effect, EventGraph, Footprint, GenerationId, GraphBuilder,
    InstructionInfo, OperandRole, OrdinaryAccess, ProgramPoint, Provenance, Proxy, ReductionOp,
    Space, StoredValue, Terminal, ThreadIx, ThreadUnit,
};

use crate::ir::{
    ArithOp, InstrId, LoopKind, LoweredKernel, Memory, NoReorderId, Origin, Reordering, TensorId,
};

use super::EvalError;
use super::footprint::{Access, Location, Mode, Reducer, footprints};

/// Which pairs of instructions the Neuron compiler is taken to order. The docs say only that
/// it synchronizes "based on data dependencies", so each policy records its [`Assumption`]s.
/// Read after write and write after read are always ordered, except across iterations of
/// one `affine_range`, which declares them independent; there, the reductions the policy
/// names are instead performed one at a time in some order.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct OrderingPolicy {
    pub write_after_write: WriteAfterWrite,
    pub placed_tiles: PlacedTiles,
    pub no_reorder: NoReorder,
    pub reductions: Reductions,
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
    /// Accesses through any tensors over the same bytes are ordered, as they must be for
    /// the compiler's own reuse of on-chip memory across tensors.
    ByAddress,
}

/// Whether a `no_reorder` block's instructions follow one another: the API page's "execute in
/// program order", which the scheduling guide leaves open to be a scheduling hint only.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum NoReorder {
    Unordered,
    ProgramOrder,
}

/// Which accumulations commute: the `affine_range` docs exempt "associative reductions" from
/// its independence, naming `nc_matmul` accumulating into one buffer as the example.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Reductions {
    /// `nc_matmul` accumulations only, the docs' example.
    Matmul,
    /// Also `tensor_tensor` add accumulations, as AWS's mamba tutorial relies on; other ops'
    /// accumulations stay ordinary reads and writes, with no sample relying on them.
    MatmulAndAdd,
}

impl OrderingPolicy {
    /// The pipeline's policy: read after write and write after read, by address, and
    /// `nc_matmul` and `tensor_tensor` add accumulations commuting; the assumptions AWS's
    /// own samples need, and no others.
    pub const BASELINE: OrderingPolicy = OrderingPolicy {
        write_after_write: WriteAfterWrite::Unordered,
        placed_tiles: PlacedTiles::ByAddress,
        no_reorder: NoReorder::Unordered,
        reductions: Reductions::MatmulAndAdd,
    };

    /// Every combination of the four choices, `BASELINE` first.
    pub const ALL: [OrderingPolicy; 16] = {
        let mut all = [OrderingPolicy::BASELINE; 16];
        let mut i = 0;
        while i < 16 {
            all[i] = OrderingPolicy {
                write_after_write: if i & 1 == 0 {
                    WriteAfterWrite::Unordered
                } else {
                    WriteAfterWrite::Ordered
                },
                placed_tiles: if i & 2 == 0 {
                    PlacedTiles::ByAddress
                } else {
                    PlacedTiles::ByTensor
                },
                no_reorder: if i & 4 == 0 {
                    NoReorder::Unordered
                } else {
                    NoReorder::ProgramOrder
                },
                reductions: if i & 8 == 0 {
                    Reductions::MatmulAndAdd
                } else {
                    Reductions::Matmul
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
            Assumption::NkiMatmulAccumulationsCommute,
        ];
        if self.reductions == Reductions::MatmulAndAdd {
            assumptions.push(Assumption::NkiTensorTensorAddsCommute);
        }
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

    /// What an access of `mode` is to hazard tracking under the policy.
    fn touch(self, mode: Mode) -> Touch {
        match (mode, self.reductions) {
            (Mode::Read, _) => Touch::Read,
            (Mode::Write, _) => Touch::Write,
            (Mode::Accumulate(Reducer::Matmul), _) => Touch::Reduce(ReductionOp::Add),
            (Mode::Accumulate(Reducer::Elementwise(ArithOp::Add)), Reductions::MatmulAndAdd) => {
                Touch::Reduce(ReductionOp::Add)
            }
            (Mode::Accumulate(Reducer::Elementwise(_)), _) => Touch::ReadWrite,
        }
    }

    /// The `no_reorder` block whose program order the policy keeps for an instruction at `origin`.
    fn ordering_block(self, origin: &Origin) -> Option<NoReorderId> {
        match (self.no_reorder, origin.reordering) {
            (NoReorder::ProgramOrder, Reordering::Forbidden { block }) => Some(block),
            (NoReorder::Unordered, _) | (_, Reordering::Allowed) => None,
        }
    }
}

/// How the kernel's program-order run (`evaluate`) ended. The graph's trace ends the same
/// way: an aborted run's stops at the instruction that failed, as PTX's and AMD's do.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Execution {
    Completed,
    Aborted(EvalError),
}

impl Execution {
    pub fn of<T>(run: &Result<T, EvalError>) -> Execution {
        match run {
            Ok(_) => Execution::Completed,
            Err(error) => Execution::Aborted(error.clone()),
        }
    }
}

/// What every NKI graph assumes of the kernel and its compilation, whatever the policy: the
/// limits of what its race check covers.
const MODELLING: [Assumption; 4] = [
    Assumption::SingleNkiInstance,
    Assumption::NkiArgumentsDistinct,
    Assumption::NkiInstructionReadsBeforeWrites,
    Assumption::NkiCompilerAllocation,
];

/// The spacing of locations' address ranges: above any placed byte (`128 << 32`).
const LOCATION_STRIDE: u64 = 1 << 40;

/// The event graph of `kernel`'s instructions under `policy`, in program order, ending as
/// `execution` did.
pub fn record_graph(
    kernel: &LoweredKernel,
    policy: OrderingPolicy,
    execution: &Execution,
) -> EventGraph {
    let accesses = footprints(kernel);
    let instructions = kernel.instructions.len() as u32;
    let mut graph = GraphBuilder::new(Provenance {
        kernel: kernel.name.clone(),
        block_dim: (instructions, 1, 1),
        unit: ThreadUnit::Instruction,
        grid_dim: (1, 1, 1),
        targets: vec!["nki".to_string()],
        assumptions: [MODELLING.as_slice(), &policy.assumptions()].concat(),
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
            let touch = policy.touch(access.mode);
            let history = hazards.of(policy, access);
            for run in &access.runs {
                if touch.reads() {
                    producers.extend(history.writers.overlapping(run).flat_map(Written::all));
                }
                if touch.writes() {
                    producers.extend(history.readers.overlapping(run).flatten());
                    if policy.write_after_write == WriteAfterWrite::Ordered {
                        producers.extend(history.writers.overlapping(run).flat_map(Written::all));
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
            for &effect in policy.touch(access.mode).effects() {
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
        if let Execution::Aborted(error) = execution
            && error.instr() == instr
        {
            return graph.finish(Terminal::Aborted {
                thread: Some(thread),
                pc: Some(pc),
                cause: AbortCause::Error,
                reason: error.to_string(),
            });
        }

        for access in own {
            let touch = policy.touch(access.mode);
            let history = hazards.of(policy, access);
            for run in &access.runs {
                match touch {
                    Touch::Read => {}
                    Touch::Write | Touch::ReadWrite => {
                        history.readers.update(run, |readers| {
                            readers.retain(|reader| producers.binary_search(reader).is_err())
                        });
                        history.writers.update(run, |written| {
                            *written = Written {
                                last: Some(instr),
                                reductions: Vec::new(),
                            }
                        });
                    }
                    Touch::Reduce(_) => {
                        history
                            .writers
                            .update(run, |written| written.reductions.push(instr));
                    }
                }
                if touch.reads() {
                    history.readers.update(run, |readers| {
                        if readers.last() != Some(&instr) {
                            readers.push(instr)
                        }
                    });
                }
            }
        }

        let signal = signals.push(graph.signal(thread, pc));
        debug_assert_eq!(signal, instr);
        graph.exit(thread, pc);
    }
    graph.finish(Terminal::Completed)
}

/// What an access is to hazard tracking: a reduction commutes with reductions of its op,
/// any other accumulation is a read, then a write.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Touch {
    Read,
    Write,
    ReadWrite,
    Reduce(ReductionOp),
}

impl Touch {
    fn reads(self) -> bool {
        self != Touch::Write
    }

    fn writes(self) -> bool {
        self != Touch::Read
    }

    /// Its graph effects at each of its locations.
    fn effects(self) -> &'static [Effect] {
        const WRITE: Effect = Effect::Write(StoredValue::Opaque);
        match self {
            Touch::Read => &[Effect::Read],
            Touch::Write => &[WRITE],
            Touch::ReadWrite => &[Effect::Read, WRITE],
            Touch::Reduce(ReductionOp::Add) => &[Effect::Reduce(ReductionOp::Add)],
            Touch::Reduce(ReductionOp::Multiply) => &[Effect::Reduce(ReductionOp::Multiply)],
            Touch::Reduce(ReductionOp::Maximum) => &[Effect::Reduce(ReductionOp::Maximum)],
        }
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
    writers: Segments<Written>,
    /// The readers a later write must follow: those since the latest write, and any earlier
    /// one that write does not follow (in another `affine_range` iteration).
    readers: Segments<Vec<InstrId>>,
}

/// The writes a later access of an offset must follow: the latest ordinary write, and the
/// reductions since, which no order chains.
#[derive(Debug, Clone, Default)]
struct Written {
    last: Option<InstrId>,
    reductions: Vec<InstrId>,
}

impl Written {
    fn all(&self) -> impl Iterator<Item = InstrId> + '_ {
        self.last.iter().chain(&self.reductions).copied()
    }
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

/// A value per offset of one location, as disjoint segments by start; an offset never
/// updated has none.
struct Segments<V>(BTreeMap<u64, (u64, V)>);

impl<V> Default for Segments<V> {
    fn default() -> Self {
        Segments(BTreeMap::new())
    }
}

impl<V: Clone + Default> Segments<V> {
    /// The values of the segments overlapping `run`.
    fn overlapping(&self, run: &Range<u64>) -> impl Iterator<Item = &V> + '_ {
        let before = self
            .0
            .range(..run.start)
            .next_back()
            .filter(|(_, (end, _))| *end > run.start);
        before
            .into_iter()
            .chain(self.0.range(run.start..run.end))
            .map(|(_, (_, value))| value)
    }

    /// Applies `f` to the value of every offset in `run`, the default where there is none.
    fn update(&mut self, run: &Range<u64>, mut f: impl FnMut(&mut V)) {
        self.split(run.start);
        self.split(run.end);
        let mut gaps = Vec::new();
        let mut cursor = run.start;
        for (&start, (end, value)) in self.0.range_mut(run.start..run.end) {
            if start > cursor {
                gaps.push(cursor..start);
            }
            f(value);
            cursor = *end;
        }
        if cursor < run.end {
            gaps.push(cursor..run.end);
        }
        for gap in gaps {
            let mut value = V::default();
            f(&mut value);
            self.0.insert(gap.start, (gap.end, value));
        }
    }

    /// Makes a segment start at `at` if one covers it.
    fn split(&mut self, at: u64) {
        let covering = self
            .0
            .range(..at)
            .next_back()
            .filter(|(_, (end, _))| *end > at)
            .map(|(&start, (end, value))| (start, *end, value.clone()));
        if let Some((start, end, value)) = covering {
            self.0.insert(start, (at, value.clone()));
            self.0.insert(at, (end, value));
        }
    }
}
