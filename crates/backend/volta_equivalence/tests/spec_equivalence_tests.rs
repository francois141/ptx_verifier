//! Spec-to-spec equivalence tests: both sides are `tests/specs/*.spec` files unfolded into
//! expressions, so the decision procedure is tested on the formulas themselves.
//! Negative pairs differ in one semantic detail; any `Equivalent` there is a false EQUIV.

#[macro_use]
mod common;

use common::*;
use volta_equivalence::EquivOutcome;

// =========================================================================
// Equivalent reformulations
// =========================================================================

const VECTOR_DIMS: &[(&str, u64)] = &[("N", 1), ("K", 4)];

/// A reduction and its unrolled linear chain.
#[test]
fn sum_reduction_equals_its_unrolled_chain() {
    assert_equivalent(&SpecPair {
        name: "sum_reduction_unrolled",
        dims: VECTOR_DIMS,
        reference: spec!("sum_reduction"),
        other: spec!("linear_chain_sum"),
    });
}

/// Reassociation alone is equivalent: pins the negative verdict of
/// `perturbed_reduction_leaf` on the leaf, not on the tree shape.
#[test]
fn linear_chain_equals_balanced_tree() {
    assert_equivalent(&SpecPair {
        name: "balanced_tree_control",
        dims: VECTOR_DIMS,
        reference: spec!("linear_chain_sum"),
        other: spec!("balanced_tree_sum"),
    });
}

const MATMUL_DIMS: &[(&str, u64)] = &[("M", 2), ("N", 2), ("K", 3)];

#[test]
fn matmul_reduction_equals_its_unrolled_dot_products() {
    assert_equivalent(&SpecPair {
        name: "matmul_unrolled",
        dims: MATMUL_DIMS,
        reference: spec!("matmul"),
        other: spec!("matmul_unrolled"),
    });
}

/// Dividing a sum by `N` once equals dividing every term: a dim used as a
/// value, distributed through the reduction.
#[test]
fn mean_division_distributes_over_the_sum() {
    assert_equivalent(&SpecPair {
        name: "mean_distributed",
        dims: &[("M", 2), ("N", 4)],
        reference: spec!("mean"),
        other: spec!("mean_distributed"),
    });
}

/// A max reduction (empty-range identity `-inf`) equals the nested binary max.
#[test]
fn max_reduction_equals_nested_max() {
    assert_equivalent(&SpecPair {
        name: "max_reduction_nested",
        dims: &[("M", 2), ("N", 3)],
        reference: spec!("max_reduction"),
        other: spec!("nested_max"),
    });
}

const EXP_DIMS: &[(&str, u64)] = &[("N", 1), ("K", 2)];

/// e^a * e^b = e^(a+b): catches losing the exp fusion rule.
#[test]
fn product_of_exps_equals_exp_of_sum() {
    assert_equivalent(&SpecPair {
        name: "exp_fusion_control",
        dims: EXP_DIMS,
        reference: spec!("product_of_exps"),
        other: spec!("exp_of_sum"),
    });
}

const SOFTMAX_DIMS: &[(&str, u64)] = &[("N", 3)];

/// The numerically safe softmax (max subtracted everywhere) equals the naive
/// one: the rescaling FlashAttention-style kernels rely on.
#[test]
fn safe_softmax_equals_naive_softmax() {
    assert_equivalent(&SpecPair {
        name: "softmax_rescaling",
        dims: SOFTMAX_DIMS,
        reference: spec!("safe_softmax"),
        other: spec!("naive_softmax"),
    });
}

// =========================================================================
// Negative pairs: one semantic detail changed
// =========================================================================

/// x * 0.5 vs x * (the f32 nearest 0.5000001): distinct exact rationals,
/// 1/2 and (2^23 + 2)/2^24.
fn pair_constant_perturbation() -> SpecPair {
    SpecPair {
        name: "constant_perturbation",
        dims: &[("N", 1)],
        reference: spec!("constant_perturbation_ref"),
        other: spec!("constant_perturbation_mut"),
    }
}

/// A 4-term sum vs the same sum with its last term dropped.
fn pair_dropped_term() -> SpecPair {
    SpecPair {
        name: "dropped_term",
        dims: VECTOR_DIMS,
        reference: spec!("sum_reduction"),
        other: spec!("dropped_term"),
    }
}

/// x - y and x / y vs the operand-swapped y - x and y / x: every element of
/// both arrays must be reported.
fn pair_swapped_noncommutative() -> SpecPair {
    SpecPair {
        name: "swapped_noncommutative",
        dims: &[("N", 2)],
        reference: spec!("swapped_noncommutative_ref"),
        other: spec!("swapped_noncommutative_mut"),
    }
}

/// out[i] = x[i] vs x[i + 1]: identical footprints, so every element fails
/// its check (NotEquivalent, not a shape error).
fn pair_off_by_one_index() -> SpecPair {
    SpecPair {
        name: "off_by_one_index",
        dims: &[("N", 4), ("M", 5)],
        reference: spec!("off_by_one_index_ref"),
        other: spec!("off_by_one_index_mut"),
    }
}

/// max(a*b + c, 0) vs a*b + c: dropping a ReLU clamp must be caught.
fn pair_missing_relu_clamp() -> SpecPair {
    SpecPair {
        name: "missing_relu_clamp",
        dims: &[("N", 1)],
        reference: spec!("missing_relu_clamp_ref"),
        other: spec!("missing_relu_clamp_mut"),
    }
}

/// The u32 sentinel 4294967295 vs 4294967294: large integer constants stay
/// exact instead of collapsing.
fn pair_integer_constant_off_by_one() -> SpecPair {
    SpecPair {
        name: "integer_constant_off_by_one",
        dims: &[("N", 1)],
        reference: spec!("integer_constant_off_by_one_ref"),
        other: spec!("integer_constant_off_by_one_mut"),
    }
}

/// x0*x1 + x2 vs x0*x1 + x3: the multiply-add shape with a different addend.
fn pair_different_addend() -> SpecPair {
    SpecPair {
        name: "different_addend",
        dims: VECTOR_DIMS,
        reference: spec!("different_addend_ref"),
        other: spec!("different_addend_mut"),
    }
}

/// The linear chain vs a balanced tree with its last leaf doubled.
fn pair_perturbed_reduction_leaf() -> SpecPair {
    SpecPair {
        name: "perturbed_reduction_leaf",
        dims: VECTOR_DIMS,
        reference: spec!("linear_chain_sum"),
        other: spec!("balanced_tree_sum_doubled_leaf"),
    }
}

/// max(x0, x1) vs min(x0, x1): the same flattened operand set, told apart by
/// the operation itself.
fn pair_max_vs_min() -> SpecPair {
    SpecPair {
        name: "max_vs_min",
        dims: EXP_DIMS,
        reference: spec!("max_vs_min_ref"),
        other: spec!("max_vs_min_mut"),
    }
}

/// e^a * e^b vs e^(a*b): the shape the fusion rule must not fire on.
fn pair_exp_of_product() -> SpecPair {
    SpecPair {
        name: "exp_of_product",
        dims: EXP_DIMS,
        reference: spec!("product_of_exps"),
        other: spec!("exp_of_product"),
    }
}

/// A @ B vs A @ B^T on square operands: every element of C differs.
fn pair_transposed_operand() -> SpecPair {
    SpecPair {
        name: "transposed_operand",
        dims: &[("M", 2), ("N", 2), ("K", 2)],
        reference: spec!("matmul"),
        other: spec!("matmul_transposed"),
    }
}

/// The safe softmax vs one that subtracts the max in the numerator only:
/// off by a factor e^-max, which the rescaling rule must not absorb.
fn pair_half_rescaled_softmax() -> SpecPair {
    SpecPair {
        name: "half_rescaled_softmax",
        dims: SOFTMAX_DIMS,
        reference: spec!("safe_softmax"),
        other: spec!("half_rescaled_softmax"),
    }
}

#[test]
fn mutation_01_constant_perturbation_not_equivalent() {
    assert_not_equivalent(&pair_constant_perturbation(), &[("out", 0)]);
}

#[test]
fn mutation_02_dropped_term_not_equivalent() {
    assert_not_equivalent(&pair_dropped_term(), &[("out", 0)]);
}

#[test]
fn mutation_03_swapped_noncommutative_operands_not_equivalent() {
    assert_not_equivalent(
        &pair_swapped_noncommutative(),
        &[("d", 0), ("d", 1), ("q", 0), ("q", 1)],
    );
}

#[test]
fn mutation_04_off_by_one_index_same_footprint_not_equivalent() {
    assert_not_equivalent(
        &pair_off_by_one_index(),
        &[("out", 0), ("out", 1), ("out", 2), ("out", 3)],
    );
}

#[test]
fn mutation_05_missing_relu_clamp_not_equivalent() {
    assert_not_equivalent(&pair_missing_relu_clamp(), &[("out", 0)]);
}

#[test]
fn mutation_06_integer_constant_off_by_one_not_equivalent() {
    assert_not_equivalent(&pair_integer_constant_off_by_one(), &[("out", 0)]);
}

#[test]
fn mutation_07_different_addend_not_equivalent() {
    assert_not_equivalent(&pair_different_addend(), &[("out", 0)]);
}

#[test]
fn mutation_08_reassociated_sum_with_perturbed_leaf_not_equivalent() {
    assert_not_equivalent(&pair_perturbed_reduction_leaf(), &[("out", 0)]);
}

#[test]
fn mutation_09_max_vs_min_not_equivalent() {
    assert_not_equivalent(&pair_max_vs_min(), &[("out", 0)]);
}

#[test]
fn mutation_10_exp_of_product_not_equivalent() {
    assert_not_equivalent(&pair_exp_of_product(), &[("out", 0)]);
}

#[test]
fn mutation_11_transposed_operand_not_equivalent() {
    assert_not_equivalent(
        &pair_transposed_operand(),
        &[("C", 0), ("C", 1), ("C", 2), ("C", 3)],
    );
}

#[test]
fn mutation_12_half_rescaled_softmax_not_equivalent() {
    assert_not_equivalent(
        &pair_half_rescaled_softmax(),
        &[("y", 0), ("y", 1), ("y", 2)],
    );
}

// =========================================================================
// Meta test: the whole taxonomy in one batch
// =========================================================================

fn negative_pairs() -> Vec<SpecPair> {
    vec![
        pair_constant_perturbation(),
        pair_dropped_term(),
        pair_swapped_noncommutative(),
        pair_off_by_one_index(),
        pair_missing_relu_clamp(),
        pair_integer_constant_off_by_one(),
        pair_different_addend(),
        pair_perturbed_reduction_leaf(),
        pair_max_vs_min(),
        pair_exp_of_product(),
        pair_transposed_operand(),
        pair_half_rescaled_softmax(),
    ]
}

/// Every negative pair re-checked in one loop, so a soundness regression fails
/// even if the individual tests change.
#[test]
fn meta_no_negative_pair_is_proved_equivalent() {
    let pairs = negative_pairs();
    assert_eq!(pairs.len(), 12, "the taxonomy has twelve negative pairs");
    for pair in &pairs {
        assert!(
            !matches!(check(pair), EquivOutcome::Equivalent),
            "SOUNDNESS BUG: mutation '{}' was proved Equivalent",
            pair.name
        );
    }
}
