//! The add fixture's symbolic outputs, compared with `fixtures/add.out`.

mod common;

use common::array;
use volta_amd_analysis::ArrayKind;

#[test]
fn the_add_kernel_writes_its_expected_outputs() {
    common::check_run(
        "add",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array("out", 0x30000, ArrayKind::Output),
        ],
    );
}
