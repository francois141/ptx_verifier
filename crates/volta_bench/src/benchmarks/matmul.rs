//! Boehm SGEMM tutorial (Table 2): MatMul-1..7, checked against MatMul-1.
//! Each computes a 64x64 tile of C = alpha*A*B + beta*C (M = N = K =
//! 4096), differing in tiling, hence thread counts.

use volta_analysis::eval::{AnalysisConfig, ParamValue};

use crate::config::{BenchmarkCategory, BenchmarkDef, KernelRun, f32_inout, f32_input};

const N: u64 = 4096;
const A_BASE: u64 = 0x1_0000_0000;
const B_BASE: u64 = 0x2_0000_0000;
const C_BASE: u64 = 0x3_0000_0000;

/// `sgemm(A, B, C, alpha, beta)` with symbolic alpha/beta; C is read then
/// written, hence inout. The grid is documentation only: no MatMul PTX
/// reads `%nctaid`, so CTA (0,0) computes C's top-left tile.
fn config(threads: u32) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.grid_dim = (64, 64, 1);
    config.arrays = vec![
        f32_input("A", A_BASE, N * N),
        f32_input("B", B_BASE, N * N),
        f32_inout("C", C_BASE, N * N),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("A".to_string()),
        ParamValue::ArrayPtr("B".to_string()),
        ParamValue::ArrayPtr("C".to_string()),
        ParamValue::SymFloat("alpha".to_string()),
        ParamValue::SymFloat("beta".to_string()),
    ];
    config
}

fn kernel(file: &str, name: &str, threads: u32) -> KernelRun {
    KernelRun::new(&format!("02_matmul/{}", file), name, config(threads))
}

fn matmul1() -> KernelRun {
    // 512 threads = BM*BN/TM = 64*64/8 results per thread (MatMul-1.cu).
    kernel("MatMul-1.ptx", "_Z5sgemmPKfS0_Pfff", 512)
}

pub fn benchmarks() -> Vec<BenchmarkDef> {
    // Threads = 64*64 / per-thread tile: MatMul-2 = 512, MatMul-3/4/5 =
    // 128, MatMul-6/7 = 256 (`NUM_THREADS`). Matches Table 2's block syncs:
    // threads x 1024 bar.syncs.
    let defs = [
        ("MatMul-2.ptx", "_Z5sgemmPKfS0_Pfff", 512u32),
        ("MatMul-3.ptx", "_Z5sgemmPfS_S_ff", 128),
        ("MatMul-4.ptx", "_Z5sgemmPfS_S_ff", 128),
        ("MatMul-5.ptx", "_Z5sgemmPfS_S_ff", 128),
        ("MatMul-6.ptx", "_Z5sgemmPKfS0_Pfff", 256),
        ("MatMul-7.ptx", "_Z5sgemmPKfS0_Pfff", 256),
    ];

    let mut benches = vec![BenchmarkDef::equivalence(
        "(MatMul-1, MatMul-1)",
        BenchmarkCategory::MatMul,
        matmul1(),
        matmul1(),
    )];
    for (i, (file, name, threads)) in defs.into_iter().enumerate() {
        benches.push(BenchmarkDef::equivalence(
            format!("(MatMul-1, MatMul-{})", i + 2),
            BenchmarkCategory::MatMul,
            matmul1(),
            kernel(file, name, threads),
        ));
    }
    benches
}
