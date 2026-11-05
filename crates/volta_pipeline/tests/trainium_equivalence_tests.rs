//! Functional equivalence of NKI kernels against mathematical specifications.

use std::collections::HashMap;

use volta_equivalence::check::EquivCheckOptions;
use volta_pipeline::{EquivalenceVerdict, check_equivalence};
use volta_trainium_analysis::frontend::parse::parse_kernel;
use volta_trainium_analysis::{evaluate, lower_kernel};

/// Run `kernel` against `spec` at dims `[M, N, K]`, comparing the `out` array: the
/// kernel is called with `a_t` of `[K, M]`, `b` of `[K, N]` and `out` of `[M, N]`.
fn check(kernel: &str, spec: &str, [m, n, k]: [u64; 3]) -> EquivalenceVerdict {
    let shapes: [(&str, &[u64]); 3] = [("a_t", &[k, m]), ("b", &[k, n]), ("out", &[m, n])];
    let parsed = parse_kernel(kernel, "kernel", &shapes).unwrap();
    let lowered = lower_kernel(&parsed).unwrap();
    let actual = evaluate(&lowered).unwrap();

    let dims = HashMap::from([("M".into(), m), ("N".into(), n), ("K".into(), k)]);
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();

    check_equivalence(
        &reference,
        &actual,
        &["out".into()],
        &EquivCheckOptions::default(),
    )
    .0
}

const MATMUL: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/matmul.py");
const MATMUL_SPEC: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/matmul.spec");
const GEMM_RELU: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/gemm_relu.py");
const GEMM_RELU_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/gemm_relu.spec");

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
