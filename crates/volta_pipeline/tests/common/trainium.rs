//! A fixture's kernel, checked against its expected renderings beside `tests/trainium/<name>.py`:
//! `<name>.ast` and `<name>.ir` the parsed and lowered kernel as `Display` renders them,
//! `<name>.out` its run's written elements, and for `FOOTPRINTS` fixtures `<name>.footprints`
//! each instruction's accesses. `VOLTA_BLESS=1` rewrites them, never `<name>.expected`:
//! the written elements derived from the kernel's math, not from a run. Before its outputs
//! are compared, a `success/` fixture's graph must be `Verified` under
//! `OrderingPolicy::BASELINE`, and a `check_failure/` fixture's `Rejected`.

use std::fmt::Write;
use std::path::{Path, PathBuf};

use volta_graph_check::{GraphConclusion, check_graph};
use volta_trainium_analysis::frontend::ast::Kernel;
use volta_trainium_analysis::frontend::parse::{KernelCall, parse_kernel_for_call};
use volta_trainium_analysis::{
    Access, Location, LoweredKernel, Mode, OrderingPolicy, PARTITION_STRIDE, Reducer, evaluate,
    footprints, lower_kernel, record_graph,
};

/// The fixtures whose footprints are snapshotted: every race fixture (`check_failure/`),
/// the race-free `sequential_carried`, `affine_matmul_accumulate` and `affine_vector_sum`, and
/// one per kind of location (placed tiles, access patterns, gathers, loops).
const FOOTPRINTS: &[&str] = &[
    "success/affine_vector_sum",
    "success/sequential_carried",
    "success/affine_matmul_accumulate",
    "success/placed_tiles",
    "success/access_patterns",
    "success/indirect",
    "success/loop_origins",
];

fn snapshots_footprints(name: &str) -> bool {
    name.starts_with("check_failure/") || FOOTPRINTS.contains(&name)
}

/// Parse, lower and run kernel `kernel` of `tests/trainium/<name>.py` for a call with
/// parameter `shapes`, comparing each stage's result with its file; `.out` holds one
/// `array[index] = expr` line per written element.
pub fn check(name: &str, kernel: &str, shapes: &[(&str, &[u64])]) {
    check_importing(name, kernel, &[], shapes);
}

/// `check` for a fixture that imports from `modules`, each a `<module>.py` beside it.
pub fn check_importing(name: &str, kernel: &str, modules: &[&str], shapes: &[(&str, &[u64])]) {
    check_call(name, kernel, modules, &KernelCall::new(shapes));
}

/// `check_importing` for `call`, which may give dtypes and tile sizes too.
pub fn check_call(name: &str, kernel: &str, modules: &[&str], call: &KernelCall) {
    let fixture = fixtures().join(name);
    let (_, lowered) = lower_call(name, kernel, modules, call);
    if snapshots_footprints(name) {
        compare(
            fixture.with_extension("footprints"),
            render_footprints(&lowered),
        );
    }

    let conclusion = check_graph(&record_graph(&lowered, OrderingPolicy::BASELINE)).conclusion();
    match (Folder::of(name), &conclusion) {
        (Folder::Success, GraphConclusion::Verified)
        | (Folder::CheckFailure, GraphConclusion::Rejected { .. }) => {}
        (folder, conclusion) => panic!("{name}: a {folder:?} fixture concluded {conclusion:?}"),
    }

    let outputs = evaluate(&lowered).unwrap_or_else(|e| panic!("{name}: {e}"));
    let mut rendered = String::new();
    for (array, elements) in &outputs.outputs {
        for &(index, value) in elements {
            let expr = outputs.arena.display_expr(value);
            writeln!(rendered, "{array}[{index}] = {expr}").unwrap();
        }
    }
    compare(fixture.with_extension("out"), rendered.clone());
    compare_with_expected(fixture.with_extension("expected"), &rendered);
}

/// The outcome folder a fixture is in, which fixes the graph conclusion `check_call` requires
/// under `OrderingPolicy::BASELINE`.
#[derive(Debug, Clone, Copy)]
enum Folder {
    Success,
    CheckFailure,
}

impl Folder {
    fn of(name: &str) -> Folder {
        match name.split('/').next() {
            Some("success") => Folder::Success,
            Some("check_failure") => Folder::CheckFailure,
            _ => panic!("{name}: checked fixtures live in success/ or check_failure/"),
        }
    }
}

/// Parse and lower kernel `kernel` of `tests/trainium/<name>.py`, which imports from
/// `modules`, comparing the two stages' results with `<name>.ast` and `<name>.ir`.
pub fn check_lowering(
    name: &str,
    kernel: &str,
    modules: &[&str],
    shapes: &[(&str, &[u64])],
) -> (Kernel, LoweredKernel) {
    lower_call(name, kernel, modules, &KernelCall::new(shapes))
}

fn lower_call(
    name: &str,
    kernel: &str,
    modules: &[&str],
    call: &KernelCall,
) -> (Kernel, LoweredKernel) {
    let fixture = fixtures().join(name);
    let source = std::fs::read_to_string(fixture.with_extension("py")).unwrap();
    let sources: Vec<(String, String)> = modules
        .iter()
        .map(|module| {
            let path = fixture.with_file_name(format!("{module}.py"));
            let source = std::fs::read_to_string(&path)
                .unwrap_or_else(|e| panic!("read {}: {e}", path.display()));
            let name = path.file_stem().unwrap().to_str().unwrap().to_string();
            (name, source)
        })
        .collect();
    let sources: Vec<(&str, &str)> = sources
        .iter()
        .map(|(name, source)| (name.as_str(), source.as_str()))
        .collect();

    let parsed = parse_kernel_for_call(&source, &sources, kernel, call)
        .unwrap_or_else(|e| panic!("{name}: {e}"));
    let lowered = lower_kernel(&parsed).unwrap_or_else(|e| panic!("{name}: {e}"));
    let base = fixture.with_file_name(match kernel {
        "kernel" => name.rsplit('/').next().unwrap().to_string(),
        kernel => kernel.to_string(),
    });
    compare(base.with_extension("ast"), parsed.to_string());
    compare(base.with_extension("ir"), lowered.to_string());
    (parsed, lowered)
}

/// One line per instruction: each access's mode, tensor and runs, a placed tile's as
/// `p<partition>:<bytes>`, any other's as element offsets.
fn render_footprints(kernel: &LoweredKernel) -> String {
    let mut out = String::new();
    for (instr, accesses) in footprints(kernel).iter() {
        let rendered: Vec<String> = accesses
            .iter()
            .map(|access: &Access| {
                let mode = match access.mode {
                    Mode::Read => "read".to_string(),
                    Mode::Write => "write".to_string(),
                    Mode::Accumulate(Reducer::Matmul) => "accumulate(matmul)".to_string(),
                    Mode::Accumulate(Reducer::Elementwise(op)) => {
                        format!("accumulate({})", op.name())
                    }
                };
                let runs: Vec<String> = access
                    .runs
                    .iter()
                    .map(|run| match access.location {
                        Location::Placed(_) => format!(
                            "p{}:{}..{}",
                            run.start / PARTITION_STRIDE,
                            run.start % PARTITION_STRIDE,
                            run.end - run.start / PARTITION_STRIDE * PARTITION_STRIDE
                        ),
                        Location::Elements(_) => format!("{}..{}", run.start, run.end),
                    })
                    .collect();
                let name = &kernel.tensors[access.tensor].name;
                format!("{mode} {name}[{}]", runs.join(", "))
            })
            .collect();
        writeln!(out, "{}: {}", instr.0, rendered.join("; ")).unwrap();
    }
    out
}

/// The source of `tests/trainium/<name>.py`.
pub fn source(name: &str) -> String {
    let path = fixtures().join(name).with_extension("py");
    std::fs::read_to_string(&path).unwrap_or_else(|e| panic!("read {}: {e}", path.display()))
}

pub fn fixtures() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/trainium")
}

fn compare_with_expected(expected_path: PathBuf, actual: &str) {
    let expected = std::fs::read_to_string(&expected_path)
        .unwrap_or_else(|e| panic!("read {}: {e}", expected_path.display()));

    assert!(
        actual == expected,
        "outputs differ from {}, which VOLTA_BLESS does not rewrite\n\
         --- expected\n{expected}--- actual\n{actual}",
        expected_path.display()
    );
}

/// `actual` against the file at `expected_path`; `VOLTA_BLESS=1` rewrites it.
pub fn compare(expected_path: PathBuf, actual: String) {
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
