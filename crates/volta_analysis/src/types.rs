//! Type system for PTX lowering
//!
//! This module provides type classification, compatibility checking,
//! and instruction category validation for the lowering pass.

use std::fmt;

use volta_frontend::ast::ScalarType;

/// Register storage class (determines which register array a value lives in)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RegClass {
    Pred = 0,
    Bits8 = 1,
    Bits16 = 2,
    Bits32 = 3,
    Bits64 = 4,
    Bits128 = 5,
}

impl RegClass {
    pub const COUNT: usize = 6;

    pub fn from_scalar_type(ty: ScalarType) -> Self {
        match ty {
            ScalarType::Pred => RegClass::Pred,
            ScalarType::S8 | ScalarType::U8 | ScalarType::B8 => RegClass::Bits8,
            ScalarType::S16
            | ScalarType::U16
            | ScalarType::F16
            | ScalarType::Bf16
            | ScalarType::B16 => RegClass::Bits16,
            ScalarType::S32
            | ScalarType::U32
            | ScalarType::F32
            | ScalarType::Tf32
            | ScalarType::B32
            | ScalarType::F16x2
            | ScalarType::Bf16x2
            | ScalarType::S16x2
            | ScalarType::U16x2 => RegClass::Bits32,
            ScalarType::S64
            | ScalarType::U64
            | ScalarType::F64
            | ScalarType::B64
            | ScalarType::F32x2 => RegClass::Bits64,
            ScalarType::B128 | ScalarType::B1024 => RegClass::Bits128,
        }
    }

    pub fn size_bytes(&self) -> usize {
        match self {
            Self::Pred => 1,
            Self::Bits8 => 1,
            Self::Bits16 => 2,
            Self::Bits32 => 4,
            Self::Bits64 => 8,
            Self::Bits128 => 16,
        }
    }
}

/// Register counts by class
#[derive(Debug, Clone, Copy, Default)]
pub struct RegCounts([u32; RegClass::COUNT]);

impl RegCounts {
    pub fn new(counts: [u32; RegClass::COUNT]) -> Self {
        Self(counts)
    }

    pub fn get(&self, class: RegClass) -> u32 {
        self.0[class as usize]
    }

    pub fn pred(&self) -> u32 {
        self.0[RegClass::Pred as usize]
    }

    pub fn b8(&self) -> u32 {
        self.0[RegClass::Bits8 as usize]
    }

    pub fn b16(&self) -> u32 {
        self.0[RegClass::Bits16 as usize]
    }

    pub fn b32(&self) -> u32 {
        self.0[RegClass::Bits32 as usize]
    }

    pub fn b64(&self) -> u32 {
        self.0[RegClass::Bits64 as usize]
    }

    pub fn b128(&self) -> u32 {
        self.0[RegClass::Bits128 as usize]
    }
}

impl fmt::Display for RegCounts {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let parts: Vec<_> = [
            (self.pred(), "pred"),
            (self.b8(), "b8"),
            (self.b16(), "b16"),
            (self.b32(), "b32"),
            (self.b64(), "b64"),
            (self.b128(), "b128"),
        ]
        .into_iter()
        .filter(|(count, _)| *count > 0)
        .map(|(count, name)| format!("{} {}", count, name))
        .collect();

        if parts.is_empty() {
            write!(f, "none")
        } else {
            write!(f, "{}", parts.join(", "))
        }
    }
}

/// Extension trait for ScalarType to add type classification methods
pub trait ScalarTypeExt {
    fn is_float(&self) -> bool;
    fn is_signed_int(&self) -> bool;
    fn is_unsigned_int(&self) -> bool;
    fn is_integer(&self) -> bool;
    fn is_bits_type(&self) -> bool;
    fn is_predicate(&self) -> bool;
    fn reg_class(&self) -> RegClass;
    fn size_bytes(&self) -> usize;
    /// Get the widened type (double the bit width), if one exists
    fn widen(&self) -> Option<ScalarType>;
    fn is_packed_pair(&self) -> bool;
    fn packed_lane(&self) -> Option<ScalarType>;
}

impl ScalarTypeExt for ScalarType {
    fn is_float(&self) -> bool {
        matches!(
            self,
            ScalarType::F16
                | ScalarType::F32
                | ScalarType::F64
                | ScalarType::Bf16
                | ScalarType::Tf32
                | ScalarType::F16x2
                | ScalarType::Bf16x2
                | ScalarType::F32x2
        )
    }

    fn is_signed_int(&self) -> bool {
        matches!(
            self,
            ScalarType::S8
                | ScalarType::S16
                | ScalarType::S32
                | ScalarType::S64
                | ScalarType::S16x2
        )
    }

    fn is_unsigned_int(&self) -> bool {
        matches!(
            self,
            ScalarType::U8
                | ScalarType::U16
                | ScalarType::U32
                | ScalarType::U64
                | ScalarType::U16x2
        )
    }

    fn is_integer(&self) -> bool {
        self.is_signed_int() || self.is_unsigned_int()
    }

    fn is_bits_type(&self) -> bool {
        matches!(
            self,
            ScalarType::B8
                | ScalarType::B16
                | ScalarType::B32
                | ScalarType::B64
                | ScalarType::B128
                | ScalarType::B1024
        )
    }

    fn is_predicate(&self) -> bool {
        matches!(self, ScalarType::Pred)
    }

    fn reg_class(&self) -> RegClass {
        RegClass::from_scalar_type(*self)
    }

    /// True for the two packed half-precision float types whose arithmetic
    /// is modeled - each lane held as an independent `ExprId` in a
    /// `Value::Pair`, never bit-encoded (see `eval::value::Value` and the
    /// packed dispatch in `eval::interp`'s `BinOp`/`UnaryOp`/`Fma` arms).
    /// Excludes the still-unmodeled packed integer (`U16x2`/`S16x2`) and
    /// `F32x2` forms.
    fn is_packed_pair(&self) -> bool {
        matches!(self, ScalarType::F16x2 | ScalarType::Bf16x2)
    }

    /// The scalar element type held in each lane of a packed pair (`F16x2`
    /// -> `F16`, `Bf16x2` -> `Bf16`), for evaluating one lane at a time
    /// through the ordinary scalar arithmetic path. `None` for anything
    /// `is_packed_pair` doesn't cover.
    fn packed_lane(&self) -> Option<ScalarType> {
        match self {
            ScalarType::F16x2 => Some(ScalarType::F16),
            ScalarType::Bf16x2 => Some(ScalarType::Bf16),
            _ => None,
        }
    }

    fn size_bytes(&self) -> usize {
        (self.bits() as usize).div_ceil(8)
    }

    fn widen(&self) -> Option<ScalarType> {
        match self {
            // Signed integers
            ScalarType::S8 => Some(ScalarType::S16),
            ScalarType::S16 => Some(ScalarType::S32),
            ScalarType::S32 => Some(ScalarType::S64),
            // Unsigned integers
            ScalarType::U8 => Some(ScalarType::U16),
            ScalarType::U16 => Some(ScalarType::U32),
            ScalarType::U32 => Some(ScalarType::U64),
            // Bit types
            ScalarType::B8 => Some(ScalarType::B16),
            ScalarType::B16 => Some(ScalarType::B32),
            ScalarType::B32 => Some(ScalarType::B64),
            ScalarType::B64 => Some(ScalarType::B128),
            // Float types
            ScalarType::F16 => Some(ScalarType::F32),
            ScalarType::F32 => Some(ScalarType::F64),
            // No wider type exists
            _ => None,
        }
    }
}

/// Result of type compatibility check
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TypeCompatibility {
    /// Types are exactly equal
    Exact,
    /// Types are compatible (same size, or bit-type matches)
    Compatible,
    /// Types are incompatible
    Incompatible { reason: &'static str },
}

/// Check if `actual` type can be used where `expected` is required
pub fn check_type_compatibility(actual: ScalarType, expected: ScalarType) -> TypeCompatibility {
    // Exact match is always fine
    if actual == expected {
        return TypeCompatibility::Exact;
    }

    let actual_size = actual.bits();
    let expected_size = expected.bits();

    // Different sizes are never compatible
    if actual_size != expected_size {
        return TypeCompatibility::Incompatible {
            reason: "size mismatch",
        };
    }

    // Bit-types are compatible with anything of same size
    if actual.is_bits_type() || expected.is_bits_type() {
        return TypeCompatibility::Compatible;
    }

    // Signed/unsigned integers of same size are compatible
    // (instruction determines interpretation)
    if actual.is_integer() && expected.is_integer() {
        return TypeCompatibility::Compatible;
    }

    // Float<->int of same size is NOT compatible
    // (this would be a semantic error)
    if actual.is_float() != expected.is_float() {
        return TypeCompatibility::Incompatible {
            reason: "cannot mix float and integer types (use cvt for conversion)",
        };
    }

    // Different float types of same size (e.g., f16 vs bf16) are compatible
    // at the bit level (both stored in same register class)
    if actual.is_float() && expected.is_float() {
        return TypeCompatibility::Compatible;
    }

    TypeCompatibility::Incompatible {
        reason: "incompatible types",
    }
}

/// Instruction categories for type validation
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InstrCategory {
    /// Integer arithmetic: add, sub, mul, div, rem, neg, abs
    IntArith,
    /// Float arithmetic: add, sub, mul, div, neg, abs, fma
    FloatArith,
    /// Bitwise: and, or, xor, not, shl, shr
    Bitwise,
    /// Comparison: setp, set
    Comparison,
    /// Data movement: mov, ld, st
    DataMove,
    /// Conversion: cvt
    Conversion,
    /// Predicate logic: and, or, xor, not on predicates
    PredicateLogic,
    /// Transcendental: sin, cos, exp, log, sqrt, rsqrt, rcp
    Transcendental,
    /// Special: min, max (work on both int and float)
    MinMax,
}

impl InstrCategory {
    /// Check if a type is valid for this instruction category
    pub fn validate_type(&self, ty: ScalarType) -> Result<(), &'static str> {
        match self {
            Self::IntArith => {
                if ty.is_integer() {
                    Ok(())
                } else {
                    Err("integer arithmetic requires integer type")
                }
            }
            Self::FloatArith => {
                if ty.is_float() {
                    Ok(())
                } else {
                    Err("floating-point arithmetic requires float type")
                }
            }
            Self::Bitwise => {
                if ty.is_bits_type() || ty.is_integer() {
                    Ok(())
                } else {
                    Err("bitwise operations require integer or bit type")
                }
            }
            Self::Comparison => {
                // setp/set work on any scalar type
                Ok(())
            }
            Self::DataMove => {
                // mov/ld/st work on any type
                Ok(())
            }
            Self::Conversion => {
                // cvt handles its own type checking
                Ok(())
            }
            Self::PredicateLogic => {
                if ty.is_predicate() {
                    Ok(())
                } else {
                    Err("predicate logic requires pred type")
                }
            }
            Self::Transcendental => {
                if ty.is_float() {
                    Ok(())
                } else {
                    Err("transcendental functions require float type")
                }
            }
            Self::MinMax => {
                if ty.is_integer() || ty.is_float() {
                    Ok(())
                } else {
                    Err("min/max requires integer or float type")
                }
            }
        }
    }
}

/// Format a scalar type as a PTX type string (e.g., ".s32", ".f32")
pub fn format_scalar_type(ty: ScalarType) -> &'static str {
    match ty {
        ScalarType::S8 => ".s8",
        ScalarType::S16 => ".s16",
        ScalarType::S32 => ".s32",
        ScalarType::S64 => ".s64",
        ScalarType::U8 => ".u8",
        ScalarType::U16 => ".u16",
        ScalarType::U32 => ".u32",
        ScalarType::U64 => ".u64",
        ScalarType::F16 => ".f16",
        ScalarType::F32 => ".f32",
        ScalarType::F64 => ".f64",
        ScalarType::Bf16 => ".bf16",
        ScalarType::Tf32 => ".tf32",
        ScalarType::F16x2 => ".f16x2",
        ScalarType::Bf16x2 => ".bf16x2",
        ScalarType::S16x2 => ".s16x2",
        ScalarType::U16x2 => ".u16x2",
        ScalarType::F32x2 => ".f32x2",
        ScalarType::B8 => ".b8",
        ScalarType::B16 => ".b16",
        ScalarType::B32 => ".b32",
        ScalarType::B64 => ".b64",
        ScalarType::B128 => ".b128",
        ScalarType::B1024 => ".b1024",
        ScalarType::Pred => ".pred",
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_type_compatibility_exact() {
        assert_eq!(
            check_type_compatibility(ScalarType::F32, ScalarType::F32),
            TypeCompatibility::Exact
        );
    }

    #[test]
    fn test_type_compatibility_bits() {
        // b32 compatible with u32, s32, f32
        assert!(matches!(
            check_type_compatibility(ScalarType::B32, ScalarType::U32),
            TypeCompatibility::Compatible
        ));
        assert!(matches!(
            check_type_compatibility(ScalarType::B32, ScalarType::F32),
            TypeCompatibility::Compatible
        ));
    }

    #[test]
    fn test_type_compatibility_int_signedness() {
        // u32 compatible with s32
        assert!(matches!(
            check_type_compatibility(ScalarType::U32, ScalarType::S32),
            TypeCompatibility::Compatible
        ));
    }

    #[test]
    fn test_type_incompatibility_float_int() {
        // f32 NOT compatible with u32
        assert!(matches!(
            check_type_compatibility(ScalarType::F32, ScalarType::U32),
            TypeCompatibility::Incompatible { .. }
        ));
    }

    #[test]
    fn test_type_incompatibility_size() {
        // u32 NOT compatible with u64
        assert!(matches!(
            check_type_compatibility(ScalarType::U32, ScalarType::U64),
            TypeCompatibility::Incompatible { .. }
        ));
    }

    #[test]
    fn test_reg_class() {
        assert_eq!(RegClass::from_scalar_type(ScalarType::Pred), RegClass::Pred);
        assert_eq!(
            RegClass::from_scalar_type(ScalarType::U32),
            RegClass::Bits32
        );
        assert_eq!(
            RegClass::from_scalar_type(ScalarType::F32),
            RegClass::Bits32
        );
        assert_eq!(
            RegClass::from_scalar_type(ScalarType::F64),
            RegClass::Bits64
        );
    }

    #[test]
    fn test_instr_category_validation() {
        assert!(
            InstrCategory::IntArith
                .validate_type(ScalarType::S32)
                .is_ok()
        );
        assert!(
            InstrCategory::IntArith
                .validate_type(ScalarType::F32)
                .is_err()
        );
        assert!(
            InstrCategory::FloatArith
                .validate_type(ScalarType::F32)
                .is_ok()
        );
        assert!(
            InstrCategory::FloatArith
                .validate_type(ScalarType::S32)
                .is_err()
        );
    }
}
