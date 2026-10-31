//! The add fixture's parsed and lowered kernels and symbolic outputs, compared with
//! `fixtures/add.ast`, `fixtures/add.ir` and `fixtures/add.out`.

mod common;

#[test]
fn the_add_kernel_parses_lowers_and_runs_as_expected() {
    common::check("add", "kernel");
}
