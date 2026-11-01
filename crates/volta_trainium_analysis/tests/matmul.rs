//! The matmul fixture's parsed and lowered kernels and symbolic outputs, compared with
//! `fixtures/matmul.ast`, `fixtures/matmul.ir` and `fixtures/matmul.out`.

mod common;

#[test]
fn the_matmul_kernel_parses_lowers_and_runs_as_expected() {
    common::check("matmul", "kernel");
}
