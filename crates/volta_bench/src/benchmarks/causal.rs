//! Causal attention (Table 4): each Table 3 level with a lower-triangular mask,
//! fused (skips work above the diagonal) vs naive (0/1 mask multiply). The mask
//! difference evaporates symbolically, so VCs are much cheaper than Table 3's.

use crate::benchmarks::attention::config;
use crate::config::{BenchmarkCategory, BenchmarkDef, KernelRun};

pub fn benchmarks() -> Vec<BenchmarkDef> {
    // (paper name, mangled entry, threads, aux l/m output buffers). Same dims
    // and single-thread guard as Table 3, so `attention::config` applies
    // unchanged (paper Table 4 #Threads 1/128/128/128).
    let levels: [(&str, &str, u32, bool); 4] = [
        ("Causal-Attention", "_Z10sdpa_basicPKfS0_S0_Pff", 1, false),
        (
            "Causal-FA1",
            "_Z12sdpa_fa_likePKfS0_S0_PffS1_S1_",
            128,
            true,
        ),
        (
            "Causal-FA1-TC",
            "_Z12sdpa_fa_likePKfS0_S0_PffS1_S1_",
            128,
            true,
        ),
        ("Causal-FA2-TC", "_Z11sdpa_fa2_tcPKfS0_S0_Pff", 128, false),
    ];

    levels
        .iter()
        .map(|&(name, entry, threads, aux)| {
            let variant = |suffix: &str| {
                KernelRun::new(
                    &format!("04_causal_attention/{}-{}.ptx", name, suffix),
                    entry,
                    config(threads, aux),
                )
            };
            BenchmarkDef::equivalence(
                format!("({}-naive, {}-fused)", name, name),
                BenchmarkCategory::CausalAttention,
                variant("naive"),
                variant("fused"),
            )
        })
        .collect()
}
