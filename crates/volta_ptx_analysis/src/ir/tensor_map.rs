//! Tensor-map types: the fields `tensormap.replace` writes (PTX ISA 9.7.9.27, Table 33),
//! named since the 128-byte object is opaque (5.5.8), and how `cp.async.bulk.tensor`
//! copies through a map (its `.load_mode`, an im2col map's box).

use crate::ir::Operand;

/// `.field3`'s `.elemtype` encoding (Table 33). Only types with a 1:1
/// `ScalarType` are modeled; the sub-byte pack types (`new_val` 13-15) are
/// rejected at lowering.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TensorElemType {
    U8,
    U16,
    U32,
    S32,
    U64,
    S64,
    F16,
    F32,
    F32Ftz,
    F64,
    Bf16,
    Tf32,
}

impl TensorElemType {
    pub fn decode(code: u32) -> Result<Self, u32> {
        Ok(match code {
            0 => Self::U8,
            1 => Self::U16,
            2 => Self::U32,
            3 => Self::S32,
            4 => Self::U64,
            5 => Self::S64,
            6 => Self::F16,
            7 => Self::F32,
            8 => Self::F32Ftz,
            9 => Self::F64,
            10 => Self::Bf16,
            11 => Self::Tf32,
            other => return Err(other),
        })
    }

    /// Byte width of one element.
    pub fn byte_width(self) -> u64 {
        match self {
            Self::U8 => 1,
            Self::U16 | Self::F16 | Self::Bf16 => 2,
            Self::U32 | Self::S32 | Self::F32 | Self::F32Ftz | Self::Tf32 => 4,
            Self::U64 | Self::S64 | Self::F64 => 8,
        }
    }

    pub fn is_float(self) -> bool {
        matches!(
            self,
            Self::F16 | Self::F32 | Self::F32Ftz | Self::F64 | Self::Bf16 | Self::Tf32
        )
    }
}

/// `.field3`'s `.interleave_layout` encoding (Table 33).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TensorInterleaveLayout {
    None,
    Interleave16B,
    Interleave32B,
}

impl TensorInterleaveLayout {
    pub fn decode(code: u32) -> Result<Self, u32> {
        Ok(match code {
            0 => Self::None,
            1 => Self::Interleave16B,
            2 => Self::Interleave32B,
            other => return Err(other),
        })
    }
}

/// `.field3`'s `.swizzle_mode` encoding (Table 33, PTX ISA 5.5.7). Distinct
/// from the matrix descriptor's `eval::tcgen05_mma::SwizzleMode`; see
/// `eval::tensor_map_table::to_mma_swizzle_mode` for the translation.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TensorSwizzleMode {
    None,
    Swizzle32B,
    Swizzle64B,
    Swizzle128B,
    Swizzle96B,
}

impl TensorSwizzleMode {
    pub fn decode(code: u32) -> Result<Self, u32> {
        Ok(match code {
            0 => Self::None,
            1 => Self::Swizzle32B,
            2 => Self::Swizzle64B,
            3 => Self::Swizzle128B,
            4 => Self::Swizzle96B,
            other => return Err(other),
        })
    }
}

/// `.field3`'s `.swizzle_atomicity` encoding (Table 33).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TensorSwizzleAtomicity {
    Atomicity16B,
    Atomicity32B,
    Atomicity32BWith8BFlip,
    Atomicity64B,
}

impl TensorSwizzleAtomicity {
    pub fn decode(code: u32) -> Result<Self, u32> {
        Ok(match code {
            0 => Self::Atomicity16B,
            1 => Self::Atomicity32B,
            2 => Self::Atomicity32BWith8BFlip,
            3 => Self::Atomicity64B,
            other => return Err(other),
        })
    }
}

/// `.field3`'s `.fill_mode` encoding (Table 33).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TensorFillMode {
    Zero,
    OobNan,
}

impl TensorFillMode {
    pub fn decode(code: u32) -> Result<Self, u32> {
        Ok(match code {
            0 => Self::Zero,
            1 => Self::OobNan,
            other => return Err(other),
        })
    }
}

/// A `cp.async.bulk.tensor` load's `.load_mode` (PTX ISA 5.5.3, 5.5.4).
#[derive(Debug, Clone, PartialEq)]
pub enum TensorLoadMode {
    /// `.tile`, the ISA's default: a box of the tensor
    Tile,
    /// `.im2col`: a pixel column; `offsets` (16-bit) shift the filter base's spatial
    /// coordinates, innermost (W) first like the tensor coordinates
    Im2col { offsets: Vec<Operand> },
}

/// What one copy through an im2col tensor map moves (PTX ISA 5.5.4, `cuTensorMapEncodeIm2col`):
/// the bounding box's corners, one per spatial dimension innermost (W) first, as offsets from
/// the tensor's first and last pixel, and the pixel column's size.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Im2colBox {
    pub lower_corner: Vec<i32>,
    pub upper_corner: Vec<i32>,
    pub channels_per_pixel: u32,
    pub pixels_per_column: u32,
}

/// One `tensormap.replace` field write, already decoded/validated at
/// lowering time (`.field3`/`ord` immediates are required by the ISA and
/// statically known there - see `lower::tma::lower_tensormap_replace`).
#[derive(Debug, Clone)]
pub enum TensormapFieldWrite {
    GlobalAddress(Operand),
    Rank(Operand),
    BoxDim { ord: u32, new_val: Operand },
    GlobalDim { ord: u32, new_val: Operand },
    GlobalStride { ord: u32, new_val: Operand },
    ElementStride { ord: u32, new_val: Operand },
    Elemtype(TensorElemType),
    InterleaveLayout(TensorInterleaveLayout),
    SwizzleMode(TensorSwizzleMode),
    SwizzleAtomicity(TensorSwizzleAtomicity),
    FillMode(TensorFillMode),
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_elemtype_decodes_every_modeled_code() {
        assert_eq!(TensorElemType::decode(0), Ok(TensorElemType::U8));
        assert_eq!(TensorElemType::decode(6), Ok(TensorElemType::F16));
        assert_eq!(TensorElemType::decode(11), Ok(TensorElemType::Tf32));
    }

    #[test]
    fn test_elemtype_rejects_sub_byte_pack_types() {
        // Table 33's `new_val` 13-15: the sub-byte pack types, deliberately
        // not modeled (see the module doc comment).
        assert_eq!(TensorElemType::decode(13), Err(13));
        assert_eq!(TensorElemType::decode(15), Err(15));
        assert_eq!(TensorElemType::decode(16), Err(16));
    }

    #[test]
    fn test_elemtype_byte_width_and_float_classification() {
        assert_eq!(TensorElemType::U8.byte_width(), 1);
        assert_eq!(TensorElemType::F16.byte_width(), 2);
        assert_eq!(TensorElemType::F32.byte_width(), 4);
        assert_eq!(TensorElemType::F64.byte_width(), 8);
        assert!(TensorElemType::F16.is_float());
        assert!(!TensorElemType::U32.is_float());
    }

    #[test]
    fn test_swizzle_mode_decodes_every_table_33_code() {
        assert_eq!(TensorSwizzleMode::decode(0), Ok(TensorSwizzleMode::None));
        assert_eq!(
            TensorSwizzleMode::decode(2),
            Ok(TensorSwizzleMode::Swizzle64B)
        );
        assert_eq!(TensorSwizzleMode::decode(5), Err(5));
    }

    #[test]
    fn test_swizzle_atomicity_and_fill_mode_decode() {
        assert_eq!(
            TensorSwizzleAtomicity::decode(2),
            Ok(TensorSwizzleAtomicity::Atomicity32BWith8BFlip)
        );
        assert_eq!(TensorSwizzleAtomicity::decode(4), Err(4));
        assert_eq!(TensorFillMode::decode(0), Ok(TensorFillMode::Zero));
        assert_eq!(TensorFillMode::decode(1), Ok(TensorFillMode::OobNan));
        assert_eq!(TensorFillMode::decode(2), Err(2));
    }
}
