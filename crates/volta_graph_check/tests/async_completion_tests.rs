//! The async-completion checker in isolation, on purpose-built graphs.

mod common;

use std::collections::HashSet;

use common::*;
use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, CollectiveSide, ContributionKind, GenerationEvidence,
    GenerationId, GenerationKind, GroupFamily, Parity, Proxy, SyncObjectKind, ThreadIx,
};
use volta_graph_check::Verdict;
use volta_graph_check::async_completion::{CompletionViolation, check_async_completion};
use volta_graph_check::barrier::SyncCertificate;
use volta_graph_check::hb::Validated;

/// `t0`'s `cp.async.wait_group keep` releasing `ops`.
fn wait_group(s: &mut Scenario, keep: u32, ops: &[AsyncOpId]) -> GenerationId {
    let o =
        s.b.sync_object(SyncObjectKind::AsyncGroupWait { thread: t(0) });
    let g =
        s.b.open_generation(o, 0, GenerationKind::AsyncGroupWait { keep_pending: keep });
    for &op in ops {
        s.b.track(op, g, 0);
    }
    s.b.complete_generation(g, GenerationEvidence::default());
    s.b.resume(t(0), PC, g);
    g
}

#[test]
fn a_cp_async_released_by_its_groups_wait_passes() {
    let mut s = Scenario::new(1);
    let op = s.async_op(
        0,
        AsyncOpKind::CpAsync,
        AccessMode::Write,
        0,
        Proxy::Generic,
    );
    s.b.group_commit(t(0), PC, GroupFamily::CpAsync);
    wait_group(&mut s, 0, &[op]);
    let (g, _) = s.completed(1);
    let (result, cert) = check_async_completion(&g, &SyncCertificate::assume_all());
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
    assert!(cert.completions.is_all());
}

#[test]
fn a_cp_async_released_by_the_wrong_wait_is_misassociated() {
    let mut s = Scenario::new(1);
    let a = s.async_op(
        0,
        AsyncOpKind::CpAsync,
        AccessMode::Write,
        0,
        Proxy::Generic,
    );
    s.b.group_commit(t(0), PC, GroupFamily::CpAsync);
    let b = s.async_op(
        0,
        AsyncOpKind::CpAsync,
        AccessMode::Write,
        4,
        Proxy::Generic,
    );
    s.b.group_commit(t(0), PC, GroupFamily::CpAsync);
    wait_group(&mut s, 1, &[a, b]);
    let (g, _) = s.finish(volta_graph::Terminal::Aborted {
        thread: None,
        pc: None,
        reason: "test".to_string(),
    });
    let (result, cert) = check_async_completion(&g, &SyncCertificate::assume_all());
    assert!(matches!(
        result.violations(),
        [CompletionViolation::Misassociated { op, .. }] if *op == b
    ));
    assert!(!cert.completions.contains(&b));
    assert!(cert.completions.contains(&a));
}

/// A bulk copy by `t0` completing `tx` bytes on phase 0 of an mbarrier `t1` waits on.
fn bulk_copy(tx: u64) -> volta_graph::EventGraph {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    s.b.contribute(
        t(0),
        PC,
        p0,
        ContributionKind::Arrival {
            count: 1,
            expect_tx: 4,
        },
    );
    let op = s.async_op(0, AsyncOpKind::BulkCopy, AccessMode::Write, 0, Proxy::Async);
    s.b.track(op, p0, tx);
    s.complete(p0);
    s.wait(1, m, Parity::Even, p0);
    s.completed(2).0
}

#[test]
fn a_bulk_copy_on_its_forming_phase_passes() {
    let (result, _) = check_async_completion(&bulk_copy(4), &SyncCertificate::assume_all());
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn a_bulk_copy_completing_other_bytes_than_it_writes_is_misassociated() {
    let (result, _) = check_async_completion(&bulk_copy(16), &SyncCertificate::assume_all());
    assert_eq!(result.verdict(), Verdict::Fail);
}

#[test]
fn tracking_through_an_unvalidated_generation_is_unknown() {
    let graph = bulk_copy(4);
    let no_phase = SyncCertificate {
        generations: Validated::Only(HashSet::new()),
    };
    let (result, cert) = check_async_completion(&graph, &no_phase);
    assert_eq!(result.verdict(), Verdict::Unknown, "{result:?}");
    assert!(!cert.completions.is_all());
}

#[test]
fn an_mma_tracked_without_its_issuers_commit_is_misassociated() {
    let mut s = Scenario::new(2);
    let m = s.mbarrier(0, 1);
    let p0 = s.phase(m, 0);
    let op = s.async_op(
        0,
        AsyncOpKind::Tcgen05Mma,
        AccessMode::Read,
        0,
        Proxy::Async,
    );
    s.b.track(op, p0, 0);
    s.arrive(1, p0);
    s.complete(p0);
    let (g, _) = s.completed(2);
    let (result, _) = check_async_completion(&g, &SyncCertificate::assume_all());
    assert_eq!(result.verdict(), Verdict::Fail, "{result:?}");
}

/// A one-thread "warp" collective instance at `pc` over lane 0, wrapping `body`.
fn collective(s: &mut Scenario, index: u32, body: impl FnOnce(&mut Scenario, GenerationId)) {
    let warp = match s
        .b
        .graph_so_far()
        .objects()
        .iter()
        .find(|(_, o)| o.kind == SyncObjectKind::WarpCollective { warp: 0 })
    {
        Some((o, _)) => o,
        None => s.b.sync_object(SyncObjectKind::WarpCollective { warp: 0 }),
    };
    let kind = |side| GenerationKind::Collective {
        pc: PC,
        mask: 1,
        side,
    };
    let entry =
        s.b.open_generation(warp, index, kind(CollectiveSide::Entry));
    s.b.contribute(t(0), PC, entry, ContributionKind::Blocking);
    s.b.complete_generation(entry, GenerationEvidence::default());
    s.b.resume(t(0), PC, entry);
    let exit = s.b.open_generation(warp, index, kind(CollectiveSide::Exit));
    body(s, exit);
    s.b.contribute(t(0), PC, exit, ContributionKind::Blocking);
    s.b.complete_generation(exit, GenerationEvidence::default());
    s.b.resume(t(0), PC, exit);
}

/// `tcgen05.ld`, then (with `sync_first`) a barrier arrival, then its `tcgen05.wait::ld`.
fn ld_then_wait(sync_first: bool) -> volta_graph::EventGraph {
    let mut s = Scenario::new(1);
    let mut ld = None;
    collective(&mut s, 0, |s, _| {
        ld = Some(s.async_op(0, AsyncOpKind::Tcgen05Ld, AccessMode::Read, 0, Proxy::Async));
    });
    let ld = ld.unwrap();
    if sync_first {
        s.barrier(&[0], &[]);
    }
    collective(&mut s, 1, |s, exit| s.b.track(ld, exit, 0));
    if !sync_first {
        s.barrier(&[0], &[]);
    }
    s.completed(1).0
}

#[test]
fn a_tcgen05_ld_waited_before_its_warp_syncs_passes() {
    let (result, _) = check_async_completion(&ld_then_wait(false), &SyncCertificate::assume_all());
    assert_eq!(result.verdict(), Verdict::Pass, "{result:?}");
}

#[test]
fn a_sync_before_the_tcgen05_ld_completes_fails() {
    let graph = ld_then_wait(true);
    let (result, _) = check_async_completion(&graph, &SyncCertificate::assume_all());
    let [CompletionViolation::UnwaitedAtSync { thread, sync, .. }] = result.violations() else {
        panic!("{result:?}");
    };
    assert_eq!(*thread, ThreadIx(0));
    assert!(matches!(
        graph.event(*sync).kind,
        volta_graph::EventKind::Contribute(_)
    ));
}
