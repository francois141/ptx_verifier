//! Kernel and expression equivalence command.

use std::num::NonZeroUsize;
use std::path::{Path, PathBuf};
use std::process::ExitCode;
use std::time::Instant;

use clap::Args;
use volta_common::run_log;
use volta_equivalence::equiv::DEFAULT_RECYCLE_TERMS;
use volta_equivalence::vc_dump::{VcDump, read_vc_dump, write_vc_dump};
use volta_equivalence::{EquivCheckOptions, EquivOutcome};
use volta_expr::SymbolicOutputs;
use volta_pipeline::{EquivalenceVerdict, check_equivalence, decide};
use volta_ptx_analysis::{AnalysisConfig, write_op_counts};

use crate::config::{LaunchArgs, launch_config, parse_dims};
use crate::output::{print_decision, print_graph_report};
use crate::ptx::{KernelSide, load_module, run_kernel};

#[derive(Args)]
pub(crate) struct CompareArgs {
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

/// The reference and optimized kernels' configs: one launch, the optimized kernel's dims
/// overridden by `--block2`/`--grid2`.
fn compare_configs(args: &CompareArgs) -> Result<(AnalysisConfig, AnalysisConfig), String> {
    let launch = launch_config(&args.launch)?;
    if let Some(kernel) = launch.kernel {
        return Err(format!(
            "the launch file names kernel '{kernel}', but compare runs two: name them with \
             --kernel1/--kernel2 and drop its \"kernel\""
        ));
    }
    let mut optimized = launch.config.clone();
    if let Some(block) = &args.block2 {
        optimized.block_dim = parse_dims(block).map_err(|e| format!("invalid --block2: {}", e))?;
    }
    if let Some(grid) = &args.grid2 {
        optimized.grid_dim = parse_dims(grid).map_err(|e| format!("invalid --grid2: {}", e))?;
    }
    Ok((launch.config, optimized))
}

fn read_exprs(path: &Path) -> Result<SymbolicOutputs, String> {
    let text =
        std::fs::read_to_string(path).map_err(|e| format!("read {}: {}", path.display(), e))?;
    volta_expr::text::read_text(&text).map_err(|e| format!("{}: {}", path.display(), e))
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

pub(crate) fn cmd_compare(args: CompareArgs, log: &mut run_log::RunLog) -> ExitCode {
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

            let (module1, source1) = match load_module(file1) {
                Ok(m) => m,
                Err(code) => return code,
            };
            let (module2, source2) = match load_module(file2) {
                Ok(m) => m,
                Err(code) => return code,
            };

            let (config1, config2) = match compare_configs(&args) {
                Ok(configs) => configs,
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
            print_graph_report(side1.label, &side1.graph, &side1.report, &source1);
            print_graph_report(side2.label, &side2.graph, &side2.report, &source2);
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
