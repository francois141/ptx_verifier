//! Helpers shared by the end-to-end test crates: PTX loading, parsing, launch
//! configs, running a kernel through `volta_pipeline::verify_kernel` (the
//! analysis stage, then the graph branch), and output rendering. With
//! `VOLTA_VIZ_DIR` set (`just viz`), every kernel run is also recorded for the
//! graph viewer.

#![allow(dead_code)]

use std::cell::Cell;
use std::collections::HashMap;
use std::fmt::Write;
use std::num::NonZeroU32;
use std::ops::Deref;
use std::path::{Path, PathBuf};
use volta_expr::SymbolicOutputs;
use volta_graph::{
    AbortCause, AccessMode, AsyncOpKind, EventGraph, EventId, EventKind, ExecContext,
};
use volta_graph_check::{GraphConclusion, GraphReport};
use volta_pipeline::{KernelVerification, verify_kernel};
use volta_ptx_analysis::frontend::ascii::AsAscii;
use volta_ptx_analysis::frontend::ast::Module;
use volta_ptx_analysis::frontend::parse::Parser;
use volta_ptx_analysis::{
    AnalysisConfig, AnalysisError, AnalysisResult, ArrayDef, ArrayKind, FieldValue, Im2colBox,
    OutputsUnavailable, ParamValue, Stats, StructField, TensorElemType, TensorFillMode,
    TensorInterleaveLayout, TensorMapMode, TensorMapValue, TensorSwizzleAtomicity,
    TensorSwizzleMode, analyze,
};
use volta_viz::{Outcome, Run, RunId, write_run};

/// The PTX test kernel at `tests/ptx/<name>.ptx` as source text, or as a
/// parsed module with `ptx!(parse "<name>")`.
macro_rules! ptx {
    (parse $name:literal) => {
        parse_named($name, &ptx!($name))
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
#[allow(unused_macros)]
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

/// A parsed PTX module with the text it was parsed from, which the graph viewer shows.
pub struct Ptx {
    pub module: Module,
    pub source: String,
    /// The test kernel's name under `tests/ptx/`; `None` for source the test built.
    pub file: Option<&'static str>,
}

impl Deref for Ptx {
    type Target = Module;

    fn deref(&self) -> &Module {
        &self.module
    }
}

/// With `VOLTA_VIZ_DIR` set, write the run into that store for `volta viz`, keyed by the test
/// binary, the test (libtest names each test's thread after it) and the run's position in
/// the test: a fresh thread per test restarts the count.
fn record(ptx: &Ptx, outcome: Outcome) {
    let Some(dir) = std::env::var_os("VOLTA_VIZ_DIR") else {
        return;
    };
    thread_local! {
        static RUNS: Cell<u32> = const { Cell::new(0) };
    }
    let ordinal = RUNS.with(|runs| {
        runs.set(runs.get() + 1);
        runs.get()
    });
    let id = RunId {
        suite: env!("CARGO_CRATE_NAME").to_string(),
        test: std::thread::current()
            .name()
            .unwrap_or("unnamed")
            .to_string(),
        ordinal: NonZeroU32::new(ordinal).expect("the count starts at 1"),
    };
    let file = ptx.file.map(|name| format!("{name}.ptx"));
    let run = Run {
        id: &id,
        ptx_file: file.as_deref(),
        source: &ptx.source,
        outcome,
    };
    let dir = Path::new(&dir);
    write_run(dir, &run).unwrap_or_else(|e| panic!("record into {}: {e}", dir.display()));
}

/// An analysis that never started, for the graph viewer: a kernel Volta cannot lower is
/// unsupported.
fn not_started(e: &AnalysisError) -> Outcome<'static> {
    let cause = match e {
        AnalysisError::Lower(_) => AbortCause::Unsupported,
        AnalysisError::KernelNotFound { .. } | AnalysisError::Eval(_) => AbortCause::Error,
    };
    Outcome::NotStarted {
        cause,
        error: e.to_string(),
    }
}

/// `verify_kernel`, recorded for the graph viewer.
pub fn verify(
    ptx: &Ptx,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<KernelVerification, AnalysisError> {
    let verified = verify_kernel(ptx, kernel, config);
    let outcome = match &verified {
        Ok(v) => Outcome::Executed {
            graph: &v.analysis.graph,
            arena: v.analysis.arena(),
            report: Some(&v.graph),
        },
        Err(e) => not_started(e),
    };
    record(ptx, outcome);
    verified
}

/// The analysis stage alone (no graph check), recorded for the graph viewer.
pub fn analyze_only(
    ptx: &Ptx,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<AnalysisResult, AnalysisError> {
    let analyzed = analyze(ptx, kernel, config);
    let outcome = match &analyzed {
        Ok(r) => Outcome::Executed {
            graph: &r.graph,
            arena: r.arena(),
            report: None,
        },
        Err(e) => not_started(e),
    };
    record(ptx, outcome);
    analyzed
}

/// One kernel through the analysis stage and the graph branch.
pub struct Checked {
    pub analysis: AnalysisResult,
    pub report: GraphReport,
}

/// Run the analysis stage and the graph checks; panics if the execution cannot start (no
/// kernel, a lowering or configuration error).
pub fn check(ptx: &Ptx, kernel: Option<&str>, config: AnalysisConfig) -> Checked {
    let verified =
        verify(ptx, kernel, config).unwrap_or_else(|e| panic!("analysis cannot start: {e}"));
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
    ptx: &Ptx,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<Completed, AnalysisError> {
    let verified = verify(ptx, kernel, config)?;
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
pub fn analyze_case(name: &'static str, src: &str, config: AnalysisConfig) -> Completed {
    let output =
        run_kernel(&parse_named(name, src), None, config).unwrap_or_else(|e| panic!("{name}: {e}"));
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

/// Parse PTX source the test built.
pub fn parse(src: &str) -> Ptx {
    parse_from(None, src)
}

/// Parse the test kernel `name` (see `ptx!`).
pub fn parse_named(name: &'static str, src: &str) -> Ptx {
    parse_from(Some(name), src)
}

fn parse_from(file: Option<&'static str>, src: &str) -> Ptx {
    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    let module = Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error));
    Ptx {
        module,
        source: src.to_string(),
        file,
    }
}

/// f16 `in` and `out` arrays, sized for the tensor-map kernels' 4x4 box over an 8x8 `in`.
pub fn tma_config(threads: u32) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 64,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

/// One thread, an f32 NHWC tensor `in` of 4-channel pixels (`dims` = `[4, W, H, N]`, innermost
/// first) behind an im2col map whose column holds `pixels` pixels, and an `out` of that column's
/// rows behind a tiled map: the `maps` struct parameter's bytes 0 and 128.
pub fn im2col_config(
    dims: [u64; 4],
    element_strides: [u32; 4],
    lower_corner: [i32; 2],
    upper_corner: [i32; 2],
    pixels: u32,
) -> AnalysisConfig {
    const CHANNELS: u32 = 4;
    const ELEM_BYTES: u64 = 4;

    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: ELEM_BYTES,
            len: dims.iter().product(),
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: ELEM_BYTES,
            len: (CHANNELS * pixels) as u64,
            kind: ArrayKind::Output,
        },
    ];

    let pixel_bytes = CHANNELS as u64 * ELEM_BYTES;
    let image = TensorMapValue {
        array: "in".to_string(),
        elemtype: TensorElemType::F32,
        dims: dims.to_vec(),
        strides: vec![
            pixel_bytes,
            pixel_bytes * dims[1],
            pixel_bytes * dims[1] * dims[2],
        ],
        mode: TensorMapMode::Im2col(Im2colBox {
            lower_corner: lower_corner.to_vec(),
            upper_corner: upper_corner.to_vec(),
            channels_per_pixel: CHANNELS,
            pixels_per_column: pixels,
        }),
        element_strides: element_strides.to_vec(),
        interleave: TensorInterleaveLayout::None,
        swizzle: TensorSwizzleMode::None,
        swizzle_atomicity: TensorSwizzleAtomicity::Atomicity16B,
        fill: TensorFillMode::Zero,
    };

    let column = TensorMapValue {
        array: "out".to_string(),
        elemtype: TensorElemType::F32,
        dims: vec![CHANNELS as u64, pixels as u64],
        strides: vec![pixel_bytes],
        mode: TensorMapMode::Tiled {
            box_dims: vec![CHANNELS, pixels],
        },
        element_strides: vec![1, 1],
        interleave: TensorInterleaveLayout::None,
        swizzle: TensorSwizzleMode::None,
        swizzle_atomicity: TensorSwizzleAtomicity::Atomicity16B,
        fill: TensorFillMode::Zero,
    };

    config.params = vec![ParamValue::Struct(vec![
        StructField {
            offset: 0,
            value: FieldValue::TensorMap(Box::new(image)),
        },
        StructField {
            offset: 128,
            value: FieldValue::TensorMap(Box::new(column)),
        },
    ])];

    config
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
