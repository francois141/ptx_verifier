//! LLM-optimized 2D convolution (Section 6.2): AlexNet conv1 as an implicit
//! GEMM (M = 96, N = 100*55*55, K = 3*11*11). Both kernels use 256 threads
//! and compute the same 128x128 tile per CTA.

use volta_analysis::eval::{AnalysisConfig, ParamValue};

use crate::config::{BenchmarkCategory, BenchmarkDef, KernelRun, f32_input, f32_output};

// The macro block shared by Conv2D-ref.cu and Conv2D-opt.cu (AlexNet
// conv1: stride 4, pad 2, so H_OUT = W_OUT = (224 + 2*2 - 11)/4 + 1 = 55).
const N_BATCH: u64 = 100;
const C_IN: u64 = 3;
const H_IN: u64 = 224;
const W_IN: u64 = 224;
const C_OUT: u64 = 96;
const K_H: u64 = 11;
const K_W: u64 = 11;
const H_OUT: u64 = 55;
const W_OUT: u64 = 55;

const IN_BASE: u64 = 0x1_0000_0000;
const W_BASE: u64 = 0x2_0000_0000;
const BIAS_BASE: u64 = 0x2_8000_0000;
const OUT_BASE: u64 = 0x3_0000_0000;

/// `conv2d(input, weight, bias, output)` with the .cu files' 256 threads and
/// grid (the grid is inert: no PTX reads `%nctaid`). Extents are the .cu
/// tensor shapes; no dynamic shared memory.
fn config() -> AnalysisConfig {
    let n_gemm = N_BATCH * H_OUT * W_OUT;
    let mut config = AnalysisConfig::new((256, 1, 1));
    config.grid_dim = (n_gemm.div_ceil(128) as u32, 1, 1);
    config.arrays = vec![
        f32_input("input", IN_BASE, N_BATCH * C_IN * H_IN * W_IN),
        f32_input("weight", W_BASE, C_OUT * C_IN * K_H * K_W),
        f32_input("bias", BIAS_BASE, C_OUT),
        f32_output("output", OUT_BASE, C_OUT * n_gemm),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("input".to_string()),
        ParamValue::ArrayPtr("weight".to_string()),
        ParamValue::ArrayPtr("bias".to_string()),
        ParamValue::ArrayPtr("output".to_string()),
    ];
    config
}

pub fn benchmarks() -> Vec<BenchmarkDef> {
    let reference = KernelRun::new(
        "05_conv2d_llm/Conv2D-ref.ptx",
        "_Z11dumb_conv2dPKfS0_S0_Pf",
        config(),
    );
    let optimized = KernelRun::new(
        "05_conv2d_llm/Conv2D-opt.ptx",
        "_Z6conv2dPKfS0_S0_Pf",
        config(),
    );
    vec![BenchmarkDef::equivalence(
        "(Conv2D-ref, Conv2D-opt)",
        BenchmarkCategory::Convolution,
        reference,
        optimized,
    )]
}
