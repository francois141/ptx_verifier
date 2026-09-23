//! The interpreter: round-robin symbolic execution with χ-context race
//! detection (paper Sections 3 and 5).
//!
//! Each thread runs until it blocks (barrier or warp-cooperative op) or
//! exits; then the next ready thread runs. When no thread is ready, complete
//! barrier/warp groups fire; if none can, the program is deadlocked. By the
//! confluence theorem, this particular schedule is as good as any other.

use std::collections::{HashMap, VecDeque};

use id_collections::IdVec;

use volta_frontend::ast::{ClampWrapMode, ScalarType, ShiftDir};

use crate::equiv::EquivSession;
use crate::eval::config::{AnalysisConfig, ParamValue};
use crate::eval::error::{AccessSite, EvalError, EvalResult};
use crate::eval::fp8;
use crate::eval::mbarrier::MbarrierTable;
use crate::eval::memory::{GranuleKind, MemAccessError, Memory};
use crate::eval::race::{MemHazard, Proxy, RaceTracker};
use crate::eval::target::TargetFeatures;
use crate::eval::tcgen05_mma::{self, Major, OperandFormat};
use crate::eval::tensor_map_table::{self, TensorMapTable};
use crate::eval::tensor_memory::TensorMemory;
use crate::eval::value::{MbarrierId, RegFile, Value};
use crate::eval::{ThreadId, WARP_SIZE, WARPGROUP_SIZE};
use crate::logging::{info, trace, warn};
use crate::lowered::{
    BinOp, Clamp, CmpOp, CpAsyncSrcSize, InstrId, LoweredInstr, LoweredProgram, MemSpace, Operand,
    Tcgen05MmaKind, UnaryOp,
};
use crate::symbolic::{ExprArena, ExprId, ExprNode, Real, StringId, structurally_equal};
use crate::symbols::{MODULE_GLOBAL_BASE, ParamId, RegId, SpecialRegKind};
use crate::tensor_core::MmaShape;
use crate::tensor_map::{TensorFillMode, TensormapFieldWrite};
use crate::types::{RegClass, ScalarTypeExt};

/// Per-array output footprint: `(array name, [(element index, value)])`.
pub type OutputFootprints = Vec<(String, Vec<(u64, ExprId)>)>;

/// Which 16-bit half of a `.b32` funnel-shift operand to read.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum LaneHalf {
    Low,
    High,
}

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

/// Scheduling status of one thread.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(in crate::eval) enum Status {
    Ready,
    /// Blocked at `bar.sync id` (at the current pc)
    AtBarrier {
        id: u32,
    },
    /// Blocked at a warp-cooperative instruction at the current pc.
    /// `mask` is the participating-lane mask within the thread's warp.
    AtWarpOp {
        mask: u32,
    },
    /// Blocked at a warpgroup-cooperative instruction (`wgmma.mma_async`)
    /// at the current pc. No mask field: unlike `AtWarpOp`, the ISA gives
    /// `wgmma.mma_async` no membermask operand at all - its mandatory
    /// `.aligned` qualifier means it always involves the full,
    /// unconditional 128-thread warpgroup (PTX ISA 9.7.17.1). A parallel,
    /// additive mechanism to `AtWarpOp` (see `eval::warpgroup`'s module
    /// doc), not a widening of it - `AtWarpOp`'s 32-bit mask is
    /// load-bearing for every other warp-collective op.
    AtWarpgroupOp,
    /// Blocked at `mbarrier.test_wait.parity`/`try_wait.parity` (at the
    /// current pc), waiting for `id`'s phase-parity condition. Unlike
    /// `AtBarrier`/`AtWarpOp`, this isn't a rendezvous - any other thread's
    /// `arrive`/`complete_tx` on the same object can satisfy it, so threads
    /// blocked here are checked independently, not as a group.
    AtMbarrier {
        id: MbarrierId,
        phase_parity: bool,
    },
    Exited,
}

/// One `cp.async` copy issued but not yet completed: its value is captured
/// eagerly at issue time, but the write into `shared` is deferred until
/// `cp.async.wait_group` releases the group it's committed into.
#[derive(Debug, Clone)]
struct PendingCopy {
    dst_addr: u64,
    src_addr: u64,
    /// Total slot width in bytes (always 4, 8, or 16).
    cp_size: u64,
    /// How many bytes of `src_addr` were actually locked/read (<= cp_size,
    /// zero if `ignore-src` held).
    real_bytes: u64,
    /// One resolved value per 4-byte word (`cp_size / 4` entries), already
    /// zero-filled where the source's real-byte prefix didn't cover it.
    words: Vec<Value>,
    /// The issuing `cp.async` instruction, for lock diagnostics and as the
    /// attributed pc of the deferred write.
    pc: InstrId,
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
    /// `wgmma.mma_async` register-hazard tracking (PTX ISA
    /// 9.7.17.7.1/.2/.3) - a separate domain and instruction family from
    /// `uncommitted`/`groups` above, so kept as its own field rather than
    /// reused.
    wgmma: WgmmaRegState,
}

/// One `wgmma.mma_async` accumulator writeback not yet released by a
/// covering `wgmma.wait_group`. Unlike `PendingCopy`, the write already
/// landed eagerly in the register file (Volta's evaluation is
/// sequential - there is no deferred value to hold), so just the register
/// is kept - the issuing pc for hazard diagnostics lives in `pending`'s
/// own map value, not duplicated here.
type PendingWgmmaAccum = RegId;

/// Per-thread `wgmma.mma_async` register-hazard state (PTX ISA
/// 9.7.17.7). Lives on `ThreadState`, not `RaceTracker`: unlike shared/
/// global memory (which needs χ's per-byte, cross-thread `FixedBitSet`),
/// registers are inherently thread-local - nothing here ever reads
/// another thread's state.
#[derive(Debug, Default)]
struct WgmmaRegState {
    /// Hazard A (`wgmma.fence`, 9.7.17.7.1): incremented by every
    /// `wgmma.fence` this thread executes.
    fence_epoch: u64,
    /// Hazard A: `(fence_epoch, pc)` as of each register's most recent
    /// write. Absent = never written by this thread = treated as epoch
    /// 0 - this is what makes "before the first `wgmma.mma_async` in a
    /// warpgroup" fire correctly even for a register nothing has touched
    /// yet.
    reg_epoch: HashMap<RegId, (u64, InstrId)>,
    /// Hazard A: present, with the shape used, iff the register's most
    /// recent write was a `wgmma.mma_async` accumulator writeback of
    /// that shape. Removed by every ordinary write (`write_reg` - breaks
    /// the chain); overwritten (not removed) by another `wgmma.mma_async`
    /// writeback, possibly of a different shape.
    reg_shape: HashMap<RegId, MmaShape>,
    /// Hazard B (`wgmma.wait_group`, 9.7.17.7.3): accumulator writebacks
    /// since the last `wgmma.commit_group`, not yet sealed into a group.
    uncommitted: Vec<PendingWgmmaAccum>,
    /// Hazard B: committed wgmma-groups, oldest first; `wgmma.wait_group
    /// N` pops from the front while more than `N` remain.
    groups: VecDeque<Vec<PendingWgmmaAccum>>,
    /// Hazard B: reference count + most recent issuing pc, per register,
    /// summed across `uncommitted` and every group in `groups` - lets
    /// `read_reg`/`write_reg` (the hottest path in the evaluator) answer
    /// "is this register pending" in O(1) without rescanning every
    /// outstanding group on every register access. A reference count
    /// (not a plain set) because a register can legitimately appear in
    /// more than one outstanding group (two interleaved same-shape
    /// chains sharing an accumulator tile before either is waited) -
    /// releasing the older group must not clear pending status the
    /// other occurrence still needs.
    pending: HashMap<RegId, (u32, InstrId)>,
}

impl WgmmaRegState {
    /// Hazard B: `Some(prior_pc)` iff `reg` is still pending a
    /// `wgmma.wait_group` release.
    fn pending_since(&self, reg: RegId) -> Option<InstrId> {
        self.pending
            .get(&reg)
            .filter(|&&(count, _)| count > 0)
            .map(|&(_, pc)| pc)
    }

    /// Hazard A: true iff a `wgmma.mma_async` of `shape` may access `reg`
    /// (as its accumulator) without needing an intervening
    /// `wgmma.fence` - either `reg`'s most recent write was itself a
    /// same-shape `wgmma.mma_async` writeback (the ISA's one exemption),
    /// or a `wgmma.fence` has executed since `reg`'s most recent write
    /// (or since this thread started, for a register never written at
    /// all).
    fn is_fenced_for(&self, reg: RegId, shape: MmaShape) -> bool {
        if self.reg_shape.get(&reg) == Some(&shape) {
            return true;
        }
        let last_write_epoch = self.reg_epoch.get(&reg).map(|&(e, _)| e).unwrap_or(0);
        self.fence_epoch > last_write_epoch
    }

    /// The pc of `reg`'s most recent write, if any - for a hazard-A
    /// error's `prior_write` (`None` means never written by this thread).
    fn last_write_pc(&self, reg: RegId) -> Option<InstrId> {
        self.reg_epoch.get(&reg).map(|&(_, pc)| pc)
    }

    /// Record an ordinary (non-`wgmma.mma_async`) write: resets `reg`'s
    /// fence gate to "dirty as of now" and breaks any same-shape chain.
    fn record_write(&mut self, reg: RegId, pc: InstrId) {
        self.reg_epoch.insert(reg, (self.fence_epoch, pc));
        self.reg_shape.remove(&reg);
    }

    /// Record a `wgmma.mma_async` accumulator writeback: same fence
    /// bookkeeping as `record_write`, but tags `reg` with `shape` (so a
    /// later same-shape chained `wgmma.mma_async` is fence-exempt) and
    /// marks it pending a `wgmma.wait_group` release.
    fn record_wgmma_write(&mut self, reg: RegId, shape: MmaShape, pc: InstrId) {
        self.reg_epoch.insert(reg, (self.fence_epoch, pc));
        self.reg_shape.insert(reg, shape);
        self.uncommitted.push(reg);
        let entry = self.pending.entry(reg).or_insert((0, pc));
        entry.0 += 1;
        entry.1 = pc;
    }

    /// `wgmma.fence`: establishes an ordering point for every register.
    fn fence(&mut self) {
        self.fence_epoch += 1;
    }

    /// `wgmma.commit_group`: seals this thread's uncommitted accumulator
    /// writebacks into a new wgmma-group.
    fn commit_group(&mut self) {
        let sealed = std::mem::take(&mut self.uncommitted);
        self.groups.push_back(sealed);
    }

    /// `wgmma.wait_group N`: releases wgmma-groups past the `N` most
    /// recent.
    fn wait_group(&mut self, n: u32) {
        while self.groups.len() > n as usize {
            let group = self.groups.pop_front().unwrap();
            for reg in group {
                if let Some((count, _)) = self.pending.get_mut(&reg) {
                    *count -= 1;
                    if *count == 0 {
                        self.pending.remove(&reg);
                    }
                }
            }
        }
    }
}

/// A contiguous validity region within one memory space.
#[derive(Debug, Clone)]
struct Region {
    base: u64,
    size: u64,
}

impl Region {
    /// Whole-access containment, in subtraction form: no sum here can
    /// overflow in any build profile. The additive form
    /// `addr + width <= base + size` wraps for addresses near `u64::MAX`
    /// (e.g. a negative index reaching `effective_addr`) and in release
    /// mode silently *accepts* the wrapped access; verification-relevant
    /// checks must not rely on debug overflow panics.
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

/// Result of a completed analysis.
#[derive(Debug)]
pub struct AnalysisOutput {
    pub arena: ExprArena,
    /// Output arrays: (name, written elements as (index, expression)),
    /// sorted by index. Only elements the kernel wrote appear.
    pub outputs: Vec<(String, Vec<(u64, ExprId)>)>,
    pub stats: Stats,
    /// Instructions executed, broken down by kind (`LoweredInstr::kind_name`)
    /// summed across all threads. A `BTreeMap` keeps printed/exported tables
    /// in deterministic order.
    pub op_counts: std::collections::BTreeMap<&'static str, u64>,
}

pub struct Interpreter<'p> {
    pub(in crate::eval) program: &'p LoweredProgram,
    pub(in crate::eval) arena: ExprArena,
    config: AnalysisConfig,
    n_threads: u32,
    /// Shared `Undefined` node returned for reads of never-written
    /// registers (see `read_reg`).
    undefined: ExprId,
    params: IdVec<ParamId, Value>,
    pub(in crate::eval) threads: IdVec<ThreadId, ThreadState>,
    pub(in crate::eval) global: Memory,
    pub(in crate::eval) shared: Memory,
    locals: IdVec<ThreadId, Memory>,
    pub(in crate::eval) tensor: TensorMemory,
    regions: MemRegions,
    pub(in crate::eval) race: RaceTracker,
    pub(in crate::eval) mbarriers: MbarrierTable,
    pub(in crate::eval) tensor_maps: TensorMapTable,
    pub(in crate::eval) stats: Stats,
    /// Per-kind instruction counts, indexed by `LoweredInstr::kind_index`.
    /// A fixed array (not a map) because this is bumped once per executed
    /// instruction in `step`, the interpreter's innermost loop; `finish`
    /// folds it into the `BTreeMap` shape `AnalysisOutput` exposes.
    pub(in crate::eval) op_counts: [u64; crate::lowered::KIND_COUNT],
    /// The analyzed module's target-arch-derived feature gates (see
    /// `eval::target::TargetFeatures`) - a fact about the module, computed
    /// once by the caller, not user launch config.
    features: TargetFeatures,
}

impl<'p> Interpreter<'p> {
    pub fn new(
        program: &'p LoweredProgram,
        config: AnalysisConfig,
        features: TargetFeatures,
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
        let declared = program.symbols.params();
        if declared.len() != config.params.len() {
            return Err(EvalError::Config {
                message: format!(
                    "kernel declares {} parameters but {} were provided",
                    declared.len(),
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

        // Build validity regions. Every region must satisfy
        // `base + size <= u64::MAX` (checked here, release-active): with
        // that invariant and the subtraction-form `Region::contains`, any
        // access that passes `check_bounds` has `addr + width` within u64
        // range, so the byte-range loops downstream (race recording, input
        // materialization, memory granules, vector element addressing)
        // can never wrap. The argument needs nothing from the address
        // itself - `effective_addr` produces arbitrary, possibly wrapped
        // u64s - only that ownership is checked before any of those loops
        // run, which `mem_read`/`mem_write` and the whole-footprint checks
        // at the vector/tensor-core sites guarantee.
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
        // Config arrays and module-scope globals share the one global
        // region list built below. `config.validate()` keeps the arrays
        // pairwise disjoint and the symbol-table packer keeps the module
        // globals pairwise disjoint, so the only possible cross-family
        // overlap is an array intersecting the reserved module-global
        // window - reject it here to uphold the region-disjointness
        // premise of `check_bounds` (an overlapping array would silently
        // shadow the module global it covers). The window end cannot
        // overflow: `declare_global_var` checks `MODULE_GLOBAL_BASE +
        // offset + size` for every variable it places. Shared and local
        // variables cannot collide with config arrays by construction:
        // they are packed in their own address spaces, and `check_bounds`
        // consults only the accessed `MemSpace`'s region list, so no
        // check is needed for them.
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
            // Analysis-setup placement, not a PTX memory instruction, so
            // the natural-alignment rule does not apply; the address is
            // naturally aligned anyway (`declare_global_var` packs with
            // `align_up` from the naturally-aligned `MODULE_GLOBAL_BASE`).
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
            regions,
            race: RaceTracker::new(n_threads as usize),
            mbarriers: MbarrierTable::new(n_threads as usize),
            tensor_maps: TensorMapTable::new(),
            stats: Stats::default(),
            op_counts: [0; crate::lowered::KIND_COUNT],
            features,
        })
    }

    /// Run to completion (all threads exited) or an analysis error.
    pub fn run(&mut self) -> EvalResult<()> {
        loop {
            match self.next_ready() {
                Some(t) => self.run_thread(t)?,
                None => {
                    if self.threads.values().all(|t| t.status == Status::Exited) {
                        info!(
                            "execution complete: {} instructions, {} block syncs, {} warp syncs",
                            self.stats.instructions, self.stats.block_syncs, self.stats.warp_syncs
                        );
                        return Ok(());
                    }
                    if !self.try_fire()? {
                        return Err(self.deadlock_error());
                    }
                }
            }
        }
    }

    /// Extract the kernel's output footprint: for each output array, every
    /// element the program actually wrote (a single CTA typically writes
    /// only its tile of a large output tensor). Elements are keyed by index
    /// so two kernels' footprints can be compared exactly.
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
                // A `mov.bN dst, {lo, hi}` pack of two concrete integer
                // halves stored as one wide element (an integer assembled
                // from two parts) is that integer, recombined here the same
                // way `scalar_operand` does for register reads.
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

    /// Consume the interpreter, producing the analysis output.
    pub fn into_output(mut self) -> EvalResult<AnalysisOutput> {
        let outputs = self.extract_outputs()?;
        let op_counts = self
            .op_counts
            .iter()
            .enumerate()
            .filter(|&(_, &count)| count > 0)
            .map(|(i, &count)| (crate::lowered::KIND_NAMES[i], count))
            .collect();
        Ok(AnalysisOutput {
            arena: self.arena,
            outputs,
            stats: self.stats,
            op_counts,
        })
    }

    pub fn stats(&self) -> Stats {
        self.stats
    }

    // =====================================================================
    // Scheduling
    // =====================================================================

    fn next_ready(&self) -> Option<ThreadId> {
        self.threads
            .iter()
            .find(|(_, t)| t.status == Status::Ready)
            .map(|(id, _)| id)
    }

    /// Run one thread until it blocks or exits.
    fn run_thread(&mut self, t: ThreadId) -> EvalResult<()> {
        while self.threads[t].status == Status::Ready {
            self.step(t)?;
        }
        Ok(())
    }

    /// Try to fire complete warp groups and barriers. Returns whether any
    /// group made progress.
    fn try_fire(&mut self) -> EvalResult<bool> {
        let mut any = false;
        loop {
            if let Some((pc, mask, members)) = self.find_ready_warp_group()? {
                trace!(
                    "warp op at pc {} fired (mask {:#010x}, {} lanes)",
                    pc.0,
                    mask,
                    members.len()
                );
                self.execute_warp_op(pc, mask, &members)?;
                any = true;
                continue;
            }
            if let Some((pc, members)) = self.find_ready_warpgroup_op()? {
                trace!(
                    "warpgroup op at pc {} fired ({} lanes)",
                    pc.0,
                    members.len()
                );
                self.execute_warpgroup_op(pc, &members)?;
                any = true;
                continue;
            }
            if self.try_fire_barrier() {
                any = true;
                continue;
            }
            if self.try_fire_mbarrier()? {
                any = true;
                continue;
            }
            return Ok(any);
        }
    }

    /// Wake every thread blocked at `mbarrier.test_wait.parity`/
    /// `try_wait.parity` whose phase-parity condition now holds. Unlike
    /// `try_fire_barrier`/`find_ready_warp_group`, this isn't a rendezvous
    /// that requires every live thread to agree - each blocked thread's
    /// condition depends only on the shared `mbarrier` object's state
    /// (updated by some *other* thread's `arrive`/`complete_tx`, which may
    /// still be freely `Ready` and running), so threads are woken
    /// independently. Returns whether any thread was woken.
    ///
    /// Establishes the χ happens-before edge the ISA actually guarantees
    /// here (9.7.14.16.19, ordering items 1-3): before waking, each waiter
    /// is `sync_group`-ed with the mbarrier's `prior_participants` (the
    /// threads whose `mbarrier.arrive` completed the phase it was waiting
    /// on) plus itself, so their prior accesses become visible to it rather
    /// than continuing to look like unsynchronized races. Lowering rejects
    /// non-default (`.relaxed`) semantics on `mbarrier.arrive`/`test_wait`/
    /// `try_wait`, so every `AtMbarrier` thread reaching here is on the
    /// default release/acquire path this edge models.
    fn try_fire_mbarrier(&mut self) -> EvalResult<bool> {
        let ready: Vec<(ThreadId, MbarrierId)> = self
            .threads
            .iter()
            .filter_map(|(tid, state)| match state.status {
                Status::AtMbarrier { id, phase_parity }
                    if self.mbarriers.parity_complete(id, phase_parity) =>
                {
                    Some((tid, id))
                }
                _ => None,
            })
            .collect();
        for (tid, id) in &ready {
            let mut group = self.mbarriers.prior_participants(*id).clone();
            group.insert(tid.0 as usize);
            self.race.sync_group(&group);

            let pc = self.threads[*tid].pc;
            let Some(LoweredInstr::MbarrierWaitParity { wait_complete, .. }) =
                self.program.instruction(pc)
            else {
                unreachable!("a thread AtMbarrier must be blocked at its own wait instruction");
            };
            let wait_complete = *wait_complete;
            let token = self.arena.bool_val(true);
            self.threads[*tid]
                .regs
                .write(wait_complete, Value::Scalar(token));
            self.threads[*tid].status = Status::Ready;
            self.threads[*tid].pc = InstrId(pc.0 + 1);
        }
        Ok(!ready.is_empty())
    }

    /// Find a warp group whose live members have all arrived at the same pc
    /// with the same mask. Returns (pc, mask, live member threads).
    fn find_ready_warp_group(&self) -> EvalResult<Option<(InstrId, u32, Vec<ThreadId>)>> {
        'candidates: for (leader, state) in self.threads.iter() {
            let Status::AtWarpOp { mask } = state.status else {
                continue;
            };
            let pc = state.pc;
            let warp_base = (leader.0 / WARP_SIZE) * WARP_SIZE;
            let mut members = Vec::new();
            for lane in 0..WARP_SIZE {
                if mask & (1 << lane) == 0 {
                    continue;
                }
                let tid = warp_base + lane;
                if tid >= self.n_threads {
                    return Err(EvalError::WarpMismatch {
                        pc,
                        reason: format!(
                            "mask {:#010x} includes lane {} but the CTA has only {} threads",
                            mask, lane, self.n_threads
                        ),
                    });
                }
                let member = &self.threads[ThreadId(tid)];
                match member.status {
                    Status::AtWarpOp { mask: m } if m == mask && member.pc == pc => {
                        members.push(ThreadId(tid));
                    }
                    // An exited lane counts as arrived at *every* warp op,
                    // not just pure syncs: the paper's Sync rule fires when
                    // each i in I is at the sync *or at return*, and the ISA
                    // says the same for shfl.sync ("wait until all
                    // non-exited threads corresponding to membermask have
                    // executed shfl.sync"). Exited lanes execute nothing
                    // (they are excluded from `members`) but rejoin the
                    // group for the chi-clear in `execute_warp_op`; data
                    // sourced from them is handled per-op.
                    Status::Exited => {}
                    // A live lane elsewhere (different pc or mask): the
                    // group is not ready. Requiring one shared pc is a
                    // deliberate conservative deviation from both
                    // authorities: the paper's syncs are unnamed ("whichever
                    // sync instances happen to align in the dynamics are
                    // matched", section 4.1) and the sm_70+ ISA matches
                    // bar.warp.sync/shfl.sync instances by mask and
                    // qualifiers, not by program point - under either,
                    // differently-located syncs could pair. Volta matches
                    // only at a single pc, for implementation simplicity; a
                    // group whose live lanes never converge at one pc stays
                    // stuck and surfaces as a loud Deadlock rather than
                    // being cross-matched.
                    _ => continue 'candidates,
                }
            }
            return Ok(Some((pc, mask, members)));
        }
        Ok(None)
    }

    /// Find a warpgroup whose live members have all arrived at the same pc.
    /// Mirrors `find_ready_warp_group` exactly (same exited-lane-
    /// vacuously-arrived, live-elsewhere-not-ready-yet, single-pc-matching
    /// rules), but there is no mask - membership is always the full
    /// contiguous 128-thread range `[group_base, group_base +
    /// WARPGROUP_SIZE)`, since `wgmma.mma_async` has no membermask operand
    /// at all (see `Status::AtWarpgroupOp`'s doc comment).
    fn find_ready_warpgroup_op(&self) -> EvalResult<Option<(InstrId, Vec<ThreadId>)>> {
        'candidates: for (leader, state) in self.threads.iter() {
            if state.status != Status::AtWarpgroupOp {
                continue;
            }
            let pc = state.pc;
            let group_base = (leader.0 / WARPGROUP_SIZE) * WARPGROUP_SIZE;
            if group_base + WARPGROUP_SIZE > self.n_threads {
                return Err(EvalError::WarpMismatch {
                    pc,
                    reason: format!(
                        "wgmma.mma_async warpgroup [{}, {}) exceeds the CTA's {} threads",
                        group_base,
                        group_base + WARPGROUP_SIZE,
                        self.n_threads
                    ),
                });
            }
            let mut members = Vec::new();
            for lane in 0..WARPGROUP_SIZE {
                let tid = ThreadId(group_base + lane);
                match self.threads[tid].status {
                    Status::AtWarpgroupOp if self.threads[tid].pc == pc => {
                        members.push(tid);
                    }
                    Status::Exited => {}
                    _ => continue 'candidates,
                }
            }
            return Ok(Some((pc, members)));
        }
        Ok(None)
    }

    /// Fire the CTA barrier if every live thread waits on the same id.
    fn try_fire_barrier(&mut self) -> bool {
        let mut id: Option<u32> = None;
        for state in self.threads.values() {
            match state.status {
                Status::Exited => {}
                Status::AtBarrier { id: this_id } => match id {
                    None => id = Some(this_id),
                    Some(prev) if prev == this_id => {}
                    Some(_) => return false, // waiting on different barriers
                },
                _ => return false, // someone is ready or at a warp op
            }
        }
        if id.is_none() {
            return false; // everyone exited (or nobody is at a barrier)
        }
        // Deliberately the paper's Sync'/syncMem semantics with I = the full
        // CTA: exited threads count as arrived (the loop above) and are
        // *included* in the chi-clear - `sync_all` empties every pending
        // set, theirs too. This is stronger than the ISA's barrier{.cta}
        // ordering, which only orders accesses "relative to all threads
        // participating in the barrier" (an exited thread participates in
        // nothing), so a spec-level race pairing a thread's pre-exit access
        // with another thread's post-barrier access is intentionally not
        // reported.
        self.race.sync_all();
        trace!("fired bar.sync {}", id.unwrap_or(0));
        for state in self.threads.values_mut() {
            if let Status::AtBarrier { .. } = state.status {
                state.status = Status::Ready;
                state.pc = InstrId(state.pc.0 + 1);
            }
        }
        true
    }

    fn deadlock_error(&self) -> EvalError {
        let blocked: Vec<_> = self
            .threads
            .iter()
            .filter(|(_, t)| !matches!(t.status, Status::Exited))
            .map(|(id, t)| (id, t.pc))
            .collect();
        warn!("deadlock: {} threads blocked", blocked.len());
        EvalError::Deadlock { blocked }
    }

    /// Apply the χ synchronization of a fired warp group. Called *before*
    /// the group's cooperative memory accesses so they cannot race with the
    /// group's own pre-sync accesses.
    pub(in crate::eval) fn sync_warp_group(&mut self, members: &[ThreadId]) {
        let mut group = fixedbitset::FixedBitSet::with_capacity(self.n_threads as usize);
        for &m in members {
            group.insert(m.0 as usize);
        }
        self.race.sync_group(&group);
    }

    /// Unblock the members of a fired warp group and advance their pcs.
    pub(in crate::eval) fn advance_warp_group(&mut self, members: &[ThreadId]) {
        for &m in members {
            let state = &mut self.threads[m];
            state.status = Status::Ready;
            state.pc = InstrId(state.pc.0 + 1);
        }
    }

    // =====================================================================
    // Single-instruction execution
    // =====================================================================

    fn step(&mut self, t: ThreadId) -> EvalResult<()> {
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
            // Parameter reads are interpreter-internal value bindings (an
            // `IdVec` lookup), not byte-addressed memory accesses, so the
            // natural-alignment rule for memory instructions has nothing to
            // apply to. Byte-addressed `.param`/`.const` accesses that do
            // reach `Load`/`Store` are rejected as unsupported in
            // `check_bounds`.
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
                // The access size of a vector load is the *total* number of
                // bytes accessed (`ld.v4.b32` is one 16-byte access, PTX
                // ISA 6.4.1), so the whole vector's bounds and alignment
                // are checked once here. The whole-footprint bounds check
                // is load-bearing: the per-element checks in `mem_read`
                // below would each pass inside a *different* region and let
                // a v4 straddle two adjacent arrays silently.
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
                // As for `LoadVec`: a vector store is one access of the
                // total size, so its whole footprint must fit in the one
                // region owning its first byte, and its alignment is the
                // total size's.
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
                // zero-filled); the ISA disambiguates `src-size` vs
                // `ignore-src` by operand kind (already resolved at
                // lowering), not by value.
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
                // The copy is decomposed into 4-byte words below (matching
                // how the corpus actually consumes cp.async destinations,
                // `ld.shared.v4.b32`), so a real/zero boundary that splits a
                // word can't be represented without byte-level masking
                // Volta doesn't model; reject it loudly instead of guessing.
                if !real_bytes.is_multiple_of(4) {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!(
                            "cp.async src-size {} is not a multiple of 4 bytes",
                            real_bytes
                        ),
                    });
                }

                // The destination's whole slot is reserved regardless of
                // how much of it is real; the ISA ties alignment to
                // `cp_size` for both operands. The source's *bounds* use
                // `real_bytes`, not `cp_size`, so a boundary-clamped
                // partial copy (the whole reason `src-size` exists) isn't
                // rejected as out-of-bounds for the untouched tail. Bounds
                // before alignment throughout, matching `mem_read`/
                // `mem_write`'s convention.
                self.check_bounds(t, pc, MemSpace::Shared, dst_addr, cp_size)?;
                self.check_alignment(t, pc, MemSpace::Shared, dst_addr, cp_size)?;
                if real_bytes > 0 {
                    self.check_bounds(t, pc, MemSpace::Global, src_addr, real_bytes)?;
                }
                self.check_alignment(t, pc, MemSpace::Global, src_addr, cp_size)?;

                // Lock the destination (exclusive) and the real-byte prefix
                // of the source (write-exclusive) for the whole in-flight
                // window, then read the source now - exact, since the lock
                // guarantees it cannot change before completion.
                self.race
                    .lock_dst(MemSpace::Shared, dst_addr, cp_size, t, pc)
                    .map_err(Self::mem_hazard_error)?;
                if real_bytes > 0 {
                    self.race
                        .lock_src(MemSpace::Global, src_addr, real_bytes, t, pc);
                }

                let zero = Value::Scalar(self.arena.int(0));
                let mut words = Vec::with_capacity((cp_size / 4) as usize);
                for i in 0..cp_size / 4 {
                    let byte = i * 4;
                    let v = if byte < real_bytes {
                        self.mem_read(t, pc, MemSpace::Global, src_addr + byte, 4)?
                    } else {
                        zero
                    };
                    words.push(v);
                }

                self.threads[t].uncommitted.push(PendingCopy {
                    dst_addr,
                    src_addr,
                    cp_size,
                    real_bytes,
                    words,
                    pc,
                });
            }

            LoweredInstr::Mov { dst, src, ty } => {
                let v = self.operand_value(t, pc, src)?;
                // Rebind the value at the mov's own type: `mov.u32 %r, -1`
                // must leave the same canonical constant in `%r` as
                // `not.b32 %r, 0` (consumers see the type-canonical value,
                // not the source operand's producer-typed rendering).
                let v = match v {
                    Value::Scalar(e) => Value::Scalar(self.canon_operand(*ty, e)),
                    pair @ Value::Pair(_, _) => pair,
                    // A `Quad` (byte-granular vector-load lane) can flow
                    // through an ordinary `mov` untouched, same as `Pair` -
                    // canonicalization only makes sense for a genuine
                    // scalar bit pattern.
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

            // Only `cvta.to.global` reaches evaluation (lowering rejects
            // every other cvta form): global addresses are absolute u64s
            // and the generic window over global is identity-mapped, so
            // the conversion is the identity.
            LoweredInstr::Cvta { dst, src, .. } => {
                let v = self.operand_value(t, pc, src)?;
                self.write_reg(t, pc, *dst, v)?;
            }

            LoweredInstr::Prmt {
                dst,
                src_a,
                src_b,
                selector,
            } => {
                let selector = self.concrete_operand(t, pc, selector, "prmt selector")?
                    as u16;
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
                // A scalar byte loaded from an FP8 array already denotes
                // its real value. A vector-loaded word is a Quad of four
                // such values, not a scalar bit pattern. Keep those lanes
                // split while applying the byte selector.
                let lanes = |this: &mut Self, value: Value| match value {
                    Value::Scalar(value) => {
                        Ok([Some(fp8_sign_xor(this, value)), None, None, None])
                    }
                    Value::Quad(b0, b1, b2, b3) => {
                        Ok([Some(b0), Some(b1), Some(b2), Some(b3)])
                    }
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
                let select_byte = |this: &mut Self, nibble: u16| {
                    let source = if nibble & 7 < 4 { &a } else { &b };
                    let byte = source[(nibble & 3) as usize].ok_or(EvalError::Unsupported {
                        pc,
                        what: format!(
                            "prmt selector {selector:#06x}: byte {} is unavailable from a scalar \
                             FP8 input",
                            nibble & 7
                        ),
                    })?;
                    Ok(if nibble & 8 == 0 { byte } else { this.arena.neg(byte) })
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
                let lut = self.concrete_operand(t, pc, lut, "lop3 LUT")?;
                let a = self.scalar_operand(t, pc, src_a)?;
                let b = self.concrete_operand(t, pc, src_b, "lop3 source b")? as u32;
                let c = self.concrete_operand(t, pc, src_c, "lop3 source c")? as u32;
                // Result bit `i` is bit `(a_i << 2) | (b_i << 1) | c_i` of
                // the LUT.
                let lop3_lut = |a: u32| {
                    let mut result = 0;
                    for i in 0..32 {
                        let a_i = (a >> i) & 1;
                        let b_i = (b >> i) & 1;
                        let c_i = (c >> i) & 1;
                        let lut_index = (a_i << 2) | (b_i << 1) | c_i;
                        let output_bit = (lut as u32 >> lut_index) & 1;
                        result |= output_bit << i;
                    }
                    result
                };
                let result = match (self.arena.as_i64(a), lut, b ^ c) {
                    // Concrete integer sources (address swizzles, masks)
                    // evaluate the full truth table bitwise.
                    (Some(a), ..) => self.arena.int(i64::from(lop3_lut(a as u32))),
                    // A symbolic `a` is an exact real: the only bit-level
                    // operation with a real reading is an XOR that leaves it
                    // unchanged or flips the f32 sign bit.
                    (None, 0x96, 0) => a,
                    (None, 0x96, 0x8000_0000) => self.arena.neg(a),
                    (None, 0x96, mask) => {
                        return Err(EvalError::Unsupported {
                            pc,
                            what: format!(
                                "lop3.b32 XOR changes bits other than the f32 sign bit ({mask:#010x})"
                            ),
                        });
                    }
                    (None, ..) => {
                        return Err(EvalError::Unsupported {
                            pc,
                            what: format!(
                                "lop3.b32 LUT {lut:#x} on a symbolic source (only XOR is modeled)"
                            ),
                        });
                    }
                };
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
                ..
            } => {
                let sign = self.scalar_operand(t, pc, sign_src)?;
                let magnitude = self.scalar_operand(t, pc, magnitude_src)?;
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
                    let a = self.scalar_operand(t, pc, src_a)?;
                    let b = self.scalar_operand(t, pc, src_b)?;
                    let c = self.scalar_operand(t, pc, src_c)?;
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
                    crate::lowered::MulMode::Lo => self.eval_binop(t, pc, BinOp::Mul, *ty, a, b)?,
                    crate::lowered::MulMode::Wide => self.mul_wide(*ty, a, b),
                    crate::lowered::MulMode::Hi => {
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
                    crate::lowered::MulMode::Lo => {
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
                ..
            } => {
                let a = self.concrete_operand(t, pc, src_a, "bfi operand")?;
                let b = self.concrete_operand(t, pc, src_b, "bfi operand")?;
                let start = self.concrete_operand(t, pc, start, "bfi start")? as u64 & 0xff;
                let len = self.concrete_operand(t, pc, len, "bfi len")? as u64 & 0xff;
                let mask = if len >= 64 {
                    u64::MAX
                } else {
                    ((1u64 << len) - 1) << start.min(63)
                };
                let r = ((b as u64) & !mask) | (((a as u64) << start.min(63)) & mask);
                let r = self.arena.int(r as i64);
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
                // Reinterpret concrete arms at the instruction type
                // before building the select: `selp.b32 %r, -1, 0, %p`
                // must export the same canonical 4294967295 a computed
                // operand would (see [`Self::canon_operand`]).
                let a = self.canon_operand(*ty, a);
                let b = self.canon_operand(*ty, b);
                let cond = self.scalar_operand(t, pc, pred)?;
                let r = self.arena.select(cond, a, b);
                self.write_reg(t, pc, *dst, Value::Scalar(r))?;
            }

            LoweredInstr::Set { .. } => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: "set (value-producing comparison)".to_string(),
                });
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
                // `cvt.u16.u32`-style truncation of a byte-quad: LLVM's
                // NVPTX backend uses this (not `mov.b32 {lo,hi}, r`) to
                // pull the low 16 bits out of a 4-byte fp8 vector-load
                // lane before feeding it to `cvt.e4m3x2` (confirmed
                // against `GELUFloat8Kernel`'s real triton-generated PTX).
                // A `Quad` has no underlying concrete bits to truncate
                // arithmetically, so this is the only sound reading: keep
                // the low `Pair` of byte lanes, exactly mirroring
                // `truncates_pair` one level up.
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
                    // input array element - already the real value that
                    // array position holds (identity-over-reals, same as
                    // every other float<->float `cvt`; see this
                    // instruction's doc comment). No bit decode needed.
                    Value::Pair(b0, b1) => {
                        Value::Pair(self.apply_clamp(clamp, b0), self.apply_clamp(clamp, b1))
                    }
                    // A genuine concrete 16-bit pattern that never went
                    // through array materialization (e.g. a `cp.async`
                    // zero-fill word, or a literal `mov.b16`): decode each
                    // byte's real `.e4m3` encoding explicitly.
                    Value::Scalar(e) if self.arena.as_i64(e).is_some() => {
                        let raw = self.arena.as_i64(e).unwrap() as u64;
                        let lo_byte = (raw & 0xFF) as u8;
                        let hi_byte = ((raw >> 8) & 0xFF) as u8;
                        let lo =
                            self.decode_fp8_byte(pc, "cvt.e4m3x2", lo_byte, fp8::decode_e4m3_byte)?;
                        let hi =
                            self.decode_fp8_byte(pc, "cvt.e4m3x2", hi_byte, fp8::decode_e4m3_byte)?;
                        Value::Pair(self.apply_clamp(clamp, lo), self.apply_clamp(clamp, hi))
                    }
                    // A single materialized fp8 array element loaded at
                    // PTX's ISA-minimum 16-bit register width (`.b8`/`.u8`
                    // have no register class of their own): `e` is already
                    // that one element's real value (identity-over-reals,
                    // same as the `Pair` case above), zero-extended into
                    // the upper byte by the loader - confirmed against
                    // `RoPEFloat8Kernel`'s real `triton_generated.ptx`
                    // (`mov.u16 %rs,0; ld.global.b8 {%rs},[addr];
                    // cvt.rn.f16x2.e4m3x2 ...`), which then always discards
                    // the upper lane (`mov.b32 {%lo,_}, %r`). We have no
                    // information left about that upper byte - not even
                    // that it's really zero, since `canon_loaded` doesn't
                    // track it - so it's `Undefined` rather than a fabricated
                    // value: silently fine when discarded, a loud
                    // `UndefinedOutput` if some kernel actually keeps it.
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
                    // A native packed-f16 granule: the two halves are
                    // already the real-valued elements, never bit-encoded
                    // (matching `CvtPackHalves` and `eval/memory.rs`'s
                    // granule combining) - distribute them directly.
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
                    // A `Quad` (byte-granular vector-load lane): each half
                    // is itself two independent byte lanes, so it splits
                    // into two `Pair`s rather than two `Scalar`s - the
                    // byte-granular analog of the native-`Pair` arm above
                    // (still never bit-encoded). This is exactly the real
                    // `mov.b32 {h0,h1}, r` idiom that precedes
                    // `cvt.rn.f16x2.e4m3x2` on an fp8 array.
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
                // Always a Value::Pair - see the type's doc comment. lo/hi
                // are half-width operands: 16-bit-class for a b32 pack
                // (always Value::Scalar) and 32-bit-class for a b64 pack,
                // where a half that is itself an f16x2 pair is rejected by
                // scalar_operand (nested pairs are not modeled).
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
                self.threads[t].status = Status::Exited;
                return Ok(());
            }

            LoweredInstr::BarSync { barrier_id } => {
                self.stats.block_syncs += 1;
                self.threads[t].status = Status::AtBarrier { id: *barrier_id };
                return Ok(()); // pc advances when the barrier fires
            }

            LoweredInstr::BarWarpSync { mask } => {
                let mask = self.concrete_operand(t, pc, mask, "warp sync mask")? as u32;
                self.block_at_warp_op(t, pc, mask)?;
                return Ok(());
            }

            LoweredInstr::Membar { .. } | LoweredInstr::Fence | LoweredInstr::Nop => {}

            LoweredInstr::FenceProxyAsync { restrict } => {
                self.race.clear_async_proxy_fence(t, *restrict);
            }

            LoweredInstr::CpAsyncCommitGroup => {
                let uncommitted = std::mem::take(&mut self.threads[t].uncommitted);
                self.threads[t].groups.push_back(uncommitted);
            }

            LoweredInstr::CpAsyncWaitGroup { n } => {
                while self.threads[t].groups.len() > *n as usize {
                    let group = self.threads[t].groups.pop_front().unwrap();
                    for copy in group {
                        // Release before writing: the deferred write must
                        // not trip the copy's own still-held dst lock (and
                        // an early same-thread peek before this point must
                        // still be caught by it - see the design writeup).
                        self.race.release_dst(
                            MemSpace::Shared,
                            copy.dst_addr,
                            copy.cp_size,
                            t,
                            copy.pc,
                        );
                        if copy.real_bytes > 0 {
                            self.race.release_src(
                                MemSpace::Global,
                                copy.src_addr,
                                copy.real_bytes,
                                t,
                                copy.pc,
                            );
                        }
                        for (i, v) in copy.words.into_iter().enumerate() {
                            self.mem_write(
                                t,
                                copy.pc,
                                MemSpace::Shared,
                                copy.dst_addr + i as u64 * 4,
                                4,
                                v,
                            )?;
                        }
                        // sm_90+ only: this write went through the async
                        // proxy, and per the ISA needs an explicit
                        // `fence.proxy.async` before any later access
                        // (through either proxy) is well-defined -
                        // `bar.sync` alone does not provide that ordering.
                        // Below sm_90 there is no such proxy distinction
                        // (and `fence.proxy.async` isn't even a legal
                        // instruction there), so this is a no-op unless
                        // `self.features.async_proxy_fence` is set.
                        if self.features.async_proxy_fence {
                            self.race.mark_async_proxy_unfenced(
                                MemSpace::Shared,
                                copy.dst_addr,
                                copy.cp_size,
                                t,
                                copy.pc,
                            );
                        }
                    }
                }
            }

            LoweredInstr::Shfl { .. } => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: "shfl without .sync (deprecated warp-unsynchronized shuffle)".to_string(),
                });
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

            // wgmma.fence/commit_group/wait_group: PTX ISA 9.7.17.7.{1,2,3}
            // track *register* hazards (accumulator registers, and
            // wgmma-group completion) around wgmma.mma_async - never a
            // memory effect the race tracker would care about. Dispatched
            // per-thread, not through `AtWarpgroupOp`: all the state
            // below is purely per-thread (no cross-thread reads), matching
            // `CpAsyncCommitGroup`/`CpAsyncWaitGroup`/`FenceProxyAsync`'s
            // existing per-thread dispatch - `wgmma.mma_async` alone needs
            // the warpgroup rendezvous, for its cross-lane-relevant
            // warpgroup-uniform operands.
            LoweredInstr::WgmmaFence => {
                self.threads[t].wgmma.fence();
            }

            LoweredInstr::WgmmaCommitGroup => {
                self.threads[t].wgmma.commit_group();
            }

            LoweredInstr::WgmmaWaitGroup { n } => {
                self.threads[t].wgmma.wait_group(*n);
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

            // tcgen05.mma: PTX ISA 9.7.17.5 gives `.cta_group::1` the issue
            // granularity "an issue from a single thread in the current
            // CTA would initiate the base operation" - unlike the
            // warp-cooperative ops just above (and unlike `mma.sync`/
            // `wmma.mma.sync`), this genuinely is single-thread, so it's
            // evaluated directly rather than through
            // `block_at_warp_op`/`execute_warp_op`.
            LoweredInstr::Tcgen05Mma {
                kind,
                d_tmem_base,
                d_tmem_offset,
                a_desc,
                b_desc,
                idesc,
                disable_output_lane,
                enable_input_d,
            } => {
                self.exec_tcgen05_mma(
                    t,
                    pc,
                    *kind,
                    d_tmem_base,
                    *d_tmem_offset,
                    a_desc,
                    b_desc,
                    idesc,
                    disable_output_lane,
                    enable_input_d,
                )?;
            }

            // tcgen05.fence::before_thread_sync/::after_thread_sync: pure
            // ordering fence, no data effect - a genuine no-op under
            // Volta's sequential, non-reordering execution model.
            LoweredInstr::Tcgen05Fence => {}

            // tcgen05.commit: once every async `tcgen05` op issued by this
            // thread so far has completed, perform an mbarrier
            // arrive-on(count=1) - same per-thread, non-warp-cooperative
            // shape as `MbarrierArrive` below (issued by a single thread,
            // not a warp rendezvous).
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
                    .map_err(|e| self.mem_error(t, pc, MemSpace::Shared, e))?;
                self.mbarriers.arrive(id, t, 1, None);
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
                    .map_err(|e| self.mem_error(t, pc, MemSpace::Shared, e))?;
            }

            LoweredInstr::MbarrierInval {
                addr_base,
                addr_offset,
            } => {
                let addr = self.effective_addr(t, pc, addr_base, *addr_offset)?;
                self.check_bounds(t, pc, MemSpace::Shared, addr, 8)?;
                self.check_alignment(t, pc, MemSpace::Shared, addr, 8)?;
                self.shared
                    .invalidate_mbarrier(addr)
                    .map_err(|e| self.mem_error(t, pc, MemSpace::Shared, e))?;
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
                    .map_err(|e| self.mem_error(t, pc, MemSpace::Shared, e))?;
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
                self.mbarriers.arrive(id, t, count, expect_tx);
                if let Some(dst) = state {
                    // The opaque phase token: not meaningfully modeled (only
                    // `.parity` waits are supported, which never consume
                    // it), so `Undefined` is the honest value - a kernel
                    // that reads it back through any other path already
                    // hit `unsupported()` at lowering.
                    let token = self.arena.undefined();
                    self.write_reg(t, pc, *dst, Value::Scalar(token))?;
                }
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
                    .map_err(|e| self.mem_error(t, pc, MemSpace::Shared, e))?;
                let tx_count =
                    self.non_negative_operand(t, pc, tx_count, "mbarrier.complete_tx txCount")?;
                self.mbarriers.complete_tx(id, tx_count);
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
                    .map_err(|e| self.mem_error(t, pc, MemSpace::Shared, e))?;
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
                self.threads[t].status = Status::AtMbarrier { id, phase_parity };
                return Ok(()); // pc advances when the wait's condition is satisfied
            }

            LoweredInstr::Activemask { dst } => {
                // The OR of `1 << lane` over the executing thread's warp
                // lanes that exist in the CTA and have not exited (ISA
                // 9.7.13.11: an "exited or inactive or predicated-off
                // thread will contribute 0"). Predication and divergence
                // are deliberately unmodeled - the per-thread interpreter
                // runs every thread's full straight-line program - so this
                // is exact for the converged case. Which lanes have exited
                // when a given thread executes activemask depends on the
                // round-robin schedule, just as it depends on timing on
                // real hardware; no cross-thread agreement is implied.
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

    /// Block `t` at a warp-cooperative instruction with the given lane mask.
    fn block_at_warp_op(&mut self, t: ThreadId, pc: InstrId, mask: u32) -> EvalResult<()> {
        if mask == 0 {
            return Err(EvalError::WarpMismatch {
                pc,
                reason: "empty lane mask".to_string(),
            });
        }
        let lane = t.0 % WARP_SIZE;
        if mask & (1 << lane) == 0 {
            return Err(EvalError::WarpMismatch {
                pc,
                reason: format!("executing lane {} is not in mask {:#010x}", lane, mask),
            });
        }
        self.threads[t].status = Status::AtWarpOp { mask };
        Ok(())
    }

    /// Block `t` at a warpgroup-cooperative instruction. No mask to
    /// validate (unlike `block_at_warp_op`) - membership is implicit;
    /// an out-of-range warpgroup is caught by `find_ready_warpgroup_op`,
    /// once the whole group's arrival can be checked in one place.
    fn block_at_warpgroup_op(&mut self, t: ThreadId, _pc: InstrId) -> EvalResult<()> {
        self.threads[t].status = Status::AtWarpgroupOp;
        Ok(())
    }

    /// `tcgen05.mma.cta_group::1.kind::{f16,f8f6f4} [d-tmem], a-desc, b-desc,
    /// idesc, enable-input-d`: `D = A*B+D` (or `A*B` if `enable-input-d` is
    /// false), `M x N x K` (`K` fixed by `.kind` - `tcgen05_mma::k_dim`),
    /// `A`/`B` read from shared memory through their matrix descriptors
    /// under the ISA's canonical layouts
    /// (`eval::tcgen05_mma::operand_element_addr`), `D` written into Tensor
    /// Memory at lane `m`, column `d_tmem + n` (Layout D for `M = 128`/
    /// `.cta_group::1`: one CTA-wide `warp-rank % 4` grouping of 32 lanes
    /// each - confirmed against Figures 211/212, fetched this session -
    /// matching the existing `tcgen05.ld`/`.st` `(lane, column)` addressing
    /// this reuses). Decodes and validates `idesc`/`a_desc`/`b_desc` first,
    /// in order, each with a specific reason, against the forms modeled:
    /// dense, `M = 128`, `D` f32, `A`/`B` f16 (`.kind::f16`) or e4m3/e5m2
    /// (`.kind::f8f6f4`), no negate, relative leading-dimension stride,
    /// `base_offset == 0` on both descriptors.
    #[allow(clippy::too_many_arguments)]
    fn exec_tcgen05_mma(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        kind: Tcgen05MmaKind,
        d_tmem_base: &Operand,
        d_tmem_offset: i64,
        a_desc: &Operand,
        b_desc: &Operand,
        idesc: &Operand,
        disable_output_lane: &[Operand],
        enable_input_d: &Operand,
    ) -> EvalResult<()> {
        let unsupported = |what: String| EvalError::Unsupported { pc, what };
        let idesc_val = self.concrete_operand(t, pc, idesc, "tcgen05.mma idesc")? as u32;
        let id = tcgen05_mma::decode_instruction_descriptor(idesc_val);

        if id.sparse {
            return Err(unsupported(
                "tcgen05.mma.sp (sparse A matrix) is not modeled".to_string(),
            ));
        }
        if id.dtype != 1 {
            return Err(unsupported(
                "tcgen05.mma with a non-f32 accumulator is not modeled".to_string(),
            ));
        }
        let format = |field: u32, operand: &str| {
            OperandFormat::decode(kind, field).ok_or_else(|| {
                unsupported(format!(
                    "tcgen05.mma {kind:?} {operand} type field {field} is not modeled \
                     (bf16 and the 6/4-bit types are not; only f16 for .kind::f16 and \
                     e4m3/e5m2 for .kind::f8f6f4)"
                ))
            })
        };
        let a_format = format(id.atype, "A")?;
        let b_format = format(id.btype, "B")?;
        if id.negate_a || id.negate_b {
            return Err(unsupported(
                "tcgen05.mma's Negate A/B Matrix is not modeled".to_string(),
            ));
        }
        if id.m != 128 {
            return Err(unsupported(format!(
                "tcgen05.mma with M = {} is not modeled (only M = 128)",
                id.m
            )));
        }

        let a_desc_val = self.concrete_operand(t, pc, a_desc, "tcgen05.mma a-desc")? as u64;
        let b_desc_val = self.concrete_operand(t, pc, b_desc, "tcgen05.mma b-desc")? as u64;
        let a_md = tcgen05_mma::decode_matrix_descriptor(a_desc_val).map_err(|sw| {
            unsupported(format!(
                "tcgen05.mma a-desc has invalid swizzle-mode encoding {sw}"
            ))
        })?;
        let b_md = tcgen05_mma::decode_matrix_descriptor(b_desc_val).map_err(|sw| {
            unsupported(format!(
                "tcgen05.mma b-desc has invalid swizzle-mode encoding {sw}"
            ))
        })?;
        if a_md.absolute_leading_stride || b_md.absolute_leading_stride {
            return Err(unsupported(
                "tcgen05.mma's absolute leading-dimension stride mode (sm_103a only) \
                 is not modeled"
                    .to_string(),
            ));
        }
        if a_md.base_offset != 0 || b_md.base_offset != 0 {
            return Err(unsupported(
                "tcgen05.mma with a nonzero matrix-descriptor base offset is not modeled"
                    .to_string(),
            ));
        }

        let k_dim = tcgen05_mma::k_dim(kind) as usize;
        let major = |transpose: bool| if transpose { Major::Mn } else { Major::K };
        let a =
            self.read_mma_operand(t, pc, (&a_md, major(id.transpose_a), a_format), id.m, k_dim)?;
        let b =
            self.read_mma_operand(t, pc, (&b_md, major(id.transpose_b), b_format), id.n, k_dim)?;

        let enable_input_d =
            self.concrete_operand(t, pc, enable_input_d, "tcgen05.mma enable-input-d")? != 0;
        let d_col_base = self.effective_addr(t, pc, d_tmem_base, d_tmem_offset)? as u32;

        // `disable-output-lane`: 4 elements form a 128-bit mask, least
        // significant bit of the first element = lane 0 (PTX ISA
        // 9.7.17.10.9.1). Resolved once up front rather than per-lane.
        let mut disable_mask = [0u32; 4];
        for (slot, op) in disable_mask.iter_mut().zip(disable_output_lane) {
            *slot = self.concrete_operand(t, pc, op, "tcgen05.mma disable-output-lane")? as u32;
        }
        let lane_disabled =
            |lane: u64| -> bool { (disable_mask[(lane / 32) as usize] >> (lane % 32)) & 1 != 0 };

        for m in 0..id.m as u64 {
            if lane_disabled(m) {
                continue;
            }
            for n in 0..id.n as u64 {
                let mut acc = if enable_input_d {
                    self.tensor
                        .read(m as u32, d_col_base + n as u32)
                        .map_err(|e| self.tcgen05_error(t, pc, e))?
                        .unwrap_or_else(|| self.arena.undefined())
                } else {
                    // A real (not integer) zero: `D` is f32-typed, and
                    // `fma`'s eager fold only fires when every operand is
                    // `RealConst` - an `IntConst(0)` seed would silently
                    // break the fold for the entire accumulation chain
                    // (each `fma`'s output becomes the next call's `c`).
                    self.arena.real(Real::zero())
                };
                let a_row = &a[m as usize * k_dim..][..k_dim];
                let b_row = &b[n as usize * k_dim..][..k_dim];
                for (&a_e, &b_e) in a_row.iter().zip(b_row) {
                    acc = self.arena.fma(a_e, b_e, acc);
                }
                self.tensor
                    .write(m as u32, d_col_base + n as u32, acc)
                    .map_err(|e| self.tcgen05_error(t, pc, e))?;
            }
        }
        Ok(())
    }

    /// Read one `tcgen05.mma` operand - `rows x k_dim` elements, `rows`
    /// being its `M` (for `A`) or `N` (for `B`) extent - from shared memory
    /// in row-major order. A concrete fp8 byte (never an input element:
    /// e.g. zero padding a kernel stored itself) is decoded from its bit
    /// encoding; a symbolic element already is its real value (see
    /// `eval::fp8`'s module doc).
    fn read_mma_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        (desc, major, format): (&tcgen05_mma::MatrixDescriptor, Major, OperandFormat),
        rows: u32,
        k_dim: usize,
    ) -> EvalResult<Vec<ExprId>> {
        let elem_bytes = format.bytes();
        let mut elems = Vec::with_capacity(rows as usize * k_dim);
        for row in 0..rows as u64 {
            for k in 0..k_dim as u64 {
                let addr = tcgen05_mma::operand_element_addr(desc, major, row, k, elem_bytes)
                    .ok_or_else(|| EvalError::Unsupported {
                        pc,
                        what: "tcgen05.mma MN-major operand without swizzling is not modeled"
                            .to_string(),
                    })?;
                let Value::Scalar(e) =
                    self.mem_read_via(t, pc, MemSpace::Shared, addr, elem_bytes, Proxy::Async)?
                else {
                    return Err(EvalError::ValueKindMismatch {
                        thread: t,
                        pc,
                        what: "tcgen05.mma operand element is not a scalar",
                    });
                };
                let e = match (format, self.arena.as_i64(e)) {
                    (OperandFormat::E4m3, Some(raw)) => self.decode_fp8_byte(
                        pc,
                        "tcgen05.mma e4m3",
                        raw as u8,
                        fp8::decode_e4m3_byte,
                    )?,
                    (OperandFormat::E5m2, Some(raw)) => self.decode_fp8_byte(
                        pc,
                        "tcgen05.mma e5m2",
                        raw as u8,
                        fp8::decode_e5m2_byte,
                    )?,
                    _ => e,
                };
                elems.push(e);
            }
        }
        Ok(elems)
    }

    // =====================================================================
    // Operand and register access
    // =====================================================================

    /// Read a register. A never-written register reads as `Undefined`
    /// rather than erroring: nvcc emits reads of dead uninitialized values
    /// (e.g. the accumulator-init idiom `selp.f32 %f, 0.0, %f, %p` on the
    /// first loop iteration). The undefined value is an error only if it
    /// reaches an output or a point that requires a concrete value.
    ///
    /// Hazard B (PTX ISA 9.7.17.7.3, `wgmma.wait_group`): reading a
    /// register a `wgmma.mma_async` wrote and hasn't yet been released by
    /// a covering `wgmma.wait_group` is exactly the external interference
    /// the ISA calls undefined behavior. `wgmma.mma_async`'s own
    /// self-continuation seed-read goes through [`Self::read_reg_wgmma_accum`]
    /// instead, which deliberately skips this check.
    pub(in crate::eval) fn read_reg(&self, t: ThreadId, pc: InstrId, reg: RegId) -> EvalResult<Value> {
        self.check_wgmma_pending(t, pc, reg)?;
        Ok(self.threads[t]
            .regs
            .read(reg)
            .unwrap_or(Value::Scalar(self.undefined)))
    }

    /// Write a register. The one chokepoint every register write in the
    /// evaluator goes through - mirrors `mem_read`/`mem_write` being the
    /// two chokepoints for memory.
    ///
    /// Hazard B: same check as `read_reg`'s, on the write side (an
    /// ordinary write to a still-pending accumulator register is equally
    /// external interference). Also hazard A bookkeeping (PTX ISA
    /// 9.7.17.7.1, `wgmma.fence`): any ordinary write always breaks a
    /// same-shape `wgmma.mma_async` chain and resets this register's
    /// fence gate to "dirty as of now" - see `WgmmaRegState`'s doc
    /// comment. `wgmma.mma_async`'s own writeback goes through
    /// [`Self::write_reg_wgmma_accum`] instead, which applies hazard A's
    /// check but not hazard B's (the self-continuation exemption).
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

    /// Hazard B's check (PTX ISA 9.7.17.7.3): is `reg` still pending a
    /// `wgmma.wait_group` release? Shared by `read_reg`/`write_reg`;
    /// `wgmma.mma_async`'s own accumulator access deliberately does not
    /// call this (see `read_reg_wgmma_accum`/`write_reg_wgmma_accum`).
    fn check_wgmma_pending(&self, t: ThreadId, pc: InstrId, reg: RegId) -> EvalResult<()> {
        if let Some(prior_pc) = self.threads[t].wgmma.pending_since(reg) {
            return Err(EvalError::WgmmaWaitGroupHazard {
                thread: t,
                pc,
                reg,
                prior_write: AccessSite {
                    thread: t,
                    pc: prior_pc,
                    is_write: true,
                },
            });
        }
        Ok(())
    }

    /// Hazard A's check (PTX ISA 9.7.17.7.1): is `wgmma.mma_async`
    /// accessing `reg` (as its accumulator, of shape `shape`) properly
    /// fenced? See `WgmmaRegState::is_fenced_for` for the two ways this
    /// can be satisfied (same-shape chaining, or an intervening fence).
    fn check_wgmma_fence(
        &self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
        shape: MmaShape,
    ) -> EvalResult<()> {
        let w = &self.threads[t].wgmma;
        if w.is_fenced_for(reg, shape) {
            return Ok(());
        }
        let prior_write = w.last_write_pc(reg).map(|p| AccessSite {
            thread: t,
            pc: p,
            is_write: true,
        });
        Err(EvalError::WgmmaFenceHazard {
            thread: t,
            pc,
            reg,
            shape,
            prior_write,
        })
    }

    /// Read a `wgmma.mma_async` accumulator seed (`scale_d` true).
    /// Applies hazard A's check but deliberately not `read_reg`'s hazard
    /// B check: this register is legitimately still pending (this
    /// thread's own prior `wgmma.mma_async` writeback in the same chain,
    /// not yet released by `wgmma.wait_group`) - exactly the
    /// self-continuation the ISA does not treat as undefined behavior.
    pub(in crate::eval) fn read_reg_wgmma_accum(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
        shape: MmaShape,
    ) -> EvalResult<Value> {
        self.check_wgmma_fence(t, pc, reg, shape)?;
        Ok(self.threads[t]
            .regs
            .read(reg)
            .unwrap_or(Value::Scalar(self.undefined)))
    }

    /// Write a `wgmma.mma_async` accumulator result. Applies hazard A's
    /// check unconditionally (not just when `scale_d` is true - this is
    /// what makes "before the first `wgmma.mma_async`" fire correctly on
    /// a chain's leading call, which has no seed-read at all), then
    /// hazard A's bookkeeping (tag `reg` with `shape` so a later
    /// same-shape chained `wgmma.mma_async` is fence-exempt) and hazard
    /// B's "now pending a `wgmma.wait_group`" mark - not `write_reg`'s
    /// generic hazard B check (same self-continuation exemption as the
    /// read side above).
    pub(in crate::eval) fn write_reg_wgmma_accum(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
        shape: MmaShape,
        value: Value,
    ) -> EvalResult<()> {
        self.check_wgmma_fence(t, pc, reg, shape)?;
        self.threads[t].regs.write(reg, value);
        self.threads[t].wgmma.record_wgmma_write(reg, shape, pc);
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
            Operand::SpecialReg(kind) => {
                let v = self.special_reg(t, pc, *kind)?;
                Ok(Value::Scalar(self.arena.int(v)))
            }
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

    /// Resolve an operand that must be a scalar.
    /// 64-bit bitwise ops with a packed-pair operand, evaluated lane-wise
    /// as exact bit semantics on two 32-bit halves: `shl`/`shr` by 32 move
    /// a lane, `or` merges lanes against a zero lane, `and` keeps or clears
    /// whole lanes. This is the idiom nvcc/Triton use to assemble `f32x2`
    /// operands from zero-extended 32-bit loads (`shl.b64 %rd_hi, 32`;
    /// `or.b64 %rd, %rd_hi, %rd_lo`). Returns `None` when no operand is a
    /// pair (the ordinary scalar path applies); errors on a pair pattern
    /// with no exact lane reading.
    fn pair_bitwise_binop(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        src_a: &Operand,
        src_b: &Operand,
    ) -> EvalResult<Option<Value>> {
        if ty.bits() != 64 || !matches!(op, BinOp::Shl | BinOp::Shr | BinOp::And | BinOp::Or) {
            return Ok(None);
        }
        let a = self.operand_value(t, pc, src_a)?;
        let b = self.operand_value(t, pc, src_b)?;
        if !matches!(a, Value::Pair(_, _)) && !matches!(b, Value::Pair(_, _)) {
            return Ok(None);
        }
        let unsupported = |what: String| EvalError::Unsupported { pc, what };
        // A concrete 64-bit scalar splits into two concrete lanes; anything
        // else alongside a pair has no lane reading.
        let lanes = |this: &mut Self, v: Value| -> EvalResult<(ExprId, ExprId)> {
            match v {
                Value::Pair(lo, hi) => Ok((lo, hi)),
                Value::Scalar(e) => match this.arena.as_int_const(e) {
                    Some(c) => {
                        let lo = this.arena.int(c & 0xFFFF_FFFF);
                        let hi = this.arena.int((c >> 32) & 0xFFFF_FFFF);
                        Ok((lo, hi))
                    }
                    None => Err(unsupported(
                        "symbolic 64-bit scalar combined bitwise with a packed pair".to_string(),
                    )),
                },
                Value::Quad(..) => Err(unsupported(
                    "packed byte-quad combined bitwise with a packed pair".to_string(),
                )),
                Value::Mbarrier(_) => Err(unsupported(
                    "mbarrier handle combined bitwise with a packed pair".to_string(),
                )),
            }
        };
        let is_zero = |this: &Self, e: ExprId| this.arena.as_int_const(e) == Some(0);
        let is_all_ones = |this: &Self, e: ExprId| this.arena.as_int_const(e) == Some(0xFFFF_FFFF);
        match op {
            BinOp::Shl | BinOp::Shr => {
                let Value::Pair(lo, hi) = a else {
                    return Err(unsupported(
                        "shift amount given as a packed pair".to_string(),
                    ));
                };
                let Value::Scalar(amount) = b else {
                    return Err(unsupported(
                        "packed pair shifted by a packed pair".to_string(),
                    ));
                };
                if self.arena.as_int_const(amount) != Some(32) || ty.is_signed_int() {
                    return Err(unsupported(format!(
                        "packed pair shifted by other than a logical 32 ({:?} on {:?})",
                        op, ty
                    )));
                }
                let zero = self.arena.int(0);
                Ok(Some(if op == BinOp::Shl {
                    Value::Pair(zero, lo)
                } else {
                    Value::Pair(hi, zero)
                }))
            }
            BinOp::Or => {
                let (a_lo, a_hi) = lanes(self, a)?;
                let (b_lo, b_hi) = lanes(self, b)?;
                let mut merge = |x: ExprId, y: ExprId| -> EvalResult<ExprId> {
                    if is_zero(self, y) {
                        Ok(x)
                    } else if is_zero(self, x) {
                        Ok(y)
                    } else {
                        match (self.arena.as_int_const(x), self.arena.as_int_const(y)) {
                            (Some(_), Some(_)) => {
                                self.eval_binop(t, pc, BinOp::Or, ScalarType::U32, x, y)
                            }
                            _ => Err(unsupported(
                                "or.b64 of two packed pairs with overlapping symbolic lanes"
                                    .to_string(),
                            )),
                        }
                    }
                };
                let lo = merge(a_lo, b_lo)?;
                let hi = merge(a_hi, b_hi)?;
                Ok(Some(Value::Pair(lo, hi)))
            }
            BinOp::And => {
                let (a_lo, a_hi) = lanes(self, a)?;
                let (b_lo, b_hi) = lanes(self, b)?;
                let mut keep = |x: ExprId, y: ExprId| -> EvalResult<ExprId> {
                    if is_all_ones(self, y) {
                        Ok(x)
                    } else if is_all_ones(self, x) {
                        Ok(y)
                    } else if is_zero(self, x) || is_zero(self, y) {
                        Ok(self.arena.int(0))
                    } else {
                        match (self.arena.as_int_const(x), self.arena.as_int_const(y)) {
                            (Some(_), Some(_)) => {
                                self.eval_binop(t, pc, BinOp::And, ScalarType::U32, x, y)
                            }
                            _ => Err(unsupported(
                                "and.b64 masking inside a packed pair's lane".to_string(),
                            )),
                        }
                    }
                };
                let lo = keep(a_lo, b_lo)?;
                let hi = keep(a_hi, b_hi)?;
                Ok(Some(Value::Pair(lo, hi)))
            }
            _ => Ok(None),
        }
    }

    /// `shf.{l,r}.{clamp,wrap}.b32 dst, lo, hi, shift` (PTX ISA 9.7.9.7):
    /// shift the 64-bit concatenation of `hi`:`lo` and keep one 32-bit end
    /// of it. See `LoweredInstr::Shf` for the bit-level definition.
    #[allow(clippy::too_many_arguments)] // internal helper; the args are the instruction's operands
    fn eval_shf(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        lo: &Operand,
        hi: &Operand,
        shift: &Operand,
        dir: ShiftDir,
        mode: ClampWrapMode,
    ) -> EvalResult<Value> {
        const WIDTH: i64 = 32;
        let raw = self.concrete_operand(t, pc, shift, "shf shift amount")?;
        let n = match mode {
            ClampWrapMode::Clamp => raw.clamp(0, WIDTH),
            ClampWrapMode::Wrap => raw & 0x1f,
        };
        let lo_v = self.operand_value(t, pc, lo)?;
        let hi_v = self.operand_value(t, pc, hi)?;

        // Packed 16-bit lanes have no bit pattern to shift, but a
        // half-width funnel shift over them is exactly a lane shuffle: at
        // n == 16 both directions extract the middle 32 bits of [hi, lo],
        // giving `Pair(lo's high lane, hi's low lane)`. This is the
        // "advance an f16 pair by one element" idiom behind an unaligned
        // gather.
        if n == WIDTH / 2 && (matches!(lo_v, Value::Pair(..)) || matches!(hi_v, Value::Pair(..))) {
            let result_lo = self.shf_lane(t, pc, lo_v, LaneHalf::High)?;
            let result_hi = self.shf_lane(t, pc, hi_v, LaneHalf::Low)?;
            return Ok(Value::Pair(result_lo, result_hi));
        }

        // Ordinary bit-vector path. The ISA's `(x << (32 - n))` is a
        // 64-bit-concatenation shift, so a 32-bit displacement contributes
        // nothing rather than being an over-wide shift.
        let a = self.scalar_operand(t, pc, lo)?;
        let b = self.scalar_operand(t, pc, hi)?;
        let (hi_shift, lo_shift) = match dir {
            ShiftDir::Left => (n, WIDTH - n),
            ShiftDir::Right => (WIDTH - n, n),
        };

        let zero = self.arena.int(0);
        let hi_part = if hi_shift >= WIDTH {
            zero
        } else {
            let amount = self.arena.int(hi_shift);
            self.eval_binop(t, pc, BinOp::Shl, ScalarType::U32, b, amount)?
        };
        
        let lo_part = if lo_shift >= WIDTH {
            zero
        } else {
            let amount = self.arena.int(lo_shift);
            self.eval_binop(t, pc, BinOp::Shr, ScalarType::U32, a, amount)?
        };

        let d = self.eval_binop(t, pc, BinOp::Or, ScalarType::U32, hi_part, lo_part)?;

        Ok(Value::Scalar(d))
    }

    /// One 16-bit lane of a `.b32` funnel-shift operand, for the lane
    /// shuffle in [`Self::eval_shf`].
    ///
    /// A `Pair` names its lanes outright and a concrete scalar slices
    /// exactly. A *symbolic* scalar has no provable lane split, and is
    /// accepted for its low lane only: reaching here means it sits
    /// opposite a packed f16 pair in a half-width funnel shift, which is
    /// the zero-extended narrow-load idiom (`ld.global.u16` into a `.b32`
    /// register, then shuffled into an f16 pair), where the register's
    /// value *is* its low lane. A genuinely 32-bit-wide symbolic value in
    /// that position would be a type error in the kernel itself. Its high
    /// lane carries no such reading, so that case stays a loud error
    /// rather than an assumed zero.
    fn shf_lane(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        v: Value,
        half: LaneHalf,
    ) -> EvalResult<ExprId> {
        const LANE_BITS: u32 = 16;
        const LANE_MASK: i64 = 0xFFFF;
        let e = match v {
            Value::Pair(lo, hi) => {
                return Ok(match half {
                    LaneHalf::Low => lo,
                    LaneHalf::High => hi,
                });
            }
            Value::Scalar(e) => e,
            Value::Quad(..) => {
                return Err(EvalError::ValueKindMismatch {
                    thread: t,
                    pc,
                    what: "shf operand holds a packed byte quad",
                });
            }
            Value::Mbarrier(_) => {
                return Err(EvalError::ValueKindMismatch {
                    thread: t,
                    pc,
                    what: "mbarrier handle used as a shf operand",
                });
            }
        };
        match (self.arena.as_int_const(e), half) {
            (Some(c), LaneHalf::Low) => Ok(self.arena.int(c & LANE_MASK)),
            (Some(c), LaneHalf::High) => Ok(self.arena.int((c >> LANE_BITS) & LANE_MASK)),
            (None, LaneHalf::Low) => Ok(e),
            (None, LaneHalf::High) => Err(EvalError::Unsupported {
                pc,
                what: "shf reading the high 16-bit lane of a symbolic 32-bit operand".to_string(),
            }),
        }
    }

    /// Apply a byte-wise FP8 sign-bit XOR to a packed byte quad. This is the
    /// `xor.b32 value, value, 0x80808080` idiom used before RoPE's FP8
    /// conversion; each quad lane already represents its decoded real value.
    fn quad_bitwise_binop(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        src_a: &Operand,
        src_b: &Operand,
    ) -> EvalResult<Option<Value>> {
        if ty.bits() != 32 || op != BinOp::Xor {
            return Ok(None);
        }
        let a = self.operand_value(t, pc, src_a)?;
        let b = self.operand_value(t, pc, src_b)?;
        let (lanes, mask) = match (a, b) {
            (Value::Quad(b0, b1, b2, b3), Value::Scalar(mask))
            | (Value::Scalar(mask), Value::Quad(b0, b1, b2, b3)) => {
                ((b0, b1, b2, b3), mask)
            }
            (Value::Quad(..), Value::Quad(..)) => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: "xor.b32 of two packed byte quads".to_string(),
                });
            }
            _ => return Ok(None),
        };
        let mask = self.arena.as_int_const(mask).ok_or(EvalError::NotConcrete {
            thread: t,
            pc,
            what: "packed byte-quad xor mask",
        })? as u32;
        let apply = |this: &mut Self, lane: ExprId, byte_mask: u32| match byte_mask {
            0 => Ok(lane),
            0x80 => Ok(this.arena.neg(lane)),
            _ => Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "packed byte-quad xor mask {mask:#010x} changes more than an FP8 sign bit"
                ),
            }),
        };
        let b0 = apply(self, lanes.0, mask & 0xff)?;
        let b1 = apply(self, lanes.1, (mask >> 8) & 0xff)?;
        let b2 = apply(self, lanes.2, (mask >> 16) & 0xff)?;
        let b3 = apply(self, lanes.3, (mask >> 24) & 0xff)?;
        Ok(Some(Value::Quad(b0, b1, b2, b3)))
    }

    pub(in crate::eval) fn scalar_operand(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: &Operand,
    ) -> EvalResult<ExprId> {
        match self.operand_value(t, pc, op)? {
            Value::Scalar(e) => Ok(e),
            Value::Pair(lo, hi) => {
                // A `mov.bN dst, {lo, hi}` pack of two concrete integer
                // halves read back as one wide scalar (a 64-bit address or
                // constant assembled from 32-bit parts): recombine the bit
                // pattern exactly. Only integer constants qualify - a pair
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

    /// Recombine two concrete integer halves of a packed pair into one wide
    /// scalar, the way a `mov.bN dst, {lo, hi}` pack or a wide granule bit-
    /// encodes an assembled value: `lo` occupies the low `half_bits` bits,
    /// `hi` the next `half_bits` above it. Shared by `scalar_operand`
    /// (register reads) and `extract_outputs` (output-array granules).
    /// Takes the arena directly (not `&mut self`) so callers holding an
    /// unrelated borrow of another field - `extract_outputs` iterates
    /// `&self.config.arrays` - can still call it.
    fn recombine_pair_halves(arena: &mut ExprArena, lo: i64, hi: i64, half_bits: u32) -> ExprId {
        let mask = (1i64 << half_bits) - 1;
        arena.int(((hi & mask) << half_bits) | (lo & mask))
    }

    /// Resolve an operand that must be a packed pair (the two lanes of a
    /// `.f16x2`/`.bf16x2` arithmetic operand, `lane_ty` = `F16`/`Bf16`).
    /// A concrete `Value::Scalar` is a raw 32-bit bit pattern moved into
    /// the register some other way than a native packed producer - most
    /// commonly `mov.b32 %r, 0` building a packed-zero clamp constant, or
    /// a packed polynomial-coefficient literal - so it's decoded bit-for-
    /// bit into the two lanes real hardware would read from it, the same
    /// interpretation `UnpackHalves`'s scalar fallback gives an integer
    /// unpack. A symbolic scalar can't be decoded this way (no bit-level
    /// reasoning over an exact-real value) and is a clean error, as is a
    /// concrete value containing a NaN half.
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

    /// `tensormap.replace`: write one named field of the tensor-map object
    /// at `addr_base + addr_offset`. `new_val` operands are resolved to
    /// concrete integers immediately (see `eval::tensor_map_table`'s
    /// module doc for why); `.field3` enum values were already decoded at
    /// lowering time, since the ISA requires them to be immediates there.
    fn exec_tensormap_replace(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr_base: &Operand,
        addr_offset: i64,
        field: &TensormapFieldWrite,
    ) -> EvalResult<()> {
        let addr = self.effective_addr(t, pc, addr_base, addr_offset)?;
        match field {
            TensormapFieldWrite::GlobalAddress(v) => {
                let val = self.concrete_operand(t, pc, v, "tensormap .global_address")?;
                self.tensor_maps.entry_mut(space, addr).global_address = Some(val as u64);
            }
            TensormapFieldWrite::Rank(v) => {
                let val = self.concrete_operand(t, pc, v, "tensormap .rank")?;
                let val = u32::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .rank value {val} out of range"),
                })?;
                self.tensor_maps.entry_mut(space, addr).rank = Some(val);
            }
            TensormapFieldWrite::BoxDim { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .box_dim")?;
                let val = u32::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .box_dim value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .box_dim
                    .insert(*ord, val);
            }
            TensormapFieldWrite::GlobalDim { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .global_dim")?;
                let val = u64::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .global_dim value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .global_dim
                    .insert(*ord, val);
            }
            TensormapFieldWrite::GlobalStride { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .global_stride")?;
                let val = u64::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .global_stride value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .global_stride
                    .insert(*ord, val);
            }
            TensormapFieldWrite::ElementStride { ord, new_val } => {
                let val = self.concrete_operand(t, pc, new_val, "tensormap .element_stride")?;
                let val = u32::try_from(val).map_err(|_| EvalError::Unsupported {
                    pc,
                    what: format!("tensormap .element_stride value {val} out of range"),
                })?;
                self.tensor_maps
                    .entry_mut(space, addr)
                    .element_stride
                    .insert(*ord, val);
            }
            TensormapFieldWrite::Elemtype(v) => {
                self.tensor_maps.entry_mut(space, addr).elemtype = Some(*v);
            }
            TensormapFieldWrite::InterleaveLayout(v) => {
                self.tensor_maps.entry_mut(space, addr).interleave_layout = Some(*v);
            }
            TensormapFieldWrite::SwizzleMode(v) => {
                self.tensor_maps.entry_mut(space, addr).swizzle_mode = Some(*v);
            }
            TensormapFieldWrite::SwizzleAtomicity(v) => {
                self.tensor_maps.entry_mut(space, addr).swizzle_atomicity = Some(*v);
            }
            TensormapFieldWrite::FillMode(v) => {
                self.tensor_maps.entry_mut(space, addr).fill_mode = Some(*v);
            }
        }
        Ok(())
    }

    /// `cp.async.bulk.tensor...tile.mbarrier::complete_tx::bytes`: TMA
    /// tensor copy, global to shared (see
    /// `lowering::lower_cp_async_bulk_tensor` for the exact scope - `.tile`
    /// mode, the `global -> shared::cluster` direction, mbarrier
    /// completion only).
    ///
    /// Per-dimension addressing follows PTX ISA 9.7.9.26.5.2/5.5.3: box-local
    /// index `k` in dimension `d` maps to global tensor index `coord[d] +
    /// k * element_stride[d]`; out-of-`global_dim` indices get `fill_mode`'s
    /// fill (scoped to zero-fill - see the `fill_mode` check below) rather
    /// than a physical read, since that is architecturally expected at tile
    /// edges (5.5.3.3), not a bug. The destination box is written in
    /// row-major (`.tile` "preserve multi-dimensional layout") order,
    /// swizzled via the *same* byte-permutation
    /// `eval::tcgen05_mma::swizzled_element_addr` already implements for
    /// the MMA operand read (PTX ISA 5.5.7 describes one pattern for both);
    /// the box is required to fit within a single swizzle atom along
    /// dimension 0 so `leading_dim_byte_offset` is never needed (see the
    /// `atom_shape`-based check below) - a box that doesn't is rejected
    /// loudly rather than silently misplaced.
    #[allow(clippy::too_many_arguments)]
    fn exec_cp_async_bulk_tensor_load(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        dst_base: &Operand,
        dst_offset: i64,
        tensormap_space: MemSpace,
        tensormap_base: &Operand,
        tensormap_offset: i64,
        coords: &[Operand],
        mbar_base: &Operand,
        mbar_offset: i64,
    ) -> EvalResult<()> {
        let dst_addr = self.effective_addr(t, pc, dst_base, dst_offset)?;
        let tm_addr = self.effective_addr(t, pc, tensormap_base, tensormap_offset)?;
        let mbar_addr = self.effective_addr(t, pc, mbar_base, mbar_offset)?;

        let entry = self
            .tensor_maps
            .get(tensormap_space, tm_addr)
            .cloned()
            .ok_or(EvalError::TensorMapNotFound {
                thread: t,
                pc,
                space: tensormap_space,
                addr: tm_addr,
            })?;

        let missing = |field: &str| EvalError::TensorMapFieldMissing {
            thread: t,
            pc,
            field: field.to_string(),
        };

        let rank0 = entry.rank.ok_or_else(|| missing("rank"))?;
        let real_rank = rank0 as usize + 1;
        if real_rank != coords.len() {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "cp.async.bulk.tensor: tensor-map rank {} does not match {} tensorCoords operand(s)",
                    real_rank,
                    coords.len()
                ),
            });
        }
        let elemtype = entry.elemtype.ok_or_else(|| missing("elemtype"))?;
        let fill_mode = entry.fill_mode.ok_or_else(|| missing("fill_mode"))?;
        if fill_mode != TensorFillMode::Zero {
            return Err(EvalError::Unsupported {
                pc,
                what: "cp.async.bulk.tensor: OOB-NaN fill mode not modeled (Volta's expression \
                       arena cannot represent a literal NaN constant)"
                    .to_string(),
            });
        }
        let swizzle_mode = entry.swizzle_mode.ok_or_else(|| missing("swizzle_mode"))?;
        let swizzle_atomicity = entry
            .swizzle_atomicity
            .ok_or_else(|| missing("swizzle_atomicity"))?;
        let mma_swizzle = tensor_map_table::to_mma_swizzle_mode(swizzle_mode, swizzle_atomicity)
            .ok_or_else(|| EvalError::Unsupported {
                pc,
                what: format!(
                    "cp.async.bulk.tensor: swizzle mode {:?} / atomicity {:?} combination not modeled",
                    swizzle_mode, swizzle_atomicity
                ),
            })?;
        let global_address = entry
            .global_address
            .ok_or_else(|| missing("global_address"))?;

        let mut box_dims = Vec::with_capacity(real_rank);
        let mut global_dims = Vec::with_capacity(real_rank);
        let mut element_strides = Vec::with_capacity(real_rank);
        for d in 0..real_rank as u32 {
            box_dims.push(*entry.box_dim.get(&d).ok_or_else(|| missing("box_dim"))?);
            global_dims.push(
                *entry
                    .global_dim
                    .get(&d)
                    .ok_or_else(|| missing("global_dim"))?,
            );
            element_strides.push(
                *entry
                    .element_stride
                    .get(&d)
                    .ok_or_else(|| missing("element_stride"))?,
            );
        }
        let mut global_strides = Vec::with_capacity(real_rank.saturating_sub(1));
        for d in 0..(real_rank as u32).saturating_sub(1) {
            global_strides.push(
                *entry
                    .global_stride
                    .get(&d)
                    .ok_or_else(|| missing("global_stride"))?,
            );
        }

        let elem_bytes = elemtype.byte_width();
        let row_bytes = box_dims[0] as u64 * elem_bytes;

        // `stride_dim_byte_offset` for a swizzled mode is the swizzle
        // *atom's own footprint* (`r * w * CELL_BYTES` - PTX ISA 5.5.7's
        // "starting address of the repeating pattern" sizes: 256/512/1024
        // bytes for 32B/64B/128B swizzle), a fixed per-mode constant -
        // *not* the box's own row width. `swizzled_element_addr`'s
        // `atom_row * row_bytes` term already accounts for the pitch
        // between individual stride-index steps *within* one atom (using
        // a fixed `w * CELL_BYTES`, unrelated to the box shape);
        // `stride_dim_byte_offset` only multiplies `stride_atom =
        // stride_idx / r`, the spacing *between* atoms. Confirmed against
        // the real corpus kernel's own independently-computed `a-desc`/
        // `b-desc` matrix-descriptor register values (`swizzled_element_addr`
        // must reproduce the exact same shared addresses `tcgen05.mma`
        // reads through those descriptors, since both sides address the
        // same physical shared memory): `A`'s real `stride_dim_byte_offset`
        // is 512 (`Swizzle64B`'s atom, `8*4*16`), `B`'s is 1024
        // (`Swizzle128B`'s atom, `8*8*16`) - both match `r*w*CELL_BYTES`
        // exactly, neither matches the box's row width.
        let stride_dim_byte_offset = if mma_swizzle == tcgen05_mma::SwizzleMode::None {
            row_bytes
        } else {
            const CELL_BYTES: u64 = 16;
            if !row_bytes.is_multiple_of(CELL_BYTES) {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "cp.async.bulk.tensor: box_dim[0] ({} elements, {} bytes) is not a whole \
                         number of 16-byte swizzle cells",
                        box_dims[0], row_bytes
                    ),
                });
            }
            let cell_count = row_bytes / CELL_BYTES;
            let (_, w) = tcgen05_mma::atom_shape(mma_swizzle);
            if cell_count > w {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "cp.async.bulk.tensor: box_dim[0] spans {} swizzle cells, more than one \
                         {:?} atom ({} cells) - crossing a leading-dimension atom boundary is not modeled",
                        cell_count, mma_swizzle, w
                    ),
                });
            }
            // The atom footprint (`r*w*CELL_BYTES`) only matches PTX ISA
            // 5.5.7's documented per-mode "repeating pattern" boundary for
            // the three modes confirmed above (256/512/1024) -
            // `Swizzle128BWith32BAtomicity`'s `atom_shape` (4,8) gives 512,
            // contradicting the ISA's 1024-byte boundary for *any* 128B
            // swizzle sub-mode (its `(r,w)` was only ever confirmed for the
            // MMA-read address formula against one diagram - see
            // `tcgen05_mma`'s module doc), so it is rejected here rather
            // than trusted for this different purpose.
            let atom_bytes = match mma_swizzle {
                tcgen05_mma::SwizzleMode::Swizzle32B => 256,
                tcgen05_mma::SwizzleMode::Swizzle64B => 512,
                tcgen05_mma::SwizzleMode::Swizzle128B => 1024,
                tcgen05_mma::SwizzleMode::None | tcgen05_mma::SwizzleMode::Swizzle128BWith32BAtomicity => {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!(
                            "cp.async.bulk.tensor: swizzle mode {:?} not modeled",
                            mma_swizzle
                        ),
                    });
                }
            };
            if !dst_addr.is_multiple_of(atom_bytes) {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!(
                        "cp.async.bulk.tensor: destination {:#x} is not aligned to the {:?} \
                         swizzle pattern's {}-byte boundary (nonzero swizzle base offset not modeled)",
                        dst_addr, mma_swizzle, atom_bytes
                    ),
                });
            }
            atom_bytes
        };

        let desc = tcgen05_mma::MatrixDescriptor {
            start_addr: dst_addr,
            leading_dim_byte_offset: 0,
            stride_dim_byte_offset,
            base_offset: 0,
            absolute_leading_stride: false,
            swizzle_mode: mma_swizzle,
        };

        let mut coord_vals = Vec::with_capacity(real_rank);
        for c in coords {
            coord_vals.push(self.concrete_operand(
                t,
                pc,
                c,
                "cp.async.bulk.tensor tensorCoords",
            )?);
        }

        let total_elems: u64 = box_dims.iter().map(|&d| d as u64).product();
        let mut idx = vec![0u32; real_rank];
        let mut global_idx = vec![0i64; real_rank];
        for linear in 0..total_elems {
            let mut rem = linear;
            for (d, dim) in idx.iter_mut().enumerate() {
                *dim = (rem % box_dims[d] as u64) as u32;
                rem /= box_dims[d] as u64;
            }

            let mut in_bounds = true;
            for d in 0..real_rank {
                let gi = coord_vals[d] + idx[d] as i64 * element_strides[d] as i64;
                global_idx[d] = gi;
                if gi < 0 || gi as u64 >= global_dims[d] {
                    in_bounds = false;
                }
            }

            let value = if in_bounds {
                let mut byte_addr = global_address + global_idx[0] as u64 * elem_bytes;
                for d in 1..real_rank {
                    byte_addr += global_idx[d] as u64 * global_strides[d - 1];
                }
                self.mem_read(t, pc, MemSpace::Global, byte_addr, elem_bytes)?
            } else if elemtype.is_float() {
                Value::Scalar(
                    self.arena
                        .float_from_f64(0.0)
                        .expect("0.0 is always representable"),
                )
            } else {
                Value::Scalar(self.arena.int(0))
            };

            let mut stride_idx = 0u64;
            let mut mult = 1u64;
            for d in 1..real_rank {
                stride_idx += idx[d] as u64 * mult;
                mult *= box_dims[d] as u64;
            }
            let leading_idx = idx[0] as u64;
            let dst_elem_addr =
                tcgen05_mma::swizzled_element_addr(&desc, stride_idx, leading_idx, elem_bytes);
            self.mem_write(t, pc, MemSpace::Shared, dst_elem_addr, elem_bytes, value)?;
            // sm_90+ only: same async-proxy write-visibility requirement as
            // `cp.async` (see `CpAsyncWaitGroup`'s handler) - TMA writes
            // land immediately here rather than being deferred to a
            // release step, so the mark happens right alongside the write
            // itself rather than at a separate completion point.
            if self.features.async_proxy_fence {
                self.race.mark_async_proxy_unfenced(
                    MemSpace::Shared,
                    dst_elem_addr,
                    elem_bytes,
                    t,
                    pc,
                );
            }
        }

        self.check_bounds(t, pc, MemSpace::Shared, mbar_addr, 8)?;
        self.check_alignment(t, pc, MemSpace::Shared, mbar_addr, 8)?;
        let mbar_id = self
            .shared
            .read_mbarrier(mbar_addr)
            .map_err(|e| self.mem_error(t, pc, MemSpace::Shared, e))?;
        let total_bytes = total_elems * elem_bytes;
        self.mbarriers.complete_tx(mbar_id, total_bytes);

        Ok(())
    }

    /// Resolve an operand that must be a concrete, non-negative integer
    /// (the mbarrier family's 32-bit unsigned `count`/`txCount` operands).
    fn non_negative_operand(
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

    fn special_reg(&self, t: ThreadId, pc: InstrId, kind: SpecialRegKind) -> EvalResult<i64> {
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
        Ok(v)
    }

    // =====================================================================
    // Memory access
    // =====================================================================

    /// Compute the concrete effective address `base + offset`.
    ///
    /// Hardware semantics: the register holds a 64-bit address and the
    /// immediate is a two's-complement byte offset, so the `[reg + imm]`
    /// sum is u64 arithmetic mod 2^64. A wrapped sum is not itself an
    /// error - it is simply an address, and unless a declared region owns
    /// it the ownership bounds check (`check_bounds`, subtraction-form,
    /// wrap-proof) rejects it loudly as `OutOfBounds` in every build
    /// profile (see `test_negative_index_wrap_is_out_of_bounds`). A
    /// checked i64 sum here would guard the wrong boundary: it rejects
    /// valid accesses that merely cross 2^63 (an array based just below
    /// the sign bit) while letting genuine u64 wraps through untouched.
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

    /// Ownership containment: the region owning the access's *first byte*
    /// must contain the whole access; an access whose first byte no region
    /// owns is out of bounds. Anchoring at the first byte's owner makes an
    /// access that starts inside one array and runs past its end a loud
    /// `OutOfBounds` even when the trailing bytes land inside an adjacent
    /// array (the paper's §6.2 point: hardware happens to tolerate
    /// out-of-bounds shared reads, the model must not). Regions never
    /// overlap - config validation keeps arrays pairwise disjoint, the
    /// symbol-table packer keeps each space's variables disjoint, and
    /// `Interpreter::new` rejects arrays overlapping the module-global
    /// window - so the owner is unique; `find` keeps the answer
    /// deterministic regardless.
    fn check_bounds(
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

    /// Natural-alignment check. PTX ISA 6.4.1: "The address must be
    /// naturally aligned to a multiple of the access size. If an address is
    /// not properly aligned, the resulting behavior is undefined". A
    /// misaligned kernel has no defined hardware semantics to model, so the
    /// access is rejected loudly instead. Addresses are always concrete
    /// here, so the check is a single modulo.
    ///
    /// `required` is the access size for scalar loads/stores (`mem_read`/
    /// `mem_write` check every access at its granule width), the *total*
    /// size for vector accesses (checked once at the `LoadVec`/`StoreVec`
    /// sites; the per-element checks below them are implied), and the
    /// row/fragment alignment for the tensor-core cooperative ops (checked
    /// at the `ldmatrix`/`wmma` sites in `eval::warp`).
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

    fn mem_error(&self, t: ThreadId, pc: InstrId, space: MemSpace, e: MemAccessError) -> EvalError {
        match e {
            MemAccessError::Uninitialized { addr } => EvalError::UninitializedMemory {
                thread: t,
                pc,
                space,
                addr,
            },
            MemAccessError::Reinterpret { addr, width, found } => EvalError::Reinterpretation {
                thread: t,
                pc,
                space,
                addr,
                width,
                found,
            },
            MemAccessError::MbarrierOverwrite { addr } => EvalError::MbarrierOverwrite {
                thread: t,
                pc,
                space,
                addr,
            },
            MemAccessError::NoLiveMbarrier { addr } => EvalError::NoLiveMbarrier {
                thread: t,
                pc,
                space,
                addr,
            },
        }
    }

    pub(in crate::eval) fn tcgen05_error(
        &self,
        t: ThreadId,
        pc: InstrId,
        e: crate::eval::tensor_memory::TensorMemError,
    ) -> EvalError {
        use crate::eval::tensor_memory::TensorMemError;
        match e {
            TensorMemError::InvalidColumnCount { num_cols } => {
                EvalError::Tcgen05InvalidColumnCount {
                    thread: t,
                    pc,
                    num_cols,
                }
            }
            TensorMemError::OutOfSpace {
                requested,
                available,
            } => EvalError::Tcgen05OutOfSpace {
                thread: t,
                pc,
                requested,
                available,
            },
            TensorMemError::AllocAfterRelinquish => {
                EvalError::Tcgen05AllocAfterRelinquish { thread: t, pc }
            }
            TensorMemError::DeallocMismatch { taddr, num_cols } => {
                EvalError::Tcgen05DeallocMismatch {
                    thread: t,
                    pc,
                    taddr,
                    num_cols,
                }
            }
            TensorMemError::NotAllocated { lane, col } => EvalError::Tcgen05NotAllocated {
                thread: t,
                pc,
                lane,
                col,
            },
        }
    }

    fn mem_hazard_error(hazard: MemHazard) -> EvalError {
        match hazard {
            MemHazard::Race(race) => EvalError::DataRace {
                space: race.space,
                addr: race.addr,
                prior: race.prior,
                current: race.current,
            },
            MemHazard::AsyncCopy(h) => EvalError::AsyncCopyHazard {
                space: h.space,
                addr: h.addr,
                prior: h.prior,
                current: h.current,
            },
            MemHazard::AsyncProxyUnfenced(h) => EvalError::AsyncProxyFenceHazard {
                space: h.space,
                addr: h.addr,
                prior: h.prior,
                current: h.current,
            },
            MemHazard::GenericProxyUnfenced(h) => EvalError::GenericProxyFenceHazard {
                space: h.space,
                addr: h.addr,
                prior: h.prior,
                current: h.current,
            },
        }
    }

    /// Bounds-check, race-check, and read memory.
    ///
    /// Reading in-bounds shared/global bytes that were never written yields
    /// `Undefined` rather than an error: the read is still recorded in χ, so
    /// a later conflicting write is reported as a race (this is exactly the
    /// paper's motivating example, where thread 0 reads `buf[1]` before
    /// thread 1 has written it). The undefined value is an error only if it
    /// reaches an output or a point that requires a concrete value.
    pub(in crate::eval) fn mem_read(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
    ) -> EvalResult<Value> {
        self.mem_read_via(t, pc, space, addr, width, Proxy::Generic)
    }

    /// [`Self::mem_read`] through a given memory proxy (see
    /// `RaceTracker::read_via`).
    pub(in crate::eval) fn mem_read_via(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
        proxy: Proxy,
    ) -> EvalResult<Value> {
        self.check_bounds(t, pc, space, addr, width)?;
        // Every program access flows through here (scalar ld/st directly;
        // vector and tensor-core ops per element, after their own
        // larger-granule checks), so this is the one natural-alignment
        // chokepoint. Param space never reaches it: `check_bounds` rejects
        // Param/Const accesses, and `LoadParam` reads interpreter-internal
        // parameter bindings, not byte-addressed memory.
        self.check_alignment(t, pc, space, addr, width)?;
        let memory = match space {
            MemSpace::Global | MemSpace::Shared => {
                self.race
                    .read_via(space, addr, width, t, pc, proxy)
                    .map_err(Self::mem_hazard_error)?;
                if space == MemSpace::Global {
                    &self.global
                } else {
                    &self.shared
                }
            }
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
                .map_err(|e| self.mem_error(t, pc, space, e)),
            Err(MemAccessError::Uninitialized { .. }) if space == MemSpace::Global => {
                // Reading an input array materializes its symbols on demand.
                if self.materialize_input(addr, width) {
                    self.global
                        .read(addr, width)
                        .map_err(|e| self.mem_error(t, pc, space, e))
                } else {
                    Ok(Value::Scalar(self.arena.undefined()))
                }
            }
            // A *partially* materialized input array: this access spans
            // elements that already exist alongside ones that do not, so
            // the granule scan stops at the first covered byte and reports
            // a reinterpretation rather than a plain miss. Materializing
            // just the absent elements (`materialize_input` skips the
            // present ones) lets the ordinary combine rules compose the
            // whole access - the two-f16-element `ld.global.b32` over an
            // array some other thread already touched 2 bytes of. A
            // genuine reinterpretation materializes nothing, so the guard
            // fails and the loud error below still stands.
            Err(MemAccessError::Reinterpret { .. })
                if space == MemSpace::Global && self.materialize_input(addr, width) =>
            {
                self.global
                    .read(addr, width)
                    .map_err(|e| self.mem_error(t, pc, space, e))
            }
            Err(MemAccessError::Uninitialized { .. }) if space == MemSpace::Shared => {
                Ok(Value::Scalar(self.arena.undefined()))
            }
            Err(e) => Err(self.mem_error(t, pc, space, e)),
        }
    }

    /// Create the input-element symbols for every input-array element
    /// overlapping `[addr, addr + width)` that is not yet present in
    /// global memory. Returns whether any element was materialized.
    fn materialize_input(&mut self, addr: u64, width: u64) -> bool {
        // Collect missing elements first (the array list borrows the config).
        // (addr, width, index, interned array name or None for identity
        // indices); the array's name is interned once and shared by all of
        // its elements.
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
            // Both sums below are exact: the access was bounds-checked
            // (`addr + width` fits inside its owning region) and the
            // array's end fits in u64 (`AnalysisConfig::validate`), so
            // with width >= 1 neither `addr + width - 1` nor
            // `base + size - 1` can wrap.
            let end = array.base + size;
            let first = (addr.max(array.base) - array.base) / array.elem_width;
            let last = ((addr + width - 1).min(end - 1) - array.base) / array.elem_width;
            let mut array_sid: Option<StringId> = None;
            for i in first..=last {
                let elem_addr = array.base + i * array.elem_width;
                if !self.global.has_cell_at(elem_addr) {
                    let value = match array.kind {
                        crate::eval::config::ArrayKind::IndexInput => None,
                        _ => Some(
                            *array_sid.get_or_insert_with(|| self.arena.intern_string(&array.name)),
                        ),
                    };
                    missing.push((elem_addr, array.elem_width, i, value));
                }
            }
        }

        // Analysis-setup placement (not a PTX access, so no alignment check
        // applies): each granule lands at `base + i*elem_width`, naturally
        // aligned because `AnalysisConfig::validate` requires every array
        // base to be a multiple of its element width.
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

    /// Whether two values denote the same reals, lane by lane: the same
    /// node, structural equality, or the canonical equivalence check used
    /// for output comparison (so a warp's lanes holding one reduced sum in
    /// different association orders count as equal). Only consulted when a
    /// write-write conflict has already been found, so its cost is paid
    /// rarely.
    fn same_real_value(&self, a: Value, b: Value) -> bool {
        let lanes = match (a, b) {
            (Value::Scalar(x), Value::Scalar(y)) => vec![(x, y)],
            (Value::Pair(x_lo, x_hi), Value::Pair(y_lo, y_hi)) => vec![(x_lo, y_lo), (x_hi, y_hi)],
            _ => return false,
        };
        let mut session = EquivSession::new(&self.arena, &self.arena);
        lanes.into_iter().all(|(x, y)| {
            x == y
                || structurally_equal(&self.arena, x, &self.arena, y)
                || session.check(x, y).unwrap_or(false)
        })
    }

    /// Bounds-check, race-check, and write memory.
    pub(in crate::eval) fn mem_write(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        space: MemSpace,
        addr: u64,
        width: u64,
        value: Value,
    ) -> EvalResult<()> {
        self.check_bounds(t, pc, space, addr, width)?;
        // See `mem_read`: the write-side natural-alignment chokepoint.
        self.check_alignment(t, pc, space, addr, width)?;
        let memory = match space {
            MemSpace::Global | MemSpace::Shared => {
                let result = self.race.write_with(space, addr, width, t, pc, false);
                // A store of exactly the value already there (the same
                // expression) is benign against the previous writer - see
                // `RaceTracker::write_with`. Only fetch the current value
                // once a write-write conflict is actually found: the
                // common non-racing store pays no extra memory read.
                let benign = if let Err(MemHazard::Race(info)) = &result
                    && info.prior.is_write
                {
                    let present = if space == MemSpace::Global {
                        self.global.read(addr, width).ok()
                    } else {
                        self.shared.read(addr, width).ok()
                    };
                    present.is_some_and(|present| self.same_real_value(present, value))
                } else {
                    false
                };
                if benign {
                    self.race
                        .write_with(space, addr, width, t, pc, true)
                        .map_err(Self::mem_hazard_error)?;
                } else {
                    result.map_err(Self::mem_hazard_error)?;
                }
                if space == MemSpace::Global {
                    &mut self.global
                } else {
                    // sm_90+: a later async-proxy read (`tcgen05.mma`)
                    // needs this write fenced by its writer. `cp.async`/TMA
                    // writes land here too and re-mark themselves as
                    // async-proxy writes right after, dropping this mark.
                    if self.features.async_proxy_fence {
                        self.race.mark_generic_unfenced(addr, width, t, pc);
                    }
                    &mut self.shared
                }
            }
            MemSpace::Local => &mut self.locals[t],
            _ => unreachable!("bounds check rejects other spaces"),
        };
        match memory.write(addr, width, value) {
            Err(MemAccessError::Reinterpret {
                found: Some((start, found_width, GranuleKind::Scalar)),
                ..
            }) if self.split_concrete_scalar(space, t, start, found_width, addr, width) => self
                .memory_mut(space, t)
                .write(addr, width, value)
                .map_err(|e| self.mem_error(t, pc, space, e)),
            result => result.map_err(|e| self.mem_error(t, pc, space, e)),
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

    /// Split the concrete scalar granule at `start` (width `found_width`)
    /// into exact halves - repeatedly, toward the half holding the access -
    /// until the access `[addr, addr + width)` is a whole granule of its
    /// own (e.g. one fp8 `tcgen05.mma` operand byte of a zero word a kernel
    /// stored as padding). Returns whether that was reached, so the access
    /// can be retried. Symbolic scalars have no bit-level halves and stay a
    /// reinterpretation error.
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

    // =====================================================================
    // Arithmetic
    // =====================================================================

    /// Evaluate a binary op. Integer ops on concrete values use exact
    /// width/signedness semantics; symbolic values get real-valued nodes.
    ///
    /// `pub(in crate::eval)`: also the fold primitive `eval::warp`'s
    /// `exec_redux_sync` uses to combine `redux.sync` lane values, since
    /// it already has the exact signed/float-aware semantics per `ty`.
    pub(in crate::eval) fn eval_binop(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        a: ExprId,
        b: ExprId,
    ) -> EvalResult<ExprId> {
        if ty.is_predicate() {
            return self.eval_pred_binop(pc, op, a, b);
        }

        if !ty.is_float()
            && let (Some(ca), Some(cb)) = (self.arena.as_i64(a), self.arena.as_i64(b))
        {
            let r = self.concrete_int_binop(t, pc, op, ty, ca, cb)?;
            return Ok(self.arena.int(r));
        }

        // One operand concrete, the other symbolic: reinterpret the
        // concrete side at the instruction type before building the node,
        // so `add.u32 %r, %sym, -1` and a chain that produced 4294967295
        // build identical expressions (the register/immediate rendering
        // is the producer's, not this instruction's).
        let a = self.canon_operand(ty, a);
        let b = self.canon_operand(ty, b);

        Ok(match op {
            BinOp::Add => self.arena.add(a, b),
            BinOp::Sub => self.arena.sub(a, b),
            BinOp::Mul => self.arena.mul(a, b),
            BinOp::Div => self.arena.div(a, b),
            BinOp::Rem => self.arena.rem(a, b),
            BinOp::And => self.arena.bit_and(a, b),
            BinOp::Or => self.arena.bit_or(a, b),
            BinOp::Xor => self.eval_xor(ty, a, b),
            BinOp::Shl => self.arena.shl(a, b),
            BinOp::Shr => {
                if ty.is_signed_int() {
                    self.arena.shr(a, b)
                } else {
                    self.arena.lshr(a, b)
                }
            }
            BinOp::Min => self.arena.min(a, b),
            BinOp::Max => self.arena.max(a, b),
        })
    }

    /// `xor` by a type's sign-bit mask is the bitflip idiom for a float
    /// negate (e.g. `xor.b16 %h, %h, 0x8000`); fold it to `Neg` so the
    /// decision procedure sees negation instead of an opaque `bit_xor`.
    fn eval_xor(&mut self, ty: ScalarType, a: ExprId, b: ExprId) -> ExprId {
        let sign_bit: i64 = match ty.bits() {
            16 => 0x8000,
            32 => 0x8000_0000,
            64 => 0x8000_0000_0000_0000u64 as i64,
            _ => return self.arena.bit_xor(a, b),
        };
        match (self.arena.as_int_const(a), self.arena.as_int_const(b)) {
            (Some(mask), _) if mask == sign_bit => return self.arena.neg(b),
            (_, Some(mask)) if mask == sign_bit => return self.arena.neg(a),
            _ => return self.arena.bit_xor(a, b),
        }
    }

    /// Exact concrete integer semantics for `ty`.
    fn concrete_int_binop(
        &self,
        t: ThreadId,
        pc: InstrId,
        op: BinOp,
        ty: ScalarType,
        a: i64,
        b: i64,
    ) -> EvalResult<i64> {
        let bits = ty.bits().min(64);
        let signed = ty.is_signed_int();
        let ua = mask_to(a, bits);
        let ub = mask_to(b, bits);
        let sa = canon_int(a, bits, true);
        let sb = canon_int(b, bits, true);

        let raw: u64 = match op {
            BinOp::Add => ua.wrapping_add(ub),
            BinOp::Sub => ua.wrapping_sub(ub),
            BinOp::Mul => ua.wrapping_mul(ub),
            BinOp::Div => {
                if ub == 0 {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("division by zero (thread {})", t),
                    });
                }
                if signed {
                    sa.wrapping_div(sb) as u64
                } else {
                    ua / ub
                }
            }
            BinOp::Rem => {
                if ub == 0 {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("remainder by zero (thread {})", t),
                    });
                }
                if signed {
                    sa.wrapping_rem(sb) as u64
                } else {
                    ua % ub
                }
            }
            BinOp::And => ua & ub,
            BinOp::Or => ua | ub,
            BinOp::Xor => ua ^ ub,
            // PTX shifts clamp: shifting by >= width produces 0 (or the sign
            // fill for arithmetic right shift).
            BinOp::Shl => {
                if ub >= bits as u64 {
                    0
                } else {
                    ua << ub
                }
            }
            BinOp::Shr => {
                if signed {
                    let sh = ub.min(bits as u64 - 1);
                    (sa >> sh) as u64
                } else if ub >= bits as u64 {
                    0
                } else {
                    ua >> ub
                }
            }
            BinOp::Min => {
                if signed {
                    sa.min(sb) as u64
                } else {
                    ua.min(ub)
                }
            }
            BinOp::Max => {
                if signed {
                    sa.max(sb) as u64
                } else {
                    ua.max(ub)
                }
            }
        };
        Ok(canon_int(raw as i64, bits, signed))
    }

    /// Boolean (predicate) binary ops.
    fn eval_pred_binop(
        &mut self,
        pc: InstrId,
        op: BinOp,
        a: ExprId,
        b: ExprId,
    ) -> EvalResult<ExprId> {
        if let (Some(ca), Some(cb)) = (self.arena.as_bool(a), self.arena.as_bool(b)) {
            let r = match op {
                BinOp::And => ca && cb,
                BinOp::Or => ca || cb,
                BinOp::Xor => ca != cb,
                _ => {
                    return Err(EvalError::Unsupported {
                        pc,
                        what: format!("{} on predicates", op.as_str()),
                    });
                }
            };
            return Ok(self.arena.bool_val(r));
        }
        Ok(match op {
            BinOp::And => self.arena.and(a, b),
            BinOp::Or => self.arena.or(a, b),
            // Boolean xor is inequality.
            BinOp::Xor => self.arena.ne(a, b),
            _ => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!("{} on predicates", op.as_str()),
                });
            }
        })
    }

    /// `ex2(v * c)` with `c` within float32 rounding of log2(e) is the PTX
    /// idiom for `exp(v)`, and `c ~ -log2(e)` the idiom for `exp(-v)`. `v`
    /// itself may be spread across an `Fma`/`Add` chain that shares the
    /// same rounded log2(e) factor per term rather than multiplying it in
    /// once at the end - e.g. softmax's max-subtraction bias,
    /// `fma(x, log2e, m)` where `m` was already built as `max * -log2e`,
    /// for `(x - max) * log2e` - [`Self::factor_log2e`] pulls the shared
    /// constant back out of that chain. Returns the exact `exp(...)`
    /// form, or `None` when `a` doesn't factor this way.
    fn fold_exp_idiom(&mut self, a: ExprId) -> Option<ExprId> {
        let argument = self.factor_log2e(a)?;
        Some(self.arena.exp(argument))
    }

    /// Pulls a `log2(e)`-ish rational constant (within float32 rounding)
    /// out of a `Mul`/`Fma`/`Add` chain, folding each term's own sign into
    /// the result so that `a == log2e * factor_log2e(a)` for whichever
    /// concrete log2(e)-approximating constant `a` was actually built
    /// with. `None` when no such factor exists at this node.
    fn factor_log2e(&mut self, a: ExprId) -> Option<ExprId> {
        let log2e = std::f64::consts::LOG2_E;
        let is_log2e_like = |value: f64| (value.abs() - log2e).abs() <= log2e * 1e-6;
        match self.arena.node(a).clone() {
            ExprNode::Mul(l, r) => {
                for (constant, other) in [(l, r), (r, l)] {
                    let value = match self.arena.node(constant) {
                        ExprNode::RealConst(real) => real.to_f64(),
                        _ => continue,
                    };
                    if !is_log2e_like(value) {
                        continue;
                    }
                    return Some(if value < 0.0 {
                        self.arena.neg(other)
                    } else {
                        other
                    });
                }
                None
            }
            ExprNode::Fma(x, c, rest) => {
                let value = match self.arena.node(c) {
                    ExprNode::RealConst(real) => real.to_f64(),
                    _ => return None,
                };
                if !is_log2e_like(value) {
                    return None;
                }
                let x_signed = if value < 0.0 { self.arena.neg(x) } else { x };
                let rest_factored = self.factor_log2e(rest)?;
                Some(self.arena.add(x_signed, rest_factored))
            }
            ExprNode::Add(l, r) => {
                let l_factored = self.factor_log2e(l)?;
                let r_factored = self.factor_log2e(r)?;
                Some(self.arena.add(l_factored, r_factored))
            }
            _ => None,
        }
    }

    fn eval_unop(
        &mut self,
        pc: InstrId,
        op: UnaryOp,
        ty: ScalarType,
        a: ExprId,
    ) -> EvalResult<ExprId> {
        Ok(match op {
            UnaryOp::Neg => self.arena.neg(a),
            UnaryOp::Abs => self.arena.abs(a),
            UnaryOp::Not => {
                if ty.is_predicate() {
                    if let Some(c) = self.arena.as_bool(a) {
                        self.arena.bool_val(!c)
                    } else {
                        self.arena.not(a)
                    }
                } else {
                    // Bitwise not; folds when concrete (via canonical i64).
                    let bits = ty.bits().min(64);
                    if let Some(c) = self.arena.as_i64(a) {
                        let r = canon_int(!c, bits, ty.is_signed_int());
                        self.arena.int(r)
                    } else {
                        self.arena.bit_not(a)
                    }
                }
            }
            UnaryOp::Rcp => self.arena.rcp(a),
            UnaryOp::Sqrt => self.arena.sqrt(a),
            UnaryOp::Rsqrt => {
                let s = self.arena.sqrt(a);
                self.arena.rcp(s)
            }
            UnaryOp::Exp => self.arena.exp(a),
            // 2^x = e^(x*ln2), so this stays in the interpreted exp fragment
            // rather than becoming an opaque atom. PTX has no exp instruction:
            // compilers and hand-written kernels spell exp(v) as
            // ex2(v * log2e) with a float32 log2e, which over the reals is
            // exp(v * 0.99999999...) and would never match a spec's exp(v).
            // That idiom is folded to an exact exp(v) first, in the same
            // spirit as reading ex2.approx as an exact 2^x.
            UnaryOp::Ex2 => {
                if let Some(folded) = self.fold_exp_idiom(a) {
                    folded
                } else {
                    let ln2 = self
                        .arena
                        .float_from_f64(std::f64::consts::LN_2)
                        .map_err(|e| EvalError::Unsupported {
                            pc,
                            what: format!("ex2 ln2 constant: {}", e),
                        })?;
                    let scaled = self.arena.mul(a, ln2);
                    self.arena.exp(scaled)
                }
            }
            // tanh(x) = (e^2x - 1) / (e^2x + 1), so this too stays in the
            // interpreted exp fragment rather than becoming an opaque atom
            // (same approach as `Ex2` above).
            UnaryOp::Tanh => {
                let two = self.arena.int(2);
                let one = self.arena.int(1);
                let two_x = self.arena.mul(a, two);
                let e2x = self.arena.exp(two_x);
                let num = self.arena.sub(e2x, one);
                let den = self.arena.add(e2x, one);
                self.arena.div(num, den)
            }
            UnaryOp::Lg2 | UnaryOp::Sin | UnaryOp::Cos => {
                return Err(EvalError::Unsupported {
                    pc,
                    what: format!("transcendental {}", op.as_str()),
                });
            }
        })
    }

    /// Reinterpret a concrete operand as canonical for `ty`. Registers and
    /// memory granules hold values canonicalized by their *producing*
    /// instruction, so a value written as signed may be consumed as
    /// unsigned (or vice versa): nvcc emits `mul.wide.u16 %r, %rs, -17873`
    /// where the immediate is really the u16 magic constant 47663. Every
    /// consumer that gives a concrete integer a type of its own re-reads
    /// the value through this (mov, cvt sources, wide/hi multiplies,
    /// binops with a symbolic side; loads and stores go through
    /// [`Self::canon_loaded`]/[`Self::canon_stored`]). Symbolic operands
    /// pass through unchanged, as do genuine float constants (always a
    /// `Real`, never an `IntConst` - a `mov.b32 %r, %f` bit-move must not
    /// coerce the float to an int).
    fn canon_operand(&mut self, ty: ScalarType, e: ExprId) -> ExprId {
        if ty.is_predicate() {
            return e;
        }
        if ty.is_float() {
            // A concrete `IntConst` under a float-consuming type is a raw
            // bit pattern from a plain `.bN` producer (e.g. `mov.b16 %h,
            // 0x4400` feeding a later `mul.rn.f16`), not an already-real
            // value: decode it at this instruction's width, the same way
            // `decode_packed_bits` does for the packed-pair operand path.
            if let Some(bits) = self.arena.as_int_const(e) {
                let decoded = match ty {
                    ScalarType::F16 => f16_bits_to_f64(bits as u16),
                    ScalarType::Bf16 => bf16_bits_to_f64(bits as u16),
                    ScalarType::F32 | ScalarType::Tf32 => {
                        Some(f32::from_bits(bits as u32) as f64)
                    }
                    ScalarType::F64 => Some(f64::from_bits(bits as u64)),
                    _ => None,
                };
                if let Some(v) = decoded {
                    if let Ok(id) = self.arena.float_from_f64(v) {
                        return id;
                    }
                }
            }
            return e;
        }
        if let Some(c) = self.arena.as_int_const(e) {
            let canon = canon_int(c, ty.bits().min(64), ty.is_signed_int());
            if canon != c {
                return self.arena.int(canon);
            }
        }
        e
    }

    /// Canonicalize a value crossing a store boundary. Memory holds bit
    /// patterns: a concrete integer is reduced to the unsigned low bits of
    /// the store type (`st.u8` of 300 stores 44); sign/zero extension is
    /// the *load*'s job (see [`Self::canon_loaded`]). Floats, `Undefined`,
    /// and packed pairs at their full 4-byte width pass through unchanged.
    ///
    /// A *symbolic* integer stored below its source register's width would
    /// need a truncation node we deliberately do not model, so that store
    /// is a loud error rather than a silently unsound pass-through.
    /// Equal-width symbolic stores are exact and pass through (an f16 half
    /// stored from a 16-bit register via `st.u16` - the corpus's only
    /// symbolic sub-word stores). Likewise a packed f16x2 pair stored
    /// below 4 bytes would stuff the whole two-half value into a narrower
    /// granule - a shape the memory model never anticipates - so it too
    /// is a loud error (its truncation would be a half extraction we do
    /// not model at store boundaries).
    fn canon_stored(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        ty: ScalarType,
        src_reg_bits: Option<u32>,
        v: Value,
    ) -> EvalResult<Value> {
        // A packed pair's own width is its *source register's* width, not a
        // fixed 4 bytes: `Memory::read` also yields a 2-byte-native `Pair`
        // when combining two adjacent 1-byte fp8 array elements (byte-
        // granular arrays), held in an ordinary 16-bit register - distinct
        // from the classic 4-byte f16x2 pair. A store matching that
        // register's full width is an exact, lossless round-trip either
        // way; only a store *narrower* than the source register would
        // require a half-extraction we don't model, so gate on
        // `src_reg_bits` (as the analogous scalar check below does)
        // instead of a width hard-coded to the f16x2 case.
        if matches!(v, Value::Pair(..))
            && src_reg_bits.is_none_or(|reg_bits| ty.bits() < reg_bits)
        {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "packed pair stored at sub-register width \
                     ({}-bit store, thread {})",
                    ty.bits(),
                    t
                ),
            });
        }
        if matches!(v, Value::Mbarrier(_)) {
            return Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "mbarrier handle stored as ordinary program data",
            });
        }
        if ty.is_float() || ty.is_predicate() {
            return Ok(v);
        }
        let Value::Scalar(e) = v else {
            return Ok(v); // packed f16 pairs at full width
        };
        if let Some(c) = self.arena.as_int_const(e) {
            let canon = canon_int(c, ty.bits().min(64), false);
            return Ok(if canon == c {
                v
            } else {
                Value::Scalar(self.arena.int(canon))
            });
        }
        if let Some(reg_bits) = src_reg_bits
            && ty.bits() < reg_bits
            && !self.arena.is_undefined(e)
            && !self.arena.is_concrete(e)
        {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "symbolic value stored at sub-register width \
                     ({}-bit store of a {}-bit register, thread {})",
                    ty.bits(),
                    reg_bits,
                    t
                ),
            });
        }
        Ok(v)
    }

    /// Zero-extending a symbolic 32-bit value into a 64-bit destination is
    /// exactly the pair (value, 0) in the packed-pair domain: this is how
    /// nvcc/Triton feed one f32 into the lanes of an `f32x2` operand,
    /// whether through a 32-bit load into a 64-bit register (`canon_loaded`)
    /// or an explicit `cvt.u64.u32` (e.g. `ld.shared.b32 %rd, [..]`, then
    /// `shl.b64`/`or.b64` to place a second value in the high lane).
    /// `None` when the shape doesn't match (concrete/undefined values fold
    /// or pass through their normal path instead).
    fn zero_extend_to_pair(
        &mut self,
        src_bits: u32,
        src_signed: bool,
        dst_bits: u32,
        e: ExprId,
    ) -> Option<Value> {
        if src_bits == 32
            && dst_bits == 64
            && !src_signed
            && !self.arena.is_undefined(e)
            && !self.arena.is_concrete(e)
        {
            let zero = self.arena.int(0);
            Some(Value::Pair(e, zero))
        } else {
            None
        }
    }

    /// Canonicalize a value crossing a load boundary: `ld` extends the
    /// memory pattern to the destination register per the *load type* -
    /// sign-extension for `.s8`/`.s16`/..., zero-extension for unsigned
    /// and bits types (the ISA's ld extension rules) - so `ld.s8` of the
    /// byte 0xFF yields -1 while `ld.u8` yields 255. Floats, packed
    /// pairs, and `Undefined` pass through unchanged.
    ///
    /// A *symbolic* scalar loaded at a type narrower than the destination
    /// register would need a **sign**-extension node we deliberately do not
    /// model (a genuine case split on the unknown value: loud error), but
    /// only when `ty` is actually signed. Zero-extension needs no such
    /// node: a bits-type or unsigned symbolic value denotes the same
    /// number whether boxed in a narrow or a wide register, so it passes
    /// through unchanged - this is also PTX's own rule for `.b8`/`.u8`
    /// register loads, which the ISA has no register class narrower than
    /// 16 bits to hold natively (confirmed against
    /// `RoPEFloat8Kernel`'s real `triton_generated.ptx`: `ld.global.b8`
    /// of one fp8 array byte into a `.b16` register). Equal-width
    /// symbolic loads are exact and pass through too (f16 halves loaded
    /// into 16-bit registers).
    fn canon_loaded(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        ty: ScalarType,
        dst: RegId,
        v: Value,
    ) -> EvalResult<Value> {
        if matches!(v, Value::Mbarrier(_)) {
            return Err(EvalError::ValueKindMismatch {
                thread: t,
                pc,
                what: "mbarrier handle loaded as ordinary program data",
            });
        }
        if ty.is_float() || ty.is_predicate() {
            return Ok(v);
        }
        let Value::Scalar(e) = v else {
            return Ok(v); // packed f16 pairs
        };
        if let Some(c) = self.arena.as_int_const(e) {
            let canon = canon_int(c, ty.bits().min(64), ty.is_signed_int());
            return Ok(if canon == c {
                v
            } else {
                Value::Scalar(self.arena.int(canon))
            });
        }
        let dst_bits = reg_bits(dst);
        if let Some(pair) = self.zero_extend_to_pair(ty.bits(), ty.is_signed_int(), dst_bits, e) {
            return Ok(pair);
        }
        if ty.bits() < dst_bits
            && ty.is_signed_int()
            && !self.arena.is_undefined(e)
            && !self.arena.is_concrete(e)
        {
            return Err(EvalError::Unsupported {
                pc,
                what: format!(
                    "symbolic value loaded at sub-register width \
                     ({}-bit load into a {}-bit register, thread {})",
                    ty.bits(),
                    dst_bits,
                    t
                ),
            });
        }
        Ok(v)
    }

    /// Widening product: operands are reinterpreted at the source type, and
    /// the product is exact in the 2x-wide destination type.
    fn mul_wide(&mut self, src_ty: ScalarType, a: ExprId, b: ExprId) -> ExprId {
        let a = self.canon_operand(src_ty, a);
        let b = self.canon_operand(src_ty, b);
        self.arena.mul(a, b)
    }

    /// High half of the widening product (nvcc's divide-by-constant idiom).
    /// Composed from existing nodes so it works symbolically and folds when
    /// concrete: `(a * b) >> bits`.
    fn mul_hi(&mut self, ty: ScalarType, a: ExprId, b: ExprId) -> ExprId {
        let a = self.canon_operand(ty, a);
        let b = self.canon_operand(ty, b);
        let bits = self.arena.int(ty.bits().min(64) as i64);
        let product = self.arena.mul(a, b);
        if ty.is_signed_int() {
            self.arena.shr(product, bits)
        } else {
            self.arena.lshr(product, bits)
        }
    }

    fn eval_cmp(
        &mut self,
        _pc: InstrId,
        cmp: CmpOp,
        ty: ScalarType,
        a: ExprId,
        b: ExprId,
    ) -> EvalResult<ExprId> {
        // Concrete integer comparisons need width/signedness care
        // (`setp.lt.u32` on canonical values would misorder negatives).
        if !ty.is_float()
            && let (Some(ca), Some(cb)) = (self.arena.as_i64(a), self.arena.as_i64(b))
        {
            let bits = ty.bits().min(64);
            let unsigned_cmp = matches!(cmp, CmpOp::Lo | CmpOp::Ls | CmpOp::Hi | CmpOp::Hs)
                || ty.is_unsigned_int()
                || ty.is_bits_type();
            let r = if unsigned_cmp {
                let (ua, ub) = (mask_to(ca, bits), mask_to(cb, bits));
                match cmp {
                    CmpOp::Eq | CmpOp::Equ => ua == ub,
                    CmpOp::Ne | CmpOp::Neu => ua != ub,
                    CmpOp::Lt | CmpOp::Lo | CmpOp::Ltu => ua < ub,
                    CmpOp::Le | CmpOp::Ls | CmpOp::Leu => ua <= ub,
                    CmpOp::Gt | CmpOp::Hi | CmpOp::Gtu => ua > ub,
                    CmpOp::Ge | CmpOp::Hs | CmpOp::Geu => ua >= ub,
                    CmpOp::Num => true,
                    CmpOp::Nan => false,
                }
            } else {
                let (sa, sb) = (canon_int(ca, bits, true), canon_int(cb, bits, true));
                match cmp {
                    CmpOp::Eq | CmpOp::Equ => sa == sb,
                    CmpOp::Ne | CmpOp::Neu => sa != sb,
                    CmpOp::Lt | CmpOp::Ltu => sa < sb,
                    CmpOp::Le | CmpOp::Leu => sa <= sb,
                    CmpOp::Gt | CmpOp::Gtu => sa > sb,
                    CmpOp::Ge | CmpOp::Geu => sa >= sb,
                    CmpOp::Lo | CmpOp::Ls | CmpOp::Hi | CmpOp::Hs => {
                        unreachable!("unsigned comparisons handled above")
                    }
                    CmpOp::Num => true,
                    CmpOp::Nan => false,
                }
            };
            return Ok(self.arena.bool_val(r));
        }

        // Symbolic: reinterpret a concrete side at the instruction type
        // first, exactly like eval_binop's fallback, so
        // `setp.eq.s32 %p, %sym, -1` and a compare against a
        // chain-computed 4294967295 build identical nodes. Over the
        // reals there are no NaNs, so unordered comparisons coincide
        // with their ordered counterparts.
        let a = self.canon_operand(ty, a);
        let b = self.canon_operand(ty, b);
        Ok(match cmp {
            CmpOp::Eq | CmpOp::Equ => self.arena.eq(a, b),
            CmpOp::Ne | CmpOp::Neu => self.arena.ne(a, b),
            CmpOp::Lt | CmpOp::Lo | CmpOp::Ltu => self.arena.lt(a, b),
            CmpOp::Le | CmpOp::Ls | CmpOp::Leu => self.arena.le(a, b),
            CmpOp::Gt | CmpOp::Hi | CmpOp::Gtu => self.arena.gt(a, b),
            CmpOp::Ge | CmpOp::Hs | CmpOp::Geu => self.arena.ge(a, b),
            CmpOp::Num => self.arena.bool_val(true),
            CmpOp::Nan => self.arena.bool_val(false),
        })
    }

    /// Apply a float value clamp (`.sat`/`.relu`) to a result expression.
    ///
    /// Over the floats-as-reals model these are exact: `.relu` is
    /// `max(r, 0)` and `.sat` is `min(max(r, 0), 1)`. Concrete operands
    /// fold through the arena's min/max constant folding. The spec's
    /// `.sat` additionally flushes a NaN result to +0.0 (and cvt's
    /// `.relu` canonicalizes NaN); NaN is out of model over the reals,
    /// as everywhere else in the interpreter.
    /// Decode a concrete fp8 byte (`decode` is one of `eval::fp8`'s
    /// decoders) into an exact real-valued `ExprId`, erroring loudly on the
    /// format's NaN encodings - Volta's real-valued model cannot represent
    /// NaN, same as every other NaN-ingestion point in the interpreter.
    /// `what` names the consuming instruction and format for the message.
    fn decode_fp8_byte(
        &mut self,
        pc: InstrId,
        what: &str,
        byte: u8,
        decode: fn(u8) -> Option<f64>,
    ) -> EvalResult<ExprId> {
        let value = decode(byte).ok_or_else(|| EvalError::Unsupported {
            pc,
            what: format!(
                "{what}: source byte {byte:#x} encodes NaN, which Volta's real-valued model \
                 cannot represent"
            ),
        })?;
        self.arena
            .float_from_f64(value)
            .map_err(|e| EvalError::Unsupported {
                pc,
                what: format!("{what} decoded constant: {e}"),
            })
    }

    fn apply_clamp(&mut self, clamp: Option<Clamp>, r: ExprId) -> ExprId {
        match clamp {
            None => r,
            Some(Clamp::Relu) => {
                let zero = self.arena.real(Real::zero());
                self.arena.max(r, zero)
            }
            Some(Clamp::Sat) => {
                let zero = self.arena.real(Real::zero());
                let one = self.arena.real(Real::one());
                let low_clamped = self.arena.max(r, zero);
                self.arena.min(low_clamped, one)
            }
        }
    }

    fn eval_cvt(
        &mut self,
        pc: InstrId,
        dst_ty: ScalarType,
        src_ty: ScalarType,
        a: ExprId,
    ) -> EvalResult<ExprId> {
        // Float-to-float conversions (f16 <-> f32 <-> f64) are the identity
        // over the reals; rounding is deliberately not modeled (paper).
        if dst_ty.is_float() && src_ty.is_float() {
            return Ok(a);
        }
        if src_ty.is_float() {
            return Err(EvalError::Unsupported {
                pc,
                what: format!("cvt float->int ({:?} -> {:?})", src_ty, dst_ty),
            });
        }
        // Integer source: cvt reads its source at the *source* format
        // first (ISA Table 15: "extension ... follows the source format"),
        // so a register canonicalized unsigned by its producer (`and.b32`
        // leaving 4294967288) reads as -8 under `cvt.s64.s32`. Symbolic
        // integers pass through (they are data, not addresses, so width
        // games cannot occur in a structured-CTA).
        let a = self.canon_operand(src_ty, a);
        if dst_ty.is_float() {
            return Ok(self.arena.to_float(a));
        }
        // ... then the result is renormalized at the destination width.
        if let Some(c) = self.arena.as_int_const(a) {
            let bits = dst_ty.bits().min(64);
            let r = canon_int(c, bits, dst_ty.is_signed_int());
            return Ok(self.arena.int(r));
        }
        Ok(a)
    }
}

/// Bit width of a register's storage class.
fn reg_bits(reg: RegId) -> u32 {
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

/// Zero-extend the low `bits` of `v` into a u64.
fn mask_to(v: i64, bits: u32) -> u64 {
    if bits >= 64 {
        v as u64
    } else {
        (v as u64) & ((1u64 << bits) - 1)
    }
}

/// Canonicalize the low `bits` of `v`: sign-extended if `signed`, else
/// zero-extended.
fn canon_int(v: i64, bits: u32, signed: bool) -> i64 {
    if bits >= 64 {
        return v;
    }
    let masked = mask_to(v, bits);
    if signed {
        let shift = 64 - bits;
        ((masked << shift) as i64) >> shift
    } else {
        masked as i64
    }
}

/// Decode a raw 16-bit IEEE 754 binary16 (`f16`) bit pattern to its real
/// value. `None` for NaN (the same "reject at ingestion" policy as every
/// other f64 entry point - see `Real::from_f64`); +/-infinity is `Some`
/// (finite `f64`, handled fine by `ExprArena::float_from_f64`).
fn f16_bits_to_f64(bits: u16) -> Option<f64> {
    let sign = if bits & 0x8000 != 0 { -1.0 } else { 1.0 };
    let exp = ((bits >> 10) & 0x1F) as i32;
    let mantissa = (bits & 0x3FF) as f64;
    Some(match exp {
        0 if mantissa == 0.0 => sign * 0.0,
        // Subnormal: 2^-14 * (mantissa / 1024) = mantissa * 2^-24.
        0 => sign * mantissa * 2f64.powi(-24),
        0x1F if mantissa == 0.0 => sign * f64::INFINITY,
        0x1F => return None,
        _ => sign * (1.0 + mantissa / 1024.0) * 2f64.powi(exp - 15),
    })
}

/// Decode a raw 16-bit `bf16` bit pattern to its real value. `bf16` is
/// exactly an `f32`'s high 16 bits (same 8-bit exponent/bias as `f32`,
/// truncated mantissa), so this is a plain bit-shift into `f32`, not a
/// hand-rolled decode. `None` for NaN, matching `f16_bits_to_f64`.
fn bf16_bits_to_f64(bits: u16) -> Option<f64> {
    let v = f32::from_bits((bits as u32) << 16) as f64;
    if v.is_nan() { None } else { Some(v) }
}

/// Split a raw 32-bit packed-pair bit pattern into its two lanes' real
/// values, per `lane_ty` (`F16` or `Bf16` - the element type of an
/// `F16x2`/`Bf16x2` operand). `(lo, hi)`, matching `Value::Pair`'s order.
fn decode_packed_bits(bits: u64, lane_ty: ScalarType) -> Option<(f64, f64)> {
    if lane_ty == ScalarType::F32 {
        // A 64-bit `f32x2` pattern: two IEEE singles, low lane first.
        let lo = f32::from_bits(bits as u32);
        let hi = f32::from_bits((bits >> 32) as u32);
        if lo.is_nan() || hi.is_nan() {
            return None;
        }
        return Some((lo as f64, hi as f64));
    }
    let lo_bits = (bits & 0xFFFF) as u16;
    let hi_bits = ((bits >> 16) & 0xFFFF) as u16;
    let decode = match lane_ty {
        ScalarType::F16 => f16_bits_to_f64,
        ScalarType::Bf16 => bf16_bits_to_f64,
        _ => unreachable!("decode_packed_bits only called for f16x2/bf16x2/f32x2 lanes"),
    };
    Some((decode(lo_bits)?, decode(hi_bits)?))
}

#[cfg(test)]
mod wgmma_reg_state_tests {
    use id_collections::Id;

    use super::WgmmaRegState;
    use crate::lowered::InstrId;
    use crate::symbols::RegId;
    use crate::tensor_core::MmaShape;
    use crate::types::RegClass;

    fn pc(n: u32) -> InstrId {
        InstrId::from_index(n)
    }

    fn reg(n: u32) -> RegId {
        RegId::new(RegClass::Bits32, n)
    }

    const S: MmaShape = MmaShape::new(64, 8, 16);
    const S2: MmaShape = MmaShape::new(64, 16, 16);

    /// Hazard A: a register nothing has ever written is not fenced -
    /// "before the first wgmma.mma_async in a warpgroup" (9.7.17.7.1).
    #[test]
    fn test_fence_hazard_before_first_wgmma_with_no_fence_ever() {
        let w = WgmmaRegState::default();
        assert!(!w.is_fenced_for(reg(0), S));
        assert_eq!(w.last_write_pc(reg(0)), None);
    }

    /// One `wgmma.fence` is enough to satisfy a never-written register.
    #[test]
    fn test_fence_clears_hazard_for_never_written_register() {
        let mut w = WgmmaRegState::default();
        w.fence();
        assert!(w.is_fenced_for(reg(0), S));
    }

    /// An ordinary write, then a wgmma access with no intervening fence,
    /// is a hazard.
    #[test]
    fn test_fence_hazard_ordinary_write_then_wgmma_without_fence() {
        let mut w = WgmmaRegState::default();
        w.record_write(reg(0), pc(1));
        assert!(!w.is_fenced_for(reg(0), S));
        assert_eq!(w.last_write_pc(reg(0)), Some(pc(1)));
    }

    /// The ISA's one exemption: a same-shape wgmma.mma_async accumulator
    /// chain needs zero fences between its own links.
    #[test]
    fn test_fence_exempt_same_shape_chain_needs_no_fence() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        assert!(w.is_fenced_for(reg(0), S));
    }

    /// The exemption is shape-specific: a different-shape wgmma access to
    /// the same register still needs a fence.
    #[test]
    fn test_fence_hazard_different_shape_chain_needs_fence() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        assert!(!w.is_fenced_for(reg(0), S2));
    }

    /// An ordinary write breaks an otherwise-exempt same-shape chain, even
    /// though the shape "would have" matched.
    #[test]
    fn test_fence_hazard_ordinary_write_breaks_same_shape_chain() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        w.record_write(reg(0), pc(2));
        assert!(!w.is_fenced_for(reg(0), S));
    }

    /// A register written after a fence, read by wgmma with no *new*
    /// fence, is still a hazard - the fence must come after the write.
    #[test]
    fn test_fence_hazard_write_after_fence_needs_its_own_fence() {
        let mut w = WgmmaRegState::default();
        w.fence();
        w.record_write(reg(0), pc(1));
        assert!(!w.is_fenced_for(reg(0), S));
        w.fence();
        assert!(w.is_fenced_for(reg(0), S));
    }

    /// Hazard B: a register a wgmma.mma_async wrote is pending until its
    /// wgmma-group is released.
    #[test]
    fn test_wait_group_pending_until_released() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        assert_eq!(w.pending_since(reg(0)), Some(pc(1)));
        w.commit_group();
        w.wait_group(0);
        assert_eq!(w.pending_since(reg(0)), None);
    }

    /// A register appearing in two interleaved, still-outstanding groups
    /// stays pending until *both* are released - releasing only the
    /// older one must not clear it.
    #[test]
    fn test_wait_group_pending_survives_partial_release() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        w.commit_group(); // group 0, contains reg(0)
        w.record_wgmma_write(reg(0), S, pc(2));
        w.commit_group(); // group 1, also contains reg(0)
        // Keep 1 group pending (group 1) - releases only group 0.
        w.wait_group(1);
        assert!(w.pending_since(reg(0)).is_some(), "still pending group 1");
        w.wait_group(0);
        assert_eq!(w.pending_since(reg(0)), None);
    }
}
