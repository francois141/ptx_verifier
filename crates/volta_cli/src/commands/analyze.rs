//! PTX analysis command.

use std::path::PathBuf;
use std::process::ExitCode;
use std::time::Instant;

use clap::Args;
use volta_common::run_log;
use volta_ptx_analysis::write_op_counts;

use crate::config::{LaunchArgs, launch_config_without_spec};
use crate::output::{
    exit_code, print_graph_conclusion, print_graph_report, print_outputs, write_exprs,
};
use crate::ptx::{load_module, run_kernel};

#[derive(Args)]
pub(crate) struct AnalyzeArgs {
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

pub(crate) fn cmd_analyze(args: AnalyzeArgs, log: &mut run_log::RunLog) -> ExitCode {
    let file = &args.file;
    let (module, source) = match load_module(file) {
        Ok(m) => m,
        Err(code) => return code,
    };

    let launch = match launch_config_without_spec(&args.launch, "analyze") {
        Ok(l) => l,
        Err(e) => {
            eprintln!("error: {}", e);
            return ExitCode::FAILURE;
        }
    };
    let kernel = args.kernel.as_deref().or(launch.kernel.as_deref());

    let start = Instant::now();
    let (run, side) = match run_kernel("kernel", &module, kernel, launch.config) {
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
    print_outputs(&run.outputs, args.print_outputs);
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

    print_graph_report(side.label, &side.graph, &side.report, &source);
    let (verdict, name) = print_graph_conclusion(&side.report);
    log.record(&format!(
        "analyze {}: {} in {:.3}s, {} instructions",
        file.display(),
        name,
        elapsed,
        run.stats.instructions
    ));
    exit_code(verdict)
}
