//! Harris reduction tutorial (Table 1). Red-1..4 are checked for
//! equivalence against Red-1; Red-5/6/7 use deprecated warp-synchronous
//! programming and must be rejected.

use volta_analysis::eval::{AnalysisConfig, ParamValue};

use crate::config::{
    BenchmarkCategory, BenchmarkDef, ExpectedOutcome, KernelRun, f32_input, f32_output,
};

const IN_BASE: u64 = 0x10000;
const OUT_BASE: u64 = 0x20000;

/// `reduceN(const int* g_idata, int* g_odata)` over `n` ints (width 4).
/// Single-block reducers that write only `g_odata[0]`, so `out` has length 1;
/// no PTX reads `%nctaid`, so the (1,1,1) grid is exact.
fn config(threads: u32, n: u64, dynamic_shared: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![f32_input("in", IN_BASE, n), f32_output("out", OUT_BASE, 1)];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config.dynamic_shared_bytes = dynamic_shared;
    config
}

fn kernel(file: &str, kernel: &str, threads: u32, n: u64, dynamic_shared: u64) -> KernelRun {
    KernelRun::new(
        &format!("01_reduction/{}", file),
        kernel,
        config(threads, n, dynamic_shared),
    )
}

fn red1() -> KernelRun {
    // Block 128 = BLOCK_SIZE in Red-1.cu (the paper's "each CTA reduces 128
    // values using up to 128 threads"); n = 128 (reads g_idata[0..128));
    // dyn-shared 0: sdata is a static `.shared ...[512]` in the PTX.
    kernel("Red-1.ptx", "_Z17reduce1024_1blockPKiPi", 128, 128, 0)
}

pub fn benchmarks() -> Vec<BenchmarkDef> {
    // Block 128 = BLOCK_SIZE; n = 128 (reads g_idata[0..128)); static shared.
    let red2 = kernel("Red-2.ptx", "_Z7reduce2PiS_", 128, 128, 0);
    // Red-3.cu's sized `extern __shared__ sdata[BLOCK_SIZE]` is demoted by nvcc
    // to a static `.shared sdata[512]`, so there is no dynamic window (dyn 0).
    let red3 = kernel("Red-3.ptx", "_Z7reduce3PiS_", 128, 128, 0);
    // Red-4 loads `in[i] + in[i+64]`, so threads 64..128 read `in[128..192)`
    // and n = 192, though only sdata[0..64) feeds the sum (loop starts at
    // s = 32). Static shared.
    let red4 = kernel("Red-4.ptx", "_Z7reduce0PiS_", 128, 192, 0);
    // Red-5/6/7 (BLOCKSIZE=128, real `.extern .shared`): Red-7's
    // `sdata[tid + 128]` reads reach sdata[255] (uninitialized, pure data), so
    // 2048 dyn bytes covers all three. Red-5 reads in[0..192).
    let red5 = kernel("Red-5_racy.ptx", "_Z7reduce0PiS_", 128, 192, 2048);
    let red6 = kernel("Red-6_racy.ptx", "_Z7reduce6ILj128EEvPiS0_", 128, 128, 2048);
    let red7 = kernel(
        "Red-7_racy.ptx",
        "_Z12reduce1blockILj128EEvPKiPi",
        128,
        128,
        2048,
    );

    vec![
        BenchmarkDef::equivalence(
            "(Red-1, Red-1)",
            BenchmarkCategory::Reduction,
            red1(),
            red1(),
        ),
        BenchmarkDef::equivalence("(Red-1, Red-2)", BenchmarkCategory::Reduction, red1(), red2),
        BenchmarkDef::equivalence("(Red-1, Red-3)", BenchmarkCategory::Reduction, red1(), red3),
        BenchmarkDef::equivalence("(Red-1, Red-4)", BenchmarkCategory::Reduction, red1(), red4),
        BenchmarkDef {
            name: "Red-5 (racy)".to_string(),
            category: BenchmarkCategory::Reduction,
            expected: ExpectedOutcome::DataRace,
            reference: red5,
            optimized: None,
        },
        BenchmarkDef {
            name: "Red-6 (racy)".to_string(),
            category: BenchmarkCategory::Reduction,
            expected: ExpectedOutcome::DataRace,
            reference: red6,
            optimized: None,
        },
        BenchmarkDef {
            name: "Red-7 (racy)".to_string(),
            category: BenchmarkCategory::Reduction,
            expected: ExpectedOutcome::DataRace,
            reference: red7,
            optimized: None,
        },
    ]
}
