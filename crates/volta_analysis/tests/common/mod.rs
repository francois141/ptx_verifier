//! Helpers shared by the evaluator test crates: PTX loading, parsing,
//! launch configs, and output rendering.

#![allow(dead_code)]

use std::collections::HashMap;
use std::fmt::Write;
use std::path::{Path, PathBuf};
use volta_analysis::driver::analyze_kernel;
use volta_analysis::eval::{AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, ParamValue};
use volta_frontend::ascii::AsAscii;
use volta_frontend::ast::Module;
use volta_frontend::parse::Parser;

/// The PTX test kernel at `tests/ptx/<name>.ptx` as source text, or as a
/// parsed module with `ptx!(parse "<name>")`.
macro_rules! ptx {
    (parse $name:literal) => {
        parse(&ptx!($name))
    };
    ($name:literal) => {
        include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/tests/ptx/",
            $name,
            ".ptx"
        ))
        .to_string()
    };
}

/// `(name, source)` for the PTX test kernel `name`, so failures name the file.
macro_rules! ptx_case {
    ($name:literal) => {
        ($name, ptx!($name))
    };
}

/// Analyzes the PTX test kernel `name` under `config`, checking its outputs
/// against `tests/ptx/<name>.out` (see `assert_out_file`).
#[allow(unused_macros)]
macro_rules! analyze {
    ($name:literal, $config:expr) => {
        analyze_case($name, &ptx!($name), $config)
    };
}

pub fn ptx_path(name: &str) -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/ptx")
        .join(format!("{name}.ptx"))
}

/// `analyze!` for a `(name, source)` pair from `ptx_case!`.
pub fn analyze_case(name: &str, src: &str, config: AnalysisConfig) -> AnalysisOutput {
    let output =
        analyze_kernel(&parse(src), None, config).unwrap_or_else(|e| panic!("{name}: {e}"));
    assert_out_file(&ptx_path(name), &output);
    output
}

/// Every written output element as `array[index] = expr`, one per line.
/// Machine symbols come from a process-global counter, so they are renamed
/// `s0, s1, ...` in order of first appearance to keep the text deterministic.
pub fn render_outputs(output: &AnalysisOutput) -> String {
    let mut text = String::new();
    for (array, elems) in &output.outputs {
        for (index, expr) in elems {
            writeln!(
                text,
                "{array}[{index}] = {}",
                output.arena.display_expr(*expr)
            )
            .unwrap();
        }
    }
    renumber_machine_symbols(&text)
}

fn renumber_machine_symbols(text: &str) -> String {
    let mut renamed: HashMap<&str, usize> = HashMap::new();
    let mut result = String::with_capacity(text.len());
    let bytes = text.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        let starts_symbol = bytes[i] == b's'
            && (i == 0 || !(bytes[i - 1].is_ascii_alphanumeric() || bytes[i - 1] == b'_'))
            && bytes.get(i + 1).is_some_and(u8::is_ascii_digit);
        if !starts_symbol {
            result.push(bytes[i] as char);
            i += 1;
            continue;
        }
        let end = (i + 1..bytes.len())
            .find(|&j| !bytes[j].is_ascii_digit())
            .unwrap_or(bytes.len());
        let next = renamed.len();
        let number = *renamed.entry(&text[i..end]).or_insert(next);
        write!(result, "s{number}").unwrap();
        i = end;
    }
    result
}

/// Checks `render_outputs(output)` against the `.out` file beside
/// `ptx_path`. `VOLTA_BLESS=1` (re)writes the file instead.
pub fn assert_out_file(ptx_path: &Path, output: &AnalysisOutput) {
    let out_path = ptx_path.with_extension("out");
    let actual = render_outputs(output);
    if std::env::var_os("VOLTA_BLESS").is_some_and(|v| v == "1") {
        std::fs::write(&out_path, &actual)
            .unwrap_or_else(|e| panic!("write {}: {e}", out_path.display()));
        return;
    }
    let expected = std::fs::read_to_string(&out_path).unwrap_or_else(|e| {
        panic!(
            "read {}: {e} (rerun with VOLTA_BLESS=1 to create it)",
            out_path.display()
        )
    });
    assert!(
        actual == expected,
        "outputs differ from {} (rerun with VOLTA_BLESS=1 to accept)\n\
         --- expected\n{expected}--- actual\n{actual}",
        out_path.display()
    );
}

pub fn parse(src: &str) -> Module {
    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error))
}

/// in/out f32 arrays at fixed bases.
pub fn in_out_config(threads: u32, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

pub fn display_output(output: &AnalysisOutput, array: &str, index: u64) -> String {
    let (_, elems) = output
        .outputs
        .iter()
        .find(|(n, _)| n == array)
        .expect("output array");
    let (_, e) = elems
        .iter()
        .find(|(i, _)| *i == index)
        .expect("element written");
    output.arena.display_expr(*e)
}

/// A byte-element global scratch array (kind Input, so it is never
/// compared as an output) plus a u32 `out` array.
pub fn u8_scratch_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "scratch".to_string(),
            base: 0x30000,
            elem_width: 1,
            len: 8,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("scratch".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

// Two-warp CTA: thread 0 arms the `count = 1` mbarrier `full` (`%r4`) for 16
// bytes and bulk-copies `in[0..4]` into `buf`. `%r6` = `count = 32` `gate`,
// `%p2` = "in warp 0".

/// `in` as four `u32`s, passed as the kernel's only parameter.
pub fn bulk_copy_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "in".to_string(),
        base: 0x10000,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    }];
    config.params = vec![ParamValue::ArrayPtr("in".to_string())];
    config
}
