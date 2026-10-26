//! CLI-only soundness regressions. These assertions state the required verdict and intentionally
//! fail until the corresponding false acceptance is fixed.

use std::path::Path;
use std::process::Command;

#[test]
fn sampled_verify_must_not_accept_an_incomplete_output_footprint() {
    let fixtures = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/ptx/soundness");
    let output = Command::new(env!("CARGO_BIN_EXE_volta"))
        .arg("--no-log-file")
        .arg("verify")
        .arg(fixtures.join("sampled_partial_output.ptx"))
        .arg(fixtures.join("two_zeroes.spec"))
        .args([
            "--array",
            "out:0x20000:4:2:out",
            "--param",
            "ptr:out",
            "--dim",
            "N=2",
            "--sample",
            "1",
            "--no-profile",
        ])
        .output()
        .expect("run volta verify");

    let stdout = String::from_utf8_lossy(&output.stdout);
    assert_eq!(
        output.status.code(),
        Some(1),
        "a kernel missing a spec index must be REJECTED; stdout:\n{}\nstderr:\n{}",
        stdout,
        String::from_utf8_lossy(&output.stderr),
    );
    assert!(
        stdout.contains("out does not have the same set of indices (1 never written, first out[1]"),
        "the rejection must name the index set mismatch; stdout:\n{stdout}"
    );
}

#[test]
fn verify_must_reject_a_kernel_writing_other_indices_than_the_spec() {
    let fixtures = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/ptx/soundness");
    let output = Command::new(env!("CARGO_BIN_EXE_volta"))
        .arg("--no-log-file")
        .arg("verify")
        .arg(fixtures.join("shifted_output_index.ptx"))
        .arg(fixtures.join("two_zeroes.spec"))
        .args([
            "--array",
            "out:0x20000:4:3:out",
            "--param",
            "ptr:out",
            "--dim",
            "N=2",
            "--no-profile",
        ])
        .output()
        .expect("run volta verify");

    let stdout = String::from_utf8_lossy(&output.stdout);
    assert_eq!(
        output.status.code(),
        Some(1),
        "writing out[0] and out[2] against a spec of out[0..2] must be REJECTED; stdout:\n{}\nstderr:\n{}",
        stdout,
        String::from_utf8_lossy(&output.stderr),
    );
    assert!(
        stdout.contains(
            "out does not have the same set of indices \
             (1 never written, first out[1], 1 written outside it, first out[2])"
        ),
        "the rejection must name the missing and the extra index; stdout:\n{stdout}"
    );
}
