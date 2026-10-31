//! The add fixture's parsed kernel, compared with `fixtures/add.ast`.

mod common;

#[test]
fn the_add_kernel_parses_into_its_expected_ast() {
    common::check_parse("add", "kernel");
}
