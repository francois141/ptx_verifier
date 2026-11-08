//! Each fixture kernel's parsed and lowered forms and symbolic outputs for one call's
//! parameter shapes, compared with `fixtures/<name>.ast`, `fixtures/<name>.ir` and
//! `fixtures/<name>.out`.

mod common;

use volta_trainium_analysis::frontend::ast::TensorName;
use volta_trainium_analysis::frontend::parse::{KernelCall, parse_kernel};
use volta_trainium_analysis::{
    EvalError, Index, InstrId, LowerError, PatternProblem, StatementError, evaluate, lower_kernel,
};

#[test]
fn the_add_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "add",
        "kernel",
        &[("a", &[16, 16]), ("b", &[16, 16]), ("out", &[16, 16])],
    );
}

#[test]
fn the_sigmoid_kernel_parses_lowers_and_runs_as_expected() {
    common::check("sigmoid", "kernel", &[("a", &[2, 4]), ("out", &[2, 4])]);
}

#[test]
fn the_transpose_kernel_parses_lowers_and_runs_as_expected() {
    common::check("transpose", "kernel", &[("a", &[2, 3]), ("out", &[3, 2])]);
}

#[test]
fn the_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "matmul",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

#[test]
fn the_gemm_relu_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "gemm_relu",
        "kernel",
        &[("a_t", &[8, 4]), ("b", &[8, 4]), ("out", &[4, 4])],
    );
}

#[test]
fn the_tiled_copy_kernel_parses_lowers_and_runs_as_expected() {
    common::check("tiled_copy", "kernel", &[("a", &[8, 4]), ("out", &[8, 4])]);
}

#[test]
fn the_rms_norm_kernel_parses_lowers_and_runs_as_expected() {
    common::check("rms_norm", "kernel", &[("a", &[4, 8]), ("out", &[4, 8])]);
}

#[test]
fn the_returned_output_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "returned_output",
        "kernel",
        &[("a", &[2, 4]), ("b", &[2, 4])],
    );
}

#[test]
fn the_call_shapes_kernel_parses_lowers_and_runs_as_expected() {
    common::check("call_shapes", "kernel", &[("a", &[2, 4]), ("b", &[2, 4])]);
}

#[test]
fn the_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::check("softmax", "kernel", &[("x", &[2, 3])]);
}

#[test]
fn the_helper_call_kernel_parses_lowers_and_runs_as_expected() {
    common::check_importing(
        "helper_call",
        "kernel",
        &["helpers"],
        &[("a", &[2, 3]), ("b", &[2, 3])],
    );
}

/// The NKI samples' `attn_fwd_v2` from their unmodified file, inlining `softmax_isa` from
/// `attention_kernel_utils.py`, at the 128 x 128 size it asserts. Its outputs are checked
/// against `attention.spec` in `volta_pipeline`, not as text.
#[test]
fn the_attention_v2_kernel_parses_and_lowers_as_expected() {
    let size: &[u64] = &[128, 128];
    common::check_lowering(
        "nki_samples/attention_kernels",
        "attn_fwd_v2",
        &["attention_kernel_utils"],
        &[("q", size), ("k", size), ("v", size)],
    );
}

#[test]
fn the_language_api_kernel_parses_lowers_and_runs_as_expected() {
    let tile: &[u64] = &[2, 2];
    common::check(
        "language_api",
        "kernel",
        &[
            ("a", tile),
            ("b", tile),
            ("mx", &[2, 1]),
            ("rs", &[2, 1]),
            ("tr", tile),
        ],
    );
}

/// The NKI samples' `attn_fwd_v1`, written with the `nki.language` functions that return a
/// tile, from its unmodified file at the 128 x 128 size it asserts.
#[test]
fn the_attention_v1_kernel_parses_and_lowers_as_expected() {
    let size: &[u64] = &[128, 128];
    common::check_lowering(
        "nki_samples/attention_kernels",
        "attn_fwd_v1",
        &["attention_kernel_utils"],
        &[("q", size), ("k", size), ("v", size)],
    );
}

#[test]
fn the_accumulate_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "accumulate",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

// softmax.py's math with every operand a region of a wider tile: its outputs are
// softmax.expected's.
#[test]
fn the_regions_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::check("regions_softmax", "kernel", &[("x", &[2, 3])]);
}

// matmul.py's math with every operand a region of a wider tile: its outputs are
// matmul.expected's.
#[test]
fn the_regions_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "regions_matmul",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

// softmax.py's math through integer and partial subscripts and a 3-D tile: its outputs
// are softmax.expected's.
#[test]
fn the_subscripts_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::check("subscripts_softmax", "kernel", &[("x", &[2, 3])]);
}

// matmul.py's math staged through indexed HBM tensors and a 3-D tile: its outputs are
// matmul.expected's.
#[test]
fn the_subscripts_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "subscripts_matmul",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

// Softmax as attn_fwd_v8 computes it: tensor_scalar_reduce, tensor_reduce with negate,
// and activation with a bias and a reset_reduce reduction, over two chunks of columns.
#[test]
fn the_fused_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::check("fused_softmax", "kernel", &[("x", &[2, 4])]);
}

// attn_fwd_v10's Python on a small kernel: an allocator class whose sizes depend on the
// call's dtype, a buffers object, and pipelined stages that skip out-of-range tiles.
#[test]
fn the_pipelined_scale_kernel_parses_lowers_and_runs_as_expected() {
    let call = KernelCall {
        dtypes: &[("a", "bfloat16")],
        ..KernelCall::new(&[("a", &[6, 4])])
    };
    common::check_call("pipelined_scale", "kernel", &[], &call);
}

// The `address=` placements, `accumulate=`, `dma_transpose` and `engine=` of
// attn_fwd_v10, on `matmul.py`'s product transposed.
#[test]
fn the_placed_tiles_kernel_parses_lowers_and_runs_as_expected() {
    common::check(
        "placed_tiles",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3])],
    );
}

/// Run `kernel` of `placement_errors.py` through lowering, for a call with `shapes`.
fn lowered_placement_error(
    kernel: &str,
    shapes: &[(&str, &[u64])],
) -> Result<volta_trainium_analysis::LoweredKernel, LowerError> {
    let parsed = parse_kernel(&common::source("placement_errors"), kernel, shapes).unwrap();
    lower_kernel(&parsed)
}

#[test]
fn reading_bytes_another_placed_tile_wrote_is_an_error() {
    let lowered = lowered_placement_error("clobbered_read", &[("a", &[2, 1])]).unwrap();
    assert_eq!(
        evaluate(&lowered).unwrap_err(),
        EvalError::ClobberedRead {
            instr: InstrId(4),
            tensor: "acc".into(),
            index: Index(vec![0, 1]),
            by: InstrId(1),
            through: "half".into(),
        }
    );
}

#[test]
fn accumulating_into_unwritten_psum_is_an_error() {
    let shapes: [(&str, &[u64]); 2] = [("a_t", &[4, 2]), ("b", &[4, 3])];
    let lowered = lowered_placement_error("accumulate_uninitialized", &shapes).unwrap();
    assert_eq!(
        evaluate(&lowered).unwrap_err(),
        EvalError::UninitializedRead {
            instr: InstrId(2),
            tensor: "acc".into(),
            index: Index(vec![0, 0]),
        }
    );
}

#[test]
fn placing_some_tiles_but_not_others_is_an_error() {
    assert_eq!(
        lowered_placement_error("mixed_allocation", &[("a", &[2, 4])]).unwrap_err(),
        LowerError::MixedAllocation {
            placed: TensorName("x".into()),
            unplaced: TensorName("y".into()),
        }
    );
}

#[test]
fn a_placed_tile_past_the_end_of_its_buffer_is_an_error() {
    let error = parse_kernel(
        &common::source("placement_errors"),
        "overflowing_psum",
        &[("a", &[2, 4])],
    )
    .unwrap_err();
    assert!(
        error.to_string().contains("does not fit in `nl.psum`"),
        "{error}"
    );
}

#[test]
fn the_access_patterns_kernel_parses_lowers_and_runs_as_expected() {
    common::check("access_patterns", "kernel", &[("a", &[2, 6])]);
}

/// The error lowering `kernel` of `pattern_errors.py` gives, for `a` of `shape`.
fn pattern_error(kernel: &str, shape: &[u64]) -> StatementError {
    let source = common::source("pattern_errors");
    let parsed = parse_kernel(&source, kernel, &[("a", shape)]).unwrap();
    match lower_kernel(&parsed).unwrap_err() {
        LowerError::Statement { error, .. } => error,
        other => panic!("{kernel}: expected a statement error, got {other}"),
    }
}

#[test]
fn access_patterns_outside_their_tensor_or_partition_are_errors() {
    let cases = [
        ("partition_step", PatternProblem::PartitionStep { free: 6 }),
        (
            "crossing_partitions",
            PatternProblem::CrossesPartition { free: 6 },
        ),
        ("out_of_bounds", PatternProblem::OutOfBounds),
    ];
    for (kernel, problem) in cases {
        let tensor = if kernel == "out_of_bounds" { "a" } else { "t" };
        assert_eq!(
            pattern_error(kernel, &[2, 6]),
            StatementError::AccessPattern {
                tensor: TensorName(tensor.into()),
                problem,
            },
            "{kernel}"
        );
    }
}

#[test]
fn reducing_other_than_trailing_axes_is_an_error() {
    assert!(matches!(
        pattern_error("leading_axis", &[2, 3, 2]),
        StatementError::UnsupportedAxis(_)
    ));
}
