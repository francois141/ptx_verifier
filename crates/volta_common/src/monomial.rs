//! A single-variable monomial, `coefficient * x^degree`, over any coefficient type.

use std::ops::Mul;

/// `coefficient * x^degree`.
pub struct Monomial<C> {
    pub coefficient: C,
    pub degree: u32,
}

impl<C: Mul<Output = C>> Mul for Monomial<C> {
    type Output = Monomial<C>;

    fn mul(self, other: Monomial<C>) -> Monomial<C> {
        Monomial {
            coefficient: self.coefficient * other.coefficient,
            degree: self.degree + other.degree,
        }
    }
}
