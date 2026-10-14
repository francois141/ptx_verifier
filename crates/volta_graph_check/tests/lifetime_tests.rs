//! The resource-lifetime checker in isolation.

mod common;

use std::collections::HashSet;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, EventGraph, EventId, Footprint, MemAccess, OperandRole,
    OrderingKind, Parity, Proxy, Space, StoredValue, SyncObjectId, Terminal,
};
use volta_graph_check::async_completion::CompletionCertificate;
use volta_graph_check::barrier::SyncCertificate;
use volta_graph_check::hb::Validated;
use volta_graph_check::lifetime::{LifetimeResult, LifetimeViolation, check_lifetimes};
use volta_graph_check::{PropertyResult, Verdict};

fn check(graph: &EventGraph) -> LifetimeResult {
    check_lifetimes(
        graph,
        &SyncCertificate::assume_all(),
        &CompletionCertificate::assume_all(),
    )
}

/// A `tcgen05.mma` by `issuer` writing accumulator columns `[0, 8)` of every lane: the op and
/// its write effect.
fn mma(s: &mut Scenario, issuer: u32) -> (AsyncOpId, EventId) {
    let op = s.b.async_issue(t(issuer), PC, AsyncOpKind::Tcgen05Mma);
    let value = Some(s.b.value(StoredValue::Opaque));
    let effect = s.b.async_effect(
        op,
        MemAccess {
            space: Space::Tensor,
            mode: AccessMode::Write,
            ordering: OrderingKind::Ordinary,
            proxy: Proxy::Async,
            footprint: Footprint::Tensor {
                lane: 0,
                lanes: 128,
                col: 0,
                cols: 8,
            },
            role: OperandRole::Accumulator,
            attributed: t(issuer),
            value,
        },
    );
    (op, effect)
}

/// t0 allocates columns `[0, 8)` and issues an MMA on them, committed to a phase t0 waits on
/// when `observe`; `deallocator` then frees the columns.
fn mma_then_dealloc(observe: bool, deallocator: u32) -> (EventGraph, EventId, EventId) {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    s.b.tmem_alloc(t(0), PC, 0, 8);
    s.barrier(&[0, 1], &[]);
    let (op, effect) = mma(&mut s, 0);
    if observe {
        let p0 = s.phase(m, 0);
        s.arrive(0, p0);
        s.b.track(op, p0, 0);
        s.complete(p0);
        s.wait(0, m, Parity::Even, p0);
    }
    let dealloc = s.b.tmem_dealloc(t(deallocator), PC, 0, 8);
    (s.completed(2).0, effect, dealloc)
}

#[test]
fn a_dealloc_after_the_observed_completion_passes() {
    let (g, _, _) = mma_then_dealloc(true, 0);
    let result = check(&g);
    assert!(
        matches!(&result, PropertyResult::Pass(e) if e.tmem_allocations == 1 && e.mbarrier_objects == 1),
        "{result:?}"
    );
}

#[test]
fn a_dealloc_with_the_mma_in_flight_fails() {
    let (g, effect, dealloc) = mma_then_dealloc(false, 0);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::FreedWhileInUse { dealloc, effect }]
    );
}

#[test]
fn a_dealloc_not_ordered_after_the_observer_fails() {
    let (g, effect, dealloc) = mma_then_dealloc(true, 1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::FreedWhileInUse { dealloc, effect }]
    );
}

#[test]
fn freeing_only_through_an_unvalidated_phase_is_unknown() {
    let (g, _, _) = mma_then_dealloc(true, 0);
    let result = check_lifetimes(
        &g,
        &SyncCertificate {
            generations: Validated::Only(HashSet::new()),
        },
        &CompletionCertificate::assume_all(),
    );
    let [u] = result.unresolved() else {
        panic!("{result:?}");
    };
    assert!(u.reason.contains("unvalidated"), "{u:?}");
}

#[test]
fn an_effect_not_ordered_after_its_allocation_fails() {
    let mut s = Scenario::new(2);
    let alloc = s.b.tmem_alloc(t(0), PC, 0, 8);
    let (_, effect) = mma(&mut s, 1);
    let (g, _) = s.completed(2);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::UsedBeforeAllocation { alloc, effect }]
    );
}

#[test]
fn an_effect_on_unallocated_columns_fails() {
    let mut s = Scenario::new(1);
    let (_, effect) = mma(&mut s, 0);
    let (g, _) = s.completed(1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::Unallocated { effect }]
    );
}

#[test]
fn a_double_free_fails() {
    let mut s = Scenario::new(1);
    s.b.tmem_alloc(t(0), PC, 0, 8);
    s.b.tmem_dealloc(t(0), PC, 0, 8);
    let dealloc = s.b.tmem_dealloc(t(0), PC, 0, 8);
    let (g, _) = s.completed(1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::FreesUnallocated { dealloc }]
    );
}

#[test]
fn leaks_and_unobserved_ops_of_a_completed_execution_are_unresolved() {
    let build = || {
        let mut s = Scenario::new(1);
        s.b.tmem_alloc(t(0), PC, 0, 8);
        mma(&mut s, 0);
        s.exit_all(1);
        s
    };
    let (g, _) = build().finish(Terminal::Completed);
    let result = check(&g);
    let reasons: Vec<&str> = result
        .unresolved()
        .iter()
        .map(|u| u.reason.as_str())
        .collect();
    assert_eq!(reasons.len(), 2, "{result:?}");
    assert!(reasons[0].contains("still allocated"), "{reasons:?}");
    assert!(
        reasons[1].contains("never observed complete"),
        "{reasons:?}"
    );
    let (aborted, _) = build().finish(Terminal::Aborted {
        thread: None,
        pc: None,
        reason: "test".to_string(),
    });
    assert_eq!(check(&aborted).verdict(), Verdict::Pass);
}

/// t1 arrives on t0's mbarrier, after a barrier ordering it after the init when `synced`.
fn arrival_after_init(synced: bool) -> (EventGraph, SyncObjectId, EventId) {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    if synced {
        s.barrier(&[0, 1], &[]);
    }
    let p0 = s.phase(m, 0);
    let arrive = s.arrive(1, p0);
    s.complete(p0);
    (s.completed(2).0, m, arrive)
}

#[test]
fn an_mbarrier_operation_must_be_ordered_after_the_init() {
    let (g, _, _) = arrival_after_init(true);
    assert_eq!(check(&g).verdict(), Verdict::Pass);
    let (g, object, event) = arrival_after_init(false);
    let bound = g.object(object).init.unwrap();
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::OutsideObjectLifetime {
            object,
            bound,
            event
        }]
    );
}

#[test]
fn an_mbarrier_operation_must_be_ordered_before_the_inval() {
    let build = |wait: bool| {
        let mut s = Scenario::new(2);
        let m = s.mbarrier(0, 1);
        s.barrier(&[0, 1], &[]);
        let p0 = s.phase(m, 0);
        let arrive = s.arrive(1, p0);
        s.complete(p0);
        if wait {
            s.wait(0, m, Parity::Even, p0);
        }
        let inval = s.b.object_inval(t(0), PC, m);
        (s.completed(2).0, m, arrive, inval)
    };
    assert_eq!(check(&build(true).0).verdict(), Verdict::Pass);
    let (g, object, event, bound) = build(false);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::OutsideObjectLifetime {
            object,
            bound,
            event
        }]
    );
}

#[test]
fn data_in_an_mbarriers_bytes_must_be_ordered_before_its_init() {
    let build = |synced: bool| {
        let mut s = Scenario::new(2);
        let effect = s.write(1, 0x1004, 0);
        if synced {
            s.barrier(&[0, 1], &[]);
        }
        let m = s.mbarrier(0, 1);
        (s.completed(2).0, m, effect)
    };
    assert_eq!(check(&build(true).0).verdict(), Verdict::Pass);
    let (g, object, effect) = build(false);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::ObjectMemoryAccess {
            object,
            bound: g.object(object).init,
            effect
        }]
    );
}

#[test]
fn data_in_a_live_mbarriers_bytes_fails_and_after_its_inval_must_be_ordered() {
    let mut s = Scenario::new(1);
    let object = s.mbarrier(0, 1);
    let effect = s.read(0, 0x1000);
    let (g, _) = s.completed(1);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::ObjectMemoryAccess {
            object,
            bound: None,
            effect
        }]
    );

    let build = |synced: bool| {
        let mut s = Scenario::new(2);
        let m = s.mbarrier(0, 1);
        let inval = s.b.object_inval(t(0), PC, m);
        if synced {
            s.barrier(&[0, 1], &[]);
        }
        let effect = s.write(1, 0x1000, 0);
        (s.completed(2).0, m, inval, effect)
    };
    assert_eq!(check(&build(true).0).verdict(), Verdict::Pass);
    let (g, object, inval, effect) = build(false);
    assert_eq!(
        check(&g).violations(),
        [LifetimeViolation::ObjectMemoryAccess {
            object,
            bound: Some(inval),
            effect
        }]
    );
}

#[test]
fn reinitializing_a_live_mbarrier_is_unresolved() {
    let mut s = Scenario::new(1);
    s.mbarrier(0, 1);
    s.mbarrier(0, 1);
    let (g, _) = s.completed(1);
    let result = check(&g);
    let [u] = result.unresolved() else {
        panic!("{result:?}");
    };
    assert!(u.reason.contains("re-initialized"), "{u:?}");
}

#[test]
fn without_lifetime_resources_the_check_is_vacuous() {
    let mut s = Scenario::new(2);
    s.write(0, 0x10, 1);
    s.read(1, 0x10);
    let (g, _) = s.completed(2);
    assert_eq!(
        check(&g),
        PropertyResult::Pass(volta_graph_check::lifetime::LifetimeEvidence {
            tmem_allocations: 0,
            mbarrier_objects: 0,
            obligations: 0,
        })
    );
}
