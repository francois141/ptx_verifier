//! Kernels with a data race or an async-ordering hazard (an async op's effect unordered with
//! another access, a tcgen05 op unwaited at a sync or freed while in flight): the graph
//! branch must fail the matching property, with these witnesses. The wgmma register hazards
//! are the exception: the interpreter raises them as execution errors.

#[macro_use]
mod common;

use volta_analysis::AnalysisError;
use volta_analysis::eval::{AnalysisConfig, ArrayDef, ArrayKind, EvalError, ParamValue};
use volta_frontend::ast::Module;
use volta_graph::{AccessMode, AsyncOpKind, EventGraph, EventId, EventKind, ExecContext, Space};
use volta_graph_check::async_completion::CompletionViolation;
use volta_graph_check::lifetime::LifetimeViolation;
use volta_graph_check::race::{ConflictKind, Location};

use common::*;

/// One side of a witness: the thread it acts for, its access mode, and the async op it is an
/// effect of (`None` for a thread's own access).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Side {
    thread: u32,
    mode: AccessMode,
    op: Option<AsyncOpKind>,
}

impl Side {
    fn plain(thread: u32, mode: AccessMode) -> Side {
        Side {
            thread,
            mode,
            op: None,
        }
    }

    fn effect(thread: u32, mode: AccessMode, op: AsyncOpKind) -> Side {
        Side {
            thread,
            mode,
            op: Some(op),
        }
    }
}

fn side(graph: &EventGraph, e: EventId) -> Side {
    let ev = graph.event(e);
    let EventKind::Access(a) = ev.kind else {
        panic!("event {} is not a memory access: {:?}", e.0, ev.kind);
    };
    Side {
        thread: graph
            .acting_thread(e)
            .expect("an access acts for a thread")
            .0,
        mode: graph.access(a).mode,
        op: match ev.ctx {
            ExecContext::Async(op) => Some(graph.async_op(op).kind),
            ExecContext::Thread(_) | ExecContext::Generation(_) => None,
        },
    }
}

/// A memory-conflict checker violation, its events resolved.
#[derive(Debug)]
struct Witness {
    kind: ConflictKind,
    location: Location,
    prior: Side,
    current: Side,
}

/// Every memory-conflict violation of `module`'s execution; panics if the property did not
/// fail.
fn conflicts(module: &Module, config: AnalysisConfig) -> Vec<Witness> {
    let checked = check(module, None, config);
    let graph = &checked.analysis.graph;
    let witnesses: Vec<Witness> = checked
        .report
        .memory_conflicts
        .violations()
        .iter()
        .map(|c| Witness {
            kind: c.kind,
            location: c.location,
            prior: side(graph, c.prior),
            current: side(graph, c.current),
        })
        .collect();
    assert!(
        !witnesses.is_empty(),
        "expected memory-conflict freedom to fail, got: {:?}",
        checked.report.memory_conflicts
    );
    witnesses
}

fn assert_any(witnesses: &[Witness], expected: &str, matches: impl Fn(&Witness) -> bool) {
    assert!(
        witnesses.iter().any(matches),
        "expected {expected}, got: {witnesses:#?}"
    );
}

fn on_shared(w: &Witness) -> bool {
    matches!(w.location, Location::Byte(Space::Shared, _))
}

fn lane(w: &Witness) -> Option<u8> {
    match w.location {
        Location::Cell { lane, .. } => Some(lane),
        Location::Byte(..) => None,
    }
}

fn warp(thread: u32) -> u32 {
    thread / 32
}

use AccessMode::{Read, Write};

/// Two threads write the same shared address without synchronization.
#[test]
fn test_shared_write_write_race() {
    let ws = conflicts(
        &ptx!(parse "execution_error/shared_write_write_race"),
        AnalysisConfig::new((2, 1, 1)),
    );
    assert_any(&ws, "a write-write race between threads 0 and 1", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.prior == Side::plain(0, Write)
            && w.current == Side::plain(1, Write)
    });
}

#[test]
fn test_shared_exchange_without_barrier_races() {
    let ws = conflicts(
        &ptx!(parse "execution_error/shared_exchange_without_barrier_races"),
        in_out_config(2, 2),
    );
    assert_any(&ws, "a shared-memory race between the two threads", |w| {
        on_shared(w)
            && w.prior.op.is_none()
            && w.current.op.is_none()
            && w.prior.thread != w.current.thread
    });
}

/// Same write/read pair, but thread 1 reads without waiting: must race, so
/// the sibling test's success comes from the mbarrier edge, not the kernel
/// shape.
#[test]
fn test_same_write_read_without_the_wait_still_races() {
    let ws = conflicts(
        &ptx!(parse "execution_error/same_write_read_without_the_wait_still_races"),
        AnalysisConfig::new((2, 1, 1)),
    );
    assert_any(&ws, "thread 1's read racing thread 0's write", |w| {
        w.kind == ConflictKind::WriteRead
            && w.prior == Side::plain(0, Write)
            && w.current == Side::plain(1, Read)
    });
}

// One warp allocates Tensor Memory, then runs its body with `%r1` its
// quadrant-0 base, `%r2` a stored value, and `%r4` a `count = 32` mbarrier
// (the `tcgen05.wait` tests below).

/// The kinds of the `tcgen05.ld`/`.st` ops `module` contributed to a sync with, unwaited.
fn unwaited_at_sync(module: &Module, config: AnalysisConfig) -> Vec<AsyncOpKind> {
    let checked = check(module, None, config);
    let kinds: Vec<AsyncOpKind> = checked
        .report
        .async_completion
        .violations()
        .iter()
        .filter_map(|v| match v {
            CompletionViolation::UnwaitedAtSync { op, .. } => {
                Some(checked.analysis.graph.async_op(*op).kind)
            }
            CompletionViolation::Misassociated { .. } => None,
        })
        .collect();
    assert!(
        !kinds.is_empty(),
        "expected an op unwaited at a sync, got: {:?}",
        checked.report.async_completion
    );
    kinds
}

/// A `tcgen05.wait::ld` placed *after* a barrier arrival is too late: the
/// wait is what completes the `.ld` for its issuer, so the barrier orders
/// nothing about it for the other participants. The arrival is rejected.
#[test]
fn test_tcgen05_wait_ld_after_bar_sync_is_rejected() {
    let kinds = unwaited_at_sync(
        &parse(&ptx!(
            "execution_error/tcgen05_wait_ld_after_bar_sync_is_rejected"
        )),
        AnalysisConfig::new((32, 1, 1)),
    );
    assert!(kinds.contains(&AsyncOpKind::Tcgen05Ld), "{kinds:?}");
}

/// Same for `tcgen05.wait::st` after an mbarrier arrive.
#[test]
fn test_tcgen05_wait_st_after_mbarrier_arrive_is_rejected() {
    let kinds = unwaited_at_sync(
        &parse(&ptx!(
            "execution_error/tcgen05_wait_st_after_mbarrier_arrive_is_rejected"
        )),
        AnalysisConfig::new((32, 1, 1)),
    );
    assert!(kinds.contains(&AsyncOpKind::Tcgen05St), "{kinds:?}");
}

/// The effects `module`'s `tcgen05.dealloc`s free while they are not ordered before them.
fn freed_while_in_use(module: &Module, config: AnalysisConfig) -> Vec<Side> {
    let checked = check(module, None, config);
    let effects: Vec<Side> = checked
        .report
        .lifetime
        .violations()
        .iter()
        .filter_map(|v| match *v {
            LifetimeViolation::FreedWhileInUse { effect, .. } => {
                Some(side(&checked.analysis.graph, effect))
            }
            _ => None,
        })
        .collect();
    assert!(
        !effects.is_empty(),
        "expected a dealloc of columns still in use, got: {:?}",
        checked.report.lifetime
    );
    effects
}

/// `tcgen05.dealloc` with an un-waited `tcgen05.ld`/`.st` still
/// outstanding on the range is rejected: the async op would touch columns
/// that are no longer allocated.
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

// Two-warp CTA: thread 0 issues an M=128, N=8 `tcgen05.mma` (D spans both
// warps' lanes) committed to `mma_bar`. `%r1` = TMEM base, `%r4` = mbarrier,
// `%r6` = `count = 32` `gate`, `%p2` = "in warp 0".

/// A `bar.sync` between commit and completion orders nothing about the MMA:
/// warp 1, released by `gate` via a bare `complete_tx` (no edge), still races
/// the MMA's write of `D`.
#[test]
fn test_tcgen05_mma_bar_sync_before_completion_orders_nothing() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_bar_sync_before_completion_orders_nothing"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "warp 1 racing the MMA's write of D at lane 32", |w| {
        lane(w) == Some(32)
            && w.prior == Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)
            && warp(w.current.thread) == 1
    });
}

/// The commit only attaches the completing mbarrier phase: no edge orders the MMA's write of
/// `D` before warp 0 reads it right after the commit, without waiting.
#[test]
fn test_tcgen05_mma_read_after_commit_without_waiting_is_an_inflight_hazard() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_read_after_commit_without_waiting_is_an_inflight_hazard"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "a quadrant-0 read racing the MMA's write of D", |w| {
        lane(w).is_some_and(|l| l < 32)
            && w.prior == Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)
            && w.current.mode == Read
    });
}

/// The MMA reads its shared operands any time until a waiter observes its completion, even
/// across a `bar.sync`: warp 1 overwriting `A` must race.
#[test]
fn test_tcgen05_mma_operand_write_after_bar_sync_is_an_inflight_hazard() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_operand_write_after_bar_sync_is_an_inflight_hazard"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "thread 32's write racing the MMA's read of A", |w| {
        on_shared(w)
            && w.prior == Side::effect(0, Read, AsyncOpKind::Tcgen05Mma)
            && w.current == Side::plain(32, Write)
    });
}

/// The MMA may write `D` any time after issue, so a `bar.sync` before the
/// commit orders nothing: warp 1's earlier read of `D`, ordered by a bare
/// `complete_tx` only, races the write.
#[test]
fn test_tcgen05_mma_bar_sync_between_issue_and_commit_orders_nothing() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_bar_sync_between_issue_and_commit_orders_nothing"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "thread 32's read of D racing the MMA's write", |w| {
        lane(w) == Some(32)
            && w.prior.thread == 32
            && w.prior.mode == Read
            && w.current == Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)
    });
}

/// `tcgen05.dealloc` of `D`'s columns while the MMA writing them is still
/// in flight - committed, but no thread has observed `mma_bar` - is
/// rejected.
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

/// Reading one's own `cp.async` destination before `wait_group` races the copy
/// even same-thread: the copy's write is an async effect, outside the issuer's
/// program order.
#[test]
fn test_cp_async_same_thread_peek_before_wait_is_hazard() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_same_thread_peek_before_wait_is_hazard"),
        in_out_config(1, 1),
    );
    assert_any(&ws, "thread 0's read racing its own cp.async write", |w| {
        w.kind == ConflictKind::WriteRead
            && w.prior == Side::effect(0, Write, AsyncOpKind::CpAsync)
            && w.current == Side::plain(0, Read)
    });
}

/// Another thread reading the destination while thread 0's copy is in flight
/// races the copy; the barrier exposes the interleaving (otherwise thread 0
/// would finish first).
#[test]
fn test_cp_async_cross_thread_read_of_locked_destination_is_hazard() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_cross_thread_read_of_locked_destination_is_hazard"),
        in_out_config(2, 1),
    );
    assert_any(
        &ws,
        "thread 1's read racing thread 0's cp.async write",
        |w| {
            w.kind == ConflictKind::WriteRead
                && w.prior == Side::effect(0, Write, AsyncOpKind::CpAsync)
                && w.current == Side::plain(1, Read)
        },
    );
}

/// A different thread writing the source while thread 0's copy is still in
/// flight must also race (the copy's source read, not just its destination
/// write).
#[test]
fn test_cp_async_cross_thread_write_of_locked_source_is_hazard() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_cross_thread_write_of_locked_source_is_hazard"),
        in_out_config(2, 1),
    );
    assert_any(
        &ws,
        "thread 1's write racing thread 0's cp.async read",
        |w| {
            w.kind == ConflictKind::ReadWrite
                && w.prior == Side::effect(0, Read, AsyncOpKind::CpAsync)
                && w.current == Side::plain(1, Write)
        },
    );
}

/// `wait_group` orders only the issuer's own later instructions: another
/// thread reading the destination after it, unsynchronized, still races the
/// copy's write.
#[test]
fn test_cp_async_post_wait_cross_thread_read_without_sync_is_data_race() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_post_wait_cross_thread_read_without_sync_is_data_race"),
        in_out_config(2, 1),
    );
    assert_any(
        &ws,
        "thread 1's read racing thread 0's cp.async write",
        |w| {
            w.kind == ConflictKind::WriteRead
                && w.prior == Side::effect(0, Write, AsyncOpKind::CpAsync)
                && w.current == Side::plain(1, Read)
        },
    );
}

/// A TMA destination read does require the copy's completion: without the
/// `mbarrier.try_wait.parity`, the reads race the copy's write.
#[test]
fn test_cp_async_bulk_tensor_read_without_waiting_is_an_inflight_hazard() {
    let module = ptx!(parse "execution_error/cp_async_bulk_tensor_read_without_waiting_is_an_inflight_hazard");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 64,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    let ws = conflicts(&module, config);
    assert_any(&ws, "thread 0's read racing the TMA copy's write", |w| {
        w.kind == ConflictKind::WriteRead
            && w.prior.op == Some(AsyncOpKind::TensorCopy)
            && w.current == Side::plain(0, Read)
    });
}

/// A `bar.sync` after the issue orders nothing about the copy's write: warp
/// 1, released by `gate`'s bare `complete_tx`, reads `buf` unordered with it.
#[test]
fn test_cp_async_bulk_bar_sync_before_completion_orders_nothing() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/cp_async_bulk_bar_sync_before_completion_orders_nothing"
        )),
        bulk_copy_config(),
    );
    assert_any(&ws, "warp 1's read racing the bulk copy's write", |w| {
        on_shared(w)
            && w.prior == Side::effect(0, Write, AsyncOpKind::BulkCopy)
            && warp(w.current.thread) == 1
            && w.current.mode == Read
    });
}

/// Only a waiter observing `full` orders the copy's write before later accesses - a
/// `bar.sync` in between orders nothing. Nobody waits here, and warp 1 reads `buf` after
/// the barrier.
#[test]
fn test_cp_async_bulk_read_after_bar_sync_is_an_inflight_hazard() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/cp_async_bulk_read_after_bar_sync_is_an_inflight_hazard"
        )),
        bulk_copy_config(),
    );
    assert_any(&ws, "thread 32's read racing the bulk copy's write", |w| {
        w.prior == Side::effect(0, Write, AsyncOpKind::BulkCopy) && w.current.thread == 32
    });
}

/// Hazard A (`WgmmaFenceHazard`): an ordinary register write between the two
/// calls breaks the same-shape chain, and the second call's accumulator read
/// has no `wgmma.fence`.
#[test]
fn test_wgmma_fence_hazard_ordinary_write_breaks_chain() {
    let module = ptx!(parse "execution_error/wgmma_fence_hazard_ordinary_write_breaks_chain");
    let err = run_kernel(&module, None, AnalysisConfig::new((128, 1, 1))).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::WgmmaFenceHazard { .. })),
        "expected a wgmma fence hazard, got: {}",
        err
    );
}

/// Hazard B (`WgmmaWaitGroupHazard`): a plain read of an accumulator
/// register still pending a `wgmma.wait_group` release.
#[test]
fn test_wgmma_wait_group_hazard_plain_read_of_pending_accumulator() {
    let module =
        ptx!(parse "execution_error/wgmma_wait_group_hazard_plain_read_of_pending_accumulator");
    let err = run_kernel(&module, None, AnalysisConfig::new((128, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::WgmmaWaitGroupHazard { .. })
        ),
        "expected a wgmma wait_group hazard, got: {}",
        err
    );
}

/// Likewise, an ordinary *write* to a pending accumulator register before
/// `wgmma.wait_group` is a hazard (`write_reg`'s hazard-B check, not just
/// `read_reg`'s).
#[test]
fn test_wgmma_wait_group_hazard_plain_write_of_pending_accumulator() {
    let module =
        ptx!(parse "execution_error/wgmma_wait_group_hazard_plain_write_of_pending_accumulator");
    let err = run_kernel(&module, None, AnalysisConfig::new((128, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::WgmmaWaitGroupHazard { .. })
        ),
        "expected a wgmma wait_group hazard, got: {}",
        err
    );
}

/// A `wgmma.mma_async` reads its shared `A`/`B` until every live member's
/// `wgmma.wait_group` releases it: thread 0 overwriting `A` before waiting
/// (`_before_wait_group`), or under a `wait_group 1` that keeps the group
/// pending (`_after_wait_group_1`), races that read.
#[test]
fn test_wgmma_operand_write_while_in_flight_is_an_inflight_hazard() {
    for (name, src) in [
        ptx_case!("execution_error/wgmma_operand_write_before_wait_group_is_an_inflight_hazard"),
        ptx_case!("execution_error/wgmma_operand_write_after_wait_group_1_is_an_inflight_hazard"),
    ] {
        let mut config = AnalysisConfig::new((128, 1, 1));
        config.arrays = vec![ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 1,
            kind: ArrayKind::Output,
        }];
        config.params = vec![ParamValue::ArrayPtr("out".to_string())];
        let ws = conflicts(&parse(&src), config);
        assert!(
            ws.iter().any(|w| on_shared(w)
                && w.prior.thread == 0
                && w.prior.mode == Read
                && matches!(w.prior.op, Some(AsyncOpKind::WgmmaMma { .. }))
                && w.current == Side::plain(0, Write)),
            "{name}: expected thread 0's write racing its wgmma's read, got: {ws:#?}"
        );
    }
}

/// Two threads storing different values to one shared address race (unlike
/// the same-value store in `accepted_tests.rs`).
#[test]
fn test_different_value_store_to_one_address_races() {
    let ws = conflicts(
        &ptx!(parse "execution_error/same_value_warp_uniform_store_is_not_a_race_differ"),
        in_out_config(2, 1),
    );
    assert_any(&ws, "a write-write race between threads 0 and 1", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.prior == Side::plain(0, Write)
            && w.current == Side::plain(1, Write)
    });
}

/// A `try_cancel` response is an async write ordered only by a waiter observing its
/// mbarrier: warp 1 reads it after `bar.sync` alone and races the write.
#[test]
fn test_clusterlaunchcontrol_response_read_without_waiting_is_an_inflight_hazard() {
    let ws = conflicts(
        &ptx!(
            parse "execution_error/clusterlaunchcontrol_response_read_without_waiting_is_an_inflight_hazard"
        ),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "thread 32's read racing the response write", |w| {
        w.prior == Side::effect(0, Write, AsyncOpKind::ClcResponse) && w.current.thread == 32
    });
}
