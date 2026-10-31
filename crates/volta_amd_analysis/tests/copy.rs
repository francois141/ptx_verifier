//! The copy fixture's symbolic outputs, compared with `fixtures/copy.out`.

mod common;

use common::array;
use volta_amd_analysis::ArrayKind;

#[test]
fn the_copy_kernel_writes_its_expected_outputs() {
    common::check_run(
        "copy",
        &[
            array("in", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output),
        ],
    );
}
