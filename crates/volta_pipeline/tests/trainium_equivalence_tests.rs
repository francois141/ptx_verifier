//! Functional equivalence of NKI kernels against mathematical specifications.

use std::collections::HashMap;

use volta_equivalence::check::EquivCheckOptions;
use volta_pipeline::{EquivalenceVerdict, check_equivalence};
use volta_trainium_analysis::frontend::ast::Kernel;
use volta_trainium_analysis::frontend::parse::{parse_kernel, parse_kernel_with_modules};
use volta_trainium_analysis::{evaluate, lower_kernel};

/// Run `kernel` against `spec` at dims `[M, N, K]`, comparing the `out` array: the
/// kernel is called with `a_t` of `[K, M]`, `b` of `[K, N]` and `out` of `[M, N]`.
fn check(kernel: &str, spec: &str, [m, n, k]: [u64; 3]) -> EquivalenceVerdict {
    let shapes: [(&str, &[u64]); 3] = [("a_t", &[k, m]), ("b", &[k, n]), ("out", &[m, n])];
    let dims = [("M", m), ("N", n), ("K", k)];
    verdict(kernel, &shapes, spec, &dims, "out")
}

/// Run `kernel` for a call with `shapes` against `spec` at `dims`, comparing `array`.
fn verdict(
    kernel: &str,
    shapes: &[(&str, &[u64])],
    spec: &str,
    dims: &[(&str, u64)],
    array: &str,
) -> EquivalenceVerdict {
    let parsed = parse_kernel(kernel, "kernel", shapes).unwrap();
    against_spec(&parsed, spec, dims, array, &EquivCheckOptions::default())
}

/// Lower and run `parsed`, then check its `array` against `spec` at `dims`.
fn against_spec(
    parsed: &Kernel,
    spec: &str,
    dims: &[(&str, u64)],
    array: &str,
    options: &EquivCheckOptions,
) -> EquivalenceVerdict {
    let lowered = lower_kernel(parsed).unwrap();
    let actual = evaluate(&lowered).unwrap();

    let dims = dims
        .iter()
        .map(|&(dim, value)| (dim.to_string(), value))
        .collect::<HashMap<_, _>>();
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();

    check_equivalence(&reference, &actual, &[array.into()], options).0
}

const MATMUL: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/matmul.py");
const MATMUL_SPEC: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/matmul.spec");
const GEMM_RELU: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/gemm_relu.py");
const GEMM_RELU_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/gemm_relu.spec");
const SOFTMAX: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/softmax.py");
const SOFTMAX_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/softmax.spec");

/// `softmax_isa`'s instructions inline, on a 2 x 3 tile, against `softmax.spec` (`spec` at
/// dims `P = 2`, `F = 3`).
fn check_softmax(spec: &str) -> EquivalenceVerdict {
    verdict(
        SOFTMAX,
        &[("x", &[2, 3])],
        spec,
        &[("P", 2), ("F", 3)],
        "kernel_out",
    )
}

#[test]
fn nki_matmul_matches_its_specification() {
    assert_eq!(
        check(MATMUL, MATMUL_SPEC, [2, 3, 4]),
        EquivalenceVerdict::Equivalent {
            checked: 6,
            total: 6,
        }
    );
}

#[test]
fn nki_gemm_relu_matches_its_specification() {
    assert_eq!(
        check(GEMM_RELU, GEMM_RELU_SPEC, [4, 4, 8]),
        EquivalenceVerdict::Equivalent {
            checked: 16,
            total: 16,
        }
    );
}

// The matmul spec at gemm_relu's dims lacks only the clamp, so the outputs agree wherever
// the product is non-negative and the oracle must separate the rest.
#[test]
fn nki_gemm_relu_against_the_unclamped_product_is_refuted() {
    let verdict = check(GEMM_RELU, MATMUL_SPEC, [4, 4, 8]);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

#[test]
fn nki_softmax_matches_its_specification() {
    assert_eq!(
        check_softmax(SOFTMAX_SPEC),
        EquivalenceVerdict::Equivalent {
            checked: 6,
            total: 6,
        }
    );
}

// `subtract` with its operands reversed would compute exp(max - x), the softmax of -x: the
// kernel must not be proved equal to that.
#[test]
fn nki_softmax_against_the_softmax_of_its_negated_input_is_refuted() {
    const NEGATED: &str = "dim P; dim F; array x[P, F]; array kernel_out[P, F];
        kernel_out[p, f] = exp(0.0 - x[p, f]) / sum(g in 0..F, exp(0.0 - x[p, g]));";
    let verdict = check_softmax(NEGATED);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

const ATTENTION_KERNELS: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/nki_samples/attention_kernels.py");
const ATTENTION_UTILS: &str = include_str!(
    "../../volta_trainium_analysis/tests/fixtures/nki_samples/attention_kernel_utils.py"
);
const ATTENTION_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/attention.spec");

/// The NKI samples' `kernel` from their own file, called as their test calls it: `q`, `k`
/// and `v` of `[128, 128]` (v1 and v2 assert that size).
fn attention_kernel(kernel: &str) -> Kernel {
    let size: &[u64] = &[128, 128];
    parse_kernel_with_modules(
        ATTENTION_KERNELS,
        &[("attention_kernel_utils", ATTENTION_UTILS)],
        kernel,
        &[("q", size), ("k", size), ("v", size)],
    )
    .unwrap()
}

fn sampled(sample: u64) -> EquivCheckOptions {
    EquivCheckOptions {
        sample,
        ..EquivCheckOptions::default()
    }
}

/// Attention sample `kernel` against `spec`'s `kernel_out`, on its first `sample` outputs.
fn check_attention(kernel: &str, spec: &str, sample: u64) -> EquivalenceVerdict {
    let dims = [("D", 128), ("N", 128)];
    against_spec(
        &attention_kernel(kernel),
        spec,
        &dims,
        "kernel_out",
        &sampled(sample),
    )
}

/// Attention samples `reference` and `other` against each other, kernel to kernel.
fn check_attention_pair(reference: &str, other: &str, sample: u64) -> EquivalenceVerdict {
    let [reference, other] = [reference, other].map(|kernel| {
        let lowered = lower_kernel(&attention_kernel(kernel)).unwrap();
        evaluate(&lowered).unwrap()
    });
    check_equivalence(&reference, &other, &["kernel_out".into()], &sampled(sample)).0
}

// The first row of outputs: every element of the 128 x 128 output is checked by
// `nki_attention_v2_matches_attention_everywhere`, which takes minutes.
#[test]
fn nki_attention_v2_matches_attention_on_its_first_row() {
    assert_eq!(
        check_attention("attn_fwd_v2", ATTENTION_SPEC, 128),
        EquivalenceVerdict::Equivalent {
            checked: 128,
            total: 16384,
        }
    );
}

#[test]
#[ignore = "checks all 16,384 outputs; run with --ignored in release"]
fn nki_attention_v2_matches_attention_everywhere() {
    assert_eq!(
        check_attention("attn_fwd_v2", ATTENTION_SPEC, 0),
        EquivalenceVerdict::Equivalent {
            checked: 16384,
            total: 16384,
        }
    );
}

// The scores of k against q, the transpose of q against k: the kernel's first output must
// differ from attention with the two inputs swapped. One refuted element suffices, and
// each costs the decision procedure far more than a proof.
#[test]
fn nki_attention_v2_against_attention_with_q_and_k_swapped_is_refuted() {
    let swapped = ATTENTION_SPEC.replace("q[d, i] * k[d,", "k[d, i] * q[d,");
    assert_ne!(swapped, ATTENTION_SPEC);
    let verdict = check_attention("attn_fwd_v2", &swapped, 1);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

// v1 writes attention with the `nki.language` functions that return a tile, which the
// parser rewrites into the `nki.isa` instructions v2 calls itself.
#[test]
fn nki_attention_v1_matches_attention_on_its_first_row() {
    assert_eq!(
        check_attention("attn_fwd_v1", ATTENTION_SPEC, 128),
        EquivalenceVerdict::Equivalent {
            checked: 128,
            total: 16384,
        }
    );
}

#[test]
#[ignore = "checks all 16,384 outputs; run with --ignored in release"]
fn nki_attention_v1_matches_attention_everywhere() {
    assert_eq!(
        check_attention("attn_fwd_v1", ATTENTION_SPEC, 0),
        EquivalenceVerdict::Equivalent {
            checked: 16384,
            total: 16384,
        }
    );
}

// Kernel against kernel, with no spec between them.
#[test]
fn nki_attention_v1_matches_v2_on_their_first_row() {
    assert_eq!(
        check_attention_pair("attn_fwd_v1", "attn_fwd_v2", 128),
        EquivalenceVerdict::Equivalent {
            checked: 128,
            total: 16384,
        }
    );
}
