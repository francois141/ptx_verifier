//! The interpreter: round-robin symbolic execution (paper §3, §5). Threads run
//! until they block or exit; then complete groups fire, else deadlock. It runs
//! one candidate schedule and checks no data races itself.

use std::collections::VecDeque;
use std::fmt;

use id_collections::IdVec;

use volta_frontend::ast::ScalarType;

use crate::config::{AnalysisConfig, ParamValue};
use crate::eval::cluster_launch_control::ObservedDecline;
use crate::eval::cp_async::PendingCopy;
use crate::eval::error::{EvalError, EvalResult};
use crate::eval::float_bits::{self, decode_packed_bits};
use crate::eval::mbarrier::MbarrierTable;
use crate::eval::memory::{GranuleKind, MemAccessError, Memory};
use crate::eval::record::{AccessOrigin, Recording, point, tix};
use crate::eval::tensor_map_table::TensorMapTable;
use crate::eval::tensor_memory::TensorMemory;
use crate::eval::value::{MbarrierId, RegFile, Value};
use crate::eval::warpgroup::WgmmaOpId;
use crate::eval::wgmma_hazards::WgmmaRegState;
use crate::eval::{ThreadId, WARP_SIZE};
use crate::ir::symbols::{MODULE_GLOBAL_BASE, ParamId, RegId, SpecialRegKind};
use crate::ir::types::{RegClass, ScalarTypeExt};
use crate::ir::{
    BinOp, Clamp, CpAsyncSrcSize, InstrId, LoweredInstr, LoweredProgram, MemSpace, Operand,
    Tcgen05FenceDirection,
};
use crate::logging::{info, warn};
use volta_expr::{ExprArena, ExprId, ExprNode, Real, StringId};
use volta_graph::{
    AbortCause, ArrivalOrdering, AsyncOpId, AsyncOpKind, EventGraph, FenceKind, GraphBuilder,
    GroupFamily, OperandRole, Provenance, Proxy, Space, Terminal,
};

/// Per-array output footprint: `(array name, [(element index, value)])`.
pub type OutputFootprints = Vec<(String, Vec<(u64, ExprId)>)>;

/// Execution statistics matching the paper's table columns.
#[derive(Debug, Clone, Copy, Default)]
pub struct Stats {
    /// Total instructions executed across all threads
    pub instructions: u64,
    /// `bar.sync` executions across all threads ("#Block Sync")
    pub block_syncs: u64,
    /// Warp-level sync operations, counted once per fired group
    /// (`shfl.sync`, `ldmatrix`, `mma.sync`, `wmma.*`, ...; "#Warp Sync" -
    /// the paper's tables count these per warp, not per thread)
    pub warp_syncs: u64,
}

/// PTX gives each CTA 16 hardware ("named") barriers, ids 0-15
/// (ISA 9.7.13.1).
pub(in crate::eval) const NUM_BARRIERS: usize = 16;

/// How many arrivals release a named barrier: `bar.sync a` waits for the whole
/// CTA; the counted forms (`bar.sync a, b`, `bar.arrive a, b`) wait for exactly
/// `b` threads (warp specialization).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(in crate::eval) enum BarrierArrivals {
    FullCta,
    Count(u32),
}

impl fmt::Display for BarrierArrivals {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::FullCta => write!(f, "the whole CTA"),
            Self::Count(n) => write!(f, "{} threads", n),
        }
    }
}

/// One named barrier's pending `bar.arrive` arrivals since it last fired, with
/// their arrival count. Blocking `bar.sync` arrivals wait in
/// `Status::AtBarrier` instead.
#[derive(Debug, Default)]
pub(in crate::eval) struct PendingArrivals {
    pub(in crate::eval) threads: Vec<ThreadId>,
    pub(in crate::eval) arrivals: Option<BarrierArrivals>,
}

/// How one candidate execution ended: a fact about the run, not a verdict.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RunEnd {
    /// Every thread exited.
    Completed,
    /// Live threads remain but none can proceed and no group can fire.
    Stuck,
}

/// Why a run has no symbolic outputs.
#[derive(Debug)]
pub enum OutputsUnavailable {
    /// The analysis stopped the candidate execution.
    Aborted(EvalError),
    /// The execution got stuck; `(thread, pc)` of every blocked thread.
    Stuck { blocked: Vec<(ThreadId, InstrId)> },
    /// The execution completed, but an output could not be read back.
    Extraction(EvalError),
}

impl std::fmt::Display for OutputsUnavailable {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Aborted(e) => write!(f, "the execution stopped: {}", e),
            Self::Stuck { blocked } => write!(
                f,
                "the execution is stuck with {} blocked thread(s)",
                blocked.len()
            ),
            Self::Extraction(e) => write!(f, "an output could not be read back: {}", e),
        }
    }
}

/// Everything one interpreter run produced: the expression arena, the output footprint (when
/// there is one) and the event graph of the candidate execution.
#[derive(Debug)]
pub struct RunArtifacts {
    pub arena: ExprArena,
    pub outputs: Result<OutputFootprints, OutputsUnavailable>,
    pub graph: EventGraph,
    pub stats: Stats,
    pub op_counts: std::collections::BTreeMap<&'static str, u64>,
}

/// Scheduling status of one thread.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(in crate::eval) enum Status {
    Ready,
    /// Blocked at `bar.sync id{, count}` (at the current pc), waiting for
    /// `arrivals` threads to arrive at barrier `id`.
    AtBarrier {
        id: u32,
        arrivals: BarrierArrivals,
    },
    /// Blocked at a warp-cooperative instruction at the current pc.
    /// `mask` is the participating-lane mask within the thread's warp.
    AtWarpOp {
        mask: u32,
    },
    /// Blocked at `wgmma.mma_async` at the current pc. No mask: `.aligned`
    /// means the full 128-thread warpgroup always takes part (PTX ISA
    /// 9.7.17.1); a parallel mechanism to `AtWarpOp`.
    AtWarpgroupOp,
    /// Blocked at `mbarrier.test_wait.parity`/`try_wait.parity` for `id`'s
    /// phase parity. Not a rendezvous: any thread's `arrive`/`complete_tx` can
    /// satisfy it, so waiters are checked independently.
    AtMbarrier {
        id: MbarrierId,
        phase_parity: bool,
    },
    Exited,
}

#[derive(Debug)]
pub(in crate::eval) struct ThreadState {
    pub pc: InstrId,
    pub regs: RegFile,
    pub status: Status,
    /// `cp.async` copies issued since the last `commit_group`.
    uncommitted: Vec<PendingCopy>,
    /// Committed async-copy groups, oldest first; `wait_group`/`wait_all`
    /// pop from the front.
    groups: VecDeque<Vec<PendingCopy>>,
    /// `wgmma.mma_async` register-hazard tracking (PTX ISA 9.7.17.7.1/.2/.3), a
    /// separate domain from `uncommitted`/`groups` above.
    pub(in crate::eval) wgmma: WgmmaRegState,
    /// `tcgen05.mma.ws` collector buffers `b0`-`b3`: the `B` elements the
    /// last `::fill` loaded, until a `::lastuse`/`::discard` drops them.
    pub(in crate::eval) tcgen05_collectors: [Option<Vec<ExprId>>; 4],
}

/// A contiguous validity region within one memory space.
#[derive(Debug, Clone)]
struct Region {
    base: u64,
    size: u64,
}

impl Region {
    /// Whole-access containment in subtraction form, which cannot overflow:
    /// `addr + width <= base + size` wraps near `u64::MAX` and in release mode
    /// would silently accept the access.
    fn contains(&self, addr: u64, width: u64) -> bool {
        width <= self.size && addr >= self.base && addr - self.base <= self.size - width
    }

    /// Whether `addr` lies inside `[base, base + size)`, i.e. this region
    /// owns the byte. Subtraction form; a zero-size region owns nothing.
    fn owns(&self, addr: u64) -> bool {
        addr >= self.base && addr - self.base < self.size
    }
}

/// Declared regions per space; every access must fall entirely inside one
/// region (this is what catches per-array out-of-bounds accesses).
#[derive(Debug, Default)]
struct MemRegions {
    global: Vec<Region>,
    shared: Vec<Region>,
    local: Vec<Region>,
}

pub struct Interpreter<'p> {
    pub(in crate::eval) program: &'p LoweredProgram,
    pub(in crate::eval) arena: ExprArena,
    config: AnalysisConfig,
    pub(in crate::eval) n_threads: u32,
    /// Shared `Undefined` node returned for reads of never-written
    /// registers (see `read_reg`).
    pub(in crate::eval) undefined: ExprId,
    params: IdVec<ParamId, Value>,
    pub(in crate::eval) threads: IdVec<ThreadId, ThreadState>,
    pub(in crate::eval) global: Memory,
    pub(in crate::eval) shared: Memory,
    locals: IdVec<ThreadId, Memory>,
    pub(in crate::eval) tensor: TensorMemory,
    pub(in crate::eval) next_wgmma_op: WgmmaOpId,
    /// The first declined cluster-launch-control response decoded, if any.
    pub(in crate::eval) clc_observed_decline: Option<ObservedDecline>,
    regions: MemRegions,
    pub(in crate::eval) mbarriers: MbarrierTable,
    /// Pending `bar.arrive` arrivals, indexed by barrier id.
    pub(in crate::eval) barriers: [PendingArrivals; NUM_BARRIERS],
    pub(in crate::eval) tensor_maps: TensorMapTable,
    /// The candidate execution's event graph under construction.
    pub(in crate::eval) graph: GraphBuilder,
    pub(in crate::eval) rec: Recording,
    pub(in crate::eval) stats: Stats,
    /// Per-kind instruction counts, indexed by `LoweredInstr::kind_index`. A
    /// fixed array since `step` bumps it per instruction; `finish` folds it
    /// into `AnalysisResult::op_counts`.
    pub(in crate::eval) op_counts: [u64; crate::ir::KIND_COUNT],
}

impl<'p> Interpreter<'p> {
    pub fn new(
        program: &'p LoweredProgram,
        config: AnalysisConfig,
        provenance: Provenance,
    ) -> EvalResult<Self> {
        let n_threads = config.num_threads();
        if n_threads == 0 {
            return Err(EvalError::Config {
                message: "block has zero threads".to_string(),
            });
        }

        config
            .validate()
            .map_err(|message| EvalError::Config { message })?;

        let mut arena = ExprArena::new();
        let undefined = arena.undefined();

        // Bind parameters positionally.
        let declared = program.symbols.param_count();
        if declared != config.params.len() {
            return Err(EvalError::Config {
                message: format!(
                    "kernel declares {} parameters but {} were provided",
                    declared,
                    config.params.len()
                ),
            });
        }
        let mut params: IdVec<ParamId, Value> = IdVec::new();
        for value in &config.params {
            let v = match value {
                ParamValue::Int(v) => Value::Scalar(arena.int(*v)),
                // Exact ingestion; NaN was rejected by `config.validate()`
                // above, but the conversion stays fallible so a bypassing
                // caller still fails loudly.
                ParamValue::Float(v) => {
                    Value::Scalar(arena.float_from_f64(*v).map_err(|e| EvalError::Config {
                        message: format!("float parameter: {}", e),
                    })?)
                }
                ParamValue::SymFloat(name) => Value::Scalar(arena.param_symbol(name.clone())),
                ParamValue::ArrayPtr(name) => {
                    let array = config.array(name).ok_or_else(|| EvalError::Config {
                        message: format!("parameter references unknown array '{}'", name),
                    })?;
                    Value::Scalar(arena.int(array.base as i64))
                }
            };
            let _ = params.push(v);
        }

        // Every region must satisfy `base + size <= u64::MAX` (checked in
        // release): with the subtraction-form `Region::contains`, any access
        // passing `check_bounds` cannot wrap in downstream byte loops.
        fn push_region(list: &mut Vec<Region>, base: u64, size: u64, what: &str) -> EvalResult<()> {
            if size > u64::MAX - base {
                return Err(EvalError::Config {
                    message: format!(
                        "{} region [{:#x}, {:#x} + {}) overflows the address space",
                        what, base, base, size
                    ),
                });
            }
            list.push(Region { base, size });
            Ok(())
        }
        let mut regions = MemRegions::default();
        // Arrays and module globals share one region list and are each pairwise
        // disjoint, so reject an array overlapping the module-global window to
        // keep `check_bounds` sound.
        let module_global_size = program.symbols.module_global_size();
        if module_global_size > 0 {
            let window_base = MODULE_GLOBAL_BASE;
            let window_end = MODULE_GLOBAL_BASE + module_global_size;
            for array in &config.arrays {
                // `validate()` established `base + size_bytes()` fits.
                let array_end = array.base + array.size_bytes();
                if array.base < window_end && window_base < array_end {
                    return Err(EvalError::Config {
                        message: format!(
                            "array '{}' ([{:#x}, {:#x})) overlaps the reserved \
                             module-global region [{:#x}, {:#x})",
                            array.name, array.base, array_end, window_base, window_end
                        ),
                    });
                }
            }
        }
        for array in &config.arrays {
            push_region(&mut regions.global, array.base, array.size_bytes(), "array")?;
        }
        for var in program.symbols.global_vars() {
            push_region(
                &mut regions.global,
                var.addr,
                var.size_bytes,
                "global variable",
            )?;
        }
        if program.symbols.has_extern_shared() && config.dynamic_shared_bytes == 0 {
            return Err(EvalError::Config {
                message: "kernel uses extern shared memory; set dynamic_shared_bytes".to_string(),
            });
        }
        for info in program.symbols.shared_vars() {
            if info.is_extern {
                // Every extern name aliases the one dynamic window; a single
                // region for it is added below.
                continue;
            }
            push_region(
                &mut regions.shared,
                info.offset,
                info.size_bytes,
                "shared variable",
            )?;
        }
        // The dynamic (`.extern .shared`) window: based after all static
        // allocations, sized by the launch configuration.
        if let Some(base) = program.symbols.extern_shared_base() {
            push_region(
                &mut regions.shared,
                base,
                config.dynamic_shared_bytes,
                "dynamic shared",
            )?;
        }
        for var in program.symbols.local_vars() {
            push_region(
                &mut regions.local,
                var.offset,
                var.size_bytes,
                "local variable",
            )?;
        }

        // Input-array symbols are materialized lazily on first read (arrays
        // can be huge - e.g. 4096x4096 matmul operands - while a single CTA
        // touches only a sliver). Module-scope globals are placed eagerly.
        let mut global = Memory::new();
        for (name, value) in &config.global_values {
            let var = program
                .symbols
                .get_global_var(name)
                .ok_or_else(|| EvalError::Config {
                    message: format!("no module-scope .global variable named '{}'", name),
                })?;
            let v = Value::Scalar(arena.int(*value));
            // Analysis-setup placement, not a memory instruction, so no
            // alignment rule applies; `declare_global_var` packs naturally
            // aligned anyway.
            global
                .init(var.addr, var.size_bytes, v)
                .expect("module-global initialization cannot fail");
        }

        let counts = program.register_counts();
        let threads = IdVec::from_vec(
            (0..n_threads)
                .map(|_| ThreadState {
                    pc: program.entry_pc,
                    regs: RegFile::new(&counts),
                    status: Status::Ready,
                    uncommitted: Vec::new(),
                    groups: VecDeque::new(),
                    wgmma: WgmmaRegState::default(),
                    tcgen05_collectors: Default::default(),
                })
                .collect(),
        );
        let locals = IdVec::from_vec((0..n_threads).map(|_| Memory::new()).collect());

        Ok(Self {
            program,
            arena,
            config,
            n_threads,
            undefined,
            params,
            threads,
            global,
            shared: Memory::new(),
            locals,
            tensor: TensorMemory::new(),
            next_wgmma_op: WgmmaOpId::default(),
            clc_observed_decline: None,
            regions,
            mbarriers: MbarrierTable::default(),
            barriers: std::array::from_fn(|_| PendingArrivals::default()),
            tensor_maps: TensorMapTable::new(),
            graph: GraphBuilder::new(provenance),
            rec: Recording::default(),
            stats: Stats::default(),
            op_counts: [0; crate::ir::KIND_COUNT],
        })
    }

    /// Run until every thread exited, no thread can proceed, or an analysis error.
    pub fn run(&mut self) -> EvalResult<RunEnd> {
        loop {
            match self.next_ready() {
                Some(t) => self.run_thread(t)?,
                None => {
                    if self.threads.values().all(|t| t.status == Status::Exited) {
                        info!(
                            "execution complete: {} instructions, {} block syncs, {} warp syncs",
                            self.stats.instructions, self.stats.block_syncs, self.stats.warp_syncs
                        );
                        return Ok(RunEnd::Completed);
                    }
                    if !self.try_fire()? {
                        return Ok(RunEnd::Stuck);
                    }
                }
            }
        }
    }

    /// Close the event graph with `end`'s terminal state and read back the outputs.
    pub fn finish(mut self, end: EvalResult<RunEnd>) -> RunArtifacts {
        let (terminal, outputs) = match end {
            Ok(RunEnd::Completed) => (
                Terminal::Completed,
                self.extract_outputs()
                    .map_err(OutputsUnavailable::Extraction),
            ),
            Ok(RunEnd::Stuck) => {
                let live: Vec<ThreadId> = self
                    .threads
                    .iter()
                    .filter(|(_, t)| t.status != Status::Exited)
                    .map(|(id, _)| id)
                    .collect();
                warn!("stuck: {} threads blocked", live.len());
                let records = live.iter().map(|&t| self.blocked_record(t)).collect();
                let blocked = live.iter().map(|&t| (t, self.threads[t].pc)).collect();
                (
                    Terminal::Stuck { blocked: records },
                    Err(OutputsUnavailable::Stuck { blocked }),
                )
            }
            Err(e) => {
                let (thread, pc) = e.location();
                let cause = match e {
                    EvalError::Unsupported { .. } => AbortCause::Unsupported,
                    _ => AbortCause::Error,
                };
                (
                    Terminal::Aborted {
                        thread: thread.map(tix),
                        pc: pc.map(point),
                        cause,
                        reason: e.to_string(),
                    },
                    Err(OutputsUnavailable::Aborted(e)),
                )
            }
        };
        let op_counts = self
            .op_counts
            .iter()
            .enumerate()
            .filter(|&(_, &count)| count > 0)
            .map(|(i, &count)| (crate::ir::KIND_NAMES[i], count))
            .collect();
        RunArtifacts {
            arena: self.arena,
            outputs,
            graph: self.graph.finish(terminal),
            stats: self.stats,
            op_counts,
        }
    }

    /// Extract the output footprint: for each output array, every element the
    /// program actually wrote, keyed by index so two kernels' footprints
    /// compare exactly.
    pub fn extract_outputs(&mut self) -> EvalResult<OutputFootprints> {
        let mut outputs = Vec::new();
        for array in &self.config.arrays {
            if !array.kind.is_output() {
                continue;
            }
            let size = array.size_bytes();
            let mut elems: Vec<(u64, ExprId)> = Vec::new();
            for (addr, width, value) in self.global.dirty_cells() {
                // Whole-cell containment in subtraction form (as in
                // `Region::contains`): no overflowing sums for any cell.
                if addr < array.base || width > size || addr - array.base > size - width {
                    continue;
                }
                let offset = addr - array.base;
                if offset % array.elem_width != 0 {
                    return Err(EvalError::Config {
                        message: format!(
                            "output array '{}' was written at misaligned offset {:#x}",
                            array.name, offset
                        ),
                    });
                }
                let index = offset / array.elem_width;
                // A `mov.bN dst, {lo, hi}` pack of two concrete integer halves
                // stored as one wide element is that integer, recombined as
                // `scalar_operand` does for registers.
                let value = match value {
                    Value::Pair(lo, hi) if width == array.elem_width => {
                        match (self.arena.as_int_const(lo), self.arena.as_int_const(hi)) {
                            (Some(l), Some(h)) => {
                                let half_bits = width as u32 * 4;
                                Value::Scalar(Self::recombine_pair_halves(
                                    &mut self.arena,
                                    l,
                                    h,
                                    half_bits,
                                ))
                            }
                            _ => Value::Pair(lo, hi),
                        }
                    }
                    other => other,
                };
                match (value, width == array.elem_width) {
                    (Value::Scalar(e), true) => {
                        if self.arena.is_undefined(e) {
                            return Err(EvalError::UndefinedOutput {
                                array: array.name.clone(),
                                index,
                            });
                        }
                        elems.push((index, e));
                    }
                    // A packed pair granule over two adjacent narrow elements.
                    (Value::Pair(lo, hi), false) if width == 2 * array.elem_width => {
                        for (k, e) in [(0, lo), (1, hi)] {
                            if self.arena.is_undefined(e) {
                                return Err(EvalError::UndefinedOutput {
                                    array: array.name.clone(),
                                    index: index + k,
                                });
                            }
                            elems.push((index + k, e));
                        }
                    }
                    // A concrete all-zero granule over several narrow elements
                    // (`st.global.v4.b32 [ptr], {0, 0, 0, 0}`): zero reads the
                    // same in every element type, so it splits untyped.
                    (Value::Scalar(e), false)
                        if width.is_multiple_of(array.elem_width)
                            && self.arena.as_int_const(e) == Some(0) =>
                    {
                        let count = width / array.elem_width;
                        elems.extend((0..count).map(|k| (index + k, e)));
                    }
                    _ => {
                        return Err(EvalError::Config {
                            message: format!(
                                "output array '{}' element {} was written at width {} \
                                 (element width {})",
                                array.name, index, width, array.elem_width
                            ),
                        });
                    }
                }
            }
            elems.sort_by_key(|(i, _)| *i);
            outputs.push((array.name.clone(), elems));
        }
        Ok(outputs)
    }
    // =====================================================================
    // Single-instruction execution
    // =====================================================================

    pub(in crate::eval) fn step(&mut self, t: ThreadId) -> EvalResult<()> {
        let pc = self.threads[t].pc;
        let Some(instr) = self.program.instruction(pc) else {
            return Err(EvalError::Unsupported {
                pc,
                what: "execution fell off the end of the program".to_string(),
            });
        };
        let instr = instr.clone();

        self.stats.instructions += 1;
        self.op_counts[instr.kind_index()] += 1;
        if self.stats.instructions > self.config.max_instructions {
            return Err(EvalError::InstructionLimit {
                limit: self.config.max_instructions,
            });
        }

        // Predicate guard: must be concrete (structured-CTA).
        if let Some(pred) = self.program.predicate(pc) {
            let value = self.read_reg(t, pc, pred.reg)?;
            let cond = self.as_concrete_bool(t, pc, value, "guard predicate")?;
            if cond == pred.negated {
                self.threads[t].pc = InstrId(pc.0 + 1);
                return Ok(());
            }
        }

        let mut next_pc = InstrId(pc.0 + 1);
        match &instr {
            // Parameter reads are value-binding lookups, not memory accesses,
            // so no alignment rule applies; byte-addressed `.param`/`.const`
            // accesses are rejected in `check_bounds`.
            LoweredInstr::LoadParam { dst, param_id } => {
                let v = self.params[*param_id];
                self.write_reg(t, pc, *dst, v)?;
            }

            LoweredInstr::Load {
                dst,
                space,
                base,
                offset,
                ty,
            } => {
                let addr = self.effective_addr(t, pc, base, *offset)?;
                let v = self.mem_read(t, pc, *space, addr, ty.size_bytes() as u64)?;
                let v = self.canon_loaded(t, pc, *ty, *dst, v)?;
                self.write_reg(t, pc, *dst, v)?;
            }

            LoweredInstr::LoadVec {
                dst,
                space,
                base,
                offset,
                ty,
            } => {
                let addr = self.effective_addr(t, pc, base, *offset)?;
                let width = ty.size_bytes() as u64;
                // A vector load is one access of the total size (PTX ISA
                // 6.4.1), so bounds and alignment are checked once for the
                // whole footprint - else a v4 could straddle two arrays.
                self.check_bounds(t, pc, *space, addr, dst.len() as u64 * width)?;
                self.check_alignment(t, pc, *space, addr, dst.len() as u64 * width)?;
                for (k, reg) in dst.iter().enumerate() {
                    let v = self.mem_read(t, pc, *space, addr + k as u64 * width, width)?;
                    let v = self.canon_loaded(t, pc, *ty, *reg, v)?;
                    self.write_reg(t, pc, *reg, v)?;
                }
            }

            LoweredInstr::Store {
                space,
                base,
                offset,
                src,
                ty,
            } => {
                let addr = self.effective_addr(t, pc, base, *offset)?;
                let v = self.operand_value(t, pc, src)?;
                let v = self.canon_stored(t, pc, *ty, operand_reg_bits(src), v)?;
                self.mem_write(t, pc, *space, addr, ty.size_bytes() as u64, v)?;
            }

            LoweredInstr::StoreVec {
                space,
                base,
                offset,
                src,
                ty,
            } => {
                let addr = self.effective_addr(t, pc, base, *offset)?;
                let width = ty.size_bytes() as u64;
                // As for `LoadVec`: a vector store is one access of the total
                // size, so its whole footprint must fit in one region and align
                // to the total size.
                self.check_bounds(t, pc, *space, addr, src.len() as u64 * width)?;
                self.check_alignment(t, pc, *space, addr, src.len() as u64 * width)?;
                for (k, op) in src.iter().enumerate() {
                    let v = self.operand_value(t, pc, op)?;
                    let v = self.canon_stored(t, pc, *ty, operand_reg_bits(op), v)?;
                    self.mem_write(t, pc, *space, addr + k as u64 * width, width, v)?;
                }
            }

            LoweredInstr::CpAsync {
                dst_base,
                dst_offset,
                src_base,
                src_offset,
                cp_size,
                src_size,
            } => {
                let dst_addr = self.effective_addr(t, pc, dst_base, *dst_offset)?;
                let src_addr = self.effective_addr(t, pc, src_base, *src_offset)?;
                let cp_size = *cp_size as u64;

                // How many of `cp_size` bytes are real (the rest is
                // zero-filled); `src-size` vs `ignore-src` was already resolved
                // at lowering by operand kind.
                let real_bytes = match src_size {
                    CpAsyncSrcSize::Full => cp_size,
                    CpAsyncSrcSize::Sized(op) => {
                        let n = self.concrete_operand(t, pc, op, "cp.async src-size")?;
                        if n < 0 || n as u64 > cp_size {
                            return Err(EvalError::Unsupported {
                                pc,
                                what: format!(
                                    "cp.async src-size {} out of range [0, {}]",
                                    n, cp_size
                                ),
                            });
                        }
                        n as u64
                    }
                    CpAsyncSrcSize::IgnoreSrc(op) => {
                        let v = self.operand_value(t, pc, op)?;
                        let ignore = self.as_concrete_bool(t, pc, v, "cp.async ignore-src")?;
                        if ignore { 0 } else { cp_size }
                    }
                };
                // The copy is decomposed into 4-byte words, so a real/zero
                // boundary inside a word would need byte masking Volta doesn't
                // model; reject it loudly.
                if !real_bytes.is_multiple_of(4) {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!(
                            "cp.async src-size {} is not a multiple of 4 bytes",
                            real_bytes
                        ),
                    });
                }

                // The destination reserves its whole slot and both align to
                // `cp_size`, but source bounds use `real_bytes` so a clamped
                // partial copy passes. Bounds before alignment.
                self.check_bounds(t, pc, MemSpace::Shared, dst_addr, cp_size)?;
                self.check_alignment(t, pc, MemSpace::Shared, dst_addr, cp_size)?;
                if real_bytes > 0 {
                    self.check_bounds(t, pc, MemSpace::Global, src_addr, real_bytes)?;
                }
                self.check_alignment(t, pc, MemSpace::Global, src_addr, cp_size)?;

                // The source is read now: exact only if nothing writes it
                // before the copy completes, which race checking must show.
                let op = self.record_async_issue(t, pc, AsyncOpKind::CpAsync);
                let source = AccessOrigin::Async {
                    op,
                    proxy: Proxy::Generic,
                    role: OperandRole::Source,
                };
                let destination = AccessOrigin::Async {
                    op,
                    proxy: Proxy::Generic,
                    role: OperandRole::Destination,
                };
                let zero = Value::Scalar(self.arena.int(0));
                let mut words = Vec::with_capacity((cp_size / 4) as usize);
                for i in 0..cp_size / 4 {
                    let byte = i * 4;
                    let v = if byte < real_bytes {
                        self.mem_read_from(t, pc, MemSpace::Global, src_addr + byte, 4, source)?
                    } else {
                        zero
                    };
                    words.push(v);
                }
                for (i, &v) in words.iter().enumerate() {
                    let addr = dst_addr + i as u64 * 4;
                    self.record_mem_access(t, pc, MemSpace::Shared, addr, 4, Some(v), destination);
                }

                self.threads[t].uncommitted.push(PendingCopy {
                    op,
                    dst_addr,
                    words,
                    pc,
                });
            }

            LoweredInstr::Mov { dst, src, ty } => {
                let v = self.operand_value(t, pc, src)?;
                // Rebind the value at the mov's own type: `mov.u32 %r, -1` must
                // leave the same canonical constant as `not.b32 %r, 0`.
                let v = match v {
                    Value::Scalar(e) => Value::Scalar(self.canon_operand(pc, *ty, e)?),
                    pair @ Value::Pair(_, _) => pair,
                    // A `Quad` (byte-granular vector-load lane) flows through
                    // `mov` untouched, like `Pair`; canonicalization applies
                    // only to scalar bit patterns.
                    quad @ Value::Quad(..) => quad,
                    Value::Mbarrier(_) => {
                        return Err(EvalError::ValueKindMismatch {
                            thread: t,
                            pc,
                            what: "mbarrier handle used as a mov operand",
                        });
                    }
                };
                self.write_reg(t, pc, *dst, v)?;
            }

            // Only `cvta.to.global` reaches evaluation; global addresses are
            // absolute and the generic window over global is identity-mapped,
            // so this is the identity.
            LoweredInstr::Cvta { dst, src } => {
                let v = self.operand_value(t, pc, src)?;
                self.write_reg(t, pc, *dst, v)?;
            }

            LoweredInstr::Mapa { dst, src, rank } => {
                let rank = self.concrete_operand(t, pc, rank, "mapa CTA rank")?;
                if rank != 0 {
                    return Err(EvalError::MapaRankOutsideCluster {
                        thread: t,
                        pc,
                        rank,
                    });
                }
                let v = self.operand_value(t, pc, src)?;
                self.write_reg(t, pc, *dst, v)?;
            }

            LoweredInstr::Prmt {
                dst,
                src_a,
                src_b,
                selector,
            } => {
                let selector = self.concrete_operand(t, pc, selector, "prmt selector")? as u16;
                let fp8_sign_xor = |this: &mut Self, value: ExprId| {
                    let ExprNode::BitXor(left, right) = this.arena.node(value).clone() else {
                        return value;
                    };
                    let magnitude = if this.arena.as_int_const(left) == Some(128) {
                        Some(right)
                    } else if this.arena.as_int_const(right) == Some(128) {
                        Some(left)
                    } else {
                        None
                    };
                    magnitude.map_or(value, |value| this.arena.neg(value))
                };
                // An FP8 scalar byte already denotes its real value, and a
                // vector-loaded word is a Quad of such values; keep the lanes
                // split while applying the byte selector.
                let lanes = |this: &mut Self, value: Value| match value {
                    Value::Scalar(value) => Ok([Some(fp8_sign_xor(this, value)), None, None, None]),
                    Value::Quad(b0, b1, b2, b3) => Ok([Some(b0), Some(b1), Some(b2), Some(b3)]),
                    Value::Pair(..) => Err(EvalError::ValueKindMismatch {
                        thread: t,
                        pc,
                        what: "packed pair used as a prmt source",
                    }),
                    Value::Mbarrier(_) => Err(EvalError::ValueKindMismatch {
                        thread: t,
                        pc,
                        what: "mbarrier handle used as a prmt source",
                    }),
                };
                let src_a = self.operand_value(t, pc, src_a)?;
                let src_b = self.operand_value(t, pc, src_b)?;
                let a = lanes(self, src_a)?;
                let b = lanes(self, src_b)?;
                let select_byte = |this: &mut Self, nibble: u16| -> EvalResult<ExprId> {
                    let source = if nibble & 7 < 4 { &a } else { &b };
                    let byte = source[(nibble & 3) as usize].ok_or(EvalError::Unsupported {
                        pc,
                        what: format!(
                            "prmt selector {selector:#06x}: byte {} is unavailable from a scalar \
                             FP8 input",
                            nibble & 7
                        ),
                    })?;
                    Ok(if nibble & 8 == 0 {
                        byte
                    } else {
                        this.arena.neg(byte)
                    })
                };
                let b0 = select_byte(self, selector & 0xf)?;
                let b1 = select_byte(self, (selector >> 4) & 0xf)?;
                let b2 = select_byte(self, (selector >> 8) & 0xf)?;
                let b3 = select_byte(self, (selector >> 12) & 0xf)?;
                self.write_reg(t, pc, *dst, Value::Quad(b0, b1, b2, b3))?;
            }

            LoweredInstr::Lop3 {
                dst,
                src_a,
                src_b,
                src_c,
                lut,
            } => {
                let lut = self.concrete_operand(t, pc, lut, "lop3 LUT")? as u32;
                let sources = [
                    self.scalar_operand(t, pc, src_a)?,
                    self.scalar_operand(t, pc, src_b)?,
                    self.scalar_operand(t, pc, src_c)?,
                ];
                let mut words = [0u32; 3];
                let mut symbolic = [0usize; 3];
                let mut symbolic_len = 0;
                for (position, &source) in sources.iter().enumerate() {
                    match self.arena.as_i64(source) {
                        Some(word) => words[position] = word as u32,
                        None => {
                            symbolic[symbolic_len] = position;
                            symbolic_len += 1;
                        }
                    }
                }
                let result = self.lop3_expand(lut, sources, words, &symbolic[..symbolic_len]);
                self.write_reg(t, pc, *dst, Value::Scalar(result))?;
            }

            LoweredInstr::BinOp {
                op,
                dst,
                src_a,
                src_b,
                ty,
                clamp,
            } => {
                if let Some(lane_ty) = ty.packed_lane() {
                    let (a_lo, a_hi) = self.pair_operand(t, pc, src_a, lane_ty)?;
                    let (b_lo, b_hi) = self.pair_operand(t, pc, src_b, lane_ty)?;
                    let lo = self.eval_binop(t, pc, *op, lane_ty, a_lo, b_lo)?;
                    let hi = self.eval_binop(t, pc, *op, lane_ty, a_hi, b_hi)?;
                    let lo = self.apply_clamp(*clamp, lo);
                    let hi = self.apply_clamp(*clamp, hi);
                    self.write_reg(t, pc, *dst, Value::Pair(lo, hi))?;
                } else if let Some(v) = self.pair_bitwise_binop(t, pc, *op, *ty, src_a, src_b)? {
                    self.write_reg(t, pc, *dst, v)?;
                } else if let Some(v) = self.quad_bitwise_binop(t, pc, *op, *ty, src_a, src_b)? {
                    self.write_reg(t, pc, *dst, v)?;
                } else {
                    let a = self.scalar_operand(t, pc, src_a)?;
                    let b = self.scalar_operand(t, pc, src_b)?;
                    let r = self.eval_binop(t, pc, *op, *ty, a, b)?;
                    let r = self.apply_clamp(*clamp, r);
                    self.write_reg(t, pc, *dst, Value::Scalar(r))?;
                }
            }

            LoweredInstr::UnaryOp { op, dst, src, ty } => {
                if let Some(lane_ty) = ty.packed_lane() {
                    let (a_lo, a_hi) = self.pair_operand(t, pc, src, lane_ty)?;
                    let lo = self.eval_unop(pc, *op, lane_ty, a_lo)?;
                    let hi = self.eval_unop(pc, *op, lane_ty, a_hi)?;
                    self.write_reg(t, pc, *dst, Value::Pair(lo, hi))?;
                } else {
                    let a = self.scalar_operand(t, pc, src)?;
                    let r = self.eval_unop(pc, *op, *ty, a)?;
                    self.write_reg(t, pc, *dst, Value::Scalar(r))?;
                }
            }

            LoweredInstr::Copysign {
                dst,
                sign_src,
                magnitude_src,
                ty,
            } => {
                let sign = self.float_operand(t, pc, sign_src, *ty)?;
                let magnitude = self.float_operand(t, pc, magnitude_src, *ty)?;
                let zero = self.arena.real(Real::zero());
                let non_negative = self.arena.ge(sign, zero);
                let abs_magnitude = self.arena.abs(magnitude);
                let neg_abs_magnitude = self.arena.neg(abs_magnitude);
                let r = self
                    .arena
                    .select(non_negative, abs_magnitude, neg_abs_magnitude);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Fma {
                dst,
                src_a,
                src_b,
                src_c,
                ty,
                mul_ty,
                clamp,
            } => {
                if let Some(lane_ty) = ty.packed_lane() {
                    let (a_lo, a_hi) = self.pair_operand(t, pc, src_a, lane_ty)?;
                    let (b_lo, b_hi) = self.pair_operand(t, pc, src_b, lane_ty)?;
                    let (c_lo, c_hi) = self.pair_operand(t, pc, src_c, lane_ty)?;
                    let lo = self.arena.fma(a_lo, b_lo, c_lo);
                    let hi = self.arena.fma(a_hi, b_hi, c_hi);
                    let lo = self.apply_clamp(*clamp, lo);
                    let hi = self.apply_clamp(*clamp, hi);
                    self.write_reg(t, pc, *dst, Value::Pair(lo, hi))?;
                } else {
                    let a = self.float_operand(t, pc, src_a, *mul_ty)?;
                    let b = self.float_operand(t, pc, src_b, *mul_ty)?;
                    let c = self.float_operand(t, pc, src_c, *ty)?;
                    let r = self.arena.fma(a, b, c);
                    let r = self.apply_clamp(*clamp, r);
                    self.write_reg(t, pc, *dst, Value::Scalar(r))?;
                }
            }

            LoweredInstr::Mad {
                dst,
                src_a,
                src_b,
                src_c,
                ty,
                mode,
            } => {
                let a = self.scalar_operand(t, pc, src_a)?;
                let b = self.scalar_operand(t, pc, src_b)?;
                let c = self.scalar_operand(t, pc, src_c)?;
                let product = match mode {
                    crate::ir::MulMode::Lo => self.eval_binop(t, pc, BinOp::Mul, *ty, a, b)?,
                    crate::ir::MulMode::Wide => self.mul_wide(*ty, a, b),
                    crate::ir::MulMode::Hi => {
                        // Same guard as MulHi: mul_hi composes `(a*b) >> bits`,
                        // which cannot represent the high half above 32 bits.
                        if ty.bits() > 32 {
                            return Err(EvalError::Unsupported {
                                pc,
                                what: format!("mad.hi at width {}", ty.bits()),
                            });
                        }
                        self.mul_hi(*ty, a, b)
                    }
                };
                let r = match mode {
                    crate::ir::MulMode::Lo => {
                        self.eval_binop(t, pc, BinOp::Add, *ty, product, c)?
                    }
                    _ => self.arena.add(product, c),
                };
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::MulWide {
                dst,
                src_a,
                src_b,
                src_ty,
            } => {
                let a = self.scalar_operand(t, pc, src_a)?;
                let b = self.scalar_operand(t, pc, src_b)?;
                let r = self.mul_wide(*src_ty, a, b);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::MulHi {
                dst,
                src_a,
                src_b,
                ty,
            } => {
                if ty.bits() > 32 {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("mul.hi at width {}", ty.bits()),
                    });
                }
                let a = self.scalar_operand(t, pc, src_a)?;
                let b = self.scalar_operand(t, pc, src_b)?;
                let r = self.mul_hi(*ty, a, b);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Bfi {
                dst,
                src_a,
                src_b,
                start,
                len,
                ty,
            } => {
                let a = self.concrete_operand(t, pc, src_a, "bfi operand")? as u64;
                let b = self.concrete_operand(t, pc, src_b, "bfi operand")? as u64;
                let pos = self.concrete_operand(t, pc, start, "bfi start")? as u64 & 0xff;
                let len = self.concrete_operand(t, pc, len, "bfi len")? as u64 & 0xff;
                let msb: u64 = if ty.bits() <= 32 { 31 } else { 63 };
                let mut f = b;
                let mut i: u64 = 0;
                while i < len && pos + i <= msb {
                    // Clear bit pos+i of f.
                    f &= !(1u64 << (pos + i));
                    // Set bit pos+i of f to bit i of a.
                    f |= ((a >> i) & 1) << (pos + i);
                    i += 1;
                }
                let r = self.arena.int(f as i64);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Shf {
                dst,
                lo,
                hi,
                shift,
                dir,
                mode,
            } => {
                let v = self.eval_shf(t, pc, lo, hi, shift, *dir, *mode)?;
                self.threads[t].regs.write(*dst, v);
            }

            LoweredInstr::Bfe {
                dst,
                src_a,
                start,
                len,
                ty,
            } => {
                let a = self.concrete_operand(t, pc, src_a, "bfe operand")? as u64;
                let pos = (self.concrete_operand(t, pc, start, "bfe start")? as u64 & 0xff) as u32;
                let len = (self.concrete_operand(t, pc, len, "bfe len")? as u64 & 0xff) as u32;
                let msb: u32 = if ty.bits() <= 32 { 31 } else { 63 };
                let a = if msb < 63 {
                    a & ((1u64 << (msb + 1)) - 1)
                } else {
                    a
                };

                let sbit: u64 = if !ty.is_signed_int() || len == 0 {
                    0
                } else {
                    let sbit_pos = pos.saturating_add(len).saturating_sub(1).min(msb);
                    (a >> sbit_pos) & 1
                };

                let mut d: u64 = 0;
                for i in 0..=msb {
                    let bit = if i < len && pos.saturating_add(i) <= msb {
                        (a >> (pos + i)) & 1
                    } else {
                        sbit
                    };
                    d |= bit << i;
                }
                let r = self.arena.int(d as i64);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Setp {
                cmp,
                dst,
                src_a,
                src_b,
                ty,
            } => {
                let a = self.scalar_operand(t, pc, src_a)?;
                let b = self.scalar_operand(t, pc, src_b)?;
                let r = self.eval_cmp(pc, *cmp, *ty, a, b)?;
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Selp {
                dst,
                src_a,
                src_b,
                pred,
                ty,
            } => {
                let a = self.scalar_operand(t, pc, src_a)?;
                let b = self.scalar_operand(t, pc, src_b)?;
                // Reinterpret concrete arms at the instruction type first:
                // `selp.b32 %r, -1, 0, %p` must export the canonical 4294967295
                // (see [`Self::canon_operand`]).
                let a = self.canon_operand(pc, *ty, a)?;
                let b = self.canon_operand(pc, *ty, b)?;
                let cond = self.scalar_operand(t, pc, pred)?;
                let r = self.arena.select(cond, a, b);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Cvt {
                dst,
                src,
                dst_ty,
                src_ty,
                clamp,
            } => {
                let int_to_int = src_ty.is_integer() && dst_ty.is_integer();
                let truncates_pair = int_to_int && src_ty.bits() == 64 && dst_ty.bits() == 32;
                // `cvt.u16.u32` of a byte-quad (LLVM's low-16-bits extraction
                // before `cvt.e4m3x2`): a `Quad` has no bits to truncate, so
                // keep its low `Pair`, as `truncates_pair` does.
                let truncates_quad = int_to_int && src_ty.bits() == 32 && dst_ty.bits() == 16;
                let result = match self.operand_value(t, pc, src)? {
                    // `cvt.u32.u64`-style truncation of a packed pair keeps
                    // its low lane, exactly.
                    Value::Pair(lo, _) if truncates_pair => Value::Scalar(lo),
                    Value::Quad(b0, b1, _, _) if truncates_quad => Value::Pair(b0, b1),
                    value => {
                        let a = match value {
                            Value::Pair(_, _) => self.scalar_operand(t, pc, src)?,
                            Value::Scalar(e) => e,
                            Value::Quad(..) => {
                                return Err(EvalError::ValueKindMismatch {
                                    thread: t,
                                    pc,
                                    what: "a packed byte-quad used as an ordinary cvt operand \
                                           outside a 32->16-bit integer truncation (the \
                                           .e4m3x2 family has its own dedicated cvt form)",
                                });
                            }
                            Value::Mbarrier(_) => {
                                return Err(EvalError::ValueKindMismatch {
                                    thread: t,
                                    pc,
                                    what: "mbarrier handle used as a cvt operand",
                                });
                            }
                        };
                        let zero_extend = if int_to_int {
                            self.zero_extend_to_pair(
                                src_ty.bits(),
                                src_ty.is_signed_int(),
                                dst_ty.bits(),
                                a,
                            )
                        } else {
                            None
                        };
                        if let Some(pair) = zero_extend {
                            pair
                        } else {
                            let r = self.eval_cvt(pc, *dst_ty, *src_ty, a)?;
                            Value::Scalar(self.apply_clamp(*clamp, r))
                        }
                    }
                };
                self.write_reg(t, pc, *dst, result)?;
            }

            LoweredInstr::CvtE4m3x2ToF16x2 { dst, src, relu } => {
                let clamp = relu.then_some(Clamp::Relu);
                let result = match self.operand_value(t, pc, src)? {
                    // The common case: a symbolic (or already-split) fp8
                    // element is already its real value (identity over reals,
                    // like every float<->float `cvt`); no bit decode needed.
                    Value::Pair(b0, b1) => {
                        Value::Pair(self.apply_clamp(clamp, b0), self.apply_clamp(clamp, b1))
                    }
                    // A genuine concrete 16-bit pattern that never went through
                    // array materialization (`cp.async` zero-fill, `mov.b16`
                    // literal): decode each byte's `.e4m3` encoding.
                    Value::Scalar(e) if self.arena.as_i64(e).is_some() => {
                        let raw = self.arena.as_i64(e).unwrap() as u64;
                        let lo_byte = (raw & 0xFF) as u8;
                        let hi_byte = ((raw >> 8) & 0xFF) as u8;
                        let lo = self.decode_fp8_byte(
                            pc,
                            "cvt.e4m3x2",
                            lo_byte,
                            float_bits::decode_e4m3_byte,
                        )?;
                        let hi = self.decode_fp8_byte(
                            pc,
                            "cvt.e4m3x2",
                            hi_byte,
                            float_bits::decode_e4m3_byte,
                        )?;
                        Value::Pair(self.apply_clamp(clamp, lo), self.apply_clamp(clamp, hi))
                    }
                    // One fp8 element loaded at 16-bit register width
                    // (`ld.global.b8 {%rs}`): `e` is its real value; the upper
                    // byte is untracked, hence `Undefined`.
                    Value::Scalar(e) => {
                        let undef = self.arena.undefined();
                        Value::Pair(self.apply_clamp(clamp, e), undef)
                    }
                    Value::Quad(..) => {
                        return Err(EvalError::ValueKindMismatch {
                            thread: t,
                            pc,
                            what: "cvt.e4m3x2 source is a 4-byte packed value \
                                   (expected a 2-byte .b16 register)",
                        });
                    }
                    Value::Mbarrier(_) => {
                        return Err(EvalError::ValueKindMismatch {
                            thread: t,
                            pc,
                            what: "mbarrier handle used as a cvt.e4m3x2 operand",
                        });
                    }
                };
                self.write_reg(t, pc, *dst, result)?;
            }

            LoweredInstr::CvtPackHalves {
                dst,
                src_hi,
                src_lo,
                dst_half_ty,
                src_ty,
            } => {
                // Each half converts independently (same identity-over-
                // reals policy as `Cvt`), then packs as a `Value::Pair` -
                // never bit-encoded, per every other packed-f16 producer.
                let hi = self.scalar_operand(t, pc, src_hi)?;
                let hi = self.eval_cvt(pc, *dst_half_ty, *src_ty, hi)?;
                let lo = self.scalar_operand(t, pc, src_lo)?;
                let lo = self.eval_cvt(pc, *dst_half_ty, *src_ty, lo)?;
                self.write_reg(t, pc, *dst, Value::Pair(lo, hi))?;
            }

            LoweredInstr::UnpackHalves { lo, hi, src, ty } => {
                match self.operand_value(t, pc, src)? {
                    // A native packed-f16 granule: the halves are already
                    // real-valued, never bit-encoded (as in `CvtPackHalves`,
                    // `eval/memory.rs`); distribute them directly.
                    Value::Pair(lo_e, hi_e) => {
                        if let Some(lo) = lo {
                            self.write_reg(t, pc, *lo, Value::Scalar(lo_e))?;
                        }
                        if let Some(hi) = hi {
                            self.write_reg(t, pc, *hi, Value::Scalar(hi_e))?;
                        }
                    }
                    // A genuine scalar bit pattern: split it the way this
                    // instruction always used to, via bitwise and/shift.
                    Value::Scalar(e) => {
                        let elem_width = ty.bits() / 2;
                        let mask = self.arena.int((1i64 << elem_width) - 1);
                        let shift = self.arena.int(elem_width as i64);
                        if let Some(lo) = lo {
                            let lo_v = self.eval_binop(t, pc, BinOp::And, *ty, e, mask)?;
                            self.write_reg(t, pc, *lo, Value::Scalar(lo_v))?;
                        }
                        if let Some(hi) = hi {
                            let hi_v = self.eval_binop(t, pc, BinOp::Shr, *ty, e, shift)?;
                            self.write_reg(t, pc, *hi, Value::Scalar(hi_v))?;
                        }
                    }
                    // A `Quad`: each half is two byte lanes, so it splits into
                    // two `Pair`s, never bit-encoded - the `mov.b32 {h0,h1}, r`
                    // idiom before `cvt.rn.f16x2.e4m3x2` on fp8 arrays.
                    Value::Quad(b0, b1, b2, b3) => {
                        if let Some(lo) = lo {
                            self.write_reg(t, pc, *lo, Value::Pair(b0, b1))?;
                        }
                        if let Some(hi) = hi {
                            self.write_reg(t, pc, *hi, Value::Pair(b2, b3))?;
                        }
                    }
                    Value::Mbarrier(_) => {
                        return Err(EvalError::ValueKindMismatch {
                            thread: t,
                            pc,
                            what: "mbarrier handle used as an unpack operand",
                        });
                    }
                }
            }

            LoweredInstr::PackHalves { dst, lo, hi } => {
                // Always a Value::Pair. lo/hi are half-width operands:
                // 16-bit-class for a b32 pack, 32-bit-class for b64, where
                // scalar_operand rejects a half that is itself a pair.
                let lo_v = self.scalar_operand(t, pc, lo)?;
                let hi_v = self.scalar_operand(t, pc, hi)?;
                self.write_reg(t, pc, *dst, Value::Pair(lo_v, hi_v))?;
            }

            LoweredInstr::PackQuad { dst, elems } => {
                // Always a Value::Quad - see the type's doc comment. A lane
                // that is itself packed is rejected by scalar_operand
                // (nested quads are not modeled), same as PackHalves.
                let l0 = self.scalar_operand(t, pc, &elems[0])?;
                let l1 = self.scalar_operand(t, pc, &elems[1])?;
                let l2 = self.scalar_operand(t, pc, &elems[2])?;
                let l3 = self.scalar_operand(t, pc, &elems[3])?;
                self.threads[t]
                    .regs
                    .write(*dst, Value::Quad(l0, l1, l2, l3));
            }

            LoweredInstr::UnpackQuad { elems, src } => {
                // Only the PackQuad round-trip is modeled: the four lanes
                // are already independent values, distributed directly and
                // never bit-decoded (see UnpackQuad's doc comment).
                let Value::Quad(l0, l1, l2, l3) = self.operand_value(t, pc, src)? else {
                    return Err(EvalError::ValueKindMismatch {
                        thread: t,
                        pc,
                        what: "mov {a,b,c,d}, src expects a four-lane packed source",
                    });
                };
                for (dst, lane) in elems.iter().zip([l0, l1, l2, l3]) {
                    if let Some(dst) = dst {
                        self.threads[t].regs.write(*dst, Value::Scalar(lane));
                    }
                }
            }

            LoweredInstr::Bra { target } => {
                next_pc = *target;
            }

            LoweredInstr::Ret | LoweredInstr::Exit => {
                // A well-formed kernel always waits on its own async copies
                // before exiting.
                let pending = self.threads[t].uncommitted.len()
                    + self.threads[t].groups.iter().map(Vec::len).sum::<usize>();
                if pending > 0 {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!(
                            "thread exited with {} async-copy operation(s) still pending \
                             (missing cp.async.wait_group/wait_all)",
                            pending
                        ),
                    });
                }
                self.record_exit(t, pc);
                self.threads[t].status = Status::Exited;
                return Ok(());
            }

            LoweredInstr::BarSync {
                barrier_id,
                thread_count,
            } => {
                let (id, arrivals) =
                    self.barrier_operands(t, pc, barrier_id, thread_count.as_ref())?;
                self.stats.block_syncs += 1;
                self.record_barrier_arrival(t, pc, id, arrivals, true);
                self.threads[t].status = Status::AtBarrier { id, arrivals };
                return Ok(()); // pc advances when the barrier fires
            }

            LoweredInstr::BarArrive {
                barrier_id,
                thread_count,
            } => {
                let (id, arrivals) =
                    self.barrier_operands(t, pc, barrier_id, Some(thread_count))?;
                self.record_barrier_arrival(t, pc, id, arrivals, false);
                let pending = &mut self.barriers[id as usize];
                pending.arrivals = Some(arrivals);
                pending.threads.push(t);
            }

            LoweredInstr::BarWarpSync { mask } => {
                let mask = self.concrete_operand(t, pc, mask, "warp sync mask")? as u32;
                self.block_at_warp_op(t, pc, mask)?;
                return Ok(());
            }

            LoweredInstr::Membar | LoweredInstr::Fence | LoweredInstr::Nop => {}

            LoweredInstr::FenceProxyAsync { restrict } => {
                let space = restrict.map(|s| match s {
                    MemSpace::Global => Space::Global,
                    _ => Space::Shared,
                });
                self.graph
                    .fence(tix(t), point(pc), FenceKind::ProxyAsync { space });
            }

            LoweredInstr::CpAsyncCommitGroup => {
                let uncommitted = std::mem::take(&mut self.threads[t].uncommitted);
                self.threads[t].groups.push_back(uncommitted);
                self.graph
                    .group_commit(tix(t), point(pc), GroupFamily::CpAsync);
            }

            LoweredInstr::CpAsyncWaitGroup { n } => {
                let mut landing = Vec::new();
                while self.threads[t].groups.len() > *n as usize {
                    landing.extend(self.threads[t].groups.pop_front().unwrap());
                }
                let ops: Vec<AsyncOpId> = landing.iter().map(|copy| copy.op).collect();
                self.record_group_wait(t, pc, *n, &ops);
                for copy in landing {
                    self.complete_cp_async_copy(t, copy)?;
                }
            }

            LoweredInstr::ShflSync { membermask, .. } => {
                let mask = self.concrete_operand(t, pc, membermask, "shfl.sync membermask")? as u32;
                self.block_at_warp_op(t, pc, mask)?;
                return Ok(());
            }

            LoweredInstr::ElectSync { membermask, .. } => {
                let mask =
                    self.concrete_operand(t, pc, membermask, "elect.sync membermask")? as u32;
                self.block_at_warp_op(t, pc, mask)?;
                return Ok(());
            }

            LoweredInstr::ReduxSync { membermask, .. }
            | LoweredInstr::ReduxSyncBroadcastMax { membermask, .. } => {
                let mask =
                    self.concrete_operand(t, pc, membermask, "redux.sync membermask")? as u32;
                self.block_at_warp_op(t, pc, mask)?;
                return Ok(());
            }

            // Tensor-core operations synchronize the full warp.
            LoweredInstr::Ldmatrix { .. }
            | LoweredInstr::Mma { .. }
            | LoweredInstr::WmmaLoad { .. }
            | LoweredInstr::WmmaStore { .. }
            | LoweredInstr::WmmaMma { .. }
            | LoweredInstr::Stmatrix { .. } => {
                self.block_at_warp_op(t, pc, u32::MAX)?;
                return Ok(());
            }

            // wgmma.mma_async: warpgroup-cooperative (128 threads), not
            // warp-cooperative - no membermask, always the full warpgroup
            // (see `Status::AtWarpgroupOp`'s doc comment).
            LoweredInstr::WgmmaMmaAsync { .. } => {
                self.block_at_warpgroup_op(t, pc)?;
                return Ok(());
            }

            // wgmma.fence/commit_group/wait_group (PTX ISA 9.7.17.7.{1,2,3})
            // are `.sync.aligned`: each thread waits for its whole warp, like
            // tcgen05.wait. Their hazard state stays per-thread.
            LoweredInstr::WgmmaFence
            | LoweredInstr::WgmmaCommitGroup
            | LoweredInstr::WgmmaWaitGroup { .. } => {
                self.block_at_warp_op(t, pc, u32::MAX)?;
                return Ok(());
            }

            // Tensor Memory allocation management: PTX ISA 9.7.17.5 ("Issue
            // Granularity") requires a single warp to collectively issue
            // these, same shape as the tensor-core ops above.
            LoweredInstr::Tcgen05Alloc { .. }
            | LoweredInstr::Tcgen05Dealloc { .. }
            | LoweredInstr::Tcgen05RelinquishAllocPermit
            | LoweredInstr::Tcgen05Ld { .. }
            | LoweredInstr::Tcgen05St { .. }
            | LoweredInstr::Tcgen05Wait { .. } => {
                self.block_at_warp_op(t, pc, u32::MAX)?;
                return Ok(());
            }

            // tcgen05.mma: `.cta_group::1` is issued by a single thread (PTX
            // ISA 9.7.17.5), unlike `mma.sync`/`wmma`, so it is evaluated
            // directly, not through `execute_warp_op`.
            LoweredInstr::Tcgen05Mma {
                kind,
                collector,
                d_tmem_base,
                d_tmem_offset,
                a,
                b_desc,
                idesc,
                disable_output_lane,
                enable_input_d,
            } => {
                self.exec_tcgen05_mma(
                    t,
                    pc,
                    (*kind, *collector),
                    d_tmem_base,
                    *d_tmem_offset,
                    a,
                    b_desc,
                    idesc,
                    disable_output_lane,
                    enable_input_d,
                )?;
            }

            // tcgen05.fence::before_thread_sync/::after_thread_sync: pure
            // ordering fence, no data effect - a genuine no-op under
            // Volta's sequential, non-reordering execution model.
            LoweredInstr::Tcgen05Fence { direction } => {
                let kind = match direction {
                    Tcgen05FenceDirection::BeforeThreadSync => FenceKind::Tcgen05BeforeThreadSync,
                    Tcgen05FenceDirection::AfterThreadSync => FenceKind::Tcgen05AfterThreadSync,
                };
                self.graph.fence(tix(t), point(pc), kind);
            }

            // tcgen05.commit: once this thread's async `tcgen05` ops complete,
            // arrive-on(count=1) the mbarrier (single-thread, like
            // `MbarrierArrive`); that phase then tracks its MMAs.
            LoweredInstr::Tcgen05Commit {
                addr_base,
                addr_offset,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let id = self
                    .shared
                    .read_mbarrier(addr)
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                self.record_mma_commit(t, id);
                self.record_mbarrier_arrival(t, pc, id, (1, 0), ArrivalOrdering::AsyncTracked);
                let before = self.mbarriers.completed_phases(id);
                self.mbarriers.arrive(id, 1, None);
                self.record_mbarrier_progress(id, before);
            }

            // cp.async.mbarrier.arrive: arrive once all this thread's prior
            // `cp.async`s complete; landing them here is one valid schedule.
            // Without `.noinc` the pending count is bumped first (net zero).
            LoweredInstr::CpAsyncMbarrierArrive {
                addr_base,
                addr_offset,
                noinc,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let id = self
                    .shared
                    .read_mbarrier(addr)
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                let thread = &mut self.threads[t];
                let copies: Vec<PendingCopy> = std::mem::take(&mut thread.groups)
                    .into_iter()
                    .flatten()
                    .chain(std::mem::take(&mut thread.uncommitted))
                    .collect();
                for copy in &copies {
                    self.record_tracked_by_mbarrier(copy.op, id, 0);
                }
                for copy in copies {
                    self.complete_cp_async_copy(t, copy)?;
                }
                self.record_mbarrier_arrival(
                    t,
                    pc,
                    id,
                    (u64::from(*noinc), 0),
                    ArrivalOrdering::AsyncTracked,
                );
                let before = self.mbarriers.completed_phases(id);
                self.mbarriers.arrive(id, u64::from(*noinc), None);
                self.record_mbarrier_progress(id, before);
            }

            LoweredInstr::TensormapReplace {
                space,
                addr_base,
                addr_offset,
                field,
            } => {
                self.exec_tensormap_replace(t, pc, *space, addr_base, *addr_offset, field)?;
            }

            LoweredInstr::TensormapCpFenceproxy {
                dst_base,
                dst_offset,
                src_base,
                src_offset,
            } => {
                let dst = self.effective_addr(t, pc, dst_base, *dst_offset)?;
                let src = self.effective_addr(t, pc, src_base, *src_offset)?;
                if self
                    .tensor_maps
                    .copy_entry(MemSpace::Global, dst, MemSpace::Shared, src)
                    .is_none()
                {
                    return Err(EvalError::TensorMapNotFound {
                        thread: t,
                        pc,
                        space: MemSpace::Shared,
                        addr: src,
                    });
                }
            }

            LoweredInstr::FenceProxyTensormap => {}

            LoweredInstr::CpAsyncBulkTensorLoad {
                dst_base,
                dst_offset,
                tensormap_space,
                tensormap_base,
                tensormap_offset,
                coords,
                mbar_base,
                mbar_offset,
            } => {
                self.exec_cp_async_bulk_tensor_load(
                    t,
                    pc,
                    dst_base,
                    *dst_offset,
                    *tensormap_space,
                    tensormap_base,
                    *tensormap_offset,
                    coords,
                    mbar_base,
                    *mbar_offset,
                )?;
            }

            LoweredInstr::CpAsyncBulkLoad {
                dst_base,
                dst_offset,
                src_base,
                src_offset,
                size,
                mbar_base,
                mbar_offset,
            } => {
                let dst = self.effective_addr(t, pc, dst_base, *dst_offset)?;
                let src = self.effective_addr(t, pc, src_base, *src_offset)?;
                let mbar = self.effective_addr(t, pc, mbar_base, *mbar_offset)?;
                self.exec_cp_async_bulk_load(t, pc, dst, src, size, mbar)?;
            }

            LoweredInstr::ClcTryCancel {
                addr_base,
                addr_offset,
                mbar_base,
                mbar_offset,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                let mbar = self.effective_addr(t, pc, mbar_base, *mbar_offset)?;
                self.exec_clc_try_cancel(t, pc, addr, mbar)?;
            }

            LoweredInstr::ClcQueryIsCanceled { dst, response } => {
                self.exec_clc_query_is_canceled(t, pc, *dst, *response)?;
            }

            LoweredInstr::ClcQueryGetFirstCtaid { response } => {
                self.exec_clc_query_get_first_ctaid(t, pc, *response)?;
            }

            // mbarrier: per-thread ops, not warp-cooperative - any single
            // thread issues these independently (unlike the tensor-core
            // family above).
            LoweredInstr::MbarrierInit {
                addr_base,
                addr_offset,
                count,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let count = self.non_negative_operand(t, pc, count, "mbarrier.init count")?;
                let id = self.mbarriers.init(count);
                self.shared
                    .write(addr, 8, Value::Mbarrier(id))
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                self.record_mbarrier_init(t, pc, id, addr, count);
            }

            LoweredInstr::MbarrierInval {
                addr_base,
                addr_offset,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let live = self.shared.read_mbarrier(addr).ok();
                self.shared
                    .invalidate_mbarrier(addr)
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                if let Some(id) = live {
                    self.record_mbarrier_inval(t, pc, id);
                }
            }

            LoweredInstr::MbarrierArrive {
                state,
                addr_base,
                addr_offset,
                count,
                expect_tx,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let id = self
                    .shared
                    .read_mbarrier(addr)
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                let count = match count {
                    Some(op) => self.non_negative_operand(t, pc, op, "mbarrier.arrive count")?,
                    None => 1,
                };
                let expect_tx = match expect_tx {
                    Some(op) => Some(self.non_negative_operand(
                        t,
                        pc,
                        op,
                        "mbarrier.arrive.expect_tx txCount",
                    )?),
                    None => None,
                };
                self.record_mbarrier_arrival(
                    t,
                    pc,
                    id,
                    (count, expect_tx.unwrap_or(0)),
                    ArrivalOrdering::Release,
                );
                let before = self.mbarriers.completed_phases(id);
                self.mbarriers.arrive(id, count, expect_tx);
                self.record_mbarrier_progress(id, before);
                if let Some(dst) = state {
                    // The opaque phase token: only `.parity` waits are
                    // supported, which never consume it, so `Undefined` is the
                    // honest value.
                    let token = self.arena.undefined();
                    self.write_reg(t, pc, *dst, Value::Scalar(token))?;
                }
            }

            LoweredInstr::MbarrierExpectTx {
                addr_base,
                addr_offset,
                tx_count,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let id = self
                    .shared
                    .read_mbarrier(addr)
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                let tx_count =
                    self.non_negative_operand(t, pc, tx_count, "mbarrier.expect_tx txCount")?;
                self.record_mbarrier_expect_tx(t, pc, id, tx_count);
                self.mbarriers.expect_tx(id, tx_count);
            }

            LoweredInstr::MbarrierCompleteTx {
                addr_base,
                addr_offset,
                tx_count,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let id = self
                    .shared
                    .read_mbarrier(addr)
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                let tx_count =
                    self.non_negative_operand(t, pc, tx_count, "mbarrier.complete_tx txCount")?;
                self.record_mbarrier_complete_tx(t, pc, id, tx_count);
                let before = self.mbarriers.completed_phases(id);
                self.mbarriers.complete_tx(id, tx_count);
                self.record_mbarrier_progress(id, before);
            }

            LoweredInstr::MbarrierWaitParity {
                addr_base,
                addr_offset,
                phase_parity,
                ..
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                let id = self
                    .shared
                    .read_mbarrier(addr)
                    .map_err(|e| EvalError::from_mem_access(t, pc, MemSpace::Shared, e))?;
                let phase_parity = match self.concrete_operand(
                    t,
                    pc,
                    phase_parity,
                    "mbarrier wait phaseParity",
                )? {
                    0 => false,
                    1 => true,
                    other => {
                        return Err(EvalError::Unsupported {
                            pc,
                            what: format!("mbarrier wait phaseParity {other} (must be 0 or 1)"),
                        });
                    }
                };
                self.record_mbarrier_wait(t, pc, id, phase_parity);
                self.threads[t].status = Status::AtMbarrier { id, phase_parity };
                return Ok(()); // pc advances when the wait's condition is satisfied
            }

            LoweredInstr::Activemask { dst } => {
                // OR of `1 << lane` over existing, non-exited warp lanes (ISA
                // 9.7.13.11). Exact when converged (divergence is unmodeled);
                // exits depend on the schedule, as on hardware.
                let warp_base = (t.0 / WARP_SIZE) * WARP_SIZE;
                let mut mask: u32 = 0;
                for lane in 0..WARP_SIZE {
                    let tid = warp_base + lane;
                    if tid < self.n_threads && self.threads[ThreadId(tid)].status != Status::Exited
                    {
                        mask |= 1 << lane;
                    }
                }
                let r = self.arena.int(mask as i64);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Trap => {
                return Err(EvalError::TrapReached { thread: t, pc });
            }
        }

        self.threads[t].pc = next_pc;
        Ok(())
    }

    // =====================================================================
    // Operand and register access
    // =====================================================================

    /// Read a register; a never-written one reads `Undefined` (nvcc's `selp`
    /// accumulator-init idiom). Hazard B (PTX ISA 9.7.17.7.3): a still-pending
    /// wgmma register is UB to read.
    pub(in crate::eval) fn read_reg(
        &self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
    ) -> EvalResult<Value> {
        self.check_wgmma_pending(t, pc, reg)?;
        Ok(self.threads[t]
            .regs
            .read(reg)
            .unwrap_or(Value::Scalar(self.undefined)))
    }

    /// Write a register - the one chokepoint for register writes. Applies
    /// hazard B's pending check and hazard A's bookkeeping (any ordinary write
    /// breaks a wgmma chain and dirties the fence gate).
    pub(in crate::eval) fn write_reg(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
        value: Value,
    ) -> EvalResult<()> {
        self.check_wgmma_pending(t, pc, reg)?;
        self.threads[t].regs.write(reg, value);
        self.threads[t].wgmma.record_write(reg, pc);
        Ok(())
    }

    /// Resolve an operand to a runtime value.
    pub(in crate::eval) fn operand_value(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: &Operand,
    ) -> EvalResult<Value> {
        match op {
            Operand::Reg(reg) => self.read_reg(t, pc, *reg),
            Operand::SpecialReg(kind) => Ok(Value::Scalar(self.special_reg(t, pc, *kind)?)),
            Operand::ImmI64(v) => Ok(Value::Scalar(self.arena.int(*v))),
            Operand::ImmU64(v) => Ok(Value::Scalar(self.arena.int(*v as i64))),
            // Exact ingestion. Lowering rejects NaN literals, so this only
            // fails if an unvetted immediate slips past it - loudly.
            Operand::ImmF64(v) => match self.arena.float_from_f64(*v) {
                Ok(e) => Ok(Value::Scalar(e)),
                Err(err) => Err(EvalError::Unsupported {
                    pc,
                    what: format!("float immediate: {}", err),
                }),
            },
        }
    }

    /// [`Self::scalar_operand`] at float type `ty`: a concrete integer is
    /// decoded as raw bits ([`float_bits::decode_float_bits`]). For inline
    /// float nodes (`copysign`, scalar `fma`).
    fn float_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: &Operand,
        ty: ScalarType,
    ) -> EvalResult<ExprId> {
        // A non-float `ty` (or a packed pair, whose lanes `pair_operand`
        // decodes) would pass a raw bit pattern through undecoded.
        assert!(
            ty.is_float() && !ty.is_packed_pair(),
            "float_operand at non-scalar-float type {ty:?}"
        );
        let e = self.scalar_operand(t, pc, op)?;
        float_bits::decode_float_bits(&mut self.arena, pc, ty, e)
    }

    /// Resolve an operand that must be a scalar.
    pub(in crate::eval) fn scalar_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: &Operand,
    ) -> EvalResult<ExprId> {
        match self.operand_value(t, pc, op)? {
            Value::Scalar(e) => Ok(e),
            Value::Pair(lo, hi) => {
                // A `mov.bN dst, {lo, hi}` pack of two concrete integer halves
                // read as one wide scalar: recombine the bits exactly. A pair
                // of real lanes has no scalar reading.
                let half_bits = match op {
                    Operand::Reg(reg) => match reg.class {
                        RegClass::Bits64 => Some(32u32),
                        RegClass::Bits32 => Some(16u32),
                        _ => None,
                    },
                    _ => None,
                };
                if let (Some(w), Some(l), Some(h)) = (
                    half_bits,
                    self.arena.as_int_const(lo),
                    self.arena.as_int_const(hi),
                ) {
                    return Ok(Self::recombine_pair_halves(&mut self.arena, l, h, w));
                }
                Err(EvalError::ValueKindMismatch {
                    thread: t,
                    pc,
                    what: "packed pair used as a scalar",
                })
            }
            Value::Quad(..) => Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "packed byte-quad used as a scalar",
            }),
            Value::Mbarrier(_) => Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "mbarrier handle used as a scalar",
            }),
        }
    }

    /// Recombine two concrete integer halves into one wide scalar, `lo` in the
    /// low `half_bits` bits. Takes the arena directly so `extract_outputs` can
    /// call it while borrowing the config.
    fn recombine_pair_halves(arena: &mut ExprArena, lo: i64, hi: i64, half_bits: u32) -> ExprId {
        let mask = (1i64 << half_bits) - 1;
        arena.int(((hi & mask) << half_bits) | (lo & mask))
    }

    /// Resolve a packed-pair operand (`.f16x2`/`.bf16x2`). A concrete scalar is
    /// decoded bit-for-bit into its two lanes (e.g. `mov.b32 %r, 0`); a
    /// symbolic scalar or a NaN half is an error.
    pub(in crate::eval) fn pair_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: &Operand,
        lane_ty: ScalarType,
    ) -> EvalResult<(ExprId, ExprId)> {
        match self.operand_value(t, pc, op)? {
            Value::Pair(lo, hi) => Ok((lo, hi)),
            Value::Scalar(e) => {
                let bits = self.arena.as_i64(e).ok_or(EvalError::ValueKindMismatch {
                    thread: t,
                    pc,
                    what: "symbolic scalar used as a packed pair",
                })? as u64;
                let (lo_v, hi_v) =
                    decode_packed_bits(bits, lane_ty).ok_or_else(|| EvalError::Unsupported {
                        pc,
                        what: "NaN half in a packed-pair bit pattern".to_string(),
                    })?;
                let lo = self
                    .arena
                    .float_from_f64(lo_v)
                    .map_err(|e| EvalError::Unsupported {
                        pc,
                        what: format!("packed-pair lane constant: {}", e),
                    })?;
                let hi = self
                    .arena
                    .float_from_f64(hi_v)
                    .map_err(|e| EvalError::Unsupported {
                        pc,
                        what: format!("packed-pair lane constant: {}", e),
                    })?;
                Ok((lo, hi))
            }
            Value::Quad(..) => Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "packed byte-quad used as a packed pair",
            }),
            Value::Mbarrier(_) => Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "mbarrier handle used as a packed pair",
            }),
        }
    }

    /// Resolve an operand that must be a concrete integer.
    pub(in crate::eval) fn concrete_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: &Operand,
        what: &'static str,
    ) -> EvalResult<i64> {
        let e = self.scalar_operand(t, pc, op)?;
        self.arena.as_i64(e).ok_or(EvalError::NotConcrete {
            thread: t,
            pc,
            what,
        })
    }

    /// Resolve an operand that must be a concrete, non-negative integer
    /// (the mbarrier family's 32-bit unsigned `count`/`txCount` operands).
    pub(in crate::eval) fn non_negative_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: &Operand,
        what: &'static str,
    ) -> EvalResult<u64> {
        let v = self.concrete_operand(t, pc, op, what)?;
        u64::try_from(v).map_err(|_| EvalError::Unsupported {
            pc,
            what: format!("{what} is negative ({v})"),
        })
    }

    fn as_concrete_bool(
        &self,
        t: ThreadId,
        pc: InstrId,
        value: Value,
        what: &'static str,
    ) -> EvalResult<bool> {
        let Value::Scalar(e) = value else {
            return Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "packed pair used as a predicate",
            });
        };
        self.arena.as_bool(e).ok_or(EvalError::NotConcrete {
            thread: t,
            pc,
            what,
        })
    }

    /// The (x, y, z) thread indices of a linear thread id.
    fn thread_coords(&self, t: ThreadId) -> (u32, u32, u32) {
        let (bx, by, _) = self.config.block_dim;
        (t.0 % bx, (t.0 / bx) % by, t.0 / (bx * by))
    }

    fn special_reg(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        kind: SpecialRegKind,
    ) -> EvalResult<ExprId> {
        let (x, y, z) = self.thread_coords(t);
        let v = match kind {
            SpecialRegKind::TidX => x as i64,
            SpecialRegKind::TidY => y as i64,
            SpecialRegKind::TidZ => z as i64,
            SpecialRegKind::NtidX => self.config.block_dim.0 as i64,
            SpecialRegKind::NtidY => self.config.block_dim.1 as i64,
            SpecialRegKind::NtidZ => self.config.block_dim.2 as i64,
            // The CTA under analysis is always block (0,0,0) (paper: CTAs
            // are checked pairwise at block 0).
            SpecialRegKind::CtaidX | SpecialRegKind::CtaidY | SpecialRegKind::CtaidZ => 0,
            SpecialRegKind::NctaidX => self.config.grid_dim.0 as i64,
            SpecialRegKind::NctaidY => self.config.grid_dim.1 as i64,
            SpecialRegKind::NctaidZ => self.config.grid_dim.2 as i64,
            // Every cluster is assumed to hold exactly one CTA, so the CTA is
            // rank 0 of its cluster and the cluster grid is the CTA grid.
            SpecialRegKind::ClusterCtaidX
            | SpecialRegKind::ClusterCtaidY
            | SpecialRegKind::ClusterCtaidZ
            | SpecialRegKind::ClusterCtarank
            | SpecialRegKind::ClusteridX
            | SpecialRegKind::ClusteridY
            | SpecialRegKind::ClusteridZ => 0,
            SpecialRegKind::ClusterNctaidX
            | SpecialRegKind::ClusterNctaidY
            | SpecialRegKind::ClusterNctaidZ
            | SpecialRegKind::ClusterNctarank => 1,
            SpecialRegKind::NclusteridX => self.config.grid_dim.0 as i64,
            SpecialRegKind::NclusteridY => self.config.grid_dim.1 as i64,
            SpecialRegKind::NclusteridZ => self.config.grid_dim.2 as i64,
            // A launch without cluster dimensions runs in implicit 1x1x1 clusters.
            SpecialRegKind::IsExplicitCluster => return Ok(self.arena.bool_val(false)),
            SpecialRegKind::LaneId => (t.0 % WARP_SIZE) as i64,
            SpecialRegKind::WarpId => (t.0 / WARP_SIZE) as i64,
            SpecialRegKind::NWarpId => self.n_threads.div_ceil(WARP_SIZE) as i64,
            SpecialRegKind::DynamicSmemSize => self.config.dynamic_shared_bytes as i64,
            other => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!("special register {}", other.as_str()),
                });
            }
        };
        Ok(self.arena.int(v))
    }

    // =====================================================================
    // Memory access
    // =====================================================================

    /// Concrete effective address `base + offset`, u64 mod 2^64 as on hardware.
    /// A wrapped sum is just an address that `check_bounds` rejects; a checked
    /// i64 sum would guard the wrong boundary.
    pub(in crate::eval) fn effective_addr(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        base: &Operand,
        offset: i64,
    ) -> EvalResult<u64> {
        let base = self.concrete_operand(t, pc, base, "memory address")?;
        Ok((base as u64).wrapping_add(offset as u64))
    }

    /// Ownership containment: the region owning the first byte must contain the
    /// whole access, so overrunning into an adjacent array is `OutOfBounds`
    /// (paper §6.2). Regions never overlap, so the owner is unique.
    pub(in crate::eval) fn check_bounds(
        &self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
    ) -> EvalResult<()> {
        let regions = match space {
            MemSpace::Global => &self.regions.global,
            MemSpace::Shared => &self.regions.shared,
            MemSpace::Local => &self.regions.local,
            MemSpace::Param | MemSpace::Const => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!("{:?}-space memory access", space),
                });
            }
        };
        match regions.iter().find(|r| r.owns(addr)) {
            Some(owner) if owner.contains(addr, width) => Ok(()),
            _ => Err(EvalError::OutOfBounds {
                thread: t,
                pc,
                space,
                addr,
                width,
            }),
        }
    }

    /// Natural alignment (PTX ISA 6.4.1: misaligned access is undefined),
    /// rejected loudly. `required` is the access size for scalars, the total
    /// size for vectors, the fragment alignment for tensor-core ops.
    pub(in crate::eval) fn check_alignment(
        &self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        required: u64,
    ) -> EvalResult<()> {
        if addr.is_multiple_of(required) {
            Ok(())
        } else {
            Err(EvalError::Misaligned {
                thread: t,
                pc,
                space,
                addr,
                required,
            })
        }
    }

    /// Bounds-check and read memory. Never-written in-bounds bytes read
    /// `Undefined` (the paper's motivating example relies on this).
    pub(in crate::eval) fn mem_read(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
    ) -> EvalResult<Value> {
        self.mem_read_from(t, pc, space, addr, width, AccessOrigin::Thread)
    }

    /// [`Self::mem_read`] performed for `origin`, which the event graph records.
    pub(in crate::eval) fn mem_read_from(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
        origin: AccessOrigin,
    ) -> EvalResult<Value> {
        self.check_bounds(t, pc, space, addr, width)?;
        // Every program access flows through here, so this is the one
        // natural-alignment chokepoint. Param space never reaches it
        // (`check_bounds` rejects it; `LoadParam` is not memory).
        self.check_alignment(t, pc, space, addr, width)?;
        self.record_mem_access(t, pc, space, addr, width, None, origin);
        let memory = match space {
            MemSpace::Global => &self.global,
            MemSpace::Shared => &self.shared,
            MemSpace::Local => &self.locals[t],
            _ => unreachable!("bounds check rejects other spaces"),
        };
        match memory.read(addr, width) {
            Ok(v) => Ok(v),
            Err(MemAccessError::Reinterpret {
                found: Some((start, found_width, GranuleKind::Scalar)),
                ..
            }) if self.split_concrete_scalar(space, t, start, found_width, addr, width) => self
                .memory_mut(space, t)
                .read(addr, width)
                .map_err(|e| EvalError::from_mem_access(t, pc, space, e)),
            Err(MemAccessError::Uninitialized { .. }) if space == MemSpace::Global => {
                // Reading an input array materializes its symbols on demand.
                if self.materialize_input(addr, width) {
                    self.global
                        .read(addr, width)
                        .map_err(|e| EvalError::from_mem_access(t, pc, space, e))
                } else {
                    Ok(Value::Scalar(self.arena.undefined()))
                }
            }
            // A partially materialized input array: materialize just the absent
            // elements and retry, so the combine rules compose the access. A
            // genuine reinterpretation materializes nothing and stays an error.
            Err(MemAccessError::Reinterpret { .. })
                if space == MemSpace::Global && self.materialize_input(addr, width) =>
            {
                self.global
                    .read(addr, width)
                    .map_err(|e| EvalError::from_mem_access(t, pc, space, e))
            }
            Err(MemAccessError::Uninitialized { .. }) if space == MemSpace::Shared => {
                Ok(Value::Scalar(self.arena.undefined()))
            }
            Err(e) => Err(EvalError::from_mem_access(t, pc, space, e)),
        }
    }

    /// Create the input-element symbols for every input-array element
    /// overlapping `[addr, addr + width)` that is not yet present in
    /// global memory. Returns whether any element was materialized.
    fn materialize_input(&mut self, addr: u64, width: u64) -> bool {
        // Collect missing elements first, since the array list borrows the
        // config: (addr, width, index, array name interned once, or None for
        // identity indices).
        let mut missing: Vec<(u64, u64, u64, Option<StringId>)> = Vec::new();
        for array in &self.config.arrays {
            if !array.kind.is_input() {
                continue;
            }
            // Overlap of [addr, addr+width) with [base, base+size), in
            // subtraction form so neither sum is formed: the intervals
            // overlap iff each start lies short of the other end.
            let size = array.size_bytes();
            let overlaps = if addr >= array.base {
                addr - array.base < size
            } else {
                array.base - addr < width
            };
            if !overlaps {
                continue;
            }
            // Both sums below are exact: `addr + width` fits in its region and
            // the array's end fits in u64 (`AnalysisConfig::validate`), so with
            // width >= 1 neither `- 1` can wrap.
            let end = array.base + size;
            let first = (addr.max(array.base) - array.base) / array.elem_width;
            let last = ((addr + width - 1).min(end - 1) - array.base) / array.elem_width;
            let mut array_sid: Option<StringId> = None;
            for i in first..=last {
                let elem_addr = array.base + i * array.elem_width;
                if !self.global.has_cell_at(elem_addr) {
                    let value = match array.kind {
                        crate::config::ArrayKind::IndexInput => None,
                        _ => Some(
                            *array_sid.get_or_insert_with(|| self.arena.intern_string(&array.name)),
                        ),
                    };
                    missing.push((elem_addr, array.elem_width, i, value));
                }
            }
        }

        // Analysis-setup placement, not a PTX access, so no alignment check;
        // granules are naturally aligned because `validate` requires bases to
        // be multiples of the element width.
        let mut any = false;
        for (elem_addr, elem_width, index, array_sid) in missing {
            let value = match array_sid {
                Some(sid) => self.arena.input_element(sid, index),
                // Identity index array: element i holds the value i.
                None => self.arena.int(index as i64),
            };
            if self
                .global
                .init(elem_addr, elem_width, Value::Scalar(value))
                .is_ok()
            {
                any = true;
            }
        }
        any
    }

    /// Bounds-check and write memory.
    pub(in crate::eval) fn mem_write(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
        value: Value,
    ) -> EvalResult<()> {
        self.mem_write_from(t, pc, space, addr, width, value, AccessOrigin::Thread)
    }

    /// [`Self::mem_write`] performed for `origin`, which the event graph records.
    #[allow(clippy::too_many_arguments)]
    pub(in crate::eval) fn mem_write_from(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
        value: Value,
        origin: AccessOrigin,
    ) -> EvalResult<()> {
        self.check_bounds(t, pc, space, addr, width)?;
        // See `mem_read`: the write-side natural-alignment chokepoint.
        self.check_alignment(t, pc, space, addr, width)?;
        self.record_mem_access(t, pc, space, addr, width, Some(value), origin);
        let memory = self.memory_mut(space, t);
        match memory.write(addr, width, value) {
            Err(MemAccessError::Reinterpret {
                found: Some((start, found_width, GranuleKind::Scalar)),
                ..
            }) if self.split_concrete_scalar(space, t, start, found_width, addr, width) => self
                .memory_mut(space, t)
                .write(addr, width, value)
                .map_err(|e| EvalError::from_mem_access(t, pc, space, e)),
            result => result.map_err(|e| EvalError::from_mem_access(t, pc, space, e)),
        }
    }

    fn memory_mut(&mut self, space: MemSpace, t: ThreadId) -> &mut Memory {
        match space {
            MemSpace::Global => &mut self.global,
            MemSpace::Shared => &mut self.shared,
            MemSpace::Local => &mut self.locals[t],
            _ => unreachable!("bounds check rejects other spaces"),
        }
    }

    /// Split the concrete scalar granule at `start` into exact halves, toward
    /// the access, until `[addr, addr + width)` is a granule of its own;
    /// returns whether it was. Symbolic scalars cannot split.
    fn split_concrete_scalar(
        &mut self,
        space: MemSpace,
        t: ThreadId,
        start: u64,
        found_width: u64,
        addr: u64,
        width: u64,
    ) -> bool {
        if width >= found_width
            || !(found_width / width).is_power_of_two()
            || addr < start
            || addr + width > start + found_width
            || !(addr - start).is_multiple_of(width)
        {
            return false;
        }
        let (mut start, mut found_width) = (start, found_width);
        while found_width > width {
            let Some((_, e, _)) = self.memory_mut(space, t).scalar_cell(start) else {
                return false;
            };
            let Some(c) = self.arena.as_int_const(e) else {
                return false;
            };
            let half = found_width / 2;
            let half_bits = (half * 8) as u32;
            let mask = if half_bits >= 64 {
                -1
            } else {
                (1i64 << half_bits) - 1
            };
            let lo = self.arena.int(c & mask);
            let hi = self.arena.int((c >> half_bits) & mask);
            self.memory_mut(space, t).split_scalar(start, lo, hi);
            if addr >= start + half {
                start += half;
            }
            found_width = half;
        }
        true
    }
}

/// Bit width of a register's storage class.
pub(in crate::eval) fn reg_bits(reg: RegId) -> u32 {
    (reg.class.size_bytes() * 8) as u32
}

/// Bit width of the register behind `op`, if it is a register operand.
/// Immediates and special registers resolve to concrete values, which
/// never trip the symbolic sub-register-width store policy.
fn operand_reg_bits(op: &Operand) -> Option<u32> {
    match op {
        Operand::Reg(r) => Some(reg_bits(*r)),
        _ => None,
    }
}
