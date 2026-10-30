//! Kernels whose global or shared memory effects (`M`) conflict unordered: the memory-conflict
//! check (Algorithm 3) must fail, with these pairs of `B`.

#[macro_use]
mod common;

use volta_graph::{AccessMode, AsyncOpKind, Space};
use volta_graph_check::domain::{ByteLocation, ConflictKind};
use volta_ptx_analysis::{
    AnalysisConfig, ArrayDef, ArrayKind, FieldValue, ParamValue, StructField, TensorElemType,
    TensorFillMode, TensorInterleaveLayout, TensorMapMode, TensorMapValue, TensorSwizzleAtomicity,
    TensorSwizzleMode,
};

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

/// Warp 1 stores to shared memory and exits; warp 0 reads the stores after `bar.sync 0`. The
/// exited warp counts as arrived for the barrier to fire (Sync'), but it does not participate,
/// and PTX orders only participating threads' accesses.
#[test]
fn test_exited_writer_unordered_by_bar_sync() {
    let ws = conflicts(
        &ptx!(parse "execution_error/exited_writer_unordered_by_bar_sync"),
        in_out_config(64, 32),
    );
    assert_any(
        &ws,
        "thread 0's read unordered with thread 32's write",
        |w| {
            w.kind == ConflictKind::WriteRead
                && on_shared(w)
                && w.earlier == Side::plain(32, Write)
                && w.later == Side::plain(0, Read)
        },
    );
}

/// The warp-collective form: lane 1 stores and exits, lane 0 reads after `bar.warp.sync 3`.
#[test]
fn test_exited_writer_unordered_by_bar_warp_sync() {
    let ws = conflicts(
        &ptx!(parse "execution_error/exited_writer_unordered_by_bar_warp_sync"),
        in_out_config(2, 1),
    );
    assert_any(&ws, "lane 0's read unordered with lane 1's write", |w| {
        w.kind == ConflictKind::WriteRead
            && on_shared(w)
            && w.earlier == Side::plain(1, Write)
            && w.later == Side::plain(0, Read)
    });
}

/// Mirrored: lane 1 reads and exits, lane 0 overwrites the word after `bar.warp.sync 3`.
#[test]
fn test_exited_reader_unordered_by_bar_warp_sync() {
    let ws = conflicts(
        &ptx!(parse "execution_error/exited_reader_unordered_by_bar_warp_sync"),
        AnalysisConfig::new((2, 1, 1)),
    );
    assert_any(&ws, "lane 0's write unordered with lane 1's read", |w| {
        w.kind == ConflictKind::ReadWrite
            && on_shared(w)
            && w.earlier == Side::plain(1, Read)
            && w.later == Side::plain(0, Write)
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

/// Two threads storing the same value to one shared address conflict too: Algorithm 3 has no
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
    let mut config = AnalysisConfig::new((32, 1, 1));
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

/// A `shfl.sync` is a rendezvous, not a memory barrier: lane 0's staged store and the other
/// lanes' loads after the shuffle stay unordered.
#[test]
fn test_shfl_sync_is_not_a_memory_barrier() {
    let ws = conflicts(
        &ptx!(parse "execution_error/shfl_sync_is_not_a_memory_barrier"),
        in_out_config(32, 32),
    );
    assert_any(
        &ws,
        "lane 0's store unordered with another lane's load",
        |w| {
            w.kind == ConflictKind::WriteRead
                && on_shared(w)
                && w.earlier == Side::plain(0, Write)
                && w.later.thread != 0
                && w.later.mode == Read
        },
    );
}

/// Lane 1's store and lane 2's load of `x` are separated only by `tcgen05.alloc`, a warp
/// collective that waits for every lane but orders no memory access.
#[test]
fn test_tcgen05_alloc_orders_lanes_plain_accesses() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let ws = conflicts(
        &ptx!(parse "execution_error/tcgen05_alloc_orders_lanes_plain_accesses"),
        config,
    );
    assert_any(&ws, "lane 1's store unordered with lane 2's load", |w| {
        w.kind == ConflictKind::WriteRead
            && on_shared(w)
            && w.earlier == Side::plain(1, Write)
            && w.later == Side::plain(2, Read)
    });
}

/// Every lane loads the Tensor Memory address right after `tcgen05.alloc`, relying on the alloc
/// to synchronize the warp: lane 0 writes the address for the warp, and the alloc orders that
/// write before no other lane's load.
#[test]
fn test_tcgen05_alloc_does_not_publish_its_address_write() {
    let ws = conflicts(
        &ptx!(parse "execution_error/tcgen05_alloc_address_read_without_bar_warp_sync"),
        AnalysisConfig::new((32, 1, 1)),
    );
    let readers: Vec<u32> = ws
        .iter()
        .filter(|w| {
            w.kind == ConflictKind::WriteRead
                && on_shared(w)
                && w.earlier == Side::plain(0, Write)
                && w.later.mode == Read
                && w.later.op.is_none()
        })
        .map(|w| w.later.thread)
        .collect();
    assert_eq!(
        readers,
        (1..32).collect::<Vec<u32>>(),
        "lane 0's address write unordered with each other lane's load: {ws:#?}"
    );
}

/// Thread 32's TMA reads the tensor map thread 0 is still building: both fences are there, but
/// nothing orders thread 0's release before thread 32's acquire.
#[test]
fn test_tma_uses_tensormap_built_by_other_thread_without_sync() {
    let ws = conflicts(
        &ptx!(parse "execution_error/tma_uses_tensormap_built_by_other_thread_without_sync"),
        tma_config(64),
    );
    assert_any(
        &ws,
        "thread 0's replace unordered with thread 32's TMA",
        |w| {
            w.kind == ConflictKind::WriteRead
                && w.location.space == Space::Global
                && w.earlier == Side::plain(0, Write)
                && w.later == Side::effect(32, Read, AsyncOpKind::TensorCopy)
        },
    );
}

/// Warp 0 publishes the tensor map with `tensormap.cp_fenceproxy`, whose release is there, and
/// thread 32 acquires it, but nothing orders the copy before thread 32's TMA.
#[test]
fn test_tma_uses_another_warps_cp_fenceproxy_copy_without_sync() {
    let ws = conflicts(
        &ptx!(parse "execution_error/tma_uses_another_warps_cp_fenceproxy_copy_without_sync"),
        tma_config(64),
    );
    assert_any(&ws, "warp 0's copy unordered with thread 32's TMA", |w| {
        w.kind == ConflictKind::WriteRead
            && w.location.space == Space::Global
            && w.earlier == Side::plain(0, Write)
            && w.later == Side::effect(32, Read, AsyncOpKind::TensorCopy)
    });
}

/// The copy reads its tensor map asynchronously, until its completion is observed: rewriting
/// the map before waiting races with that read.
#[test]
fn test_tensormap_replace_while_tma_in_flight() {
    let ws = conflicts(
        &ptx!(parse "execution_error/tensormap_replace_while_tma_in_flight"),
        tma_config(32),
    );
    assert_any(
        &ws,
        "the TMA's read unordered with the later replace",
        |w| {
            w.kind == ConflictKind::ReadWrite
                && w.location.space == Space::Global
                && w.earlier == Side::effect(0, Read, AsyncOpKind::TensorCopy)
                && w.later == Side::plain(0, Write)
        },
    );
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

/// Two warps; thread 0 stages `scale[0]` in shared `meta`, which thread 32 reads.
fn staged_meta_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((64, 1, 1));
    let array = |name: &str, base, len, kind| ArrayDef {
        name: name.to_string(),
        base,
        elem_width: 4,
        len,
        kind,
    };
    config.arrays = vec![
        array("in", 0x10000, 4, ArrayKind::Input),
        array("scale", 0x18000, 1, ArrayKind::Input),
        array("out", 0x20000, 1, ArrayKind::Output),
    ];
    config.params = ["in", "scale", "out"]
        .map(|a| ParamValue::ArrayPtr(a.to_string()))
        .to_vec();
    config
}

/// An async op's completion or arrive-on is ordered only with that op's own accesses, so a
/// store the signalling thread made before it is unordered with the waiter's read.
fn assert_meta_races(name: &str, module: &Ptx) {
    let ws = conflicts(module, staged_meta_config());
    assert_any(&ws, &format!("{name}: thread 32's read of meta"), |w| {
        w.kind == ConflictKind::WriteRead
            && on_shared(w)
            && w.earlier == Side::plain(0, Write)
            && w.later == Side::plain(32, Read)
    });
}

#[test]
fn test_tma_complete_tx_does_not_release_the_issuers_earlier_store() {
    assert_meta_races(
        "TMA",
        &ptx!(parse "execution_error/tma_complete_tx_does_not_release_the_issuers_earlier_store"),
    );
}

#[test]
fn test_cp_async_mbarrier_arrive_does_not_release_the_threads_earlier_store() {
    assert_meta_races(
        "cp.async.mbarrier.arrive",
        &ptx!(
            parse "execution_error/cp_async_mbarrier_arrive_does_not_release_the_threads_earlier_store"
        ),
    );
}

#[test]
fn test_tcgen05_commit_does_not_release_the_threads_earlier_store() {
    assert_meta_races(
        "tcgen05.commit",
        &ptx!(parse "execution_error/tcgen05_commit_does_not_release_the_threads_earlier_store"),
    );
}

/// `mbarrier.init` writes its object: thread 1's init of `word` is unordered with thread 0's
/// store and load of it, so `out[0]` need not read back 42.
#[test]
fn test_mbarrier_init_write_races_plain_store_load() {
    let mut config = AnalysisConfig::new((2, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 8,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let ws = conflicts(
        &ptx!(parse "execution_error/mbarrier_init_write_races_plain_store_load"),
        config,
    );
    assert_any(&ws, "thread 0's store, then thread 1's init", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.earlier == Side::plain(0, Write)
            && w.later == Side::plain(1, Write)
    });
    assert_any(&ws, "thread 0's load, then thread 1's init", |w| {
        w.kind == ConflictKind::ReadWrite
            && on_shared(w)
            && w.earlier == Side::plain(0, Read)
            && w.later == Side::plain(1, Write)
    });
}

/// `tensormap.replace` writes the whole opaque tensor-map object, so two threads replacing a
/// field of one map with no synchronization race.
#[test]
fn test_tensormap_replace_write_write_race() {
    let ws = conflicts(
        &ptx!(parse "execution_error/tensormap_replace_write_write_race"),
        AnalysisConfig::new((2, 1, 1)),
    );
    assert_any(&ws, "a write-write pair of threads 0 and 1", |w| {
        w.kind == ConflictKind::WriteWrite
            && on_shared(w)
            && w.earlier == Side::plain(0, Write)
            && w.later == Side::plain(1, Write)
    });
}

/// `tensormap.cp_fenceproxy` reads its shared source and writes its global destination, once for
/// the warp (thread 0): thread 32's unordered replaces of both, which run first, race the copy.
#[test]
fn test_cp_fenceproxy_races_another_warps_replace() {
    let ws = conflicts(
        &ptx!(parse "execution_error/cp_fenceproxy_races_another_warps_replace"),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert_any(&ws, "thread 32's replace, then the copy's read", |w| {
        w.kind == ConflictKind::WriteRead
            && on_shared(w)
            && w.earlier == Side::plain(32, Write)
            && w.later == Side::plain(0, Read)
    });
    assert_any(&ws, "thread 32's replace, then the copy's write", |w| {
        w.kind == ConflictKind::WriteWrite
            && w.location.space == Space::Global
            && w.earlier == Side::plain(32, Write)
            && w.later == Side::plain(0, Write)
    });
}

/// `tma_param_tensor_maps`'s launch: an 8x8 f32 `in` and `out`, their tensor
/// maps (8x4 boxes) at bytes 0 and 128 of the struct parameter.
fn tma_param_tensor_maps_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len: 64,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 64,
            kind: ArrayKind::Output,
        },
    ];

    let map = |offset: u64, name: &str| StructField {
        offset,
        value: FieldValue::TensorMap(Box::new(TensorMapValue {
            array: name.to_string(),
            elemtype: TensorElemType::F32,
            dims: vec![8, 8],
            strides: vec![32],
            mode: TensorMapMode::Tiled {
                box_dims: vec![8, 4],
            },
            element_strides: vec![1, 1],
            interleave: TensorInterleaveLayout::None,
            swizzle: TensorSwizzleMode::None,
            swizzle_atomicity: TensorSwizzleAtomicity::Atomicity16B,
            fill: TensorFillMode::Zero,
        })),
    };
    config.params = vec![ParamValue::Struct(vec![map(0, "in"), map(128, "out")])];
    config
}

/// Thread 0 stores to the tile its TMA store reads, without having waited for
/// that read: no `commit_group`, no `wait_group`, or a `wait_group.read 1`
/// that leaves the store's group pending.
#[test]
fn test_tma_store_tile_reuse_before_its_read_completes_races() {
    for module in [
        ptx!(parse "execution_error/tma_store_tile_reuse_without_commit_group_races"),
        ptx!(parse "execution_error/tma_store_tile_reuse_without_wait_group_races"),
        ptx!(parse "execution_error/tma_store_tile_reuse_after_wait_group_1_races"),
    ] {
        let ws = conflicts(&module, tma_param_tensor_maps_config());
        assert_any(&ws, "the TMA store's read and thread 0's tile store", |w| {
            w.kind == ConflictKind::ReadWrite
                && on_shared(w)
                && w.earlier == Side::effect(0, Read, AsyncOpKind::TensorStoreRead)
                && w.later == Side::plain(0, Write)
        });
    }
}
