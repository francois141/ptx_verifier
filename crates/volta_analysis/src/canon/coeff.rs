//! Exact rational coefficients.
//!
//! Expression constants arrive as exact [`Real`] rationals (the evaluator
//! folds in the same exact algebra), so coefficient arithmetic is exact:
//! cancellation in the decision procedure never depends on floating-point
//! rounding. A coefficient is kept as `num * 2^exp2 / den` with the
//! numerator and the denominator both odd, so an IEEE constant costs only
//! its mantissa in i128 and its binary exponent - however extreme - costs
//! nothing. That split is what a subnormal float needs: `1e-40f32` is
//! `35681 / 2^148`, whose reduced denominator alone is 21 bits past i128.
//! Overflow is a reported error, not a panic.

use std::fmt;

use crate::symbolic::{Real, RealRepr};

/// A reduced dyadic-scaled rational: `num * 2^exp2 / den`, with `den > 0`,
/// `num` and `den` both odd, and gcd(num, den) = 1. Zero is `0 * 2^0 / 1`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Coeff {
    num: i128,
    den: i128,
    exp2: i32,
}

/// Coefficient arithmetic failure (overflow, division by zero, or a
/// non-finite constant).
#[derive(Debug, Clone, PartialEq)]
pub enum CoeffError {
    Overflow,
    DivByZero,
    NonFinite(f64),
}

impl fmt::Display for CoeffError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Overflow => write!(f, "rational coefficient overflowed i128"),
            Self::DivByZero => write!(f, "division by a zero coefficient"),
            Self::NonFinite(v) => write!(f, "non-finite constant {} in expression", v),
        }
    }
}

fn gcd(mut a: i128, mut b: i128) -> i128 {
    a = a.abs();
    b = b.abs();
    while b != 0 {
        (a, b) = (b, a % b);
    }
    a
}

/// `v * 2^shift`, or `None` when it leaves i128.
fn shift_up(v: i128, shift: u32) -> Option<i128> {
    if shift == 0 {
        return Some(v);
    }
    if shift > 126 {
        return None;
    }
    (1i128 << shift).checked_mul(v)
}

impl Coeff {
    pub const ZERO: Coeff = Coeff {
        num: 0,
        den: 1,
        exp2: 0,
    };
    pub const ONE: Coeff = Coeff {
        num: 1,
        den: 1,
        exp2: 0,
    };
    pub const MINUS_ONE: Coeff = Coeff {
        num: -1,
        den: 1,
        exp2: 0,
    };

    /// `num * 2^exp2 / den` in canonical form. Every field is free-form:
    /// the powers of two in `num` and `den` migrate into the exponent, so
    /// equal values always have equal fields (the derived `Eq`/`Hash` the
    /// intern tables key on).
    fn reduced(num: i128, den: i128, exp2: i32) -> Result<Coeff, CoeffError> {
        debug_assert!(den != 0);
        if num == 0 {
            return Ok(Coeff::ZERO);
        }
        // The magnitude of i128::MIN has no i128 image, so the `abs` and
        // the sign flip below would wrap; report it as the overflow it is.
        if num == i128::MIN || den == i128::MIN {
            return Err(CoeffError::Overflow);
        }
        let g = gcd(num, den);
        let sign = if den < 0 { -1 } else { 1 };
        let num = sign * (num / g);
        let den = (den / g).abs();
        let (num_twos, den_twos) = (num.trailing_zeros(), den.trailing_zeros());
        let exp2 = exp2
            .checked_add_unsigned(num_twos)
            .and_then(|e| e.checked_sub_unsigned(den_twos))
            .ok_or(CoeffError::Overflow)?;
        Ok(Coeff {
            num: num >> num_twos,
            den: den >> den_twos,
            exp2,
        })
    }

    pub fn from_int(v: i64) -> Coeff {
        // An integer's odd part and its power of two both fit by
        // construction, so canonicalization cannot overflow here.
        Coeff::reduced(v as i128, 1, 0).expect("integer coefficient fits i128")
    }

    /// Exact conversion from a [`Real`] constant: only the odd parts of
    /// the rational's numerator/denominator need fit i128 (it is already
    /// reduced with a positive denominator - rug's canonical form); an
    /// infinity is the same loud non-finite error a non-finite f64 was.
    pub fn from_real(v: &Real) -> Result<Coeff, CoeffError> {
        match v.repr() {
            RealRepr::Rational(q) => {
                let (numer, denom) = (q.numer(), q.denom());
                debug_assert!(*denom > 0);
                if *numer == 0 {
                    return Ok(Coeff::ZERO);
                }
                let num_twos = numer.find_one(0).ok_or(CoeffError::Overflow)?;
                let den_twos = denom.find_one(0).ok_or(CoeffError::Overflow)?;
                let num = rug::Integer::from(numer >> num_twos)
                    .to_i128()
                    .ok_or(CoeffError::Overflow)?;
                let den = rug::Integer::from(denom >> den_twos)
                    .to_i128()
                    .ok_or(CoeffError::Overflow)?;
                let exp2 = i32::try_from(num_twos)
                    .ok()
                    .and_then(|n| i32::try_from(den_twos).ok().and_then(|d| n.checked_sub(d)))
                    .ok_or(CoeffError::Overflow)?;
                Ok(Coeff { num, den, exp2 })
            }
            RealRepr::NegInf | RealRepr::PosInf => Err(CoeffError::NonFinite(v.to_f64())),
        }
    }

    pub fn is_zero(&self) -> bool {
        self.num == 0
    }

    pub fn is_one(&self) -> bool {
        self.num == 1 && self.den == 1 && self.exp2 == 0
    }

    /// The exact integer value, for a rational that denotes one.
    pub fn as_integer(&self) -> Option<i128> {
        if self.num == 0 {
            return Some(0);
        }
        // `num` is odd, so a negative exponent never leaves an integer.
        if self.den != 1 || self.exp2 < 0 {
            return None;
        }
        shift_up(self.num, self.exp2 as u32)
    }

    pub fn add(&self, other: &Coeff) -> Result<Coeff, CoeffError> {
        if self.is_zero() {
            return Ok(*other);
        }
        if other.is_zero() {
            return Ok(*self);
        }
        // Align on the smaller exponent, then a/b + c/d = (ad + cb) / bd
        // with a gcd pre-reduction on b, d.
        let exp2 = self.exp2.min(other.exp2);
        // The gaps widen to i64 first: two far-apart exponents overflow an
        // i32 subtraction well before `shift_up` gets to reject the shift.
        let gap = |e: i32| (e as i64 - exp2 as i64) as u32;
        let a = shift_up(self.num, gap(self.exp2)).ok_or(CoeffError::Overflow)?;
        let c = shift_up(other.num, gap(other.exp2)).ok_or(CoeffError::Overflow)?;
        let g = gcd(self.den, other.den);
        let (b, d) = (self.den / g, other.den / g);
        let num = a
            .checked_mul(d)
            .and_then(|x| c.checked_mul(b).and_then(|y| x.checked_add(y)))
            .ok_or(CoeffError::Overflow)?;
        let den = self.den.checked_mul(d).ok_or(CoeffError::Overflow)?;
        Coeff::reduced(num, den, exp2)
    }

    pub fn mul(&self, other: &Coeff) -> Result<Coeff, CoeffError> {
        if self.is_zero() || other.is_zero() {
            return Ok(Coeff::ZERO);
        }
        // Cross-reducing makes the product reduced by construction, and
        // odd parts stay odd under multiplication, so the result is
        // already canonical: only the exponents have to be combined. That
        // keeps the hottest coefficient path free of a second gcd.
        let g1 = gcd(self.num, other.den);
        let g2 = gcd(other.num, self.den);
        let num = (self.num / g1)
            .checked_mul(other.num / g2)
            .ok_or(CoeffError::Overflow)?;
        let den = (self.den / g2)
            .checked_mul(other.den / g1)
            .ok_or(CoeffError::Overflow)?;
        let exp2 = self
            .exp2
            .checked_add(other.exp2)
            .ok_or(CoeffError::Overflow)?;
        Ok(Coeff { num, den, exp2 })
    }

    pub fn neg(&self) -> Coeff {
        Coeff {
            num: -self.num,
            den: self.den,
            exp2: self.exp2,
        }
    }

    /// Multiplicative inverse; error on zero.
    pub fn recip(&self) -> Result<Coeff, CoeffError> {
        if self.is_zero() {
            return Err(CoeffError::DivByZero);
        }
        let exp2 = self.exp2.checked_neg().ok_or(CoeffError::Overflow)?;
        Coeff::reduced(self.den, self.num, exp2)
    }

    /// Approximate value (for diagnostics only; never used in decisions).
    pub fn to_f64(&self) -> f64 {
        // Scale in two halves: a single `2^exp2` flushes to zero or to
        // infinity for exponents whose full product is still finite.
        let half = self.exp2 / 2;
        (self.num as f64 / self.den as f64)
            * f64::from(half).exp2()
            * f64::from(self.exp2 - half).exp2()
    }
}

impl fmt::Display for Coeff {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // Fold the scale back into whichever side it belongs to, so the
        // common small constants print as plain rationals.
        let folded = if self.exp2 >= 0 {
            shift_up(self.num, self.exp2 as u32).map(|num| (num, self.den))
        } else {
            shift_up(self.den, self.exp2.unsigned_abs()).map(|den| (self.num, den))
        };
        match folded {
            Some((num, 1)) => write!(f, "{}", num),
            Some((num, den)) => write!(f, "{}/{}", num, den),
            None if self.den == 1 => write!(f, "{}*2^{}", self.num, self.exp2),
            None => write!(f, "{}*2^{}/{}", self.num, self.exp2, self.den),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn coeff_of(v: f64) -> Result<Coeff, CoeffError> {
        Coeff::from_real(&Real::from_f64(v).unwrap())
    }

    fn reduced(num: i128, den: i128) -> Coeff {
        Coeff::reduced(num, den, 0).unwrap()
    }

    #[test]
    fn test_f64_exact() {
        assert_eq!(coeff_of(0.125).unwrap(), reduced(1, 8));
        assert_eq!(coeff_of(-1.0).unwrap(), Coeff::MINUS_ONE);
        assert_eq!(coeff_of(0.0).unwrap(), Coeff::ZERO);
        // 1e-5 is NOT 1/100000 in binary; conversion must be bit-exact.
        let c = coeff_of(1e-5).unwrap();
        assert_eq!(c.to_f64(), 1e-5);
        assert_ne!(c, reduced(1, 100000));
    }

    /// The same value reached two ways interns as one coefficient: the
    /// powers of two always sit in the exponent, never in `num`/`den`.
    #[test]
    fn test_canonical_scale() {
        assert_eq!(Coeff::from_int(4), reduced(8, 2));
        assert_eq!(
            Coeff::from_int(2).mul(&Coeff::from_int(2)).unwrap(),
            Coeff::from_int(4)
        );
        assert_eq!(reduced(6, 4), reduced(3, 2));
        assert_eq!(Coeff::from_int(4).as_integer(), Some(4));
        assert_eq!(reduced(1, 2).as_integer(), None);
    }

    #[test]
    fn test_non_finite() {
        // NaN cannot even construct a `Real`; the infinities reach
        // `from_real` and fail there, as non-finite f64s used to.
        assert!(coeff_of(f64::INFINITY).is_err());
        assert!(coeff_of(f64::NEG_INFINITY).is_err());
    }

    /// A subnormal float32 - FlashSinkhorn's `1e-40` log floor - is
    /// `35681 / 2^148`, so only the exponent split keeps it in i128.
    #[test]
    fn test_subnormal_float32_constant() {
        let bits = f32::from_bits(0x0001_16C2);
        let c = coeff_of(bits as f64).unwrap();
        assert_eq!(c.to_f64(), bits as f64);
        assert_eq!(
            c.mul(&Coeff::from_int(2)).unwrap().to_f64(),
            2.0 * bits as f64
        );
    }

    /// A wide *odd* rational still does not fit: the fold algebra is
    /// arbitrary-precision, canon's hot path deliberately stays i128.
    #[test]
    fn test_overflow_from_wide_rational() {
        let huge = rug::Rational::from((rug::Integer::from(1) << 200u32) + 1u32);
        let r = Real::from_rational(huge);
        assert_eq!(Coeff::from_real(&r), Err(CoeffError::Overflow));
    }

    #[test]
    fn test_arithmetic() {
        let half = coeff_of(0.5).unwrap();
        let quarter = coeff_of(0.25).unwrap();
        assert_eq!(half.mul(&half).unwrap(), quarter);
        assert_eq!(quarter.add(&quarter).unwrap(), half);
        assert_eq!(half.add(&half.neg()).unwrap(), Coeff::ZERO);
        assert_eq!(half.recip().unwrap(), Coeff::from_int(2));
    }

    #[test]
    fn test_exact_cancellation() {
        // (1/3 + 1/6) - 1/2 == 0 exactly; floats would drift.
        let third = reduced(1, 3);
        let sixth = reduced(1, 6);
        let half = reduced(1, 2);
        let sum = third.add(&sixth).unwrap();
        assert_eq!(sum, half);
        assert!(sum.add(&half.neg()).unwrap().is_zero());
    }

    #[test]
    fn test_display_folds_the_scale() {
        assert_eq!(reduced(1, 8).to_string(), "1/8");
        assert_eq!(Coeff::from_int(4).to_string(), "4");
        assert_eq!(Coeff::MINUS_ONE.to_string(), "-1");
    }
}
