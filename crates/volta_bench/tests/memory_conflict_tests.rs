//! Kernels whose global or shared memory effects (`M`) conflict unordered: the memory-conflict
//! check (Algorithm 2) must fail, with these pairs of `B`.

#[macro_use]
mod common;

use volta_analysis::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};
use volta_graph::{AccessMode, AsyncOpKind, Space};
use volta_graph_check::domain::{ByteLocation, ConflictKind};

use common::*;

/// A pair of `B`, its events resolved.
#[derive(Debug)]
struct Witness {
    kind: ConflictKind,
    location: ByteLocation,
    earlier: Side,
    later: Side,
}

/// Every pair of `B` for `module`'s execution; panics if the check did not fail.
fn conflicts(module: &Ptx, config: AnalysisConfig) -> Vec<Witness> {
    let checked = check(module, None, config);
    let graph = &checked.analysis.graph;
    let witnesses: Vec<Witness> = checked
        .report
        .memory_conflict
        .violations()
        .iter()
        .map(|c| Witness {
            kind: c.kind,
            location: c.location,
            earlier: side(graph, c.earlier),
            later: side(graph, c.later),
        })
        .collect();
    assert!(
        !witnesses.is_empty(),
        "expected memory-conflict freedom to fail, got: {:?}",
        checked.report.memory_conflict
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
    w.location.space == Space::Shared
}

use AccessMode::{Read, Write};

/// Two threads write the same shared address without synchronization.
#[test]
fn test_shared_write_write_race() {
    let ws = conflicts(
        &ptx!(parse "execution_error/shared_write_write_race"),
        AnalysisConfig::new((2, 1, 1)),
    );
    assert_any(&ws, "a write-write pair of threads 0 and 1", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.earlier == Side::plain(0, Write)
            && w.later == Side::plain(1, Write)
    });
}

#[test]
fn test_shared_exchange_without_barrier_races() {
    let ws = conflicts(
        &ptx!(parse "execution_error/shared_exchange_without_barrier_races"),
        in_out_config(2, 2),
    );
    assert_any(&ws, "a shared-memory pair of the two threads", |w| {
        on_shared(w)
            && w.earlier.op.is_none()
            && w.later.op.is_none()
            && w.earlier.thread != w.later.thread
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
    assert_any(
        &ws,
        "thread 1's read unordered with thread 0's write",
        |w| {
            w.kind == ConflictKind::WriteRead
                && w.earlier == Side::plain(0, Write)
                && w.later == Side::plain(1, Read)
        },
    );
}

/// Two threads storing the same value to one shared address conflict too: Algorithm 2 has no
/// exception for equal values. A `bar.sync` between the stores makes the kernel race-free
/// (`test_same_value_stores_separated_by_bar_sync_are_not_a_race`).
#[test]
fn test_same_value_store_to_one_address_races() {
    let ws = conflicts(
        &ptx!(parse "execution_error/same_value_store_to_one_address_races"),
        in_out_config(2, 1),
    );
    assert_any(&ws, "a write-write pair of threads 0 and 1", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.earlier == Side::plain(0, Write)
            && w.later == Side::plain(1, Write)
    });
}

/// Two threads storing different values to one shared address conflict.
#[test]
fn test_different_value_store_to_one_address_races() {
    let ws = conflicts(
        &ptx!(parse "execution_error/same_value_warp_uniform_store_is_not_a_race_differ"),
        in_out_config(2, 1),
    );
    assert_any(&ws, "a write-write pair of threads 0 and 1", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.earlier == Side::plain(0, Write)
            && w.later == Side::plain(1, Write)
    });
}

// Two-warp CTA: thread 0 issues an M=128, N=8 `tcgen05.mma` (D spans both
// warps' lanes) committed to `mma_bar`. `%r1` = TMEM base, `%r4` = mbarrier,
// `%r6` = `count = 32` `gate`, `%p2` = "in warp 0".

/// The MMA reads its shared operands any time until a waiter observes its completion, even
/// across a `bar.sync`: warp 1 overwriting `A` must conflict with that read.
#[test]
fn test_tcgen05_mma_operand_write_after_bar_sync_is_an_inflight_hazard() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/tcgen05_mma_operand_write_after_bar_sync_is_an_inflight_hazard"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "thread 32's write after the MMA's read of A", |w| {
        on_shared(w)
            && w.earlier == Side::effect(0, Read, AsyncOpKind::Tcgen05Mma)
            && w.later == Side::plain(32, Write)
    });
}

/// Reading one's own `cp.async` destination before `wait_group` conflicts with the copy even
/// on one thread: the copy's write is an async effect, outside the issuer's program order.
#[test]
fn test_cp_async_same_thread_peek_before_wait_is_hazard() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_same_thread_peek_before_wait_is_hazard"),
        in_out_config(1, 1),
    );
    assert_any(&ws, "thread 0's read and its own cp.async write", |w| {
        w.kind == ConflictKind::WriteRead
            && w.earlier == Side::effect(0, Write, AsyncOpKind::CpAsync)
            && w.later == Side::plain(0, Read)
    });
}

/// Likewise for a store: thread 0 writes its own `cp.async` destination before `wait_all`, so
/// which write the shared word ends up holding depends on when the copy lands. The other
/// threads of the warp exit at once.
#[test]
fn test_cp_async_same_thread_store_before_wait_is_hazard() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_same_thread_store_before_wait_is_hazard"),
        in_out_config(32, 1),
    );
    assert_any(&ws, "thread 0's store and its own cp.async write", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.earlier == Side::effect(0, Write, AsyncOpKind::CpAsync)
            && w.later == Side::plain(0, Write)
    });
}

/// Another thread reading the destination while thread 0's copy is in flight conflicts with
/// the copy; the barrier exposes the interleaving.
#[test]
fn test_cp_async_cross_thread_read_of_locked_destination_is_hazard() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_cross_thread_read_of_locked_destination_is_hazard"),
        in_out_config(2, 1),
    );
    assert_any(&ws, "thread 1's read and thread 0's cp.async write", |w| {
        w.kind == ConflictKind::WriteRead
            && w.earlier == Side::effect(0, Write, AsyncOpKind::CpAsync)
            && w.later == Side::plain(1, Read)
    });
}

/// A different thread writing the source while thread 0's copy is still in flight conflicts
/// with the copy's source read.
#[test]
fn test_cp_async_cross_thread_write_of_locked_source_is_hazard() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_cross_thread_write_of_locked_source_is_hazard"),
        in_out_config(2, 1),
    );
    assert_any(&ws, "thread 1's write and thread 0's cp.async read", |w| {
        w.kind == ConflictKind::ReadWrite
            && w.earlier == Side::effect(0, Read, AsyncOpKind::CpAsync)
            && w.later == Side::plain(1, Write)
    });
}

/// `wait_group` orders only the issuer's own later instructions: another thread reading the
/// destination after it, unsynchronized, still conflicts with the copy's write.
#[test]
fn test_cp_async_post_wait_cross_thread_read_without_sync_is_data_race() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_async_post_wait_cross_thread_read_without_sync_is_data_race"),
        in_out_config(2, 1),
    );
    assert_any(&ws, "thread 1's read and thread 0's cp.async write", |w| {
        w.kind == ConflictKind::WriteRead
            && w.earlier == Side::effect(0, Write, AsyncOpKind::CpAsync)
            && w.later == Side::plain(1, Read)
    });
}

/// A TMA destination read requires the copy's completion: without the
/// `mbarrier.try_wait.parity`, the reads conflict with the copy's write.
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
    assert_any(&ws, "thread 0's read and the TMA copy's write", |w| {
        w.kind == ConflictKind::WriteRead
            && w.earlier.op == Some(AsyncOpKind::TensorCopy)
            && w.later == Side::plain(0, Read)
    });
}

/// A `bar.sync` after the issue orders nothing about the copy's write: warp 1, released by
/// `gate`'s bare `complete_tx`, reads `buf` unordered with it.
#[test]
fn test_cp_async_bulk_bar_sync_before_completion_orders_nothing() {
    let ws = conflicts(
        &parse(&ptx!(
            "execution_error/cp_async_bulk_bar_sync_before_completion_orders_nothing"
        )),
        bulk_copy_config(),
    );
    assert_any(&ws, "warp 1's read and the bulk copy's write", |w| {
        on_shared(w)
            && w.earlier == Side::effect(0, Write, AsyncOpKind::BulkCopy)
            && warp(w.later.thread) == 1
            && w.later.mode == Read
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
    assert_any(&ws, "thread 32's read and the bulk copy's write", |w| {
        w.earlier == Side::effect(0, Write, AsyncOpKind::BulkCopy) && w.later.thread == 32
    });
}

/// A `wgmma.mma_async` reads its shared `A`/`B` until every live member's
/// `wgmma.wait_group` releases it: thread 0 overwriting `A` before waiting
/// (`_before_wait_group`), or under a `wait_group 1` that keeps the group
/// pending (`_after_wait_group_1`), conflicts with that read.
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
                && w.earlier.thread == 0
                && w.earlier.mode == Read
                && matches!(w.earlier.op, Some(AsyncOpKind::WgmmaMma { .. }))
                && w.later == Side::plain(0, Write)),
            "{name}: expected thread 0's write after its wgmma's read, got: {ws:#?}"
        );
    }
}

/// A `try_cancel` response is an async write ordered only by a waiter observing its
/// mbarrier: warp 1 reads it after `bar.sync` alone and conflicts with the write.
#[test]
fn test_clusterlaunchcontrol_response_read_without_waiting_is_an_inflight_hazard() {
    let ws = conflicts(
        &ptx!(
            parse "execution_error/clusterlaunchcontrol_response_read_without_waiting_is_an_inflight_hazard"
        ),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "thread 32's read and the response write", |w| {
        w.earlier == Side::effect(0, Write, AsyncOpKind::ClcResponse) && w.later.thread == 32
    });
}
