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
    let lowered = lower_kernel(&parsed).unwrap();
    let actual = evaluate(&lowered).unwrap();

    let dims = dims
        .iter()
        .map(|&(dim, value)| (dim.to_string(), value))
        .collect::<HashMap<_, _>>();
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();

    check_equivalence(
        &reference,
        &actual,
        &[array.into()],
        &EquivCheckOptions::default(),
    )
    .0
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
