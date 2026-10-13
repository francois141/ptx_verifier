//! End-to-end tests over the paper kernels: each kernel is parsed, symbolically executed under
//! its benchmark config, and checked against a spec of what it computes (`tests/specs/`) at its
//! first output elements, plus a deliberately wrong spec it must not match.

use std::collections::HashMap;
use std::path::Path;

use volta_analysis::driver::analyze_kernel;
use volta_bench::runner::load_module;
use volta_bench::{KERNELS_DIR, KernelRun, all_benchmarks};
use volta_equivalence::{CanonValueEquality, EquivOutcome, check_output_equivalence};
use volta_expr::SymbolicOutputs;
use volta_expr::spec::unfold;

/// Output elements checked per array, a flat-index prefix as in `unfold`: one, like the
/// paper's `--sample 1` runs, keeps the attention VCs cheap.
const SAMPLE: u64 = 1;

/// A spec file and the dim values it is instantiated under.
struct Spec {
    file: &'static str,
    src: &'static str,
    dims: &'static [(&'static str, u64)],
}

macro_rules! spec {
    ($file:literal, $dims:expr) => {
        Spec {
            file: $file,
            src: include_str!(concat!("specs/", $file, ".spec")),
            dims: $dims,
        }
    };
}

/// What a kernel family computes (`spec`) and a near miss it must not match (`wrong`),
/// compared over the output `arrays`.
struct Family {
    arrays: &'static [&'static str],
    spec: Spec,
    wrong: Spec,
}

/// The run the benchmark suite defines for the kernel at `path`, so the tests use exactly
/// the paper evaluation's launch configs.
fn benchmark_run(path: &str) -> KernelRun {
    all_benchmarks()
        .benchmarks
        .into_iter()
        .flat_map(|def| [Some(def.reference), def.optimized])
        .flatten()
        .find(|run| run.path == path)
        .unwrap_or_else(|| panic!("no benchmark runs {path}"))
}

fn kernel_outputs(run: &KernelRun) -> SymbolicOutputs {
    let module = load_module(&Path::new(KERNELS_DIR).join(&run.path))
        .unwrap_or_else(|e| panic!("{}: {e:#}", run.path));
    analyze_kernel(
        &module,
        Some(&run.kernel),
        run.config.clone(),
        &CanonValueEquality,
    )
    .unwrap_or_else(|e| panic!("{}: analysis failed: {e}", run.path))
    .exprs
}

/// The kernel's outputs cut down to the checked arrays' first `SAMPLE` elements; an element
/// the kernel did not write then surfaces as a footprint mismatch in the check.
fn restrict(kernel: SymbolicOutputs, arrays: &[&str]) -> SymbolicOutputs {
    let outputs = kernel
        .outputs
        .into_iter()
        .filter(|(name, _)| arrays.contains(&name.as_str()))
        .map(|(name, elems)| {
            let elems = elems.into_iter().filter(|&(i, _)| i < SAMPLE).collect();
            (name, elems)
        })
        .collect();
    SymbolicOutputs {
        arena: kernel.arena,
        outputs,
    }
}

fn spec_outputs(spec: &Spec) -> SymbolicOutputs {
    let parsed = volta_spec::parse_spec(spec.src)
        .unwrap_or_else(|e| panic!("{}.spec: parse error: {}", spec.file, e.error));
    let dims: HashMap<String, u64> = spec.dims.iter().map(|&(d, v)| (d.to_string(), v)).collect();
    let (env, specs) = volta_spec::instantiate(&parsed, &dims)
        .unwrap_or_else(|e| panic!("{}.spec: instantiate: {e}", spec.file));
    unfold(&specs, &env, SAMPLE).unwrap_or_else(|e| panic!("{}.spec: unfold: {e}", spec.file))
}

fn assert_kernel_computes(path: &str, family: &Family) {
    let kernel = restrict(kernel_outputs(&benchmark_run(path)), family.arrays);
    let arrays: Vec<String> = family.arrays.iter().map(|a| a.to_string()).collect();
    let verdict = |spec: &Spec| {
        check_output_equivalence(&kernel, &spec_outputs(spec), &arrays)
            .unwrap_or_else(|e| panic!("{path} vs {}.spec: check errored: {e}", spec.file))
    };
    let outcome = verdict(&family.spec);
    assert!(
        matches!(outcome, EquivOutcome::Equivalent),
        "{path} must compute {}.spec at its first {SAMPLE} elements, got {outcome:?}",
        family.spec.file
    );
    assert!(
        matches!(verdict(&family.wrong), EquivOutcome::NotEquivalent { .. }),
        "SOUNDNESS BUG: {path} matched the wrong spec {}.spec",
        family.wrong.file
    );
}

const REDUCTION: Family = Family {
    arrays: &["out"],
    spec: spec!("reduction", &[("N", 128), ("O", 1)]),
    wrong: spec!("reduction", &[("N", 127), ("O", 1)]),
};

const GEMM_DIMS: &[(&str, u64)] = &[("M", 4096), ("N", 4096), ("K", 4096)];

const MATMUL: Family = Family {
    arrays: &["C"],
    spec: spec!("matmul", GEMM_DIMS),
    wrong: spec!("matmul_without_beta", GEMM_DIMS),
};

const AGENT_GEMM: Family = Family {
    arrays: &["C"],
    spec: spec!("gemm", GEMM_DIMS),
    wrong: spec!("gemm_transposed_b", GEMM_DIMS),
};

const ATTENTION_DIMS: &[(&str, u64)] = &[("LQ", 16), ("LK", 512), ("D", 64)];

const ATTENTION: Family = Family {
    arrays: &["O"],
    spec: spec!("attention", ATTENTION_DIMS),
    wrong: spec!("attention_unscaled", ATTENTION_DIMS),
};

const CAUSAL_ATTENTION: Family = Family {
    arrays: &["O"],
    spec: spec!("causal_attention", ATTENTION_DIMS),
    wrong: spec!("attention", ATTENTION_DIMS),
};

const CONV2D_DIMS: &[(&str, u64)] = &[
    ("NB", 100),
    ("CI", 3),
    ("H", 224),
    ("W", 224),
    ("CO", 96),
    ("KH", 11),
    ("KW", 11),
    ("HO", 55),
    ("WO", 55),
];

const CONV2D: Family = Family {
    arrays: &["output"],
    spec: spec!("conv2d", CONV2D_DIMS),
    wrong: spec!("conv2d_without_bias", CONV2D_DIMS),
};

/// TileLang's square problem size grows with the CTA tile (read off the PTX).
const fn tilelang(size: u64) -> &'static [(&'static str, u64)] {
    match size {
        1024 => &[("M", 1024), ("N", 1024), ("K", 1024)],
        2048 => &[("M", 2048), ("N", 2048), ("K", 2048)],
        _ => &[("M", 4096), ("N", 4096), ("K", 4096)],
    }
}

const fn tilelang_gemm(size: u64) -> Family {
    Family {
        arrays: &["C"],
        spec: spec!("tilelang_gemm", tilelang(size)),
        wrong: spec!("tilelang_gemm_untransposed", tilelang(size)),
    }
}

/// One `#[test]` per kernel, so each failure names its kernel.
macro_rules! kernel_tests {
    ($($test:ident: $path:literal => $family:expr;)*) => {$(
        #[test]
        fn $test() {
            assert_kernel_computes($path, &$family);
        }
    )*};
}

kernel_tests! {
    red_1: "01_reduction/Red-1.ptx" => REDUCTION;
    red_2: "01_reduction/Red-2.ptx" => REDUCTION;
    red_3: "01_reduction/Red-3.ptx" => REDUCTION;
    red_4: "01_reduction/Red-4.ptx" => REDUCTION;

    matmul_1: "02_matmul/MatMul-1.ptx" => MATMUL;
    matmul_2: "02_matmul/MatMul-2.ptx" => MATMUL;
    matmul_3: "02_matmul/MatMul-3.ptx" => MATMUL;
    matmul_4: "02_matmul/MatMul-4.ptx" => MATMUL;
    matmul_5: "02_matmul/MatMul-5.ptx" => MATMUL;
    matmul_6: "02_matmul/MatMul-6.ptx" => MATMUL;
    matmul_7: "02_matmul/MatMul-7.ptx" => MATMUL;

    attention: "03_attention/Attention.ptx" => ATTENTION;
    attention_fa1: "03_attention/FA1.ptx" => ATTENTION;
    attention_fa1_tc: "03_attention/FA1-TC.ptx" => ATTENTION;
    attention_fa2_tc: "03_attention/FA2-TC.ptx" => ATTENTION;

    causal_attention_naive: "04_causal_attention/Causal-Attention-naive.ptx" => CAUSAL_ATTENTION;
    causal_attention_fused: "04_causal_attention/Causal-Attention-fused.ptx" => CAUSAL_ATTENTION;
    causal_fa1_naive: "04_causal_attention/Causal-FA1-naive.ptx" => CAUSAL_ATTENTION;
    causal_fa1_fused: "04_causal_attention/Causal-FA1-fused.ptx" => CAUSAL_ATTENTION;
    causal_fa1_tc_naive: "04_causal_attention/Causal-FA1-TC-naive.ptx" => CAUSAL_ATTENTION;
    causal_fa1_tc_fused: "04_causal_attention/Causal-FA1-TC-fused.ptx" => CAUSAL_ATTENTION;
    causal_fa2_tc_naive: "04_causal_attention/Causal-FA2-TC-naive.ptx" => CAUSAL_ATTENTION;
    causal_fa2_tc_fused: "04_causal_attention/Causal-FA2-TC-fused.ptx" => CAUSAL_ATTENTION;

    conv2d_ref: "05_conv2d_llm/Conv2D-ref.ptx" => CONV2D;
    conv2d_opt: "05_conv2d_llm/Conv2D-opt.ptx" => CONV2D;

    agent_gemm_ref: "06_agent_gemm/MatMul-1-ref_32x32.ptx" => AGENT_GEMM;
    agent_gemm_1: "06_agent_gemm/GEMM-1.ptx" => AGENT_GEMM;
    agent_gemm_2: "06_agent_gemm/GEMM-2.ptx" => AGENT_GEMM;
    agent_gemm_3: "06_agent_gemm/GEMM-3.ptx" => AGENT_GEMM;

    tilelang_32x32x32_ref: "07_tilelang/32x32x32-ref.ptx" => tilelang_gemm(1024);
    tilelang_32x32x32_opt: "07_tilelang/32x32x32-opt.ptx" => tilelang_gemm(1024);
    tilelang_64x32x32_ref: "07_tilelang/64x32x32-ref.ptx" => tilelang_gemm(2048);
    tilelang_64x32x32_opt: "07_tilelang/64x32x32-opt.ptx" => tilelang_gemm(2048);
    tilelang_64x64x32_ref: "07_tilelang/64x64x32-ref.ptx" => tilelang_gemm(4096);
    tilelang_64x64x32_opt: "07_tilelang/64x64x32-opt.ptx" => tilelang_gemm(4096);
}
