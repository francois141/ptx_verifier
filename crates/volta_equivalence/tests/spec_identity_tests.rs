//! Algebraic identities the decision procedure must prove: each case is a pair
//! `tests/specs/equivalent/<case>_{lhs,rhs}.spec` of equal formulas, so a
//! failure here is a lost proof (incompleteness), never a soundness bug.

#[macro_use]
mod common;

use common::*;

/// One `#[test]` per case, checking `<case>_lhs.spec` against `<case>_rhs.spec`
/// under the given dim values.
macro_rules! proved_equivalent {
    ($($(#[$attr:meta])* $case:ident: $dims:expr;)*) => {$(
        $(#[$attr])*
        #[test]
        fn $case() {
            assert_equivalent(&SpecPair {
                name: stringify!($case),
                dims: $dims,
                reference: spec!(concat!("equivalent/", stringify!($case), "_lhs")),
                other: spec!(concat!("equivalent/", stringify!($case), "_rhs")),
            });
        }
    )*};
}

proved_equivalent! {
    // Polynomial algebra
    /// a + b = b + a.
    addition_commutes: &[("N", 2)];
    /// ab = ba.
    multiplication_commutes: &[("N", 2)];
    /// (ab)c = a(bc).
    multiplication_associates: &[("N", 2)];
    /// a(b + c) = ab + ca.
    multiplication_distributes: &[("N", 2)];
    /// (a + b)^2 = a^2 + 2ab + b^2.
    binomial_square: &[("N", 2)];
    /// (a - b)^3 expanded.
    binomial_cube: &[("N", 2)];
    /// (a - b)(a + b) = a^2 - b^2.
    difference_of_squares: &[("N", 2)];
    /// -(a - b) = b - a.
    negated_difference: &[("N", 2)];
    /// a + b - b = a.
    added_then_subtracted_cancels: &[("N", 2)];
    /// a - a = 0.
    self_difference_is_zero: &[("N", 2)];
    /// 2a + 3a = 5a.
    like_terms_combine: &[("N", 2)];
    /// ad^2 + bd + c in Horner form.
    horner_form: &[("N", 2)];
    /// a(0.5 + 0.25) = 0.75a.
    constants_fold_exactly: &[("N", 2)];

    // Rational functions
    /// a/b + c/b = (a + c)/b.
    fractions_over_a_common_denominator: &[("N", 2)];
    /// a/b + c/d = (ad + bc)/(bd).
    fractions_cross_multiplied: &[("N", 2)];
    /// (ab)/b = a (canon's field model).
    common_factor_cancels: &[("N", 2)];
    /// 1/(1/a) = a.
    double_reciprocal: &[("N", 2)];
    /// (a/b)/(c/d) = (ad)/(bc).
    nested_fraction: &[("N", 2)];
    /// s/4 = s * 0.25.
    division_by_constant_is_multiplication: &[("N", 4), ("O", 1)];

    // Reductions
    /// sum a_k b_k = sum b_k a_k.
    dot_product_commutes: &[("N", 4), ("O", 1)];
    /// sum (a_k + b_k) = sum a_k + sum b_k.
    sum_of_sums_splits: &[("N", 4), ("O", 1)];
    /// sum 2x_k = 2 sum x_k.
    constant_factors_out_of_a_sum: &[("N", 4), ("O", 1)];
    /// sum_i sum_j A_ij = sum_j sum_i A_ij.
    nested_sums_swap_order: &[("M", 2), ("N", 3), ("O", 1)];
    /// sum x_k = sum x_(N-1-k).
    sum_in_reverse_order: &[("N", 4), ("O", 1)];
    /// sum (x_k - mean) = 0.
    centered_values_sum_to_zero: &[("N", 4), ("O", 1)];
    /// mean((x - mean)^2) = mean(x^2) - mean^2.
    variance_two_ways: &[("N", 3), ("O", 1)];

    // Linear algebra
    /// (AB)C = A(BC).
    matmul_associates: &[("N", 2)];
    /// 2(AB) + 3C with the 2 moved into the sum.
    gemm_epilogue_scales_inside_the_sum: &[("N", 2)];
    /// x_i y_j = y_j x_i.
    outer_product_commutes: &[("N", 2)];
    /// A 3-tap convolution as a reduction vs unrolled out of order.
    conv1d_unrolled: &[("N", 3), ("K", 3), ("M", 5)];

    // Max and min
    /// max(a, max(b, c)) = max(max(c, a), b).
    max_commutes_and_associates: &[("N", 2)];
    /// min(a, min(b, c)) = min(min(c, a), b).
    min_commutes_and_associates: &[("N", 2)];
    /// max(a, 0) = max(0, a).
    relu_operand_order: &[("N", 2)];
    /// max(a, a) = a.
    max_is_idempotent: &[("N", 2)];
    /// max(a + b, c) = max(c, b + a).
    max_operands_are_canonicalized: &[("N", 2)];

    // Exponentials
    /// e^a e^b e^c = e^(a + b + c).
    product_of_three_exps: &[("N", 2)];
    /// e^a / e^b = e^(a - b).
    quotient_of_exps: &[("N", 2)];
    /// e^(2a) = e^a e^a.
    exp_of_a_double: &[("N", 2)];
    /// e^(a - a) b = b.
    exp_of_zero_is_one: &[("N", 2)];
    /// e^(a(b + c)) = e^(ab) e^(ca).
    exp_of_a_polynomial: &[("N", 2)];
    /// 1/(1 + e^-a) = e^a/(e^a + 1).
    sigmoid_two_forms: &[("N", 2)];
    /// tanh(a) = (1 - e^-2a)/(1 + e^-2a).
    tanh_with_negative_exponents: &[("N", 2)];
    /// tanh(a) = 2 sigmoid(2a) - 1.
    tanh_from_sigmoid: &[("N", 2)];

    // Softmax and attention
    /// Shifting every logit by the same c leaves softmax unchanged.
    softmax_is_shift_invariant: &[("N", 3), ("C", 1)];
    /// softmax(x/2), naive vs max-subtracted.
    softmax_with_temperature: &[("N", 3)];
    /// FlashAttention's online softmax: two blocks of two, the first rescaled by e^(m1 - m).
    online_softmax_two_blocks: &[("N", 4)];
    /// softmax(QK^T)V: safe softmax with one division vs naive weights each divided.
    attention_normalized_once_or_per_score: &[("N", 2), ("D", 2)];

    // Opaque operations
    /// sqrt(ab) = sqrt(ba).
    sqrt_operands_are_canonicalized: &[("N", 2)];
    /// log(a + b) c = c log(b + a).
    log_operands_are_canonicalized: &[("N", 2)];
    /// |a - b| + c = c + |-b + a|.
    abs_operands_are_canonicalized: &[("N", 2)];
    /// sign(2a) b = b sign(2a), operands reordered.
    sign_operands_are_canonicalized: &[("N", 2)];
    /// sqrt(a)(b + c) = c sqrt(a) + sqrt(a) b.
    polynomial_algebra_around_an_opaque_atom: &[("N", 2)];
}
