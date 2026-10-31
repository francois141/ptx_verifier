//! A fixture's kernel, checked against its expected renderings beside
//! `tests/fixtures/<name>.py`: `<name>.ast` the parsed kernel and `<name>.ir`
//! the lowered one, each as its `Display` renders it. `VOLTA_BLESS=1` rewrites them.

use std::path::{Path, PathBuf};

use volta_trainium_analysis::frontend::parse::parse_kernel;
use volta_trainium_analysis::lower_kernel;

/// Parse kernel `kernel` of `tests/fixtures/<name>.py`, compare it with `<name>.ast`,
/// then lower it and compare the result with `<name>.ir`.
pub fn check(name: &str, kernel: &str) {
    let fixture = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let source = std::fs::read_to_string(fixture.with_extension("py")).unwrap();

    let parsed = parse_kernel(&source, kernel).unwrap_or_else(|e| panic!("{name}: {e}"));
    compare(fixture.with_extension("ast"), parsed.to_string());

    let lowered = lower_kernel(&parsed).unwrap_or_else(|e| panic!("{name}: {e}"));
    compare(fixture.with_extension("ir"), lowered.to_string());
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
        "kernel differs from {} (rerun with VOLTA_BLESS=1 to accept)\n\
         --- expected\n{expected}--- actual\n{actual}",
        expected_path.display()
    );
}
