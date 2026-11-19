//! Bugs Volta found in nkilib's experimental kernels, traced from nki-library at the commit
//! `external/trainium/nkilib/nki-library.commit` names (`just nkilib` fetches it into
//! `target/nkilib`), and their proposed fixes. Each buggy kernel
//! fails at the call that shows its bug (an execution error, or a refutation against its spec
//! in `external/trainium/nkilib/`, the operation of nkilib's own `*_torch.py` reference); the
//! same call with the fix `fixes.py` applies is proved equal to the spec and race free.

use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use volta_equivalence::check::EquivCheckOptions;
use volta_expr::{FullOutputs, SymbolicOutputs};
use volta_graph_check::{GraphConclusion, check_graph};
use volta_pipeline::{EquivalenceVerdict, check_equivalence};
use volta_trainium_analysis::frontend::parse::{Constant, KernelCall};
use volta_trainium_analysis::{
    EvalError, Execution, LoweredKernel, OrderingPolicy, WriteAfterWrite, evaluate,
    evaluate_sharing_aliases, lower_kernel, record_graph,
};

const NKILIB: &str = concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../external/trainium/nkilib"
);

/// The root nki-library's `nkilib` package is imported from: `target/nkilib`'s
/// `src/nkilib_src`, checked once to be at the pinned commit.
fn nkilib_source() -> PathBuf {
    static SOURCE: OnceLock<PathBuf> = OnceLock::new();
    SOURCE
        .get_or_init(|| {
            let clone = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../target/nkilib");
            let pinned = std::fs::read_to_string(Path::new(NKILIB).join("nki-library.commit"))
                .expect("external/trainium/nkilib/nki-library.commit is readable");
            let head = std::fs::read_to_string(clone.join(".git/HEAD")).unwrap_or_default();
            assert!(
                head.trim() == pinned.trim(),
                "the nkilib suite traces nki-library at {}, which `target/nkilib` does not hold. \
                 Run `just nkilib` (or `just trainium`) to fetch it.",
                pinned.trim()
            );
            clone.join("src/nkilib_src")
        })
        .clone()
}

/// The fixed kernels write a tile and overwrite it unread (a `memset` before a copy), which
/// races unless the compiler orders write after write.
const WAW: OrderingPolicy = OrderingPolicy {
    write_after_write: WriteAfterWrite::Ordered,
    ..OrderingPolicy::BASELINE
};

/// One argument of a kernel call: a `float32` tensor's shape, or a constant.
enum Arg {
    Tensor(&'static str, Vec<u64>),
    Int(&'static str, i64),
    Ints(&'static str, Vec<i64>),
}

/// Wrapper `wrapper`'s `kernel` traced for `args` and lowered.
fn lowered(wrapper: &str, args: &[Arg]) -> LoweredKernel {
    let shapes: Vec<(&str, &[u64])> = args
        .iter()
        .filter_map(|arg| match arg {
            Arg::Tensor(name, shape) => Some((*name, shape.as_slice())),
            _ => None,
        })
        .collect();
    let dtypes: Vec<(&str, &str)> = shapes.iter().map(|&(name, _)| (name, "float32")).collect();
    let constants: Vec<(&str, Constant)> = args
        .iter()
        .filter_map(|arg| match arg {
            Arg::Int(name, value) => Some((*name, Constant::Int(*value))),
            Arg::Ints(name, values) => Some((*name, Constant::Ints(values))),
            Arg::Tensor(..) => None,
        })
        .collect();
    let call = KernelCall {
        dtypes: &dtypes,
        constants: &constants,
        ..KernelCall::new(&shapes)
    };
    let file = PathBuf::from(NKILIB).join(wrapper);
    let kernel = crate::common::trainium::tracer()
        .trace(&file, &[nkilib_source()], "kernel", &call)
        .unwrap_or_else(|e| panic!("{wrapper}: {e}"));
    lower_kernel(&kernel).unwrap_or_else(|e| panic!("{wrapper}: {e}"))
}

/// The outputs of spec file `spec` at `dims`, with the index arrays `indices`.
fn spec(spec: &str, dims: &[(&str, u64)], indices: &[(&str, Vec<i64>)]) -> SymbolicOutputs {
    let source = std::fs::read_to_string(PathBuf::from(NKILIB).join(spec)).unwrap();
    let dims: HashMap<String, u64> = dims.iter().map(|&(d, v)| (d.to_string(), v)).collect();
    let indices: HashMap<String, Vec<i64>> = indices
        .iter()
        .map(|(a, v)| (a.to_string(), v.clone()))
        .collect();
    volta_spec::extract_expressions_from_spec_with_indices(&source, &dims, &indices)
        .unwrap()
        .lower()
        .unwrap()
}

fn verdict(spec: &SymbolicOutputs, run: &FullOutputs, array: &str) -> EquivalenceVerdict {
    let run = run.lower().unwrap();
    check_equivalence(spec, &run, &[array.into()], &EquivCheckOptions::default()).0
}

/// The run of `kernel` must complete, race free under `WAW`, and equal `spec` on `array`.
fn assert_fixed(kernel: &LoweredKernel, spec: &SymbolicOutputs, array: &str) {
    let run = evaluate(kernel);
    let graph = record_graph(kernel, WAW, &Execution::of(&run));
    assert_eq!(check_graph(&graph).conclusion(), GraphConclusion::Verified);
    let outputs = run.unwrap();
    let total = spec
        .outputs
        .iter()
        .find(|(name, _)| name == array)
        .map_or(0, |(_, elements)| elements.len() as u64);
    assert_eq!(
        verdict(spec, &outputs, array),
        EquivalenceVerdict::Equivalent {
            checked: total,
            total
        }
    );
}

fn refuted_count(verdict: EquivalenceVerdict) -> usize {
    match verdict {
        EquivalenceVerdict::Refuted { elements } => elements.len(),
        other => panic!("expected a refutation, got {other:?}"),
    }
}

/// Each output position's window `[low, high)` along one axis, clamped to the input:
/// `max_pooling_3d.spec`'s `L` and `H` index arrays.
fn pool_bounds(input: u64, kernel: u64, stride: u64, pad: u64) -> (u64, [Vec<i64>; 2]) {
    let [input, kernel, stride, pad] = [input, kernel, stride, pad].map(|v| v as i64);
    let out = (input + 2 * pad - kernel) / stride + 1;
    let start = |j: i64| j * stride - pad;
    let low = (0..out).map(|j| start(j).max(0)).collect();
    let high = (0..out).map(|j| (start(j) + kernel).min(input)).collect();
    (out as u64, [low, high])
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
    assert_fixed(&lowered("max_pooling_3d_fixed.py", &args), &spec, "out");
}

/// A convolution's spec dims (`conv3d.spec`, `conv3d_bwd.spec`) for input `x`, filters `f`
/// (`[Kd, Kh, Kw, C_in, C_out]`), stride `s`, padding `p` (`[d_lo, d_hi, h_lo, h_hi, w_lo,
/// w_hi]`) and dilation `dl`.
fn conv_dims(
    x: [u64; 5],
    f: [u64; 5],
    s: [u64; 3],
    p: [u64; 6],
    dl: [u64; 3],
) -> Vec<(&'static str, u64)> {
    let out: [u64; 3] = std::array::from_fn(|i| {
        (x[2 + i] + p[2 * i] + p[2 * i + 1] - dl[i] * (f[i] - 1) - 1) / s[i] + 1
    });
    vec![
        ("B", x[0]),
        ("CI", x[1]),
        ("CO", f[4]),
        ("D", x[2]),
        ("H", x[3]),
        ("W", x[4]),
        ("OD", out[0]),
        ("OH", out[1]),
        ("OW", out[2]),
        ("KD", f[0]),
        ("KH", f[1]),
        ("KW", f[2]),
        ("SD", s[0]),
        ("SH", s[1]),
        ("SW", s[2]),
        ("DD", dl[0]),
        ("DH", dl[1]),
        ("DW", dl[2]),
        ("PD", p[0]),
        ("PH", p[2]),
        ("PW", p[4]),
    ]
}

fn conv_args(x: [u64; 5], f: [u64; 5], s: [u64; 3], p: [u64; 6], dl: [u64; 3]) -> Vec<Arg> {
    vec![
        Arg::Tensor("x_in", x.to_vec()),
        Arg::Tensor("filters", f.to_vec()),
        Arg::Ints("stride", s.map(|v| v as i64).to_vec()),
        Arg::Ints("padding", p.map(|v| v as i64).to_vec()),
        Arg::Ints("dilation", dl.map(|v| v as i64).to_vec()),
    ]
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
        assert_fixed(&lowered("conv3d_fixed.py", &args), &spec, "conv_out");
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
        assert_fixed(&lowered("conv3d_bwd_dx_fixed.py", &args), &spec, "dx");
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
    assert_fixed(
        &lowered("conv3d_temporal_unroll_fixed.py", &args),
        &spec,
        "y_out",
    );
}
