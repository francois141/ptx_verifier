//! Core nkilib kernels of a transformer layer found correct, on one core and unquantized:
//! `RoPE` and `rope_hf`, and `output_projection`, `qkv` and `mlp` on both their token
//! generation and context encoding paths. Each is proved equal to its spec on every element and race free
//! under the baseline.

use volta_pipeline::EquivalenceVerdict;
use volta_trainium_analysis::frontend::parse::TileSizes;
use volta_trainium_analysis::{OrderingPolicy, evaluate};

use super::Arg;
use super::Arg::Tensor as T;
use super::{assert_proved, lowered, lowered_at, spec, verdict};

const BASELINE: OrderingPolicy = OrderingPolicy::BASELINE;

#[test]
fn nkilib_rope_matches_rotary_embedding() {
    for [d, b, n, s] in [[128, 1, 2, 4], [64, 2, 1, 3]] {
        let kernel = lowered(
            "rope.py",
            &[
                T("x_in", vec![d, b, n, s]),
                T("cos", vec![d / 2, b, s]),
                T("sin", vec![d / 2, b, s]),
            ],
        );
        let dims = [("TWO", 2), ("HALF", d / 2), ("B", b), ("N", n), ("S", s)];
        assert_proved(BASELINE, &kernel, &spec("rope.spec", &dims, &[]), "x_out");
    }
}

/// The interleaved layout pairs other elements of each head dimension, so every one of the
/// 128 outputs is refuted.
#[test]
fn nkilib_rope_refutes_the_interleaved_layout() {
    let [d, b, n, s] = [64, 1, 1, 2];
    let kernel = lowered(
        "rope.py",
        &[
            T("x_in", vec![d, b, n, s]),
            T("cos", vec![d / 2, b, s]),
            T("sin", vec![d / 2, b, s]),
        ],
    );
    let dims = [("TWO", 2), ("HALF", d / 2), ("B", b), ("N", n), ("S", s)];
    let spec = spec("rope_interleaved.spec", &dims, &[]);
    match verdict(&spec, &evaluate(&kernel).unwrap(), "x_out") {
        EquivalenceVerdict::Refuted { elements } => assert_eq!(elements.len(), 128),
        other => panic!("expected a refutation, got {other:?}"),
    }
}

#[test]
fn nkilib_rope_hf_matches_rotate_half() {
    let [b, qh, kh, s, d] = [1, 2, 1, 128, 64];
    let kernel = lowered(
        "rope_hf.py",
        &[
            T("q", vec![b, qh, s, d]),
            T("k", vec![b, kh, s, d]),
            T("q_out", vec![b, qh, s, d]),
            T("k_out", vec![b, kh, s, d]),
            T("cos", vec![b, s, d]),
            T("sin", vec![b, s, d]),
        ],
    );
    let dims = [
        ("B", b),
        ("QH", qh),
        ("KH", kh),
        ("S", s),
        ("TWO", 2),
        ("HALF", d / 2),
    ];
    let spec = spec("rope_hf.spec", &dims, &[]);
    assert_proved(BASELINE, &kernel, &spec, "q_out");
    assert_proved(BASELINE, &kernel, &spec, "k_out");
}

#[test]
fn nkilib_output_projection_cte_matches_the_product() {
    let [b, n, d, s, h] = [1, 2, 128, 128, 128];
    let kernel = lowered(
        "output_projection_cte.py",
        &[
            T("attention", vec![b, n, d, s]),
            T("weight", vec![n * d, h]),
        ],
    );
    let dims = [("B", b), ("N", n), ("D", d), ("S", s), ("H", h)];
    assert_proved(
        BASELINE,
        &kernel,
        &spec("output_projection.spec", &dims, &[]),
        "out",
    );
}

/// Two query heads and one key and one value head of 128: `I` is 512.
#[test]
fn nkilib_qkv_tkg_matches_the_product() {
    let [b, s, h, i] = [1, 4, 512, 512];
    let kernel = lowered(
        "qkv.py",
        &[
            T("input", vec![b, s, h]),
            T("fused_qkv_weights", vec![h, i]),
        ],
    );
    let dims = [("B", b), ("S", s), ("H", h), ("I", i)];
    assert_proved(BASELINE, &kernel, &spec("qkv.spec", &dims, &[]), "out");
}

#[test]
fn nkilib_output_projection_tkg_matches_the_product() {
    let [b, n, d, s, h] = [1, 2, 128, 4, 512];
    let kernel = lowered(
        "output_projection_tkg.py",
        &[
            T("attention", vec![d, b, n, s]),
            T("weight", vec![n * d, h]),
        ],
    );
    let dims = [("B", b), ("N", n), ("D", d), ("S", s), ("H", h)];
    assert_proved(
        BASELINE,
        &kernel,
        &spec("output_projection_tkg.spec", &dims, &[]),
        "out",
    );
}

/// `qkv`'s context encoding path, from 128 tokens on.
#[test]
fn nkilib_qkv_cte_matches_the_product() {
    let [b, s, h, i] = [1, 128, 128, 512];
    let kernel = lowered(
        "qkv.py",
        &[
            T("input", vec![b, s, h]),
            T("fused_qkv_weights", vec![h, i]),
        ],
    );
    let dims = [("B", b), ("S", s), ("H", h), ("I", i)];
    assert_proved(BASELINE, &kernel, &spec("qkv.spec", &dims, &[]), "out");
}

/// `mlp` at a 224 KiB SBUF partition: it sizes its own heap past `HARDWARE`'s 192 KiB.
const MLP_SBUF: TileSizes = TileSizes {
    sbuf_fmax_bytes: 224 * 1024,
    ..TileSizes::HARDWARE
};

/// `mlp`'s call at `[b, s, h]` with an intermediate of `i`, proved equal to `mlp.spec`. Each
/// output sums `i` SiLU fractions over different denominators, which the decision procedure
/// puts over one: past a few, the VC outgrows its budget, so `i` stays small.
fn assert_mlp_proved([b, s, h, i]: [u64; 4], force_cte_mode: bool) {
    let kernel = lowered_at(
        "mlp.py",
        &[
            T("hidden", vec![b, s, h]),
            T("gate_w", vec![h, i]),
            T("up_w", vec![h, i]),
            T("down_w", vec![i, h]),
            Arg::Bool("force_cte_mode", force_cte_mode),
        ],
        MLP_SBUF,
    );
    let dims = [("T", b * s), ("H", h), ("I", i)];
    assert_proved(BASELINE, &kernel, &spec("mlp.spec", &dims, &[]), "out");
}

/// Token generation, up to 96 tokens; `H` must be a multiple of 128.
#[test]
fn nkilib_mlp_tkg_matches_the_gated_projection() {
    assert_mlp_proved([1, 1, 128, 2], false);
}

/// Context encoding, forced at 4 tokens.
#[test]
fn nkilib_mlp_cte_matches_the_gated_projection() {
    assert_mlp_proved([1, 4, 128, 2], true);
}

/// Context encoding as `mlp` picks it, past 96 tokens: about 2.5 minutes.
#[test]
#[ignore]
fn nkilib_mlp_cte_on_97_tokens_matches_the_gated_projection() {
    assert_mlp_proved([1, 97, 128, 1], false);
}
