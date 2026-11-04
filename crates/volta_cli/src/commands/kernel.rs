//! `volta solve`: a kernel file of any ISA through its interpreter, its outputs checked against
//! a spec when one is given.

use std::num::NonZeroUsize;
use std::path::PathBuf;
use std::process::ExitCode;
use std::time::Instant;

use clap::Args;
use volta_common::file_cache::FileCache;
use volta_common::report::{Report, report_error};
use volta_common::run_log;
use volta_equivalence::EquivCheckOptions;
use volta_equivalence::equiv::DEFAULT_RECYCLE_TERMS;
use volta_pipeline::{FrontendError, GraphEvidence, Isa, Solution, Solver};
use volta_ptx_analysis::LaunchFile;

use crate::config::{LaunchArgs, launch_config};
use crate::output::{
    exit_code, print_decision, print_graph_conclusion, print_graph_report, print_outputs,
    print_spec_check, write_exprs,
};
use crate::spec::{dim_values, load_spec};

#[derive(Args)]
struct KernelArgs {
    /// Kernel file: `.ptx`, `.s` (AMD gfx950 assembly) or `.py` (Trainium NKI)
    file: PathBuf,

    /// Kernel name (defaults to the file's first PTX entry, or its only AMD or NKI kernel)
    #[arg(short, long)]
    kernel: Option<String>,

    #[command(flatten)]
    launch: LaunchArgs,

    /// Spec to check the outputs against: a .spec path, or inline spec source if no such file
    /// exists. Without one, the kernel is only run (and, for PTX, race checked).
    #[arg(long)]
    spec: Option<String>,

    /// Concrete value for a spec `dim`: "NAME=VALUE". Repeatable.
    #[arg(long = "dim", value_name = "NAME=VALUE", requires = "spec")]
    dims: Vec<String>,

    /// Print up to N elements of each output array
    #[arg(long, default_value_t = 8)]
    print_outputs: u64,

    /// Write the output expressions to this file in the `.vexpr` text format
    #[arg(long, value_name = "FILE")]
    emit_exprs: Option<PathBuf>,
}

#[derive(Args)]
pub(crate) struct SolveArgs {
    #[command(flatten)]
    input: KernelArgs,

    /// Check at most this many elements per output array (0 = all)
    #[arg(long, default_value_t = 0)]
    sample: u64,

    /// Confirm every verdict with the f64 numeric oracle
    #[arg(long)]
    verify_numeric: bool,

    /// Recycle the VC intern tables past this many interned terms (0 = never)
    #[arg(long, default_value_t = DEFAULT_RECYCLE_TERMS)]
    recycle_terms: usize,

    /// Run the solve phase N times (fresh session each; later iterations must agree)
    #[arg(long, default_value_t = NonZeroUsize::MIN)]
    iterations: NonZeroUsize,
}

pub(crate) fn cmd_solve(args: SolveArgs, log: &mut run_log::RunLog) -> ExitCode {
    let options = EquivCheckOptions {
        sample: args.sample,
        verify_numeric: args.verify_numeric,
        recycle_terms: args.recycle_terms,
        iterations: args.iterations,
    };
    let args = args.input;
    let file = &args.file;
    let Some(isa) = Isa::of_path(file) else {
        eprintln!(
            "error: {} is not a kernel file Volta reads (.ptx, .s or .py)",
            file.display()
        );
        return ExitCode::FAILURE;
    };
    let LaunchFile {
        kernel: launch_kernel,
        config,
    } = match launch_config(&args.launch) {
        Ok(l) => l,
        Err(e) => {
            eprintln!("error: {}", e);
            return ExitCode::FAILURE;
        }
    };
    let kernel = args.kernel.as_deref().or(launch_kernel.as_deref());
    let spec = match &args.spec {
        Some(arg) => match dim_values(&args.dims).and_then(|dims| load_spec(arg, &dims)) {
            Ok(spec) => Some(spec),
            Err(code) => return code,
        },
        None => None,
    };
    let mut files = FileCache::new();
    let source = match files.read(file) {
        Ok(contents) => contents.to_string(),
        Err(e) => {
            eprintln!("error: failed to read {}: {}", file.display(), e);
            return ExitCode::FAILURE;
        }
    };

    println!("{}: {} kernel", file.display(), isa.name());
    let start = Instant::now();
    let mut run = match isa.frontend().analyze(&source, kernel, config) {
        Ok(run) => run,
        Err(FrontendError::Parse {
            title,
            message,
            span: Some(span),
        }) => {
            let _ = report_error(
                &mut std::io::stderr(),
                &files,
                Report {
                    path: Some(file),
                    span: Some(span),
                    title: &title,
                    message: message.as_deref(),
                },
            );
            return ExitCode::FAILURE;
        }
        Err(e) => {
            eprintln!("error: {}", e);
            log.record(&format!("solve {}: FAILED: {}", file.display(), e));
            return ExitCode::FAILURE;
        }
    };
    let exec_secs = start.elapsed().as_secs_f64();
    println!("  time: {:.3}s", exec_secs);
    print_outputs(&run.outputs, args.print_outputs);
    match &run.graph {
        GraphEvidence::Checked { graph, report } => {
            print_graph_report("kernel", graph, report, &source)
        }
        GraphEvidence::NotRecorded => println!(
            "kernel: race freedom not checked: the {} interpreter records no memory events",
            isa.name()
        ),
    }
    if let (Some(path), Ok(exprs)) = (&args.emit_exprs, &run.outputs) {
        if let Err(e) = write_exprs(path, exprs) {
            eprintln!("error: failed to write {}: {}", path.display(), e);
            return ExitCode::FAILURE;
        }
        println!("Wrote output expressions to {}", path.display());
    }

    let Some(spec) = spec else {
        return match &run.graph {
            GraphEvidence::Checked { report, .. } => {
                let (verdict, name) = print_graph_conclusion(report);
                log.record(&format!("solve {}: {}", file.display(), name));
                exit_code(verdict)
            }
            GraphEvidence::NotRecorded if run.outputs.is_ok() => {
                println!("OUTPUTS EXTRACTED (no spec given, nothing checked)");
                log.record(&format!("solve {}: outputs extracted", file.display()));
                ExitCode::SUCCESS
            }
            GraphEvidence::NotRecorded => {
                log.record(&format!("solve {}: no outputs", file.display()));
                ExitCode::FAILURE
            }
        };
    };

    let vc_start = Instant::now();
    let solver = Solver::Canonical(options);
    let solution = match run.solve(&spec, &solver) {
        Ok(solution) => solution,
        Err(e) => {
            eprintln!("error: building spec: {}", e);
            return ExitCode::FAILURE;
        }
    };
    let vc_secs = vc_start.elapsed().as_secs_f64();
    let Solution::Canonical { verdict, report } = &solution;
    print_spec_check("solve", verdict, report.as_ref(), exec_secs, vc_secs, log);
    let decision = run.decide(&solution);
    log.record(&format!(
        "solve {}: {}",
        file.display(),
        decision.verdict.name()
    ));
    print_decision(&decision)
}
