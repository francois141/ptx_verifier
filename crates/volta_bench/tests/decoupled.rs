//! End-to-end check of the phase-decoupled workflow: `generate` then `solve` must
//! reach the one-shot pipeline's verdict from a real dump + manifest, on the smallest
//! real equivalence benchmark (one iteration each; timing is not under test).

use std::num::NonZeroUsize;
use std::path::PathBuf;

use volta_bench::{
    BenchmarkDef, BenchmarkRunner, KERNELS_DIR, RunnerConfig, SolveBackend, SolveItem,
    all_benchmarks, manifest, results,
};

fn benchmark(name: &str) -> BenchmarkDef {
    all_benchmarks()
        .benchmarks
        .iter()
        .find(|b| b.name == name)
        .unwrap_or_else(|| panic!("benchmark {} not found", name))
        .clone()
}

fn runner(vcs_dir: Option<PathBuf>) -> BenchmarkRunner {
    BenchmarkRunner::new(RunnerConfig {
        kernels_dir: PathBuf::from(KERNELS_DIR),
        vcs_dir,
        iterations: NonZeroUsize::MIN,
        ..RunnerConfig::default()
    })
}

#[test]
fn generate_then_solve_matches_the_one_shot_verdict() {
    let def = benchmark("(Red-1, Red-2)");
    let out = std::env::temp_dir().join(format!("volta_decoupled_{}", std::process::id()));
    let vcs_dir = out.join("vcs");

    // The one-shot pipeline (no dump involved): the reference verdict.
    let one_shot = runner(None).run(&def);
    assert_eq!(one_shot.outcome.status(), "EQUIV");
    assert!(one_shot.passed);

    // generate: dump + manifest written, gen stats only, no solve.
    let generated = runner(Some(vcs_dir.clone())).run_generate(&def);
    assert_eq!(generated.outcome.status(), "GEN");
    assert!(
        generated.passed,
        "generate must pass: {:?}",
        generated.outcome
    );
    assert!(!generated.stats.vc_gen_iters_secs.is_empty());
    assert!(
        generated.stats.solve_iters_secs.is_empty(),
        "generate must not solve"
    );
    let dump_path = generated
        .dump_path
        .as_ref()
        .expect("generate writes the dump");
    assert!(dump_path.exists());
    let manifest = manifest::read_manifest(&vcs_dir)
        .expect("manifest is readable")
        .expect("generate writes the manifest");
    let entry = &manifest.entries[&results::sanitize_name(&def.name)];
    assert_eq!(entry.benchmark, def.name);
    // Red benchmarks write out[0] only.
    assert_eq!(entry.reference_elements["out"], 1);
    // The recorded fingerprint is the FNV-1a of the exact file bytes -
    // what `solve` recomputes from `fs::read` below.
    assert_eq!(
        entry.vc_fingerprint,
        manifest::fingerprint_bytes(&std::fs::read(dump_path).unwrap()),
        "manifest fingerprint must match the on-disk dump bytes"
    );

    // The record shapes: gen-only for generate.
    let record = results::generate_record(&generated);
    assert!(record.get("vc_gen_iters_secs").is_some());
    assert!(record.get("solve_iters_secs").is_none());

    // solve: from the dump, decision backend - the same verdict as the
    // one-shot run, same element coverage, and the load time recorded.
    let items = runner(Some(vcs_dir.clone()))
        .solve_suite(std::slice::from_ref(&def), SolveBackend::Decision)
        .expect("manifest is present and valid");
    assert_eq!(items.len(), 1);
    let SolveItem::Solved(solved) = &items[0] else {
        panic!("equivalence benchmarks are solved, not skipped");
    };
    assert_eq!(solved.outcome.status(), one_shot.outcome.status());
    assert!(solved.passed);
    assert_eq!(
        solved.stats.elements_checked,
        one_shot.stats.elements_checked
    );
    assert_eq!(solved.stats.elements_total, one_shot.stats.elements_total);
    assert!(solved.stats.dump_load_secs.is_some());
    assert!(
        solved.stats.vc_gen_iters_secs.is_empty(),
        "solve must not generate"
    );
    let record = results::solve_record(solved);
    assert!(record.get("dump_load_secs").is_some());
    assert!(record.get("vc_gen_iters_secs").is_none());

    // A race-check benchmark under solve is skipped: its verdict belongs to
    // generate, which shares the one-shot path's generation phase.
    let race = benchmark("Red-5 (racy)");
    let items = runner(Some(vcs_dir))
        .solve_suite(std::slice::from_ref(&race), SolveBackend::Decision)
        .unwrap();
    assert!(matches!(&items[0], SolveItem::Skipped { name, .. } if name == "Red-5 (racy)"));

    let _ = std::fs::remove_dir_all(&out);
}

/// A single-thread kernel writing `1.0f` to `out[0]` - enough to run the
/// whole generate pipeline (parse, lower, execute, pair, dump) in
/// microseconds for the staleness scenario below.
const TINY_PTX: &str = "\
.version 8.0
.target sm_80
.address_size 64

.visible .entry k(
    .param .u64 k_param_0
)
{
    .reg .f32 %f<2>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    cvta.to.global.u64 %rd2, %rd1;
    mov.f32 %f1, 0f3F800000;
    st.global.f32 [%rd2], %f1;
    ret;
}
";

/// A failed regeneration must not leave a stale dump for `solve` to silently use:
/// generate ok -> generate fails (bad kernels-dir) -> dump and manifest entry gone
/// -> solve fails loudly, naming `generate`.
#[test]
fn failed_regeneration_removes_the_stale_dump() {
    use volta_analysis::eval::{AnalysisConfig, ParamValue};
    use volta_bench::config::f32_output;
    use volta_bench::{ActualOutcome, BenchmarkCategory, KernelRun};

    let out = std::env::temp_dir().join(format!("volta_stale_regen_{}", std::process::id()));
    let kernels = out.join("kernels");
    let vcs_dir = out.join("vcs");
    std::fs::create_dir_all(&kernels).unwrap();
    std::fs::write(kernels.join("tiny.ptx"), TINY_PTX).unwrap();

    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![f32_output("out", 0x1000, 1)];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let run = || KernelRun::new("tiny.ptx", "k", config.clone());
    let def = volta_bench::BenchmarkDef::equivalence(
        "Stale Pair",
        BenchmarkCategory::Reduction,
        run(),
        run(),
    );
    let runner_with = |kernels_dir: PathBuf| {
        BenchmarkRunner::new(RunnerConfig {
            kernels_dir,
            vcs_dir: Some(vcs_dir.clone()),
            iterations: NonZeroUsize::MIN,
            ..RunnerConfig::default()
        })
    };

    // 1. A successful generate: dump + manifest entry exist.
    let ok = runner_with(kernels.clone()).run_generate(&def);
    assert_eq!(ok.outcome.status(), "GEN");
    assert!(ok.passed, "generate must pass: {:?}", ok.outcome);
    let dump_path = ok.dump_path.clone().expect("generate writes the dump");
    assert!(dump_path.exists());
    let slug = results::sanitize_name(&def.name);
    assert!(
        manifest::read_manifest(&vcs_dir)
            .unwrap()
            .expect("manifest written")
            .entries
            .contains_key(&slug)
    );

    // 2. A failed regeneration (unreadable kernels-dir): the benchmark
    // errors, and the older dump and manifest entry are removed.
    let failed = runner_with(out.join("no-such-kernels")).run_generate(&def);
    assert_eq!(failed.outcome.status(), "ERR");
    assert!(!failed.passed);
    assert_eq!(failed.dump_path, None, "no valid dump survives the failure");
    assert!(
        !dump_path.exists(),
        "the stale dump file must be removed after a failed regeneration"
    );
    assert!(
        !manifest::read_manifest(&vcs_dir)
            .unwrap()
            .expect("manifest still present for other entries")
            .entries
            .contains_key(&slug),
        "the stale manifest entry must be removed too"
    );

    // 3. solve now fails loudly, naming the generate command - instead
    // of silently solving the pre-failure VCs.
    let items = runner_with(kernels)
        .solve_suite(std::slice::from_ref(&def), SolveBackend::Decision)
        .unwrap();
    let SolveItem::Solved(solved) = &items[0] else {
        panic!("equivalence benchmarks are solved, not skipped");
    };
    assert!(!solved.passed);
    assert_eq!(solved.outcome.status(), "ERR");
    let ActualOutcome::Error { message } = &solved.outcome else {
        panic!("missing dump must be an Error outcome");
    };
    assert!(message.contains("no VC dump"), "{message}");
    assert!(message.contains("generate"), "{message}");

    let _ = std::fs::remove_dir_all(&out);
}
