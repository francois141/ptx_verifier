//! `wgmma.mma_async` shared-memory matrix descriptor decode (PTX ISA
//! 9.7.17.5.1.2.2): its layout differs from tcgen05's (14-bit fields, 2-bit
//! swizzle at `[63:62]`), but the swizzle math (ISA 5.5.7) is shared.

use crate::eval::tcgen05_mma::{self, MatrixDescriptor, SwizzleMode};

/// Decode the 2-bit swizzle-mode field (bits `[63:62]`); unlike
/// `tcgen05.mma`'s 3-bit field, all four encodings are valid
/// (9.7.17.5.1.2.2), so this never fails.
fn decode_swizzle_mode(desc: u64) -> SwizzleMode {
    match (desc >> 62) & 0x3 {
        0 => SwizzleMode::None,
        1 => SwizzleMode::Swizzle128B,
        2 => SwizzleMode::Swizzle64B,
        3 => SwizzleMode::Swizzle32B,
        _ => unreachable!("2-bit field has only 4 possible values"),
    }
}

/// Decode a `wgmma.mma_async` matrix descriptor (PTX ISA 9.7.17.5.1.2.2) for
/// [`tcgen05_mma::swizzled_element_addr`]. `absolute_leading_stride` is
/// always `false`: that mode is `tcgen05`/`sm_103a`-only.
pub fn decode_wgmma_matrix_descriptor(desc: u64) -> MatrixDescriptor {
    MatrixDescriptor {
        start_addr: tcgen05_mma::decode_encoded_offset(desc & 0x3FFF),
        leading_dim_byte_offset: tcgen05_mma::decode_encoded_offset((desc >> 16) & 0x3FFF),
        stride_dim_byte_offset: tcgen05_mma::decode_encoded_offset((desc >> 32) & 0x3FFF),
        base_offset: ((desc >> 49) & 0x7) as u8,
        absolute_leading_stride: false,
        lut_b_offset: false,
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

    /// The H100 GEMM's K-major `A` descriptor (`0x4000004000010000`): 128B
    /// swizzle, one-atom stride offset 1024, leading offset 16 (the K-major
    /// "assumed to be 1" case of 9.7.17.5.1.2.1.1).
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

    /// The same kernel's `b-desc`: same swizzle and stride offset as
    /// `a-desc`, but leading offset 8192, since B's N-major leading dimension
    /// spans several atoms.
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

    /// A wgmma-decoded descriptor composes with the shared swizzle math:
    /// crossing into the second stride atom (row 8) adds exactly one
    /// `stride_dim_byte_offset`.
    #[test]
    fn test_swizzle_crosses_a_stride_atom() {
        let desc = decode_wgmma_matrix_descriptor(0x4000004000010000);
        let row0 = swizzled_element_addr(&desc, 0, 4, 2);
        let row8 = swizzled_element_addr(&desc, 8, 4, 2);
        assert_eq!(row8, row0 + desc.stride_dim_byte_offset);
    }

    /// Same, for the leading dimension: crossing into the second leading atom
    /// (N-index 64) adds exactly one `leading_dim_byte_offset` (8192).
    #[test]
    fn test_swizzle_crosses_a_leading_atom() {
        let desc = decode_wgmma_matrix_descriptor(0x4000004002000000);
        let n0 = swizzled_element_addr(&desc, 0, 0, 2);
        let n64 = swizzled_element_addr(&desc, 0, 64, 2);
        assert_eq!(n64, n0 + desc.leading_dim_byte_offset);
    }
}
