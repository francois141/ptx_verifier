//! Extraction is successful when a module is written, and graph failures must not write one.

use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::sync::atomic::{AtomicUsize, Ordering};

const ADD_SPEC: &str = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];";

struct TestDir(PathBuf);

impl TestDir {
    fn new() -> Self {
        static NEXT: AtomicUsize = AtomicUsize::new(0);
        let path = std::env::temp_dir().join(format!(
            "volta-extract-{}-{}",
            std::process::id(),
            NEXT.fetch_add(1, Ordering::Relaxed)
        ));
        std::fs::create_dir_all(&path).unwrap();
        Self(path)
    }
}

impl Drop for TestDir {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.0);
    }
}

fn root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .to_path_buf()
}

fn extract(file: &Path, output: &Path) -> Command {
    let mut command = Command::new(env!("CARGO_BIN_EXE_volta"));
    command
        .args(["--no-log-file", "extract", "lean"])
        .arg(file)
        .arg("--output")
        .arg(output);
    command
}

fn launch(command: &mut Command, size: usize) {
    command.arg("--block").arg(size.to_string());
    for (name, base, kind) in [
        ("a", "0x10000", "in"),
        ("b", "0x20000", "in"),
        ("out", "0x30000", "out"),
    ] {
        command
            .arg("--array")
            .arg(format!("{name}:{base}:4:{size}:{kind}"))
            .arg("--param")
            .arg(format!("ptr:{name}"));
    }
}

fn assert_status(output: &Output, expected: i32) {
    assert_eq!(
        output.status.code(),
        Some(expected),
        "stdout:\n{}\nstderr:\n{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}

#[test]
fn extracts_all_three_isas_and_exits_successfully() {
    let dir = TestDir::new();
    for (kernel, size) in [
        ("examples/quickstart/add.ptx", 128),
        ("crates/volta_amd_analysis/tests/fixtures/add.s", 64),
        ("crates/volta_trainium_analysis/tests/fixtures/add.py", 256),
    ] {
        let out = dir.0.join(format!("add_{size}.lean"));
        let mut command = extract(&root().join(kernel), &out);
        command
            .args(["--spec", ADD_SPEC, "--dim"])
            .arg(format!("N={size}"));
        if !kernel.ends_with(".py") {
            launch(&mut command, size);
        }
        let output = command.output().unwrap();
        assert_status(&output, 0);
        let lean = std::fs::read_to_string(out).unwrap();
        assert_eq!(lean.matches(" : Prop :=").count(), size);
        assert!(String::from_utf8_lossy(&output.stdout).contains("proofs still required"));
    }
}

#[test]
fn extracts_with_a_launch_file_and_tolerance() {
    let dir = TestDir::new();
    let out = dir.0.join("sigmoid.lean");
    let output = extract(
        &root().join("crates/volta_amd_analysis/tests/fixtures/sigmoid.s"),
        &out,
    )
    .arg("--config")
    .arg(root().join("examples/lean/sigmoid_amd.json"))
    .args(["--tolerance", "1/1000"])
    .output()
    .unwrap();
    assert_status(&output, 0);
    let lean = std::fs::read_to_string(out).unwrap();
    assert_eq!(lean.matches(" : Prop :=").count(), 64);
    assert!(lean.contains("≤ (0.001 : ℝ)"));
}

#[test]
fn a_race_neither_creates_nor_overwrites_lean_output() {
    let dir = TestDir::new();
    let kernel = dir.0.join("race.ptx");
    let source = std::fs::read_to_string(root().join("examples/quickstart/add.ptx")).unwrap();
    std::fs::write(
        &kernel,
        source.replace("add.s64 %rd10, %rd6, %rd7;", "mov.b64 %rd10, %rd6;"),
    )
    .unwrap();
    let out = dir.0.join("race.lean");
    for existing in [false, true] {
        if existing {
            std::fs::write(&out, "existing proof file").unwrap();
        }
        let mut command = extract(&kernel, &out);
        command.args(["--spec", ADD_SPEC, "--dim", "N=1"]);
        launch(&mut command, 2);
        let output = command.output().unwrap();
        assert_status(&output, 1);
        assert!(String::from_utf8_lossy(&output.stderr).contains("memory-conflict freedom failed"));
        if existing {
            assert_eq!(
                std::fs::read_to_string(&out).unwrap(),
                "existing proof file"
            );
        } else {
            assert!(!out.exists());
        }
    }
}

#[test]
fn a_deadlock_does_not_write_lean_output() {
    let dir = TestDir::new();
    let out = dir.0.join("deadlock.lean");
    let output = extract(
        &root().join("crates/volta_pipeline/tests/ptx/failing/mismatched_barriers_deadlock.ptx"),
        &out,
    )
    .args(["--block", "2", "--spec", ADD_SPEC, "--dim", "N=1"])
    .output()
    .unwrap();
    assert_status(&output, 1);
    assert!(String::from_utf8_lossy(&output.stderr).contains("deadlocked"));
    assert!(!out.exists());
}

#[test]
fn extraction_needs_a_spec() {
    let dir = TestDir::new();
    let out = dir.0.join("missing.lean");
    let output = extract(
        &root().join("crates/volta_trainium_analysis/tests/fixtures/add.py"),
        &out,
    )
    .output()
    .unwrap();
    assert_status(&output, 1);
    assert!(String::from_utf8_lossy(&output.stderr).contains("extract lean needs a spec"));
    assert!(!out.exists());
}
