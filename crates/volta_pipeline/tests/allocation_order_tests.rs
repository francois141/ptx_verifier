//! Kernels whose Tensor Memory allocations are not totally ordered, or whose column count grows
//! along that order: the allocation-order check (the PTX ISA's `tcgen05.alloc` rule) must fail.

#[macro_use]
mod common;

use volta_graph_check::allocation_order::AllocationOrderViolation;
use volta_ptx_analysis::AnalysisConfig;

use common::*;

/// Warp 0's 64-column and warp 1's 32-column allocations are unordered: the schedule that runs
/// warp 1's first grows the column count.
#[test]
fn test_tcgen05_alloc_sizes_unordered() {
    let checked = check(
        &parse(&ptx!("execution_error/tcgen05_alloc_sizes_unordered")),
        None,
        AnalysisConfig::new((64, 1, 1)),
    );
    let graph = &checked.analysis.graph;
    let thread = |e| {
        graph
            .acting_thread(e)
            .expect("an allocation acts for a thread")
            .0
    };
    let pairs: Vec<(u32, u32)> = checked
        .report
        .allocation_order
        .violations()
        .iter()
        .map(|v| match *v {
            AllocationOrderViolation::Unordered { earlier, later } => {
                (thread(earlier), thread(later))
            }
            ref other => panic!("expected unordered allocations, got {other:?}"),
        })
        .collect();
    assert_eq!(pairs, [(0, 32)], "warp 0's allocation, then warp 1's");
}
