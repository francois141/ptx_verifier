//! The `solve` subcommand: replay the solve phase(s) from `generate`'s VC dumps (each
//! fingerprint-checked against the manifest before decoding) through the same solve and
//! `assemble_result` code as the one-shot pipeline; race benchmarks are skipped.

use std::time::Instant;

use anyhow::{Context, Result, anyhow};
use volta_equivalence::check::{paired_elements, sampled_elements};
use volta_equivalence::vc_dump::read_vc_dump_bytes;

use crate::config::{BenchmarkCategory, BenchmarkDef};
use crate::manifest::{self, ManifestCheck, VcsManifest};
use crate::results::vc_dump_path;
use crate::runner::{
    ActualOutcome, BenchmarkResult, BenchmarkRunner, BenchmarkStats, RunFailure, RunOutput,
};
use crate::z3_phase::run_z3_phase;

/// Which solver backend(s) a `solve` run applies to the dumped VCs.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SolveBackend {
    /// The decision procedure only (the default).
    Decision,
    /// Z3 only: no decision verdict is produced
    /// ([`ActualOutcome::Z3Only`]); the Z3 per-element outcomes are the
    /// run's data.
    Z3,
    /// Both, side by side over the same sampled elements - the dumps'
    /// analogue of the one-shot `--z3` comparison.
    Both,
}

impl SolveBackend {
    pub fn runs_decision(self) -> bool {
        matches!(self, Self::Decision | Self::Both)
    }

    pub fn runs_z3(self) -> bool {
        matches!(self, Self::Z3 | Self::Both)
    }

    pub fn name(self) -> &'static str {
        match self {
            Self::Decision => "decision",
            Self::Z3 => "z3",
            Self::Both => "both",
        }
    }
}

/// The console/record note for benchmarks `solve` does not run.
pub const RACE_SKIP_NOTE: &str =
    "race-check benchmark: no VC to solve; its verdict comes from `volta-bench generate`";

/// One benchmark's fate under `solve`.
#[derive(Debug)]
pub enum SolveItem {
    /// An equivalence benchmark: solved (or failed loudly trying).
    /// Boxed: a full [`BenchmarkResult`] is ~500 bytes, dwarfing the
    /// `Skipped` variant.
    Solved(Box<BenchmarkResult>),
    /// A race-check benchmark: nothing to solve (see [`RACE_SKIP_NOTE`]).
    Skipped {
        name: String,
        category: BenchmarkCategory,
    },
}

impl BenchmarkRunner {
    /// `solve` over a benchmark list: read the vcs manifest once (absent: warn
    /// and skip the guard; unreadable: hard error), then
    /// [`run_solve`](Self::run_solve) each benchmark.
    pub fn solve_suite(
        &self,
        defs: &[BenchmarkDef],
        backend: SolveBackend,
    ) -> Result<Vec<SolveItem>> {
        let vcs_dir = self
            .config
            .vcs_dir
            .as_deref()
            .ok_or_else(|| anyhow!("solve requires a VC dump directory"))?;
        let manifest = manifest::read_manifest(vcs_dir)?;
        if manifest.is_none() {
            eprintln!(
                "warning: no {} - skipping the staleness check (dumps not \
                 written by `volta-bench generate`?)",
                manifest::manifest_path(vcs_dir).display()
            );
        }
        Ok(defs
            .iter()
            .map(|def| {
                if self.config.verbose && def.optimized.is_some() {
                    eprintln!("solving {} ...", def.name);
                }
                let item = self.run_solve(def, backend, manifest.as_ref());
                if self.config.verbose
                    && let SolveItem::Solved(result) = &item
                {
                    eprintln!(
                        "  -> {} in {:.1}s",
                        result.outcome.status(),
                        result.elapsed_secs
                    );
                }
                item
            })
            .collect())
    }

    /// Solve one benchmark from its dump. Any failure (missing/corrupt dump,
    /// manifest disagreement, solve error) becomes a per-benchmark `Error`
    /// result rather than aborting the run.
    pub fn run_solve(
        &self,
        def: &BenchmarkDef,
        backend: SolveBackend,
        manifest: Option<&VcsManifest>,
    ) -> SolveItem {
        if def.optimized.is_none() {
            // stderr like the rest of the progress chatter (must survive
            // a closed stdout pipe).
            eprintln!("note: {}: skipped - {}", def.name, RACE_SKIP_NOTE);
            return SolveItem::Skipped {
                name: def.name.clone(),
                category: def.category,
            };
        }
        let start = Instant::now();
        let output = self
            .solve_inner(def, backend, manifest)
            .unwrap_or_else(|failure| failure.into_output());
        SolveItem::Solved(Box::new(self.assemble_result(def, start, output)))
    }

    fn solve_inner(
        &self,
        def: &BenchmarkDef,
        backend: SolveBackend,
        manifest: Option<&VcsManifest>,
    ) -> Result<RunOutput, RunFailure> {
        let vcs_dir = self
            .config
            .vcs_dir
            .as_deref()
            .ok_or_else(|| anyhow!("solve requires a VC dump directory"))?;
        let path = vc_dump_path(vcs_dir, &def.name);
        if !path.exists() {
            return Err(anyhow!(
                "no VC dump at {}; run `volta-bench generate single \"{}\"` \
                 (or `volta-bench generate all`) first",
                path.display(),
                def.name
            )
            .into());
        }
        // The dump file exists from here on: every later failure keeps
        // pointing at it in the record (`RunFailure::dump_path`),
        // matching the one-shot pipeline's post-dump failures.
        let fail = |error: anyhow::Error| RunFailure {
            error,
            dump_path: Some(path.clone()),
        };

        // Load (timed into `dump_load_secs`, not the solve spans): fingerprint
        // the raw bytes against the manifest before decoding, then decode via
        // `read_vc_dump_bytes`, which validates the header and every id.
        let load_start = Instant::now();
        let bytes = std::fs::read(&path)
            .with_context(|| format!("reading VC dump {}", path.display()))
            .map_err(fail)?;
        if let Some(manifest) = manifest {
            match manifest::check_dump(manifest, &def.name, &bytes).map_err(fail)? {
                ManifestCheck::Verified => {}
                ManifestCheck::NoEntry => eprintln!(
                    "warning: {}: dump has no manifest entry (hand-copied?); \
                     skipping the staleness check",
                    def.name
                ),
            }
        }
        let dump = read_vc_dump_bytes(&bytes)
            .with_context(|| {
                format!(
                    "loading VC dump {} (if it is stale or corrupt, re-run \
                     `volta-bench generate`)",
                    path.display()
                )
            })
            .map_err(fail)?;
        drop(bytes);
        let dump_load_secs = load_start.elapsed().as_secs_f64();

        let reference = dump.reference;
        let optimized = dump.optimized;
        let arrays = def.reference.config.output_array_names();
        let mut stats = BenchmarkStats {
            dump_load_secs: Some(dump_load_secs),
            ..BenchmarkStats::default()
        };
        let paired = paired_elements(&reference, &optimized, &arrays)
            .map_err(|e| fail(anyhow!("pairing the dumped footprints: {}", e)))?;
        stats.elements_total = paired.iter().map(|(_, common)| common.len() as u64).sum();

        // --- Decision solve (backend decision|both): the same phase
        // function as the one-shot pipeline, iterations and all.
        let outcome = if backend.runs_decision() {
            self.check_equivalence(&reference, &optimized, &arrays, &mut stats)
                .map_err(fail)?
        } else {
            stats.elements_checked = sampled_elements(&paired, self.config.sample).len() as u64;
            // `assemble_result` folds the Z3 phase's `not_equivalent`
            // counts into `refutations` - the judgment lives there so
            // every entry point applies the same rule.
            ActualOutcome::Z3Only { refutations: 0 }
        };

        // --- Z3 solve (backend z3|both): the same phase function as the
        // one-shot `--z3` comparison, over the same sampled elements.
        let z3 = if backend.runs_z3() {
            let options = self.config.z3.as_ref().ok_or_else(|| {
                fail(anyhow!(
                    "solve backend '{}' requires Z3 options in the runner config",
                    backend.name()
                ))
            })?;
            let sampled = sampled_elements(&paired, self.config.sample);
            Some(run_z3_phase(
                &reference,
                &optimized,
                &arrays,
                &sampled,
                self.config.sample,
                self.config.iterations,
                options,
            ))
        } else {
            None
        };

        Ok(RunOutput {
            outcome,
            stats,
            dump_path: Some(path),
            z3,
        })
    }
}

#[cfg(test)]
mod tests {
    use volta_analysis::eval::AnalysisConfig;
    use volta_equivalence::vc_dump::{VcDump, write_vc_dump};
    use volta_expr::SymbolicOutputs;
    use volta_expr::{ExprArena, ExprId};

    use super::*;
    use crate::config::{BenchmarkDef, KernelRun, f32_output};
    use crate::runner::RunnerConfig;

    /// An equivalence benchmark whose config declares one output array
    /// `out`; `solve` never reads the kernel paths, only the dump.
    fn synthetic_def() -> BenchmarkDef {
        let mut config = AnalysisConfig::new((1, 1, 1));
        config.arrays = vec![f32_output("out", 0x1000, 2)];
        let run = || KernelRun::new("unused.ptx", "k", config.clone());
        BenchmarkDef::equivalence("Synthetic Pair", BenchmarkCategory::Reduction, run(), run())
    }

    /// A snapshot writing `out[0..len)` as reads of input array `src`.
    fn snapshot(src: &str, len: u64) -> SymbolicOutputs {
        let mut arena = ExprArena::new();
        let sid = arena.intern_string(src);
        let elems: Vec<(u64, ExprId)> =
            (0..len).map(|i| (i, arena.input_element(sid, i))).collect();
        SymbolicOutputs {
            arena,
            outputs: vec![("out".to_string(), elems)],
        }
    }

    fn runner(vcs_dir: &std::path::Path) -> BenchmarkRunner {
        BenchmarkRunner::new(RunnerConfig {
            vcs_dir: Some(vcs_dir.to_path_buf()),
            ..RunnerConfig::default()
        })
    }

    fn temp_vcs_dir(tag: &str) -> std::path::PathBuf {
        let dir = std::env::temp_dir().join(format!("volta_solve_{}_{}", tag, std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        dir
    }

    /// A missing dump is a per-benchmark FAILURE record that names the
    /// generate command to run - not a panic, not a silent skip. With no
    /// file on disk there is no dump path to record.
    #[test]
    fn missing_dump_is_a_failure_naming_generate() {
        let dir = temp_vcs_dir("missing");
        let def = synthetic_def();
        let SolveItem::Solved(result) = runner(&dir).run_solve(&def, SolveBackend::Decision, None)
        else {
            panic!("equivalence benchmarks are solved, not skipped");
        };
        assert!(!result.passed);
        assert_eq!(result.outcome.status(), "ERR");
        assert_eq!(result.dump_path, None);
        let ActualOutcome::Error { message } = &result.outcome else {
            panic!("missing dump must be an Error outcome");
        };
        assert!(message.contains("no VC dump"), "{message}");
        assert!(
            message.contains("volta-bench generate single \"Synthetic Pair\""),
            "{message}"
        );
        let _ = std::fs::remove_dir_all(&dir);
    }

    /// Race-check benchmarks are skipped (their verdicts come from
    /// `generate`), even when a dump directory exists.
    #[test]
    fn race_benchmarks_are_skipped() {
        let dir = temp_vcs_dir("race");
        let def = BenchmarkDef::race_check(
            "Racy Kernel",
            BenchmarkCategory::DataRace,
            KernelRun::new("unused.ptx", "k", AnalysisConfig::new((1, 1, 1))),
            true,
        );
        let item = runner(&dir).run_solve(&def, SolveBackend::Decision, None);
        let SolveItem::Skipped { name, .. } = item else {
            panic!("race-check benchmarks must be skipped by solve");
        };
        assert_eq!(name, "Racy Kernel");
        let _ = std::fs::remove_dir_all(&dir);
    }

    /// A well-formed dump solves with its load time recorded; a disagreeing
    /// manifest makes it a per-benchmark failure that still keeps `dump_path`.
    #[test]
    fn solve_from_dump_checks_manifest_and_solves() {
        let dir = temp_vcs_dir("dump");
        let def = synthetic_def();
        let dump = VcDump {
            reference: snapshot("in", 2),
            optimized: snapshot("in", 2),
        };
        let dump_path = vc_dump_path(&dir, &def.name);
        write_vc_dump(&dump_path, &dump).unwrap();
        let dump_bytes = std::fs::read(&dump_path).unwrap();

        // Matching manifest (the fingerprint of the exact file bytes):
        // verified and solved (identical expressions on both sides ->
        // EQUIV, which matches the expectation).
        let mut manifest = VcsManifest::new();
        manifest::record_dump(
            &mut manifest,
            &def.name,
            manifest::fingerprint_bytes(&dump_bytes),
            &dump.reference.outputs,
            &dump.optimized.outputs,
        );
        let SolveItem::Solved(result) =
            runner(&dir).run_solve(&def, SolveBackend::Decision, Some(&manifest))
        else {
            panic!("solved, not skipped");
        };
        assert_eq!(result.outcome.status(), "EQUIV");
        assert!(result.passed);
        assert!(result.stats.dump_load_secs.is_some());
        assert_eq!(result.stats.elements_checked, 2);
        assert_eq!(result.stats.elements_total, 2);
        assert!(!result.stats.solve_iters_secs.is_empty());

        // Stale manifest (recorded a different generation's fingerprint):
        // hard failure pointing at generate, record pointing at the dump.
        let mut stale = VcsManifest::new();
        manifest::record_dump(
            &mut stale,
            &def.name,
            manifest::fingerprint_bytes(b"a different generation's bytes"),
            &dump.reference.outputs,
            &dump.optimized.outputs,
        );
        let SolveItem::Solved(result) =
            runner(&dir).run_solve(&def, SolveBackend::Decision, Some(&stale))
        else {
            panic!("solved, not skipped");
        };
        assert!(!result.passed);
        assert_eq!(
            result.dump_path.as_deref(),
            Some(dump_path.as_path()),
            "post-existence failures keep pointing at the dump file"
        );
        let ActualOutcome::Error { message } = &result.outcome else {
            panic!("manifest disagreement must be an Error outcome");
        };
        assert!(
            message.contains("does not match the vcs manifest"),
            "{message}"
        );
        assert!(message.contains("generate"), "{message}");
        let _ = std::fs::remove_dir_all(&dir);
    }
}
