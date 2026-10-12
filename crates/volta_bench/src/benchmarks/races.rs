//! FaialAA data-race benchmarks (Table 7): pre-fix (racy) and post-fix OpenMM
//! and Megatron-LM kernels. Scalar dims are baked into the PTX (line counts
//! match Table 7); array extents only bound-check. OpenMM runs one CTA.

use volta_analysis::eval::{AnalysisConfig, ParamValue};

use crate::config::{
    BenchmarkCategory, BenchmarkDef, KernelRun, f32_inout, f32_input, f32_output, u32_index,
    u32_inout, u32_input, u32_output,
};

fn pair(name: &str, file_base: &str, kernel: &str, config: AnalysisConfig) -> [BenchmarkDef; 2] {
    pair_with(name, file_base, kernel, config.clone(), config)
}

fn pair_with(
    name: &str,
    file_base: &str,
    kernel: &str,
    pre_config: AnalysisConfig,
    post_config: AnalysisConfig,
) -> [BenchmarkDef; 2] {
    let pre = KernelRun::new(
        &format!("08_races/{}-pre_racy.ptx", file_base),
        kernel,
        pre_config,
    );
    let post = KernelRun::new(
        &format!("08_races/{}-post_fixed.ptx", file_base),
        kernel,
        post_config,
    );
    [
        BenchmarkDef::race_check(
            format!("{} (pre-fix)", name),
            BenchmarkCategory::DataRace,
            pre,
            true,
        ),
        BenchmarkDef::race_check(
            format!("{} (post-fix)", name),
            BenchmarkCategory::DataRace,
            post,
            false,
        ),
    ]
}

/// `computeBucketPositions` exclusive scan; pre-fix misses a barrier. The race
/// is cross-pass, so blockDim.x = 64 < the baked `numBuckets = 1024` (16
/// passes); GPUVerify's `--blockDim=1024` would run one pass and mask it.
fn bucket_positions() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![u32_inout("bucketOffset", 0x1_0000_0000, 1 << 20)];
    config.params = vec![ParamValue::ArrayPtr("bucketOffset".to_string())];
    config.dynamic_shared_bytes = 64 * 1024;
    config
}

/// `computeRange` min/max reduction; the pre-fix missing barrier races at any
/// blockDim >= 2 (64 keeps it cheap). `data` is never loaded; unset
/// `MIN_KEY`/`SORT_KEY` feed only data values, which a race check tolerates.
fn compute_range() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![
        u32_input("data", 0x1_0000_0000, 1 << 20),
        u32_output("range", 0x2_0000_0000, 1 << 20),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("data".to_string()),
        ParamValue::ArrayPtr("range".to_string()),
    ];
    config.global_values = vec![("MAX_KEY".to_string(), 32)];
    config.dynamic_shared_bytes = 64 * 1024;
    config
}

/// `computeRMSDPart1` with `numParticles = 1024` baked; `particles` is a
/// concrete identity index array (the paper's `M[x]` pattern). The pre-fix
/// `temp[thread]` vs `temp[0]` race fires at any blockDim >= 2; 64 is cheap.
fn reduce_value() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![
        f32_input("posq", 0x1_0000_0000, 1 << 20),
        f32_input("refpos", 0x2_0000_0000, 1 << 20),
        u32_index("particles", 0x3_0000_0000, 1 << 20),
        f32_inout("buffer", 0x4_0000_0000, 1 << 20),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("posq".to_string()),
        ParamValue::ArrayPtr("refpos".to_string()),
        ParamValue::ArrayPtr("particles".to_string()),
        ParamValue::ArrayPtr("buffer".to_string()),
    ];
    config.dynamic_shared_bytes = 64 * 1024;
    config
}

/// `cuApplyLayerNorm` (flat-test fork: N1 = N2 = 1 baked; most params unread).
/// Exactly one warp: full-mask shfl needs 32 lanes and y > 1 hits a `trap`;
/// pre-fix races on `smu`/`sinv` broadcast with no barrier. No dyn. shared.
fn layer_norm() -> AnalysisConfig {
    const N1: i64 = 2;
    const N2: i64 = 1024;
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.grid_dim = (1, 2, 1);
    config.arrays = vec![
        f32_output("out", 0x1_0000_0000, (N1 * N2) as u64),
        f32_output("mean", 0x2_0000_0000, N1 as u64),
        f32_output("invvar", 0x3_0000_0000, N1 as u64),
        f32_input("vals", 0x4_0000_0000, (N1 * N2) as u64),
        f32_input("gamma", 0x5_0000_0000, N2 as u64),
        f32_input("beta", 0x6_0000_0000, N2 as u64),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("out".to_string()),
        ParamValue::ArrayPtr("mean".to_string()),
        ParamValue::ArrayPtr("invvar".to_string()),
        ParamValue::ArrayPtr("vals".to_string()),
        ParamValue::Int(N1),
        ParamValue::Int(N2),
        ParamValue::Float(1e-5),
        ParamValue::ArrayPtr("gamma".to_string()),
        ParamValue::ArrayPtr("beta".to_string()),
        ParamValue::Int(1),
        ParamValue::Int(1),
    ];
    config
}

/// `cuComputeGradInput` (n1 = n2 = 8 baked). Huge grid.y makes CTA (0,0) do
/// row 0 only. `block_y` is the point: `buf[2*threadIdx.x]` ignores y, so
/// pre-fix at y = 4 collides (the race); the fix is y-safe only at y = 1.
fn grad_input(block_y: u32) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((32, block_y, 1));
    config.grid_dim = (1, 1 << 20, 1);
    config.arrays = vec![
        f32_input("dout", 0x1_0000_0000, 1 << 22),
        f32_input("input", 0x2_0000_0000, 1 << 22),
        f32_input("mean", 0x3_0000_0000, 1 << 20),
        f32_input("invvar", 0x4_0000_0000, 1 << 20),
        f32_input("gamma", 0x5_0000_0000, 1 << 12),
        f32_output("grad_input", 0x6_0000_0000, 1 << 22),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("dout".to_string()),
        ParamValue::ArrayPtr("input".to_string()),
        ParamValue::ArrayPtr("mean".to_string()),
        ParamValue::ArrayPtr("invvar".to_string()),
        ParamValue::Float(1e-5),
        ParamValue::ArrayPtr("gamma".to_string()),
        ParamValue::ArrayPtr("grad_input".to_string()),
    ];
    config.dynamic_shared_bytes = 64 * 1024;
    config
}

pub fn benchmarks() -> Vec<BenchmarkDef> {
    let mut benches = Vec::new();
    benches.extend(pair(
        "BucketPositions",
        "BucketPositions",
        "_Z22computeBucketPositionsPj",
        bucket_positions(),
    ));
    benches.extend(pair(
        "ComputeRange",
        "ComputeRange",
        "_Z12computeRangePKiPi",
        compute_range(),
    ));
    benches.extend(pair(
        "ReduceValue",
        "ReduceValue",
        "computeRMSDPart1",
        reduce_value(),
    ));
    benches.extend(pair(
        "LayerNorm",
        "LayerNorm",
        "_Z16cuApplyLayerNormIfffEvPT1_PT0_S3_PKT_iiS2_PKS0_S8_ii",
        layer_norm(),
    ));
    benches.extend(pair_with(
        "GradInput",
        "GradInput",
        "_Z18cuComputeGradInputIfffEvPKT1_PKT_PKT0_S8_S6_S2_PS3_",
        grad_input(4),
        grad_input(1),
    ));
    benches
}
