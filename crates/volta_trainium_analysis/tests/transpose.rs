//! The transpose fixture's parsed and lowered kernels and symbolic outputs, compared with
//! `fixtures/transpose.ast`, `fixtures/transpose.ir` and `fixtures/transpose.out`.

mod common;

#[test]
fn the_transpose_kernel_parses_lowers_and_runs_as_expected() {
    common::check("transpose", "kernel");
}
