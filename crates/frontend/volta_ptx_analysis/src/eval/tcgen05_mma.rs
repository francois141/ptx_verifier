//! `tcgen05.mma` decode at eval time: instruction descriptor (ISA 9.7.17.4.2),
//! shared-memory matrix descriptor (9.7.17.4.1), and swizzled addressing,
//! checked against the ISA's Figures 219/222-229 (`base_offset == 0` only).

use crate::ir::tcgen05::Tcgen05MmaKind;

/// Decoded `idesc` fields shared by `.kind::f16` and `.kind::f8f6f4` (ISA
/// 9.7.17.4.2, Table 45: same layout; type fields stay raw for the caller).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InstructionDescriptor {
    pub sparse: bool,
    /// Matrix D element type field: 0 = f16, 1 = f32.
    pub dtype: u32,
    /// Matrix A element type field (`.kind::f16`: 0 = f16, 1 = bf16;
    /// `.kind::f8f6f4`: 0 = e4m3, 1 = e5m2, 3/4/5 = e2m3/e3m2/e2m1).
    pub atype: u32,
    /// Matrix B element type field, same encoding as `atype`.
    pub btype: u32,
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
    /// The K Dimension bit (bit 29, PTX ISA 9.4 Table 51).
    pub k_select: KSelect,
    /// Saturate for integer types (bit 3): `.kind::i8` only, `0 (NA)` for
    /// every float kind.
    pub saturate: bool,
    /// Maximum shift while attempting `B` matrix reuse (bits 30-31):
    /// meaningful for `tcgen05.mma.ws` only.
    pub max_shift: u32,
}

/// An `idesc` bit the ISA reserves as "must be 0" was set (bits 6 and 23,
/// Table 51).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ReservedIdescBit(pub u32);

/// `idesc`'s 1-bit K Dimension field (bit 29, from `sm_107f`). `Base` is the
/// kind's dense `K` ([`k_dim`]); `Wide` doubles it but Table 51 defines it
/// only for `.kind::i8`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KSelect {
    Base,
    Wide,
}

/// Element format of one `tcgen05.mma` operand: `.kind` plus `idesc`'s
/// type field for that operand.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OperandFormat {
    F16,
    Bf16,
    E4m3,
    E5m2,
}

impl OperandFormat {
    /// The modeled formats; the 6/4-bit `.kind::f8f6f4` types (which the ISA
    /// pads inside shared memory) are `None`.
    pub fn decode(kind: Tcgen05MmaKind, type_field: u32) -> Option<Self> {
        match (kind, type_field) {
            (Tcgen05MmaKind::F16, 0) => Some(Self::F16),
            (Tcgen05MmaKind::F16, 1) => Some(Self::Bf16),
            (Tcgen05MmaKind::F8f6f4 | Tcgen05MmaKind::Mxf8f6f4, 0) => Some(Self::E4m3),
            (Tcgen05MmaKind::F8f6f4 | Tcgen05MmaKind::Mxf8f6f4, 1) => Some(Self::E5m2),
            _ => None,
        }
    }

    pub fn bytes(self) -> u64 {
        match self {
            Self::F16 | Self::Bf16 => 2,
            Self::E4m3 | Self::E5m2 => 1,
        }
    }
}

/// `K` of one dense `.cta_group::1` operation (PTX ISA Table 42): 32 bytes
/// of each operand row for every modeled kind - the `KSelect::Base` value.
pub fn k_dim(kind: Tcgen05MmaKind) -> u64 {
    match kind {
        Tcgen05MmaKind::F16 => 16,
        Tcgen05MmaKind::F8f6f4 | Tcgen05MmaKind::Mxf8f6f4 => 32,
    }
}

pub(in crate::eval) fn bits(x: u32, lo: u32, width: u32) -> u32 {
    (x >> lo) & ((1 << width) - 1)
}

/// Decode a `.kind::f16`/`.kind::f8f6f4` instruction descriptor, failing only
/// on a set reserved bit (6 or 23); `.kind`-dependent validity is the caller's.
pub fn decode_instruction_descriptor(
    idesc: u32,
) -> Result<InstructionDescriptor, ReservedIdescBit> {
    if let Some(bit) = [6, 23].into_iter().find(|&b| bits(idesc, b, 1) != 0) {
        return Err(ReservedIdescBit(bit));
    }
    Ok(InstructionDescriptor {
        sparse: bits(idesc, 2, 1) != 0,
        dtype: bits(idesc, 4, 2),
        atype: bits(idesc, 7, 3),
        btype: bits(idesc, 10, 3),
        negate_a: bits(idesc, 13, 1) != 0,
        negate_b: bits(idesc, 14, 1) != 0,
        transpose_a: bits(idesc, 15, 1) != 0,
        transpose_b: bits(idesc, 16, 1) != 0,
        n: bits(idesc, 17, 6) << 3,
        m: bits(idesc, 24, 5) << 4,
        k_select: if bits(idesc, 29, 1) == 0 {
            KSelect::Base
        } else {
            KSelect::Wide
        },
        saturate: bits(idesc, 3, 1) != 0,
        max_shift: bits(idesc, 30, 2),
    })
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

/// Decoded shared-memory matrix descriptor (PTX ISA 9.7.17.4.1, Table 43),
/// with `leading_dim_byte_offset`/`stride_dim_byte_offset`/`base_offset`
/// recovered to real byte values (the field's `<< 4` undone).
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
    /// `lut::b` K-segment start offset (bit 53): only meaningful under
    /// `.decompress::lut::b`, which is not modeled.
    pub lut_b_offset: bool,
    pub swizzle_mode: SwizzleMode,
}

/// Why a 64-bit shared-memory matrix descriptor is malformed (PTX ISA
/// 9.7.18.4.1, Table 49).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DescriptorError {
    /// The swizzle-mode field (bits 61-63) holds one of its documented-
    /// invalid encodings: 3, 5 or 7.
    InvalidSwizzle(u8),
    /// A "Reserved - Must be 0" bit (15 or 31) is set.
    ReservedBit(u32),
    /// A fixed-constant field differs from its required value: bits 46-48
    /// must be `0b001`, bits 54-60 must be 0.
    FixedField { lo: u32, expected: u64, found: u64 },
}

impl std::fmt::Display for DescriptorError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::InvalidSwizzle(sw) => write!(f, "invalid swizzle-mode encoding {sw}"),
            Self::ReservedBit(bit) => write!(f, "reserved bit {bit} is set (must be 0)"),
            Self::FixedField {
                lo,
                expected,
                found,
            } => write!(
                f,
                "fixed-constant field at bit {lo} is {found:#b} (must be {expected:#b})"
            ),
        }
    }
}

/// `matrix-descriptor-encode`'s inverse: the 14-bit field holds `(real >> 4)
/// & 0x3FFF`.
fn decode_encoded_offset(field: u64) -> u64 {
    field << 4
}

/// Decode a 64-bit shared-memory matrix descriptor (ISA 9.7.18.4.1, Table 49),
/// rejecting bad swizzle modes, set reserved bits, and off-value fixed fields.
/// Address fields keep all 15 bits so bogus values go out of bounds, not wrap.
pub fn decode_matrix_descriptor(desc: u64) -> Result<MatrixDescriptor, DescriptorError> {
    let field = |lo: u32, width: u32| (desc >> lo) & ((1 << width) - 1);
    let swizzle_mode = match field(61, 3) as u8 {
        0 => SwizzleMode::None,
        1 => SwizzleMode::Swizzle128BWith32BAtomicity,
        2 => SwizzleMode::Swizzle128B,
        4 => SwizzleMode::Swizzle64B,
        6 => SwizzleMode::Swizzle32B,
        other => return Err(DescriptorError::InvalidSwizzle(other)),
    };
    if let Some(bit) = [15, 31].into_iter().find(|&b| field(b, 1) != 0) {
        return Err(DescriptorError::ReservedBit(bit));
    }
    for (lo, width, expected) in [(46, 3, 0b001), (54, 7, 0)] {
        let found = field(lo, width);
        if found != expected {
            return Err(DescriptorError::FixedField {
                lo,
                expected,
                found,
            });
        }
    }
    Ok(MatrixDescriptor {
        start_addr: decode_encoded_offset(field(0, 15)),
        leading_dim_byte_offset: decode_encoded_offset(field(16, 15)),
        stride_dim_byte_offset: decode_encoded_offset(field(32, 14)),
        base_offset: field(49, 3) as u8,
        absolute_leading_stride: field(52, 1) != 0,
        lut_b_offset: field(53, 1) != 0,
        swizzle_mode,
    })
}

/// One 16-byte swizzle "cell" - the unit the permutation operates on,
/// regardless of the matrix's own element size (PTX ISA 5.5.7: "each
/// element (numbered cell) is 16 byte").
const CELL_BYTES: u64 = 16;

/// `(R, W)` of a swizzled mode's atom: stride-dim rows by leading-dim cells;
/// `R * W * CELL_BYTES` is the pattern size of Table 43/44. Confirmed against
/// Figures 219/222-229; 128B-with-32B-atomicity rests on Figure 219 alone.
pub(crate) fn atom_shape(mode: SwizzleMode) -> (u64, u64) {
    match mode {
        SwizzleMode::Swizzle32B => (8, 2),
        SwizzleMode::Swizzle64B => (8, 4),
        SwizzleMode::Swizzle128B => (8, 8),
        SwizzleMode::Swizzle128BWith32BAtomicity => (4, 8),
        SwizzleMode::None => unreachable!("None has no atom - handled separately"),
    }
}

/// Shared-memory byte address of the element at swizzle-space `(stride_idx,
/// leading_idx)` via `desc`. `None` mode is linear with SBO as row pitch;
/// others tile atoms by SBO/LBO. Caller must reject nonzero `base_offset`.
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

    let linear = desc.start_addr
        + (stride_idx / r) * desc.stride_dim_byte_offset
        + (cell / w) * desc.leading_dim_byte_offset
        + (stride_idx % r) * row_bytes
        + (cell % w) * CELL_BYTES
        + elem_in_cell * elem_bytes;
    // The swizzle XORs address bits `[m, m+b)` with `[m+s, m+s+b)`, so it
    // also holds inside an atom. TODO: check these bit ranges in more detail
    // against https://docs.nvidia.com/cuda/pdf/ptx_isa_9.0.pdf
    let (b, m, s) = match desc.swizzle_mode {
        SwizzleMode::Swizzle32B => (1, 4, 3),
        SwizzleMode::Swizzle64B => (2, 4, 3),
        SwizzleMode::Swizzle128B => (3, 4, 3),
        SwizzleMode::Swizzle128BWith32BAtomicity => (2, 5, 2),
        SwizzleMode::None => unreachable!("None returns before the swizzle"),
    };
    linear ^ (((linear >> (m + s)) & ((1 << b) - 1)) << m)
}

/// Which of an MMA operand's two axes is contiguous in shared memory
/// (PTX ISA 9.7.17.10.6: `idesc`'s transpose bit selects it).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Major {
    K,
    Mn,
}

/// Address of MMA operand element `(mn_idx, k_idx)` in the ISA's canonical
/// layouts (9.7.16.5.1/9.7.17.10.6). K-major `None` is the 8x16B core-matrix
/// layout (not TMA row-major); MN-major `None` is unconfirmed, so `None`.
pub fn operand_element_addr(
    desc: &MatrixDescriptor,
    major: Major,
    mn_idx: u64,
    k_idx: u64,
    elem_bytes: u64,
) -> Option<u64> {
    match (desc.swizzle_mode, major) {
        (SwizzleMode::None, Major::K) => {
            let cell_elems = CELL_BYTES / elem_bytes;
            Some(
                desc.start_addr
                    + (mn_idx % 8) * CELL_BYTES
                    + (mn_idx / 8) * desc.stride_dim_byte_offset
                    + (k_idx / cell_elems) * desc.leading_dim_byte_offset
                    + (k_idx % cell_elems) * elem_bytes,
            )
        }
        (SwizzleMode::None, Major::Mn) => None,
        (_, Major::K) => Some(swizzled_element_addr(desc, mn_idx, k_idx, elem_bytes)),
        (_, Major::Mn) => Some(swizzled_element_addr(desc, k_idx, mn_idx, elem_bytes)),
    }
}

/// Tensor Memory lanes, all of which a full-datapath `D` spans (PTX ISA 9.7.17.1).
const TMEM_LANES: u32 = 128;

/// How a `.cta_group::1` operation's `M x N` `D` sits in Tensor Memory from
/// its first lane (PTX ISA 9.7.18.10.5).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DLayout {
    /// Layouts D (M = 128) and G (M = 32, `.ws`): `128 / M` row-groups of `M`
    /// lanes, each a slice of `N / (128 / M)` columns.
    Stacked,
    /// Layout F (M = 64, not `.ws`, half the datapath): rows `16w..16w + 15`
    /// in lanes `32w..32w + 15`, each row all `N` columns.
    HalfDatapath,
}

impl DLayout {
    /// Whether `D` may start at lane `lane`. Layout F fills lanes 0-15 of each
    /// quadrant, so a second `D` may start at lane 16 and fill the other half.
    pub fn may_start_at(self, lane: u32) -> bool {
        match self {
            Self::Stacked => lane == 0,
            Self::HalfDatapath => lane == 0 || lane == 16,
        }
    }

    /// `(lane, column offset)` of element `(m, n)`, from `D`'s first lane.
    pub fn cell(self, m: u32, n: u32, (m_dim, n_dim): (u32, u32)) -> (u32, u32) {
        match self {
            Self::Stacked => {
                let cols_per_group = self.cols((m_dim, n_dim));
                (m + m_dim * (n / cols_per_group), n % cols_per_group)
            }
            Self::HalfDatapath => (32 * (m / 16) + m % 16, n),
        }
    }

    /// Columns `D` spans.
    pub fn cols(self, (m_dim, n_dim): (u32, u32)) -> u32 {
        match self {
            Self::Stacked => n_dim / (TMEM_LANES / m_dim),
            Self::HalfDatapath => n_dim,
        }
    }

    /// Whether `D` occupies `lane`, counted from its first lane.
    pub fn holds_lane(self, lane: u32) -> bool {
        match self {
            Self::Stacked => lane < TMEM_LANES,
            Self::HalfDatapath => lane < TMEM_LANES && lane % 32 < 16,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// `idesc` from the corpus kernel `triton_generated.ptx` (`mov.b32 %r94,
    /// 138477584`): dense, D=f32, A/B=f16, no negate, transpose A=0,
    /// transpose B=1, N=256, M=128.
    #[test]
    fn test_decode_real_kernel_idesc() {
        let d = decode_instruction_descriptor(138477584).unwrap();
        assert!(!d.sparse);
        assert_eq!(d.dtype, 1);
        assert_eq!(d.atype, 0);
        assert_eq!(d.btype, 0);
        assert!(!d.negate_a);
        assert!(!d.negate_b);
        assert!(!d.transpose_a);
        assert!(d.transpose_b);
        assert_eq!(d.n, 256);
        assert_eq!(d.m, 128);
        assert_eq!(d.k_select, KSelect::Base);
    }

    /// Bit 29 is the K Dimension field, adjacent to `M`'s top bit (28):
    /// setting it must not perturb `M` and must not be dropped.
    #[test]
    fn test_decode_k_dimension_bit() {
        let d = decode_instruction_descriptor(138477584 | (1 << 29)).unwrap();
        assert_eq!(d.k_select, KSelect::Wide);
        assert_eq!(d.m, 128);
        assert_eq!(d.n, 256);
    }

    /// `idesc` 0x08040010 from the B200 fp8 MatrixVectorMultiplication kernel:
    /// dense, D=f32, A/B type 0, no negate/transpose, N=16, M=128. Type 0 is
    /// e4m3 under `.kind::f8f6f4` (f16 under `.kind::f16`); 1 is e5m2.
    #[test]
    fn test_decode_real_fp8_kernel_idesc() {
        let d = decode_instruction_descriptor(0x0804_0010).unwrap();
        assert!(!d.sparse);
        assert_eq!(d.dtype, 1);
        assert_eq!(d.atype, 0);
        assert_eq!(d.btype, 0);
        assert!(!d.negate_a);
        assert!(!d.negate_b);
        assert!(!d.transpose_a);
        assert!(!d.transpose_b);
        assert_eq!(d.n, 16);
        assert_eq!(d.m, 128);

        let kind = Tcgen05MmaKind::F8f6f4;
        assert_eq!(
            OperandFormat::decode(kind, d.atype),
            Some(OperandFormat::E4m3)
        );
        assert_eq!(OperandFormat::decode(kind, 1), Some(OperandFormat::E5m2));
        assert_eq!(
            OperandFormat::decode(Tcgen05MmaKind::F16, d.atype),
            Some(OperandFormat::F16)
        );
        assert_eq!(
            OperandFormat::decode(Tcgen05MmaKind::F16, 1),
            Some(OperandFormat::Bf16)
        );
        assert_eq!(k_dim(kind), 32);
    }

    /// `a-desc`'s static half (`%rd69 | 4611756662049472512`): swizzle mode 2
    /// (128B), stride-dim offset 1024, leading-dim offset 0, base offset 0.
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

    /// `b-desc`'s static half (`%rd70 | 4611756662083026944`): like `a-desc`,
    /// but leading-dim offset 8192 - B's leading dim (N = 256, N-major) spans
    /// several swizzle atoms, unlike A's (K = 16).
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

    /// Bits 46-48 of every well-formed descriptor: the fixed `0b001`.
    const FIXED_CONSTANT: u64 = 1 << 46;

    #[test]
    fn test_invalid_swizzle_mode_rejected() {
        for invalid in [3u64, 5, 7] {
            let desc = FIXED_CONSTANT | invalid << 61;
            assert_eq!(
                decode_matrix_descriptor(desc),
                Err(DescriptorError::InvalidSwizzle(invalid as u8))
            );
        }
    }

    #[test]
    fn test_no_swizzle_mode_decodes() {
        let d = decode_matrix_descriptor(FIXED_CONSTANT).unwrap();
        assert_eq!(d.swizzle_mode, SwizzleMode::None);
    }

    #[test]
    fn test_descriptor_reserved_bits_rejected() {
        for bit in [15, 31] {
            assert_eq!(
                decode_matrix_descriptor(FIXED_CONSTANT | 1 << bit),
                Err(DescriptorError::ReservedBit(bit))
            );
        }
    }

    #[test]
    fn test_descriptor_fixed_constant_fields_checked() {
        // Bits 46-48 missing their fixed 0b001, or holding anything else.
        for found in [0b000, 0b010, 0b011, 0b111] {
            assert_eq!(
                decode_matrix_descriptor(found << 46),
                Err(DescriptorError::FixedField {
                    lo: 46,
                    expected: 0b001,
                    found
                })
            );
        }
        // Bits 54-60 must be 0.
        assert_eq!(
            decode_matrix_descriptor(FIXED_CONSTANT | 1 << 57),
            Err(DescriptorError::FixedField {
                lo: 54,
                expected: 0,
                found: 1 << 3
            })
        );
    }

    /// Address fields decode at their full 15-bit width: bit 14 is never
    /// produced by `matrix-descriptor-encode`, so masking it off would wrap an
    /// out-of-range address back into shared memory.
    #[test]
    fn test_descriptor_address_fields_are_not_truncated() {
        let d = decode_matrix_descriptor(FIXED_CONSTANT | 1 << 14 | 1 << 30).unwrap();
        assert_eq!(d.start_addr, 1 << 18);
        assert_eq!(d.leading_dim_byte_offset, 1 << 18);
    }

    #[test]
    fn test_descriptor_lut_b_offset_bit_decodes() {
        assert!(
            !decode_matrix_descriptor(FIXED_CONSTANT)
                .unwrap()
                .lut_b_offset
        );
        assert!(
            decode_matrix_descriptor(FIXED_CONSTANT | 1 << 53)
                .unwrap()
                .lut_b_offset
        );
    }

    #[test]
    fn test_idesc_reserved_bits_rejected() {
        for bit in [6, 23] {
            assert_eq!(
                decode_instruction_descriptor(0x0804_0010 | 1 << bit),
                Err(ReservedIdescBit(bit))
            );
        }
    }

    #[test]
    fn test_idesc_saturate_decode() {
        let saturate = |idesc| decode_instruction_descriptor(idesc).unwrap().saturate;
        assert!(saturate(0x0804_0010 | 1 << 3));
        assert!(!saturate(0x0804_0010));
    }

    #[test]
    fn test_idesc_max_shift_decode() {
        let max_shift = |idesc| decode_instruction_descriptor(idesc).unwrap().max_shift;
        assert_eq!(max_shift(0x0804_0010 | 2 << 30), 2);
        assert_eq!(max_shift(0x0804_0010), 0);
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
            lut_b_offset: false,
            swizzle_mode: SwizzleMode::Swizzle128B,
        }
    }

    /// Reproduces Figure 228 (K-major 128B swizzle, 4-byte elements): logical
    /// `(1, 4)` (element 36) sits at physical cell 0 of row 1, and `(3, 24)`
    /// (element 120) at cell 5 of row 3.
    #[test]
    fn test_swizzle_matches_figure_228_k_major() {
        let desc = atomless_desc();
        // Physical cell `cell` of row `row`: each 128B-swizzle row is 128
        // bytes wide.
        let at = |row: u64, cell: u64| row * 128 + cell * CELL_BYTES;
        // (row=1, col=4) lands in cell 0 of row 1.
        assert_eq!(swizzled_element_addr(&desc, 1, 4, 4), at(1, 0));
        // (row=3, col=24): logical cell 6, lands in physical cell 5.
        assert_eq!(swizzled_element_addr(&desc, 3, 24, 4), at(3, 5));
    }

    /// The diagonal (`stride_idx == leading_idx` in cells) always swizzles to
    /// cell 0 (`a XOR a == 0`), checking every row at once.
    #[test]
    fn test_swizzle_diagonal_lands_in_cell_zero() {
        let desc = atomless_desc();
        for row in 0..8u64 {
            let addr = swizzled_element_addr(&desc, row, row * 8, 2); // row*8 elems = logical cell `row`
            assert_eq!(addr, row * 128);
        }
    }

    /// Real kernel's `A` descriptor (K=16, f16): row 8 enters the second stride
    /// atom, adding exactly one `stride_dim_byte_offset` (1024) to row 0's
    /// intra-atom address.
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
            lut_b_offset: false,
            swizzle_mode: mode,
        }
    }

    /// For a 16-byte element (`elem_bytes = CELL_BYTES`), the address in cells:
    /// `atom_row * row_width + swizzled_cell`, the diagrams' own numbering, so
    /// assertions transcribe the figures directly.
    fn swizzled_cell_index(desc: &MatrixDescriptor, stride_idx: u64, leading_cell: u64) -> u64 {
        swizzled_element_addr(desc, stride_idx, leading_cell, CELL_BYTES) / CELL_BYTES
    }

    /// Figure 226/227 (no swizzle): identity in both orientations. `None` uses
    /// `stride_dim_byte_offset` as the row pitch, so it must be set here.
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

    /// Figure 219 (128B swizzle with 32B atomicity, MN-major only: the ISA has
    /// no K-major counterpart, so this mode is less cross-checked).
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

    /// Layout F (M = 64, not `.ws`): rows `16w..16w + 15` in lanes `32w..32w +
    /// 15`, every row all `N` columns; lanes `16..31` of each quadrant stay empty.
    #[test]
    fn test_half_datapath_d_layout() {
        let layout = DLayout::HalfDatapath;
        assert_eq!(layout.cell(0, 7, (64, 64)), (0, 7));
        assert_eq!(layout.cell(17, 63, (64, 64)), (33, 63));
        assert_eq!(layout.cell(63, 0, (64, 64)), (111, 0));
        assert_eq!(layout.cols((64, 64)), 64);
        assert!(layout.holds_lane(15) && !layout.holds_lane(16) && layout.holds_lane(32));
    }

    /// A Layout F `D` may start at lane 0 or 16 (two of them share the
    /// quadrants), a stacked one only at lane 0.
    #[test]
    fn test_d_layout_first_lanes() {
        let half = DLayout::HalfDatapath;
        assert!(half.may_start_at(0) && half.may_start_at(16) && !half.may_start_at(32));
        assert!(DLayout::Stacked.may_start_at(0) && !DLayout::Stacked.may_start_at(16));
    }
}
