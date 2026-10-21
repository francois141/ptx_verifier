//! Kernels whose Tensor Memory effects (`A`) conflict without a pipelining rule or a
//! synchronization witness: the tensor-operation ordering check (Algorithm 4, with
//! Algorithm 5's search) must fail, with these pairs of `B`.

#[macro_use]
#[allow(unused_macros)]
mod common;

use volta_analysis::eval::AnalysisConfig;
use volta_frontend::ast::Module;
use volta_graph::{AccessMode, AsyncOpKind};
use volta_graph_check::domain::{ConflictKind, TmemCell};

use common::*;

/// A pair of `B`, its events resolved.
#[derive(Debug)]
struct Witness {
    kind: ConflictKind,
    cell: TmemCell,
    earlier: Side,
    later: Side,
}

/// Every pair of `B` for `module`'s execution; panics if the check did not fail.
fn unproved(module: &Module, config: AnalysisConfig) -> Vec<Witness> {
    let checked = check(module, None, config);
    let graph = &checked.analysis.graph;
    let witnesses: Vec<Witness> = checked
        .report
        .tensor_order
        .violations()
        .iter()
        .map(|c| Witness {
            kind: c.kind,
            cell: c.cell,
            earlier: side(graph, c.earlier),
            later: side(graph, c.later),
        })
        .collect();
    assert!(
        !witnesses.is_empty(),
        "expected tensor-operation ordering to fail, got: {:?}",
        checked.report.tensor_order
    );
    witnesses
}

fn assert_any(witnesses: &[Witness], expected: &str, matches: impl Fn(&Witness) -> bool) {
    assert!(
        witnesses.iter().any(matches),
        "expected {expected}, got: {witnesses:#?}"
    );
}

use AccessMode::{Read, Write};

// Two-warp CTA: thread 0 issues an M=128, N=8 `tcgen05.mma` (D spans both
// warps' lanes) committed to `mma_bar`. `%r1` = TMEM base, `%r4` = mbarrier,
// `%r6` = `count = 32` `gate`, `%p2` = "in warp 0".

/// A `bar.sync` between commit and completion, without the `tcgen05` fences, is no witness:
/// warp 1's read of `D` at lane 32 is unproved against the MMA's write.
#[test]
fn test_tcgen05_mma_bar_sync_before_completion_orders_nothing() {
    let ws = unproved(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_bar_sync_before_completion_orders_nothing"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(
        &ws,
        "warp 1's read of D at lane 32 after the MMA's write",
        |w| {
            w.kind == ConflictKind::WriteRead
                && w.cell.lane == 32
                && w.earlier == Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)
                && warp(w.later.thread) == 1
        },
    );
}

/// Warp 0 reads `D` right after the commit, without waiting and without an after-fence.
#[test]
fn test_tcgen05_mma_read_after_commit_without_waiting_is_an_inflight_hazard() {
    let ws = unproved(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_read_after_commit_without_waiting_is_an_inflight_hazard"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "a quadrant-0 read after the MMA's write of D", |w| {
        w.cell.lane < 32
            && w.earlier == Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)
            && w.later.mode == Read
    });
}

/// Warp 1 reads `D` before the MMA is issued; a `bar.sync` between issue and commit is no
/// witness for the read-then-write pair.
#[test]
fn test_tcgen05_mma_bar_sync_between_issue_and_commit_orders_nothing() {
    let ws = unproved(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_bar_sync_between_issue_and_commit_orders_nothing"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "thread 32's read of D before the MMA's write", |w| {
        w.kind == ConflictKind::ReadWrite
            && w.cell.lane == 32
            && w.earlier.thread == 32
            && w.earlier.mode == Read
            && w.later == Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)
    });
}

/// Warp 1 waits on `mma_bar` and then reads `D` without `tcgen05.fence::after_thread_sync`: the
/// commit supplies the before role, nothing the after role. With the fence, the same kernel is
/// accepted (`test_tcgen05_mma_every_reader_waiting_is_accepted`).
#[test]
fn test_tcgen05_mma_reader_without_fence_after_thread_sync_is_rejected() {
    let ws = unproved(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_reader_without_fence_after_thread_sync_is_rejected"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(
        &ws,
        "warp 1's read of D at lane 32 after the MMA's write",
        |w| {
            w.kind == ConflictKind::WriteRead
                && w.cell.lane == 32
                && w.earlier == Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)
                && w.later == Side::effect(32, Read, AsyncOpKind::Tcgen05Ld)
        },
    );
}

/// A `tcgen05.wait::ld` placed after a barrier arrival is too late for the warp's other
/// accesses; the kernel's `tcgen05.ld` must be reported.
#[test]
fn test_tcgen05_wait_ld_after_bar_sync_is_rejected() {
    let ws = unproved(
        &parse(&ptx!(
            "execution_error/tcgen05_wait_ld_after_bar_sync_is_rejected"
        )),
        AnalysisConfig::new((32, 1, 1)),
    );
    assert_any(&ws, "a pair with the tcgen05.ld", |w| {
        w.earlier.op == Some(AsyncOpKind::Tcgen05Ld) || w.later.op == Some(AsyncOpKind::Tcgen05Ld)
    });
}

/// Same for `tcgen05.wait::st` after an mbarrier arrive.
#[test]
fn test_tcgen05_wait_st_after_mbarrier_arrive_is_rejected() {
    let ws = unproved(
        &parse(&ptx!(
            "execution_error/tcgen05_wait_st_after_mbarrier_arrive_is_rejected"
        )),
        AnalysisConfig::new((32, 1, 1)),
    );
    assert_any(&ws, "a pair with the tcgen05.st", |w| {
        w.earlier.op == Some(AsyncOpKind::Tcgen05St) || w.later.op == Some(AsyncOpKind::Tcgen05St)
    });
}
