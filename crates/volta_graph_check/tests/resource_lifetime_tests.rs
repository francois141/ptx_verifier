//! Check 7, resource lifetime (Algorithm 7), in isolation over an assumed-validated `G_HB`.

mod common;

use common::*;
use volta_graph::{EventGraph, EventId, Parity};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::resource_lifetime::{
    LifetimeResult, LifetimeViolation, check_resource_lifetimes,
};
use volta_graph_check::{PropertyResult, Verdict};

fn check(graph: &EventGraph) -> LifetimeResult {
    check_resource_lifetimes(&ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph"))
}

/// t0 allocates columns `[0, 8)`, both threads synchronize, and t0 issues an MMA on them,
/// committed to a phase t0 waits on when `observe`; `deallocator` then frees the columns.
fn mma_then_dealloc(observe: bool, deallocator: u32) -> (EventGraph, EventId, EventId, EventId) {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let alloc = s.b.tmem_alloc(t(0), PC, 0, 8);
    s.barrier(&[0, 1], &[]);
    let (op, effect) = s.mma(0, (0, 8));
    if observe {
        let p0 = s.phase(m, 0);
        s.commit(0, p0, &[op]);
        s.complete(p0);
        s.wait(0, m, Parity::Even, p0);
    }
    let dealloc = s.b.tmem_dealloc(t(deallocator), PC, 0, 8);
    (s.completed(2).0, alloc, effect, dealloc)
}

#[test]
fn a_dealloc_after_the_observed_completion_passes() {
    let (g, ..) = mma_then_dealloc(true, 0);
    assert_eq!(
        check(&g),
        PropertyResult::Pass(volta_graph_check::resource_lifetime::LifetimeEvidence {
            allocations: 1,
            uses: 1,
        })
    );
}

#[test]
fn phase_1_reports_a_dealloc_with_the_use_in_flight() {
    let (g, alloc, effect, dealloc) = mma_then_dealloc(false, 0);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::UseNotBeforeDeallocation {
            effect,
            alloc,
            dealloc
        }]
    );
}

#[test]
fn phase_1_reports_a_dealloc_unordered_after_the_observer() {
    let (g, alloc, effect, dealloc) = mma_then_dealloc(true, 1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::UseNotBeforeDeallocation {
            effect,
            alloc,
            dealloc
        }]
    );
}

#[test]
fn phase_2_reports_a_use_unordered_after_its_allocation() {
    let mut s = Scenario::new(2);
    let alloc = s.b.tmem_alloc(t(0), PC, 0, 8);
    let (_, effect) = s.mma(1, (0, 8));
    s.b.tmem_dealloc(t(1), PC, 0, 8);
    let (g, _) = s.aborted();
    let result = check(&g);
    assert!(
        result
            .violations()
            .contains(&LifetimeViolation::AllocationNotBeforeUse { effect, alloc }),
        "{result:?}"
    );
}

#[test]
fn a_use_of_unallocated_columns_is_uncovered() {
    let mut s = Scenario::new(1);
    let (_, effect) = s.mma(0, (0, 8));
    let (g, _) = s.completed(1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::Uncovered {
            effect,
            alloc: None
        }]
    );
}

#[test]
fn the_allocation_must_cover_the_entire_footprint() {
    let mut s = Scenario::new(1);
    let alloc = s.b.tmem_alloc(t(0), PC, 0, 4);
    let (_, effect) = s.mma(0, (0, 8));
    s.b.tmem_dealloc(t(0), PC, 0, 4);
    let (g, _) = s.completed(1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::Uncovered {
            effect,
            alloc: Some(alloc)
        }]
    );
}

#[test]
fn a_double_free_is_reported() {
    let mut s = Scenario::new(1);
    let alloc = s.b.tmem_alloc(t(0), PC, 0, 8);
    let first = s.b.tmem_dealloc(t(0), PC, 0, 8);
    let second = s.b.tmem_dealloc(t(0), PC, 0, 8);
    let (g, _) = s.completed(1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::DoubleFree {
            alloc,
            deallocs: vec![first, second]
        }]
    );
}

#[test]
fn a_deallocation_without_an_allocation_is_reported() {
    let mut s = Scenario::new(1);
    let dealloc = s.b.tmem_dealloc(t(0), PC, 0, 8);
    let (g, _) = s.completed(1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::UnmatchedDeallocation { dealloc }]
    );
}

#[test]
fn a_missing_deallocation_fails_a_completed_trace_only() {
    let build = || {
        let mut s = Scenario::new(1);
        let alloc = s.b.tmem_alloc(t(0), PC, 0, 8);
        (s, alloc)
    };
    let (s, alloc) = build();
    let (completed, _) = s.completed(1);
    assert_eq!(
        check(&completed).violations(),
        [LifetimeViolation::NeverDeallocated { alloc }]
    );
    let (s, alloc) = build();
    let (aborted, _) = s.aborted();
    let result = check(&aborted);
    assert_eq!(result.verdict(), Verdict::Unknown, "{result:?}");
    assert_eq!(result.unresolved()[0].events, [alloc]);
}

#[test]
fn a_reallocation_is_a_fresh_resource() {
    let mut s = Scenario::new(1);
    let first = s.b.tmem_alloc(t(0), PC, 0, 8);
    s.mma(0, (0, 8));
    s.b.tmem_dealloc(t(0), PC, 0, 8);
    let second = s.b.tmem_alloc(t(0), PC, 0, 8);
    let (_, late) = s.mma(0, (0, 8));
    s.b.tmem_dealloc(t(0), PC, 0, 8);
    let (g, _) = s.completed(1);
    let result = check(&g);
    let reported: Vec<(EventId, EventId)> = result
        .violations()
        .iter()
        .map(|v| match v {
            LifetimeViolation::UseNotBeforeDeallocation { effect, alloc, .. } => (*effect, *alloc),
            other => panic!("{other:?}"),
        })
        .collect();
    assert_eq!(
        reported.len(),
        2,
        "neither MMA is observed before its dealloc"
    );
    assert_eq!(reported[1], (late, second));
    assert_ne!(reported[0].1, second);
    assert_eq!(reported[0].1, first);
}

#[test]
fn without_tensor_memory_the_check_is_vacuous() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.read(1, 0x10);
    let (g, _) = s.completed(2);
    assert_eq!(
        check(&g),
        PropertyResult::Pass(volta_graph_check::resource_lifetime::LifetimeEvidence {
            allocations: 0,
            uses: 0,
        })
    );
}
