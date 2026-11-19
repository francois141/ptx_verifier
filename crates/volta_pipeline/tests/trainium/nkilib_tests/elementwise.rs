//! nkilib kernels found correct whose outputs are elementwise in their inputs or reduce them
//! per channel: the foreach ops and norms, fused Adam and AdamW, and batch norm's backward.
//! Each is proved equal to its spec on every element and race free under the baseline, but for
//! F6 and a scratch tile `batch_norm_bwd` rewrites unread.

use volta_expr::SymbolicOutputs;
use volta_graph_check::{GraphConclusion, Property, check_graph};
use volta_trainium_analysis::frontend::parse::TileSizes;
use volta_trainium_analysis::{Execution, LoweredKernel, OrderingPolicy, evaluate, record_graph};

use super::{Arg, WAW, assert_equal, assert_proved, lowered, lowered_at, spec};

/// With the foreach wrappers' 4 free elements, a 16-element tile.
const FOREACH_TILES: TileSizes = TileSizes {
    pmax: 4,
    ..TileSizes::HARDWARE
};

/// Element counts of three tiles of 16, 16 and 8 plus a tail of 3, one full tile, a partial
/// tile, and a tail alone.
const FOREACH_NUMELS: [u64; 4] = [43, 16, 4, 3];

/// One of `foreach_elementwise.py`'s `OPS`, in its order: the kernel's tensor operands and its
/// `[pmax, 1]` scalar operand, if any, which the call fills with 3 as the specs assume.
struct ForeachOp {
    name: &'static str,
    tensors: &'static [&'static str],
    scalar: Option<&'static str>,
}

const FOREACH_OPS: [ForeachOp; 8] = [
    ForeachOp {
        name: "add_scalar",
        tensors: &["data"],
        scalar: Some("scalar_tensor"),
    },
    ForeachOp {
        name: "add_tensor",
        tensors: &["data1", "data2"],
        scalar: Some("alpha_tensor"),
    },
    ForeachOp {
        name: "sub_tensor",
        tensors: &["data1", "data2"],
        scalar: Some("alpha_tensor"),
    },
    ForeachOp {
        name: "mul_tensor",
        tensors: &["data1", "data2"],
        scalar: None,
    },
    ForeachOp {
        name: "div_tensor",
        tensors: &["data1", "data2"],
        scalar: None,
    },
    ForeachOp {
        name: "addcdiv",
        tensors: &["data", "data1", "data2"],
        scalar: Some("value_tensor"),
    },
    ForeachOp {
        name: "addcmul",
        tensors: &["data", "data1", "data2"],
        scalar: Some("value_tensor"),
    },
    ForeachOp {
        name: "lerp",
        tensors: &["data", "end"],
        scalar: Some("weight_tensor"),
    },
];

#[test]
fn nkilib_foreach_elementwise_ops_match_their_torch_references_across_tiles_and_tails() {
    for (index, op) in FOREACH_OPS.iter().enumerate() {
        for numel in FOREACH_NUMELS {
            let mut args = vec![
                Arg::Int("op", index as i64),
                Arg::Int("numel", numel as i64),
            ];
            args.extend(
                op.tensors
                    .iter()
                    .map(|&name| Arg::Tensor(name, vec![numel])),
            );
            args.extend(
                op.scalar
                    .map(|name| Arg::Filled(name, vec![FOREACH_TILES.pmax, 1], vec![3; 4])),
            );
            let kernel = lowered_at("foreach_elementwise.py", &args, FOREACH_TILES);
            let spec = spec(&format!("foreach_{}.spec", op.name), &[("N", numel)], &[]);
            assert_proved(OrderingPolicy::BASELINE, &kernel, &spec, "out_hbm");
        }
    }
}

/// `foreach_norm.py`'s `NORMS`, in its order.
const NORMS: [&str; 3] = ["l2", "l1", "linf"];

fn norm_call(norm: &str, numel: u64) -> (LoweredKernel, SymbolicOutputs) {
    let index = NORMS.iter().position(|&n| n == norm).unwrap();
    let args = [
        Arg::Int("norm", index as i64),
        Arg::Tensor("data", vec![numel]),
        Arg::Int("numel", numel as i64),
    ];
    let kernel = lowered_at("foreach_norm.py", &args, FOREACH_TILES);
    let spec = spec(
        &format!("foreach_{norm}_norm.spec"),
        &[("N", numel), ("ONE", 1)],
        &[],
    );
    (kernel, spec)
}

#[test]
fn nkilib_foreach_norms_match_their_torch_references() {
    for norm in NORMS {
        for numel in [43, 16, 3] {
            if (norm, numel) != ("linf", 43) {
                let (kernel, spec) = norm_call(norm, numel);
                assert_proved(OrderingPolicy::BASELINE, &kernel, &spec, "out");
            }
        }
    }
}

/// F6 (doubtful): across tiles, `linf_norm` folds each tile into one accumulator with
/// `maximum` in an `affine_range`, which the baseline does not let commute as it does adds.
#[test]
fn nkilib_foreach_linf_norm_across_tiles_is_equal_but_races_on_its_maximum_accumulator() {
    let (kernel, spec) = norm_call("linf", 43);
    assert_equal(&kernel, &spec, "out");
    let graph = record_graph(
        &kernel,
        OrderingPolicy::BASELINE,
        &Execution::of(&evaluate(&kernel)),
    );
    let GraphConclusion::Rejected { failed, deadlock } = check_graph(&graph).conclusion() else {
        panic!("linf_norm across tiles should race under the baseline");
    };
    assert!(deadlock.is_none());
    let failed: Vec<Property> = failed.iter().map(|summary| summary.property).collect();
    assert_eq!(failed, [Property::MemoryConflict]);
}

/// Whether `fused_adam.py` runs `adam_kernel` or `adamw_kernel`.
#[derive(Clone, Copy)]
enum WeightDecay {
    Coupled,
    Decoupled,
}

const ADAM_OUTPUTS: [&str; 3] = ["weights", "first_moment", "second_moment"];

/// `numel` elements over free tiles of `f_size`: 300 at the hardware's 2048 is a partial tile
/// and a tail; 1000 at 3 is two full tiles, a partial one and a tail.
const ADAM_CALLS: [(u64, i64); 3] = [(1, 2048), (300, 2048), (1000, 3)];

#[test]
fn nkilib_fused_adam_and_adamw_match_their_torch_references() {
    for (decay, spec_file) in [
        (WeightDecay::Coupled, "adam.spec"),
        (WeightDecay::Decoupled, "adamw.spec"),
    ] {
        for (numel, f_size) in ADAM_CALLS {
            let spec = spec(spec_file, &[("N", numel)], &[]);
            for (output, array) in ADAM_OUTPUTS.iter().enumerate() {
                let mut args: Vec<Arg> = ["p", "g", "m", "v"]
                    .into_iter()
                    .map(|name| Arg::Tensor(name, vec![numel]))
                    .collect();
                args.extend(
                    ["step_size", "inv_bc2_sqrt", "wd_factor"]
                        .map(|name| Arg::Filled(name, vec![128, 1], vec![1; 128])),
                );
                args.extend([
                    Arg::Bool("adamw", matches!(decay, WeightDecay::Decoupled)),
                    Arg::Int("output", output as i64),
                    Arg::Int("f_size", f_size),
                ]);
                let kernel = lowered("fused_adam.py", &args);
                assert_proved(OrderingPolicy::BASELINE, &kernel, &spec, array);
            }
        }
    }
}

const BATCH_NORM_OUTPUTS: [&str; 3] = ["dx", "dgamma", "dbeta"];

/// `batch_norm_bwd` on `[B, C, D, H, W]` (one batch): `[1, 4, 2, 8, 8]`, two channel tiles at
/// `[1, 130, 1, 4, 4]`, and 105 elements per channel at `[1, 2, 3, 5, 7]`, where the kernel
/// multiplies by the double nearest 1/105, as `batch_norm_bwd_m105.spec` does.
#[test]
fn nkilib_batch_norm_bwd_matches_the_gradients_in_the_saved_statistics() {
    // Each channel tile's `dbeta` reduction also writes its elementwise result, never read, to
    // one scratch tile: two channel tiles are race free once write after write is ordered.
    for (shape, spec_file, policy) in [
        (
            [1, 4, 2, 8, 8],
            "batch_norm_bwd.spec",
            OrderingPolicy::BASELINE,
        ),
        ([1, 130, 1, 4, 4], "batch_norm_bwd.spec", WAW),
        (
            [1, 2, 3, 5, 7],
            "batch_norm_bwd_m105.spec",
            OrderingPolicy::BASELINE,
        ),
    ] {
        let [b, c, d, h, w] = shape;
        let dims = [
            ("B", b),
            ("C", c),
            ("D", d),
            ("H", h),
            ("W", w),
            ("M", b * d * h * w),
            ("ONE", 1),
        ];
        let spec = spec(spec_file, &dims, &[]);
        for (output, array) in BATCH_NORM_OUTPUTS.iter().enumerate() {
            let args = [
                Arg::Tensor("dy", shape.to_vec()),
                Arg::Tensor("x_in", shape.to_vec()),
                Arg::Tensor("means", vec![c]),
                Arg::Tensor("variances", vec![c]),
                Arg::Tensor("gamma", vec![c, 1]),
                Arg::Tensor("beta", vec![c, 1]),
                Arg::Int("output", output as i64),
            ];
            let kernel = lowered("batch_norm_bwd.py", &args);
            assert_proved(policy, &kernel, &spec, array);
        }
    }
}
