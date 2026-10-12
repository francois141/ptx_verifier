//! Attention kernels (Table 3): the single-thread reference vs FlashAttention
//! FA1 and tensor-core variants (FA1-TC, FA2-TC). Dims match the paper:
//! Q:(16,64), K:(512,64), V:(512,64), one CTA per head.

use volta_analysis::eval::{AnalysisConfig, ParamValue};

use crate::config::{BenchmarkCategory, BenchmarkDef, KernelRun, f32_input, f32_output};

// The `LQ`/`LK`/`HEAD_DIM`(= `VALUE_DIM`) macros shared by all the .cu
// sources in 03_attention/ and 04_causal_attention/, and the paper's
// "Q:(16,64), K:(512,64), V:(512,64)".
const LQ: u64 = 16;
const LK: u64 = 512;
const DIM: u64 = 64;

const Q_BASE: u64 = 0x1_0000_0000;
const K_BASE: u64 = 0x2_0000_0000;
const V_BASE: u64 = 0x3_0000_0000;
const O_BASE: u64 = 0x4_0000_0000;
const AUX0_BASE: u64 = 0x5_0000_0000;
const AUX1_BASE: u64 = 0x6_0000_0000;

/// scale = 1/sqrt(HEAD_DIM) = 1/sqrt(64), exactly representable; kernels
/// are specialized for it, and a concrete value keeps the exponents simple
/// for the decision procedure.
const SCALE: f64 = 0.125;

/// `sdpa(Q, K, V, O, scale, [l, m])`, FA1 adding `[LQ]` softmax-stat outputs;
/// shared with the causal variants (Table 4). Shared memory is all static and
/// grid is (1,1,1): no PTX reads `%nctaid` and all work stays in CTA 0.
pub(super) fn config(threads: u32, aux_outputs: bool) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        f32_input("Q", Q_BASE, LQ * DIM),
        f32_input("K", K_BASE, LK * DIM),
        f32_input("V", V_BASE, LK * DIM),
        f32_output("O", O_BASE, LQ * DIM),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("Q".to_string()),
        ParamValue::ArrayPtr("K".to_string()),
        ParamValue::ArrayPtr("V".to_string()),
        ParamValue::ArrayPtr("O".to_string()),
        ParamValue::Float(SCALE),
    ];
    if aux_outputs {
        config.arrays.push(f32_output("fa_l", AUX0_BASE, LQ));
        config.arrays.push(f32_output("fa_m", AUX1_BASE, LQ));
        config.params.push(ParamValue::ArrayPtr("fa_l".to_string()));
        config.params.push(ParamValue::ArrayPtr("fa_m".to_string()));
    }
    config
}

fn attention() -> KernelRun {
    // The reference computes the whole head with a single thread:
    // Attention.cu guards `threadIdx.x != 0 || blockIdx.x != 0` (paper
    // Table 3 lists #Threads = 1).
    KernelRun::new(
        "03_attention/Attention.ptx",
        "_Z10sdpa_basicPKfS0_S0_Pff",
        config(1, false),
    )
}

pub fn benchmarks() -> Vec<BenchmarkDef> {
    // The optimized kernels all use 128 threads = the BLOCKSIZE macro in
    // their .cu (paper Table 3). The `S1_S1_` suffix on the FA1 mangled
    // name is the two extra `float*` aux outputs.
    let fa1 = KernelRun::new(
        "03_attention/FA1.ptx",
        "_Z12sdpa_fa_likePKfS0_S0_PffS1_S1_",
        config(128, true),
    );
    let fa1_tc = KernelRun::new(
        "03_attention/FA1-TC.ptx",
        "_Z12sdpa_fa_likePKfS0_S0_PffS1_S1_",
        config(128, true),
    );
    let fa2_tc = KernelRun::new(
        "03_attention/FA2-TC.ptx",
        "_Z11sdpa_fa2_tcPKfS0_S0_Pff",
        config(128, false),
    );

    vec![
        BenchmarkDef::equivalence(
            "(Attention, Attention)",
            BenchmarkCategory::Attention,
            attention(),
            attention(),
        ),
        BenchmarkDef::equivalence(
            "(Attention, FA1)",
            BenchmarkCategory::Attention,
            attention(),
            fa1,
        ),
        BenchmarkDef::equivalence(
            "(Attention, FA1-TC)",
            BenchmarkCategory::Attention,
            attention(),
            fa1_tc,
        ),
        BenchmarkDef::equivalence(
            "(Attention, FA2-TC)",
            BenchmarkCategory::Attention,
            attention(),
            fa2_tc,
        ),
    ]
}
