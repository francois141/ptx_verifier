//! Volta CLI - PTX analysis tool: `parse <file>` (syntax check), `analyze <file>` (symbolically
//! execute one kernel), `compare <file1> <file2>` (equivalence), `verify <file>` (against a spec),
//! `viz <store>` (the event-graph viewer page over recorded runs).

use std::collections::{BTreeMap, HashMap};
use std::num::NonZeroUsize;
use std::path::{Path, PathBuf};
use std::process::ExitCode;
use std::time::Instant;

use clap::{Args, Parser, Subcommand};
use volta_analysis::frontend::ascii::{AsAscii, AsciiChar};
use volta_analysis::frontend::ast::{Module, TopLevelItem};
use volta_analysis::frontend::parse;
use volta_analysis::{
    AnalysisConfig, AnalysisParts, ArrayDef, ArrayKind, OutputsUnavailable, ParamValue, Stats,
    write_op_counts,
};
use volta_common::file_cache::FileCache;
use volta_common::report::{Report, locate_path, report_error};
use volta_common::run_log;
use volta_equivalence::equiv::DEFAULT_RECYCLE_TERMS;
use volta_equivalence::vc_dump::{VcDump, read_vc_dump, write_vc_dump};
use volta_equivalence::{EquivCheckOptions, EquivOutcome};
use volta_expr::SymbolicOutputs;
use volta_graph::EventGraph;
use volta_graph_check::{GraphConclusion, GraphReport};
use volta_pipeline::{
    Decision, EquivalenceVerdict, KernelEvidence, Verdict, check_equivalence, decide, verify_kernel,
};
use volta_spec::unfold;

/// Log level for controlling output verbosity
#[cfg(feature = "logging")]
#[derive(Debug, Clone, Copy, Default, clap::ValueEnum)]
enum LogLevel {
    /// Only show errors
    Error,
    /// Show warnings and errors
    #[default]
    Warn,
    /// Show info, warnings, and errors
    Info,
    /// Show debug output and above
    Debug,
    /// Show all log output including trace
    Trace,
}

#[cfg(feature = "logging")]
impl From<LogLevel> for log::LevelFilter {
    fn from(level: LogLevel) -> Self {
        match level {
            LogLevel::Error => log::LevelFilter::Error,
            LogLevel::Warn => log::LevelFilter::Warn,
            LogLevel::Info => log::LevelFilter::Info,
            LogLevel::Debug => log::LevelFilter::Debug,
            LogLevel::Trace => log::LevelFilter::Trace,
        }
    }
}

#[derive(Parser)]
#[command(name = "volta")]
#[command(about = "The Volta PTX analysis engine.")]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Log level for output verbosity
    #[cfg(feature = "logging")]
    #[arg(long, value_enum, default_value = "warn", global = true)]
    log_level: LogLevel,

    /// Directory for per-run log files
    #[arg(long, global = true, default_value = "volta-logs")]
    log_dir: PathBuf,

    /// Don't write a per-run log file
    #[arg(long, global = true)]
    no_log_file: bool,
}

#[derive(Subcommand)]
enum Commands {
    /// Parse a PTX file and check for syntax errors
    Parse {
        /// PTX file to parse
        file: PathBuf,
    },

    /// Symbolically execute a kernel: detect races/deadlocks and print the
    /// symbolic output tensors
    Analyze(AnalyzeArgs),

    /// Check two kernels for semantic equivalence (each is also checked for
    /// data races/deadlocks). Arrays/params/globals are shared by both
    /// kernels unless a `--block2`/`--grid2` override is given.
    Compare(CompareArgs),

    /// Check one kernel against a math spec (and for races/deadlocks). SPEC is a `.spec` path, or
    /// inline spec source if no such file exists; every array with a spec output equation must be a
    /// declared output array of the kernel.
    Verify(VerifyArgs),

    /// Build the event-graph viewer: one self-contained HTML page over a store of recorded runs
    /// (`just viz` records every volta_pipeline test into one, then builds the page)
    Viz(VizArgs),
}

#[derive(Args)]
struct VizArgs {
    /// Directory of recorded runs (the `VOLTA_VIZ_DIR` the tests recorded into)
    store: PathBuf,

    /// The HTML page to write
    #[arg(short, long, default_value = "volta-graphs.html")]
    output: PathBuf,
}

/// Launch configuration shared by `analyze` and `compare` (flattened into both, so they cannot
/// drift apart). For `compare` it describes the reference kernel; `--block2`/`--grid2` override
/// the optimized kernel's dims.
#[derive(Args)]
struct LaunchArgs {
    /// Block dimensions, e.g. "128" or "32,4,1"
    #[arg(short, long, default_value = "1")]
    block: String,

    /// Grid dimensions, e.g. "64,64"
    #[arg(short, long, default_value = "1")]
    grid: String,

    /// Global array: "name:base:elem_width:len:kind" where kind is
    /// in|out|inout|index (e.g. "in:0x10000:4:128:in"). Repeatable.
    #[arg(long = "array")]
    arrays: Vec<String>,

    /// Kernel parameter (in declaration order): "int:N", "float:X",
    /// "sym:name", or "ptr:array_name". Repeatable.
    #[arg(long = "param")]
    params: Vec<String>,

    /// Module-scope .global variable value: "NAME=value". Repeatable.
    #[arg(long = "global")]
    globals: Vec<String>,

    /// Dynamic (extern) shared memory size in bytes
    #[arg(long, default_value_t = 0)]
    dyn_shared: u64,
}

#[derive(Args)]
struct AnalyzeArgs {
    /// PTX file to analyze
    file: PathBuf,

    /// Kernel entry name (defaults to the first kernel in the module)
    #[arg(short, long)]
    kernel: Option<String>,

    #[command(flatten)]
    launch: LaunchArgs,

    /// Print up to N elements of each output array
    #[arg(long, default_value_t = 8)]
    print_outputs: u64,

    /// Skip the per-instruction-kind execution profile (shown by default)
    #[arg(long = "no-profile", action = clap::ArgAction::SetFalse, default_value_t = true)]
    profile: bool,

    /// Write the output expressions to this file in the `.vexpr` text format,
    /// which `compare --exprs` reads back.
    #[arg(long, value_name = "FILE")]
    emit_exprs: Option<PathBuf>,

    /// Write the candidate execution's event graph to this file in the
    /// deterministic `volta-graph 1` text format (also when the run fails).
    #[arg(long, value_name = "FILE")]
    dump_graph: Option<PathBuf>,
}

#[derive(Args)]
struct CompareArgs {
    /// Reference PTX file, or `.vexpr` file with --exprs (omit when using --from-dump)
    file1: Option<PathBuf>,

    /// Optimized PTX file, or `.vexpr` file with --exprs (omit when using --from-dump)
    file2: Option<PathBuf>,

    /// FILE1 and FILE2 are `.vexpr` expression files (from `analyze --emit-exprs`):
    /// check them directly, without parsing PTX or running symbolic execution.
    #[arg(long, conflicts_with_all = ["from_dump", "dump_vcs"])]
    exprs: bool,

    /// Reference kernel entry name (defaults to the first in the module)
    #[arg(long)]
    kernel1: Option<String>,

    /// Optimized kernel entry name (defaults to the first in the module)
    #[arg(long)]
    kernel2: Option<String>,

    #[command(flatten)]
    launch: LaunchArgs,

    /// Block dimensions for the optimized kernel only, if it differs
    #[arg(long)]
    block2: Option<String>,

    /// Grid dimensions for the optimized kernel only, if it differs
    #[arg(long)]
    grid2: Option<String>,

    /// Output array to check, by name (repeatable, at least one required; order = check order).
    /// Must be a declared output array of the launch config (with --from-dump: of the dump).
    #[arg(long = "check-array", value_name = "NAME", required = true)]
    check_arrays: Vec<String>,

    /// Check at most this many common elements per array (0 = all)
    #[arg(long, default_value_t = 0)]
    sample: u64,

    /// Confirm every verdict with the f64 numeric oracle
    #[arg(long)]
    verify_numeric: bool,

    /// Recycle the VC intern tables past this many interned terms (0 = never)
    #[arg(long, default_value_t = DEFAULT_RECYCLE_TERMS)]
    recycle_terms: usize,

    /// Run the solve phase N times (fresh session each; verdict from
    /// iteration 1, later iterations must agree)
    #[arg(long, default_value_t = NonZeroUsize::MIN)]
    iterations: NonZeroUsize,

    /// Skip the per-instruction-kind execution profile (shown by default)
    #[arg(long = "no-profile", action = clap::ArgAction::SetFalse, default_value_t = true)]
    profile: bool,

    /// After symbolic execution, dump both kernels' verification conditions (arena + output
    /// footprint) to this file; --from-dump reruns the check without parsing/symbolic execution.
    #[arg(long)]
    dump_vcs: Option<PathBuf>,

    /// Skip parsing and symbolic execution entirely and check
    /// equivalence directly from a --dump-vcs file. FILE1/FILE2 and the
    /// launch-config flags are ignored when this is set.
    #[arg(long)]
    from_dump: Option<PathBuf>,
}

#[derive(Args)]
struct VerifyArgs {
    /// PTX file to verify
    file: PathBuf,

    /// Kernel entry name (defaults to the first kernel in the module)
    #[arg(short, long)]
    kernel: Option<String>,

    /// Path to a .spec file, or inline spec source (e.g.
    /// "dim N; array A[N]; array C[N]; C[i] = A[i];"). Tried as a file
    /// path first; if no such file exists, parsed directly as spec text.
    spec: String,

    #[command(flatten)]
    launch: LaunchArgs,

    /// Concrete value for a spec `dim`: "NAME=VALUE" (hex with a 0x
    /// prefix). Repeatable - one per `dim` the spec declares.
    #[arg(long = "dim", value_name = "NAME=VALUE")]
    dims: Vec<String>,

    /// Check at most this many common elements per output array (0 = all)
    #[arg(long, default_value_t = 0)]
    sample: u64,

    /// Confirm every verdict with the f64 numeric oracle
    #[arg(long)]
    verify_numeric: bool,

    /// Recycle the VC intern tables past this many interned terms (0 = never)
    #[arg(long, default_value_t = DEFAULT_RECYCLE_TERMS)]
    recycle_terms: usize,

    /// Run the solve phase N times (fresh session each; verdict from
    /// iteration 1, later iterations must agree)
    #[arg(long, default_value_t = NonZeroUsize::MIN)]
    iterations: NonZeroUsize,

    /// Skip the per-instruction-kind execution profile (shown by default)
    #[arg(long = "no-profile", action = clap::ArgAction::SetFalse, default_value_t = true)]
    profile: bool,
}

fn main() -> ExitCode {
    let cli = Cli::parse();

    let command_name = match &cli.command {
        Commands::Parse { .. } => "parse",
        Commands::Analyze(_) => "analyze",
        Commands::Compare(_) => "compare",
        Commands::Verify(_) => "verify",
        Commands::Viz(_) => "viz",
    };
    let mut log = run_log::RunLog::open(&cli.log_dir, command_name, cli.no_log_file);

    #[cfg(feature = "logging")]
    env_logger::Builder::new()
        .filter_level(cli.log_level.into())
        .format_timestamp(None)
        .format_target(false)
        .target(env_logger::Target::Pipe(log.tee(std::io::stderr())))
        .init();

    let code = match cli.command {
        Commands::Parse { file } => cmd_parse(&file),
        Commands::Analyze(args) => cmd_analyze(args, &mut log),
        Commands::Compare(args) => cmd_compare(args, &mut log),
        Commands::Verify(args) => cmd_verify(args, &mut log),
        Commands::Viz(args) => cmd_viz(&args),
    };

    if let Some(path) = log.path() {
        eprintln!("log: {}", path.display());
    }
    code
}

/// Parse "x[,y[,z]]" dimensions.
fn parse_dims(s: &str) -> Result<(u32, u32, u32), String> {
    let mut parts = s.split(',').map(|p| p.trim().parse::<u32>());
    let x = parts
        .next()
        .transpose()
        .map_err(|e| e.to_string())?
        .unwrap_or(1);
    let y = parts
        .next()
        .transpose()
        .map_err(|e| e.to_string())?
        .unwrap_or(1);
    let z = parts
        .next()
        .transpose()
        .map_err(|e| e.to_string())?
        .unwrap_or(1);
    Ok((x, y, z))
}

fn parse_u64_value(s: &str) -> Result<u64, String> {
    if let Some(hex) = s.strip_prefix("0x") {
        u64::from_str_radix(hex, 16).map_err(|e| e.to_string())
    } else {
        s.parse()
            .map_err(|e: std::num::ParseIntError| e.to_string())
    }
}

/// Parse "name:base:elem_width:len:kind".
fn parse_array(s: &str) -> Result<ArrayDef, String> {
    let parts: Vec<&str> = s.split(':').collect();
    let [name, base, elem_width, len, kind] = parts.as_slice() else {
        return Err(format!(
            "expected name:base:elem_width:len:kind, got '{}'",
            s
        ));
    };
    let kind = match *kind {
        "in" => ArrayKind::Input,
        "out" => ArrayKind::Output,
        "inout" => ArrayKind::InputOutput,
        "index" => ArrayKind::IndexInput,
        other => return Err(format!("unknown array kind '{}'", other)),
    };
    Ok(ArrayDef {
        name: name.to_string(),
        base: parse_u64_value(base)?,
        elem_width: parse_u64_value(elem_width)?,
        len: parse_u64_value(len)?,
        kind,
    })
}

/// Parse "int:N" | "float:X" | "sym:name" | "ptr:array".
fn parse_param(s: &str) -> Result<ParamValue, String> {
    let Some((kind, value)) = s.split_once(':') else {
        return Err(format!("expected kind:value, got '{}'", s));
    };
    match kind {
        "int" => Ok(ParamValue::Int(
            value.parse().map_err(|e| format!("{}", e))?,
        )),
        "float" => Ok(ParamValue::Float(
            value.parse().map_err(|e| format!("{}", e))?,
        )),
        "sym" => Ok(ParamValue::SymFloat(value.to_string())),
        "ptr" => Ok(ParamValue::ArrayPtr(value.to_string())),
        other => Err(format!("unknown param kind '{}'", other)),
    }
}

/// Shared launch-config inputs, parsed into an `AnalysisConfig` by
/// `build_config`. Used by both `analyze` and `compare` so the two
/// commands' array/param/global flags behave identically.
struct ConfigInput<'a> {
    block: &'a str,
    grid: &'a str,
    arrays: &'a [String],
    params: &'a [String],
    globals: &'a [String],
    dyn_shared: u64,
}

impl<'a> ConfigInput<'a> {
    /// The reference-kernel launch config straight from the shared flags.
    /// `compare` overrides `block`/`grid` afterwards for the optimized
    /// kernel via `--block2`/`--grid2`.
    fn from_launch(launch: &'a LaunchArgs) -> Self {
        Self {
            block: &launch.block,
            grid: &launch.grid,
            arrays: &launch.arrays,
            params: &launch.params,
            globals: &launch.globals,
            dyn_shared: launch.dyn_shared,
        }
    }
}

fn build_config(input: ConfigInput) -> Result<AnalysisConfig, String> {
    let block_dim = parse_dims(input.block).map_err(|e| format!("invalid --block: {}", e))?;
    let mut config = AnalysisConfig::new(block_dim);
    config.grid_dim = parse_dims(input.grid).map_err(|e| format!("invalid --grid: {}", e))?;
    config.dynamic_shared_bytes = input.dyn_shared;
    for a in input.arrays {
        config
            .arrays
            .push(parse_array(a).map_err(|e| format!("invalid --array: {}", e))?);
    }
    for p in input.params {
        config
            .params
            .push(parse_param(p).map_err(|e| format!("invalid --param: {}", e))?);
    }
    for g in input.globals {
        let (name, value) = g
            .split_once('=')
            .ok_or_else(|| format!("invalid --global (expected NAME=value): {}", g))?;
        let v: i64 = value
            .parse()
            .map_err(|e: std::num::ParseIntError| format!("invalid --global value: {}", e))?;
        config.global_values.push((name.to_string(), v));
    }
    Ok(config)
}

fn write_exprs(path: &Path, exprs: &SymbolicOutputs) -> std::io::Result<()> {
    let mut out = std::io::BufWriter::new(std::fs::File::create(path)?);
    volta_expr::text::write_text(&mut out, exprs)?;
    std::io::Write::flush(&mut out)
}

fn read_exprs(path: &Path) -> Result<SymbolicOutputs, String> {
    let text =
        std::fs::read_to_string(path).map_err(|e| format!("read {}: {}", path.display(), e))?;
    volta_expr::text::read_text(&text).map_err(|e| format!("{}: {}", path.display(), e))
}

/// Exit status of a verdict: 0 only for ACCEPT (or a verified graph), 1 for REJECT, 2 for
/// UNKNOWN.
fn exit_code(verdict: Verdict) -> ExitCode {
    match verdict {
        Verdict::Accept => ExitCode::SUCCESS,
        Verdict::Reject => ExitCode::FAILURE,
        Verdict::Unknown => ExitCode::from(2),
    }
}

/// One kernel after the analysis stage and the graph branch.
struct KernelSide {
    label: &'static str,
    graph: EventGraph,
    report: GraphReport,
}

impl KernelSide {
    fn evidence(&self) -> KernelEvidence<'_> {
        KernelEvidence {
            label: self.label,
            graph: &self.report,
            assumptions: &self.graph.provenance().assumptions,
        }
    }
}

/// Print the graph branch's per-check verdicts for one kernel, with each failed check's
/// witnesses and the trace generator's deadlock.
fn print_graph_report(side: &KernelSide) {
    println!("{}: graph verification", side.label);
    for s in side.report.summaries() {
        let check = format!("{} ({})", s.property.name(), s.property.algorithm());
        println!("  {:<55} {}", check, s.verdict.name());
        for f in s.findings.iter().take(3) {
            println!("      {}", f);
        }
        if s.findings.len() > 3 {
            println!("      ... ({} more)", s.findings.len() - 3);
        }
    }
    if let Some(deadlock) = side.report.deadlock() {
        println!(
            "  trace: deadlock, {} blocked thread(s)",
            deadlock.blocked.len()
        );
    }
}

fn print_decision(decision: &Decision) -> ExitCode {
    println!("VERDICT: {}", decision.verdict.name());
    for e in &decision.evidence {
        println!("  {}", e);
    }
    if !decision.assumptions.is_empty() {
        println!("  under the assumptions:");
        for a in &decision.assumptions {
            println!("    - {}", a.describe());
        }
    }
    exit_code(decision.verdict)
}

/// One kernel's analysis artifacts other than its graph.
struct KernelRun {
    outputs: Result<SymbolicOutputs, OutputsUnavailable>,
    stats: Stats,
    op_counts: BTreeMap<&'static str, u64>,
}

/// Analysis stage plus graph branch for one kernel, split into its owned parts.
fn run_kernel(
    label: &'static str,
    module: &Module,
    kernel: Option<&str>,
    config: AnalysisConfig,
) -> Result<(KernelRun, KernelSide), String> {
    let verified =
        verify_kernel(module, kernel, config).map_err(|e| format!("{} kernel: {}", label, e))?;
    let AnalysisParts {
        outputs,
        graph,
        stats,
        op_counts,
    } = verified.analysis.into_parts();
    Ok((
        KernelRun {
            outputs,
            stats,
            op_counts,
        },
        KernelSide {
            label,
            graph,
            report: verified.graph,
        },
    ))
}

fn cmd_analyze(args: AnalyzeArgs, log: &mut run_log::RunLog) -> ExitCode {
    let file = &args.file;
    let module = match load_module(file) {
        Ok(m) => m,
        Err(code) => return code,
    };

    let config = match build_config(ConfigInput::from_launch(&args.launch)) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("error: {}", e);
            return ExitCode::FAILURE;
        }
    };

    let start = Instant::now();
    let (run, side) = match run_kernel("kernel", &module, args.kernel.as_deref(), config) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("analysis failed: {}", e);
            log.record(&format!("analyze {}: FAILED: {}", file.display(), e));
            return ExitCode::FAILURE;
        }
    };
    let elapsed = start.elapsed().as_secs_f64();
    #[cfg(feature = "logging")]
    log::info!(
        "[equivalence] skipped: analyze has no second kernel or spec (compare and verify run it)"
    );
    if let Some(path) = &args.dump_graph {
        match std::fs::write(path, side.graph.dump()) {
            Ok(()) => eprintln!("Wrote event graph to {}", path.display()),
            Err(e) => eprintln!("error: failed to write {}: {}", path.display(), e),
        }
    }

    println!(
        "  time: {:.3}s  instructions: {}  block syncs: {}  warp syncs: {}",
        elapsed, run.stats.instructions, run.stats.block_syncs, run.stats.warp_syncs
    );
    match &run.outputs {
        Ok(exprs) => {
            for (name, elems) in &exprs.outputs {
                println!("  output '{}': {} element(s) written", name, elems.len());
                for (index, expr) in elems.iter().take(args.print_outputs as usize) {
                    println!(
                        "    {}[{}] = {}",
                        name,
                        index,
                        exprs.arena.display_expr(*expr)
                    );
                }
                if elems.len() as u64 > args.print_outputs {
                    println!("    ... ({} more)", elems.len() as u64 - args.print_outputs);
                }
            }
        }
        Err(why) => println!("  no outputs: {}", why),
    }
    if args.profile {
        let _ = write_op_counts(&mut std::io::stdout().lock(), "instruction", &run.op_counts);
    }
    if let (Some(path), Ok(exprs)) = (&args.emit_exprs, &run.outputs) {
        if let Err(e) = write_exprs(path, exprs) {
            eprintln!("error: failed to write {}: {}", path.display(), e);
            return ExitCode::FAILURE;
        }
        println!("Wrote output expressions to {}", path.display());
    }

    print_graph_report(&side);
    let (verdict, reasons) = match side.report.conclusion() {
        GraphConclusion::Verified => (Verdict::Accept, Vec::new()),
        GraphConclusion::Rejected { failed, deadlock } => (
            Verdict::Reject,
            deadlock
                .map(|_| "the trace deadlocked".to_string())
                .into_iter()
                .chain(
                    failed
                        .iter()
                        .map(|s| format!("{} failed", s.property.name())),
                )
                .collect(),
        ),
        GraphConclusion::Unknown { reasons } => (Verdict::Unknown, reasons),
    };
    let name = match verdict {
        Verdict::Accept => "VERIFIED",
        Verdict::Reject => "REJECTED",
        Verdict::Unknown => "UNKNOWN",
    };
    println!(
        "GRAPH VERIFICATION: {} (no equivalence check requested)",
        name
    );
    for r in &reasons {
        println!("  {}", r);
    }
    log.record(&format!(
        "analyze {}: {} in {:.3}s, {} instructions",
        file.display(),
        name,
        elapsed,
        run.stats.instructions
    ));
    exit_code(verdict)
}

/// Reject duplicate `--check-array` names (they would double-count elements). Clap enforces at
/// least one; membership is checked against the launch config before symbolic execution and by
/// `paired_elements` (the authority) after.
fn validate_check_arrays(arrays: &[String]) -> Result<(), String> {
    for (i, name) in arrays.iter().enumerate() {
        if arrays[..i].contains(name) {
            return Err(format!("--check-array '{}' given more than once", name));
        }
    }
    Ok(())
}

fn cmd_compare(args: CompareArgs, log: &mut run_log::RunLog) -> ExitCode {
    if let Err(e) = validate_check_arrays(&args.check_arrays) {
        eprintln!("error: {}", e);
        return ExitCode::FAILURE;
    }
    if args.from_dump.is_some() && args.dump_vcs.is_some() {
        eprintln!("note: --dump-vcs is a no-op with --from-dump (nothing new to dump)");
    }

    // Kernel inputs run both branches; expression inputs (.vexpr files, a dump) carry no
    // event graph, so only the equivalence branch.
    let mut sides: Option<[KernelSide; 2]> = None;
    let (reference, optimized, exec_secs): (SymbolicOutputs, SymbolicOutputs, Option<f64>) =
        if args.exprs {
            let (Some(file1), Some(file2)) = (args.file1.as_ref(), args.file2.as_ref()) else {
                eprintln!("error: compare --exprs needs FILE1 and FILE2 (.vexpr files)");
                return ExitCode::FAILURE;
            };
            let reference = match read_exprs(file1) {
                Ok(e) => e,
                Err(e) => {
                    eprintln!("error: {}", e);
                    return ExitCode::FAILURE;
                }
            };
            let optimized = match read_exprs(file2) {
                Ok(e) => e,
                Err(e) => {
                    eprintln!("error: {}", e);
                    return ExitCode::FAILURE;
                }
            };
            (reference, optimized, None)
        } else if let Some(dump_path) = &args.from_dump {
            if args.file1.is_some() || args.file2.is_some() {
                eprintln!("note: --from-dump ignores FILE1/FILE2 and the launch-config flags");
            }
            let dump = match read_vc_dump(dump_path) {
                Ok(d) => d,
                Err(e) => {
                    eprintln!("error: failed to read dump {}: {}", dump_path.display(), e);
                    return ExitCode::FAILURE;
                }
            };
            (dump.reference, dump.optimized, None)
        } else {
            let (Some(file1), Some(file2)) = (args.file1.as_ref(), args.file2.as_ref()) else {
                eprintln!("error: compare needs FILE1 and FILE2 (or --from-dump)");
                return ExitCode::FAILURE;
            };

            let module1 = match load_module(file1) {
                Ok(m) => m,
                Err(code) => return code,
            };
            let module2 = match load_module(file2) {
                Ok(m) => m,
                Err(code) => return code,
            };

            let config1 = match build_config(ConfigInput::from_launch(&args.launch)) {
                Ok(c) => c,
                Err(e) => {
                    eprintln!("error: {}", e);
                    return ExitCode::FAILURE;
                }
            };
            let config2 = match build_config(ConfigInput {
                block: args.block2.as_deref().unwrap_or(&args.launch.block),
                grid: args.grid2.as_deref().unwrap_or(&args.launch.grid),
                ..ConfigInput::from_launch(&args.launch)
            }) {
                Ok(c) => c,
                Err(e) => {
                    eprintln!("error: {}", e);
                    return ExitCode::FAILURE;
                }
            };

            // Fail fast on a name no declared out/inout array matches: catches a typo before
            // minutes of symbolic execution. `paired_elements` stays the authority afterwards.
            for name in &args.check_arrays {
                if !config1
                    .arrays
                    .iter()
                    .any(|a| a.kind.is_output() && &a.name == name)
                {
                    eprintln!(
                        "error: --check-array '{}' is not a declared output array",
                        name
                    );
                    return ExitCode::FAILURE;
                }
            }

            let start = Instant::now();
            let analyzed = run_kernel(
                "reference kernel",
                &module1,
                args.kernel1.as_deref(),
                config1,
            )
            .and_then(|r| {
                run_kernel(
                    "optimized kernel",
                    &module2,
                    args.kernel2.as_deref(),
                    config2,
                )
                .map(|o| (r, o))
            });
            let ((run1, side1), (run2, side2)) = match analyzed {
                Ok(both) => both,
                Err(e) => {
                    eprintln!("error: {}", e);
                    log.record(&format!("compare: FAILED: {}", e));
                    return ExitCode::FAILURE;
                }
            };
            let exec_secs = start.elapsed().as_secs_f64();

            if args.profile {
                let mut out = std::io::stdout().lock();
                let _ = write_op_counts(&mut out, "reference instruction", &run1.op_counts);
                let _ = write_op_counts(&mut out, "optimized instruction", &run2.op_counts);
            }
            println!(
                "Exec: {:.3}s  instructions: {}  block syncs: {}  warp syncs: {}",
                exec_secs,
                run1.stats.instructions + run2.stats.instructions,
                run2.stats.block_syncs,
                run2.stats.warp_syncs
            );
            print_graph_report(&side1);
            print_graph_report(&side2);
            let (reference, optimized) = match (run1.outputs, run2.outputs) {
                (Ok(r), Ok(o)) => (r, o),
                (r, o) => {
                    let reason = [(side1.label, r.err()), (side2.label, o.err())]
                        .into_iter()
                        .filter_map(|(label, why)| why.map(|w| format!("{}: {}", label, w)))
                        .collect::<Vec<_>>()
                        .join("; ");
                    let decision = decide(
                        &EquivalenceVerdict::Failed { reason },
                        &[side1.evidence(), side2.evidence()],
                    );
                    log.record(&format!("compare: {}", decision.verdict.name()));
                    return print_decision(&decision);
                }
            };
            sides = Some([side1, side2]);

            if let Some(dump_path) = &args.dump_vcs {
                let dump = VcDump {
                    reference,
                    optimized,
                };
                if let Err(e) = write_vc_dump(dump_path, &dump) {
                    eprintln!("error: failed to write dump {}: {}", dump_path.display(), e);
                    return ExitCode::FAILURE;
                }
                println!("Dumped verification conditions to {}", dump_path.display());
                (dump.reference, dump.optimized, Some(exec_secs))
            } else {
                (reference, optimized, Some(exec_secs))
            }
        };

    if exec_secs.is_none() {
        let source = if args.exprs { ".vexpr files" } else { "dump" };
        println!("Loaded verification conditions from {source} (no fresh symbolic execution).");
    }

    // The arrays to check: exactly the --check-array names, in their given
    // order. `paired_elements` rejects any that both runs don't have.
    let check_arrays: &[String] = &args.check_arrays;

    let equivalence = {
        let options = EquivCheckOptions {
            sample: args.sample,
            verify_numeric: args.verify_numeric,
            recycle_terms: args.recycle_terms,
            iterations: args.iterations,
        };
        let vc_start = Instant::now();
        let (verdict, report) = check_equivalence(&reference, &optimized, check_arrays, &options);
        let vc_secs = vc_start.elapsed().as_secs_f64();
        match report {
            Some(report) => {
                let elems = if report.elements_checked == report.elements_total {
                    format!("{}", report.elements_total)
                } else {
                    format!("{}/{}", report.elements_checked, report.elements_total)
                };
                // Wall clock for the whole phase; the parenthetical is the decision procedure
                // alone (summed canon checks).
                println!(
                    "VC check: {:.3}s (decision procedure {:.3}s)  elements: {}",
                    vc_secs,
                    report.check_time().as_secs_f64(),
                    elems
                );
                if report.check_iters.len() > 1 {
                    let per_iter: Vec<String> = report
                        .check_iters
                        .iter()
                        .map(|d| format!("{:.3}", d.as_secs_f64()))
                        .collect();
                    println!(
                        "  decision procedure iterations (s): [{}]",
                        per_iter.join(", ")
                    );
                }
                match &report.outcome {
                    EquivOutcome::Equivalent => {
                        println!("EQUIVALENT");
                        log.record(&format!(
                            "compare: EQUIVALENT ({} elements, exec {:?}, vc {:.3}s)",
                            elems, exec_secs, vc_secs
                        ));
                    }
                    EquivOutcome::NotEquivalent { mismatches } => {
                        println!("NOT EQUIVALENT: {} mismatched element(s)", mismatches.len());
                        for m in mismatches.iter().take(10) {
                            println!("  {}[{}]", m.array, m.index);
                        }
                        if mismatches.len() > 10 {
                            println!("  ... ({} more)", mismatches.len() - 10);
                        }
                        log.record(&format!(
                            "compare: NOT EQUIVALENT, {} mismatches",
                            mismatches.len()
                        ));
                    }
                }
            }
            None => {
                if let EquivalenceVerdict::Failed { reason } = &verdict {
                    eprintln!("error: {}", reason);
                    log.record(&format!("compare: FAILED: {}", reason));
                }
            }
        }
        verdict
    };
    match &equivalence {
        EquivalenceVerdict::Refuted { elements } => println!(
            "  {} element(s) refuted by a numeric counterexample",
            elements.len()
        ),
        EquivalenceVerdict::Unproven { elements } => println!(
            "  {} element(s) neither proved equivalent nor refuted numerically",
            elements.len()
        ),
        _ => {}
    }
    match sides {
        Some([reference, optimized]) => {
            let decision = decide(&equivalence, &[reference.evidence(), optimized.evidence()]);
            log.record(&format!("compare: {}", decision.verdict.name()));
            print_decision(&decision)
        }
        None => {
            println!(
                "(equivalence branch only: expression inputs carry no event graph, so no graph \
                 property was checked)"
            );
            if matches!(equivalence, EquivalenceVerdict::Equivalent { .. }) {
                ExitCode::SUCCESS
            } else {
                ExitCode::FAILURE
            }
        }
    }
}

/// Resolve `verify`'s `spec` argument: a file path first (via `files`, for parse-error
/// snippets), else inline spec text - but only when the file is missing; other I/O errors
/// (permission denied, is a directory, ...) are reported directly.
fn load_spec_source(files: &mut FileCache, arg: &str) -> Result<(String, Option<PathBuf>), String> {
    match files.read(arg) {
        Ok(contents) => Ok((contents.to_string(), Some(PathBuf::from(arg)))),
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok((arg.to_string(), None)),
        Err(e) => Err(format!("failed to read spec file '{}': {}", arg, e)),
    }
}

/// Parse "NAME=VALUE" (hex with a 0x prefix, via `parse_u64_value`).
fn parse_dim(s: &str) -> Result<(String, u64), String> {
    let (name, value) = s
        .split_once('=')
        .ok_or_else(|| format!("invalid --dim (expected NAME=VALUE): {}", s))?;
    Ok((name.to_string(), parse_u64_value(value)?))
}

fn cmd_verify(args: VerifyArgs, log: &mut run_log::RunLog) -> ExitCode {
    let module = match load_module(&args.file) {
        Ok(m) => m,
        Err(code) => return code,
    };

    let mut spec_files = FileCache::new();
    let (spec_src, spec_path) = match load_spec_source(&mut spec_files, &args.spec) {
        Ok(v) => v,
        Err(e) => {
            eprintln!("error: {}", e);
            return ExitCode::FAILURE;
        }
    };
    let parsed_spec = match volta_spec::parse_spec(&spec_src) {
        Ok(s) => s,
        Err(e) => {
            if spec_path.is_none() {
                eprintln!(
                    "note: '{}' is not an existing file, so it was parsed as inline spec text",
                    args.spec
                );
            }
            let _ = report_error(
                &mut std::io::stderr(),
                &spec_files,
                Report {
                    path: spec_path.as_deref(),
                    span: e.span,
                    title: "spec parse error",
                    message: Some(&e.error.to_string()),
                },
            );
            return ExitCode::FAILURE;
        }
    };

    let mut dim_values = HashMap::with_capacity(args.dims.len());
    for d in &args.dims {
        match parse_dim(d) {
            Ok((name, value)) => {
                dim_values.insert(name, value);
            }
            Err(e) => {
                eprintln!("error: {}", e);
                return ExitCode::FAILURE;
            }
        }
    }
    let (env, specs) = match volta_spec::instantiate(&parsed_spec, &dim_values) {
        Ok(v) => v,
        Err(e) => {
            eprintln!("error: {}", e);
            return ExitCode::FAILURE;
        }
    };

    // The arrays to check: every array the spec defines an output
    // equation for, in declaration order.
    let mut check_arrays: Vec<String> = Vec::new();
    for o in &parsed_spec.outputs {
        if !check_arrays.contains(&o.array) {
            check_arrays.push(o.array.clone());
        }
    }
    if check_arrays.is_empty() {
        eprintln!("error: spec declares no output equations to check");
        return ExitCode::FAILURE;
    }

    let config = match build_config(ConfigInput::from_launch(&args.launch)) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("error: {}", e);
            return ExitCode::FAILURE;
        }
    };

    // Fail fast, before symbolic execution: every array the spec checks
    // must be a declared output array of the kernel under this config.
    for name in &check_arrays {
        if !config
            .arrays
            .iter()
            .any(|a| a.kind.is_output() && &a.name == name)
        {
            eprintln!(
                "error: verify requires a declared output array named '{}' (the spec defines it)",
                name
            );
            return ExitCode::FAILURE;
        }
    }

    let start = Instant::now();
    let (run, side) = match run_kernel("kernel", &module, args.kernel.as_deref(), config) {
        Ok(r) => r,
        Err(e) => {
            eprintln!("error: {}", e);
            log.record(&format!("verify {}: FAILED: {}", args.file.display(), e));
            return ExitCode::FAILURE;
        }
    };
    let exec_secs = start.elapsed().as_secs_f64();

    if args.profile {
        let _ = write_op_counts(&mut std::io::stdout().lock(), "instruction", &run.op_counts);
    }
    println!(
        "Exec: {:.3}s  instructions: {}  block syncs: {}  warp syncs: {}",
        exec_secs, run.stats.instructions, run.stats.block_syncs, run.stats.warp_syncs
    );
    print_graph_report(&side);
    let mut kernel_exprs = match run.outputs {
        Ok(exprs) => exprs,
        Err(why) => {
            let decision = decide(
                &EquivalenceVerdict::Failed {
                    reason: format!("kernel: {}", why),
                },
                &[side.evidence()],
            );
            log.record(&format!("verify: {}", decision.verdict.name()));
            return print_decision(&decision);
        }
    };

    // --sample also caps *generation* (a big kernel's footprint is impractical to unroll a
    // Sum-heavy spec over): truncate the kernel's elements to the same ascending prefix
    // `unfold` builds, so the two sides still pair up.
    let untruncated: u64 = kernel_exprs
        .outputs
        .iter()
        .filter(|(n, _)| check_arrays.contains(n))
        .map(|(_, elems)| elems.len() as u64)
        .sum();
    if args.sample > 0 {
        for name in &check_arrays {
            if let Some((_, elems)) = kernel_exprs.outputs.iter_mut().find(|(n, _)| n == name) {
                elems.truncate(args.sample as usize);
            }
        }
    }

    let spec_output = match unfold(&specs, &env, args.sample) {
        Ok(o) => o,
        Err(e) => {
            eprintln!("error: building spec: {}", e);
            return ExitCode::FAILURE;
        }
    };

    let options = EquivCheckOptions {
        sample: args.sample,
        verify_numeric: args.verify_numeric,
        recycle_terms: args.recycle_terms,
        iterations: args.iterations,
    };
    let vc_start = Instant::now();
    let (mut equivalence, report) =
        check_equivalence(&kernel_exprs, &spec_output, &check_arrays, &options);
    let vc_secs = vc_start.elapsed().as_secs_f64();
    if let EquivalenceVerdict::Equivalent { checked, total } = &mut equivalence {
        *total = (*total).max(untruncated);
        if *checked > *total {
            *checked = *total;
        }
    }

    match &report {
        Some(report) => {
            let elems = if report.elements_checked == report.elements_total {
                format!("{}", report.elements_total)
            } else {
                format!("{}/{}", report.elements_checked, report.elements_total)
            };
            println!(
                "VC check: {:.3}s (decision procedure {:.3}s)  elements: {}",
                vc_secs,
                report.check_time().as_secs_f64(),
                elems
            );
            if report.check_iters.len() > 1 {
                let per_iter: Vec<String> = report
                    .check_iters
                    .iter()
                    .map(|d| format!("{:.3}", d.as_secs_f64()))
                    .collect();
                println!(
                    "  decision procedure iterations (s): [{}]",
                    per_iter.join(", ")
                );
            }
            match &report.outcome {
                EquivOutcome::Equivalent => {
                    println!("EQUIVALENT (matches spec)");
                    log.record(&format!(
                        "verify: EQUIVALENT ({} elements, exec {:.3}s, vc {:.3}s)",
                        elems, exec_secs, vc_secs
                    ));
                }
                EquivOutcome::NotEquivalent { mismatches } => {
                    println!(
                        "NOT EQUIVALENT: {} mismatched element(s) vs spec",
                        mismatches.len()
                    );
                    for m in mismatches.iter().take(10) {
                        println!("  {}[{}]", m.array, m.index);
                    }
                    if mismatches.len() > 10 {
                        println!("  ... ({} more)", mismatches.len() - 10);
                    }
                    log.record(&format!(
                        "verify: NOT EQUIVALENT, {} mismatches",
                        mismatches.len()
                    ));
                }
            }
        }
        None => {
            if let EquivalenceVerdict::Failed { reason } = &equivalence {
                eprintln!("error: {}", reason);
                log.record(&format!("verify: FAILED: {}", reason));
            }
        }
    }
    let decision = decide(&equivalence, &[side.evidence()]);
    log.record(&format!("verify: {}", decision.verdict.name()));
    print_decision(&decision)
}

/// Load and parse a module, reporting errors nicely.
fn load_module(file: &Path) -> Result<Module, ExitCode> {
    let mut files = FileCache::new();
    let contents = match files.read(file) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("error: failed to read {}: {}", file.display(), e);
            return Err(ExitCode::FAILURE);
        }
    };
    let ascii_src: &[AsciiChar] = match contents.as_bytes().as_ascii_slice() {
        Some(src) => src,
        None => {
            eprintln!("error: file contains non-ASCII character");
            return Err(ExitCode::FAILURE);
        }
    };
    let mut parser = parse::Parser::new(ascii_src);
    match parser.parse_module().map_err(locate_path(file)) {
        Ok(module) => Ok(module),
        Err(e) => {
            let _ = report_error(
                &mut std::io::stderr(),
                &files,
                Report {
                    path: e.path.as_deref(),
                    span: e.span,
                    title: e.error.title(),
                    message: e.error.message().as_deref(),
                },
            );
            Err(ExitCode::FAILURE)
        }
    }
}

/// Write the viewer page over the runs recorded in `args.store`
fn cmd_viz(args: &VizArgs) -> ExitCode {
    match volta_viz::write_page(&args.store, &args.output) {
        Ok(runs) => {
            println!(
                "Wrote {} run(s) from {} to {}",
                runs,
                args.store.display(),
                args.output.display()
            );
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!(
                "error: cannot build {} from {}: {}",
                args.output.display(),
                args.store.display(),
                e
            );
            ExitCode::FAILURE
        }
    }
}

/// Parse a PTX file and report any errors
fn cmd_parse(file: &Path) -> ExitCode {
    let mut files = FileCache::new();

    let contents = match files.read(file) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("error: failed to read {}: {}", file.display(), e);
            return ExitCode::FAILURE;
        }
    };

    let ascii_src: &[AsciiChar] = match contents.as_bytes().as_ascii_slice() {
        Some(src) => src,
        None => {
            eprintln!("error: file contains non-ASCII character");
            return ExitCode::FAILURE;
        }
    };

    let mut parser = parse::Parser::new(ascii_src);
    match parser.parse_module().map_err(locate_path(file)) {
        Ok(module) => {
            println!("Parsed successfully: {}", file.display());
            print_module_summary(&module);
            ExitCode::SUCCESS
        }
        Err(e) => {
            let _ = report_error(
                &mut std::io::stderr(),
                &files,
                Report {
                    path: e.path.as_deref(),
                    span: e.span,
                    title: e.error.title(),
                    message: e.error.message().as_deref(),
                },
            );
            ExitCode::FAILURE
        }
    }
}

/// Print a summary of the parsed module
fn print_module_summary(module: &Module) {
    let mut entries = 0;
    let mut functions = 0;

    for item in &module.items {
        match item {
            TopLevelItem::Entry(_) => entries += 1,
            TopLevelItem::Function(_) => functions += 1,
            _ => {}
        }
    }

    println!("  Entries (kernels): {}", entries);
    if functions > 0 {
        println!("  Functions: {}", functions);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn unique_check_arrays_validate() {
        // Membership is deliberately not checked here: the declared-config
        // check owns it before execution, `paired_elements` after.
        assert!(validate_check_arrays(&["out".to_string(), "aux".to_string()]).is_ok());
    }

    #[test]
    fn duplicate_check_arrays_are_rejected() {
        let arrays = vec!["out".to_string(), "aux".to_string(), "out".to_string()];
        let err = validate_check_arrays(&arrays).unwrap_err();
        assert!(err.contains("'out'"), "{}", err);
    }

    #[test]
    fn compare_requires_at_least_one_check_array() {
        // The list is required, never derived - parity with
        // `paired_elements`' explicit-list interface.
        let without = ["volta", "compare", "a.ptx", "b.ptx"];
        assert!(Cli::try_parse_from(without).is_err());
        let with = ["volta", "compare", "a.ptx", "b.ptx", "--check-array", "out"];
        assert!(Cli::try_parse_from(with).is_ok());
    }

    #[test]
    fn verify_requires_a_spec_argument() {
        let without = ["volta", "verify", "a.ptx"];
        assert!(Cli::try_parse_from(without).is_err());
        let with = ["volta", "verify", "a.ptx", "C[i] = A[i];", "--dim", "N=4"];
        assert!(Cli::try_parse_from(with).is_ok());
    }

    #[test]
    fn parse_dim_splits_name_and_value() {
        assert_eq!(parse_dim("K=4096").unwrap(), ("K".to_string(), 4096));
        assert_eq!(parse_dim("K=0x10").unwrap(), ("K".to_string(), 16));
        assert!(parse_dim("K").is_err());
    }

    #[test]
    fn load_spec_source_falls_back_to_inline_text_when_no_such_file() {
        let mut files = FileCache::new();
        let (src, path) = load_spec_source(&mut files, "C[i] = A[i];").unwrap();
        assert_eq!(src, "C[i] = A[i];");
        assert!(path.is_none());
    }

    #[test]
    fn load_spec_source_reads_an_existing_file() {
        let dir = std::env::temp_dir();
        let path = dir.join(format!("volta_cli_test_{}.spec", std::process::id()));
        std::fs::write(&path, "dim N;\narray A[N];\nC[i] = A[i];").unwrap();
        let mut files = FileCache::new();
        let (src, resolved) = load_spec_source(&mut files, path.to_str().unwrap()).unwrap();
        assert!(src.contains("dim N;"));
        assert_eq!(resolved, Some(path.clone()));
        let _ = std::fs::remove_file(&path);
    }
}
