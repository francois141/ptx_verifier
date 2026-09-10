//! `tcgen05.mma` decode: the instruction descriptor (PTX ISA 9.7.17.4.2)
//! and the shared-memory matrix descriptor (9.7.17.4.1), both packed
//! bit-fields in ordinary registers, resolved to concrete integers and
//! decoded here at eval time (nothing about their *contents* is visible at
//! lowering - only the register operands are).
//!
//! Scoped to exactly the form `sm100a_support_plan.md` documents as the
//! "conservative first pass": dense (non-sparse) `.kind::f16`,
//! `.cta_group::1`, `A` addressed via a shared-memory descriptor (not
//! `[a-tmem]`), `M = 128`. Anything else decodes fine (the bit layout
//! doesn't care) but is rejected with `unsupported()` by the caller.
//!
//! [`swizzled_element_addr`] turns a decoded [`MatrixDescriptor`] into an
//! actual shared-memory byte address, for all five swizzle modes
//! (`base_offset == 0` only - a start-address-misalignment correction
//! never independently confirmed for any mode, so still rejected
//! universally). PTX ISA 9.7.17.10.5/9.7.17.10.6 define that mapping
//! primarily through reference diagrams (Figures 205-229) not reproducible
//! as text - the bit-field layout and the swizzle byte-permutation table
//! (5.5.7) are specified in prose, but the diagrams themselves are plain
//! PNGs hosted at `docs.nvidia.com`, fetched with `curl` and visually
//! inspected during this session (see the session notes) rather than
//! guessed at - guessing here would risk silently wrong tensor-core math
//! in a tool whose entire purpose is verifying kernel correctness.
//! Confirmed this way, against every data point in Figures 222-229 (the
//! K-major and MN-major worked examples for `Swizzle32B`/`Swizzle64B`/
//! `Swizzle128B`/`None`) plus Figure 228 specifically (two points checked
//! independently before trusting the rest): `swizzled_element_addr`'s
//! `atom_row XOR atom_cell` step (via [`atom_shape`]'s per-mode `(R, W)`)
//! reproduces every one of them exactly. `Swizzle128BWith32BAtomicity`
//! rests on comparatively thinner evidence - see [`atom_shape`]'s doc
//! comment.

/// Decoded `idesc` fields for `.kind::f16` (PTX ISA 9.7.17.4.2, Table 45).
/// Every other `.kind` has a different bit layout and is rejected before
/// this is ever called (the caller dispatches by mnemonic/modifier, not by
/// inspecting `idesc`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InstructionDescriptor {
    pub sparse: bool,
    /// Matrix D element type: `false` = f16, `true` = f32.
    pub dtype_f32: bool,
    /// Matrix A element type: `false` = f16, `true` = bf16.
    pub atype_bf16: bool,
    /// Matrix B element type: `false` = f16, `true` = bf16.
    pub btype_bf16: bool,
    pub negate_a: bool,
    pub negate_b: bool,
    pub transpose_a: bool,
    pub transpose_b: bool,
    /// Dimension of matrix B's columns (`N`), already shifted back up
    /// (the field stores `N >> 3`).
    pub n: u32,
    /// Dimension of matrix A's rows (`M`), already shifted back up (the
    /// field stores `M >> 4`).
    pub m: u32,
}

fn bits(x: u32, lo: u32, width: u32) -> u32 {
    (x >> lo) & ((1 << width) - 1)
}

/// Decode a `.kind::f16` instruction descriptor (Table 45's `.kind::f16`
/// column). The bit layout itself has no invalid encodings - every 32-bit
/// value decodes to *some* `InstructionDescriptor` - so this never fails;
/// validating the decoded fields against what's actually modeled is the
/// caller's job.
pub fn decode_instruction_descriptor(idesc: u32) -> InstructionDescriptor {
    InstructionDescriptor {
        sparse: bits(idesc, 2, 1) != 0,
        dtype_f32: bits(idesc, 4, 2) != 0,
        atype_bf16: bits(idesc, 7, 3) != 0,
        btype_bf16: bits(idesc, 10, 3) != 0,
        negate_a: bits(idesc, 13, 1) != 0,
        negate_b: bits(idesc, 14, 1) != 0,
        transpose_a: bits(idesc, 15, 1) != 0,
        transpose_b: bits(idesc, 16, 1) != 0,
        n: bits(idesc, 17, 6) << 3,
        m: bits(idesc, 24, 5) << 4,
    }
}

/// Swizzling mode of a shared-memory matrix descriptor (PTX ISA 9.7.17.4.1,
/// the 3-bit field at bits 61-63).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SwizzleMode {
    None,
    Swizzle128BWith32BAtomicity,
    Swizzle128B,
    Swizzle64B,
    Swizzle32B,
}

/// Decoded shared-memory matrix descriptor (PTX ISA 9.7.17.4.1, Table 43).
/// `leading_dim_byte_offset`/`stride_dim_byte_offset`/`base_offset` are
/// recovered to their real byte values (the field's own `<< 4` undone),
/// but - see the module doc comment - nothing here turns them into an
/// actual address.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MatrixDescriptor {
    pub start_addr: u64,
    pub leading_dim_byte_offset: u64,
    pub stride_dim_byte_offset: u64,
    pub base_offset: u8,
    /// Leading-dimension stride mode (bit 52): `false` = relative byte
    /// offset (the only mode modeled - the absolute-address mode is
    /// `sm_103a`-only), `true` = absolute byte address.
    pub absolute_leading_stride: bool,
    pub swizzle_mode: SwizzleMode,
}

/// `matrix-descriptor-encode`'s inverse: a 14-bit field holds `(real >>
/// 4) & 0x3FFF`, so the real value is the field shifted back up.
fn decode_encoded_offset(field: u64) -> u64 {
    field << 4
}

/// Decode a 64-bit shared-memory matrix descriptor. Fails (returning the
/// raw field) only on the swizzle-mode field's documented-invalid
/// encodings - Table 43 lists 3, 5, and 7 as invalid - rather than
/// silently mapping them to something.
pub fn decode_matrix_descriptor(desc: u64) -> Result<MatrixDescriptor, u8> {
    let swizzle_mode = match ((desc >> 61) & 0x7) as u8 {
        0 => SwizzleMode::None,
        1 => SwizzleMode::Swizzle128BWith32BAtomicity,
        2 => SwizzleMode::Swizzle128B,
        4 => SwizzleMode::Swizzle64B,
        6 => SwizzleMode::Swizzle32B,
        other => return Err(other),
    };
    Ok(MatrixDescriptor {
        start_addr: decode_encoded_offset(desc & 0x3FFF),
        leading_dim_byte_offset: decode_encoded_offset((desc >> 16) & 0x3FFF),
        stride_dim_byte_offset: decode_encoded_offset((desc >> 32) & 0x3FFF),
        base_offset: ((desc >> 49) & 0x7) as u8,
        absolute_leading_stride: (desc >> 52) & 0x1 != 0,
        swizzle_mode,
    })
}

/// One 16-byte swizzle "cell" - the unit the permutation operates on,
/// regardless of the matrix's own element size (PTX ISA 5.5.7: "each
/// element (numbered cell) is 16 byte").
const CELL_BYTES: u64 = 16;

/// `(R, W)` for a swizzled mode: `R` = stride-dimension depth of one atom
/// (rows sharing one repeating pattern before `stride_dim_byte_offset`
/// starts a new one), `W` = leading-dimension width of one atom, in
/// cells. `R * W * CELL_BYTES` is the atom's total byte size, matching
/// Table 43/44's "starting address of the repeating pattern" boundaries
/// (1024/512/256 bytes for 128B/64B/32B). Confirmed against
/// `docs.nvidia.com`'s Figures 219/222-229 (K-major and MN-major worked
/// examples for every mode below `SwizzleMode::None`, fetched and visually
/// inspected - see the module doc comment): each pair reproduces every
/// data point in its diagram(s) exactly via [`swizzled_element_addr`]'s
/// `key = atom_row * W / R` step.
///
/// `Swizzle128BWith32BAtomicity`'s `(4, 8)` rests on one diagram only
/// (Figure 219, MN-major) - the ISA provides no K-major counterpart to
/// cross-check the way every other mode has, so this one entry carries
/// less confirmation than the rest, though the 32 data points in that one
/// diagram are all reproduced exactly.
fn atom_shape(mode: SwizzleMode) -> (u64, u64) {
    match mode {
        SwizzleMode::Swizzle32B => (8, 2),
        SwizzleMode::Swizzle64B => (8, 4),
        SwizzleMode::Swizzle128B => (8, 8),
        SwizzleMode::Swizzle128BWith32BAtomicity => (4, 8),
        SwizzleMode::None => unreachable!("None has no atom - handled separately"),
    }
}

/// Compute the shared-memory byte address of one matrix element addressed
/// via `desc`, given its position in *swizzle-space coordinates*:
/// `stride_idx` = index along the stride dimension (element granularity -
/// `M` for a K-major matrix, `K` for an MN-major/transposed one, per
/// 9.7.17.10.6's transpose-bit rule), `leading_idx` = index along the
/// leading dimension. See the module doc comment and [`atom_shape`] for
/// how this formula was confirmed; scoped to `base_offset == 0` (the
/// caller must reject a nonzero one before calling this - its correction
/// was never independently confirmed for any mode).
///
/// `SwizzleMode::None` has no atom or permutation at all (confirmed by
/// Figures 226/227, both trivial identity mappings) - a plain linear
/// layout, `stride_dim_byte_offset` used directly as the per-row pitch
/// and `leading_dim_byte_offset` never needed (nothing before this ever
/// crosses a "leading atom" boundary, since there isn't one).
///
/// For every other mode, atoms tile along the stride dimension using
/// `stride_dim_byte_offset` per atom and along the leading dimension using
/// `leading_dim_byte_offset` per atom, applied mechanically: this doesn't
/// need to know *why* a kernel's specific buffer layout produces the
/// byte-offset values its descriptor carries (e.g. pipeline staging), only
/// that the descriptor is authoritative and the offsets compose linearly
/// per atom index - confirmed self-consistent with the real kernel's `A`
/// descriptor, whose `stride_dim_byte_offset` (1024) exactly equals one
/// full `Swizzle128B` atom's size, consistent with zero-padding atom
/// stacking along `M`.
pub fn swizzled_element_addr(
    desc: &MatrixDescriptor,
    stride_idx: u64,
    leading_idx: u64,
    elem_bytes: u64,
) -> u64 {
    let cell_elems = CELL_BYTES / elem_bytes;
    let cell = leading_idx / cell_elems;
    let elem_in_cell = leading_idx % cell_elems;

    if desc.swizzle_mode == SwizzleMode::None {
        return desc.start_addr
            + stride_idx * desc.stride_dim_byte_offset
            + cell * CELL_BYTES
            + elem_in_cell * elem_bytes;
    }

    let (r, w) = atom_shape(desc.swizzle_mode);
    let row_bytes = w * CELL_BYTES;

    let atom_row = stride_idx % r;
    let stride_atom = stride_idx / r;
    let atom_cell = cell % w;
    let leading_atom = cell / w;

    // Exact (no remainder) for every modeled `(r, w)` pair: `w` is always
    // a multiple of `r`, or vice versa.
    let key = (atom_row * w) / r;
    let swizzled_cell = atom_cell ^ key;

    desc.start_addr
        + stride_atom * desc.stride_dim_byte_offset
        + leading_atom * desc.leading_dim_byte_offset
        + atom_row * row_bytes
        + swizzled_cell * CELL_BYTES
        + elem_in_cell * elem_bytes
}

#[cfg(test)]
mod tests {
    use super::*;

    /// `idesc` from the real corpus kernel
    /// (`tcgen05.mma.cta_group::1.kind::f16 [...], %rd56, %rd57, %r94, %p3;`,
    /// `mov.b32 %r94, 138477584;` -
    /// `triton_generated.ptx`): decoded by hand (see the session's working
    /// notes) as dense, D=f32, A/B=f16, no negate, transpose A=0,
    /// transpose B=1, N=256, M=128.
    #[test]
    fn test_decode_real_kernel_idesc() {
        let d = decode_instruction_descriptor(138477584);
        assert!(!d.sparse);
        assert!(d.dtype_f32);
        assert!(!d.atype_bf16);
        assert!(!d.btype_bf16);
        assert!(!d.negate_a);
        assert!(!d.negate_b);
        assert!(!d.transpose_a);
        assert!(d.transpose_b);
        assert_eq!(d.n, 256);
        assert_eq!(d.m, 128);
    }

    /// `a-desc`'s static half (`%rd56 = %rd69 | 4611756662049472512`, the
    /// dynamic base address ORed in separately): swizzle mode 2 (128B, no
    /// atomicity), stride-dim byte offset 1024, leading-dim byte offset 0,
    /// base offset 0, relative stride mode.
    #[test]
    fn test_decode_real_kernel_a_desc() {
        let d = decode_matrix_descriptor(4611756662049472512).unwrap();
        assert_eq!(d.start_addr, 0);
        assert_eq!(d.leading_dim_byte_offset, 0);
        assert_eq!(d.stride_dim_byte_offset, 1024);
        assert_eq!(d.base_offset, 0);
        assert!(!d.absolute_leading_stride);
        assert_eq!(d.swizzle_mode, SwizzleMode::Swizzle128B);
    }

    /// `b-desc`'s static half (`%rd57 = %rd70 | 4611756662083026944`):
    /// same swizzle mode and stride-dim offset as `a-desc`, but a nonzero
    /// leading-dim byte offset (8192) - B's leading dimension (N = 256,
    /// since B is transposed/N-major here) spans multiple swizzle atoms,
    /// unlike A's (K = 16).
    #[test]
    fn test_decode_real_kernel_b_desc() {
        let d = decode_matrix_descriptor(4611756662083026944).unwrap();
        assert_eq!(d.start_addr, 0);
        assert_eq!(d.leading_dim_byte_offset, 8192);
        assert_eq!(d.stride_dim_byte_offset, 1024);
        assert_eq!(d.base_offset, 0);
        assert!(!d.absolute_leading_stride);
        assert_eq!(d.swizzle_mode, SwizzleMode::Swizzle128B);
    }

    #[test]
    fn test_invalid_swizzle_mode_rejected() {
        for invalid in [3u64, 5, 7] {
            let desc = invalid << 61;
            assert_eq!(decode_matrix_descriptor(desc), Err(invalid as u8));
        }
    }

    #[test]
    fn test_no_swizzle_mode_decodes() {
        let d = decode_matrix_descriptor(0).unwrap();
        assert_eq!(d.swizzle_mode, SwizzleMode::None);
    }

    fn atomless_desc() -> MatrixDescriptor {
        // start=0, offsets irrelevant (never used - both a real kernel's
        // and this test's matrices fit within one atom on both axes).
        MatrixDescriptor {
            start_addr: 0,
            leading_dim_byte_offset: 0,
            stride_dim_byte_offset: 0,
            base_offset: 0,
            absolute_leading_stride: false,
            swizzle_mode: SwizzleMode::Swizzle128B,
        }
    }

    /// Reproduces Figure 228 (K-major 128B swizzle, tf32/4-byte elements)
    /// exactly, fetched and visually inspected this session: logical
    /// `(row=1, col=4)` is element index 36 in the figure's linear
    /// numbering (`row*32 + col`) and is shown at physical cell 0 of row
    /// 1; logical `(row=3, col=24)` is element 120, shown at physical cell
    /// 5 of row 3.
    #[test]
    fn test_swizzle_matches_figure_228_k_major() {
        let desc = atomless_desc();
        // byte offset of (row=1, col=4) should land in cell 0 of row 1:
        // row 1's row-base is 1 * 128 (128); cell 0 adds 0.
        assert_eq!(
            swizzled_element_addr(&desc, 1, 4, 4),
            1 * 128 + 0 * CELL_BYTES
        );
        // (row=3, col=24): logical cell 6, row 3's base is 3 * 128; lands
        // in physical cell 5.
        assert_eq!(
            swizzled_element_addr(&desc, 3, 24, 4),
            3 * 128 + 5 * CELL_BYTES
        );
    }

    /// The diagonal (`stride_idx == leading_idx` in cell units) always
    /// swizzles to cell 0 - a direct property of `a XOR a == 0`, and a
    /// cheap way to check every row's self-consistency at once rather than
    /// only the two hand-picked figure points above.
    #[test]
    fn test_swizzle_diagonal_lands_in_cell_zero() {
        let desc = atomless_desc();
        for row in 0..8u64 {
            let addr = swizzled_element_addr(&desc, row, row * 8, 2); // row*8 elems = logical cell `row`
            assert_eq!(addr, row * 128);
        }
    }

    /// Real kernel's `A` descriptor (K=16, f16): crossing into the second
    /// stride atom (row 8, i.e. M-index 8) adds exactly one
    /// `stride_dim_byte_offset` (1024) on top of the intra-atom part,
    /// which is identical to row 0's (both map to atom_row 0).
    #[test]
    fn test_swizzle_crosses_a_stride_atom() {
        let desc = decode_matrix_descriptor(4611756662049472512).unwrap();
        let row0 = swizzled_element_addr(&desc, 0, 4, 2);
        let row8 = swizzled_element_addr(&desc, 8, 4, 2);
        assert_eq!(row8, row0 + desc.stride_dim_byte_offset);
    }

    /// Real kernel's `B` descriptor (N=256, f16, N-major since transposed):
    /// crossing into the second leading atom (cell 8, i.e. N-index 64)
    /// adds exactly one `leading_dim_byte_offset` (8192).
    #[test]
    fn test_swizzle_crosses_a_leading_atom() {
        let desc = decode_matrix_descriptor(4611756662083026944).unwrap();
        let n0 = swizzled_element_addr(&desc, 0, 0, 2);
        let n64 = swizzled_element_addr(&desc, 0, 64, 2);
        assert_eq!(n64, n0 + desc.leading_dim_byte_offset);
    }

    fn desc_with_mode(mode: SwizzleMode) -> MatrixDescriptor {
        MatrixDescriptor {
            start_addr: 0,
            leading_dim_byte_offset: 0,
            stride_dim_byte_offset: 0,
            base_offset: 0,
            absolute_leading_stride: false,
            swizzle_mode: mode,
        }
    }

    /// One 16-byte-cell element (`elem_bytes = CELL_BYTES`), so `cell ==
    /// leading_idx` and the returned address, divided by `CELL_BYTES`,
    /// directly gives `atom_row * row_width_in_cells + swizzled_cell` -
    /// exactly the "value" numbering the diagrams themselves use. Keeps
    /// the test assertions a direct transcription of the diagram's numbers
    /// rather than needing byte-level arithmetic.
    fn swizzled_cell_index(desc: &MatrixDescriptor, stride_idx: u64, leading_cell: u64) -> u64 {
        swizzled_element_addr(desc, stride_idx, leading_cell, CELL_BYTES) / CELL_BYTES
    }

    /// Figure 226/227 (no swizzle): identity in both orientations - the
    /// two simplest, least-ambiguous diagrams available. `None` mode uses
    /// `stride_dim_byte_offset` directly as the per-row pitch (no atom
    /// batching - see `swizzled_element_addr`'s doc comment), so it must
    /// be set for this check to mean anything.
    #[test]
    fn test_no_swizzle_is_identity() {
        let mut desc = desc_with_mode(SwizzleMode::None);
        desc.stride_dim_byte_offset = 8 * CELL_BYTES;
        for stride_idx in 0..8 {
            for leading_cell in 0..8 {
                assert_eq!(
                    swizzled_cell_index(&desc, stride_idx, leading_cell),
                    stride_idx * 8 + leading_cell
                );
            }
        }
    }

    /// Figure 224 (32B swizzle, MN-major: leading = row, `W = 2`): every
    /// value from the fetched diagram (2 rows x 8 cols), transcribed
    /// directly - `value = col*2 + swizzled_row`.
    #[test]
    fn test_swizzle_32b_matches_figure_224_mn_major() {
        let desc = desc_with_mode(SwizzleMode::Swizzle32B);
        let expected: [[u64; 8]; 2] = [[0, 2, 4, 6, 9, 11, 13, 15], [1, 3, 5, 7, 8, 10, 12, 14]];
        for (row, vals) in expected.iter().enumerate() {
            for (k, &want) in vals.iter().enumerate() {
                // leading = row (M/N), stride = k (K), matching the
                // diagram's MN-major orientation.
                let got = swizzled_cell_index(&desc, k as u64, row as u64);
                assert_eq!(got, want, "row={row} k={k}");
            }
        }
    }

    /// Figure 225 (32B swizzle, K-major: leading = col, `W = 2`).
    #[test]
    fn test_swizzle_32b_matches_figure_225_k_major() {
        let desc = desc_with_mode(SwizzleMode::Swizzle32B);
        let expected: [[u64; 2]; 8] = [
            [0, 1],
            [2, 3],
            [4, 5],
            [6, 7],
            [9, 8],
            [11, 10],
            [13, 12],
            [15, 14],
        ];
        for (row, vals) in expected.iter().enumerate() {
            for (k, &want) in vals.iter().enumerate() {
                // leading = k (K), stride = row (M/N), matching the
                // diagram's K-major orientation.
                let got = swizzled_cell_index(&desc, row as u64, k as u64);
                assert_eq!(got, want, "row={row} k={k}");
            }
        }
    }

    /// Figure 223 (64B swizzle, K-major: leading = col, `W = 4`).
    #[test]
    fn test_swizzle_64b_matches_figure_223_k_major() {
        let desc = desc_with_mode(SwizzleMode::Swizzle64B);
        let expected: [[u64; 4]; 8] = [
            [0, 1, 2, 3],
            [4, 5, 6, 7],
            [9, 8, 11, 10],
            [13, 12, 15, 14],
            [18, 19, 16, 17],
            [22, 23, 20, 21],
            [27, 26, 25, 24],
            [31, 30, 29, 28],
        ];
        for (row, vals) in expected.iter().enumerate() {
            for (k, &want) in vals.iter().enumerate() {
                let got = swizzled_cell_index(&desc, row as u64, k as u64);
                assert_eq!(got, want, "row={row} k={k}");
            }
        }
    }

    /// Figure 222 (64B swizzle, MN-major: leading = row, `W = 4`).
    #[test]
    fn test_swizzle_64b_matches_figure_222_mn_major() {
        let desc = desc_with_mode(SwizzleMode::Swizzle64B);
        let expected: [[u64; 8]; 4] = [
            [0, 4, 9, 13, 18, 22, 27, 31],
            [1, 5, 8, 12, 19, 23, 26, 30],
            [2, 6, 11, 15, 16, 20, 25, 29],
            [3, 7, 10, 14, 17, 21, 24, 28],
        ];
        for (row, vals) in expected.iter().enumerate() {
            for (k, &want) in vals.iter().enumerate() {
                let got = swizzled_cell_index(&desc, k as u64, row as u64);
                assert_eq!(got, want, "row={row} k={k}");
            }
        }
    }

    /// Figure 219 (128B swizzle with 32B atomicity, MN-major only - the
    /// ISA provides no K-major counterpart for this specific mode; see
    /// `atom_shape`'s doc comment for why this one carries less
    /// cross-checking than the others).
    #[test]
    fn test_swizzle_128b_32b_atomicity_matches_figure_219_mn_major() {
        let desc = desc_with_mode(SwizzleMode::Swizzle128BWith32BAtomicity);
        let expected: [[u64; 4]; 8] = [
            [0, 10, 20, 30],
            [1, 11, 21, 31],
            [2, 8, 22, 28],
            [3, 9, 23, 29],
            [4, 14, 16, 26],
            [5, 15, 17, 27],
            [6, 12, 18, 24],
            [7, 13, 19, 25],
        ];
        for (row, vals) in expected.iter().enumerate() {
            for (k, &want) in vals.iter().enumerate() {
                let got = swizzled_cell_index(&desc, k as u64, row as u64);
                assert_eq!(got, want, "row={row} k={k}");
            }
        }
    }
}
