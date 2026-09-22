//! `wgmma.mma_async` decode: the shared-memory matrix descriptor (PTX ISA
//! 9.7.17.5.1.2.2, "Matrix Descriptor Format") - a 64-bit packed bit-field
//! in an ordinary register, resolved to a concrete integer and decoded here
//! at eval time. Unlike `tcgen05.mma` (`eval::tcgen05_mma`), `wgmma.mma_async`
//! has no separate 32-bit "instruction descriptor" register - `.shape`,
//! `.dtype`, transpose, and scale are all plain mnemonic modifiers / immediate
//! operands in the PTX text itself, so only the shared-memory descriptor
//! needs bit-level decoding.
//!
//! # Why this is a separate decoder from `tcgen05_mma`'s, not a reuse
//!
//! `wgmma.mma_async`'s descriptor is a genuinely different bit layout from
//! `tcgen05.mma`'s, confirmed against the live PTX ISA docs (fetched and
//! read this session, both descriptor-format sections in full):
//!
//! | field | wgmma (9.7.17.5.1.2.2) | tcgen05 (9.7.18.4.1, Table 49) |
//! |---|---|---|
//! | start address | 14 bits, `[13:0]` | 15 bits, `[14:0]` (bit 15 reserved) |
//! | leading-dim offset | 14 bits, `[29:16]` | 15 bits, `[30:16]` (bit 31 reserved) |
//! | stride-dim offset | 14 bits, `[45:32]` | 14 bits, `[45:32]` - same |
//! | base offset | 3 bits, `[51:49]` | 3 bits, `[51:49]` - same |
//! | leading-stride mode | *(no such bit)* | bit 52 (`sm_103a`-only) |
//! | `lut::b` offset | *(no such bit)* | bit 53 |
//! | swizzle mode | **2 bits**, `[63:62]`: `{0:None,1:128B,2:64B,3:32B}`, all 4 encodings valid | **3 bits**, `[63:61]`: `{0:None,1:128B+32Batomic,2:128B,4:64B,6:32B}`, 3/5/7 invalid |
//!
//! Feeding a `wgmma` descriptor through `tcgen05_mma::decode_matrix_descriptor`
//! unchanged would read the wrong bits for the swizzle mode (3-bit field vs
//! wgmma's 2-bit one) and misalign the address/leading-dim/stride split -
//! silently wrong shared-memory addresses, which is exactly the failure mode
//! that would make Volta's race detector miss a genuine conflicting access
//! (a false "no race" verdict) rather than reject the kernel or report loudly.
//!
//! # Why the *swizzle permutation* math (not the descriptor bit layout) is
//! safely shared with `tcgen05_mma`
//!
//! The byte-permutation itself - [`tcgen05_mma::atom_shape`] and
//! [`tcgen05_mma::swizzled_element_addr`] - is not a `tcgen05`-specific
//! algorithm. It implements PTX ISA **5.5.7 "Swizzling Modes"**, one section
//! shared verbatim across every swizzle-consuming instruction family in the
//! ISA (`cp.async.bulk.tensor`/TMA already reuses it too, via
//! `eval::tensor_map_table`). `wgmma`'s own layout section, 9.7.17.5.1.2
//! ("Shared Memory Matrix Layout", Table 47), gives the *same* per-mode
//! "swizzle atom" shapes tcgen05_mma's `atom_shape` was independently
//! confirmed against (via NVIDIA's Figures 222-229, fetched and visually
//! inspected - see that module's doc comment): 128B -> 8x8, 64B -> 4x8/8x4,
//! 32B -> 8x2/2x8, None -> 8x1/1x8 - i.e. `(r, w)` = `(8,8)`/`(8,4)`/`(8,2)`
//! respectively, identical to `atom_shape`'s existing `Swizzle128B`/
//! `Swizzle64B`/`Swizzle32B` cases. `wgmma` simply never produces
//! `Swizzle128BWith32BAtomicity` (its swizzle field only has 4 possible
//! encodings and none of them is that mode - Table 47 doesn't list it as a
//! `wgmma` mode at all), so that one `atom_shape` arm - already the least
//! independently-confirmed one - is never reached from this module.
//!
//! Once decoded to real byte values, a `wgmma` descriptor is handed to
//! [`tcgen05_mma::swizzled_element_addr`] via a `tcgen05_mma::MatrixDescriptor`
//! (the same reuse `eval::interp`'s TMA/tensor-map swizzle path already does
//! for a third, unrelated instruction family) - `absolute_leading_stride` is
//! set `false` unconditionally, since `wgmma`'s descriptor has no such bit at
//! all (the byte-address-absolute leading-dimension mode is `sm_103a`/
//! `tcgen05`-only); `wgmma` is always the relative-offset mode.
//!
//! Cross-checked against the real H100 GEMM candidate this module was built
//! for (`kernels/astra_final/260918023412_MatrixMultiplicationFloat16_gpt-6-
//! astra_max/final_candidate.ptx`): its `a-desc`/`b-desc` static halves
//! decode to `stride_dim_byte_offset = 1024` for both (one full
//! `Swizzle128B` atom, `8 * 8 * 16` bytes - matching the *unrelated*
//! `tcgen05.mma` corpus kernel's own `A`/`B` descriptors exactly, an
//! independent sanity check that both generations' compilers stage tiles the
//! same way) and `leading_dim_byte_offset = 16` for the K-major `A`
//! descriptor - matching 9.7.17.5.1.2.1.1's own text precisely: "K-Major ...
//! Swizzled layouts: [leading dimension byte offset] not used, assumed to be
//! 1" (the *encoded* field value 1, decoded via `matrix-descriptor-encode`'s
//! inverse: `1 << 4 = 16`).

use crate::eval::tcgen05_mma::{self, MatrixDescriptor, SwizzleMode};

/// Decode `wgmma.mma_async`'s 2-bit swizzle-mode field (bits `[63:62]`).
/// Unlike `tcgen05.mma`'s 3-bit field, all four encodings are valid PTX ISA
/// values (9.7.17.5.1.2.2: `0..=3` map to `None`/`128B`/`64B`/`32B`) - there
/// is no invalid encoding to reject, so this never fails.
fn decode_swizzle_mode(desc: u64) -> SwizzleMode {
    match (desc >> 62) & 0x3 {
        0 => SwizzleMode::None,
        1 => SwizzleMode::Swizzle128B,
        2 => SwizzleMode::Swizzle64B,
        3 => SwizzleMode::Swizzle32B,
        _ => unreachable!("2-bit field has only 4 possible values"),
    }
}

/// Decode a 64-bit `wgmma.mma_async` shared-memory matrix descriptor (PTX
/// ISA 9.7.17.5.1.2.2). Returned as a `tcgen05_mma::MatrixDescriptor` so it
/// can be fed directly to [`tcgen05_mma::swizzled_element_addr`] - see the
/// module doc comment for why that reuse is sound (the byte-permutation math
/// is ISA-shared, only the descriptor's own bit layout differs per
/// instruction). `absolute_leading_stride` is always `false`: `wgmma`'s
/// descriptor has no leading-dimension-stride-mode bit at all (that's
/// `tcgen05`/`sm_103a`-only), so it is unconditionally the relative-offset
/// mode.
pub fn decode_wgmma_matrix_descriptor(desc: u64) -> MatrixDescriptor {
    MatrixDescriptor {
        start_addr: tcgen05_mma::decode_encoded_offset(desc & 0x3FFF),
        leading_dim_byte_offset: tcgen05_mma::decode_encoded_offset((desc >> 16) & 0x3FFF),
        stride_dim_byte_offset: tcgen05_mma::decode_encoded_offset((desc >> 32) & 0x3FFF),
        base_offset: ((desc >> 49) & 0x7) as u8,
        absolute_leading_stride: false,
        swizzle_mode: decode_swizzle_mode(desc),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::eval::tcgen05_mma::swizzled_element_addr;

    /// All four 2-bit encodings are valid and exhaustive - no `Err` case
    /// exists for this field, unlike `tcgen05.mma`'s 3-bit one.
    #[test]
    fn test_decode_swizzle_mode_exhaustive() {
        assert_eq!(decode_swizzle_mode(0 << 62), SwizzleMode::None);
        assert_eq!(decode_swizzle_mode(1 << 62), SwizzleMode::Swizzle128B);
        assert_eq!(decode_swizzle_mode(2 << 62), SwizzleMode::Swizzle64B);
        assert_eq!(decode_swizzle_mode(3 << 62), SwizzleMode::Swizzle32B);
    }

    /// Real kernel's `a-desc` static half
    /// (`or.b64 %da, %da, 0x4000004000010000;` -
    /// `260918023412_MatrixMultiplicationFloat16_gpt-6-astra_max/
    /// final_candidate.ptx`, the H100 GEMM's K-major `A` operand, "128-byte
    /// swizzling" per the kernel's own comment): swizzle mode 128B, stride-
    /// dim byte offset 1024 (one full atom), leading-dim byte offset 16
    /// (the K-major "assumed to be 1 [encoded]" case from 9.7.17.5.1.2.1.1),
    /// base offset 0.
    #[test]
    fn test_decode_real_kernel_a_desc() {
        let d = decode_wgmma_matrix_descriptor(0x4000004000010000);
        assert_eq!(d.start_addr, 0);
        assert_eq!(d.leading_dim_byte_offset, 16);
        assert_eq!(d.stride_dim_byte_offset, 1024);
        assert_eq!(d.base_offset, 0);
        assert!(!d.absolute_leading_stride);
        assert_eq!(d.swizzle_mode, SwizzleMode::Swizzle128B);
    }

    /// Real kernel's `b-desc` static half
    /// (`or.b64 %db, %db, 0x4000004002000000;`): same swizzle mode and
    /// stride-dim offset as `a-desc`, but a much larger leading-dim byte
    /// offset (8192) - B's leading dimension (N = 256, transposed/N-major)
    /// spans multiple swizzle atoms, unlike A's (K = 16 per instruction).
    #[test]
    fn test_decode_real_kernel_b_desc() {
        let d = decode_wgmma_matrix_descriptor(0x4000004002000000);
        assert_eq!(d.start_addr, 0);
        assert_eq!(d.leading_dim_byte_offset, 8192);
        assert_eq!(d.stride_dim_byte_offset, 1024);
        assert_eq!(d.base_offset, 0);
        assert!(!d.absolute_leading_stride);
        assert_eq!(d.swizzle_mode, SwizzleMode::Swizzle128B);
    }

    /// A wgmma-decoded descriptor composes with the shared swizzle-address
    /// math exactly like a tcgen05 one does (mirrors
    /// `tcgen05_mma::tests::test_swizzle_crosses_a_stride_atom`): crossing
    /// into the second stride atom (row 8, `atom_shape(Swizzle128B) = (8,
    /// 8)`) adds exactly one `stride_dim_byte_offset` on top of the
    /// intra-atom part.
    #[test]
    fn test_swizzle_crosses_a_stride_atom() {
        let desc = decode_wgmma_matrix_descriptor(0x4000004000010000);
        let row0 = swizzled_element_addr(&desc, 0, 4, 2);
        let row8 = swizzled_element_addr(&desc, 8, 4, 2);
        assert_eq!(row8, row0 + desc.stride_dim_byte_offset);
    }

    /// Same, for the leading dimension: real `B` descriptor, crossing into
    /// the second leading atom (cell 8, i.e. N-index 64) adds exactly one
    /// `leading_dim_byte_offset` (8192).
    #[test]
    fn test_swizzle_crosses_a_leading_atom() {
        let desc = decode_wgmma_matrix_descriptor(0x4000004002000000);
        let n0 = swizzled_element_addr(&desc, 0, 0, 2);
        let n64 = swizzled_element_addr(&desc, 0, 64, 2);
        assert_eq!(n64, n0 + desc.leading_dim_byte_offset);
    }
}
