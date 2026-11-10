//! Functional equivalence of NKI kernels against mathematical specifications.

use std::collections::HashMap;

use volta_equivalence::check::EquivCheckOptions;
use volta_expr::SymbolicOutputs;
use volta_pipeline::{
    EquivalenceVerdict, GraphEvidence, Isa, Solver, Spec, Verdict, check_equivalence,
};
use volta_ptx_analysis::AnalysisConfig;
use volta_trainium_analysis::frontend::ast::Kernel;
use volta_trainium_analysis::frontend::parse::{
    Constant, KernelCall, TileSizes, parse_kernel, parse_kernel_for_call, parse_kernel_with_modules,
};

/// The inputs' dtype upstream's `test_attention.py` calls each tiled sample with:
/// `bfloat16` for v10, whose allocator sizes its tiles by it, else `float32`.
fn upstream_dtype(kernel: &str) -> &'static str {
    match kernel {
        "attn_fwd_v10" => "bfloat16",
        _ => "float32",
    }
}

/// Tiled sample `kernel` of `source` for `q`, `k` and `v` of `shape` in their upstream
/// dtype, with `nl.tile_size` reading `tile_sizes`.
fn parse_tiled(source: &str, kernel: &str, tile_sizes: TileSizes, shape: &[u64]) -> Kernel {
    let shapes = [("q", shape), ("k", shape), ("v", shape)];
    let dtype = upstream_dtype(kernel);
    let dtypes = [("q", dtype), ("k", dtype), ("v", dtype)];
    let call = KernelCall {
        dtypes: &dtypes,
        tile_sizes,
        ..KernelCall::new(&shapes)
    };
    parse_kernel_for_call(
        source,
        &[("attention_kernel_utils", ATTENTION_UTILS)],
        kernel,
        &call,
    )
    .unwrap_or_else(|e| panic!("{kernel}: {e}"))
}
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

// Test that an NKI kernel proved equal to its spec is not accepted, as its interpreter records no
// event graph to establish race freedom.
#[test]
fn nki_kernel_equal_to_its_spec_is_unknown_without_race_evidence() {
    let parsed = volta_spec::parse_spec(MATMUL_SPEC).unwrap();
    let dims = HashMap::from([
        ("M".to_string(), 2),
        ("N".to_string(), 3),
        ("K".to_string(), 4),
    ]);
    let spec = Spec::new(&parsed, &dims).unwrap();
    let solver = Solver::Canonical(EquivCheckOptions::default());
    let launch = AnalysisConfig::new((1, 1, 1));

    let (run, solution) = Isa::Trainium
        .frontend()
        .solve(MATMUL, None, launch, &spec, &solver)
        .unwrap();
    assert!(matches!(run.graph, GraphEvidence::NotRecorded));
    assert_eq!(
        solution.verdict(),
        EquivalenceVerdict::Equivalent {
            checked: 6,
            total: 6,
        }
    );

    let decision = run.decide(&solution);
    assert_eq!(decision.verdict, Verdict::Unknown);
    assert!(
        decision
            .evidence
            .iter()
            .any(|e| e.contains("race freedom not checked")),
        "{:?}",
        decision.evidence
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

/// Tiled sample `kernel` of the tileable file at `[d, n]` (`parse_tiled`).
fn tiled_attention_kernel(kernel: &str, tile_sizes: TileSizes, [d, n]: [u64; 2]) -> Kernel {
    parse_tiled(&tileable_attention_kernels(), kernel, tile_sizes, &[d, n])
}

/// Reduced tile sizes and the `[d_head, seqlen]` the tiled kernels run at: `pmax` and
/// `gemm_stationary_fmax` equal, as on the hardware and as the kernels need, and every
/// loop running at least twice. The last gives eight key tiles, so v10's QK matmuls wrap
/// around its seven PSUM banks as they do at seqlen 4096.
const REDUCED: [(TileSizes, [u64; 2]); 4] = [
    (reduced_tiles(4, 8), [4, 16]),
    (reduced_tiles(4, 8), [4, 32]),
    (reduced_tiles(8, 16), [8, 32]),
    (reduced_tiles(4, 4), [4, 32]),
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
    let tileable = tileable_attention_kernels();
    for kernel in TILED {
        assert_eq!(
            parse_tiled(&tileable, kernel, TileSizes::HARDWARE, shape),
            parse_tiled(ATTENTION_KERNELS, kernel, TileSizes::HARDWARE, shape),
            "{kernel}"
        );
    }
}

/// The samples' tiled kernels, in the tutorial's order (the samples have no v9).
const TILED: [&str; 8] = [
    "attn_fwd_v3",
    "attn_fwd_v4",
    "attn_fwd_v5",
    "attn_fwd_v6",
    "attn_fwd_v7",
    "attn_fwd_v8",
    "attn_fwd_v8a",
    "attn_fwd_v10",
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

// v10 places every tile itself (`v_psum_t` over `qk_psum`'s PSUM banks) and software
// pipelines v8a's stages across query tiles; it states `seqlen_q >= FMAX_MOVING` itself.
#[test]
fn nki_attention_v10_matches_attention_at_reduced_tile_sizes() {
    assert_matches_attention_at_reduced_tile_sizes("attn_fwd_v10");
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
        let parsed = parse_tiled(ATTENTION_KERNELS, kernel, TileSizes::HARDWARE, shape);
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

const TENSOR_ADDITION: &str = include_str!(
    "../../volta_trainium_analysis/tests/fixtures/nki_samples/tensor_addition_nki_kernels.py"
);
const TENSOR_ADDITION_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/tensor_addition.spec");

/// The tensor addition tutorial's kernel, from its unmodified file, for float32 `a_input`
/// and `b_input` of `[m, n]`, against `tensor_addition.spec`.
fn check_tensor_addition(spec: &str, [m, n]: [u64; 2]) -> EquivalenceVerdict {
    let shape: &[u64] = &[m, n];
    let shapes = [("a_input", shape), ("b_input", shape)];
    let dtypes = [("a_input", "float32"), ("b_input", "float32")];
    let call = KernelCall {
        dtypes: &dtypes,
        ..KernelCall::new(&shapes)
    };
    let parsed = parse_kernel_for_call(TENSOR_ADDITION, &[], "nki_tensor_add", &call).unwrap();
    against_spec(
        &parsed,
        spec,
        &[("M", m), ("N", n)],
        "c_output",
        &EquivCheckOptions::default(),
    )
}

// At the torch driver's own size: its tiles are literal 128 x 512, so it has no reduced
// one, and each output is one addition.
#[test]
fn nki_tensor_addition_matches_its_specification_at_full_size() {
    assert_eq!(
        check_tensor_addition(TENSOR_ADDITION_SPEC, [256, 1024]),
        everywhere([256, 1024])
    );
}

#[test]
fn nki_tensor_addition_against_a_subtraction_is_refuted() {
    let subtraction = TENSOR_ADDITION_SPEC.replace("] + b_input", "] - b_input");
    assert_ne!(subtraction, TENSOR_ADDITION_SPEC);
    let verdict = check_tensor_addition(&subtraction, [128, 512]);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

const MATRIX_MULTIPLICATION: &str = include_str!(
    "../../volta_trainium_analysis/tests/fixtures/nki_samples/matrix_multiplication_nki_kernels.py"
);
const MATRIX_MULTIPLICATION_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/matrix_multiplication.spec");

/// Matrix multiplication tutorial `kernel`, from its unmodified file, for `lhsT` of
/// `[k, m]` and `rhs` of `[k, n]`, with `nl.tile_size` reading `tile_sizes`.
fn matrix_multiplication(kernel: &str, tile_sizes: TileSizes, dims: [u64; 3]) -> SymbolicOutputs {
    matrix_multiplication_with(kernel, tile_sizes, dims, &[])
}

/// `matrix_multiplication` with the kernel's other parameters given `constants`.
fn matrix_multiplication_with(
    kernel: &str,
    tile_sizes: TileSizes,
    [m, n, k]: [u64; 3],
    constants: &[(&str, Constant)],
) -> SymbolicOutputs {
    let (lhs_t, rhs): (&[u64], &[u64]) = (&[k, m], &[k, n]);
    let shapes = [("lhsT", lhs_t), ("rhs", rhs)];
    let call = KernelCall {
        tile_sizes,
        constants,
        ..KernelCall::new(&shapes)
    };
    let parsed = parse_kernel_for_call(MATRIX_MULTIPLICATION, &[], kernel, &call)
        .unwrap_or_else(|e| panic!("{kernel}: {e}"));
    evaluate(&lower_kernel(&parsed).unwrap()).unwrap()
}

/// `outputs`' `result` against `spec` at `[m, n, k]`.
fn matrix_multiplication_against(
    spec: &str,
    outputs: &SymbolicOutputs,
    [m, n, k]: [u64; 3],
    sample: u64,
) -> EquivalenceVerdict {
    let dims = [("M", m), ("N", n), ("K", k)]
        .map(|(dim, value)| (dim.to_string(), value))
        .into();
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();
    check_equivalence(&reference, outputs, &["result".into()], &sampled(sample)).0
}

/// The tutorial's tiled kernels, in its order.
const TILED_MATMULS: [&str; 4] = [
    "nki_matmul_tiled_",
    "nki_matmul_hoist_load_",
    "nki_matmul_block_free_dimension_",
    "nki_matmul_fully_optimized_",
];

/// Reduced tile sizes and the `[M, N, K]` they run the tiled kernels at: each a
/// multiple of `nki_matmul_fully_optimized_`'s blocks of 16 x 2 x 8 tiles, two of each,
/// so every loop of every kernel runs at least twice.
const REDUCED_MATMULS: [(TileSizes, [u64; 3]); 2] = [
    (reduced_tiles(2, 4), [64, 16, 32]),
    (reduced_tiles(4, 8), [128, 32, 64]),
];

// `nki_matmul_basic_` asserts its 64 x 512 x 128 and reads no tile size.
#[test]
fn nki_matmul_basic_matches_its_specification_at_full_size() {
    let dims = [64, 512, 128];
    let outputs = matrix_multiplication("nki_matmul_basic_", TileSizes::HARDWARE, dims);
    assert_eq!(
        matrix_multiplication_against(MATRIX_MULTIPLICATION_SPEC, &outputs, dims, 0),
        EquivalenceVerdict::Equivalent {
            checked: 64 * 512,
            total: 64 * 512,
        }
    );
}

#[test]
fn nki_tiled_matmuls_match_their_specification_and_each_other_at_reduced_tile_sizes() {
    for (tile_sizes, dims @ [m, n, _]) in REDUCED_MATMULS {
        let everywhere = EquivalenceVerdict::Equivalent {
            checked: m * n,
            total: m * n,
        };
        let mut previous: Option<(&str, SymbolicOutputs)> = None;
        for kernel in TILED_MATMULS {
            let outputs = matrix_multiplication(kernel, tile_sizes, dims);
            assert_eq!(
                matrix_multiplication_against(MATRIX_MULTIPLICATION_SPEC, &outputs, dims, 0),
                everywhere,
                "{kernel}: {tile_sizes:?} at {dims:?}"
            );
            if let Some((earlier, earlier_outputs)) = &previous {
                let arrays = ["result".into()];
                assert_eq!(
                    check_equivalence(earlier_outputs, &outputs, &arrays, &sampled(0)).0,
                    everywhere,
                    "{earlier} against {kernel}: {tile_sizes:?} at {dims:?}"
                );
            }
            previous = Some((kernel, outputs));
        }
    }
}

// The fully optimized kernel's meta-parameters given by the call rather than defaulted:
// blocks of 2 x 2 x 2 tiles, two of each.
#[test]
fn nki_matmul_fully_optimized_matches_its_specification_with_smaller_blocks() {
    let dims @ [m, n, _] = [16, 32, 16];
    let blocks = [
        ("TILES_IN_BLOCK_M", Constant::Int(2)),
        ("TILES_IN_BLOCK_N", Constant::Int(2)),
        ("TILES_IN_BLOCK_K", Constant::Int(2)),
    ];
    let kernel = "nki_matmul_fully_optimized_";
    let outputs = matrix_multiplication_with(kernel, reduced_tiles(4, 8), dims, &blocks);
    assert_eq!(
        matrix_multiplication_against(MATRIX_MULTIPLICATION_SPEC, &outputs, dims, 0),
        EquivalenceVerdict::Equivalent {
            checked: m * n,
            total: m * n,
        }
    );
}

// Summing the product twice, as a PSUM tile accumulated across output tiles would.
#[test]
fn nki_matmuls_against_a_doubled_product_are_refuted() {
    let doubled = MATRIX_MULTIPLICATION_SPEC.replace("= sum(", "= 2 * sum(");
    assert_ne!(doubled, MATRIX_MULTIPLICATION_SPEC);
    let basic = [64, 512, 128];
    let (tile_sizes, reduced) = REDUCED_MATMULS[0];
    let kernels = std::iter::once(("nki_matmul_basic_", TileSizes::HARDWARE, basic))
        .chain(TILED_MATMULS.map(|kernel| (kernel, tile_sizes, reduced)));
    for (kernel, tile_sizes, dims) in kernels {
        let outputs = matrix_multiplication(kernel, tile_sizes, dims);
        let verdict = matrix_multiplication_against(&doubled, &outputs, dims, 1);
        assert!(
            matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
            "{kernel}: expected a confirmed difference, got {verdict:?}"
        );
    }
}

const TRANSPOSE2D: &str = include_str!(
    "../../volta_trainium_analysis/tests/fixtures/nki_samples/transpose2d_nki_kernels.py"
);
const TRANSPOSE2D_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/transpose2d.spec");

/// The transpose2d tutorial's kernel, from its unmodified file, for a float32
/// `in_tensor` of `[p, x * y]` with `shape2D=(x, y)`, against `spec`.
fn check_transpose2d(spec: &str, [p, x, y]: [u64; 3]) -> EquivalenceVerdict {
    let shape: &[u64] = &[p, x * y];
    let shapes = [("in_tensor", shape)];
    let dtypes = [("in_tensor", "float32")];
    let shape_2d = [x as i64, y as i64];
    let constants = [("shape2D", Constant::Ints(&shape_2d))];
    let call = KernelCall {
        dtypes: &dtypes,
        constants: &constants,
        ..KernelCall::new(&shapes)
    };
    let parsed = parse_kernel_for_call(TRANSPOSE2D, &[], "tensor_transpose2D_kernel_", &call)
        .unwrap_or_else(|e| panic!("{e}"));
    against_spec(
        &parsed,
        spec,
        &[("P", p), ("X", x), ("Y", y)],
        "out_tensor",
        &EquivCheckOptions::default(),
    )
}

// At the torch and numpy drivers' 5 x (3 x 4) and the jax driver's 5 x (37 x 44).
#[test]
fn nki_transpose2d_matches_its_specification_at_its_drivers_sizes() {
    for dims @ [p, x, y] in [[5, 3, 4], [5, 37, 44]] {
        assert_eq!(
            check_transpose2d(TRANSPOSE2D_SPEC, dims),
            EquivalenceVerdict::Equivalent {
                checked: p * x * y,
                total: p * x * y,
            },
            "{dims:?}"
        );
    }
}

// The identity, which agrees with the transpose only where `i * Y + j == j * X + i`.
#[test]
fn nki_transpose2d_against_the_identity_is_refuted() {
    let identity = TRANSPOSE2D_SPEC
        .replace("out_tensor[P, Y, X]", "out_tensor[P, X, Y]")
        .replace("out_tensor[p, j, i]", "out_tensor[p, i, j]");
    assert_ne!(identity, TRANSPOSE2D_SPEC);
    let verdict = check_transpose2d(&identity, [5, 3, 4]);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

const AVERAGE_POOL2D: &str = include_str!(
    "../../volta_trainium_analysis/tests/fixtures/nki_samples/average_pool2d_nki_kernels.py"
);
const AVERAGE_POOL2D_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/average_pool2d.spec");

/// The average_pool2d tutorial's kernel, from its unmodified file, for a float32
/// `in_tensor` of `[c, h, w]` with `pool_size=s`, against `spec`.
fn check_average_pool2d(spec: &str, [c, h, w, s]: [u64; 4]) -> EquivalenceVerdict {
    let shape: &[u64] = &[c, h, w];
    let shapes = [("in_tensor", shape)];
    let dtypes = [("in_tensor", "float32")];
    let constants = [("pool_size", Constant::Int(s as i64))];
    let call = KernelCall {
        dtypes: &dtypes,
        constants: &constants,
        ..KernelCall::new(&shapes)
    };
    let parsed = parse_kernel_for_call(AVERAGE_POOL2D, &[], "tensor_avgpool_kernel", &call)
        .unwrap_or_else(|e| panic!("{e}"));
    let dims = [
        ("C", c),
        ("H", h),
        ("W", w),
        ("S", s),
        ("HOUT", h / s),
        ("WOUT", w / s),
    ];
    against_spec(
        &parsed,
        spec,
        &dims,
        "out_tensor",
        &EquivCheckOptions::default(),
    )
}

// At the drivers' 2 x 6 x 6 with 2 x 2 windows, then 4 x 4 windows of a non-square input.
// The kernel scales each window's sum by the float `1.0 / (pool_size * pool_size)`, the
// mean exactly only where that is: pool sizes that are powers of two.
#[test]
fn nki_average_pool2d_matches_its_specification() {
    for dims @ [c, h, w, s] in [[2, 6, 6, 2], [3, 8, 12, 4]] {
        let outputs = c * (h / s) * (w / s);
        assert_eq!(
            check_average_pool2d(AVERAGE_POOL2D_SPEC, dims),
            EquivalenceVerdict::Equivalent {
                checked: outputs,
                total: outputs,
            },
            "{dims:?}"
        );
    }
}

// The window sum undivided, and overlapping windows one element apart.
#[test]
fn nki_average_pool2d_against_unscaled_or_overlapping_windows_is_refuted() {
    let unscaled = AVERAGE_POOL2D_SPEC.replace(" / (S * S);", ";");
    let overlapping = AVERAGE_POOL2D_SPEC.replace("[c, i * S + a, j * S + b]", "[c, i + a, j + b]");
    for spec in [unscaled, overlapping] {
        assert_ne!(spec, AVERAGE_POOL2D_SPEC);
        let verdict = check_average_pool2d(&spec, [2, 6, 6, 2]);
        assert!(
            matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
            "expected a confirmed difference, got {verdict:?}"
        );
    }
}

const MAMBA: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/nki_samples/mamba_nki_kernels.py");
const MAMBA_SPEC: &str = include_str!("../../volta_trainium_analysis/tests/fixtures/mamba.spec");

/// The fused_mamba tutorial's kernels, in its order.
const MAMBAS: [&str; 3] = ["mamba_v1", "mamba_v2", "mamba_v3"];

/// The tutorial's file with v3's sequence tile, `seq_len_fsize = 512` ("decided through
/// empirical profiling"), stated as the tile size it equals on the hardware, so reduced
/// tile sizes give v3 several sequence tiles.
fn tileable_mambas() -> String {
    let literal = "seq_len_fsize = 512\n";
    assert_eq!(MAMBA.matches(literal).count(), 1);
    MAMBA.replace(literal, "seq_len_fsize = nl.tile_size.gemm_moving_fmax\n")
}

/// Mamba `kernel` of `source`, its arguments float32 as the drivers make them, for `delta`
/// and `u` of `[batch, channels, seq_len]`, `A` of `[channels, state]` and `B` and `C` of
/// `[batch, state, seq_len]`, run.
fn mamba(
    source: &str,
    kernel: &str,
    tile_sizes: TileSizes,
    [batch, channels, seq_len, state]: [u64; 4],
) -> SymbolicOutputs {
    evaluate(
        &lower_kernel(&parse_mamba(
            source,
            kernel,
            tile_sizes,
            [batch, channels, seq_len, state],
        ))
        .unwrap(),
    )
    .unwrap()
}

fn parse_mamba(
    source: &str,
    kernel: &str,
    tile_sizes: TileSizes,
    [batch, channels, seq_len, state]: [u64; 4],
) -> Kernel {
    let (sequence, a, by_state): (&[u64], &[u64], &[u64]) = (
        &[batch, channels, seq_len],
        &[channels, state],
        &[batch, state, seq_len],
    );
    let shapes = [
        ("delta", sequence),
        ("u", sequence),
        ("A", a),
        ("B", by_state),
        ("C", by_state),
    ];
    let dtypes = ["delta", "u", "A", "B", "C"].map(|param| (param, "float32"));
    let call = KernelCall {
        dtypes: &dtypes,
        tile_sizes,
        ..KernelCall::new(&shapes)
    };
    parse_kernel_for_call(source, &[], kernel, &call).unwrap_or_else(|e| panic!("{kernel}: {e}"))
}

/// `outputs`' `output` against `spec` at `[batch, channels, seq_len, state]`.
fn mamba_against(
    spec: &str,
    outputs: &SymbolicOutputs,
    [batch, channels, seq_len, state]: [u64; 4],
) -> EquivalenceVerdict {
    let dims = [
        ("BATCH", batch),
        ("CH", channels),
        ("L", seq_len),
        ("N", state),
    ]
    .map(|(dim, value)| (dim.to_string(), value))
    .into();
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();
    check_equivalence(
        &reference,
        outputs,
        &["output".into()],
        &EquivCheckOptions::default(),
    )
    .0
}

/// Two batches, two channel tiles of `pmax` 64 (v1 and v2 assert 128 channels per tile
/// group, literally), two states, and for v3 two sequence tiles of 4.
const MAMBA_TILES: TileSizes = reduced_tiles(64, 4);
const MAMBA_DIMS: [u64; 4] = [2, 128, 8, 2];

// At the hardware's tile sizes the stated tile is the literal one, so the tileable file
// parses to exactly the tutorial's kernels.
#[test]
fn nki_mamba_tileable_kernels_are_the_tutorials_at_full_size() {
    let tileable = tileable_mambas();
    let dims = [1, 128, 1024, 1];
    for kernel in MAMBAS {
        assert_eq!(
            parse_mamba(&tileable, kernel, TileSizes::HARDWARE, dims),
            parse_mamba(MAMBA, kernel, TileSizes::HARDWARE, dims),
            "{kernel}"
        );
    }
}

#[test]
fn nki_mambas_match_their_specification_and_each_other_at_reduced_tile_sizes() {
    let tileable = tileable_mambas();
    let [batch, channels, seq_len, _] = MAMBA_DIMS;
    let outputs = batch * channels * seq_len;
    let equivalent = EquivalenceVerdict::Equivalent {
        checked: outputs,
        total: outputs,
    };
    let runs = MAMBAS.map(|kernel| mamba(&tileable, kernel, MAMBA_TILES, MAMBA_DIMS));
    for (kernel, run) in MAMBAS.iter().zip(&runs) {
        assert_eq!(
            mamba_against(MAMBA_SPEC, run, MAMBA_DIMS),
            equivalent,
            "{kernel}"
        );
    }
    for pair in [[0, 1], [1, 2]] {
        let [before, after] = pair.map(|i| &runs[i]);
        assert_eq!(
            check_equivalence(
                before,
                after,
                &["output".into()],
                &EquivCheckOptions::default()
            )
            .0,
            equivalent,
            "{} against {}",
            MAMBAS[pair[1]],
            MAMBAS[pair[0]]
        );
    }
}

// The decay over one step too many (from `delta[s]` on), and the scan without its
// recurrence (`s = t` only); and v3 restarting each sequence tile's scan from zero.
#[test]
fn nki_mambas_against_a_shifted_decay_a_missing_scan_or_a_dropped_carry_are_refuted() {
    let shifted = MAMBA_SPEC.replace("r in s + 1..t + 1", "r in s..t + 1");
    let unscanned = MAMBA_SPEC.replace("s in 0..t + 1", "s in t..t + 1");
    let tileable = tileable_mambas();
    let refuted = |verdict: EquivalenceVerdict| {
        assert!(
            matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
            "expected a confirmed difference, got {verdict:?}"
        );
    };
    for spec in [&shifted, &unscanned] {
        assert_ne!(spec, MAMBA_SPEC);
        for kernel in MAMBAS {
            refuted(mamba_against(
                spec,
                &mamba(&tileable, kernel, MAMBA_TILES, MAMBA_DIMS),
                MAMBA_DIMS,
            ));
        }
    }
    let carry = "initial=scan_init,";
    assert_eq!(tileable.matches(carry).count(), 1);
    let restarting = tileable.replace(carry, "initial=0.0,");
    let run = mamba(&restarting, "mamba_v3", MAMBA_TILES, MAMBA_DIMS);
    refuted(mamba_against(MAMBA_SPEC, &run, MAMBA_DIMS));
}

const TENSOR_INDIRECTION: &str = include_str!(
    "../../volta_trainium_analysis/tests/fixtures/nki_samples/tensor_indirection_nki_kernels.py"
);
const TENSOR_INDIRECTION_SPEC: &str =
    include_str!("../../volta_trainium_analysis/tests/fixtures/tensor_indirection.spec");

/// The tensor indirection tutorial's kernel, from its unmodified file, run on `data_tensor`
/// of `[data_p, data_f]` with `index_tensor` holding `offsets`, as its driver's
/// `torch.randint` draws them.
fn tensor_indirection(data: [u64; 2], offsets: &[u64]) -> SymbolicOutputs {
    let index: [u64; 2] = [1, offsets.len() as u64];
    let shapes: [(&str, &[u64]); 2] = [("index_tensor", &index), ("data_tensor", &data)];
    let call = KernelCall {
        contents: &[("index_tensor", offsets)],
        ..KernelCall::new(&shapes)
    };
    let parsed =
        parse_kernel_for_call(TENSOR_INDIRECTION, &[], "tensor_indirection_kernel", &call).unwrap();
    evaluate(&lower_kernel(&parsed).unwrap()).unwrap()
}

/// `outputs`' `out_tensor` against `spec` at `[data_p, data_f]`, its index array holding
/// `offsets`.
fn tensor_indirection_against(
    spec: &str,
    outputs: &SymbolicOutputs,
    [data_p, data_f]: [u64; 2],
    offsets: &[u64],
) -> EquivalenceVerdict {
    let dims = [
        ("DATA_P", data_p),
        ("DATA_F", data_f),
        ("INDEX_F", offsets.len() as u64),
        ("ONE", 1),
    ]
    .map(|(dim, value)| (dim.to_string(), value))
    .into();
    let offsets = offsets.iter().map(|&offset| offset as i64).collect();
    let indices = [("index_tensor".to_string(), offsets)].into();
    let reference =
        volta_spec::extract_expressions_from_spec_with_indices(spec, &dims, &indices).unwrap();
    check_equivalence(
        &reference,
        outputs,
        &["out_tensor".into()],
        &EquivCheckOptions::default(),
    )
    .0
}

/// `count` offsets below `data_f` from a fixed linear congruential sequence, with repeats.
fn drawn_offsets(count: usize, data_f: u64, seed: u64) -> Vec<u64> {
    let mut state = seed;
    (0..count)
        .map(|_| {
            state = state
                .wrapping_mul(6364136223846793005)
                .wrapping_add(1442695040888963407);
            (state >> 33) % data_f
        })
        .collect()
}

/// The driver's `DATA_P`, `DATA_F` and `INDEX_F`.
const INDIRECTION_DATA: [u64; 2] = [128, 64];
const INDIRECTION_INDEX_F: usize = 32;

#[test]
fn nki_tensor_indirection_matches_its_specification_at_its_drivers_size() {
    let [data_p, data_f] = INDIRECTION_DATA;
    let extremes: Vec<u64> = (0..INDIRECTION_INDEX_F as u64)
        .map(|i| if i % 2 == 0 { data_f - 1 } else { 0 })
        .collect();
    for offsets in [
        drawn_offsets(INDIRECTION_INDEX_F, data_f, 1),
        drawn_offsets(INDIRECTION_INDEX_F, data_f, 2),
        extremes,
    ] {
        let outputs = data_p * offsets.len() as u64;
        assert_eq!(
            tensor_indirection_against(
                TENSOR_INDIRECTION_SPEC,
                &tensor_indirection(INDIRECTION_DATA, &offsets),
                INDIRECTION_DATA,
                &offsets
            ),
            EquivalenceVerdict::Equivalent {
                checked: outputs,
                total: outputs
            },
            "{offsets:?}"
        );
    }
}

// One 16-partition group and one index column, then three of each.
#[test]
fn nki_tensor_indirection_matches_its_specification_at_other_sizes() {
    for (data, index_f) in [([16, 8], 16), ([48, 20], 48)] {
        let offsets = drawn_offsets(index_f, data[1], 3);
        let outputs = data[0] * index_f as u64;
        assert_eq!(
            tensor_indirection_against(
                TENSOR_INDIRECTION_SPEC,
                &tensor_indirection(data, &offsets),
                data,
                &offsets
            ),
            EquivalenceVerdict::Equivalent {
                checked: outputs,
                total: outputs
            },
            "{data:?}"
        );
    }
}

#[test]
fn nki_tensor_indirection_against_another_offset_or_no_gather_is_refuted() {
    let offsets = drawn_offsets(INDIRECTION_INDEX_F, INDIRECTION_DATA[1], 1);
    let outputs = tensor_indirection(INDIRECTION_DATA, &offsets);
    let refuted = |verdict: EquivalenceVerdict| {
        assert!(
            matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
            "expected a confirmed difference, got {verdict:?}"
        );
    };

    let mut moved = offsets.clone();
    moved[17] = (moved[17] + 1) % INDIRECTION_DATA[1];
    refuted(tensor_indirection_against(
        TENSOR_INDIRECTION_SPEC,
        &outputs,
        INDIRECTION_DATA,
        &moved,
    ));

    let ungathered =
        TENSOR_INDIRECTION_SPEC.replace("data_tensor[p, index_tensor[0, i]]", "data_tensor[p, i]");
    assert_ne!(ungathered, TENSOR_INDIRECTION_SPEC);
    let ungathered = ungathered.replace("array index_tensor[ONE, INDEX_F] index;", "");
    let dims = [
        ("DATA_P", INDIRECTION_DATA[0]),
        ("DATA_F", INDIRECTION_DATA[1]),
        ("INDEX_F", INDIRECTION_INDEX_F as u64),
        ("ONE", 1),
    ]
    .map(|(dim, value)| (dim.to_string(), value))
    .into();
    let reference = volta_spec::extract_expressions_from_spec(&ungathered, &dims).unwrap();
    refuted(
        check_equivalence(
            &reference,
            &outputs,
            &["out_tensor".into()],
            &EquivCheckOptions::default(),
        )
        .0,
    );
}
