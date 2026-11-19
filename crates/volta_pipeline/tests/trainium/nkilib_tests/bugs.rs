//! The bugs Volta found, each failing at the call that shows it, and the same call with the
//! proposed fix `fixes.py` applies proved equal to its spec and race free.

use volta_expr::SymbolicOutputs;
use volta_pipeline::EquivalenceVerdict;
use volta_trainium_analysis::{EvalError, evaluate, evaluate_sharing_aliases};

use super::{Arg, WAW, assert_proved, conv_args, conv_dims, lowered, pool_bounds, spec, verdict};

fn refuted_count(verdict: EquivalenceVerdict) -> usize {
    match verdict {
        EquivalenceVerdict::Refuted { elements } => elements.len(),
        other => panic!("expected a refutation, got {other:?}"),
    }
}

/// `max_pooling_3d` on `[1, 2, 5, 6, 7]`, kernel 2, stride 1, padding 1: its `out`, the spec's,
/// and the kernel's arguments.
fn max_pooling_call() -> (SymbolicOutputs, Vec<Arg>) {
    let input = [5, 6, 7];
    let mut dims = vec![("B", 1), ("C", 2), ("D", 5), ("H", 6), ("W", 7)];
    let mut indices = vec![];
    for ((axis, out_dim), &extent) in ["D", "H", "W"].iter().zip(["OD", "OH", "OW"]).zip(&input) {
        let (out, [low, high]) = pool_bounds(extent, 2, 1, 1);
        dims.push((out_dim, out));
        indices.push((["L", axis].concat(), low));
        indices.push((["H", axis].concat(), high));
    }
    let indices: Vec<(&str, Vec<i64>)> = indices
        .iter()
        .map(|(a, v)| (a.as_str(), v.clone()))
        .collect();
    let args = vec![
        Arg::Tensor("src_tensor", vec![1, 2, 5, 6, 7]),
        Arg::Int("kernel_size", 2),
        Arg::Int("stride", 1),
        Arg::Int("padding", 1),
    ];
    (spec("max_pooling_3d.spec", &dims, &indices), args)
}

/// F7: padding grows each axis's output, so the reduce scope's two ping-pong sections no longer
/// fit: axis 2's output reuses axis 0's bytes and overruns axis 1's while it is still read.
#[test]
fn nkilib_max_pooling_3d_overwrites_a_tile_it_still_reads_when_padding_grows_the_output() {
    let (spec, args) = max_pooling_call();
    let kernel = lowered("max_pooling_3d.py", &args);
    assert!(matches!(
        evaluate(&kernel),
        Err(EvalError::ClobberedRead { .. })
    ));
    let shared = evaluate_sharing_aliases(&kernel).unwrap();
    assert_eq!(refuted_count(verdict(&spec, &shared, "out")), 40);
}

#[test]
fn nkilib_max_pooling_3d_with_a_section_per_axis_matches_max_pool3d() {
    let (spec, args) = max_pooling_call();
    assert_proved(
        WAW,
        &lowered("max_pooling_3d_fixed.py", &args),
        &spec,
        "out",
    );
}

/// `conv3d` on `[1, 130, 1, 3, 4]` (the fallback path, `C_in > 64`) with a 1 x 1 x 1 filter
/// and W padding: the spec's `conv_out` and the kernel's arguments.
fn conv3d_call(padding: [u64; 6]) -> (SymbolicOutputs, Vec<Arg>) {
    let (x, f) = ([1, 130, 1, 3, 4], [1, 1, 1, 130, 2]);
    let dims = conv_dims(x, f, [1; 3], padding, [1; 3]);
    let mut args = conv_args(x, f, [1; 3], padding, [1; 3]);
    args.push(Arg::Tensor("bias", vec![2]));
    (spec("conv3d.spec", &dims, &[]), args)
}

const CONV3D_PADDINGS: [[u64; 6]; 2] = [[0, 0, 0, 0, 0, 2], [1, 1, 0, 2, 0, 2]];

/// F9: the padding-only columns between a tap's rows count as written, so they are neither
/// filled nor computed, and stale PSUM reaches `conv_out`.
#[test]
fn nkilib_conv3d_outputs_unwritten_psum_where_w_padding_outruns_the_filter() {
    for padding in CONV3D_PADDINGS {
        let (_, args) = conv3d_call(padding);
        let run = evaluate(&lowered("conv3d.py", &args));
        assert!(
            matches!(run, Err(EvalError::UninitializedRead { .. })),
            "padding {padding:?}: {run:?}"
        );
    }
}

#[test]
fn nkilib_conv3d_marking_each_taps_rectangle_matches_conv3d() {
    for padding in CONV3D_PADDINGS {
        let (spec, args) = conv3d_call(padding);
        assert_proved(WAW, &lowered("conv3d_fixed.py", &args), &spec, "conv_out");
    }
}

/// `conv3d_bwd`'s `dx` at stride 1 with `C_out = 130` (its col2im path) on input `x`, cubic
/// filter side `k`, padding `pad` on every side: the spec's `dx` and the kernel's arguments.
/// `MD`, `MH` and `MW` map a padded `dy` coordinate to its output position, or `-1`.
fn conv3d_dx_call(x: [u64; 5], k: u64, pad: u64) -> (SymbolicOutputs, Vec<Arg>) {
    let f = [k, k, k, x[1], 130];
    let mut dims = conv_dims(x, f, [1; 3], [pad; 6], [1; 3]);
    let out = x.map(|extent| extent + 2 * pad - (k - 1));
    let mut indices = vec![];
    for (i, (map_name, size_name)) in [("MD", "ZD"), ("MH", "ZH"), ("MW", "ZW")]
        .into_iter()
        .enumerate()
    {
        let (reach, out) = ((k - 1) as i64, out[2 + i] as i64);
        let map: Vec<i64> = (0..(x[2 + i] + pad + k - 1) as i64)
            .map(|q| {
                if reach <= q && q - reach < out {
                    q - reach
                } else {
                    -1
                }
            })
            .collect();
        dims.push((size_name, map.len() as u64));
        indices.push((map_name, map));
    }
    let mut args = vec![Arg::Tensor("dy", vec![x[0], 130, out[2], out[3], out[4]])];
    args.extend(conv_args(x, f, [1; 3], [pad; 6], [1; 3]));
    (spec("conv3d_bwd.spec", &dims, &indices), args)
}

/// F11: with one output depth plane, col2im's 2-D branch runs although depth matters: it
/// reads only the `kd = 0` filter taps and writes only `dx`'s plane 0.
#[test]
fn nkilib_conv3d_bwd_dx_ignores_depth_when_the_output_has_one_depth_plane() {
    // One frame, a 3 x 3 x 3 filter, padding 1: the gradient needs the kd = 1 taps.
    let (spec, args) = conv3d_dx_call([1, 2, 1, 4, 4], 3, 1);
    let run = evaluate(&lowered("conv3d_bwd_dx.py", &args)).unwrap();
    assert_eq!(refuted_count(verdict(&spec, &run, "dx")), 32);

    // Two frames, a 2 x 2 x 2 filter: plane 1 of dx is never written.
    let (_, args) = conv3d_dx_call([1, 2, 2, 4, 4], 2, 0);
    let run = evaluate(&lowered("conv3d_bwd_dx.py", &args)).unwrap();
    let written: Vec<u64> = run.outputs[0].1.iter().map(|&(index, _)| index).collect();
    assert_eq!(
        written,
        (0..2).flat_map(|c| 32 * c..32 * c + 16).collect::<Vec<_>>()
    );
}

#[test]
fn nkilib_conv3d_bwd_dx_taking_the_3d_branch_when_depth_matters_matches_the_gradient() {
    for (x, k, pad) in [([1, 2, 1, 4, 4], 3, 1), ([1, 2, 2, 4, 4], 2, 0)] {
        let (spec, args) = conv3d_dx_call(x, k, pad);
        assert_proved(WAW, &lowered("conv3d_bwd_dx_fixed.py", &args), &spec, "dx");
    }
}

/// `conv3d_temporal_unroll` on `[1, 65, 6, 1, 513]` (its intended range: `C_in` 65 to 128,
/// `W_out` above 512) with a 2 x 1 x 1 filter and depth dilation 2.
fn temporal_unroll_call() -> (SymbolicOutputs, Vec<Arg>) {
    let (x, f, dl) = ([1, 65, 6, 1, 513], [2, 1, 1, 65, 1], [2, 1, 1]);
    let dims = conv_dims(x, f, [1; 3], [0; 6], dl);
    let mut args = conv_args(x, f, [1; 3], [0; 6], dl);
    args.push(Arg::Tensor("bias", vec![1]));
    (spec("conv3d.spec", &dims, &[]), args)
}

/// F12: an input plane's depth tap is computed from `d_in * dilation_d`, so under dilation
/// every output plane reads the wrong planes or none.
#[test]
fn nkilib_conv3d_temporal_unroll_mismaps_depth_taps_under_dilation() {
    let (spec, args) = temporal_unroll_call();
    let run = evaluate(&lowered("conv3d_temporal_unroll.py", &args)).unwrap();
    assert_eq!(refuted_count(verdict(&spec, &run, "y_out")), 4 * 513);
}

#[test]
fn nkilib_conv3d_temporal_unroll_with_undilated_input_planes_matches_conv3d() {
    let (spec, args) = temporal_unroll_call();
    assert_proved(
        WAW,
        &lowered("conv3d_temporal_unroll_fixed.py", &args),
        &spec,
        "y_out",
    );
}
