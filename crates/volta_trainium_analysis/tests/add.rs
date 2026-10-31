//! The add fixture's parsed and lowered kernels, compared with `fixtures/add.ast`
//! and `fixtures/add.ir`.

mod common;

#[test]
fn the_add_kernel_parses_and_lowers_into_its_expected_ast_and_ir() {
    common::check("add", "kernel");
}
