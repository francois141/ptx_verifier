//! nkilib's kernels, traced from nki-library at the commit
//! `external/trainium/nkilib/nki-library.commit` names (`just nkilib` fetches it into
//! `target/nkilib`) through the wrappers in `external/trainium/nkilib/`, and checked against
//! specs there, each the operation of nkilib's own `*_torch.py` reference. `bugs` holds the
//! bugs Volta found and their fixes; the other modules, kernels found correct.

mod bugs;
mod conv;
mod elementwise;
mod norms;
mod pooling;

use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use volta_equivalence::check::EquivCheckOptions;
use volta_expr::{FullOutputs, SymbolicOutputs};
use volta_graph_check::{GraphConclusion, check_graph};
use volta_pipeline::{EquivalenceVerdict, check_equivalence};
use volta_trainium_analysis::frontend::parse::{Constant, KernelCall, TileSizes};
use volta_trainium_analysis::{
    Execution, LoweredKernel, OrderingPolicy, WriteAfterWrite, evaluate, lower_kernel, record_graph,
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

/// Many kernels write a tile and overwrite it unread (a `memset` before a copy), which races
/// unless the compiler orders write after write.
const WAW: OrderingPolicy = OrderingPolicy {
    write_after_write: WriteAfterWrite::Ordered,
    ..OrderingPolicy::BASELINE
};

/// One argument of a kernel call: a tensor's shape (`float32` unless given), the elements
/// of a `float32` tensor whose values the call fixes (row-major), or a constant.
enum Arg {
    Tensor(&'static str, Vec<u64>),
    TensorOf(&'static str, Vec<u64>, &'static str),
    Filled(&'static str, Vec<u64>, Vec<u64>),
    Int(&'static str, i64),
    Ints(&'static str, Vec<i64>),
    Bool(&'static str, bool),
}

/// Wrapper `wrapper`'s `kernel` traced for `args` at hardware tile sizes and lowered.
fn lowered(wrapper: &str, args: &[Arg]) -> LoweredKernel {
    lowered_at(wrapper, args, TileSizes::HARDWARE)
}

/// Wrapper `wrapper`'s `kernel` traced for `args` at `tile_sizes` and lowered.
fn lowered_at(wrapper: &str, args: &[Arg], tile_sizes: TileSizes) -> LoweredKernel {
    let mut shapes: Vec<(&str, &[u64])> = vec![];
    let mut dtypes: Vec<(&str, &str)> = vec![];
    let mut contents: Vec<(&str, &[u64])> = vec![];
    let mut constants: Vec<(&str, Constant)> = vec![];
    for arg in args {
        match arg {
            Arg::Tensor(name, shape) => {
                shapes.push((name, shape));
                dtypes.push((name, "float32"));
            }
            Arg::TensorOf(name, shape, dtype) => {
                shapes.push((name, shape));
                dtypes.push((name, dtype));
            }
            Arg::Filled(name, shape, values) => {
                shapes.push((name, shape));
                dtypes.push((name, "float32"));
                contents.push((name, values));
            }
            Arg::Int(name, value) => constants.push((name, Constant::Int(*value))),
            Arg::Ints(name, values) => constants.push((name, Constant::Ints(values))),
            Arg::Bool(name, value) => constants.push((name, Constant::Bool(*value))),
        }
    }
    let call = KernelCall {
        dtypes: &dtypes,
        constants: &constants,
        contents: &contents,
        tile_sizes,
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

/// The run of `kernel` must complete, race free under `policy`, and equal `spec` on `array`.
fn assert_proved(
    policy: OrderingPolicy,
    kernel: &LoweredKernel,
    spec: &SymbolicOutputs,
    array: &str,
) {
    let run = evaluate(kernel);
    let graph = record_graph(kernel, policy, &Execution::of(&run));
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

/// The run of `kernel` must equal `spec` on `array`, races unchecked.
fn assert_equal(kernel: &LoweredKernel, spec: &SymbolicOutputs, array: &str) {
    let outputs = evaluate(kernel).unwrap();
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

/// The runs of `reference` and `candidate` must complete and be equal on `array`, and
/// `candidate`'s must be race free under `policy`: a kernel against itself at other tile sizes.
fn assert_same(
    policy: OrderingPolicy,
    reference: &LoweredKernel,
    candidate: &LoweredKernel,
    array: &str,
) {
    let reference = evaluate(reference).unwrap().lower().unwrap();
    assert_proved(policy, candidate, &reference, array);
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
