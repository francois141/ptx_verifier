//! A fixture's parse, checked against its expected kernel: `tests/fixtures/<name>.ast`
//! beside `<name>.py`, the parsed kernel as its `Display` renders it.
//! `VOLTA_BLESS=1` rewrites the file instead.

use std::path::Path;

use volta_trainium_analysis::frontend::parse::parse_kernel;

/// Parse kernel `kernel` of `tests/fixtures/<name>.py` and compare it with `<name>.ast`.
pub fn check_parse(name: &str, kernel: &str) {
    let fixture = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures")
        .join(name);
    let source = std::fs::read_to_string(fixture.with_extension("py")).unwrap();
    let actual = parse_kernel(&source, kernel)
        .unwrap_or_else(|e| panic!("{name}: {e}"))
        .to_string();

    print!("{actual}");

    let ast_path = fixture.with_extension("ast");
    if std::env::var_os("VOLTA_BLESS").is_some_and(|v| v == "1") {
        std::fs::write(&ast_path, &actual)
            .unwrap_or_else(|e| panic!("write {}: {e}", ast_path.display()));
        return;
    }

    let expected = std::fs::read_to_string(&ast_path).unwrap_or_else(|e| {
        panic!(
            "read {}: {e} (rerun with VOLTA_BLESS=1 to create it)",
            ast_path.display()
        )
    });

    assert!(
        actual == expected,
        "parsed kernel differs from {} (rerun with VOLTA_BLESS=1 to accept)\n\
         --- expected\n{expected}--- actual\n{actual}",
        ast_path.display()
    );
}
