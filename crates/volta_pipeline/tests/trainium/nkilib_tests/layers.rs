//! Core nkilib kernels of a transformer layer found correct, on one core and unquantized:
//! `RoPE` and `rope_hf`, `output_projection_cte`, and `qkv`'s token generation path. Each is
//! proved equal to its spec on every element and race free under the baseline.

use volta_pipeline::EquivalenceVerdict;
use volta_trainium_analysis::{OrderingPolicy, evaluate};

use super::Arg::Tensor as T;
use super::{assert_proved, lowered, spec, verdict};

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
