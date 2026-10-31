//! The sigmoid fixture's parsed and lowered kernels and symbolic outputs, compared with
//! `fixtures/sigmoid.ast`, `fixtures/sigmoid.ir` and `fixtures/sigmoid.out`.

mod common;

#[test]
fn the_sigmoid_kernel_parses_lowers_and_runs_as_expected() {
    common::check("sigmoid", "kernel");
}
