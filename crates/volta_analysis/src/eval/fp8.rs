//! `.e4m3` byte decode (PTX ISA 5.2.3): 1 sign bit + 4 exponent bits (bias
//! 7) + 3 mantissa bits, no infinity, NaN only at `0x7f`/`0xff`.
//!
//! This is only needed for a genuinely *concrete* `.e4m3x2` source byte
//! (e.g. a `cp.async` zero-fill word, or a literal `mov.b16` pattern) that
//! never went through array materialization - see
//! `eval::interp::LoweredInstr::CvtE4m3x2ToF16x2`'s doc comment for why the
//! common case (a symbolic fp8 input array element) never reaches this at
//! all: it's already a real-valued expression by the time it's split into
//! a `Value::Pair`, and `.e4m3x2 -> .f16x2` conversion is the identity over
//! the reals there, exactly like every other float<->float `cvt` in this
//! codebase.
//!
//! Every finite `.e4m3` value is an exact dyadic rational (a small integer
//! times a power of two), so decoding through `f64` is exact - no
//! precision is lost, unlike a general float-to-float rounding.

/// Decode one `.e4m3` byte to its exact real value, or `None` if the byte
/// is the format's NaN encoding (`0x7f`/`0xff` - PTX ISA 5.2.3: "NaN
/// values are limited to 0x7f and 0xff").
pub fn decode_e4m3_byte(byte: u8) -> Option<f64> {
    let sign = (byte >> 7) & 1;
    let exponent = (byte >> 3) & 0xF;
    let mantissa = (byte & 0x7) as i32;

    if exponent == 0xF && mantissa == 0x7 {
        return None;
    }

    let magnitude = if exponent == 0 {
        // Subnormal: mantissa * 2^-9.
        mantissa as f64 * 2f64.powi(-9)
    } else {
        // Normal: (1 + mantissa/8) * 2^(exponent-7).
        (1.0 + mantissa as f64 / 8.0) * 2f64.powi(exponent as i32 - 7)
    };

    Some(if sign == 1 { -magnitude } else { magnitude })
}

#[cfg(test)]
// The binary literals below are deliberately grouped 1_4_3 (sign, exponent,
// mantissa) to document the bit layout directly, not clippy's uniform
// grouping.
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
        // sign=0, exponent=0111 (7), mantissa=000: (1+0)*2^(7-7) = 1.0.
        assert_eq!(decode_e4m3_byte(0b0_0111_000), Some(1.0));
    }

    #[test]
    fn test_decode_negative() {
        assert_eq!(decode_e4m3_byte(0b1_0111_000), Some(-1.0));
    }

    #[test]
    fn test_decode_max_finite_is_448() {
        // Known E4M3FN max: exponent=1111 (15), mantissa=110 (6, since 111
        // is reserved for NaN): (1+6/8)*2^(15-7) = 1.75*256 = 448.
        assert_eq!(decode_e4m3_byte(0b0_1111_110), Some(448.0));
        assert_eq!(decode_e4m3_byte(0b1_1111_110), Some(-448.0));
    }

    #[test]
    fn test_decode_min_subnormal() {
        // exponent=0000, mantissa=001: 1 * 2^-9.
        assert_eq!(decode_e4m3_byte(0b0_0000_001), Some(2f64.powi(-9)));
    }

    #[test]
    fn test_decode_min_normal() {
        // exponent=0001 (1), mantissa=000: (1+0)*2^(1-7) = 2^-6.
        assert_eq!(decode_e4m3_byte(0b0_0001_000), Some(2f64.powi(-6)));
    }

    #[test]
    fn test_decode_nan_bytes() {
        assert_eq!(decode_e4m3_byte(0x7f), None);
        assert_eq!(decode_e4m3_byte(0xff), None);
    }

    #[test]
    fn test_decode_exponent_all_ones_but_not_nan_is_finite() {
        // Unlike IEEE754, exponent=1111 with a non-NaN mantissa is an
        // ordinary finite value (no infinity in this format).
        assert!(decode_e4m3_byte(0b0_1111_000).is_some());
        assert!(decode_e4m3_byte(0b0_1111_101).is_some());
    }
}
