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

/// Either kind of memory hazard `read`/`write` can report.
#[derive(Debug, Clone, Copy)]
pub enum MemHazard {
    Race(RaceInfo),
    AsyncCopy(AsyncHazardInfo),
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

/// χ-context tracker over all racy memory (shared + global), plus in-flight
/// `cp.async` lock state.
#[derive(Debug)]
pub struct RaceTracker {
    n_threads: usize,
    /// Precomputed full thread set (the paper's 𝕀).
    all: FixedBitSet,
    cells: HashMap<(MemSpace, u64), ChiCell>,
    async_locks: HashMap<(MemSpace, u64), AsyncLockCell>,
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
        }
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
            cell.wr = Some((t, self.all.clone(), pc));
        }
        Ok(())
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
}
