//! End-to-end NEGATIVE equivalence tests: the no-false-EQUIV suite.
//!
//! Every test runs a pair of PTX kernels through the FULL pipeline
//! (parse -> instr_parse -> lower -> interpret -> paired_elements -> canon
//! decision procedure) and asserts the outcome is `NotEquivalent`. The two
//! kernels of each pair are *almost* equivalent - they differ in exactly one
//! semantic detail - so any `Equivalent` verdict here is a soundness bug
//! (a false EQUIV), not a modeling choice.
//!
//! The positive suites (eval_tests.rs, canon's unit tests) establish that
//! the tool proves true equivalences; this suite establishes the other half
//! of soundness confidence: it does not prove false ones. Inputs are
//! symbolic arrays wherever a value is needed, so each verdict quantifies
//! over all inputs rather than checking one concrete point.
//!
//! Mutation taxonomy (one test each, plus controls where a nearby positive
//! direction sharpens the negative one):
//!  1. constant perturbation (0.5 vs the f32 nearest 0.5000001)
//!  2. dropped term (sum of 4 inputs vs sum of 3)
//!  3. swapped non-commutative operands (a-b vs b-a; a/b vs b/a)
//!  4. off-by-one index with an identical output footprint
//!  5. missing clamp (fma.rn.relu.f16 vs plain fma.rn.f16)
//!  6. boundary sentinel off by one (-1 vs 4294967294 at u32)
//!  7. fma vs mul+add with a different addend
//!  8. reassociated reduction with one perturbed leaf
//!  9. max(a, b) vs min(a, b)
//! 10. exp fragment, both directions: e^a * e^b == e^(a+b) (positive
//!     control for the fusion) and e^a * e^b != e^(a*b)
//! 11. sign-bit xor on integer data is not a negate
//!     (xor.b32 x, 0x80000000 != neg.s32 x)
//!
//! The meta test at the bottom re-checks every negative pair in one batch,
//! so a soundness regression still fails loudly even if an individual
//! test's assertion is edited.

use volta_analysis::driver::{EquivOutcome, analyze_kernel, check_output_equivalence};
use volta_analysis::eval::{AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, ParamValue};
use volta_frontend::ascii::AsAscii;
use volta_frontend::ast::Module;
use volta_frontend::parse::Parser;

// =========================================================================
// Harness
// =========================================================================

fn parse(src: &str) -> Module {
    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error))
}

const HEADER: &str = ".version 8.0\n.target sm_80\n.address_size 64\n\n";

/// Generous register declarations shared by every kernel, so each kernel
/// body below is only the instructions under test.
const REGS: &str = "    .reg .pred %p<4>;
    .reg .b16 %rs<6>;
    .reg .f32 %f<12>;
    .reg .b32 %r<10>;
    .reg .b64 %rd<10>;
";

/// Kernel with two pointer params: %rd1 = param 0 (input), %rd2 = param 1
/// (output), both cvta'd to global.
fn two_param_kernel(body: &str) -> String {
    format!(
        "{HEADER}.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{{
{REGS}
    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
{body}    ret;
}}
"
    )
}

/// Kernel with a single pointer param: %rd1 = param 0 (output).
fn one_param_kernel(body: &str) -> String {
    format!(
        "{HEADER}.visible .entry k(
    .param .u64 k_param_0
)
{{
{REGS}
    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd1, %rd1;
{body}    ret;
}}
"
    )
}

/// A two-param kernel preceded by the `__symexpf` extern declaration (the
/// paper's symbolic-exp hook; the nvcc callseq idiom lowers to `Exp`).
fn exp_kernel(body: &str) -> String {
    let kernel = two_param_kernel(body);
    let decl = ".extern .func  (.param .b32 func_retval0) __symexpf
(
    .param .b32 __symexpf_param_0
)
;

";
    kernel.replacen(HEADER, &format!("{HEADER}{decl}"), 1)
}

/// One nvcc callseq block applying `__symexpf` to `%f{src}`, result in
/// `%f{dst}`.
fn symexp_call(seq: u32, src: u32, dst: u32) -> String {
    format!(
        "    {{ // callseq {seq}, 0
    .reg .b32 temp_param_reg;
    .param .b32 param0;
    st.param.f32 [param0+0], %f{src};
    .param .b32 retval0;
    call.uni (retval0),
    __symexpf,
    (
    param0
    );
    ld.param.f32 %f{dst}, [retval0+0];
    }} // callseq {seq}
"
    )
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
    let body = |half: &str| {
        format!(
            "    ld.global.f32 %f1, [%rd1];
    mul.f32 %f2, %f1, {half};
    st.global.f32 [%rd2], %f2;
"
        )
    };
    NegativePair {
        name: "constant_perturbation",
        reference: Kernel {
            src: two_param_kernel(&body("0f3F000000")),
            config: f32_config(1, 1, 1),
        },
        mutant: Kernel {
            src: two_param_kernel(&body("0f3F000002")),
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
    const LOADS: &str = "    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    ld.global.f32 %f3, [%rd1+8];
    ld.global.f32 %f4, [%rd1+12];
";
    let sum4 = format!(
        "{LOADS}    add.f32 %f5, %f1, %f2;
    add.f32 %f6, %f5, %f3;
    add.f32 %f7, %f6, %f4;
    st.global.f32 [%rd2], %f7;
"
    );
    let sum3 = format!(
        "{LOADS}    add.f32 %f5, %f1, %f2;
    add.f32 %f6, %f5, %f3;
    st.global.f32 [%rd2], %f6;
"
    );
    NegativePair {
        name: "dropped_term",
        reference: Kernel {
            src: two_param_kernel(&sum4),
            config: f32_config(1, 4, 1),
        },
        mutant: Kernel {
            src: two_param_kernel(&sum3),
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
    let body = |first: &str, second: &str| {
        format!(
            "    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    sub.f32 %f3, {first};
    st.global.f32 [%rd2], %f3;
    div.rn.f32 %f4, {second};
    st.global.f32 [%rd2+4], %f4;
"
        )
    };
    NegativePair {
        name: "swapped_noncommutative",
        reference: Kernel {
            src: two_param_kernel(&body("%f1, %f2", "%f1, %f2")),
            config: f32_config(1, 2, 2),
        },
        mutant: Kernel {
            src: two_param_kernel(&body("%f2, %f1", "%f2, %f1")),
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

/// out[tid] = in[tid] vs out[tid] = in[tid + 1] with 4 threads. Both
/// kernels write exactly out[0..4), so the footprints pair up cleanly and
/// the per-element checks (in[i] vs in[i+1]) all fail: the outcome is
/// NotEquivalent on every element, not a shape error. (The input array is
/// sized so in[tid + 1] stays in bounds.)
fn pair_off_by_one_index() -> NegativePair {
    let body = |offset: &str| {
        format!(
            "    mov.u32 %r1, %tid.x;
    shl.b32 %r2, %r1, 2;
    cvt.u64.u32 %rd3, %r2;
    add.s64 %rd4, %rd1, %rd3;
    ld.global.f32 %f1, [%rd4{offset}];
    add.s64 %rd5, %rd2, %rd3;
    st.global.f32 [%rd5], %f1;
"
        )
    };
    NegativePair {
        name: "off_by_one_index",
        reference: Kernel {
            src: two_param_kernel(&body("")),
            config: f32_config(4, 8, 4),
        },
        mutant: Kernel {
            src: two_param_kernel(&body("+4")),
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
    let body = |fma: &str| {
        format!(
            "    ld.global.u16 %rs1, [%rd1];
    ld.global.u16 %rs2, [%rd1+2];
    ld.global.u16 %rs3, [%rd1+4];
    {fma} %rs4, %rs1, %rs2, %rs3;
    st.global.u16 [%rd2], %rs4;
"
        )
    };
    NegativePair {
        name: "missing_relu_clamp",
        reference: Kernel {
            src: two_param_kernel(&body("fma.rn.relu.f16")),
            config: f16_config(3, 1),
        },
        mutant: Kernel {
            src: two_param_kernel(&body("fma.rn.f16")),
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

/// mov.u32 -1 (the canonical 4294967295 sentinel) vs a kernel storing
/// 4294967294 - one below the canonicalized all-ones pattern. The positive
/// twin (eval_tests: mov -1 == not.b32 0) proves the canonicalization
/// direction; this proves the boundary is exact, not a collapse.
fn pair_sentinel_off_by_one() -> NegativePair {
    let body = |value: &str| {
        format!(
            "    mov.u32 %r1, {value};
    st.global.u32 [%rd1], %r1;
"
        )
    };
    NegativePair {
        name: "sentinel_off_by_one",
        reference: Kernel {
            src: one_param_kernel(&body("-1")),
            config: u32_out_config(),
        },
        mutant: Kernel {
            src: one_param_kernel(&body("4294967294")),
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

/// fma(in[0], in[1], in[2]) vs mul+add computing in[0]*in[1] + in[3]:
/// the same shape the true fma == mul+add identity has (eval_tests proves
/// that positive direction), but with the addend swapped for a different
/// input element.
fn pair_fma_different_addend() -> NegativePair {
    const LOADS: &str = "    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    ld.global.f32 %f3, [%rd1+8];
    ld.global.f32 %f4, [%rd1+12];
";
    let fused = format!(
        "{LOADS}    fma.rn.f32 %f5, %f1, %f2, %f3;
    st.global.f32 [%rd2], %f5;
"
    );
    let unfused_wrong_addend = format!(
        "{LOADS}    mul.f32 %f5, %f1, %f2;
    add.f32 %f6, %f5, %f4;
    st.global.f32 [%rd2], %f6;
"
    );
    NegativePair {
        name: "fma_different_addend",
        reference: Kernel {
            src: two_param_kernel(&fused),
            config: f32_config(1, 4, 1),
        },
        mutant: Kernel {
            src: two_param_kernel(&unfused_wrong_addend),
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

const SUM4_LOADS: &str = "    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    ld.global.f32 %f3, [%rd1+8];
    ld.global.f32 %f4, [%rd1+12];
";

/// The linear-chain sum ((in[0]+in[1])+in[2])+in[3].
fn linear_chain_sum() -> Kernel {
    let body = format!(
        "{SUM4_LOADS}    add.f32 %f5, %f1, %f2;
    add.f32 %f6, %f5, %f3;
    add.f32 %f7, %f6, %f4;
    st.global.f32 [%rd2], %f7;
"
    );
    Kernel {
        src: two_param_kernel(&body),
        config: f32_config(1, 4, 1),
    }
}

/// The balanced tree (in[0]+in[1]) + (in[2]+LEAF), with the last leaf
/// either honest (in[3]) or doubled (in[3]+in[3]).
fn balanced_tree_sum(doubled_leaf: bool) -> Kernel {
    let leaf = if doubled_leaf {
        "    add.f32 %f8, %f4, %f4;\n"
    } else {
        "    mov.f32 %f8, %f4;\n"
    };
    let body = format!(
        "{SUM4_LOADS}{leaf}    add.f32 %f5, %f1, %f2;
    add.f32 %f6, %f3, %f8;
    add.f32 %f7, %f5, %f6;
    st.global.f32 [%rd2], %f7;
"
    );
    Kernel {
        src: two_param_kernel(&body),
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
    let body = |op: &str| {
        format!(
            "    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    {op} %f3, %f1, %f2;
    st.global.f32 [%rd2], %f3;
"
        )
    };
    NegativePair {
        name: "max_vs_min",
        reference: Kernel {
            src: two_param_kernel(&body("max.f32")),
            config: f32_config(1, 2, 1),
        },
        mutant: Kernel {
            src: two_param_kernel(&body("min.f32")),
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
    let body = format!(
        "    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
{}{}    mul.f32 %f5, %f3, %f4;
    st.global.f32 [%rd2], %f5;
",
        symexp_call(0, 1, 3),
        symexp_call(1, 2, 4)
    );
    Kernel {
        src: exp_kernel(&body),
        config: f32_config(1, 2, 1),
    }
}

/// out[0] = exp(in[0] OP in[1]) for the given combining instruction.
fn exp_of_combined(op: &str) -> Kernel {
    let body = format!(
        "    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    {op} %f3, %f1, %f2;
{}    st.global.f32 [%rd2], %f4;
",
        symexp_call(0, 3, 4)
    );
    Kernel {
        src: exp_kernel(&body),
        config: f32_config(1, 2, 1),
    }
}

/// exp(a) * exp(b) vs exp(a * b): the shape the fusion rule must NOT fire
/// on.
fn pair_exp_of_product() -> NegativePair {
    NegativePair {
        name: "exp_of_product",
        reference: exp_product_of_exps(),
        mutant: exp_of_combined("mul.f32"),
    }
}

/// Both directions of the e^a * e^b fusion, end to end: equal to e^(a+b)
/// (an under-approximation drift - losing the fusion - fails the control)
/// and not equal to e^(a*b) (an over-approximation drift - fusing too
/// eagerly - fails the negative half).
#[test]
fn mutation_10_exp_fusion_control_and_exp_of_product_not_equivalent() {
    assert_equivalent_control(
        "exp_fusion_control",
        &exp_product_of_exps(),
        &exp_of_combined("add.f32"),
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
    let body = |op: &str| {
        format!(
            "    ld.global.u32 %r1, [%rd1];
    {op};
    st.global.u32 [%rd2], %r2;
"
        )
    };
    let pair = NegativePair {
        name: "integer_sign_bit_xor",
        reference: Kernel {
            src: two_param_kernel(&body("xor.b32 %r2, %r1, 0x80000000")),
            config: f32_config(1, 1, 1),
        },
        mutant: Kernel {
            src: two_param_kernel(&body("neg.s32 %r2, %r1")),
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

/// Every negative pair, re-checked in one loop: none may come back
/// Equivalent, no matter how the individual tests above evolve. A failure
/// here is a false EQUIV - a soundness bug in the pipeline or the decision
/// procedure - for the named mutation.
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
