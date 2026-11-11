//! `volta solve` end to end: a kernel run from a launch file through its ISA's frontend, then
//! graph checked and proved against the spec the launch file names.

use std::path::{Path, PathBuf};
use std::process::Command;

fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .to_path_buf()
}

// Test that CK RMSNorm, launched from its launch file, is accepted: every graph check passes
// and all 1,024 outputs are proved equivalent to the spec.
#[test]
fn solves_ck_rmsnorm_from_its_launch_file() {
    let output = Command::new(env!("CARGO_BIN_EXE_volta"))
        .args(["--no-log-file", "solve"])
        .arg(root().join("crates/volta_pipeline/tests/amd/success/ck_rmsnorm2d.s"))
        .arg("--config")
        .arg(root().join("examples/lean/rmsnorm_amd.json"))
        // Each output expression holds the row's whole sum, so none is printed.
        .args(["--print-outputs", "0"])
        .output()
        .unwrap();
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert_eq!(
        output.status.code(),
        Some(0),
        "stdout:\n{stdout}\nstderr:\n{}",
        String::from_utf8_lossy(&output.stderr)
    );
    for expected in [
        "kernel: every graph check passed",
        "equivalence: all 1024 compared elements proved equivalent",
        "VERDICT: ACCEPT",
    ] {
        assert!(stdout.contains(expected), "missing `{expected}`:\n{stdout}");
    }
}
