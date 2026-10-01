//! Decoding of concrete float bit patterns: a concrete `IntConst` consumed
//! at a float (or fp8) type is a raw bit pattern from a plain `.bN`
//! producer (`mov.b32 %r, 0x3F800000` feeding an `add.f32`, a
//! `st.shared.b16` of `0x3C00` feeding a `tcgen05.mma` operand), not an
//! already-real value, so every float consumer reads it through here.
//!
//! NaN encodings are rejected (`None` from the raw decoders, a loud error
//! from [`decode_float_bits`]) - the same "reject at ingestion" policy as
//! every other f64 entry point (see `Real::from_f64`). +/-infinity decodes
//! fine (`ExprArena::float_from_f64` handles it).
//!
//! The fp8 decoders ([`decode_e4m3_byte`], [`decode_e5m2_byte`], PTX ISA
//! 5.2.3) see only concrete fp8 bytes: a symbolic fp8 element already is
//! its real value and never reaches them (see
//! `LoweredInstr::CvtE4m3x2ToF16x2`). Every finite value of every format
//! here is a dyadic rational, so decoding through `f64` is exact.

use volta_frontend::ast::ScalarType;

use crate::eval::error::{EvalError, EvalResult};
use crate::lowered::InstrId;
use crate::symbolic::{ExprArena, ExprId};

/// Read `e`, consumed at float (or fp8) type `ty`: a concrete `IntConst`
/// is decoded at `ty`'s width (`0x3F800000` is 1.0, not 1065353216), the
/// way [`decode_packed_bits`] does for packed pairs. A NaN encoding is a
/// loud error - Volta's real-valued model cannot represent it, and leaving
/// the integer in place would misread it. Symbolic values, genuine float
/// constants, and packed-pair types pass through (a pair's lanes are
/// decoded by `Interpreter::pair_operand`).
pub fn decode_float_bits(
    arena: &mut ExprArena,
    pc: InstrId,
    ty: ScalarType,
    e: ExprId,
) -> EvalResult<ExprId> {
    let Some(bits) = arena.as_int_const(e) else {
        return Ok(e);
    };
    let finite_f64 = |v: f64| (!v.is_nan()).then_some(v);
    let decoded = match ty {
        ScalarType::F16 => f16_bits_to_f64(bits as u16),
        ScalarType::Bf16 => bf16_bits_to_f64(bits as u16),
        ScalarType::F32 | ScalarType::Tf32 => finite_f64(f32::from_bits(bits as u32) as f64),
        ScalarType::F64 => finite_f64(f64::from_bits(bits as u64)),
        ScalarType::E4m3 => decode_e4m3_byte(bits as u8),
        ScalarType::E5m2 => decode_e5m2_byte(bits as u8),
        _ => return Ok(e),
    };
    let value = decoded.ok_or_else(|| EvalError::Unsupported {
        pc,
        what: format!(
            "{ty:?} operand bit pattern {bits:#x} encodes NaN, which Volta's \
             real-valued model cannot represent"
        ),
    })?;
    arena
        .float_from_f64(value)
        .map_err(|e| EvalError::Unsupported {
            pc,
            what: format!("{ty:?} operand bit pattern {bits:#x}: {e}"),
        })
}

/// Decode a raw 16-bit IEEE 754 binary16 (`f16`) bit pattern to its real
/// value. `None` for NaN; +/-infinity is `Some`.
pub fn f16_bits_to_f64(bits: u16) -> Option<f64> {
    let sign = if bits & 0x8000 != 0 { -1.0 } else { 1.0 };
    let exp = ((bits >> 10) & 0x1F) as i32;
    let mantissa = (bits & 0x3FF) as f64;
    Some(match exp {
        0 if mantissa == 0.0 => sign * 0.0,
        // Subnormal: 2^-14 * (mantissa / 1024) = mantissa * 2^-24.
        0 => sign * mantissa * 2f64.powi(-24),
        0x1F if mantissa == 0.0 => sign * f64::INFINITY,
        0x1F => return None,
        _ => sign * (1.0 + mantissa / 1024.0) * 2f64.powi(exp - 15),
    })
}

/// Decode a raw 16-bit `bf16` bit pattern to its real value. `bf16` is
/// exactly an `f32`'s high 16 bits (same 8-bit exponent/bias as `f32`,
/// truncated mantissa), so this is a plain bit-shift into `f32`, not a
/// hand-rolled decode. `None` for NaN, matching [`f16_bits_to_f64`].
pub fn bf16_bits_to_f64(bits: u16) -> Option<f64> {
    let v = f32::from_bits((bits as u32) << 16) as f64;
    if v.is_nan() { None } else { Some(v) }
}

/// Decode one `.e4m3` byte (bias 7, no infinity), or `None` for NaN
/// (`0x7f`/`0xff`).
pub fn decode_e4m3_byte(byte: u8) -> Option<f64> {
    let sign = (byte >> 7) & 1;
    let exponent = (byte >> 3) & 0xF;
    let mantissa = (byte & 0x7) as i32;

    if exponent == 0xF && mantissa == 0x7 {
        return None;
    }

    let magnitude = if exponent == 0 {
        mantissa as f64 * 2f64.powi(-9)
    } else {
        (1.0 + mantissa as f64 / 8.0) * 2f64.powi(exponent as i32 - 7)
    };

    Some(if sign == 1 { -magnitude } else { magnitude })
}

/// Decode one `.e5m2` byte (bias 15, IEEE-754-shaped with `±inf`), or `None`
/// for NaN.
pub fn decode_e5m2_byte(byte: u8) -> Option<f64> {
    let sign = if byte & 0x80 != 0 { -1.0 } else { 1.0 };
    let exponent = ((byte >> 2) & 0x1F) as i32;
    let mantissa = (byte & 0x3) as f64;
    let magnitude = match exponent {
        0 => mantissa * 2f64.powi(-16),
        0x1F if mantissa == 0.0 => f64::INFINITY,
        0x1F => return None,
        _ => (1.0 + mantissa / 4.0) * 2f64.powi(exponent - 15),
    };
    Some(sign * magnitude)
}

/// Split a raw packed-pair bit pattern into its two lanes' real values,
/// per `lane_ty` (`F16` or `Bf16` for a 32-bit `F16x2`/`Bf16x2` operand,
/// `F32` for a 64-bit `F32x2` one). `(lo, hi)`, matching `Value::Pair`'s
/// order; `None` if either lane is NaN.
pub fn decode_packed_bits(bits: u64, lane_ty: ScalarType) -> Option<(f64, f64)> {
    if lane_ty == ScalarType::F32 {
        // A 64-bit `f32x2` pattern: two IEEE singles, low lane first.
        let lo = f32::from_bits(bits as u32);
        let hi = f32::from_bits((bits >> 32) as u32);
        if lo.is_nan() || hi.is_nan() {
            return None;
        }
        return Some((lo as f64, hi as f64));
    }
    let lo_bits = (bits & 0xFFFF) as u16;
    let hi_bits = ((bits >> 16) & 0xFFFF) as u16;
    let decode = match lane_ty {
        ScalarType::F16 => f16_bits_to_f64,
        ScalarType::Bf16 => bf16_bits_to_f64,
        _ => unreachable!("decode_packed_bits only called for f16x2/bf16x2/f32x2 lanes"),
    };
    Some((decode(lo_bits)?, decode(hi_bits)?))
}

#[cfg(test)]
// Binary literals are grouped by (sign, exponent, mantissa) fields.
#[allow(clippy::unusual_byte_groupings)]
mod tests {
    use super::*;

    fn pc() -> InstrId {
        use id_collections::Id;
        InstrId::from_index(0)
    }

    /// Decode the concrete integer `bits` at `ty` and render the result.
    fn decode(ty: ScalarType, bits: i64) -> EvalResult<String> {
        let mut arena = ExprArena::new();
        let e = arena.int(bits);
        let r = decode_float_bits(&mut arena, pc(), ty, e)?;
        Ok(arena.display_expr(r))
    }

    fn expect_nan_error(ty: ScalarType, bits: i64) {
        match decode(ty, bits) {
            Err(EvalError::Unsupported { what, .. }) => assert!(what.contains("NaN"), "{what}"),
            other => panic!("expected a NaN rejection for {ty:?} {bits:#x}, got {other:?}"),
        }
    }

    #[test]
    fn test_decode_float_bits_reads_each_type_at_its_own_width() {
        assert_eq!(decode(ScalarType::F32, 0x3F80_0000).unwrap(), "1");
        assert_eq!(decode(ScalarType::Tf32, 0x3F80_0000).unwrap(), "1");
        assert_eq!(decode(ScalarType::F64, 0x3FF0_0000_0000_0000).unwrap(), "1");
        assert_eq!(decode(ScalarType::F16, 0x3C00).unwrap(), "1");
        assert_eq!(decode(ScalarType::Bf16, 0x3F80).unwrap(), "1");
        assert_eq!(decode(ScalarType::E4m3, 0x38).unwrap(), "1");
        assert_eq!(decode(ScalarType::E5m2, 0x3C).unwrap(), "1");
    }

    #[test]
    fn test_decode_float_bits_sign_and_infinity() {
        assert_eq!(decode(ScalarType::F32, 0xC0A0_0000).unwrap(), "-5");
        assert_eq!(decode(ScalarType::F32, 0x7F80_0000).unwrap(), "inf");
        assert_eq!(decode(ScalarType::F16, 0xFC00).unwrap(), "-inf");
        assert_eq!(decode(ScalarType::F32, 0).unwrap(), "0");
    }

    #[test]
    fn test_decode_float_bits_rejects_nan_encodings() {
        expect_nan_error(ScalarType::F32, 0x7FC0_0000);
        expect_nan_error(ScalarType::F64, 0x7FF8_0000_0000_0000);
        expect_nan_error(ScalarType::F16, 0x7E00);
        expect_nan_error(ScalarType::Bf16, 0x7FC0);
        expect_nan_error(ScalarType::E4m3, 0x7F);
        expect_nan_error(ScalarType::E5m2, 0x7E);
    }

    /// Only a concrete `IntConst` at a scalar float type is decoded: integer
    /// and packed-pair types, genuine float constants, and non-constant
    /// values come back as the same `ExprId`.
    #[test]
    fn test_decode_float_bits_passes_everything_else_through() {
        let mut arena = ExprArena::new();
        let bits = arena.int(0x3F80_0000);
        for ty in [ScalarType::U32, ScalarType::B32, ScalarType::F16x2] {
            assert_eq!(decode_float_bits(&mut arena, pc(), ty, bits).unwrap(), bits);
        }
        let real = arena.float_from_f64(1.5).unwrap();
        let symbol = arena.symbol();
        let undefined = arena.undefined();
        for e in [real, symbol, undefined] {
            assert_eq!(
                decode_float_bits(&mut arena, pc(), ScalarType::F32, e).unwrap(),
                e
            );
        }
    }

    #[test]
    fn test_f16_bits_to_f64() {
        assert_eq!(f16_bits_to_f64(0x3C00), Some(1.0));
        assert_eq!(f16_bits_to_f64(0xC000), Some(-2.0));
        assert_eq!(f16_bits_to_f64(0x7BFF), Some(65504.0));
        assert_eq!(f16_bits_to_f64(0x0001), Some(2f64.powi(-24)));
        assert_eq!(f16_bits_to_f64(0x8000), Some(-0.0));
        assert_eq!(f16_bits_to_f64(0x7C00), Some(f64::INFINITY));
        assert_eq!(f16_bits_to_f64(0x7C01), None);
    }

    #[test]
    fn test_bf16_bits_to_f64() {
        assert_eq!(bf16_bits_to_f64(0x3F80), Some(1.0));
        assert_eq!(bf16_bits_to_f64(0xC0A0), Some(-5.0));
        assert_eq!(bf16_bits_to_f64(0x7F80), Some(f64::INFINITY));
        assert_eq!(bf16_bits_to_f64(0x7FC0), None);
    }

    #[test]
    fn test_decode_packed_bits_low_lane_first() {
        assert_eq!(
            decode_packed_bits(0x4000_3C00, ScalarType::F16),
            Some((1.0, 2.0))
        );
        assert_eq!(
            decode_packed_bits(0x4000_3F80, ScalarType::Bf16),
            Some((1.0, 2.0))
        );
        assert_eq!(
            decode_packed_bits(0x4000_0000_3F80_0000, ScalarType::F32),
            Some((1.0, 2.0))
        );
        assert_eq!(decode_packed_bits(0x7E00_3C00, ScalarType::F16), None);
        assert_eq!(
            decode_packed_bits(0x3F80_0000_7FC0_0000, ScalarType::F32),
            None
        );
    }

    #[test]
    fn test_decode_e4m3_zero() {
        assert_eq!(decode_e4m3_byte(0x00), Some(0.0));
        assert_eq!(decode_e4m3_byte(0x80), Some(-0.0));
    }

    #[test]
    fn test_decode_e4m3_one_point_zero() {
        assert_eq!(decode_e4m3_byte(0b0_0111_000), Some(1.0));
    }

    #[test]
    fn test_decode_e4m3_negative() {
        assert_eq!(decode_e4m3_byte(0b1_0111_000), Some(-1.0));
    }

    #[test]
    fn test_decode_e4m3_max_finite_is_448() {
        assert_eq!(decode_e4m3_byte(0b0_1111_110), Some(448.0));
        assert_eq!(decode_e4m3_byte(0b1_1111_110), Some(-448.0));
    }

    #[test]
    fn test_decode_e4m3_min_subnormal() {
        assert_eq!(decode_e4m3_byte(0b0_0000_001), Some(2f64.powi(-9)));
    }

    #[test]
    fn test_decode_e4m3_min_normal() {
        assert_eq!(decode_e4m3_byte(0b0_0001_000), Some(2f64.powi(-6)));
    }

    #[test]
    fn test_decode_e4m3_nan_bytes() {
        assert_eq!(decode_e4m3_byte(0x7f), None);
        assert_eq!(decode_e4m3_byte(0xff), None);
    }

    #[test]
    fn test_decode_e4m3_exponent_all_ones_but_not_nan_is_finite() {
        assert!(decode_e4m3_byte(0b0_1111_000).is_some());
        assert!(decode_e4m3_byte(0b0_1111_101).is_some());
    }

    #[test]
    fn test_decode_e5m2_zero() {
        assert_eq!(decode_e5m2_byte(0x00), Some(0.0));
        let negative_zero = decode_e5m2_byte(0x80).unwrap();
        assert_eq!(negative_zero, 0.0);
        assert!(negative_zero.is_sign_negative());
    }

    #[test]
    fn test_decode_e5m2_one_point_zero() {
        assert_eq!(decode_e5m2_byte(0b0_01111_00), Some(1.0));
        assert_eq!(decode_e5m2_byte(0b1_01111_00), Some(-1.0));
    }

    #[test]
    fn test_decode_e5m2_mantissa() {
        assert_eq!(decode_e5m2_byte(0b0_10000_11), Some(3.5));
    }

    #[test]
    fn test_decode_e5m2_max_finite_is_57344() {
        assert_eq!(decode_e5m2_byte(0b0_11110_11), Some(57344.0));
        assert_eq!(decode_e5m2_byte(0b1_11110_11), Some(-57344.0));
    }

    #[test]
    fn test_decode_e5m2_min_subnormal() {
        assert_eq!(decode_e5m2_byte(0b0_00000_01), Some(2f64.powi(-16)));
        assert_eq!(decode_e5m2_byte(0b0_00000_11), Some(3.0 * 2f64.powi(-16)));
    }

    #[test]
    fn test_decode_e5m2_min_normal() {
        assert_eq!(decode_e5m2_byte(0b0_00001_00), Some(2f64.powi(-14)));
    }

    #[test]
    fn test_decode_e5m2_infinity() {
        assert_eq!(decode_e5m2_byte(0b0_11111_00), Some(f64::INFINITY));
        assert_eq!(decode_e5m2_byte(0b1_11111_00), Some(f64::NEG_INFINITY));
    }

    #[test]
    fn test_decode_e5m2_nan_bytes() {
        for byte in [0x7d, 0x7e, 0x7f, 0xfd, 0xfe, 0xff] {
            assert_eq!(decode_e5m2_byte(byte), None, "byte {byte:#04x}");
        }
    }

    #[test]
    fn test_decode_e5m2_matches_f16_upper_byte() {
        for byte in 0..=u8::MAX {
            let as_f16_bits = u16::from(byte) << 8;
            let sign = if as_f16_bits & 0x8000 != 0 { -1.0 } else { 1.0 };
            let exponent = ((as_f16_bits >> 10) & 0x1F) as i32;
            let mantissa = f64::from(as_f16_bits & 0x3FF);
            let expected = match exponent {
                0 => Some(sign * mantissa * 2f64.powi(-24)),
                0x1F if mantissa == 0.0 => Some(sign * f64::INFINITY),
                0x1F => None,
                _ => Some(sign * (1.0 + mantissa / 1024.0) * 2f64.powi(exponent - 15)),
            };
            assert_eq!(decode_e5m2_byte(byte), expected, "byte {byte:#04x}");
        }
    }
}
