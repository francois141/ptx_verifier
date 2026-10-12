//! TileLang compiler-generated GEMMs (Table 6): `gemm_basic` vs tensor-core
//! `gemm_tc` pairs at three CTA tile sizes, f16 operands, full 4096-column
//! matrices; each pair's CTA (0,0) computes the same tile.

use volta_analysis::eval::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};

use crate::config::{BenchmarkCategory, BenchmarkDef, KernelRun, f16_input};

/// Full matrix extent (row stride observed in the PTX: 8192 bytes = 4096 f16)
const N: u64 = 4096;

const A_BASE: u64 = 0x1_0000_0000;
const B_BASE: u64 = 0x2_0000_0000;
const C_BASE: u64 = 0x3_0000_0000;

/// `main_kernel(A, B, C)`; with no .cu sources, the 128 threads come from
/// `.maxntid` and the 4096 row stride from PTX address math. The grid is
/// inert: no PTX reads `%nctaid` and only CTA (0,0) runs.
fn config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((128, 1, 1));
    config.grid_dim = (128, 128, 1);
    config.arrays = vec![
        f16_input("A", A_BASE, N * N),
        f16_input("B", B_BASE, N * N),
        ArrayDef {
            name: "C".to_string(),
            base: C_BASE,
            elem_width: 2,
            len: N * N,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("A".to_string()),
        ParamValue::ArrayPtr("B".to_string()),
        ParamValue::ArrayPtr("C".to_string()),
    ];
    // Dynamic shared size is set by TileLang's absent launcher (kernels need
    // 4-8 KiB); 160 KiB is a generous ceiling under sm_80's 163 KiB opt-in
    // max, and slack only costs bounds-check precision.
    config.dynamic_shared_bytes = 160 * 1024;
    config
}

pub fn benchmarks() -> Vec<BenchmarkDef> {
    ["32x32x32", "64x32x32", "64x64x32"]
        .into_iter()
        .map(|size| {
            BenchmarkDef::equivalence(
                format!("(TL-{size}-ref, TL-{size}-opt)"),
                BenchmarkCategory::CompilerGenerated,
                KernelRun::new(
                    &format!("07_tilelang/{size}-ref.ptx"),
                    "main_kernel",
                    config(),
                ),
                KernelRun::new(
                    &format!("07_tilelang/{size}-opt.ptx"),
                    "main_kernel",
                    config(),
                ),
            )
        })
        .collect()
}
