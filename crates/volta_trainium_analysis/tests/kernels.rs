//! Each fixture kernel's parsed and lowered forms and symbolic outputs for one call's
//! parameter shapes, compared with `fixtures/<name>.ast`, `fixtures/<name>.ir` and
//! `fixtures/<name>.out`.

mod common;

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
