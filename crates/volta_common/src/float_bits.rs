//! Concrete floating-point format decoding shared by accelerator frontends.

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

#[cfg(test)]
mod tests {
    use super::*;

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
}
