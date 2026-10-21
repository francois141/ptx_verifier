//! Helpers shared by the end-to-end test crates: PTX loading, parsing, launch
//! configs, running a kernel through `volta_pipeline::verify_kernel` (the
//! analysis stage, then the graph branch), and output rendering.

#![allow(dead_code)]

use std::collections::HashMap;
use std::fmt::Write;
use std::path::{Path, PathBuf};
use volta_analysis::{
    AnalysisConfig, AnalysisError, AnalysisResult, ArrayDef, ArrayKind, OutputsUnavailable,
    ParamValue, Stats,
};
use volta_expr::SymbolicOutputs;
use volta_frontend::ascii::AsAscii;
use volta_frontend::ast::Module;
use volta_frontend::parse::Parser;
use volta_graph::{AccessMode, AsyncOpKind, EventGraph, EventId, EventKind, ExecContext};
use volta_graph_check::{GraphConclusion, GraphReport};
use volta_pipeline::verify_kernel;

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

/// One kernel through the analysis stage and the graph branch.
pub struct Checked {
    pub analysis: AnalysisResult,
    pub report: GraphReport,
}

/// Run the analysis stage and the six graph checks; panics if the execution cannot start (no
/// kernel, a lowering or configuration error).
pub fn check(module: &Module, kernel: Option<&str>, config: AnalysisConfig) -> Checked {
    let verified = verify_kernel(module, kernel, config)
        .unwrap_or_else(|e| panic!("analysis cannot start: {e}"));
    Checked {
        analysis: verified.analysis,
        report: verified.graph,
    }
}

/// One side of a witness: the thread it acts for, its access mode, and the async op it is an
/// effect of (`None` for a thread's own access).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Side {
    pub thread: u32,
    pub mode: AccessMode,
    pub op: Option<AsyncOpKind>,
}

impl Side {
    pub fn plain(thread: u32, mode: AccessMode) -> Side {
        Side {
            thread,
            mode,
            op: None,
        }
    }

    pub fn effect(thread: u32, mode: AccessMode, op: AsyncOpKind) -> Side {
        Side {
            thread,
            mode,
            op: Some(op),
        }
    }
}

/// The witness side of access event `e`.
pub fn side(graph: &EventGraph, e: EventId) -> Side {
    let ev = graph.event(e);
    let EventKind::Access(a) = ev.kind else {
        panic!("event {} is not a memory access: {:?}", e.0, ev.kind);
    };
    Side {
        thread: graph
            .acting_thread(e)
            .expect("an access acts for a thread")
            .0,
        mode: graph.access(a).mode,
        op: match ev.ctx {
            ExecContext::Async(op) => Some(graph.async_op(op).kind),
            ExecContext::Thread(_) | ExecContext::Generation(_) => None,
        },
    }
}

pub fn warp(thread: u32) -> u32 {
    thread / 32
}

/// A kernel that ran to completion and whose graph check concluded `Verified`.
#[derive(Debug)]
pub struct Completed {
    pub exprs: SymbolicOutputs,
    pub stats: Stats,
}

/// Run a kernel expected to complete: its outputs, or why it produced none (it could not
/// start, or its execution raised an error). A failed graph check or a deadlock panics, and so
/// does a completed run the graph check does not conclude `Verified`; tests expecting either
/// inspect `check`'s report.
pub fn run_kernel(
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<Completed, AnalysisError> {
    let verified = verify_kernel(module, kernel, config)?;
    let conclusion = verified.graph.conclusion();
    if let GraphConclusion::Rejected { failed, deadlock } = &conclusion {
        panic!("the graph branch rejected the kernel: {failed:#?}, deadlock: {deadlock:#?}");
    }
    let parts = verified.analysis.into_parts();
    match parts.outputs {
        Ok(exprs) => {
            if let GraphConclusion::Unknown { reasons } = conclusion {
                panic!("the graph check did not verify the kernel: {reasons:#?}");
            }
            Ok(Completed {
                exprs,
                stats: parts.stats,
            })
        }
        Err(OutputsUnavailable::Aborted(e) | OutputsUnavailable::Extraction(e)) => {
            Err(AnalysisError::Eval(e))
        }
        Err(why @ OutputsUnavailable::Stuck { .. }) => {
            panic!("a stuck execution was not rejected as a deadlock: {why}")
        }
    }
}

/// `analyze!` for a `(name, source)` pair from `ptx_case!`.
pub fn analyze_case(name: &str, src: &str, config: AnalysisConfig) -> Completed {
    let output = run_kernel(&parse(src), None, config).unwrap_or_else(|e| panic!("{name}: {e}"));
    assert_out_file(&ptx_path(name), &output);
    output
}

/// Every written output element as `array[index] = expr`, one per line.
/// Machine symbols come from a process-global counter, so they are renamed
/// `s0, s1, ...` in order of first appearance to keep the text deterministic.
pub fn render_outputs(output: &Completed) -> String {
    let mut text = String::new();
    for (array, elems) in &output.exprs.outputs {
        for (index, expr) in elems {
            writeln!(
                text,
                "{array}[{index}] = {}",
                output.exprs.arena.display_expr(*expr)
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
pub fn assert_out_file(ptx_path: &Path, output: &Completed) {
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

pub fn display_output(output: &Completed, array: &str, index: u64) -> String {
    let e = output
        .exprs
        .element(array, index)
        .unwrap_or_else(|| panic!("{array}[{index}] not written"));
    output.exprs.arena.display_expr(e)
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
