//! χ-context race detection (paper Section 3.2).
//!
//! For every byte of shared and global memory we track:
//!
//! - `rd`: for each thread that has read the byte, the set of threads that
//!   have *not* synchronized with it since that read, and
//! - `wr`: the last writer and the set of threads that have not synchronized
//!   with it since the write.
//!
//! A read races if the reader hasn't synchronized with the last writer
//! (`noRacingWr`); a write races if the writer hasn't synchronized with every
//! reader (`noRacingRd`) or the last writer. `sync(I)` removes `I` from the
//! pending sets of members of `I`. A full-CTA barrier empties every set, so
//! it is implemented as a wholesale clear.
//!
//! Access sites (thread, pc) are retained so races can be reported with both
//! source locations.
//!
//! Separately, `async_locks` tracks the in-flight window of every
//! uncompleted `cp.async` copy: its destination range is locked against all
//! access, its source range against writes only.
//!
//! A third, later state - `async_proxy_unfenced` - tracks the PTX ISA's
//! async-vs-generic-proxy ordering requirement (sm_90+ only): once a
//! `cp.async`/TMA copy's destination lock is released (the copy completed),
//! its bytes are *not yet* safe to access through any proxy until every
//! thread has executed a matching `fence.proxy.async`. This is deliberately
//! not the same window as `async_locks` (which ends the instant the copy
//! completes) or the same clearing rule as χ's full-CTA `bar.sync` (which
//! must *not* also satisfy this requirement - per the ISA, `bar.sync` alone
//! never provides cross-proxy ordering, only `fence.proxy.async` does).
//! Confirmed against the real corpus that this must be gated by target
//! arch, not applied unconditionally: `fence.proxy.async` isn't a legal
//! instruction below sm_90, and `kernels/astra2/
//! 260905094515_MatrixVectorMultiplicationFloat16Kernel_gpt-6-astra_max/
//! final_candidate.ptx` (`.target sm_89`) does exactly the pattern this
//! tracker would otherwise flag - `cp.async` write, `wait_group`,
//! `bar.sync`, `ldmatrix` read, zero `fence.proxy.async` - and is real,
//! correct, compiler-generated code. The gating itself lives in
//! `eval::interp`/`eval::target::TargetFeatures`, not here: this tracker is
//! a pure mechanism like `async_locks`, with no notion of target arch -
//! if `mark_async_proxy_unfenced` is never called, this map stays empty and
//! the check is a permanent no-op via the same pattern `async_locks` uses.
//!
//! That tracker covers *generic* accesses of async-proxy writes. The reverse
//! direction - an async-proxy read (`tcgen05.mma` operands, via
//! [`RaceTracker::read_via`] with [`Proxy::Async`]) of bytes a generic write
//! landed - is `generic_unfenced`: there the ISA puts the fence on the
//! *writer*, which must execute `fence.proxy.async` before the sync that
//! orders its write ahead of the tensor-core read. An async-proxy read skips
//! the `async_proxy_unfenced` check (same proxy as the write).

use std::collections::HashMap;

use fixedbitset::FixedBitSet;

use crate::eval::ThreadId;
use crate::eval::error::AccessSite;
use crate::lowered::{InstrId, MemSpace};

/// A detected race: the recorded prior access and the current one.
#[derive(Debug, Clone, Copy)]
pub struct RaceInfo {
    pub space: MemSpace,
    pub addr: u64,
    pub prior: AccessSite,
    pub current: AccessSite,
}

/// A detected in-flight `cp.async` hazard: an access that conflicts with a
/// still-uncompleted copy's lock.
#[derive(Debug, Clone, Copy)]
pub struct AsyncHazardInfo {
    pub space: MemSpace,
    pub addr: u64,
    pub prior: AccessSite,
    pub current: AccessSite,
}

/// A detected missing-`fence.proxy.async` hazard: an access to bytes an
/// async-proxy write (`cp.async`, TMA) landed, where the accessing thread
/// hasn't executed a matching fence since.
#[derive(Debug, Clone, Copy)]
pub struct AsyncProxyFenceHazardInfo {
    pub space: MemSpace,
    pub addr: u64,
    pub prior: AccessSite,
    pub current: AccessSite,
}

/// Any kind of memory hazard `read`/`write` can report.
#[derive(Debug, Clone, Copy)]
pub enum MemHazard {
    Race(RaceInfo),
    AsyncCopy(AsyncHazardInfo),
    AsyncProxyUnfenced(AsyncProxyFenceHazardInfo),
    /// An async-proxy read of bytes a generic-proxy write landed, the
    /// writer not having executed `fence.proxy.async` since.
    GenericProxyUnfenced(AsyncProxyFenceHazardInfo),
}

/// The PTX memory proxy an access goes through: ordinary loads/stores use
/// the generic proxy; tensor-core operand reads (`tcgen05.mma`) use the
/// async proxy, and ordering across the two needs `fence.proxy.async`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Proxy {
    Generic,
    Async,
}

/// In-flight `cp.async` lock state for one byte.
#[derive(Debug, Clone, Default)]
struct AsyncLockCell {
    /// Set while a destination range covers this byte: blocks all access
    /// until released. At most one copy may hold a byte this way.
    dst_holder: Option<(ThreadId, InstrId)>,
    /// Set while a source range covers this byte: blocks writes only.
    /// Multiple in-flight copies may legitimately share a source byte for
    /// reading.
    src_holders: Vec<(ThreadId, InstrId)>,
}

/// χ state for one byte.
#[derive(Debug, Clone, Default)]
struct ChiCell {
    /// reader thread → (threads not yet synced with it, pc of the read)
    rd: HashMap<u32, (FixedBitSet, InstrId)>,
    /// last writer: (thread, threads not yet synced with it, pc of the write)
    wr: Option<(u32, FixedBitSet, InstrId)>,
}

/// One byte's "written via the async proxy, not yet fenced" state. Unlike
/// `ChiCell.wr`'s pending set, `pending` is *not* seeded excluding the
/// writer's own thread: per the ISA, even the issuing thread must execute
/// `fence.proxy.async` before its own later access to these bytes is
/// well-defined (there is no `writer != t` exemption anywhere this is
/// checked, unlike every other hazard in this file).
#[derive(Debug, Clone)]
struct AsyncProxyUnfenced {
    site: AccessSite,
    pending: FixedBitSet,
}

/// A detected in-flight `tcgen05.ld`/`.st` hazard: an access to Tensor
/// Memory that conflicts with a still-unacknowledged (not yet `tcgen05.wait`
/// -ed) async op's column range.
#[derive(Debug, Clone, Copy)]
pub struct Tcgen05HazardInfo {
    pub quadrant: u32,
    pub start_col: u32,
    pub num_cols: u32,
    pub prior: AccessSite,
    pub current: AccessSite,
}

/// One warp-quadrant's pending async Tensor Memory `.ld`/`.st` footprints.
///
/// PTX ISA 9.7.17.8: a single `.ld`/`.st` always describes one contiguous
/// column range (`taddr` is warp-uniform, `.num` columns are consecutive)
/// within one lane quadrant (a warp only ever reaches its own quadrant - see
/// `eval/warp.rs`'s `tcgen05_lane`), so plain ranges suffice; no per-cell
/// tracking is needed, unlike the general `(MemSpace, u64)` address space
/// `cells`/`async_locks` above cover. `.wait::ld`/`::st` aren't scoped to an
/// address either - they unconditionally release *every* pending op of
/// their kind - so release is a clear, not a partial removal.
///
/// Conflict rule mirrors `AsyncLockCell`: a pending `.st` is a destination
/// lock (blocks *any* subsequent overlapping access, read or write); a
/// pending `.ld` is a source lock (blocks only a subsequent overlapping
/// write - concurrent reads of the same range are harmless).
#[derive(Debug, Clone, Default)]
struct Tcgen05Pending {
    /// `(start_col, num_cols, issuing access)` per un-waited `.ld`.
    ld: Vec<(u32, u32, AccessSite)>,
    /// `(start_col, num_cols, issuing access)` per un-waited `.st`.
    st: Vec<(u32, u32, AccessSite)>,
}

/// χ-context tracker over all racy memory (shared + global), plus in-flight
/// `cp.async` lock state, plus in-flight `tcgen05.ld`/`.st` lock state.
#[derive(Debug)]
pub struct RaceTracker {
    n_threads: usize,
    /// Precomputed full thread set (the paper's 𝕀).
    all: FixedBitSet,
    cells: HashMap<(MemSpace, u64), ChiCell>,
    async_locks: HashMap<(MemSpace, u64), AsyncLockCell>,
    /// Indexed by quadrant `0..4` (`(lane % 128) / 32`) - see `Tcgen05Pending`.
    tcgen05_pending: [Tcgen05Pending; 4],
    async_proxy_unfenced: HashMap<(MemSpace, u64), AsyncProxyUnfenced>,
    /// Shared bytes whose last write went through the generic proxy and
    /// whose writer has not executed `fence.proxy.async` since - see
    /// [`Self::mark_generic_unfenced`].
    generic_unfenced: HashMap<u64, AccessSite>,
}

impl RaceTracker {
    pub fn new(n_threads: usize) -> Self {
        let mut all = FixedBitSet::with_capacity(n_threads);
        all.set_range(.., true);
        Self {
            n_threads,
            all,
            cells: HashMap::new(),
            async_locks: HashMap::new(),
            tcgen05_pending: Default::default(),
            async_proxy_unfenced: HashMap::new(),
            generic_unfenced: HashMap::new(),
        }
    }

    /// Check `[start_col, start_col + num_cols)` in `quadrant` against
    /// pending `tcgen05` ops per the conflict rule on [`Tcgen05Pending`],
    /// and record `current` as newly pending if clear.
    pub fn tcgen05_begin(
        &mut self,
        quadrant: u32,
        start_col: u32,
        num_cols: u32,
        is_st: bool,
        current: AccessSite,
    ) -> Result<(), Tcgen05HazardInfo> {
        let end = start_col + num_cols;
        let overlaps = |&(s, n, _): &(u32, u32, AccessSite)| s < end && start_col < s + n;
        let q = &self.tcgen05_pending[quadrant as usize];
        let conflict = if is_st {
            q.ld.iter()
                .find(|e| overlaps(e))
                .or_else(|| q.st.iter().find(|e| overlaps(e)))
        } else {
            q.st.iter().find(|e| overlaps(e))
        };
        if let Some(&(_, _, prior)) = conflict {
            return Err(Tcgen05HazardInfo {
                quadrant,
                start_col,
                num_cols,
                prior,
                current,
            });
        }
        let q = &mut self.tcgen05_pending[quadrant as usize];
        let list = if is_st { &mut q.st } else { &mut q.ld };
        list.push((start_col, num_cols, current));
        Ok(())
    }

    /// Release every pending `.ld` (`is_st = false`) or `.st`
    /// (`is_st = true`) footprint in `quadrant` - `tcgen05.wait::ld`/`::st`.
    pub fn tcgen05_wait(&mut self, quadrant: u32, is_st: bool) {
        let q = &mut self.tcgen05_pending[quadrant as usize];
        if is_st { q.st.clear() } else { q.ld.clear() }
    }

    /// Record a read of `[addr, addr + width)` by `thread`, checking for a
    /// race with the last writer of each byte.
    ///
    /// The byte range cannot wrap: callers (`mem_read`) bounds-check the
    /// access first, and every region satisfies `base + size <= u64::MAX`
    /// (checked at region construction in `Interpreter::new`), so
    /// `addr + width` is always representable.
    pub fn read(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
    ) -> Result<(), MemHazard> {
        self.read_via(space, addr, width, thread, pc, Proxy::Generic)
    }

    /// [`Self::read`] through a given proxy. Through the async proxy (a
    /// `tcgen05.mma` operand read), bytes an async-proxy write landed need
    /// no proxy fence - same proxy - but bytes a *generic* write landed
    /// must have been fenced by their writer (see
    /// [`Self::mark_generic_unfenced`]).
    pub fn read_via(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
        proxy: Proxy,
    ) -> Result<(), MemHazard> {
        let t = thread.0;
        let current = AccessSite {
            thread,
            pc,
            is_write: false,
        };
        // Check for async copies
        if !self.async_locks.is_empty() {
            for byte in addr..addr + width {
                if let Some((holder, hpc)) = self
                    .async_locks
                    .get(&(space, byte))
                    .and_then(|cell| cell.dst_holder)
                {
                    return Err(MemHazard::AsyncCopy(AsyncHazardInfo {
                        space,
                        addr: byte,
                        prior: AccessSite {
                            thread: holder,
                            pc: hpc,
                            is_write: true,
                        },
                        current,
                    }));
                }
            }
        }
        match proxy {
            Proxy::Generic => {
                self.check_async_proxy_fence(space, addr, width, thread, pc, false)?
            }
            Proxy::Async => self.check_generic_proxy_fence(space, addr, width, current)?,
        }
        for byte in addr..addr + width {
            let cell = self.cells.entry((space, byte)).or_default();
            if let Some((writer, pending, wpc)) = &cell.wr
                && *writer != t
                && pending.contains(t as usize)
            {
                return Err(MemHazard::Race(RaceInfo {
                    space,
                    addr: byte,
                    prior: AccessSite {
                        thread: ThreadId(*writer),
                        pc: *wpc,
                        is_write: true,
                    },
                    current,
                }));
            }
            cell.rd.insert(t, (self.all.clone(), pc));
        }
        Ok(())
    }

    /// Record a write of `[addr, addr + width)` by `thread`, checking for a
    /// race with every recorded reader and the last writer of each byte.
    /// Following the paper's WrMem', the read sets are left unchanged.
    ///
    /// As for [`Self::read`], the byte range cannot wrap: accesses are
    /// bounds-checked against overflow-checked regions before reaching
    /// here.
    pub fn write(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
    ) -> Result<(), MemHazard> {
        self.write_with(space, addr, width, thread, pc, false)
    }

    /// [`Self::write`] with `same_value` set when the bytes already hold
    /// exactly the value being written (the same expression). Such a write
    /// cannot change the outcome whichever order the writers run in, so a
    /// write-write conflict with the previous writer is not a race: this is
    /// the warp-uniform store compilers emit deliberately (every lane of a
    /// warp storing the one reduced value to the same address). Conflicts
    /// with readers and with in-flight `cp.async` copies are still reported.
    pub fn write_with(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
        same_value: bool,
    ) -> Result<(), MemHazard> {
        let t = thread.0;
        let current = AccessSite {
            thread,
            pc,
            is_write: true,
        };
        // Check for async copies
        if !self.async_locks.is_empty() {
            for byte in addr..addr + width {
                let Some(cell) = self.async_locks.get(&(space, byte)) else {
                    continue;
                };
                if let Some((holder, hpc)) = cell.dst_holder {
                    return Err(MemHazard::AsyncCopy(AsyncHazardInfo {
                        space,
                        addr: byte,
                        prior: AccessSite {
                            thread: holder,
                            pc: hpc,
                            is_write: true,
                        },
                        current,
                    }));
                }
                if let Some(&(holder, hpc)) = cell.src_holders.first() {
                    return Err(MemHazard::AsyncCopy(AsyncHazardInfo {
                        space,
                        addr: byte,
                        prior: AccessSite {
                            thread: holder,
                            pc: hpc,
                            is_write: false,
                        },
                        current,
                    }));
                }
            }
        }
        self.check_async_proxy_fence(space, addr, width, thread, pc, true)?;
        for byte in addr..addr + width {
            let cell = self.cells.entry((space, byte)).or_default();
            // Report the lowest-numbered conflicting reader. HashMap
            // iteration order varies per instance, and a race verdict is
            // terminal, so completing the scan costs nothing and makes
            // the diagnostic deterministic across runs.
            if let Some((reader, rpc)) = cell
                .rd
                .iter()
                .filter(|(reader, (pending, _))| **reader != t && pending.contains(t as usize))
                .map(|(reader, (_, rpc))| (*reader, *rpc))
                .min_by_key(|&(reader, _)| reader)
            {
                return Err(MemHazard::Race(RaceInfo {
                    space,
                    addr: byte,
                    prior: AccessSite {
                        thread: ThreadId(reader),
                        pc: rpc,
                        is_write: false,
                    },
                    current,
                }));
            }
            if !same_value
                && let Some((writer, pending, wpc)) = &cell.wr
                && *writer != t
                && pending.contains(t as usize)
            {
                return Err(MemHazard::Race(RaceInfo {
                    space,
                    addr: byte,
                    prior: AccessSite {
                        thread: ThreadId(*writer),
                        pc: *wpc,
                        is_write: true,
                    },
                    current,
                }));
            }
            cell.wr = Some((t, self.all.clone(), pc));
        }
        Ok(())
    }

    /// Check `[addr, addr + width)` against outstanding unfenced
    /// async-proxy writes, per the module doc comment. Same `is_empty()`
    /// early-exit shape as the `async_locks` check above - a no-op unless
    /// [`Self::mark_async_proxy_unfenced`] has ever been called (which the
    /// caller gates by target arch - see `eval::target::TargetFeatures`).
    fn check_async_proxy_fence(
        &self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
        is_write: bool,
    ) -> Result<(), MemHazard> {
        if self.async_proxy_unfenced.is_empty() {
            return Ok(());
        }
        let t = thread.0 as usize;
        for byte in addr..addr + width {
            if let Some(cell) = self.async_proxy_unfenced.get(&(space, byte))
                && cell.pending.contains(t)
            {
                return Err(MemHazard::AsyncProxyUnfenced(AsyncProxyFenceHazardInfo {
                    space,
                    addr: byte,
                    prior: cell.site,
                    current: AccessSite {
                        thread,
                        pc,
                        is_write,
                    },
                }));
            }
        }
        Ok(())
    }

    /// The writer-side counterpart of [`Self::check_async_proxy_fence`], for
    /// an async-proxy read: generic-proxy writes become visible to the
    /// async proxy only once their *writer* executes `fence.proxy.async`
    /// (before whatever sync orders them ahead of the reader), so a byte
    /// still in `generic_unfenced` is a hazard whoever reads it.
    fn check_generic_proxy_fence(
        &self,
        space: MemSpace,
        addr: u64,
        width: u64,
        current: AccessSite,
    ) -> Result<(), MemHazard> {
        if space != MemSpace::Shared || self.generic_unfenced.is_empty() {
            return Ok(());
        }
        match (addr..addr + width).find_map(|byte| Some((byte, *self.generic_unfenced.get(&byte)?)))
        {
            Some((byte, prior)) => {
                Err(MemHazard::GenericProxyUnfenced(AsyncProxyFenceHazardInfo {
                    space,
                    addr: byte,
                    prior,
                    current,
                }))
            }
            None => Ok(()),
        }
    }

    /// Mark shared `[addr, addr + width)` as written through the generic
    /// proxy by `thread` and not yet fenced. Called for every generic
    /// shared write on sm_90+ (gated by the caller, like
    /// [`Self::mark_async_proxy_unfenced`]); an async-proxy write to the same
    /// bytes supersedes the mark.
    pub fn mark_generic_unfenced(&mut self, addr: u64, width: u64, thread: ThreadId, pc: InstrId) {
        let site = AccessSite {
            thread,
            pc,
            is_write: true,
        };
        for byte in addr..addr + width {
            self.generic_unfenced.insert(byte, site);
        }
    }

    /// Mark `[addr, addr + width)` as written via the async proxy but not
    /// yet fenced - call only *after* the write itself has already landed
    /// (through [`Self::write`]/[`Self::write_with`]), the same ordering
    /// [`Self::release_dst`] already requires relative to a `cp.async`
    /// copy's own deferred write: marking first would make that very write
    /// trip the hazard it just recorded.
    pub fn mark_async_proxy_unfenced(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
    ) {
        let site = AccessSite {
            thread,
            pc,
            is_write: true,
        };
        for byte in addr..addr + width {
            self.async_proxy_unfenced.insert(
                (space, byte),
                AsyncProxyUnfenced {
                    site,
                    pending: self.all.clone(),
                },
            );
            if space == MemSpace::Shared {
                self.generic_unfenced.remove(&byte);
            }
        }
    }

    /// `fence.proxy.async{.global|.shared::cta|.shared::cluster}`: clear
    /// `thread`'s own bit from every unfenced mark matching `restrict`
    /// (`None` = both spaces), dropping an entry once every thread has
    /// fenced it. Same "clear bits, drop if empty" shape as
    /// [`Self::sync_group`], but scoped to one thread rather than a group -
    /// per the ISA, a bi-directional proxy fence "take[s] effect within a
    /// single thread", unlike `bar.sync`'s full-CTA effect.
    ///
    /// Also releases `thread`'s own generic-proxy writes to shared memory
    /// (see [`Self::mark_generic_unfenced`]).
    pub fn clear_async_proxy_fence(&mut self, thread: ThreadId, restrict: Option<MemSpace>) {
        if restrict.is_none_or(|r| r == MemSpace::Shared) {
            self.generic_unfenced
                .retain(|_, site| site.thread != thread);
        }
        if self.async_proxy_unfenced.is_empty() {
            return;
        }
        let t = thread.0 as usize;
        self.async_proxy_unfenced.retain(|(space, _), cell| {
            if restrict.is_none_or(|r| r == *space) {
                cell.pending.set(t, false);
            }
            !cell.pending.is_clear()
        });
    }

    /// Lock `[addr, addr + width)` in `space` as a `cp.async` destination:
    /// blocks all access (read or write, by any thread, including the
    /// issuing one) until [`Self::release_dst`] is called for the same
    /// range.
    pub fn lock_dst(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
    ) -> Result<(), MemHazard> {
        let current = AccessSite {
            thread,
            pc,
            is_write: true,
        };
        for byte in addr..addr + width {
            if let Some((holder, hpc)) = self
                .async_locks
                .get(&(space, byte))
                .and_then(|cell| cell.dst_holder)
            {
                return Err(MemHazard::AsyncCopy(AsyncHazardInfo {
                    space,
                    addr: byte,
                    prior: AccessSite {
                        thread: holder,
                        pc: hpc,
                        is_write: true,
                    },
                    current,
                }));
            }
        }
        for byte in addr..addr + width {
            self.async_locks
                .entry((space, byte))
                .or_default()
                .dst_holder = Some((thread, pc));
        }
        Ok(())
    }

    /// Lock `[addr, addr + width)` in `space` as a `cp.async` source: blocks
    /// writes only.
    pub fn lock_src(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
    ) {
        for byte in addr..addr + width {
            self.async_locks
                .entry((space, byte))
                .or_default()
                .src_holders
                .push((thread, pc));
        }
    }

    /// Release a destination lock acquired by `lock_dst` for the same
    /// `(thread, pc)`.
    pub fn release_dst(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
    ) {
        for byte in addr..addr + width {
            if let Some(cell) = self.async_locks.get_mut(&(space, byte)) {
                debug_assert_eq!(
                    cell.dst_holder,
                    Some((thread, pc)),
                    "releasing a dst lock not held by this copy"
                );
                cell.dst_holder = None;
                if cell.src_holders.is_empty() {
                    self.async_locks.remove(&(space, byte));
                }
            }
        }
    }

    /// Release one source lock instance acquired by `lock_src` for the same
    /// `(thread, pc)`.
    pub fn release_src(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
    ) {
        for byte in addr..addr + width {
            if let Some(cell) = self.async_locks.get_mut(&(space, byte)) {
                if let Some(pos) = cell
                    .src_holders
                    .iter()
                    .position(|&(h, p)| h == thread && p == pc)
                {
                    cell.src_holders.swap_remove(pos);
                }
                if cell.dst_holder.is_none() && cell.src_holders.is_empty() {
                    self.async_locks.remove(&(space, byte));
                }
            }
        }
    }

    /// Synchronize the full CTA: every pending set becomes empty, so drop
    /// all state. Exact per the paper's `syncMem` with `I = 𝕀`.
    pub fn sync_all(&mut self) {
        self.cells.clear();
    }

    /// Synchronize the threads in `group` (a warp or mask subset): members of
    /// the group are removed from the pending sets of members of the group.
    pub fn sync_group(&mut self, group: &FixedBitSet) {
        debug_assert_eq!(group.len(), self.n_threads);
        self.cells.retain(|_, cell| {
            cell.rd.retain(|reader, (pending, _)| {
                if group.contains(*reader as usize) {
                    pending.difference_with(group);
                    !pending.is_clear()
                } else {
                    true
                }
            });
            if let Some((writer, pending, _)) = &mut cell.wr
                && group.contains(*writer as usize)
            {
                pending.difference_with(group);
                if pending.is_clear() {
                    cell.wr = None;
                }
            }
            !(cell.rd.is_empty() && cell.wr.is_none())
        });
    }

    /// Exactly `sync_group(participants ∪ {w})` for every `w` in
    /// `waiters` in turn (an mbarrier phase's waiters each synchronize
    /// with its arrivers, not with one another), in one pass over χ: a
    /// participant's accesses lose every group they belong to
    /// (`participants ∪ waiters`); a non-participant waiter's accesses
    /// lose only its own group.
    // TODO: understand this batching and its equivalence argument in more
    // detail (see `batched_waiter_sync_matches_sequential_sync_groups`).
    pub fn sync_mbarrier_waiters(&mut self, participants: &FixedBitSet, waiters: &FixedBitSet) {
        debug_assert_eq!(participants.len(), self.n_threads);
        debug_assert_eq!(waiters.len(), self.n_threads);
        let mut all_groups = participants.clone();
        all_groups.union_with(waiters);
        let mut own_group = participants.clone();
        let mut remove = |accessor: usize, pending: &mut FixedBitSet| {
            if participants.contains(accessor) {
                pending.difference_with(&all_groups);
            } else if waiters.contains(accessor) {
                own_group.insert(accessor);
                pending.difference_with(&own_group);
                own_group.set(accessor, false);
            }
        };
        self.cells.retain(|_, cell| {
            cell.rd.retain(|reader, (pending, _)| {
                remove(*reader as usize, pending);
                !pending.is_clear()
            });
            if let Some((writer, pending, _)) = &mut cell.wr {
                remove(*writer as usize, pending);
                if pending.is_clear() {
                    cell.wr = None;
                }
            }
            !(cell.rd.is_empty() && cell.wr.is_none())
        });
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const S: MemSpace = MemSpace::Shared;

    fn pc(n: u32) -> InstrId {
        use id_collections::Id;
        InstrId::from_index(n)
    }

    fn group(n_threads: usize, members: &[u32]) -> FixedBitSet {
        let mut g = FixedBitSet::with_capacity(n_threads);
        for &m in members {
            g.insert(m as usize);
        }
        g
    }

    /// Unwrap a `read`/`write` error as a `RaceInfo`, panicking if it was
    /// actually an async-copy hazard.
    fn expect_race(result: Result<(), MemHazard>) -> RaceInfo {
        match result {
            Err(MemHazard::Race(info)) => info,
            Err(MemHazard::AsyncCopy(h)) => panic!("expected a race, got an async hazard: {:?}", h),
            Err(MemHazard::AsyncProxyUnfenced(h) | MemHazard::GenericProxyUnfenced(h)) => {
                panic!("expected a race, got a proxy-fence hazard: {:?}", h)
            }
            Ok(()) => panic!("expected a race, got Ok"),
        }
    }

    #[test]
    fn test_write_read_race() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        // Another thread reads without a sync: race.
        let err = expect_race(chi.read(S, 0x10, 4, ThreadId(1), pc(2)));
        assert_eq!(err.prior.thread, ThreadId(0));
        assert!(err.prior.is_write);
    }

    #[test]
    fn test_read_write_race() {
        let mut chi = RaceTracker::new(4);
        chi.read(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        let err = expect_race(chi.write(S, 0x10, 4, ThreadId(1), pc(2)));
        assert_eq!(err.prior.thread, ThreadId(0));
        assert!(!err.prior.is_write);
    }

    #[test]
    fn test_read_read_no_race() {
        let mut chi = RaceTracker::new(4);
        chi.read(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.read(S, 0x10, 4, ThreadId(1), pc(2)).unwrap();
    }

    #[test]
    fn test_same_thread_no_race() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.read(S, 0x10, 4, ThreadId(0), pc(2)).unwrap();
        chi.write(S, 0x10, 4, ThreadId(0), pc(3)).unwrap();
    }

    #[test]
    fn test_barrier_clears() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.sync_all();
        chi.read(S, 0x10, 4, ThreadId(1), pc(2)).unwrap();
        chi.write(S, 0x10, 4, ThreadId(2), pc(3)).unwrap_err();
    }

    #[test]
    fn test_warp_sync_only_covers_group() {
        let mut chi = RaceTracker::new(64);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        // Threads 0-31 sync; thread 1 may now read, thread 32 may not.
        chi.sync_group(&group(64, &(0..32).collect::<Vec<_>>()));
        chi.read(S, 0x10, 4, ThreadId(1), pc(2)).unwrap();
        let err = expect_race(chi.read(S, 0x10, 4, ThreadId(32), pc(3)));
        assert_eq!(err.prior.thread, ThreadId(0));
    }

    #[test]
    fn test_disjoint_bytes_no_race() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.write(S, 0x14, 4, ThreadId(1), pc(2)).unwrap();
    }

    #[test]
    fn test_overlapping_bytes_race() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        // Writes [0x12, 0x16) overlapping [0x10, 0x14).
        let err = expect_race(chi.write(S, 0x12, 4, ThreadId(1), pc(2)));
        assert_eq!(err.addr, 0x12);
    }

    #[test]
    fn test_write_then_write_after_read_still_races_with_reader() {
        // WrMem' keeps rd unchanged: after t0 reads and t1 writes (with a
        // sync in between covering t0/t1 only), a write by t2 must still
        // race with t0's read.
        let mut chi = RaceTracker::new(4);
        chi.read(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.sync_group(&group(4, &[0, 1]));
        chi.write(S, 0x10, 4, ThreadId(1), pc(2)).unwrap();
        let err = expect_race(chi.write(S, 0x10, 4, ThreadId(2), pc(3)));
        assert_eq!(err.prior.thread, ThreadId(0));
        assert!(!err.prior.is_write);
    }

    #[test]
    fn test_race_report_names_the_lowest_conflicting_reader() {
        // Several threads read the same byte; the reported victim must be
        // the lowest-numbered conflicting reader regardless of HashMap
        // iteration order (which varies per map instance). Two trackers
        // with different insertion orders must agree.
        for order in [[5u32, 2, 9], [9, 5, 2]] {
            let mut chi = RaceTracker::new(16);
            for t in order {
                chi.read(S, 0x10, 1, ThreadId(t), pc(t)).unwrap();
            }
            let err = expect_race(chi.write(S, 0x10, 1, ThreadId(0), pc(100)));
            assert_eq!(err.prior.thread, ThreadId(2));
            assert_eq!(err.prior.pc, pc(2));
            assert!(!err.prior.is_write);
        }
    }

    fn site(t: u32, p: u32, is_write: bool) -> AccessSite {
        AccessSite {
            thread: ThreadId(t),
            pc: pc(p),
            is_write,
        }
    }

    #[test]
    fn test_tcgen05_concurrent_ld_no_conflict() {
        // Multiple in-flight loads of the same range are fine (src_holders'
        // "multiple in-flight copies may legitimately share a source byte
        // for reading" rule, mirrored for tcgen05 pending loads).
        let mut chi = RaceTracker::new(32);
        chi.tcgen05_begin(0, 0, 64, false, site(0, 1, false))
            .unwrap();
        chi.tcgen05_begin(0, 0, 64, false, site(0, 2, false))
            .unwrap();
    }

    #[test]
    fn test_tcgen05_st_conflicts_with_pending_ld() {
        let mut chi = RaceTracker::new(32);
        chi.tcgen05_begin(0, 0, 64, false, site(0, 1, false))
            .unwrap();
        let err = chi
            .tcgen05_begin(0, 32, 32, true, site(0, 2, true))
            .unwrap_err();
        assert_eq!(err.prior.pc, pc(1));
        assert!(!err.prior.is_write);
    }

    #[test]
    fn test_tcgen05_ld_conflicts_with_pending_st() {
        let mut chi = RaceTracker::new(32);
        chi.tcgen05_begin(0, 0, 64, true, site(0, 1, true)).unwrap();
        let err = chi
            .tcgen05_begin(0, 32, 32, false, site(0, 2, false))
            .unwrap_err();
        assert_eq!(err.prior.pc, pc(1));
        assert!(err.prior.is_write);
    }

    #[test]
    fn test_tcgen05_st_conflicts_with_pending_st() {
        // A second pending write to an overlapping range - "at most one
        // copy may hold a byte this way" for the destination-lock side.
        let mut chi = RaceTracker::new(32);
        chi.tcgen05_begin(0, 0, 64, true, site(0, 1, true)).unwrap();
        let err = chi
            .tcgen05_begin(0, 0, 64, true, site(0, 2, true))
            .unwrap_err();
        assert_eq!(err.prior.pc, pc(1));
    }

    #[test]
    fn test_tcgen05_non_overlapping_ranges_do_not_conflict() {
        let mut chi = RaceTracker::new(32);
        chi.tcgen05_begin(0, 0, 32, true, site(0, 1, true)).unwrap();
        chi.tcgen05_begin(0, 32, 32, true, site(0, 2, true))
            .unwrap();
    }

    #[test]
    fn test_tcgen05_wait_releases_only_its_own_kind_and_quadrant() {
        let mut chi = RaceTracker::new(32);
        // Non-overlapping ranges, so the pending .ld and .st below coexist
        // without conflicting with *each other*.
        chi.tcgen05_begin(0, 0, 32, false, site(0, 1, false))
            .unwrap();
        chi.tcgen05_begin(0, 64, 32, true, site(0, 2, true))
            .unwrap();
        // Waiting on .st in quadrant 0 must not release the pending .ld -
        // a subsequent .st at the .ld's range still conflicts with it.
        chi.tcgen05_wait(0, true);
        let err = chi
            .tcgen05_begin(0, 0, 32, true, site(0, 3, true))
            .unwrap_err();
        assert!(!err.prior.is_write);

        // A different quadrant is entirely unaffected by quadrant 0's
        // pending state.
        chi.tcgen05_begin(1, 0, 32, true, site(1, 4, true)).unwrap();

        // Waiting on .ld in quadrant 0 releases it; the same range is now free.
        chi.tcgen05_wait(0, false);
        chi.tcgen05_begin(0, 0, 32, false, site(0, 5, false))
            .unwrap();
    }

    fn expect_async_proxy_hazard(result: Result<(), MemHazard>) -> AsyncProxyFenceHazardInfo {
        match result {
            Err(MemHazard::AsyncProxyUnfenced(info)) => info,
            Err(other) => panic!("expected an async-proxy-fence hazard, got: {:?}", other),
            Ok(()) => panic!("expected an async-proxy-fence hazard, got Ok"),
        }
    }

    /// The one deliberate difference from every other hazard in this file:
    /// the *same* thread that performed the unfenced async-proxy write is
    /// still blocked by it, not exempted the way `ChiCell.wr`'s `writer !=
    /// t` check would exempt a same-thread write-then-read.
    #[test]
    fn test_async_proxy_fence_writer_itself_is_not_exempt() {
        let mut chi = RaceTracker::new(4);
        chi.mark_async_proxy_unfenced(S, 0x10, 4, ThreadId(0), pc(1));
        let hazard = expect_async_proxy_hazard(chi.read(S, 0x10, 4, ThreadId(0), pc(2)));
        assert_eq!(hazard.prior.thread, ThreadId(0));
        assert!(hazard.prior.is_write);
    }

    /// `clear_async_proxy_fence` only clears the fencing thread's own bit -
    /// per the ISA, a bi-directional proxy fence "takes effect within a
    /// single thread". Thread 0 fencing must not unblock thread 1.
    #[test]
    fn test_async_proxy_fence_clear_releases_only_the_fencing_thread() {
        let mut chi = RaceTracker::new(4);
        chi.mark_async_proxy_unfenced(S, 0x10, 4, ThreadId(0), pc(1));
        chi.clear_async_proxy_fence(ThreadId(0), None);
        // Thread 0 fenced: its own access now succeeds.
        chi.read(S, 0x10, 4, ThreadId(0), pc(2)).unwrap();
        // Thread 1 never fenced: still blocked.
        expect_async_proxy_hazard(chi.write(S, 0x10, 4, ThreadId(1), pc(3)));
    }

    /// A `.global`-restricted fence must not clear a `Shared`-space mark,
    /// and vice versa - the restriction is a real per-space filter, not
    /// just documentation.
    #[test]
    fn test_async_proxy_fence_restrict_to_one_space_does_not_clear_the_other() {
        const G: MemSpace = MemSpace::Global;
        let mut chi = RaceTracker::new(4);
        chi.mark_async_proxy_unfenced(G, 0x10, 4, ThreadId(0), pc(1));
        chi.mark_async_proxy_unfenced(S, 0x20, 4, ThreadId(0), pc(2));
        chi.clear_async_proxy_fence(ThreadId(0), Some(MemSpace::Global));
        // The Global mark is cleared...
        chi.read(G, 0x10, 4, ThreadId(0), pc(3)).unwrap();
        // ...but the Shared mark is untouched.
        expect_async_proxy_hazard(chi.read(S, 0x20, 4, ThreadId(0), pc(4)));
    }

    /// An unrestricted fence (`restrict: None`, e.g. bare `fence.proxy.async;`)
    /// clears both spaces at once.
    #[test]
    fn test_async_proxy_fence_unrestricted_clear_covers_both_spaces() {
        const G: MemSpace = MemSpace::Global;
        let mut chi = RaceTracker::new(4);
        chi.mark_async_proxy_unfenced(G, 0x10, 4, ThreadId(0), pc(1));
        chi.mark_async_proxy_unfenced(S, 0x20, 4, ThreadId(0), pc(2));
        chi.clear_async_proxy_fence(ThreadId(0), None);
        chi.read(G, 0x10, 4, ThreadId(0), pc(3)).unwrap();
        chi.read(S, 0x20, 4, ThreadId(0), pc(4)).unwrap();
    }

    /// [`RaceTracker::sync_mbarrier_waiters`] must leave χ in exactly the
    /// state that `sync_group(participants ∪ {w})` for each waiter `w` in
    /// turn leaves it - the equivalence its single pass is built on. Driven
    /// over pseudo-random access histories because the evaluator's own tests
    /// never put two threads on one barrier's phase at once.
    #[test]
    fn batched_waiter_sync_matches_sequential_sync_groups() {
        const N_THREADS: usize = 12;
        const N_ADDRS: u64 = 6;

        type Snapshot = Vec<(u64, Vec<(u32, Vec<usize>)>, Option<(u32, Vec<usize>)>)>;

        /// χ reduced to a deterministically ordered, comparable form.
        fn snapshot(chi: &RaceTracker) -> Snapshot {
            let mut cells: Snapshot = chi
                .cells
                .iter()
                .map(|(&(_, addr), cell)| {
                    let mut readers: Vec<(u32, Vec<usize>)> = cell
                        .rd
                        .iter()
                        .map(|(&reader, (pending, _))| (reader, pending.ones().collect()))
                        .collect();
                    readers.sort();
                    let writer = cell
                        .wr
                        .as_ref()
                        .map(|(writer, pending, _)| (*writer, pending.ones().collect()));
                    (addr, readers, writer)
                })
                .collect();
            cells.sort();
            cells
        }

        /// A deterministic pseudo-random access history (xorshift64).
        fn history(seed: u64) -> RaceTracker {
            let mut chi = RaceTracker::new(N_THREADS);
            let mut x = seed | 1;
            for step in 0..120u32 {
                x ^= x << 13;
                x ^= x >> 7;
                x ^= x << 17;
                let thread = ThreadId((x % N_THREADS as u64) as u32);
                let addr = (x >> 8) % N_ADDRS;
                // Hazards are irrelevant here: either way the access is
                // recorded in χ, which is what is being compared.
                let _ = if (x >> 20) & 1 == 0 {
                    chi.write_with(S, addr, 1, thread, pc(step), false)
                } else {
                    chi.read(S, addr, 1, thread, pc(step))
                };
            }
            chi
        }

        let cases: [(&[u32], &[u32]); 5] = [
            (&[0, 1, 2], &[3, 4]),
            (&[0, 1], &[1, 2, 3]),
            (&[5], &[5]),
            (&[2, 7, 9], &[0, 2, 11]),
            (&[], &[1, 2]),
        ];
        for seed in 1..40u64 {
            for (participants, waiters) in cases {
                let arrived = group(N_THREADS, participants);
                let woken = group(N_THREADS, waiters);

                let mut sequential = history(seed);
                for &waiter in waiters {
                    let mut one = arrived.clone();
                    one.insert(waiter as usize);
                    sequential.sync_group(&one);
                }

                let mut batched = history(seed);
                batched.sync_mbarrier_waiters(&arrived, &woken);

                assert_eq!(
                    snapshot(&sequential),
                    snapshot(&batched),
                    "seed {seed}, participants {participants:?}, waiters {waiters:?}"
                );
            }
        }
    }
}
