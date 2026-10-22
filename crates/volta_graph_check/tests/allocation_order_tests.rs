//! Check 8, allocation order (the PTX ISA's `tcgen05.alloc` rule), in isolation over an
//! assumed-validated `G_HB`, and through the suite.

mod common;

use common::*;
use volta_graph::EventGraph;
use volta_graph_check::allocation_order::{
    AllocationOrderEvidence, AllocationOrderResult, AllocationOrderViolation,
    check_allocation_order,
};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::{GraphConclusion, Property, PropertyResult, Verdict, check_graph};

fn check(graph: &EventGraph) -> AllocationOrderResult {
    check_allocation_order(&ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph"))
}

#[test]
fn a_single_allocation_passes() {
    let mut s = Scenario::new(1);
    s.b.tmem_alloc(t(0), PC, 0, 64);
    assert_eq!(
        check(&s.completed(1).0),
        PropertyResult::Pass(AllocationOrderEvidence { allocations: 1 })
    );
}

/// 64, then 32, then 32 again, each ordered after the last by a barrier: the column count
/// never increases, and equal sizes are allowed.
#[test]
fn ordered_non_increasing_allocations_pass() {
    let mut s = Scenario::new(2);
    s.b.tmem_alloc(t(0), PC, 0, 64);
    s.barrier(&[0, 1], &[]);
    s.b.tmem_alloc(t(1), PC, 64, 32);
    s.barrier(&[0, 1], &[]);
    s.b.tmem_alloc(t(0), PC, 96, 32);
    assert_eq!(
        check(&s.completed(2).0),
        PropertyResult::Pass(AllocationOrderEvidence { allocations: 3 })
    );
}

#[test]
fn program_order_orders_one_threads_allocations() {
    let mut s = Scenario::new(1);
    s.b.tmem_alloc(t(0), PC, 0, 64);
    s.b.tmem_alloc(t(0), PC, 64, 32);
    assert_eq!(check(&s.completed(1).0).verdict(), Verdict::Pass);
}

/// The shape of `tcgen05_alloc_sizes_unordered`: another schedule runs the 32-column
/// allocation first, and the column count grows.
#[test]
fn unordered_allocations_of_different_sizes_fail() {
    let mut s = Scenario::new(2);
    let earlier = s.b.tmem_alloc(t(0), PC, 0, 64);
    let later = s.b.tmem_alloc(t(1), PC, 64, 32);
    assert_eq!(
        check(&s.completed(2).0).violations(),
        [AllocationOrderViolation::Unordered { earlier, later }]
    );
}

/// Equal sizes satisfy the ISA in either order, but the check requires a total order.
#[test]
fn unordered_allocations_of_equal_size_fail() {
    let mut s = Scenario::new(2);
    let earlier = s.b.tmem_alloc(t(0), PC, 0, 32);
    let later = s.b.tmem_alloc(t(1), PC, 32, 32);
    assert_eq!(
        check(&s.completed(2).0).violations(),
        [AllocationOrderViolation::Unordered { earlier, later }]
    );
}

#[test]
fn an_ordered_increase_fails() {
    let mut s = Scenario::new(2);
    let earlier = s.b.tmem_alloc(t(0), PC, 0, 32);
    s.barrier(&[0, 1], &[]);
    let later = s.b.tmem_alloc(t(1), PC, 32, 64);
    assert_eq!(
        check(&s.completed(2).0).violations(),
        [AllocationOrderViolation::IncreasingColumnCount {
            earlier,
            earlier_cols: 32,
            later,
            later_cols: 64,
        }]
    );
}

/// t1's allocation falls between t0's two, ordered with neither: both consecutive pairs are
/// unordered, although program order orders t0's.
#[test]
fn every_unordered_consecutive_pair_is_reported() {
    let mut s = Scenario::new(2);
    let a = s.b.tmem_alloc(t(0), PC, 0, 64);
    let b = s.b.tmem_alloc(t(1), PC, 64, 64);
    let c = s.b.tmem_alloc(t(0), PC, 128, 32);
    assert_eq!(
        check(&s.completed(2).0).violations(),
        [
            AllocationOrderViolation::Unordered {
                earlier: a,
                later: b
            },
            AllocationOrderViolation::Unordered {
                earlier: b,
                later: c
            },
        ]
    );
}

#[test]
fn the_suite_rejects_unordered_allocations() {
    let mut s = Scenario::new(2);
    s.b.tmem_alloc(t(0), PC, 0, 64);
    s.b.tmem_alloc(t(1), PC, 64, 32);
    s.b.tmem_dealloc(t(0), PC, 0, 64);
    s.b.tmem_dealloc(t(1), PC, 64, 32);
    let report = check_graph(&s.completed(2).0);
    assert_eq!(report.verdict(Property::AllocationOrder), Verdict::Fail);
    let GraphConclusion::Rejected { failed, .. } = report.conclusion() else {
        panic!("expected a rejection, got {:?}", report.conclusion());
    };
    let failed: Vec<Property> = failed.iter().map(|f| f.property).collect();
    assert_eq!(failed, [Property::AllocationOrder]);
}
