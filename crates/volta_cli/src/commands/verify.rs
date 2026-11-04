//! PTX verification against a mathematical specification.

use std::num::NonZeroUsize;
use std::path::PathBuf;
use std::process::ExitCode;
use std::time::Instant;

use clap::Args;
use volta_common::run_log;
use volta_equivalence::EquivCheckOptions;
use volta_equivalence::equiv::DEFAULT_RECYCLE_TERMS;
use volta_pipeline::{EquivalenceVerdict, check_against_spec, decide};
use volta_ptx_analysis::{LaunchFile, write_op_counts};

use crate::config::{LaunchArgs, launch_config_without_spec};
use crate::output::{print_decision, print_graph_report, print_spec_check};
use crate::ptx::{load_module, run_kernel};
use crate::spec::{SpecSource, dim_values, load_spec};

#[derive(Args)]
pub(crate) struct VerifyArgs {
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

pub(crate) fn cmd_verify(args: VerifyArgs, log: &mut run_log::RunLog) -> ExitCode {
    let (module, source) = match load_module(&args.file) {
        Ok(m) => m,
        Err(code) => return code,
    };
    let spec = match dim_values(&args.dims)
        .and_then(|dims| load_spec(SpecSource::Argument(&args.spec), &dims))
    {
        Ok(spec) => spec,
        Err(code) => return code,
    };

    let LaunchFile {
        kernel: launch_kernel,
        config,
        ..
    } = match launch_config_without_spec(&args.launch, "verify") {
        Ok(l) => l,
        Err(e) => {
            eprintln!("error: {}", e);
            return ExitCode::FAILURE;
        }
    };
    let kernel = args.kernel.as_deref().or(launch_kernel.as_deref());

    // Fail fast, before symbolic execution: every array the spec checks
    // must be a declared output array of the kernel under this config.
    for name in spec.arrays() {
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
    let (run, side) = match run_kernel("kernel", &module, kernel, config) {
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
    print_graph_report(side.label, &side.graph, &side.report, &source);
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

    let options = EquivCheckOptions {
        sample: args.sample,
        verify_numeric: args.verify_numeric,
        recycle_terms: args.recycle_terms,
        iterations: args.iterations,
    };
    let vc_start = Instant::now();
    let (equivalence, report) = match check_against_spec(&mut kernel_exprs, &spec, &options) {
        Ok(checked) => checked,
        Err(e) => {
            eprintln!("error: building spec: {}", e);
            return ExitCode::FAILURE;
        }
    };
    let vc_secs = vc_start.elapsed().as_secs_f64();
    print_spec_check(
        "verify",
        &equivalence,
        report.as_ref(),
        exec_secs,
        vc_secs,
        log,
    );
    let decision = decide(&equivalence, &[side.evidence()]);
    log.record(&format!("verify: {}", decision.verdict.name()));
    print_decision(&decision)
}
