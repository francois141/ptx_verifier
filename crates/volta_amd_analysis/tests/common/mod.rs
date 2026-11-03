//! A fixture's run, checked against its expected symbolic outputs: `tests/fixtures/<name>.out`
//! beside `<name>.s`, one `array[index] = expr` line per written element as in the PTX tests'
//! `.out` files. `VOLTA_BLESS=1` rewrites the expected file instead.

#![allow(dead_code)]

use std::fmt::Write as _;
use std::io::{IsTerminal, Write};
use std::path::{Path, PathBuf};

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    AnalysisError, AnalysisResult, ArrayDef, ArrayKind, Terminal, WorkgroupLaunch, analyze,
};
use volta_expr::SymbolicOutputs;

const KERNARG_ADDRESS: u64 = 0x1000;
pub const WORKITEMS: u32 = 64;

/// An array of one word per work-item of `check_run`'s wave.
pub fn array(name: &str, base: u64, kind: ArrayKind) -> ArrayDef {
    array_of(name, base, u64::from(WORKITEMS), kind)
}

/// An array of `len` words.
pub fn array_of(name: &str, base: u64, len: u64, kind: ArrayKind) -> ArrayDef {
    ArrayDef {
        name: name.into(),
        base,
        len,
        kind,
    }
}

/// Run kernel `name` of `tests/fixtures/<name>.s` on one wave, with `arrays` in global memory
/// and their bases as the kernel's pointer arguments, in order, and compare its outputs with
/// `<name>.out`.
pub fn check_run(name: &str, arrays: &[ArrayDef]) {
    check_run_on(name, WORKITEMS, arrays);
}

/// `check_run` on a workgroup of `workitems` work-items along X.
pub fn check_run_on(name: &str, workitems: u32, arrays: &[ArrayDef]) {
    check_run_kernel(name, name, workitems, &kernarg(arrays), arrays);
}

/// The symbolic outputs `check_run` compares, of kernel `name` on one wave.
pub fn outputs(name: &str, arrays: &[ArrayDef]) -> Result<SymbolicOutputs, String> {
    run_outputs(name, name, WORKITEMS, &kernarg(arrays), arrays)
}

fn kernarg(arrays: &[ArrayDef]) -> Vec<u8> {
    arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect()
}

/// Run kernel `kernel` of `tests/fixtures/<fixture>.s` on a workgroup of `workitems` work-items
/// along X, with `kernarg` as its argument buffer, and compare its outputs with `<fixture>.out`.
pub fn check_run_kernel(
    fixture: &str,
    kernel: &str,
    workitems: u32,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) {
    let result = run(fixture, kernel, workitems, kernarg, arrays);
    report(fixture, result.is_ok());
    if let Err(error) = result {
        panic!("{fixture}: {error}");
    }
}

/// Require a fixture kernel to fail in the specified way, using one wave and array pointers.
pub fn check_rejected_kernel(
    fixture: &str,
    kernel: &str,
    arrays: &[ArrayDef],
    expected: impl FnOnce(&Result<AnalysisResult, AnalysisError>) -> bool,
) {
    let path = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(format!("{fixture}.s"));
    let source = std::fs::read_to_string(path).unwrap();
    let parsed = parse_kernel(&source, kernel).unwrap();
    let kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    let launch = WorkgroupLaunch {
        kernarg_address: KERNARG_ADDRESS,
        workgroup_size: (WORKITEMS, 1, 1),
    };
    let result = analyze(&parsed, &launch, &kernarg, arrays);
    let passed = expected(&result);
    report(&format!("{kernel} (rejected)"), passed);
    assert!(passed, "{kernel}: unexpected outcome: {result:?}");
}

/// Written to stderr directly, past the test harness's output capture.
fn report(name: &str, passed: bool) {
    let (verdict, color) = if passed {
        ("PASS", "32")
    } else {
        ("FAIL", "31")
    };
    let mut stderr = std::io::stderr();
    let line = if stderr.is_terminal() {
        format!("\x1b[{color}m{verdict}\x1b[0m {name}\n")
    } else {
        format!("{verdict} {name}\n")
    };
    stderr.write_all(line.as_bytes()).unwrap();
}

/// `tests/fixtures/<name>`, without an extension.
pub fn fixture(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name)
}

fn run(
    name: &str,
    kernel: &str,
    workitems: u32,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> Result<(), String> {
    let outputs = run_outputs(name, kernel, workitems, kernarg, arrays)?;
    let mut actual = String::new();
    for (array, elements) in &outputs.outputs {
        for &(index, value) in elements {
            let expr = outputs.arena.display_expr(value);
            writeln!(actual, "{array}[{index}] = {expr}").unwrap();
        }
    }
    expect_file(&fixture(name).with_extension("out"), &actual)
}

fn run_outputs(
    name: &str,
    kernel: &str,
    workitems: u32,
    kernarg: &[u8],
    arrays: &[ArrayDef],
) -> Result<SymbolicOutputs, String> {
    let source =
        std::fs::read_to_string(fixture(name).with_extension("s")).map_err(|e| e.to_string())?;
    let kernel = parse_kernel(&source, kernel).map_err(|e| e.to_string())?;

    let launch = WorkgroupLaunch {
        kernarg_address: KERNARG_ADDRESS,
        workgroup_size: (workitems, 1, 1),
    };
    let result = analyze(&kernel, &launch, kernarg, arrays).map_err(|e| e.to_string())?;

    if let Terminal::Aborted { wave, pc, error } = &result.terminal {
        return Err(format!(
            "wave {} aborted at instruction {} ({}): {error}",
            wave.0, pc.0, kernel.instructions[pc.0 as usize].opcode
        ));
    }
    result.symbolic_outputs.ok_or("no symbolic outputs".into())
}

/// Compare `actual` with the file at `path`, or rewrite the file under `VOLTA_BLESS=1`.
fn expect_file(path: &Path, actual: &str) -> Result<(), String> {
    if std::env::var_os("VOLTA_BLESS").is_some_and(|v| v == "1") {
        return std::fs::write(path, actual).map_err(|e| format!("write {}: {e}", path.display()));
    }

    let expected = std::fs::read_to_string(path).map_err(|e| {
        format!(
            "read {}: {e} (rerun with VOLTA_BLESS=1 to create it)",
            path.display()
        )
    })?;

    if actual != expected {
        return Err(format!(
            "outputs differ from {} (rerun with VOLTA_BLESS=1 to accept)",
            path.display()
        ));
    }
    Ok(())
}
