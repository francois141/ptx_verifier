//! Each fixture kernel's parsed and lowered forms and symbolic outputs, compared with
//! `fixtures/<name>.ast`, `fixtures/<name>.ir` and `fixtures/<name>.out`.

mod common;

#[test]
fn the_add_kernel_parses_lowers_and_runs_as_expected() {
    common::check("add", "kernel");
}

#[test]
fn the_sigmoid_kernel_parses_lowers_and_runs_as_expected() {
    common::check("sigmoid", "kernel");
}

#[test]
fn the_transpose_kernel_parses_lowers_and_runs_as_expected() {
    common::check("transpose", "kernel");
}

#[test]
fn the_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::check("matmul", "kernel");
}

#[test]
fn the_gemm_relu_kernel_parses_lowers_and_runs_as_expected() {
    common::check("gemm_relu", "kernel");
}

#[test]
fn the_tiled_copy_kernel_parses_lowers_and_runs_as_expected() {
    common::check("tiled_copy", "kernel");
}

#[test]
fn the_rms_norm_kernel_parses_lowers_and_runs_as_expected() {
    common::check("rms_norm", "kernel");
}
