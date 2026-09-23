//! Exact decoding of `.e4m3` and `.e5m2` bytes (PTX ISA 5.2.3), used only for
//! concrete fp8 source bytes; symbolic fp8 elements never reach this (see
//! `eval::interp::LoweredInstr::CvtE4m3x2ToF16x2`). Every finite value is a
//! dyadic rational, so decoding through `f64` is exact.

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

#[cfg(test)]
// Binary literals are grouped by (sign, exponent, mantissa) fields.
#[allow(clippy::unusual_byte_groupings)]
mod tests {
    use super::*;

    #[test]
    fn test_decode_zero() {
        assert_eq!(decode_e4m3_byte(0x00), Some(0.0));
        assert_eq!(decode_e4m3_byte(0x80), Some(-0.0));
    }

    #[test]
    fn test_decode_one_point_zero() {
        assert_eq!(decode_e4m3_byte(0b0_0111_000), Some(1.0));
    }

    #[test]
    fn test_decode_negative() {
        assert_eq!(decode_e4m3_byte(0b1_0111_000), Some(-1.0));
    }

    #[test]
    fn test_decode_max_finite_is_448() {
        assert_eq!(decode_e4m3_byte(0b0_1111_110), Some(448.0));
        assert_eq!(decode_e4m3_byte(0b1_1111_110), Some(-448.0));
    }

    #[test]
    fn test_decode_min_subnormal() {
        assert_eq!(decode_e4m3_byte(0b0_0000_001), Some(2f64.powi(-9)));
    }

    #[test]
    fn test_decode_min_normal() {
        assert_eq!(decode_e4m3_byte(0b0_0001_000), Some(2f64.powi(-6)));
    }

    #[test]
    fn test_decode_nan_bytes() {
        assert_eq!(decode_e4m3_byte(0x7f), None);
        assert_eq!(decode_e4m3_byte(0xff), None);
    }

    #[test]
    fn test_decode_exponent_all_ones_but_not_nan_is_finite() {
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
