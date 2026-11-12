//! NKI kernels expected to complete: each fixture kernel's parsed and lowered forms and
//! symbolic outputs for one call's parameter shapes, compared with `<name>.ast`, `<name>.ir`
//! and `<name>.out` beside `trainium/success/<name>.py`.

use crate::common;

use volta_trainium_analysis::frontend::parse::KernelCall;

#[test]
fn the_add_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/add",
        "kernel",
        &[("a", &[16, 16]), ("b", &[16, 16]), ("out", &[16, 16])],
    );
}

#[test]
fn the_sigmoid_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/sigmoid",
        "kernel",
        &[("a", &[2, 4]), ("out", &[2, 4])],
    );
}

#[test]
fn the_transpose_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/transpose",
        "kernel",
        &[("a", &[2, 3]), ("out", &[3, 2])],
    );
}

#[test]
fn the_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/matmul",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

#[test]
fn the_gemm_relu_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/gemm_relu",
        "kernel",
        &[("a_t", &[8, 4]), ("b", &[8, 4]), ("out", &[4, 4])],
    );
}

// Each instruction's origin: its loops of every kind, outermost first and across a helper
// call, a new loop id each time an inner loop is entered, and an enclosing no_reorder block.
#[test]
fn the_loop_origins_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/loop_origins",
        "kernel",
        &[("a", &[2, 4]), ("out", &[2, 4])],
    );
}

// The race fixtures in `check_failure/` run in program order; `graph_tests.rs` checks their
// event graphs' races.
#[test]
fn the_race_fixtures_parse_lower_and_run_in_program_order() {
    let rows = |count: u64| [("a", [count, 4]), ("out", [count - 1, 4])];
    for (name, [a, out]) in [
        ("back_to_back_dmas", rows(2)),
        ("affine_overwrite", rows(2)),
        ("sequential_overwrite", rows(2)),
        ("affine_carried", rows(3)),
        ("no_reorder_back_to_back_dmas", rows(2)),
        ("no_reorder_boundary", rows(2)),
    ] {
        common::trainium::check(
            &format!("check_failure/{name}"),
            "kernel",
            &[(a.0, &a.1), (out.0, &out.1)],
        );
    }
    common::trainium::check(
        "check_failure/affine_matmul_partial_read",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[4, 3])],
    );
    common::trainium::check(
        "check_failure/no_reorder_affine",
        "kernel",
        &[("a", &[2, 4]), ("out", &[2, 4])],
    );
}

// An affine_range's tensor_tensor adds accumulating into one SBUF tile, as mamba does.
#[test]
fn the_affine_vector_sum_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/affine_vector_sum",
        "kernel",
        &[("a", &[2, 4]), ("out", &[1, 4])],
    );
}

// An affine_range's nc_matmuls accumulating into one PSUM tile, the reduction the docs allow.
#[test]
fn the_affine_matmul_accumulate_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/affine_matmul_accumulate",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

// The twin of `check_failure/affine_carried` whose iterations are in order.
#[test]
fn the_sequential_carried_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/sequential_carried",
        "kernel",
        &[("a", &[3, 4]), ("out", &[2, 4])],
    );
}

#[test]
fn the_tiled_copy_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/tiled_copy",
        "kernel",
        &[("a", &[8, 4]), ("out", &[8, 4])],
    );
}

#[test]
fn the_rms_norm_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/rms_norm",
        "kernel",
        &[("a", &[4, 8]), ("out", &[4, 8])],
    );
}

#[test]
fn the_returned_output_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/returned_output",
        "kernel",
        &[("a", &[2, 4]), ("b", &[2, 4])],
    );
}

#[test]
fn the_call_shapes_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/call_shapes",
        "kernel",
        &[("a", &[2, 4]), ("b", &[2, 4])],
    );
}

#[test]
fn the_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check("success/softmax", "kernel", &[("x", &[2, 3])]);
}

#[test]
fn the_helper_call_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check_importing(
        "success/helper_call",
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
    common::trainium::check_lowering(
        "success/nki_samples/attention_kernels",
        "attn_fwd_v2",
        &["attention_kernel_utils"],
        &[("q", size), ("k", size), ("v", size)],
    );
}

#[test]
fn the_language_api_kernel_parses_lowers_and_runs_as_expected() {
    let tile: &[u64] = &[2, 2];
    common::trainium::check(
        "success/language_api",
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
    common::trainium::check_lowering(
        "success/nki_samples/attention_kernels",
        "attn_fwd_v1",
        &["attention_kernel_utils"],
        &[("q", size), ("k", size), ("v", size)],
    );
}

#[test]
fn the_accumulate_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/accumulate",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

// softmax.py's math with every operand a region of a wider tile: its outputs are
// softmax.expected's.
#[test]
fn the_regions_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check("success/regions_softmax", "kernel", &[("x", &[2, 3])]);
}

// matmul.py's math with every operand a region of a wider tile: its outputs are
// matmul.expected's.
#[test]
fn the_regions_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/regions_matmul",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

// softmax.py's math through integer and partial subscripts and a 3-D tile: its outputs
// are softmax.expected's.
#[test]
fn the_subscripts_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check("success/subscripts_softmax", "kernel", &[("x", &[2, 3])]);
}

// matmul.py's math staged through indexed HBM tensors and a 3-D tile: its outputs are
// matmul.expected's.
#[test]
fn the_subscripts_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/subscripts_matmul",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])],
    );
}

// Softmax as attn_fwd_v8 computes it: tensor_scalar_reduce, tensor_reduce with negate,
// and activation with a bias and a reset_reduce reduction, over two chunks of columns.
#[test]
fn the_fused_softmax_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check("success/fused_softmax", "kernel", &[("x", &[2, 4])]);
}

// attn_fwd_v10's Python on a small kernel: an allocator class whose sizes depend on the
// call's dtype, a buffers object, and pipelined stages that skip out-of-range tiles.
#[test]
fn the_pipelined_scale_kernel_parses_lowers_and_runs_as_expected() {
    let call = KernelCall {
        dtypes: &[("a", "bfloat16")],
        ..KernelCall::new(&[("a", &[6, 4])])
    };
    common::trainium::check_call("success/pipelined_scale", "kernel", &[], &call);
}

// The `address=` placements, `accumulate=`, `dma_transpose` and `engine=` of
// attn_fwd_v10, on `matmul.py`'s product transposed.
#[test]
fn the_placed_tiles_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "success/placed_tiles",
        "kernel",
        &[("a_t", &[4, 2]), ("b", &[4, 3])],
    );
}

#[test]
fn the_access_patterns_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check("success/access_patterns", "kernel", &[("a", &[2, 6])]);
}

// Its `scale` memset, overwritten unread, races under the baseline; it runs in program order.
#[test]
fn the_scan_kernel_parses_lowers_and_runs_as_expected() {
    common::trainium::check(
        "check_failure/scan",
        "kernel",
        &[("a", &[2, 3]), ("b", &[1, 3]), ("c", &[2, 1])],
    );
}

/// The first 16 offsets of `indirect.py`'s index, the gather reading its first three.
const OFFSETS: [u64; 16] = [3, 0, 3, 1, 2, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2];

#[test]
fn the_indirect_kernel_parses_lowers_and_runs_as_expected() {
    let call = KernelCall {
        contents: &[("idx", &OFFSETS)],
        ..KernelCall::new(&[("a", &[32, 4]), ("idx", &[16, 1])])
    };
    common::trainium::check_call("success/indirect", "kernel", &[], &call);
}
