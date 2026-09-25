//! χ-context race detection (paper Section 3.2).
//!
//! For every byte of shared and global memory, and every Tensor Memory cell,
//! we track:
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
//! An async-proxy (TMA/bulk copy) write needs *no* `fence.proxy.async`
//! before a later generic access of the same bytes: per PTX ISA 9.7.9.25.2,
//! "the completion of a `cp{.reduce}.async.bulk` operation is followed by an
//! implicit generic-async proxy fence", so observing the copy's completion
//! is itself what makes the bytes visible to the generic proxy - which is
//! why real TMA code (this repo's corpus, CUTLASS, Triton) reads a TMA
//! destination straight after an `mbarrier` wait and never fences. What such
//! an access does need is for the copy to have *completed*: `async_locks`
//! keeps a bulk copy's destination locked from issue until a waiter observes
//! the tracking mbarrier's phase (`eval::interp`'s `InflightBulkCopy`), so a
//! read that skips the wait is still caught - as an in-flight-copy hazard.
//! Non-bulk `cp.async` is a generic-proxy operation (PTX ISA 9.7.10.28.3)
//! and so is a generic read of its destination, so no proxy question
//! arises there either. Its destination is nonetheless exempt from the
//! generic-unfenced mark below: a bare reading of 8.6 makes a later
//! async-proxy read of a `cp.async` destination cross-proxy, but no
//! producer of such code fences it - NVIDIA's own
//! `sm100_mma_cpasync_warpspecialized` mainloop feeds `tcgen05.mma`
//! straight from `cp.async` with an `mbarrier` wait and no fence at all,
//! and Triton fences only register-to-shared copies
//! (`FenceInsertion.cpp`). Like a bulk copy, the async copy's completion
//! mechanism is what carries the ordering.
//!
//! The reverse direction *is* a real fence requirement, tracked here as
//! `generic_unfenced`: an async-proxy read (`tcgen05.mma` operands, via
//! [`RaceTracker::read_via`] with [`Proxy::Async`]) of bytes a generic write
//! landed needs a `fence.proxy.async` somewhere along the causality path
//! from the write to the read, i.e. either the *writer* fences after its
//! write (covering every reader), or the reader fences after synchronizing
//! with the writer (covering its own later async-proxy reads). A generic
//! read is unaffected, and so is an async-proxy read of bytes any
//! asynchronous copy landed (see
//! [`RaceTracker::clear_generic_unfenced`]).

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

/// A detected missing-`fence.proxy.async` hazard: an async-proxy read of
/// bytes a generic-proxy write landed, whose writer hasn't executed a
/// matching fence since.
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

/// A detected unsynchronized pair of Tensor Memory accesses to one cell.
#[derive(Debug, Clone, Copy)]
pub struct TensorMemRaceInfo {
    pub lane: u32,
    pub col: u32,
    pub prior: AccessSite,
    pub current: AccessSite,
}

/// One χ-tracked location: a byte of racy memory, or a 32-bit Tensor
/// Memory cell.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum ChiLoc {
    Mem(MemSpace, u64),
    TensorMem { lane: u32, col: u32 },
}

/// χ state for one location.
#[derive(Debug, Clone, Default)]
struct ChiCell {
    /// reader thread → (threads not yet synced with it, pc of the read)
    rd: HashMap<u32, (FixedBitSet, InstrId)>,
    /// last writer: (thread, threads not yet synced with it, pc of the write)
    wr: Option<(u32, FixedBitSet, InstrId)>,
}

/// One shared byte's "written via the generic proxy, writer not yet
/// fenced" state. `fenced_readers` are the other threads that executed
/// `fence.proxy.async` after synchronizing with the write: their own later
/// async-proxy reads are ordered after it.
#[derive(Debug, Clone)]
struct GenericUnfenced {
    site: AccessSite,
    fenced_readers: FixedBitSet,
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

/// χ-context tracker over all racy memory (shared + global + Tensor
/// Memory), plus in-flight `cp.async` lock state, plus in-flight
/// `tcgen05.ld`/`.st` lock state, plus the proxy-fence tracker.
#[derive(Debug)]
pub struct RaceTracker {
    n_threads: usize,
    /// Precomputed full thread set (the paper's 𝕀).
    all: FixedBitSet,
    cells: HashMap<ChiLoc, ChiCell>,
    async_locks: HashMap<(MemSpace, u64), AsyncLockCell>,
    /// Indexed by quadrant `0..4` (`(lane % 128) / 32`) - see `Tcgen05Pending`.
    tcgen05_pending: [Tcgen05Pending; 4],
    /// Shared bytes whose last write went through the generic proxy and
    /// whose writer has not executed `fence.proxy.async` since - see
    /// [`Self::mark_generic_unfenced`].
    generic_unfenced: HashMap<u64, GenericUnfenced>,
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
    /// [`Self::mark_generic_unfenced`]). A generic read needs no cross-proxy
    /// check at all: an async-proxy write becomes visible to the generic
    /// proxy at the copy's completion (PTX ISA 9.7.9.25.2).
    pub fn read_via(
        &mut self,
        space: MemSpace,
        addr: u64,
        width: u64,
        thread: ThreadId,
        pc: InstrId,
        proxy: Proxy,
    ) -> Result<(), MemHazard> {
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
        if proxy == Proxy::Async {
            self.check_generic_proxy_fence(space, addr, width, current)?;
        }
        for byte in addr..addr + width {
            self.chi_read(ChiLoc::Mem(space, byte), thread, pc)
                .map_err(|prior| {
                    MemHazard::Race(RaceInfo {
                        space,
                        addr: byte,
                        prior,
                        current,
                    })
                })?;
        }
        Ok(())
    }

    /// The paper's `noRacingWr` check plus read-set update for one
    /// location, returning the racing prior write on failure.
    fn chi_read(&mut self, loc: ChiLoc, thread: ThreadId, pc: InstrId) -> Result<(), AccessSite> {
        let t = thread.0;
        let cell = self.cells.entry(loc).or_default();
        if let Some((writer, pending, wpc)) = &cell.wr
            && *writer != t
            && pending.contains(t as usize)
        {
            return Err(AccessSite {
                thread: ThreadId(*writer),
                pc: *wpc,
                is_write: true,
            });
        }
        cell.rd.insert(t, (self.all.clone(), pc));
        Ok(())
    }

    /// The paper's `noRacingRd`/`noRacingWr` checks plus last-writer update
    /// for one location, returning the racing prior access on failure.
    /// `same_value`: see [`Self::write_with`].
    fn chi_write(
        &mut self,
        loc: ChiLoc,
        thread: ThreadId,
        pc: InstrId,
        same_value: bool,
    ) -> Result<(), AccessSite> {
        let t = thread.0;
        let cell = self.cells.entry(loc).or_default();
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
            return Err(AccessSite {
                thread: ThreadId(reader),
                pc: rpc,
                is_write: false,
            });
        }
        if !same_value
            && let Some((writer, pending, wpc)) = &cell.wr
            && *writer != t
            && pending.contains(t as usize)
        {
            return Err(AccessSite {
                thread: ThreadId(*writer),
                pc: *wpc,
                is_write: true,
            });
        }
        cell.wr = Some((t, self.all.clone(), pc));
        Ok(())
    }

    /// χ-checked read of Tensor Memory cell `(lane, col)` by `thread` -
    /// the same per-location rule as shared/global bytes, so every sync
    /// that orders memory (`bar.sync`, an mbarrier wait) orders Tensor
    /// Memory too. Needed because a `tcgen05.mma` issued by one thread
    /// writes all 128 lanes, so its `D` is read by *other* warps.
    pub fn tmem_read(
        &mut self,
        lane: u32,
        col: u32,
        thread: ThreadId,
        pc: InstrId,
    ) -> Result<(), TensorMemRaceInfo> {
        let current = AccessSite {
            thread,
            pc,
            is_write: false,
        };
        self.chi_read(ChiLoc::TensorMem { lane, col }, thread, pc)
            .map_err(|prior| TensorMemRaceInfo {
                lane,
                col,
                prior,
                current,
            })
    }

    /// χ-checked write of Tensor Memory cell `(lane, col)` - see
    /// [`Self::tmem_read`].
    pub fn tmem_write(
        &mut self,
        lane: u32,
        col: u32,
        thread: ThreadId,
        pc: InstrId,
    ) -> Result<(), TensorMemRaceInfo> {
        let current = AccessSite {
            thread,
            pc,
            is_write: true,
        };
        self.chi_write(ChiLoc::TensorMem { lane, col }, thread, pc, false)
            .map_err(|prior| TensorMemRaceInfo {
                lane,
                col,
                prior,
                current,
            })
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
        for byte in addr..addr + width {
            self.chi_write(ChiLoc::Mem(space, byte), thread, pc, same_value)
                .map_err(|prior| {
                    MemHazard::Race(RaceInfo {
                        space,
                        addr: byte,
                        prior,
                        current,
                    })
                })?;
        }
        Ok(())
    }

    /// For an async-proxy read: generic-proxy writes become visible to the
    /// async proxy only once their *writer* executes `fence.proxy.async`
    /// (before whatever sync orders them ahead of the reader), so a byte
    /// still in `generic_unfenced` is a hazard for any reader that has not
    /// itself fenced after synchronizing with the write.
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
        let reader = current.thread.0 as usize;
        match (addr..addr + width).find_map(|byte| {
            let cell = self.generic_unfenced.get(&byte)?;
            (!cell.fenced_readers.contains(reader)).then_some((byte, cell.site))
        }) {
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
    /// shared write on sm_90+ (gated by the caller); an async-proxy write to
    /// the same bytes supersedes the mark (see
    /// [`Self::clear_generic_unfenced`]).
    pub fn mark_generic_unfenced(&mut self, addr: u64, width: u64, thread: ThreadId, pc: InstrId) {
        let site = AccessSite {
            thread,
            pc,
            is_write: true,
        };
        for byte in addr..addr + width {
            self.generic_unfenced.insert(
                byte,
                GenericUnfenced {
                    site,
                    fenced_readers: FixedBitSet::new(),
                },
            );
        }
    }

    /// Drop the generic-proxy mark [`Self::mark_generic_unfenced`] left on
    /// shared `[addr, addr + width)` when an asynchronous copy's write
    /// landed through [`Self::write`]: a later async-proxy read of these
    /// bytes needs no `fence.proxy.async`, because the copy's own
    /// completion mechanism is what orders it. Call *after* the write
    /// itself. See the module docs for which copies qualify.
    pub fn clear_generic_unfenced(&mut self, addr: u64, width: u64) {
        if self.generic_unfenced.is_empty() {
            return;
        }
        for byte in addr..addr + width {
            self.generic_unfenced.remove(&byte);
        }
    }

    /// `fence.proxy.async{.global|.shared::cta|.shared::cluster}`: releases
    /// `thread`'s own generic-proxy writes to shared memory, and fences, for
    /// `thread`'s own later async-proxy reads, every other thread's generic
    /// write already synchronized with `thread` in χ (see
    /// [`Self::mark_generic_unfenced`]). A `.global`-restricted fence orders
    /// nothing in shared memory, so it clears nothing here.
    ///
    /// Scoped to one thread rather than a group - per the ISA, a
    /// bi-directional proxy fence "take[s] effect within a single thread",
    /// unlike `bar.sync`'s full-CTA effect.
    pub fn clear_async_proxy_fence(&mut self, thread: ThreadId, restrict: Option<MemSpace>) {
        if restrict.is_none_or(|r| r == MemSpace::Shared) {
            let t = thread.0 as usize;
            let cells = &self.cells;
            let n_threads = self.n_threads;
            self.generic_unfenced.retain(|&byte, cell| {
                if cell.site.thread == thread {
                    return false;
                }
                let synced = cells
                    .get(&ChiLoc::Mem(MemSpace::Shared, byte))
                    .and_then(|chi| chi.wr.as_ref())
                    .is_none_or(|(_, pending, _)| !pending.contains(t));
                if synced {
                    cell.fenced_readers.grow(n_threads);
                    cell.fenced_readers.insert(t);
                }
                true
            });
        }
    }

    /// Lock `[addr, addr + width)` in `space` as a `cp.async` destination:
    /// blocks all access (read or write, by any thread, including the
    /// issuing one) until [`Self::release_dst`] is called for the same
    /// range. Conflicts with an existing source lock too: the copy may
    /// land at any point of its window, so a byte an in-flight operation
    /// is still reading (a `tcgen05.mma` operand) must not be targeted.
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
            Err(MemHazard::GenericProxyUnfenced(h)) => {
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

    fn expect_generic_proxy_hazard(result: Result<(), MemHazard>) -> AsyncProxyFenceHazardInfo {
        match result {
            Err(MemHazard::GenericProxyUnfenced(info)) => info,
            Err(other) => panic!("expected a generic-proxy-fence hazard, got: {:?}", other),
            Ok(()) => panic!("expected a generic-proxy-fence hazard, got Ok"),
        }
    }

    /// PTX ISA 9.7.9.25.2: a completed async-proxy (TMA) write is visible to
    /// the generic proxy with no `fence.proxy.async` at all - by the issuing
    /// thread or any thread it has synchronized with.
    #[test]
    fn test_async_proxy_write_needs_no_fence_for_a_generic_read() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.clear_generic_unfenced(0x10, 4);
        chi.read(S, 0x10, 4, ThreadId(0), pc(2)).unwrap();
        chi.sync_all();
        chi.read(S, 0x10, 4, ThreadId(1), pc(3)).unwrap();
    }

    /// An async-proxy write supersedes the generic-proxy mark its landing
    /// left behind, so a later async-proxy read of those bytes is
    /// same-proxy and needs no fence either - while a generic write to the
    /// same bytes still does.
    #[test]
    fn test_async_proxy_write_supersedes_the_generic_unfenced_mark() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.mark_generic_unfenced(0x10, 4, ThreadId(0), pc(1));
        chi.clear_generic_unfenced(0x10, 4);
        chi.read_via(S, 0x10, 4, ThreadId(0), pc(2), Proxy::Async)
            .unwrap();

        chi.write(S, 0x10, 4, ThreadId(0), pc(3)).unwrap();
        chi.mark_generic_unfenced(0x10, 4, ThreadId(0), pc(3));
        let hazard =
            expect_generic_proxy_hazard(chi.read_via(S, 0x10, 4, ThreadId(0), pc(4), Proxy::Async));
        assert_eq!(hazard.prior.thread, ThreadId(0));
        assert!(hazard.prior.is_write);
    }

    /// `fence.proxy.async` releases the fencing thread's own generic writes;
    /// a `.global`-restricted fence orders nothing in shared memory.
    #[test]
    fn test_generic_proxy_fence_clear_is_restricted_by_state_space() {
        let mut chi = RaceTracker::new(4);
        chi.write(S, 0x10, 4, ThreadId(0), pc(1)).unwrap();
        chi.mark_generic_unfenced(0x10, 4, ThreadId(0), pc(1));
        chi.clear_async_proxy_fence(ThreadId(0), Some(MemSpace::Global));
        expect_generic_proxy_hazard(chi.read_via(S, 0x10, 4, ThreadId(0), pc(2), Proxy::Async));
        chi.clear_async_proxy_fence(ThreadId(0), Some(MemSpace::Shared));
        chi.read_via(S, 0x10, 4, ThreadId(0), pc(3), Proxy::Async)
            .unwrap();
    }
}
