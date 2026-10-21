//! Kernels that free Tensor Memory while a use of it is not ordered before the deallocation
//! (phase 1 reports those uses), or that never free it: the resource-lifetime check
//! (Algorithm 6) must fail.

#[macro_use]
mod common;

use volta_analysis::eval::AnalysisConfig;
use volta_frontend::ast::Module;
use volta_graph::{AccessMode, AsyncOpKind, EventKind};
use volta_graph_check::resource_lifetime::LifetimeViolation;

use common::*;

/// The uses phase 1 reports as not ordered before their deallocation.
fn freed_while_in_use(module: &Module, config: AnalysisConfig) -> Vec<Side> {
    let checked = check(module, None, config);
    let effects: Vec<Side> = checked
        .report
        .resource_lifetime
        .violations()
        .iter()
        .filter_map(|v| match *v {
            LifetimeViolation::UseNotBeforeDeallocation { effect, .. } => {
                Some(side(&checked.analysis.graph, effect))
            }
            _ => None,
        })
        .collect();
    assert!(
        !effects.is_empty(),
        "expected a use not ordered before its deallocation, got: {:?}",
        checked.report.resource_lifetime
    );
    effects
}

/// The allocations the completed trace never frees, as `(thread, columns)`.
fn never_freed(module: &Module, config: AnalysisConfig) -> Vec<(u32, u16)> {
    let checked = check(module, None, config);
    let graph = &checked.analysis.graph;
    let allocs: Vec<(u32, u16)> = checked
        .report
        .resource_lifetime
        .violations()
        .iter()
        .filter_map(|v| match *v {
            LifetimeViolation::NeverDeallocated { alloc } => {
                let EventKind::TmemAlloc { num_cols, .. } = graph.event(alloc).kind else {
                    panic!("event {} is not an allocation", alloc.0);
                };
                let thread = graph
                    .acting_thread(alloc)
                    .expect("an allocation acts for a thread");
                Some((thread.0, num_cols))
            }
            _ => None,
        })
        .collect();
    assert!(
        !allocs.is_empty(),
        "expected an allocation never freed, got: {:?}",
        checked.report.resource_lifetime
    );
    allocs
}

use AccessMode::{Read, Write};

/// `tcgen05.dealloc` with an un-waited `tcgen05.ld`/`.st` still outstanding on the range:
/// the use is not ordered before the deallocation.
#[test]
fn test_tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected() {
    for (expected, (name, src)) in [
        (
            Side::effect(0, Read, AsyncOpKind::Tcgen05Ld),
            ptx_case!("execution_error/tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected_ld"),
        ),
        (
            Side::effect(0, Write, AsyncOpKind::Tcgen05St),
            ptx_case!("execution_error/tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected_st"),
        ),
    ] {
        let effects = freed_while_in_use(&parse(&src), AnalysisConfig::new((32, 1, 1)));
        assert!(
            effects
                .iter()
                .any(|e| e.op == expected.op && e.mode == expected.mode),
            "{name}: expected a freed {expected:?}, got: {effects:?}"
        );
    }
}

/// `tcgen05.dealloc` of `D`'s columns while the MMA writing them is still in flight -
/// committed, but no thread has observed `mma_bar` - is rejected.
#[test]
fn test_tcgen05_dealloc_with_an_mma_in_flight_is_rejected() {
    let effects = freed_while_in_use(
        &parse(&ptx!(
            "execution_error/tcgen05_dealloc_with_an_mma_in_flight_is_rejected"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert!(
        effects.contains(&Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)),
        "expected the MMA's write of D freed, got: {effects:?}"
    );
}

/// A `tcgen05.wait::ld` after a `bar.sync` is no hazard by itself: the kernel's only Tensor
/// Memory operation conflicts with nothing, so tensor ordering passes. The kernel is rejected
/// because it never frees its 32 columns.
#[test]
fn test_tcgen05_wait_ld_after_bar_sync_is_rejected() {
    let allocs = never_freed(
        &parse(&ptx!(
            "execution_error/tcgen05_wait_ld_after_bar_sync_is_rejected"
        )),
        AnalysisConfig::new((32, 1, 1)),
    );
    assert_eq!(
        allocs,
        vec![(0, 32)],
        "expected warp 0's allocation never freed"
    );
}

/// Same for a `tcgen05.wait::st` after an `mbarrier.arrive`.
#[test]
fn test_tcgen05_wait_st_after_mbarrier_arrive_is_rejected() {
    let allocs = never_freed(
        &parse(&ptx!(
            "execution_error/tcgen05_wait_st_after_mbarrier_arrive_is_rejected"
        )),
        AnalysisConfig::new((32, 1, 1)),
    );
    assert_eq!(
        allocs,
        vec![(0, 32)],
        "expected warp 0's allocation never freed"
    );
}
