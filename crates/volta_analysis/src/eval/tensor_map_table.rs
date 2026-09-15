//! `tensormap` object state: a side table of named fields, keyed by the
//! concrete `(space, address)` the tensor-map object is created/accessed
//! at (PTX ISA 5.5.8, 9.7.9.27 `tensormap.replace`).
//!
//! The ISA declares the tensor-map a 128-byte *opaque* object with an
//! undefined binary layout - only `tensormap.replace`'s named-field
//! interface is specified. Volta therefore never models literal
//! tensor-map bytes (unlike ordinary memory); each entry here holds the
//! fields `.replace` has written so far, `None`/absent until then.

use std::collections::HashMap;

use crate::lowered::MemSpace;
use crate::tensor_map::{
    TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorSwizzleAtomicity,
    TensorSwizzleMode,
};

/// One tensor-map object's fields, as populated by `tensormap.replace`.
/// Per-dimension fields are sparse (keyed by `ord`) rather than
/// fixed-size: `.rank` may be written before or after the per-dimension
/// fields in source order, so nothing here can assume a dimension count
/// up front - completeness (every `ord` in the field's valid range
/// present) is checked only once the entry is actually used, by whichever
/// instruction consumes it (`eval::interp`'s `cp.async.bulk.tensor`
/// handling).
///
/// `new_val` operands are resolved to concrete integers at `.replace` time
/// (not kept symbolic): every field here ultimately shapes an address
/// (PTX ISA 9.7.9.26.5.2's addressing formula), and Volta already requires
/// concreteness for anything address-shaping (`Interpreter::effective_addr`
/// and friends) - deferring it here would just move the same `NotConcrete`
/// error to a confusing place, two instructions away from the register
/// write that was actually symbolic.
#[derive(Debug, Clone, Default)]
pub struct TensorMapEntry {
    pub global_address: Option<u64>,
    /// Zero-based: the real tensor rank is `rank + 1` (PTX ISA 9.7.9.27's
    /// "operand `new_val` must be one less than the desired tensor rank").
    pub rank: Option<u32>,
    pub box_dim: HashMap<u32, u32>,
    pub global_dim: HashMap<u32, u64>,
    pub global_stride: HashMap<u32, u64>,
    pub element_stride: HashMap<u32, u32>,
    pub elemtype: Option<TensorElemType>,
    pub interleave_layout: Option<TensorInterleaveLayout>,
    pub swizzle_mode: Option<TensorSwizzleMode>,
    pub swizzle_atomicity: Option<TensorSwizzleAtomicity>,
    pub fill_mode: Option<TensorFillMode>,
}

/// Every live tensor-map object in one kernel run.
#[derive(Debug, Clone, Default)]
pub struct TensorMapTable {
    entries: HashMap<(MemSpace, u64), TensorMapEntry>,
}

impl TensorMapTable {
    pub fn new() -> Self {
        Self::default()
    }

    /// Get-or-create the entry at `(space, addr)` for a `tensormap.replace`
    /// write. There is no `tensormap.init`-like instruction - a tensor-map
    /// object comes into existence at its first field write (this
    /// candidate kernel's own idiom: build one entirely in shared memory
    /// via a sequence of `.replace` calls).
    pub fn entry_mut(&mut self, space: MemSpace, addr: u64) -> &mut TensorMapEntry {
        self.entries.entry((space, addr)).or_default()
    }

    pub fn get(&self, space: MemSpace, addr: u64) -> Option<&TensorMapEntry> {
        self.entries.get(&(space, addr))
    }

    /// `tensormap.cp_fenceproxy`: materialize a structured copy of the
    /// entry at `(src_space, src_addr)` at `(dst_space, dst_addr)` - a copy
    /// of the *named fields*, matching the ISA's "opaque object" framing
    /// (there are no literal bytes to copy). `None` if there is no source
    /// entry yet.
    pub fn copy_entry(
        &mut self,
        dst_space: MemSpace,
        dst_addr: u64,
        src_space: MemSpace,
        src_addr: u64,
    ) -> Option<()> {
        let src = self.entries.get(&(src_space, src_addr))?.clone();
        self.entries.insert((dst_space, dst_addr), src);
        Some(())
    }
}

/// Translate a tensor-map's (`.swizzle_mode`, `.swizzle_atomicity`) field
/// pair into the matrix-descriptor swizzle encoding
/// (`eval::tcgen05_mma::SwizzleMode`) that
/// `eval::tcgen05_mma::swizzled_element_addr` understands - PTX ISA 5.5.7
/// describes the same byte-permutation pattern for both the tensor-copy
/// destination and the MMA operand read, just reached from two
/// differently-encoded fields. Combinations with no matrix-descriptor
/// equivalent (96B swizzle; 128B with plain-32B or 64B atomicity) return
/// `None` - not yet modeled, no corpus kernel uses them.
pub fn to_mma_swizzle_mode(
    mode: TensorSwizzleMode,
    atomicity: TensorSwizzleAtomicity,
) -> Option<crate::eval::tcgen05_mma::SwizzleMode> {
    use crate::eval::tcgen05_mma::SwizzleMode as Mma;
    match (mode, atomicity) {
        (TensorSwizzleMode::None, _) => Some(Mma::None),
        (TensorSwizzleMode::Swizzle32B, TensorSwizzleAtomicity::Atomicity16B) => {
            Some(Mma::Swizzle32B)
        }
        (TensorSwizzleMode::Swizzle64B, TensorSwizzleAtomicity::Atomicity16B) => {
            Some(Mma::Swizzle64B)
        }
        (TensorSwizzleMode::Swizzle128B, TensorSwizzleAtomicity::Atomicity16B) => {
            Some(Mma::Swizzle128B)
        }
        (TensorSwizzleMode::Swizzle128B, TensorSwizzleAtomicity::Atomicity32BWith8BFlip) => {
            Some(Mma::Swizzle128BWith32BAtomicity)
        }
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_entry_mut_creates_on_first_write() {
        let mut table = TensorMapTable::new();
        assert!(table.get(MemSpace::Shared, 0x100).is_none());
        table.entry_mut(MemSpace::Shared, 0x100).rank = Some(1);
        assert_eq!(table.get(MemSpace::Shared, 0x100).unwrap().rank, Some(1));
    }

    #[test]
    fn test_copy_entry_duplicates_fields_to_a_new_address() {
        let mut table = TensorMapTable::new();
        table.entry_mut(MemSpace::Shared, 0x100).rank = Some(1);
        table
            .entry_mut(MemSpace::Shared, 0x100)
            .box_dim
            .insert(0, 32);

        assert!(
            table
                .copy_entry(MemSpace::Global, 0x8000, MemSpace::Shared, 0x100)
                .is_some()
        );
        let dst = table.get(MemSpace::Global, 0x8000).unwrap();
        assert_eq!(dst.rank, Some(1));
        assert_eq!(dst.box_dim.get(&0), Some(&32));

        // The two entries are now independent copies.
        table.entry_mut(MemSpace::Shared, 0x100).rank = Some(2);
        assert_eq!(table.get(MemSpace::Global, 0x8000).unwrap().rank, Some(1));
    }

    #[test]
    fn test_copy_entry_without_a_source_fails() {
        let mut table = TensorMapTable::new();
        assert!(
            table
                .copy_entry(MemSpace::Global, 0x8000, MemSpace::Shared, 0x100)
                .is_none()
        );
    }

    #[test]
    fn test_swizzle_mode_translation_matches_the_corpus_combinations() {
        assert_eq!(
            to_mma_swizzle_mode(
                TensorSwizzleMode::None,
                TensorSwizzleAtomicity::Atomicity16B
            ),
            Some(crate::eval::tcgen05_mma::SwizzleMode::None)
        );
        assert_eq!(
            to_mma_swizzle_mode(
                TensorSwizzleMode::Swizzle64B,
                TensorSwizzleAtomicity::Atomicity16B
            ),
            Some(crate::eval::tcgen05_mma::SwizzleMode::Swizzle64B)
        );
        assert_eq!(
            to_mma_swizzle_mode(
                TensorSwizzleMode::Swizzle128B,
                TensorSwizzleAtomicity::Atomicity16B
            ),
            Some(crate::eval::tcgen05_mma::SwizzleMode::Swizzle128B)
        );
        // Not yet modeled.
        assert_eq!(
            to_mma_swizzle_mode(
                TensorSwizzleMode::Swizzle96B,
                TensorSwizzleAtomicity::Atomicity16B
            ),
            None
        );
        assert_eq!(
            to_mma_swizzle_mode(
                TensorSwizzleMode::Swizzle128B,
                TensorSwizzleAtomicity::Atomicity32B
            ),
            None
        );
    }
}
