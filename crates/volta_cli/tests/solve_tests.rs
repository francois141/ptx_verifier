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

/// Run `volta solve` with `options` on the AMD fixture `kernel` and the launch file
/// `examples/lean/<launch>`. Require exit status `status` and each of `expected` in its output.
fn check_solve(kernel: &str, launch: &str, options: &[&str], status: i32, expected: &[&str]) {
    let fixtures = root().join("crates/volta_pipeline/tests/amd/success");
    let output = Command::new(env!("CARGO_BIN_EXE_volta"))
        .args(["--no-log-file", "solve"])
        .arg(fixtures.join(kernel))
        .arg("--config")
        .arg(root().join("examples/lean").join(launch))
        .args(options)
        .output()
        .unwrap();
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert_eq!(
        output.status.code(),
        Some(status),
        "stdout:\n{stdout}\nstderr:\n{}",
        String::from_utf8_lossy(&output.stderr)
    );
    for text in expected {
        assert!(stdout.contains(text), "missing `{text}`:\n{stdout}");
    }
}

// Test that CK RMSNorm, launched from its launch file, is accepted: every graph check passes
// and all 1,024 outputs are proved equivalent to the spec.
#[test]
fn solves_ck_rmsnorm_from_its_launch_file() {
    check_solve(
        "ck_rmsnorm2d.s",
        "rmsnorm_amd.json",
        // Each output expression holds the row's whole sum, so none is printed.
        &["--print-outputs", "0"],
        0,
        &[
            "kernel: every graph check passed",
            "equivalence: all 1024 compared elements proved equivalent",
            "VERDICT: ACCEPT",
        ],
    );
}

// Test that the GEMM launch passes all graph checks and proves all 64 outputs.
#[test]
fn solves_ck_gemm_from_its_launch_file() {
    check_solve(
        "ck_gemm.s",
        "gemm_amd.json",
        &[],
        0,
        &[
            "kernel: every graph check passed",
            "equivalence: all 64 compared elements proved equivalent",
            "VERDICT: ACCEPT",
        ],
    );
}

// Test that the attention launch passes all graph checks and proves all 4,096 outputs.
#[test]
fn solves_ck_fmha_from_its_launch_file() {
    check_solve(
        "ck_fmha.s",
        "fmha_amd.json",
        // Each output expression holds a whole softmax row, so none is printed.
        &["--print-outputs", "0"],
        0,
        &[
            "kernel: every graph check passed",
            "equivalence: all 4096 compared elements proved equivalent",
            "VERDICT: ACCEPT",
        ],
    );
}

// Test that swapping query and key is rejected with a numeric counterexample.
#[test]
fn rejects_ck_fmha_launch_with_swapped_query_and_key() {
    check_solve(
        "ck_fmha.s",
        "fmha_amd_swapped_qk.json",
        // The first output row is enough to refute the launch.
        &["--print-outputs", "0", "--sample", "64"],
        1,
        &[
            "VERDICT: REJECT",
            "element(s) refuted by a numeric counterexample",
        ],
    );
}

// Test that CK average pooling with 3 x 3 windows over a padded 14 x 14 input is accepted:
// every graph check passes and all 147 outputs are proved equivalent to the spec.
#[test]
fn solves_ck_avgpool2d_from_its_launch_file() {
    check_solve(
        "ck_avgpool2d.s",
        "avgpool2d_amd.json",
        &[],
        0,
        &[
            "kernel: every graph check passed",
            "equivalence: all 147 compared elements proved equivalent",
            "VERDICT: ACCEPT",
        ],
    );
}

// Test that CK average pooling of a 2 x 2 input into a 3 x 3 output is rejected. CK's output
// buffer bound of five elements drops four of the nine stores, and the verdict names the
// outputs never written.
#[test]
fn rejects_ck_avgpool2d_launch_that_drops_outputs() {
    check_solve(
        "ck_avgpool2d.s",
        "avgpool2d_amd_larger_output.json",
        &[],
        1,
        &[
            "output 'output': 5 element(s) written",
            "VERDICT: REJECT",
            "equivalence: output does not have the same set of indices",
            "4 never written, first output[5], 0 written outside it",
        ],
    );
}
