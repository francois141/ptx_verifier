//! End-to-end NEGATIVE equivalence tests: each pair of PTX kernels differs in
//! one semantic detail and must come back `NotEquivalent` through the full
//! pipeline, so any `Equivalent` verdict here is a soundness bug (false EQUIV).

use volta_analysis::driver::{EquivOutcome, analyze_kernel, check_output_equivalence};
use volta_analysis::eval::{AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, ParamValue};
use volta_frontend::ascii::AsAscii;
use volta_frontend::ast::Module;
use volta_frontend::parse::Parser;

// =========================================================================
// Harness
// =========================================================================

/// The PTX test kernel at `tests/ptx/<name>.ptx`.
macro_rules! ptx {
    ($name:literal) => {
        include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/tests/ptx/",
            $name,
            ".ptx"
        ))
        .to_string()
    };
}

fn parse(src: &str) -> Module {
    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error))
}

/// Symbolic f32 `in` array plus f32 `out` array.
fn f32_config(threads: u32, in_len: u64, out_len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len: in_len,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: out_len,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

/// Symbolic f16 `in` array plus f16 `out` array (2-byte elements).
fn f16_config(in_len: u64, out_len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: in_len,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: out_len,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

/// Output-only u32 array (for the constant-sentinel kernels).
fn u32_out_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// One runnable kernel: PTX source plus the launch config it runs under.
struct Kernel {
    src: String,
    config: AnalysisConfig,
}

/// One almost-equivalent pair: `reference` and `mutant` differ in exactly
/// one semantic detail, and the decision procedure must not prove them
/// equivalent.
struct NegativePair {
    name: &'static str,
    reference: Kernel,
    mutant: Kernel,
}

fn run(name: &str, kernel: &Kernel) -> AnalysisOutput {
    analyze_kernel(&parse(&kernel.src), None, kernel.config.clone())
        .unwrap_or_else(|e| panic!("{}: analysis failed: {}", name, e))
}

/// Run both kernels of a pair and check them along the reference run's
/// output arrays. Errors from the checker are a hard panic: a pair that
/// errors is not testing the decision procedure.
fn check_pair(pair: &NegativePair) -> EquivOutcome {
    let reference = run(pair.name, &pair.reference);
    let mutant = run(pair.name, &pair.mutant);
    let arrays: Vec<String> = reference.outputs.iter().map(|(n, _)| n.clone()).collect();
    check_output_equivalence(&reference, &mutant, &arrays)
        .unwrap_or_else(|e| panic!("{}: equivalence check errored: {}", pair.name, e))
}

/// Assert the pair is `NotEquivalent` and that the report names exactly
/// the expected mismatched elements.
fn assert_not_equivalent(pair: &NegativePair, expected_mismatches: &[(&str, u64)]) {
    let EquivOutcome::NotEquivalent { mismatches } = check_pair(pair) else {
        panic!(
            "SOUNDNESS BUG: mutation '{}' was proved Equivalent",
            pair.name
        );
    };
    let got: Vec<(&str, u64)> = mismatches
        .iter()
        .map(|m| (m.array.as_str(), m.index))
        .collect();
    assert_eq!(
        got, expected_mismatches,
        "mutation '{}': wrong mismatched elements reported",
        pair.name
    );
}

/// Assert a control pair IS equivalent (used where a nearby positive
/// direction pins down what the negative test distinguishes).
fn assert_equivalent_control(name: &str, reference: &Kernel, other: &Kernel) {
    let a = run(name, reference);
    let b = run(name, other);
    let arrays: Vec<String> = a.outputs.iter().map(|(n, _)| n.clone()).collect();
    let outcome = check_output_equivalence(&a, &b, &arrays)
        .unwrap_or_else(|e| panic!("{}: equivalence check errored: {}", name, e));
    assert!(
        matches!(outcome, EquivOutcome::Equivalent),
        "positive control '{}' must be Equivalent",
        name
    );
}

fn display_output(output: &AnalysisOutput, array: &str, index: u64) -> String {
    let (_, elems) = output
        .outputs
        .iter()
        .find(|(n, _)| n == array)
        .expect("output array");
    let (_, e) = elems
        .iter()
        .find(|(i, _)| *i == index)
        .expect("element written");
    output.arena.display_expr(*e)
}

// =========================================================================
// Mutation 1: constant perturbation
// =========================================================================

/// out[0] = in[0] * 0.5 vs out[0] = in[0] * 0.50000012 (0f3F000002, the
/// f32 nearest 0.5000001). Under the exact-rational constant model these
/// are the distinct rationals 1/2 and (2^23 + 2)/2^24.
fn pair_constant_perturbation() -> NegativePair {
    NegativePair {
        name: "constant_perturbation",
        reference: Kernel {
            src: ptx!("negative_equivalence/constant_perturbation_ref"),
            config: f32_config(1, 1, 1),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/constant_perturbation_mut"),
            config: f32_config(1, 1, 1),
        },
    }
}

#[test]
fn mutation_01_constant_perturbation_not_equivalent() {
    assert_not_equivalent(&pair_constant_perturbation(), &[("out", 0)]);
}

// =========================================================================
// Mutation 2: dropped term
// =========================================================================

/// out[0] = in[0]+in[1]+in[2]+in[3] vs the same chain with the final add
/// dropped (sum of 3). The loads are identical on both sides; only the
/// last accumulation step is missing.
fn pair_dropped_term() -> NegativePair {
    NegativePair {
        name: "dropped_term",
        reference: Kernel {
            src: ptx!("negative_equivalence/dropped_term_ref"),
            config: f32_config(1, 4, 1),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/dropped_term_mut"),
            config: f32_config(1, 4, 1),
        },
    }
}

#[test]
fn mutation_02_dropped_term_not_equivalent() {
    assert_not_equivalent(&pair_dropped_term(), &[("out", 0)]);
}

// =========================================================================
// Mutation 3: swapped non-commutative operands
// =========================================================================

/// out[0] = in[0] - in[1] and out[1] = in[0] / in[1] vs the operand-swapped
/// b-a and b/a. Both elements must be reported as mismatches.
fn pair_swapped_noncommutative() -> NegativePair {
    NegativePair {
        name: "swapped_noncommutative",
        reference: Kernel {
            src: ptx!("negative_equivalence/swapped_noncommutative_ref"),
            config: f32_config(1, 2, 2),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/swapped_noncommutative_mut"),
            config: f32_config(1, 2, 2),
        },
    }
}

#[test]
fn mutation_03_swapped_noncommutative_operands_not_equivalent() {
    assert_not_equivalent(&pair_swapped_noncommutative(), &[("out", 0), ("out", 1)]);
}

// =========================================================================
// Mutation 4: off-by-one index (same output footprint)
// =========================================================================

/// out[tid] = in[tid] vs out[tid] = in[tid + 1] with 4 threads: identical
/// footprints out[0..4), so every per-element check fails (NotEquivalent, not
/// a shape error). The input is sized so in[tid + 1] stays in bounds.
fn pair_off_by_one_index() -> NegativePair {
    NegativePair {
        name: "off_by_one_index",
        reference: Kernel {
            src: ptx!("negative_equivalence/off_by_one_index_ref"),
            config: f32_config(4, 8, 4),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/off_by_one_index_mut"),
            config: f32_config(4, 8, 4),
        },
    }
}

#[test]
fn mutation_04_off_by_one_index_same_footprint_not_equivalent() {
    assert_not_equivalent(
        &pair_off_by_one_index(),
        &[("out", 0), ("out", 1), ("out", 2), ("out", 3)],
    );
}

// =========================================================================
// Mutation 5: missing clamp
// =========================================================================

/// fma.rn.relu.f16 (result clamped to max(x, 0)) vs plain fma.rn.f16 on
/// the same symbolic operands: max(a*b + c, 0) is not a*b + c for
/// arbitrary inputs, so dropping the clamp must be caught.
fn pair_missing_relu_clamp() -> NegativePair {
    NegativePair {
        name: "missing_relu_clamp",
        reference: Kernel {
            src: ptx!("negative_equivalence/missing_relu_clamp_ref"),
            config: f16_config(3, 1),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/missing_relu_clamp_mut"),
            config: f16_config(3, 1),
        },
    }
}

#[test]
fn mutation_05_missing_relu_clamp_not_equivalent() {
    assert_not_equivalent(&pair_missing_relu_clamp(), &[("out", 0)]);
}

// =========================================================================
// Mutation 6: boundary sentinel off by one
// =========================================================================

/// mov.u32 -1 (the 4294967295 sentinel) vs a kernel storing 4294967294: the
/// positive twin (mov -1 == not.b32 0) proves the canonicalization direction;
/// this proves the boundary is exact, not a collapse.
fn pair_sentinel_off_by_one() -> NegativePair {
    NegativePair {
        name: "sentinel_off_by_one",
        reference: Kernel {
            src: ptx!("negative_equivalence/sentinel_off_by_one_ref"),
            config: u32_out_config(),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/sentinel_off_by_one_mut"),
            config: u32_out_config(),
        },
    }
}

#[test]
fn mutation_06_sentinel_off_by_one_not_equivalent() {
    let pair = pair_sentinel_off_by_one();
    // Both sides export their canonical u32 constants...
    let a = run(pair.name, &pair.reference);
    let b = run(pair.name, &pair.mutant);
    assert_eq!(display_output(&a, "out", 0), "4294967295");
    assert_eq!(display_output(&b, "out", 0), "4294967294");
    // ...and the off-by-one is caught.
    assert_not_equivalent(&pair, &[("out", 0)]);
}

// =========================================================================
// Mutation 7: fma vs mul+add with a different addend
// =========================================================================

/// fma(in[0], in[1], in[2]) vs mul+add computing in[0]*in[1] + in[3]: the
/// shape of the true fma == mul+add identity, but with a different addend.
fn pair_fma_different_addend() -> NegativePair {
    NegativePair {
        name: "fma_different_addend",
        reference: Kernel {
            src: ptx!("negative_equivalence/fma_different_addend_ref"),
            config: f32_config(1, 4, 1),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/fma_different_addend_mut"),
            config: f32_config(1, 4, 1),
        },
    }
}

#[test]
fn mutation_07_fma_vs_mul_add_different_addend_not_equivalent() {
    assert_not_equivalent(&pair_fma_different_addend(), &[("out", 0)]);
}

// =========================================================================
// Mutation 8: reassociated reduction with a perturbed leaf
// =========================================================================

/// The linear-chain sum ((in[0]+in[1])+in[2])+in[3].
fn linear_chain_sum() -> Kernel {
    Kernel {
        src: ptx!("negative_equivalence/linear_chain_sum"),
        config: f32_config(1, 4, 1),
    }
}

/// The balanced tree (in[0]+in[1]) + (in[2]+LEAF), with the last leaf
/// either honest (in[3]) or doubled (in[3]+in[3]).
fn balanced_tree_sum(doubled_leaf: bool) -> Kernel {
    let src = if doubled_leaf {
        ptx!("negative_equivalence/balanced_tree_sum_doubled_leaf")
    } else {
        ptx!("negative_equivalence/balanced_tree_sum")
    };
    Kernel {
        src,
        config: f32_config(1, 4, 1),
    }
}

/// Linear chain vs balanced tree with one leaf doubled (2 * in[3]).
fn pair_perturbed_reduction_leaf() -> NegativePair {
    NegativePair {
        name: "perturbed_reduction_leaf",
        reference: linear_chain_sum(),
        mutant: balanced_tree_sum(true),
    }
}

#[test]
fn mutation_08_reassociated_sum_with_perturbed_leaf_not_equivalent() {
    // Control: reassociation alone (linear chain vs honest balanced tree)
    // IS equivalent, so the negative verdict below is pinned on the leaf,
    // not on the tree shape.
    assert_equivalent_control(
        "balanced_tree_control",
        &linear_chain_sum(),
        &balanced_tree_sum(false),
    );
    assert_not_equivalent(&pair_perturbed_reduction_leaf(), &[("out", 0)]);
}

// =========================================================================
// Mutation 9: max vs min
// =========================================================================

/// max(in[0], in[1]) vs min(in[0], in[1]): both flatten into sorted atom
/// sets over the same operands, and must still be distinguished by the
/// operation itself.
fn pair_max_vs_min() -> NegativePair {
    NegativePair {
        name: "max_vs_min",
        reference: Kernel {
            src: ptx!("negative_equivalence/max_vs_min_ref"),
            config: f32_config(1, 2, 1),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/max_vs_min_mut"),
            config: f32_config(1, 2, 1),
        },
    }
}

#[test]
fn mutation_09_max_vs_min_not_equivalent() {
    assert_not_equivalent(&pair_max_vs_min(), &[("out", 0)]);
}

// =========================================================================
// Mutation 10: the exp fragment, both directions
// =========================================================================

/// out[0] = exp(in[0]) * exp(in[1]) via two __symexpf callseqs.
fn exp_product_of_exps() -> Kernel {
    Kernel {
        src: ptx!("negative_equivalence/exp_product_of_exps"),
        config: f32_config(1, 2, 1),
    }
}

/// out[0] = exp(in[0] OP in[1]), for a kernel `src` of that shape.
fn exp_of_combined(src: String) -> Kernel {
    Kernel {
        src,
        config: f32_config(1, 2, 1),
    }
}

/// exp(a) * exp(b) vs exp(a * b): the shape the fusion rule must NOT fire
/// on.
fn pair_exp_of_product() -> NegativePair {
    NegativePair {
        name: "exp_of_product",
        reference: exp_product_of_exps(),
        mutant: exp_of_combined(ptx!("negative_equivalence/exp_of_product")),
    }
}

/// Both directions of the e^a * e^b fusion: equal to e^(a+b) (catches losing
/// the fusion) and not equal to e^(a*b) (catches fusing too eagerly).
#[test]
fn mutation_10_exp_fusion_control_and_exp_of_product_not_equivalent() {
    assert_equivalent_control(
        "exp_fusion_control",
        &exp_product_of_exps(),
        &exp_of_combined(ptx!("negative_equivalence/exp_of_sum")),
    );
    assert_not_equivalent(&pair_exp_of_product(), &[("out", 0)]);
}

// =========================================================================
// Mutation 11: sign-bit xor is not a negate on integer data
// =========================================================================

/// out[0] = in[0] ^ 0x80000000 on integer data vs out[0] = -in[0]
/// (neg.s32). The flip is x + 2^31 mod 2^32, not -x: they agree only at
/// 0 and 2^31, so e.g. x = 1 gives 0x80000001 vs 0xFFFFFFFF.
#[test]
fn mutation_11_integer_sign_bit_xor_is_not_a_negate() {
    let pair = NegativePair {
        name: "integer_sign_bit_xor",
        reference: Kernel {
            src: ptx!("negative_equivalence/integer_sign_bit_xor_ref"),
            config: f32_config(1, 1, 1),
        },
        mutant: Kernel {
            src: ptx!("negative_equivalence/integer_sign_bit_xor_mut"),
            config: f32_config(1, 1, 1),
        },
    };
    assert_not_equivalent(&pair, &[("out", 0)]);
}

// =========================================================================
// Meta test: the whole taxonomy in one batch
// =========================================================================

fn negative_pairs() -> Vec<NegativePair> {
    vec![
        pair_constant_perturbation(),
        pair_dropped_term(),
        pair_swapped_noncommutative(),
        pair_off_by_one_index(),
        pair_missing_relu_clamp(),
        pair_sentinel_off_by_one(),
        pair_fma_different_addend(),
        pair_perturbed_reduction_leaf(),
        pair_max_vs_min(),
        pair_exp_of_product(),
    ]
}

/// Every negative pair, re-checked in one loop so a soundness regression
/// fails even if the individual tests change: an Equivalent verdict here is a
/// false EQUIV for the named mutation.
#[test]
fn meta_no_negative_pair_is_proved_equivalent() {
    let pairs = negative_pairs();
    assert_eq!(pairs.len(), 10, "the taxonomy has ten negative pairs");
    for pair in &pairs {
        assert!(
            !matches!(check_pair(pair), EquivOutcome::Equivalent),
            "SOUNDNESS BUG: mutation '{}' was proved Equivalent",
            pair.name
        );
    }
}
