//! Functional equivalence of NKI kernels against mathematical specifications.

use std::collections::HashMap;

use volta_equivalence::check::EquivCheckOptions;
use volta_expr::SymbolicOutputs;
use volta_pipeline::{EquivalenceVerdict, check_equivalence};
use volta_trainium_analysis::frontend::ast::Kernel;
use volta_trainium_analysis::frontend::parse::{
    KernelCall, TileSizes, parse_kernel, parse_kernel_for_call, parse_kernel_with_modules,
};
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

const FUSED_SOFTMAX: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/fused_softmax.py");

// Softmax as attn_fwd_v8 fuses it: a negated max reduction, then activation with a bias
// and a reduction. A sign error in either would compute another function.
#[test]
fn nki_fused_softmax_matches_its_specification() {
    assert_eq!(
        verdict(
            FUSED_SOFTMAX,
            &[("x", &[2, 4])],
            SOFTMAX_SPEC,
            &[("P", 2), ("F", 4)],
            "kernel_out",
        ),
        EquivalenceVerdict::Equivalent {
            checked: 8,
            total: 8,
        }
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

/// The samples' file with v3 to v8a's `assert seqlen_q >= 512` stated as the limit it
/// stands for, `nl.tile_size.gemm_moving_fmax` (512 on the hardware), so they also run
/// at smaller tile sizes. This is the one change; every other line is the samples'.
fn tileable_attention_kernels() -> String {
    const ASSERT: &str = "assert seqlen_q >= 512";
    assert_eq!(ATTENTION_KERNELS.matches(ASSERT).count(), 7);
    ATTENTION_KERNELS.replace(ASSERT, "assert seqlen_q >= FMAX_MOVING")
}

/// Tiled sample `kernel` of the tileable file, `q`, `k` and `v` of `[d, n]`, with
/// `nl.tile_size` reading `tile_sizes`.
fn tiled_attention_kernel(kernel: &str, tile_sizes: TileSizes, [d, n]: [u64; 2]) -> Kernel {
    let shape: &[u64] = &[d, n];
    let shapes = [("q", shape), ("k", shape), ("v", shape)];
    let call = KernelCall {
        tile_sizes,
        ..KernelCall::new(&shapes)
    };
    parse_kernel_for_call(
        &tileable_attention_kernels(),
        &[("attention_kernel_utils", ATTENTION_UTILS)],
        kernel,
        &call,
    )
    .unwrap()
}

/// Reduced tile sizes and the `[d_head, seqlen]` they run v3 and v4 at: `pmax` and
/// `gemm_stationary_fmax` equal, as on the hardware and as both kernels need, and every
/// loop running at least twice.
const REDUCED: [(TileSizes, [u64; 2]); 3] = [
    (reduced_tiles(4, 8), [4, 16]),
    (reduced_tiles(4, 8), [4, 32]),
    (reduced_tiles(8, 16), [8, 32]),
];

const fn reduced_tiles(pmax: u64, gemm_moving_fmax: u64) -> TileSizes {
    TileSizes {
        pmax,
        gemm_stationary_fmax: pmax,
        gemm_moving_fmax,
        sbuf_fmax_bytes: TileSizes::HARDWARE.sbuf_fmax_bytes,
    }
}

/// Tiled sample `kernel` against `spec` at `[d, n]`, on its first `sample` outputs.
fn check_tiled_attention(
    kernel: &str,
    spec: &str,
    tile_sizes: TileSizes,
    [d, n]: [u64; 2],
    sample: u64,
) -> EquivalenceVerdict {
    against_spec(
        &tiled_attention_kernel(kernel, tile_sizes, [d, n]),
        spec,
        &[("D", d), ("N", n)],
        "kernel_out",
        &sampled(sample),
    )
}

/// Tiled samples `reference` and `other` against each other at `[d, n]`.
fn check_tiled_attention_pair(
    [reference, other]: [&str; 2],
    tile_sizes: TileSizes,
    shape: [u64; 2],
    sample: u64,
) -> EquivalenceVerdict {
    let [reference, other] = [reference, other].map(|kernel| {
        let lowered = lower_kernel(&tiled_attention_kernel(kernel, tile_sizes, shape)).unwrap();
        evaluate(&lowered).unwrap()
    });
    check_equivalence(&reference, &other, &["kernel_out".into()], &sampled(sample)).0
}

/// Equivalent on every one of an `[n, d]` output's elements.
fn everywhere([d, n]: [u64; 2]) -> EquivalenceVerdict {
    EquivalenceVerdict::Equivalent {
        checked: d * n,
        total: d * n,
    }
}

// At the hardware's tile sizes the stated limit is the literal one, so the tileable file
// parses to exactly the samples' kernels.
#[test]
fn nki_attention_tileable_kernels_are_the_samples_at_full_size() {
    let shape: &[u64] = &[128, 512];
    let shapes = [("q", shape), ("k", shape), ("v", shape)];
    let modules = [("attention_kernel_utils", ATTENTION_UTILS)];
    let tileable = tileable_attention_kernels();
    for kernel in TILED {
        assert_eq!(
            parse_kernel_with_modules(&tileable, &modules, kernel, &shapes),
            parse_kernel_with_modules(ATTENTION_KERNELS, &modules, kernel, &shapes),
            "{kernel}"
        );
    }
}

/// The samples' tiled kernels, in the tutorial's order.
const TILED: [&str; 7] = [
    "attn_fwd_v3",
    "attn_fwd_v4",
    "attn_fwd_v5",
    "attn_fwd_v6",
    "attn_fwd_v7",
    "attn_fwd_v8",
    "attn_fwd_v8a",
];

/// Check tiled sample `kernel` equal to `attention.spec` on every output at each
/// reduced tile size.
fn assert_matches_attention_at_reduced_tile_sizes(kernel: &str) {
    for (tile_sizes, shape) in REDUCED {
        assert_eq!(
            check_tiled_attention(kernel, ATTENTION_SPEC, tile_sizes, shape, 0),
            everywhere(shape),
            "{kernel}: {tile_sizes:?} at {shape:?}"
        );
    }
}

#[test]
fn nki_attention_v3_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v3");
}

#[test]
fn nki_attention_v4_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v4");
}

// v5 delays the softmax division until after the product with v.
#[test]
fn nki_attention_v5_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v5");
}

// v6 fuses the max subtraction and the sum into one activation (bias, reduce) and
// negates the max in its reduction.
#[test]
fn nki_attention_v6_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v6");
}

// v7 stores the scores in bfloat16, which Volta does not round: a check over the reals.
#[test]
fn nki_attention_v7_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v7");
}

// v8 takes the row maxima with tensor_scalar_reduce on a copy evicted from PSUM.
#[test]
fn nki_attention_v8_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v8");
}

// v8a reorders v8 into the stages v10 pipelines, reading the evicted copy.
#[test]
fn nki_attention_v8a_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v8a");
}

// Each version against the one before it, kernel to kernel.
#[test]
fn nki_attention_each_tiled_version_matches_the_previous_at_reduced_tile_sizes() {
    for pair in TILED.windows(2) {
        let pair = [pair[0], pair[1]];
        for (tile_sizes, shape) in REDUCED {
            assert_eq!(
                check_tiled_attention_pair(pair, tile_sizes, shape, 0),
                everywhere(shape),
                "{pair:?}: {tile_sizes:?} at {shape:?}"
            );
        }
    }
}

#[test]
fn nki_attention_tiled_versions_against_attention_with_q_and_k_swapped_are_refuted() {
    let swapped = ATTENTION_SPEC.replace("q[d, i] * k[d,", "k[d, i] * q[d,");
    assert_ne!(swapped, ATTENTION_SPEC);
    let (tile_sizes, shape) = REDUCED[0];
    for kernel in TILED {
        let verdict = check_tiled_attention(kernel, &swapped, tile_sizes, shape, 1);
        assert!(
            matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
            "{kernel}: expected a confirmed difference, got {verdict:?}"
        );
    }
}

/// One output row of each of the tiled kernels' four 128-row query tiles at `[128, 512]`, each at
/// another partition of its tile: 0, 42, 85 and 127.
const QUERY_TILE_ROWS: [u64; 4] = [0, 170, 341, 511];

/// `outputs` with `kernel_out` cut down to `rows` of its 128-element rows, so the
/// check covers every query tile, not just a prefix of the outputs.
fn only_rows(mut outputs: SymbolicOutputs, rows: &[u64]) -> SymbolicOutputs {
    for (_, elements) in &mut outputs.outputs {
        elements.retain(|&(index, _)| rows.contains(&(index / 128)));
    }
    outputs
}

// The unmodified kernels at the size they assert, on one row of each query tile, each
// against the spec and the version before it. One test, so the spec's 65,536 outputs
// (most of the time, and many GB) unfold once.
#[test]
#[ignore = "unfolds attention at 128 x 512 (about 5 minutes and 12 GB); run with --ignored in release"]
fn nki_attention_tiled_versions_match_attention_and_each_other_on_a_row_of_each_query_tile_at_full_size()
 {
    let shape: &[u64] = &[128, 512];
    let dims = [("D", 128), ("N", 512)]
        .map(|(dim, value)| (dim.to_string(), value))
        .into();
    let reference = only_rows(
        volta_spec::extract_expressions_from_spec(ATTENTION_SPEC, &dims).unwrap(),
        &QUERY_TILE_ROWS,
    );
    let every_tile = EquivalenceVerdict::Equivalent {
        checked: 512,
        total: 512,
    };
    let arrays = ["kernel_out".into()];

    let mut previous: Option<(&str, SymbolicOutputs)> = None;
    for kernel in TILED {
        let parsed = parse_kernel_with_modules(
            ATTENTION_KERNELS,
            &[("attention_kernel_utils", ATTENTION_UTILS)],
            kernel,
            &[("q", shape), ("k", shape), ("v", shape)],
        )
        .unwrap();
        let actual = only_rows(
            evaluate(&lower_kernel(&parsed).unwrap()).unwrap(),
            &QUERY_TILE_ROWS,
        );
        assert_eq!(
            check_equivalence(&reference, &actual, &arrays, &sampled(0)).0,
            every_tile,
            "{kernel} against attention.spec"
        );
        if let Some((earlier, outputs)) = &previous {
            assert_eq!(
                check_equivalence(outputs, &actual, &arrays, &sampled(0)).0,
                every_tile,
                "{earlier} against {kernel}"
            );
        }
        previous = Some((kernel, actual));
    }
}
