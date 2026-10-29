//! `tensormap` object state: named fields keyed by the object's concrete `(space, address)`
//! (PTX ISA 5.5.8, 9.7.9.27). The ISA makes the 128-byte object opaque, so Volta models only
//! the fields `tensormap.replace` has written, never literal bytes.

use std::collections::HashMap;

use crate::ir::MemSpace;
use crate::ir::tensor_map::{
    Im2colBox, TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorSwizzleAtomicity,
    TensorSwizzleMode,
};

/// The size of a tensor-map object (`.b1024`), the footprint of every access to it.
pub(in crate::eval) const TENSOR_MAP_BYTES: u64 = 128;

/// One tensor-map object's fields, as written by `tensormap.replace` (concrete, since they
/// shape addresses). Per-dimension fields are sparse by `ord` since `.rank` may come later;
/// completeness is checked only when a consumer (`cp.async.bulk.tensor`) uses the entry.
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
    /// The pixel column of a host-encoded im2col map, which has no `box_dim`; `None` for a
    /// tiled map, the only kind `tensormap.replace` writes (its `.tile` mode).
    pub im2col: Option<Im2colBox>,
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

    /// Get-or-create the entry at `(space, addr)` for a `tensormap.replace` write; there is
    /// no init instruction, so an object comes into existence at its first field write.
    pub fn entry_mut(&mut self, space: MemSpace, addr: u64) -> &mut TensorMapEntry {
        self.entries.entry((space, addr)).or_default()
    }

    pub fn get(&self, space: MemSpace, addr: u64) -> Option<&TensorMapEntry> {
        self.entries.get(&(space, addr))
    }

    /// `tensormap.cp_fenceproxy`: copy the source entry's *named fields* (the object is
    /// opaque, so there are no bytes) to `(dst_space, dst_addr)`; `None` if no source entry.
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

/// Map a tensor-map's (`.swizzle_mode`, `.swizzle_atomicity`) pair to the matrix-descriptor
/// `eval::tcgen05_mma::SwizzleMode` (same permutation, PTX ISA 5.5.7). `None` for combinations
/// with no descriptor equivalent (96B; 128B with 32B/64B atomicity) - unmodeled, unused.
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
