//! A fixture's kernel, checked against its expected renderings beside `tests/fixtures/<name>.py`:
//! `<name>.ast` and `<name>.ir` the parsed and lowered kernel as `Display` renders them, and
//! `<name>.out` its run's written elements. `VOLTA_BLESS=1` rewrites them.

use std::fmt::Write;
use std::path::{Path, PathBuf};

use volta_trainium_analysis::frontend::parse::parse_kernel;
use volta_trainium_analysis::{evaluate, lower_kernel};

/// Parse, lower and run kernel `kernel` of `tests/fixtures/<name>.py`, comparing each stage's
/// result with its file; `.out` holds one `array[index] = expr` line per written element.
pub fn check(name: &str, kernel: &str) {
    let fixture = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let source = std::fs::read_to_string(fixture.with_extension("py")).unwrap();

    let parsed = parse_kernel(&source, kernel).unwrap_or_else(|e| panic!("{name}: {e}"));
    compare(fixture.with_extension("ast"), parsed.to_string());

    let lowered = lower_kernel(&parsed).unwrap_or_else(|e| panic!("{name}: {e}"));
    compare(fixture.with_extension("ir"), lowered.to_string());

    let outputs = evaluate(&lowered).unwrap_or_else(|e| panic!("{name}: {e}"));
    let mut rendered = String::new();
    for (array, elements) in &outputs.outputs {
        for &(index, value) in elements {
            let expr = outputs.arena.display_expr(value);
            writeln!(rendered, "{array}[{index}] = {expr}").unwrap();
        }
    }
    compare(fixture.with_extension("out"), rendered);
}

fn compare(expected_path: PathBuf, actual: String) {
    print!("{actual}");

    if std::env::var_os("VOLTA_BLESS").is_some_and(|v| v == "1") {
        std::fs::write(&expected_path, &actual)
            .unwrap_or_else(|e| panic!("write {}: {e}", expected_path.display()));
        return;
    }

    let expected = std::fs::read_to_string(&expected_path).unwrap_or_else(|e| {
        panic!(
            "read {}: {e} (rerun with VOLTA_BLESS=1 to create it)",
            expected_path.display()
        )
    });

    assert!(
        actual == expected,
        "rendering differs from {} (rerun with VOLTA_BLESS=1 to accept)\n\
         --- expected\n{expected}--- actual\n{actual}",
        expected_path.display()
    );
}
