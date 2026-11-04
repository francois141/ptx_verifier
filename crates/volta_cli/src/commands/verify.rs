//! PTX verification against a mathematical specification.

use std::num::NonZeroUsize;
use std::path::PathBuf;
use std::process::ExitCode;
use std::time::Instant;

use clap::Args;
use volta_common::run_log;
use volta_equivalence::EquivCheckOptions;
use volta_equivalence::equiv::DEFAULT_RECYCLE_TERMS;
use volta_pipeline::{EquivalenceVerdict, check_equivalence, decide};
use volta_ptx_analysis::{LaunchFile, write_op_counts};
use volta_spec::unfold;

use crate::config::{LaunchArgs, launch_config};
use crate::output::{print_decision, print_graph_report, print_spec_check};
use crate::ptx::{load_module, run_kernel};
use crate::spec::{dim_values, load_spec};

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
    let parsed_spec = match load_spec(&args.spec) {
        Ok(spec) => spec,
        Err(code) => return code,
    };
    let dim_values = match dim_values(&args.dims) {
        Ok(dims) => dims,
        Err(code) => return code,
    };
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

    // Before --sample truncates either side, so a sampled prefix cannot hide an element the
    // kernel never writes: each spec output defines every flat index of its shape.
    for name in &check_arrays {
        let expected = specs
            .iter()
            .filter(|s| &s.array == name)
            .map(|s| s.shape.size())
            .max()
            .unwrap_or(0);
        let written: Vec<u64> = kernel_exprs
            .outputs
            .iter()
            .find(|(n, _)| n == name)
            .map_or_else(Vec::new, |(_, elems)| {
                elems.iter().map(|&(index, _)| index).collect()
            });
        let unwritten: Vec<u64> = (0..expected)
            .filter(|index| written.binary_search(index).is_err())
            .collect();
        let unexpected: Vec<u64> = written.iter().copied().filter(|&i| i >= expected).collect();
        if !unwritten.is_empty() || !unexpected.is_empty() {
            let decision = decide(
                &EquivalenceVerdict::IndexSetMismatch {
                    array: name.clone(),
                    unwritten,
                    unexpected,
                },
                &[side.evidence()],
            );
            log.record(&format!("verify: {}", decision.verdict.name()));
            return print_decision(&decision);
        }
    }

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
