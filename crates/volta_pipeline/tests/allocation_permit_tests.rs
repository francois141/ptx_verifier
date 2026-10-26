//! Kernels with a Tensor Memory allocation not ordered before a `relinquish_alloc_permit`: the
//! allocation-permit check (the PTX ISA's `tcgen05.relinquish_alloc_permit` rule) must fail.

#[macro_use]
mod common;

use volta_ptx_analysis::AnalysisConfig;

use common::*;

/// Warp 1's `relinquish_alloc_permit` is unordered with warp 0's `tcgen05.alloc`: the schedule
/// that relinquishes first allocates illegally.
#[test]
fn test_tcgen05_relinquish_unordered_with_other_warps_alloc() {
    let checked = check(
        &parse(&ptx!(
            "execution_error/tcgen05_relinquish_unordered_with_other_warps_alloc"
        )),
        None,
        AnalysisConfig::new((64, 1, 1)),
    );
    let graph = &checked.analysis.graph;
    let thread = |e| {
        graph
            .acting_thread(e)
            .expect("an allocation and a relinquish act for a thread")
            .0
    };
    let pairs: Vec<(u32, u32)> = checked
        .report
        .allocation_permit
        .violations()
        .iter()
        .map(|v| (thread(v.allocation), thread(v.relinquish)))
        .collect();
    assert_eq!(pairs, [(0, 32)], "warp 0's allocation, warp 1's relinquish");
}
