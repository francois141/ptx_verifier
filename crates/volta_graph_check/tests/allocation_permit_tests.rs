//! Check 9, allocation permit (the PTX ISA's `tcgen05.relinquish_alloc_permit` rule), in
//! isolation over an assumed-validated `G_HB`, and through the suite.

mod common;

use common::*;
use volta_graph::EventGraph;
use volta_graph_check::allocation_permit::{
    AllocationPermitEvidence, AllocationPermitResult, AllocationPermitViolation,
    check_allocation_permit,
};
use volta_graph_check::relation::ValidatedGraph;
use volta_graph_check::{GraphConclusion, Property, PropertyResult, Verdict, check_graph};

fn check(graph: &EventGraph) -> AllocationPermitResult {
    check_allocation_permit(&ValidatedGraph::assuming_epochs(graph).expect("a well-formed graph"))
}

#[test]
fn allocations_without_a_relinquish_pass() {
    let mut s = Scenario::new(2);
    s.b.tmem_alloc(t(0), PC, 0, 32);
    s.b.tmem_alloc(t(1), PC, 32, 32);
    assert_eq!(
        check(&s.completed(2).0),
        PropertyResult::Pass(AllocationPermitEvidence {
            allocations: 2,
            relinquishes: 0
        })
    );
}

#[test]
fn program_order_orders_an_allocation_before_its_threads_relinquish() {
    let mut s = Scenario::new(1);
    s.b.tmem_alloc(t(0), PC, 0, 32);
    s.b.tmem_relinquish(t(0), PC);
    assert_eq!(
        check(&s.completed(1).0),
        PropertyResult::Pass(AllocationPermitEvidence {
            allocations: 1,
            relinquishes: 1
        })
    );
}

#[test]
fn a_barrier_orders_an_allocation_before_another_threads_relinquish() {
    let mut s = Scenario::new(2);
    s.b.tmem_alloc(t(0), PC, 0, 32);
    s.barrier(&[0, 1], &[]);
    s.b.tmem_relinquish(t(1), PC);
    assert_eq!(check(&s.completed(2).0).verdict(), Verdict::Pass);
}

/// The shape of `tcgen05_relinquish_unordered_with_other_warps_alloc`: another schedule runs
/// t1's relinquish first, and t0 then allocates without the permit.
#[test]
fn an_allocation_unordered_with_a_relinquish_fails() {
    let mut s = Scenario::new(2);
    let allocation = s.b.tmem_alloc(t(0), PC, 0, 32);
    let relinquish = s.b.tmem_relinquish(t(1), PC);
    assert_eq!(
        check(&s.completed(2).0).violations(),
        [AllocationPermitViolation {
            allocation,
            relinquish
        }]
    );
}

#[test]
fn an_allocation_after_a_relinquish_in_the_trace_fails() {
    let mut s = Scenario::new(1);
    let relinquish = s.b.tmem_relinquish(t(0), PC);
    let allocation = s.b.tmem_alloc(t(0), PC, 0, 32);
    assert_eq!(
        check(&s.completed(1).0).violations(),
        [AllocationPermitViolation {
            allocation,
            relinquish
        }]
    );
}

/// t0's allocation reaches t0's own relinquish but not t1's: only the unordered pair fails.
#[test]
fn every_relinquish_must_follow_every_allocation() {
    let mut s = Scenario::new(2);
    let allocation = s.b.tmem_alloc(t(0), PC, 0, 32);
    s.b.tmem_relinquish(t(0), PC);
    let relinquish = s.b.tmem_relinquish(t(1), PC);
    assert_eq!(
        check(&s.completed(2).0).violations(),
        [AllocationPermitViolation {
            allocation,
            relinquish
        }]
    );
}

#[test]
fn the_suite_rejects_an_allocation_unordered_with_a_relinquish() {
    let mut s = Scenario::new(2);
    s.b.tmem_alloc(t(0), PC, 0, 32);
    s.b.tmem_relinquish(t(1), PC);
    s.b.tmem_dealloc(t(0), PC, 0, 32);
    let report = check_graph(&s.completed(2).0);
    assert_eq!(report.verdict(Property::AllocationPermit), Verdict::Fail);
    let GraphConclusion::Rejected { failed, .. } = report.conclusion() else {
        panic!("expected a rejection, got {:?}", report.conclusion());
    };
    let failed: Vec<Property> = failed.iter().map(|f| f.property).collect();
    assert_eq!(failed, [Property::AllocationPermit]);
}
