//! Tensor Memory (5th-generation TensorCore, PTX ISA 9.7.17.1): a small,
//! fixed-size, per-CTA scratch space private to `tcgen05.*` instructions.
//!
//! Represented as a dedicated allocator rather than reusing the general
//! byte-addressed `Memory` type used for global/shared/local: Tensor Memory
//! cells are always 32-bit (none of `Memory`'s packed-pair reinterpretation
//! logic applies - that exists for nvcc's f16x2/f32x2-in-regular-memory
//! idiom, not this dedicated hardware layout), the space is never itself a
//! kernel output (must be deallocated before the kernel exits, so no
//! dirty/output-footprint tracking is needed), and its valid bounds are
//! dynamic - tracked by `.alloc`/`.dealloc`, not declared upfront via launch
//! config the way `MemRegions` works for the other spaces.
//!
//! Cross-warp races don't apply here either (see the design discussion this
//! module implements): every `tcgen05` access is issued collectively by a
//! warp or warpgroup, and the ISA restricts each warp to its own quadrant of
//! Tensor Memory, so two warps legitimately touching the same cell without
//! synchronizing can't arise the way it can for `.shared`/`.global` - it
//! would already be undefined behavior per the ISA's own partitioning.

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
    /// (9.7.17.7: "The number of columns must be a power of 2... within the
    /// range [32, 512]").
    InvalidColumnCount { num_cols: u32 },
    /// Not enough unallocated columns remain.
    OutOfSpace { requested: u32, available: u32 },
    /// `.alloc` after this CTA already relinquished its allocation permit.
    AllocAfterRelinquish,
    /// `.dealloc`'s `(taddr, nCols)` doesn't match any live allocation.
    DeallocMismatch { taddr: u32, num_cols: u32 },
}

/// The Tensor Memory allocator for one CTA (this analysis models a single
/// CTA's execution, so one instance suffices - like `Interpreter::shared`,
/// not one per thread).
///
/// A bump allocator: `.dealloc` removes a range from `allocated` but never
/// lets a later `.alloc` reuse its columns. This is sound - it never permits
/// an out-of-bounds or overlapping access - just conservative about total
/// capacity across many alloc/dealloc cycles in one kernel; the kernels
/// driving this implementation allocate once near the start and deallocate
/// once near the end, so gap reuse isn't needed yet.
#[derive(Debug, Clone, Default)]
pub struct TensorMemory {
    /// Currently-live allocations, as `(base_col, num_cols)`.
    allocated: Vec<(u32, u32)>,
    /// Never-decreasing bump pointer: the next unallocated column.
    high_water: u32,
    permit_relinquished: bool,
}

impl TensorMemory {
    pub fn new() -> Self {
        Self::default()
    }

    /// Allocate `num_cols` columns, returning the base Tensor Memory address
    /// (lane 0, since an allocation spans all `LANES` lanes of its columns -
    /// individual `tcgen05.ld`/`.st`/`.mma` accesses add their own lane
    /// offset on top of this base).
    pub fn alloc(&mut self, num_cols: u32) -> Result<u32, TensorMemError> {
        if self.permit_relinquished {
            return Err(TensorMemError::AllocAfterRelinquish);
        }
        if num_cols == 0 || num_cols > COLUMNS || !num_cols.is_power_of_two() {
            return Err(TensorMemError::InvalidColumnCount { num_cols });
        }
        let base = self.high_water;
        let new_high = base.checked_add(num_cols).filter(|&h| h <= COLUMNS).ok_or(
            TensorMemError::OutOfSpace {
                requested: num_cols,
                available: COLUMNS - base,
            },
        )?;
        self.high_water = new_high;
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
        assert_eq!(tm.alloc(32), Ok(0));
        assert_eq!(tm.alloc(64), Ok(32));
        assert_eq!(tm.alloc(32), Ok(96));
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
}
