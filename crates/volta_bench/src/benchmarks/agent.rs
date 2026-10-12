//! Claude-Code-generated GEMMs (Table 5): GEMM-1/2/3 vs a 32x32-tile coalesced
//! reference. All use 512 threads and M = N = K = 4096 with alpha/beta baked to 1/0
//! via the `ALPHA`/`BETA` macros (C still reads its old value; see `config`).

use volta_analysis::eval::{AnalysisConfig, ParamValue};

use crate::config::{BenchmarkCategory, BenchmarkDef, KernelRun, f32_inout, f32_input};

const N: u64 = 4096;
const A_BASE: u64 = 0x1_0000_0000;
const B_BASE: u64 = 0x2_0000_0000;
const C_BASE: u64 = 0x3_0000_0000;

/// `sgemm(A, B, C)` with 512 threads (as in every .cu and paper Table 5) and a 1-D grid
/// over 32x32 tiles matching the kernels' `blockIdx.x` mod/div decomposition; no PTX
/// reads `%nctaid`, so the grid is documentation only. All shared memory is static.
fn config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((512, 1, 1));
    config.grid_dim = ((N / 32) as u32 * (N / 32) as u32, 1, 1);
    // C is read even though beta = 0 is baked in (nvcc keeps the
    // `0.0 * C[i]` term under IEEE semantics), so it must be initialized.
    config.arrays = vec![
        f32_input("A", A_BASE, N * N),
        f32_input("B", B_BASE, N * N),
        f32_inout("C", C_BASE, N * N),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("A".to_string()),
        ParamValue::ArrayPtr("B".to_string()),
        ParamValue::ArrayPtr("C".to_string()),
    ];
    config
}

fn reference() -> KernelRun {
    KernelRun::new(
        "06_agent_gemm/MatMul-1-ref_32x32.ptx",
        "_Z25sgemm_global_mem_coalescePKfS0_Pf",
        config(),
    )
}

pub fn benchmarks() -> Vec<BenchmarkDef> {
    let files = ["GEMM-1.ptx", "GEMM-2.ptx", "GEMM-3.ptx"];
    files
        .into_iter()
        .enumerate()
        .map(|(i, file)| {
            BenchmarkDef::equivalence(
                format!("(MatMul-1-32x32, GEMM-{})", i + 1),
                BenchmarkCategory::AgentGenerated,
                reference(),
                KernelRun::new(
                    &format!("06_agent_gemm/{}", file),
                    "_Z15sgemm_optimizedPKfS0_Pf",
                    config(),
                ),
            )
        })
        .collect()
}
