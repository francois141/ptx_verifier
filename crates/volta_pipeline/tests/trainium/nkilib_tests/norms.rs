//! Normalizations and scans found correct: `rmsnorm_tkg` and `layernorm_tkg` (one core),
//! `rmsnorm_quant` with static quantization, `cumsum`, and the experimental `linear_scan`,
//! `selective_scan` and `ssd`.

use volta_pipeline::EquivalenceVerdict;
use volta_trainium_analysis::{OrderingPolicy, evaluate};

use super::{Arg, WAW, assert_proved, assert_same, lowered, spec, verdict};

const BASELINE: OrderingPolicy = OrderingPolicy::BASELINE;

fn refuted_count(verdict: EquivalenceVerdict) -> usize {
    match verdict {
        EquivalenceVerdict::Refuted { elements } => elements.len(),
        other => panic!("expected a refutation, got {other:?}"),
    }
}

/// A `_tkg` normalization's `input` of `[batch, seq, hidden]` with `gamma`, and `options`: the
/// arguments, then the spec dims (`output` is `[128, batch * seq, hidden / 128]`).
fn norm_call(
    [batch, seq, hidden]: [u64; 3],
    options: Vec<Arg>,
) -> (Vec<Arg>, Vec<(&'static str, u64)>) {
    let (tokens, h1) = (batch * seq, hidden / 128);
    let mut args = vec![
        Arg::Tensor("input", vec![batch, seq, hidden]),
        Arg::Tensor("gamma", vec![1, hidden]),
        Arg::Tensor("output", vec![128, tokens, h1]),
    ];
    args.extend(options);
    let dims = vec![
        ("T", tokens),
        ("H", hidden),
        ("H0", 128),
        ("H1", h1),
        ("ONE", 1),
    ];
    (args, dims)
}

/// Hidden sizes that are powers of two, where the kernel's `1 / H` is exact, and 384, where
/// the spec multiplies by the kernel's rounded double instead.
#[test]
fn nkilib_rmsnorm_tkg_matches_rms_norm() {
    for (shape, spec_file) in [
        ([1, 4, 256], "rmsnorm_tkg.spec"),
        ([1, 1, 128], "rmsnorm_tkg.spec"),
        ([2, 80, 256], "rmsnorm_tkg.spec"),
        ([3, 5, 384], "rmsnorm_tkg_384.spec"),
    ] {
        let (args, dims) = norm_call(shape, vec![]);
        let kernel = lowered("rmsnorm_tkg.py", &args);
        assert_proved(BASELINE, &kernel, &spec(spec_file, &dims, &[]), "output");
    }
}

#[test]
fn nkilib_rmsnorm_tkg_with_hidden_dim_tp_matches_rms_norm() {
    for (shape, spec_file) in [
        ([1, 4, 256], "rmsnorm_tkg_tp.spec"),
        ([3, 5, 384], "rmsnorm_tkg_tp_384.spec"),
    ] {
        let (args, dims) = norm_call(shape, vec![Arg::Bool("hidden_dim_tp", true)]);
        let kernel = lowered("rmsnorm_tkg.py", &args);
        assert_proved(BASELINE, &kernel, &spec(spec_file, &dims, &[]), "output");
    }
}

#[test]
fn nkilib_rmsnorm_tkg_with_hidden_actual_matches_rms_norm() {
    let (args, dims) = norm_call([1, 3, 256], vec![Arg::Int("hidden_actual", 200)]);
    let kernel = lowered("rmsnorm_tkg.py", &args);
    let spec = spec("rmsnorm_tkg_padded.spec", &dims, &[]);
    assert_proved(BASELINE, &kernel, &spec, "output");
}

/// The default layout against the `hidden_dim_tp` one: only the 8 elements whose hidden index
/// is the same in both layouts agree.
#[test]
fn nkilib_rmsnorm_tkg_refutes_the_other_layout() {
    let (args, dims) = norm_call([1, 4, 256], vec![]);
    let outputs = evaluate(&lowered("rmsnorm_tkg.py", &args)).unwrap();
    let spec = spec("rmsnorm_tkg_tp.spec", &dims, &[]);
    assert_eq!(refuted_count(verdict(&spec, &outputs, "output")), 1016);
}

#[test]
fn nkilib_layernorm_tkg_matches_layer_norm() {
    for shape in [[1, 4, 256], [3, 2, 128]] {
        let (mut args, dims) = norm_call(shape, vec![]);
        args.push(Arg::Tensor("beta", vec![1, shape[2]]));
        let kernel = lowered("layernorm_tkg.py", &args);
        let spec = spec("layernorm_tkg.spec", &dims, &[]);
        assert_proved(BASELINE, &kernel, &spec, "output");
    }
}

/// `cumsum` of `x` (`dtype`), with tile sizes `[p_max, f_tile_size]` if given, and the spec dims
/// of its `[rows, columns]` view.
fn cumsum_call(
    shape: &[u64],
    dtype: &'static str,
    tiles: Option<[i64; 2]>,
) -> (Vec<Arg>, Vec<(&'static str, u64)>) {
    let mut args = vec![Arg::TensorOf("x", shape.to_vec(), dtype)];
    if let Some([p_max, f_tile_size]) = tiles {
        args.push(Arg::Int("p_max", p_max));
        args.push(Arg::Int("f_tile_size", f_tile_size));
    }
    let (columns, rows) = shape.split_last().unwrap();
    let dims = vec![("R", rows.iter().product()), ("C", *columns)];
    (args, dims)
}

/// Tiles of 4 rows and 8 columns, so small inputs cross row and column tiles with uneven
/// tails, on the float path (`tensor_scalar_cumulative`) and the int32 one (`tensor_tensor_scan`),
/// then hardware tile sizes.
#[test]
fn nkilib_cumsum_matches_a_running_sum() {
    let small = Some([4, 8]);
    for (shape, dtype, tiles) in [
        (&[10, 21][..], "float32", small),
        (&[10, 21], "int32", small),
        (&[3, 2, 17], "float32", small),
        (&[8, 16], "float32", small),
        (&[1, 1], "float32", small),
        (&[4, 8], "float32", None),
        (&[2, 3, 600], "float32", None),
    ] {
        let (args, dims) = cumsum_call(shape, dtype, tiles);
        let kernel = lowered("cumsum.py", &args);
        assert_proved(BASELINE, &kernel, &spec("cumsum.spec", &dims, &[]), "y");
    }
}

#[test]
fn nkilib_cumsum_refutes_an_exclusive_scan() {
    let (args, dims) = cumsum_call(&[10, 21], "float32", Some([4, 8]));
    let outputs = evaluate(&lowered("cumsum.py", &args)).unwrap();
    let spec = spec("cumsum_exclusive.spec", &dims, &[]);
    assert_eq!(refuted_count(verdict(&spec, &outputs, "y")), 210);
}

/// Free tiles of 3 elements against the kernel's 2048, so the carry crosses tiles.
#[test]
fn nkilib_linear_scan_with_small_tiles_matches_itself_untiled() {
    for shape in [&[2, 10][..], &[130, 7], &[3, 2, 8]] {
        let mut initial = shape.to_vec();
        *initial.last_mut().unwrap() = 1;
        for (output, final_state) in [("result", false), ("final_state", true)] {
            let args = |tiles: Vec<Arg>| {
                let mut args = vec![
                    Arg::Tensor("decay", shape.to_vec()),
                    Arg::Tensor("data", shape.to_vec()),
                    Arg::Tensor("initial", initial.clone()),
                    Arg::Bool("final", final_state),
                ];
                args.extend(tiles);
                args
            };
            let untiled = lowered("linear_scan.py", &args(vec![]));
            let tiled = lowered("linear_scan.py", &args(vec![Arg::Int("f_tile_size", 3)]));
            assert_same(BASELINE, &untiled, &tiled, output);
        }
    }
}

/// Free tiles of 3 elements, so the state carries across tiles, over one and two 128-channel
/// tiles. Race free once write after write is ordered: `A_block` is zeroed, then loaded.
#[test]
fn nkilib_selective_scan_matches_mambas_recurrence() {
    for [batch, channels, states, length] in [[1, 2, 3, 7], [2, 130, 2, 5]] {
        let dims = [
            ("BD", batch),
            ("CH", channels),
            ("N", states),
            ("L", length),
        ];
        let spec = spec("selective_scan.spec", &dims, &[]);
        for (output, final_state) in [("y", false), ("final_state", true)] {
            let args = [
                Arg::Tensor("x", vec![batch, channels, length]),
                Arg::Tensor("dt", vec![batch, channels, length]),
                Arg::Tensor("A", vec![channels, states]),
                Arg::Tensor("B", vec![batch, states, length]),
                Arg::Tensor("C", vec![batch, states, length]),
                Arg::Tensor("initial_state", vec![batch, channels, states]),
                Arg::Int("f_tile_size", 3),
                Arg::Bool("final", final_state),
            ];
            assert_proved(WAW, &lowered("selective_scan.py", &args), &spec, output);
        }
    }
}

/// Fewer than 8 heads take the head-outer path, 8 heads or a `headdim` past 512 the chunk-outer
/// one; up to two batches and three chunks. `causal_mask` holds the lower-triangular ones.
#[test]
fn nkilib_ssd_matches_mamba2s_recurrence() {
    for [batch, heads, length, headdim, states, chunk] in [
        [1, 2, 4, 3, 2, 2],
        [1, 8, 4, 2, 2, 2],
        [2, 3, 6, 3, 2, 2],
        [1, 2, 4, 515, 2, 2],
    ] {
        let dims = [
            ("BT", batch),
            ("NH", heads),
            ("L", length),
            ("P", headdim),
            ("N", states),
            ("Q", chunk),
        ];
        let spec = spec("ssd.spec", &dims, &[]);
        let tril: Vec<u64> = (0..chunk * chunk)
            .map(|i| u64::from(i % chunk <= i / chunk))
            .collect();
        for (output, final_state) in [("y", false), ("final_state", true)] {
            let args = [
                Arg::Tensor("x", vec![batch, heads, length, headdim]),
                Arg::Tensor("dt", vec![batch, heads, length]),
                Arg::Tensor("A", vec![heads]),
                Arg::Tensor("B", vec![batch, length, states]),
                Arg::Tensor("C", vec![batch, length, states]),
                Arg::Tensor("initial_state", vec![batch, heads, states, headdim]),
                Arg::Filled("causal_mask", vec![chunk, chunk], tril.clone()),
                Arg::Int("chunk_size", chunk as i64),
                Arg::Bool("final", final_state),
            ];
            assert_proved(BASELINE, &lowered("ssd.py", &args), &spec, output);
        }
    }
}

/// Static quantization: RMSNorm, then the clip to float8_e4m3's range, over reals.
#[test]
fn nkilib_rmsnorm_quant_static_matches_clipped_rms_norm() {
    for [b, s, h] in [[1, 4, 256], [2, 3, 128]] {
        let kernel = lowered(
            "rmsnorm_quant.py",
            &[
                Arg::Tensor("hidden", vec![b, s, h]),
                Arg::Tensor("ln_w", vec![1, h]),
                Arg::Tensor("input_dequant_scale", vec![128, 1]),
            ],
        );
        let dims = [("T", b * s), ("H", h), ("ONE", 1), ("P", 128)];
        let spec = spec("rmsnorm_quant_static.spec", &dims, &[]);
        assert_proved(BASELINE, &kernel, &spec, "out");
    }
}
