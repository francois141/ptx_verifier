//! Tensor Memory (PTX ISA 9.7.17.1): per-CTA 32-bit-cell scratch private to `tcgen05.*`, kept
//! apart from byte-addressed `Memory` (never an output; bounds set dynamically by `.alloc`).

use crate::eval::value::Value;

/// Lanes per CTA's Tensor Memory (PTX ISA 9.7.17.1).
pub const LANES: u32 = 128;
/// Columns per CTA's Tensor Memory (PTX ISA 9.7.17.1).
pub const COLUMNS: u32 = 512;

/// Failure modes of the Tensor Memory allocator. Carries no thread/pc
/// context - `eval/interp.rs` attaches that when converting to `EvalError`,
/// matching how `MemAccessError` (`eval/memory.rs`) stays decoupled from it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TensorMemError {
    /// `nCols` violated the ISA's "power of 2 in `[32, 512]`" rule
    /// (9.7.18.7.1: "the operand nCols must be a power of 2, in the range
    /// [32, 512]" - the unit of allocation is 32 columns).
    InvalidColumnCount { num_cols: u32 },
    /// An `.alloc` asked for more columns than the previous one (9.7.18.7.1:
    /// "The number of columns allocated should not increase between any
    /// two allocations in the execution order within the CTA").
    IncreasingColumnCount { previous: u32, requested: u32 },
    /// Not enough unallocated columns remain.
    OutOfSpace { requested: u32, available: u32 },
    /// `.alloc` after this CTA already relinquished its allocation permit.
    AllocAfterRelinquish,
    /// `.dealloc`'s `(taddr, nCols)` doesn't match any live allocation.
    DeallocMismatch { taddr: u32, num_cols: u32 },
    /// A `tcgen05.ld`/`.st` touched a column outside every live allocation.
    NotAllocated { lane: u32, col: u32 },
    /// An access's column range `[start_col, start_col + num_cols)` is not inside one live
    /// allocation: it starts outside every allocation, or runs past the end of its own.
    RangeOutsideAllocation { start_col: u32, num_cols: u32 },
}

/// The Tensor Memory allocator + cell store for the one modeled CTA. A bump allocator:
/// `.dealloc` frees a range but its columns are never reused - sound (no OOB or overlap
/// can slip through), only conservative about capacity across alloc/dealloc cycles.
#[derive(Debug, Clone, Default)]
pub struct TensorMemory {
    /// Currently-live allocations, as `(base_col, num_cols)`.
    allocated: Vec<(u32, u32)>,
    /// Never-decreasing bump pointer: the next unallocated column.
    high_water: u32,
    /// `nCols` of the most recent `.alloc`, which bounds every later one.
    last_alloc_cols: Option<u32>,
    permit_relinquished: bool,
    /// `LANES * COLUMNS` cells, empty until first touched. Cells hold whole [`Value`]s so
    /// packed `f16x2` `A` operands (`Value::Pair`) stored by `tcgen05.st` keep both halves
    /// symbolic for `tcgen05.mma`'s `[a-tmem]` form.
    cells: Vec<Option<Value>>,
}

impl TensorMemory {
    pub fn new() -> Self {
        Self::default()
    }

    /// Allocate `num_cols` columns, returning the base address at lane 0 (an allocation
    /// spans all `LANES` lanes; accesses add their own lane offset).
    pub fn alloc(&mut self, num_cols: u32) -> Result<u32, TensorMemError> {
        if self.permit_relinquished {
            return Err(TensorMemError::AllocAfterRelinquish);
        }
        if !(32..=COLUMNS).contains(&num_cols) || !num_cols.is_power_of_two() {
            return Err(TensorMemError::InvalidColumnCount { num_cols });
        }
        if let Some(previous) = self.last_alloc_cols
            && num_cols > previous
        {
            return Err(TensorMemError::IncreasingColumnCount {
                previous,
                requested: num_cols,
            });
        }
        let base = self.high_water;
        let new_high = base.checked_add(num_cols).filter(|&h| h <= COLUMNS).ok_or(
            TensorMemError::OutOfSpace {
                requested: num_cols,
                available: COLUMNS - base,
            },
        )?;
        self.high_water = new_high;
        self.last_alloc_cols = Some(num_cols);
        self.allocated.push((base, num_cols));
        Ok(base)
    }

    /// Deallocate the live range `(taddr, num_cols)`. Errors if no such
    /// exact range is currently allocated - catches a kernel deallocating
    /// with the wrong address/count, or double-deallocating.
    pub fn dealloc(&mut self, taddr: u32, num_cols: u32) -> Result<(), TensorMemError> {
        match self
            .allocated
            .iter()
            .position(|&(base, cols)| base == taddr && cols == num_cols)
        {
            Some(i) => {
                self.allocated.remove(i);
                Ok(())
            }
            None => Err(TensorMemError::DeallocMismatch { taddr, num_cols }),
        }
    }

    fn is_allocated(&self, col: u32) -> bool {
        self.allocated
            .iter()
            .any(|&(base, cols)| col >= base && col < base + cols)
    }

    /// Check that `[start_col, start_col + num_cols)` lies inside a single live allocation;
    /// per-cell [`Self::read`]/[`Self::write`] would pass a run into an adjacent allocation.
    pub fn check_range(&self, start_col: u32, num_cols: u32) -> Result<(), TensorMemError> {
        let end = u64::from(start_col) + u64::from(num_cols);
        if self
            .allocated
            .iter()
            .any(|&(base, cols)| base <= start_col && end <= u64::from(base) + u64::from(cols))
        {
            Ok(())
        } else {
            Err(TensorMemError::RangeOutsideAllocation {
                start_col,
                num_cols,
            })
        }
    }

    fn index(lane: u32, col: u32) -> usize {
        (lane * COLUMNS + col) as usize
    }

    /// Read cell `(lane, col)`: `Ok(None)` for an allocated, never-written cell (caller
    /// substitutes `Undefined`, as for `.shared`), `Err` if `col` isn't allocated.
    pub fn read(&self, lane: u32, col: u32) -> Result<Option<Value>, TensorMemError> {
        if !self.is_allocated(col) {
            return Err(TensorMemError::NotAllocated { lane, col });
        }
        Ok(self.cells.get(Self::index(lane, col)).copied().flatten())
    }

    /// Write cell `(lane, col)`. Errors if `col` isn't currently allocated.
    pub fn write(&mut self, lane: u32, col: u32, value: Value) -> Result<(), TensorMemError> {
        if !self.is_allocated(col) {
            return Err(TensorMemError::NotAllocated { lane, col });
        }
        if self.cells.is_empty() {
            self.cells = vec![None; (LANES * COLUMNS) as usize];
        }
        self.cells[Self::index(lane, col)] = Some(value);
        Ok(())
    }

    /// Mark this CTA as having relinquished its right to allocate further
    /// Tensor Memory (`tcgen05.relinquish_alloc_permit`).
    pub fn relinquish_alloc_permit(&mut self) {
        self.permit_relinquished = true;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn alloc_returns_increasing_bases_and_tracks_high_water() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(64), Ok(0));
        assert_eq!(tm.alloc(32), Ok(64));
        assert_eq!(tm.alloc(32), Ok(96));
    }

    #[test]
    fn alloc_rejects_an_increasing_column_count() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(32), Ok(0));
        assert_eq!(
            tm.alloc(64),
            Err(TensorMemError::IncreasingColumnCount {
                previous: 32,
                requested: 64
            })
        );
        // The bound is the previous *allocation*, not a live one: freeing
        // it does not lift it.
        assert_eq!(tm.dealloc(0, 32), Ok(()));
        assert_eq!(
            tm.alloc(64),
            Err(TensorMemError::IncreasingColumnCount {
                previous: 32,
                requested: 64
            })
        );
    }

    #[test]
    fn alloc_rejects_non_power_of_two_and_out_of_range() {
        let mut tm = TensorMemory::new();
        assert_eq!(
            tm.alloc(48),
            Err(TensorMemError::InvalidColumnCount { num_cols: 48 })
        );
        assert_eq!(
            tm.alloc(1024),
            Err(TensorMemError::InvalidColumnCount { num_cols: 1024 })
        );
        assert_eq!(
            tm.alloc(0),
            Err(TensorMemError::InvalidColumnCount { num_cols: 0 })
        );
        // Powers of two below the 32-column allocation unit.
        for num_cols in [1, 2, 4, 8, 16] {
            assert_eq!(
                tm.alloc(num_cols),
                Err(TensorMemError::InvalidColumnCount { num_cols })
            );
        }
    }

    #[test]
    fn alloc_rejects_once_out_of_space() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(512), Ok(0));
        assert_eq!(
            tm.alloc(32),
            Err(TensorMemError::OutOfSpace {
                requested: 32,
                available: 0
            })
        );
    }

    #[test]
    fn dealloc_requires_an_exact_live_match() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(32), Ok(0));
        assert_eq!(
            tm.dealloc(0, 64),
            Err(TensorMemError::DeallocMismatch {
                taddr: 0,
                num_cols: 64
            })
        );
        assert_eq!(tm.dealloc(0, 32), Ok(()));
        // Already deallocated - can't double-free.
        assert_eq!(
            tm.dealloc(0, 32),
            Err(TensorMemError::DeallocMismatch {
                taddr: 0,
                num_cols: 32
            })
        );
    }

    #[test]
    fn dealloc_does_not_reclaim_the_bump_pointer() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(32), Ok(0));
        assert_eq!(tm.dealloc(0, 32), Ok(()));
        // Even though [0, 32) is free again, the bump pointer doesn't
        // reclaim it - see the type's doc comment.
        assert_eq!(tm.alloc(32), Ok(32));
    }

    #[test]
    fn alloc_after_relinquish_is_rejected() {
        let mut tm = TensorMemory::new();
        tm.relinquish_alloc_permit();
        assert_eq!(tm.alloc(32), Err(TensorMemError::AllocAfterRelinquish));
    }

    fn fake_value(n: u32) -> Value {
        use id_collections::Id;
        Value::Scalar(Id::from_index(n))
    }

    #[test]
    fn read_write_roundtrip_within_an_allocation() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(32), Ok(0));
        let e = fake_value(7);
        assert_eq!(tm.write(5, 3, e), Ok(()));
        assert_eq!(tm.read(5, 3), Ok(Some(e)));
        // A different lane/column at the same allocation is untouched.
        assert_eq!(tm.read(5, 4), Ok(None));
        assert_eq!(tm.read(6, 3), Ok(None));
    }

    #[test]
    fn read_write_outside_any_allocation_is_rejected() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(32), Ok(0));
        assert_eq!(
            tm.read(0, 32),
            Err(TensorMemError::NotAllocated { lane: 0, col: 32 })
        );
        assert_eq!(
            tm.write(0, 32, fake_value(1)),
            Err(TensorMemError::NotAllocated { lane: 0, col: 32 })
        );
    }

    #[test]
    fn check_range_requires_a_single_allocation() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(32), Ok(0));
        assert_eq!(tm.alloc(32), Ok(32));
        assert_eq!(tm.check_range(0, 32), Ok(()));
        assert_eq!(tm.check_range(40, 8), Ok(()));
        // Every column is allocated, but the range straddles two
        // allocations.
        assert_eq!(
            tm.check_range(16, 32),
            Err(TensorMemError::RangeOutsideAllocation {
                start_col: 16,
                num_cols: 32
            })
        );
        // Past the last allocation.
        assert_eq!(
            tm.check_range(48, 32),
            Err(TensorMemError::RangeOutsideAllocation {
                start_col: 48,
                num_cols: 32
            })
        );
        assert_eq!(
            tm.check_range(64, 1),
            Err(TensorMemError::RangeOutsideAllocation {
                start_col: 64,
                num_cols: 1
            })
        );
    }

    #[test]
    fn dealloc_makes_reads_and_writes_fail_again() {
        let mut tm = TensorMemory::new();
        assert_eq!(tm.alloc(32), Ok(0));
        assert_eq!(tm.write(0, 0, fake_value(1)), Ok(()));
        assert_eq!(tm.dealloc(0, 32), Ok(()));
        assert_eq!(
            tm.read(0, 0),
            Err(TensorMemError::NotAllocated { lane: 0, col: 0 })
        );
    }
}
