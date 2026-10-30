//! End-to-end tests on well-formed, race-free kernels: each passes every
//! graph check, then its rendered symbolic outputs match the kernel's
//! `.out` file exactly, and any stats are checked.

#[macro_use]
mod common;

use volta_ptx_analysis::{
    AnalysisConfig, ArrayDef, ArrayKind, FieldValue, IntWidth, ParamValue, StructField,
    TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorMapMode, TensorMapValue,
    TensorSwizzleAtomicity, TensorSwizzleMode,
};

use common::*;

/// Output-only config: one `out` array of `len` `elem_width`-byte
/// elements, passed as the kernel's single parameter.
fn out_only_config(elem_width: u64, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width,
        len,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// Output-only config for a full 32-lane warp, storing `len`
/// `elem_width`-byte elements as the kernel's single parameter.
fn warp_out_config(elem_width: u64, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width,
        len,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// f16 input/output arrays alongside an f32 input (elem_width 2 out).
fn f32_in_f16_out_config(threads: u32, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

/// One-input/one-output f32 config over `in`/`out` (single thread).
fn one_elem_config() -> AnalysisConfig {
    in_out_config(1, 1)
}

/// f64 in/out config for the double-precision constant tests.
fn f64_out_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 8,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    config
}

/// Neighbor exchange through shared memory, correctly synchronized:
/// out[tid] = in[tid ^ 1].
#[test]
fn test_shared_exchange_with_barrier() {
    let output = analyze!("success/shared_exchange_with_barrier", in_out_config(2, 2));
    assert_eq!(output.stats.block_syncs, 2);
}

/// Unsynchronized accesses to the extern window and to a static `.shared`
/// variable from different threads are not a race: the regions are disjoint.
#[test]
fn test_extern_vs_static_shared_no_false_race() {
    let mut config = in_out_config(2, 1);
    config.dynamic_shared_bytes = 16;
    analyze!("success/extern_vs_static_shared_no_false_race", config);
}

/// A thread that exits counts as having arrived at the barrier (paper's
/// Sync rule allows `return`), so this does NOT deadlock.
#[test]
fn test_exited_thread_releases_barrier() {
    analyze!(
        "success/exited_thread_releases_barrier",
        AnalysisConfig::new((2, 1, 1))
    );
}

/// `failing/bar_arrive_twice_before_the_barrier_fires` with a handshake: warp 1
/// waits on barrier 2, which warp 0 arrives at once past its first `bar.sync`,
/// so each of warp 1's arrivals completes its own generation of barrier 1.
#[test]
fn test_bar_arrive_twice_with_a_handshake_between_generations() {
    analyze!(
        "success/bar_arrive_twice_with_a_handshake_between_generations",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// Accepted: lane 0, the only lane of its warp that has not exited, arrives at
/// `bar.arrive 1, 32` three times. A warp counts as 32 threads at a counted barrier, so each
/// arrival completes its own generation, and the arithmetic between them is unaffected.
#[test]
fn test_lone_lane_bar_arrives_complete_whole_warp_generations() {
    analyze!(
        "success/lone_lane_bar_arrives_complete_whole_warp_generations",
        in_out_config(32, 3)
    );
}

/// The control for `failing/bar_sync_register_id_count_mismatch`: a register id naming the
/// same count as the immediate one is accepted, and the barrier orders the exchange.
#[test]
fn test_bar_sync_register_id_count_matches() {
    analyze!(
        "success/bar_sync_register_id_count_matches",
        in_out_config(64, 1)
    );
}

/// A register thread count is resolved at eval: naming the same count as the immediate one,
/// the barrier orders the exchange.
#[test]
fn test_bar_sync_register_count_matches() {
    analyze!(
        "success/bar_sync_register_count_matches",
        in_out_config(64, 1)
    );
}

/// Barrier 1 (count 32, through a register id, twice) and barrier 0 (count 64) each keep
/// their own pinned count.
#[test]
fn test_bar_sync_register_ids_pin_one_count_per_id() {
    analyze!(
        "success/bar_sync_register_ids_pin_one_count_per_id",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// `mbarrier.init` with `count = 2` needs both threads' `arrive` before
/// `try_wait.parity` proceeds: the scheduler wakes a thread when a
/// *different* thread's arrive completes the phase.
#[test]
fn test_mbarrier_wait_wakes_on_another_threads_arrive() {
    analyze!(
        "success/mbarrier_wait_wakes_on_another_threads_arrive",
        in_out_config(2, 2)
    );
}

/// `mbarrier.arrive.expect_tx` + `mbarrier.complete_tx` end to end: the wait
/// is not satisfied by the arrival alone, only once `complete_tx` clears the
/// outstanding transaction.
#[test]
fn test_mbarrier_expect_tx_blocks_until_complete_tx() {
    analyze!(
        "success/mbarrier_expect_tx_blocks_until_complete_tx",
        in_out_config(1, 1)
    );
}

/// `mbarrier.arrive`/`try_wait.parity` is a χ happens-before edge (PTX ISA
/// 9.7.14.16.19): thread 0 writes then arrives, thread 1 waits then reads,
/// with no race reported. A `bar.sync` orders the init before the wait only.
#[test]
fn test_mbarrier_arrive_wait_establishes_happens_before() {
    analyze!(
        "success/mbarrier_arrive_wait_establishes_happens_before",
        in_out_config(2, 2)
    );
}

/// ThunderKittens' wait loop (`@P1 bra.uni DONE; bra.uni LAB_WAIT; DONE:`,
/// in a scoped inline-asm block) lowers to a blocking wait like nvcc's.
#[test]
fn test_mbarrier_wait_loop_with_an_exit_label() {
    analyze!(
        "success/mbarrier_wait_loop_with_an_exit_label",
        in_out_config(1, 1)
    );
}

/// A producer's first odd-parity wait on a fresh `empty` barrier returns
/// through its pre-init phase (the ISA's "immediately preceding phase"),
/// separated from the consumer's first arrival by the `full` handoff.
#[test]
fn test_mbarrier_producer_starts_through_the_pre_init_phase() {
    analyze!(
        "success/mbarrier_producer_starts_through_the_pre_init_phase",
        in_out_config(2, 2)
    );
}

/// The control for `inflight_complete_tx_lets_parity_wait_return_early`:
/// thread 1 observes the copy's phase 0 before its parity-1 wait.
#[test]
fn test_parity_1_wait_after_observing_the_copy_phase() {
    analyze!(
        "success/parity_1_wait_after_observing_the_copy_phase",
        in_out_config(2, 8)
    );
}

/// Two consumers wait on the same `full` phase and never synchronize with
/// each other: a phase's waiters need no order among themselves, only its
/// completion before their next wait, which each consumer's own release gives.
#[test]
fn test_mbarrier_two_consumers_wait_on_one_full_barrier() {
    analyze!(
        "success/mbarrier_two_consumers_wait_on_one_full_barrier",
        in_out_config(3, 4)
    );
}

/// `ld.shared.b128` of four separately stored 4-byte words reads them as the
/// `.b128` register's four 32-bit lanes, in address order.
#[test]
fn test_ld_shared_b128_reads_four_stored_words() {
    analyze!(
        "success/ld_shared_b128_reads_four_stored_words",
        in_out_config(1, 4)
    );
}

/// `tcgen05.fence::before_thread_sync`/`::after_thread_sync` parse (via the
/// `::`-glued trie fallback) and are pure ordering fences: eval just falls
/// through.
#[test]
fn test_tcgen05_fence_is_a_no_op() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/tcgen05_fence_is_a_no_op", config);
}

/// `tcgen05.commit`'s `.mbarrier::arrive::one` alone satisfies a `count = 1`
/// mbarrier's `try_wait.parity`; `.shared::cluster` covers the optional
/// state-space path.
#[test]
fn test_tcgen05_commit_satisfies_mbarrier_wait() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/tcgen05_commit_satisfies_mbarrier_wait", config);
}

/// `tcgen05.ld`/`.st` decode `taddr` as a Tensor Memory address (PTX ISA
/// 9.7.17.1.1: `[31:16]=lane, [15:0]=column`): two warps each pack their own
/// quadrant and read back exactly their own value.
#[test]
fn test_tcgen05_st_ld_respects_warp_quadrant_addressing() {
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 64,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/tcgen05_st_ld_respects_warp_quadrant_addressing",
        config
    );
}

/// Not a bug: a warp's `tcgen05.st` then `tcgen05.ld` of the same cells form an implicit
/// tcgen05 pipeline (PTX ISA 9.7.18.6.2), so the load reads each lane's stored `%tid.x` without a
/// `tcgen05.wait::st` in between.
#[test]
fn test_tcgen05_st_then_ld_is_implicitly_pipelined() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 256,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/tcgen05_st_then_ld_is_implicitly_pipelined", config);
}

/// Not a bug: reading a `tcgen05.ld` destination register before `tcgen05.wait::ld` is ordered
/// after the load by the true register dependency (PTX ISA 9.7.18.6.4.5).
#[test]
fn test_tcgen05_ld_result_ordered_by_register_dependency() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 256,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/tcgen05_ld_result_ordered_by_register_dependency",
        config
    );
}

/// The control for `tcgen05_alloc_sizes_unordered`: `bar.sync 1` orders warp 0's 64-column
/// allocation before warp 1's 32-column one.
#[test]
fn test_tcgen05_alloc_sizes_ordered_by_bar_sync_is_accepted() {
    analyze!(
        "success/tcgen05_alloc_sizes_ordered_by_bar_sync_is_accepted",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// The control for `tcgen05_alloc_orders_lanes_plain_accesses`: `bar.warp.sync` after the
/// alloc orders lane 1's store of `x` before lane 2's load, and the address write before every
/// lane's load of it.
#[test]
fn test_tcgen05_alloc_lanes_ordered_by_bar_warp_sync_is_accepted() {
    analyze!(
        "success/tcgen05_alloc_lanes_ordered_by_bar_warp_sync_is_accepted",
        warp_out_config(4, 1)
    );
}

/// The same allocation with nCols in a register, as TileLang passes it.
#[test]
fn test_tcgen05_alloc_register_column_count_is_accepted() {
    analyze!(
        "success/tcgen05_alloc_register_column_count_is_accepted",
        warp_out_config(4, 1)
    );
}

/// The control for `tcgen05_relinquish_unordered_with_other_warps_alloc`: `bar.sync 1` orders
/// warp 0's allocation before warp 1's `relinquish_alloc_permit`.
#[test]
fn test_tcgen05_relinquish_ordered_by_bar_sync_is_accepted() {
    analyze!(
        "success/tcgen05_relinquish_ordered_by_bar_sync_is_accepted",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// The control: the same `.ld`/`.st` waited *before* the arrivals pass.
#[test]
fn test_tcgen05_wait_before_sync_is_accepted() {
    analyze!(
        "success/tcgen05_wait_before_sync_is_accepted",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// The control: the same `.ld`/`.st` waited before the `tcgen05.dealloc`
/// pass.
#[test]
fn test_tcgen05_dealloc_after_waiting_is_accepted() {
    analyze!(
        "success/tcgen05_dealloc_after_waiting_is_accepted",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// `tensormap.replace` (8x8 f16 map built in shared) +
/// `cp.async.bulk.tensor`: a 4x4 box at (6, 6) reads input in bounds and
/// `fill_mode` zeros past `global_dim`; `complete_tx` unblocks the wait.
#[test]
fn test_cp_async_bulk_tensor_cta_and_cluster_destinations_copy_in_bounds() {
    for (scope, src) in [
        ptx_case!("success/cp_async_bulk_tensor_cta_and_cluster_destinations_copy_in_bounds"),
        ptx_case!("success/cp_async_bulk_tensor_cta_and_cluster_destinations_copy_in_bounds_cta"),
    ] {
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
        analyze_case(scope, &src, config);
    }
}

/// `elect.sync` elects the lowest *live* lane in the mask (PTX ISA
/// 9.7.14.15): with a full warp, lane 0 gets `dst = 0` and `dst_pred` true;
/// each thread encodes both as one f32.
#[test]
fn test_elect_sync_elects_the_lowest_active_lane() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 32,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/elect_sync_elects_the_lowest_active_lane", config);
}

/// Same shape, but lane 0 exits before `elect.sync`: exited lanes count as
/// arrived but cannot be leader, so lane 1 is elected.
#[test]
fn test_elect_sync_skips_an_already_exited_lane() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 32,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/elect_sync_skips_an_already_exited_lane", config);
}

/// `tcgen05.mma` with `triton_generated.ptx`'s exact `idesc`/descriptors
/// (`.kind::f16`, M=128, N=256, 128B swizzle) over uninitialized shared
/// buffers: every `(m, n, k)` address must land in bounds.
#[test]
fn test_tcgen05_mma_real_kernel_descriptors_run_to_completion() {
    analyze!(
        "success/tcgen05_mma_real_kernel_descriptors_run_to_completion",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// A synthetic `.kind::f16` `tcgen05.mma` (M=128, N=8) with
/// `SwizzleMode::None` K-major descriptors packed at 32 bytes/row reaches
/// `exec_tcgen05_mma`'s addressing end to end.
#[test]
fn test_tcgen05_mma_no_swizzle_mode_runs_to_completion() {
    analyze!(
        "success/tcgen05_mma_no_swizzle_mode_runs_to_completion",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// LLVM's NVPTX backend emits 5-operand `tcgen05.mma` with no
/// `disable-output-lane`, so the mask is optional (no lane disabled): like
/// `test_tcgen05_mma_numeric_correctness`, must produce `136`.
#[test]
fn test_tcgen05_mma_without_an_explicit_disable_output_lane_mask() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/tcgen05_mma_without_an_explicit_disable_output_lane_mask",
        config
    );
}

/// `tcgen05.mma` decodes concrete operands from their bits: `A`/`B` hold raw f16 `0x3C00` (1.0,
/// not 15360) and each warp seeds its quadrant of `D` with raw f32 1.0 via `tcgen05.st`, so
/// `D[0][0] = 16 + 1 = 17`. The `tcgen05` fences around `bar.sync` order the seeds before the MMA.
#[test]
fn test_tcgen05_mma_decodes_raw_operand_and_accumulator_bits() {
    let mut config = AnalysisConfig::new((128, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/tcgen05_mma_decodes_raw_operand_and_accumulator_bits",
        config
    );
}

/// Numeric check: `A[0][k] = k+1` and `B[k][0] = 1` as f16 at hand-computed
/// 128B-swizzled addresses (B transposed, crossing a stride atom at `k=8`);
/// `D[0][0]` must read back as `136`.
#[test]
fn test_tcgen05_mma_numeric_correctness() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/tcgen05_mma_numeric_correctness", config);
}

/// The control: a `bar.sync` *after* warp 0 observed the completion, then warp 1's
/// `tcgen05.fence::after_thread_sync`, orders the MMA before warp 1's read.
#[test]
fn test_tcgen05_mma_bar_sync_after_completion_orders_the_read() {
    analyze!(
        "success/tcgen05_mma_bar_sync_after_completion_orders_the_read",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// The control: warp 1 waiting on `mma_bar` itself, then executing
/// `tcgen05.fence::after_thread_sync`, is ordered after the MMA whatever
/// `bar.sync` ran before it.
#[test]
fn test_tcgen05_mma_every_reader_waiting_is_accepted() {
    analyze!(
        "success/tcgen05_mma_every_reader_waiting_is_accepted",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// The same kernel without `tcgen05.fence::after_thread_sync`: warp 1's default `.acquire` wait
/// on `mma_bar` pairs with the commit's release, which orders the MMA before its read
/// (<https://github.com/NVIDIA/cutlass/issues/2974>).
#[test]
fn test_tcgen05_mma_reader_after_an_acquire_wait_is_accepted() {
    analyze!(
        "success/tcgen05_mma_reader_after_an_acquire_wait_is_accepted",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// The control: deallocating after waiting on `mma_bar` is accepted.
#[test]
fn test_tcgen05_dealloc_after_the_mma_completed_is_accepted() {
    analyze!(
        "success/tcgen05_dealloc_after_the_mma_completed_is_accepted",
        AnalysisConfig::new((64, 1, 1))
    );
}

/// `.kind::f8f6f4` with e4m3 `A`, e5m2 `B`, K = 32, `SwizzleMode::None` (`LBO
/// = 128`): `D[0][0] = 136 + 2 * 136 = 408` holds only with 1-byte elements,
/// `LBO` stepping and per-operand decoders.
#[test]
fn test_tcgen05_mma_kind_f8f6f4_numeric_correctness() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/tcgen05_mma_kind_f8f6f4_numeric_correctness",
        config
    );
}

/// 2-byte accesses at addresses 2 mod 4 are *naturally aligned* (natural
/// alignment is relative to the access size, not any fixed width): the
/// ordinary f16 access pattern must keep working.
#[test]
fn test_aligned_u16_access_at_2_mod_4() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 4,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 2,
            len: 4,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!("success/aligned_u16_access_at_2_mod_4", config);
}

/// The same vector load at a 16-byte boundary is legal.
#[test]
fn test_aligned_vector_load() {
    analyze!("success/aligned_vector_load", in_out_config(1, 8));
}

/// A vector store's source list may mix immediates with registers (nvcc's
/// `{%f1, 0f00000000, %f2, 0f3F800000}` init idiom), unlike a vector load's
/// destination.
#[test]
fn test_vector_store_with_immediate_source() {
    let mut config = in_out_config(1, 8);
    config.arrays[1].len = 4; // out: exactly the 4 stored elements
    analyze!("success/vector_store_with_immediate_source", config);
}

// Full-warp ldmatrix.x4 kernels; each lane supplies the row address
// `sdata + tid*16 + extra` (lane i*8+r owns row r of matrix i).

/// ldmatrix row addresses are legal at 16-byte boundaries: each 8x8 b16
/// matrix row is fetched by four lanes as one 16-byte access.
#[test]
fn test_aligned_ldmatrix() {
    analyze!("success/aligned_ldmatrix", AnalysisConfig::new((32, 1, 1)));
}

/// `ldmatrix.trans.x1`: lane `l` gets (row `2*(l%4)`, col `l/4`) low and (row
/// `2*(l%4)+1`, col `l/4`) high, the transpose of the plain mapping.
#[test]
fn test_ldmatrix_trans_mapping() {
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
            len: 64,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!("success/ldmatrix_trans_mapping", config);
}

fn array(name: &str, base: u64, elem_width: u64, len: u64, kind: ArrayKind) -> ArrayDef {
    ArrayDef {
        name: name.to_string(),
        base,
        elem_width,
        len,
        kind,
    }
}

/// A by-value struct parameter (`.param .b8 args[32]`) read through its
/// address: a `v2.u64` load of its two pointers, a `u32` load of the low half
/// of its `u64` count, and a by-name `[args+8]`. Three of the four threads
/// pass the `tid < n` guard, so `out[0..3] = in[i] + 3` and `out[3]` stays unwritten.
#[test]
fn test_struct_param_by_address() {
    let mut config = AnalysisConfig::new((4, 1, 1));
    config.arrays = vec![
        array("in", 0x10000, 4, 4, ArrayKind::Input),
        array("out", 0x20000, 4, 4, ArrayKind::Output),
    ];
    let field = |offset, value| StructField { offset, value };
    config.params = vec![ParamValue::Struct(vec![
        field(0, FieldValue::ArrayPtr("in".to_string())),
        field(8, FieldValue::ArrayPtr("out".to_string())),
        field(
            16,
            FieldValue::Int {
                value: 3,
                width: IntWidth::W8,
            },
        ),
    ])];
    analyze!("success/struct_param_by_address", config);
}

/// `movmatrix.sync.aligned.m8n8.trans.b16` transposes the warp's 8x8 matrix:
/// out[j] = in[8(j%8) + j/8].
#[test]
fn test_movmatrix_transpose() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![
        array("in", 0x10000, 2, 64, ArrayKind::Input),
        array("out", 0x20000, 2, 64, ArrayKind::Output),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!("success/movmatrix_transpose", config);
}

/// `cvta.shared.u64` and `cvta.to.shared.u64` round-trip through the generic
/// shared window, and rounding the generic address up to 1024 bytes lands on
/// shared offset 1024, as in ThunderKittens' shared allocator.
#[test]
fn test_cvta_shared_round_trip() {
    analyze!("success/cvta_shared_round_trip", in_out_config(1, 4));
}

/// A host-encoded tensor map inside a struct parameter, reached through
/// `cvta.param`: a TMA load of `in`'s rows 2-5, copied out by the thread.
#[test]
fn test_tma_param_tensor_map_load() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        array("in", 0x10000, 4, 64, ArrayKind::Input),
        array("out", 0x20000, 4, 32, ArrayKind::Output),
    ];

    let map = TensorMapValue {
        array: "in".to_string(),
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
    };

    config.params = vec![ParamValue::Struct(vec![
        StructField {
            offset: 0,
            value: FieldValue::TensorMap(Box::new(map)),
        },
        StructField {
            offset: 128,
            value: FieldValue::ArrayPtr("out".to_string()),
        },
    ])];

    analyze!("success/tma_param_tensor_map_load", config);
}

/// Host-encoded tensor maps inside a struct parameter, reached through
/// `cvta.param`: a TMA load of `in`'s rows 2-5, then a TMA store of the tile to
/// `out`'s rows 0-3 in a bulk async-group whose source reads are waited for.
#[test]
fn test_tma_param_tensor_maps() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        array("in", 0x10000, 4, 64, ArrayKind::Input),
        array("out", 0x20000, 4, 64, ArrayKind::Output),
    ];
    let map = |name: &str| {
        FieldValue::TensorMap(Box::new(TensorMapValue {
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
        }))
    };
    config.params = vec![ParamValue::Struct(vec![
        StructField {
            offset: 0,
            value: map("in"),
        },
        StructField {
            offset: 128,
            value: map("out"),
        },
    ])];
    analyze!("success/tma_param_tensor_maps", config);
}

/// One thread over a 40-element f32 `in` and a 16-element f32 `out`, both
/// reached through 1-D tensor maps of 16-element boxes in one by-value struct.
fn tma_1d_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        array("in", 0x10000, 4, 40, ArrayKind::Input),
        array("out", 0x20000, 4, 16, ArrayKind::Output),
    ];
    let map = |name: &str, len: u64| {
        FieldValue::TensorMap(Box::new(TensorMapValue {
            array: name.to_string(),
            elemtype: TensorElemType::F32,
            dims: vec![len],
            strides: vec![],
            mode: TensorMapMode::Tiled { box_dims: vec![16] },
            element_strides: vec![1],
            interleave: TensorInterleaveLayout::None,
            swizzle: TensorSwizzleMode::None,
            swizzle_atomicity: TensorSwizzleAtomicity::Atomicity16B,
            fill: TensorFillMode::Zero,
        }))
    };
    config.params = vec![ParamValue::Struct(vec![
        StructField {
            offset: 0,
            value: map("in", 40),
        },
        StructField {
            offset: 128,
            value: map("out", 16),
        },
    ])];
    config
}

/// A 1-D TMA load of `in`'s 16 elements at element 32, the last 8 past its end
/// (zero-filled, yet counted by `complete_tx`), then a 1-D TMA store of the box:
/// out[0..7] = in[32..39], out[8..15] = 0.
#[test]
fn test_tma_1d_load_zero_fills_past_the_tensor_end() {
    analyze!(
        "success/tma_1d_load_zero_fills_past_the_tensor_end",
        tma_1d_config()
    );
}

/// `prefetch.tensormap` of both maps before the copies changes nothing.
#[test]
fn test_tma_load_after_prefetch_tensormap() {
    analyze!("success/tma_load_after_prefetch_tensormap", tma_1d_config());
}

/// A TMA load's `.L2::cache_hint` policy operand changes nothing.
#[test]
fn test_tma_load_with_l2_cache_hint() {
    analyze!("success/tma_load_with_l2_cache_hint", tma_1d_config());
}

/// The four f16 lanes of a `.b64` register, unpacked by shifts and truncations
/// or split into f16x2 words and repacked: out = in[3, 2, 1, 0, 6, 7, 4, 5].
#[test]
fn test_f16_lanes_of_a_vectorized_u64_load() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        array("in", 0x10000, 2, 8, ArrayKind::Input),
        array("out", 0x20000, 2, 8, ArrayKind::Output),
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!("success/f16_lanes_of_a_vectorized_u64_load", config);
}

/// Four integer-constant 16-bit lanes of a `.b64`, loaded or packed, combine into one number
/// that arithmetic reads and a 2-byte load splits again: out = 0x0004000300020001 + {16, 32},
/// then lane 2 of the packed number, 3.
#[test]
fn test_f16_constant_lanes_of_a_b64_are_a_number() {
    analyze!(
        "success/f16_constant_lanes_of_a_b64_are_a_number",
        out_only_config(8, 3)
    );
}

/// A 5-D TMA load of a 4x1x2x1x2 box of a 4x2x2x2x2 `in` at {0, 1, 0, 1, 0},
/// offset or iterated in every dimension, then a 5-D TMA store of it to `out`
/// at the same coordinates: out[i] = in[i] for i in 20-23, 28-31, 52-55, 60-63.
#[test]
fn test_tma_5d_load_and_store_stride_every_dimension() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        array("in", 0x10000, 4, 64, ArrayKind::Input),
        array("out", 0x20000, 4, 64, ArrayKind::Output),
    ];
    let map = |name: &str| {
        FieldValue::TensorMap(Box::new(TensorMapValue {
            array: name.to_string(),
            elemtype: TensorElemType::F32,
            dims: vec![4, 2, 2, 2, 2],
            strides: vec![16, 32, 64, 128],
            mode: TensorMapMode::Tiled {
                box_dims: vec![4, 1, 2, 1, 2],
            },
            element_strides: vec![1; 5],
            interleave: TensorInterleaveLayout::None,
            swizzle: TensorSwizzleMode::None,
            swizzle_atomicity: TensorSwizzleAtomicity::Atomicity16B,
            fill: TensorFillMode::Zero,
        }))
    };
    config.params = vec![ParamValue::Struct(vec![
        StructField {
            offset: 0,
            value: map("in"),
        },
        StructField {
            offset: 128,
            value: map("out"),
        },
    ])];
    analyze!(
        "success/tma_5d_load_and_store_stride_every_dimension",
        config
    );
}

/// The Gluon tutorial's GPU-checked multi-image im2col load: the 16-pixel column from
/// pixel (n, h, w) = (0, 1, 2) of a box spanning [-1, 2] reads image pixels 6, -, 8, 9,
/// 10, -, -, -, -, -, 16, 17, 18, -, 20, 21 (`-` zero-filled), as the tutorial's 7, 0, 9, ...
#[test]
fn test_tma_im2col_walk_wraps_into_the_next_image() {
    let config = im2col_config([4, 4, 4, 2], [1; 4], [-1, -1], [-1, -1], 16);
    analyze!("success/tma_im2col_walk_wraps_into_the_next_image", config);
}

/// Im2col offsets {w: 0, h: 1} shift every pixel read one row down from the walked filter
/// base: output pixel `p` reads image row `p / 4`, column `p % 4 - 1` (zero-filled at -1).
#[test]
fn test_tma_im2col_offsets_shift_the_pixel_read() {
    let config = im2col_config([4, 4, 4, 1], [1; 4], [-1, -1], [-1, -1], 16);
    analyze!("success/tma_im2col_offsets_shift_the_pixel_read", config);
}

/// Traversal stride 2 in W and H over a box spanning W in [0, 2], H in [0, 1]: the column
/// reads image pixels 0, 2, 16, 18 and zero-fills the two pixels past the last image.
#[test]
fn test_tma_im2col_strided_walk_runs_past_the_last_image() {
    let config = im2col_config([4, 4, 4, 2], [1, 2, 2, 1], [0, 0], [-1, -2], 6);
    analyze!(
        "success/tma_im2col_strided_walk_runs_past_the_last_image",
        config
    );
}

/// A concrete `mul.hi.u64` is the exact high half of the 128-bit product.
#[test]
fn test_mul_hi_u64_concrete() {
    analyze!("success/mul_hi_u64_concrete", out_only_config(4, 1));
}

/// `mma.sync...f32.bf16.bf16.f32` shares f16's m16n8k16 fragments.
#[test]
fn test_mma_bf16() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![
        array("a", 0x10000, 2, 256, ArrayKind::Input),
        array("b", 0x20000, 2, 128, ArrayKind::Input),
        array("out", 0x30000, 4, 4, ArrayKind::Output),
    ];
    config.params = ["a", "b", "out"]
        .map(|name| ParamValue::ArrayPtr(name.to_string()))
        .to_vec();
    analyze!("success/mma_bf16", config);
}

/// `mma.sync`'s accumulator may be an immediate (nvcc's `{0f00000000, ...}`
/// first-tile idiom): with all-zero packed A/B, `D = C`, so thread 0's
/// registers get the literal `{1.0, 0, 0, 0}`.
#[test]
fn test_mma_with_immediate_accumulator() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 128,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/mma_with_immediate_accumulator", config);
}

/// An `mma.sync` f32 accumulator holding a raw bit pattern (`mov.b32`) is
/// decoded as f32 bits: thread 0's `D[0][0]` is 1.0, not 1065353216.
#[test]
fn test_mma_accumulator_register_decodes_raw_bits() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 128,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/mma_accumulator_register_decodes_raw_bits", config);
}

// Full-warp wmma.load.a / wmma.store.d kernels with base `sdata + extra`
// and a stride in f16 (load) or f32 (store) elements.

/// wmma with a 32-byte-aligned base and the default stride (16 elements)
/// is legal, for both the f16 a-fragment load and the f32 d-fragment store.
#[test]
fn test_aligned_wmma_load_and_store() {
    analyze!(
        "success/aligned_wmma_load_and_store_load",
        AnalysisConfig::new((32, 1, 1))
    );

    analyze!(
        "success/aligned_wmma_load_and_store_store",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// A stride *larger* than the default is explicitly allowed (a submatrix
/// of a larger matrix) as long as it keeps rows aligned.
#[test]
fn test_wmma_stride_above_default_is_legal() {
    analyze!(
        "success/wmma_stride_above_default_is_legal",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// nvcc's bank-conflict skew (`half tile[..][16 + 8]`, Conv2D-opt) gives a
/// 48-byte stride: not a multiple of the 32-byte fragment but 16-byte
/// aligned, which must stay legal.
#[test]
fn test_wmma_skewed_stride_is_legal() {
    analyze!(
        "success/wmma_skewed_stride_is_legal",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// nvcc's u16 magic-number division (Conv2D-opt): the immediate -17873 is u16
/// 47663 = ceil(2^19/11), so `mul.wide.u16` operands are reinterpreted as
/// unsigned.
#[test]
fn test_mul_wide_u16_magic_division() {
    analyze!("success/mul_wide_u16_magic_division", in_out_config(1, 2));
}

/// `mul.hi.u32` must zero-extend a canonically-signed operand: the high
/// half of 0xFFFFFFFF * 2 is 1, not -1's sign fill.
#[test]
fn test_mul_hi_u32_negative_operand() {
    analyze!("success/mul_hi_u32_negative_operand", in_out_config(1, 1));
}

/// `shf`'s shift amount is `.u32`: `-1` is 0xFFFFFFFF, which `.clamp`
/// saturates to 32 (left gives `lo`, right `hi`) - not 0; `.wrap` takes the
/// low 5 bits, i.e. 31.
#[test]
fn test_shf_clamp_negative_shift_amount_saturates() {
    analyze!(
        "success/shf_clamp_negative_shift_amount_saturates",
        in_out_config(1, 4)
    );
}

/// A shift's amount is `.u32` for every operand type, so a `.b16` shift
/// by 0x10000 is over-wide (>= 16), not a shift by 0x10000 & 0xFFFF = 0.
#[test]
fn test_b16_shift_amount_is_read_as_u32() {
    analyze!(
        "success/b16_shift_amount_is_read_as_u32",
        in_out_config(1, 3)
    );
}

/// Integer `abs` re-reads a concrete operand at its signed width: 0xFFFFFFFB
/// is -5 to `abs.s32`, and the result wraps (`abs.s32` of i32::MIN is
/// i32::MIN).
#[test]
fn test_int_abs_read_at_signed_width() {
    analyze!("success/int_abs_read_at_signed_width", in_out_config(1, 2));
}

/// `abs.f32` decodes a raw bit pattern first: 0xC0A00000 (-5.0) gives 5.0 and
/// 0xFF800000 (-inf) gives inf. A symbolic operand stays an `abs` node.
#[test]
fn test_float_abs_decodes_raw_bits() {
    analyze!("success/float_abs_decodes_raw_bits", in_out_config(1, 3));
}

/// Every float consumer decodes a raw `mov.b32`/`mov.b16` bit pattern
/// (0x3F800000 is 1.0): `fma`, `rcp`/`sqrt`, both `copysign` operands, and
/// float-to-float `cvt` (f16 0x3C00).
#[test]
fn test_float_ops_decode_raw_bit_patterns() {
    analyze!(
        "success/float_ops_decode_raw_bit_patterns",
        in_out_config(1, 6)
    );
}

/// Mixed precision `fma.rn.f32.f16` decodes its multiplicands as f16 bits
/// and only its accumulator as f32 bits: `0x3C00 * 0x4000 + 0x3F800000`
/// is `1 * 2 + 1 = 3`.
#[test]
fn test_mixed_precision_fma_decodes_multiplicands_at_their_own_type() {
    analyze!(
        "success/mixed_precision_fma_decodes_multiplicands_at_their_own_type",
        in_out_config(1, 1)
    );
}

/// `neg` re-reads a concrete operand as its type: 0xFFFFFFFB is -5 to
/// `neg.s32` (i32::MIN wraps to itself); `neg.f32` decodes raw bits
/// (0xC0A00000 is -5.0). Symbolic stays a `neg` node.
#[test]
fn test_neg_reads_operand_as_instruction_type() {
    analyze!(
        "success/neg_reads_operand_as_instruction_type",
        in_out_config(1, 5)
    );
}

/// `shl.b64`/`shr.b64` take their shift amount in a `.u32` register, as
/// the ISA types it - not rejected as a width mismatch against `.b64`.
#[test]
fn test_b64_shift_by_u32_register() {
    let mut config = in_out_config(1, 2);
    for array in &mut config.arrays {
        array.elem_width = 8;
    }
    analyze!("success/b64_shift_by_u32_register", config);
}

/// A constant operand of add/sub/mul only matters mod 2^N, so the
/// instruction's signedness must not change it: `add.s32 x, -1` and
/// `add.u32 x, -1` are the same op, and `-1` stays `-1` under `.u32`.
#[test]
fn test_ring_op_constant_signedness_is_irrelevant() {
    let kernel = |name: &'static str, src: String| analyze_case(name, &src, in_out_config(1, 1));
    for ((signed, signed_src), (unsigned, unsigned_src)) in [
        (
            ptx_case!("success/ring_op_constant_signedness_is_irrelevant_add_s32_neg1"),
            ptx_case!("success/ring_op_constant_signedness_is_irrelevant_add_u32_neg1"),
        ),
        (
            ptx_case!("success/ring_op_constant_signedness_is_irrelevant_sub_s32_neg7"),
            ptx_case!("success/ring_op_constant_signedness_is_irrelevant_sub_u32_neg7"),
        ),
        (
            ptx_case!("success/ring_op_constant_signedness_is_irrelevant_mul_lo_s32_neg3"),
            ptx_case!("success/ring_op_constant_signedness_is_irrelevant_mul_lo_u32_neg3"),
        ),
    ] {
        assert_eq!(
            render_outputs(&kernel(signed, signed_src)),
            render_outputs(&kernel(unsigned, unsigned_src)),
            "`{signed}` vs `{unsigned}`"
        );
    }

    let (name, src) = ptx_case!("success/ring_op_constant_signedness_is_irrelevant_sub_u32_1");
    kernel(name, src);
}

#[test]
fn test_bfe_extract_and_sign_fill() {
    analyze!("success/bfe_extract_and_sign_fill", out_only_config(4, 4));
}

#[test]
fn test_bfi_clips_field_to_register_width() {
    analyze!(
        "success/bfi_clips_field_to_register_width",
        out_only_config(4, 4)
    );
}

#[test]
fn test_mov_vector_destination_unpack_values() {
    analyze!(
        "success/mov_vector_destination_unpack_values",
        out_only_config(2, 2)
    );
}

#[test]
fn test_cvt_pack_halves_values() {
    // cvt.rn.f16x2.f32 d, a, b: `a` goes to the *high* half and `b` to the
    // *low* (opposite mov.b32's brace order); also exercises storing a Pair and
    // reading its 2-byte granules back.
    analyze!("success/cvt_pack_halves_values", out_only_config(2, 2));
}

#[test]
fn test_mov_unpack_native_pair_source() {
    // `ld.global.b32` over a 2-byte array yields a `Value::Pair`; `mov.b32
    // {lo,hi}` must split its real halves directly, not bit-mask an opaque
    // integer (nvcc/Triton's f16 idiom).
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 2,
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
    analyze!("success/mov_unpack_native_pair_source", config);
}

#[test]
fn test_mov_pack_b32_always_builds_pair() {
    // The mirror image: `mov.b32 dst, {lo, hi}` always writes `Value::Pair(lo,
    // hi)`, not bit-packing, so packed f16 or integer halves round-trip exactly
    // through memory.
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 2,
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
    analyze!("success/mov_pack_b32_always_builds_pair", config);
}

/// `prmt.b32 0x5410` of two f16x2 pairs takes each pair's low half whole.
#[test]
fn test_f16x2_pair_halves_interleaved_by_prmt() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 4,
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
    analyze!("success/f16x2_pair_halves_interleaved_by_prmt", config);
}

/// A logical shift by 16 takes an f16x2 pair's high half, a 16-bit store its low half.
#[test]
fn test_f16x2_pair_halves_split_by_shift_and_store() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 2,
            len: 2,
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
    analyze!("success/f16x2_pair_halves_split_by_shift_and_store", config);
}

/// `mov.b64 dst, {lo, hi}` with concrete 32-bit integer halves yields the
/// exact 64-bit integer: the `Value::Pair` is recombined when consumed as a
/// scalar (here, the u64 output).
#[test]
fn test_mov_pack_b64_integer_halves_recombine() {
    analyze!(
        "success/mov_pack_b64_integer_halves_recombine",
        out_only_config(8, 1)
    );
}

/// Value-boundary canonicalization: `mov.u32 %r, -1` and `not.b32 %r, 0` hold
/// the same hardware value, so both kernels must export the same canonical
/// constant.
#[test]
fn test_mov_neg1_vs_not_zero() {
    let a = analyze!("success/mov_neg1_vs_not_zero", out_only_config(4, 1));
    let b = analyze!("success/mov_neg1_vs_not_zero_2", out_only_config(4, 1));
    assert_eq!(render_outputs(&a), render_outputs(&b));
}

/// Value-boundary canonicalization at setp/selp: `-1` and a computed
/// 4294967295 are reinterpreted at the instruction type, so both build
/// identical comparison and select nodes.
#[test]
fn test_setp_selp_canonicalize_operands() {
    let a = analyze!(
        "success/setp_selp_canonicalize_operands",
        in_out_config(1, 1)
    );
    let b = analyze!(
        "success/setp_selp_canonicalize_operands_2",
        in_out_config(1, 1)
    );
    assert_eq!(render_outputs(&a), render_outputs(&b));
}

/// `st.u8` keeps only the low byte of the stored value (hardware chops
/// 300 to 44); `ld.u8` zero-extends it back.
#[test]
fn test_store_u8_truncates_to_low_bits() {
    analyze!(
        "success/store_u8_truncates_to_low_bits",
        u8_scratch_config()
    );
}

/// `ld.s8` sign-extends: byte 0xFF reads as -1, and storing it at 32 bits
/// exports the canonical 4294967295, the same constant as storing -1
/// directly.
#[test]
fn test_load_s8_sign_extends() {
    let a = analyze!("success/load_s8_sign_extends", u8_scratch_config());
    let b = analyze!("success/load_s8_sign_extends_2", u8_scratch_config());
    assert_eq!(render_outputs(&a), render_outputs(&b));
}

/// cvt reads its source at the *source* format (ISA Table 15): `cvt.s64.s32`
/// of an `and.b32` result 4294967288 widens -8, and `cvt.u64.u32` of
/// `sub.s32`'s -8 widens 4294967288.
#[test]
fn test_cvt_reinterprets_at_source_format() {
    analyze!(
        "success/cvt_reinterprets_at_source_format",
        out_only_config(8, 2)
    );
}

/// A bits-type or unsigned sub-register symbolic load needs no extension
/// node: zero-extension is the identity on the number (PTX's rule for
/// `.b8`/`.u8` loads too).
#[test]
fn test_unsigned_sub_register_load_passes_through() {
    analyze!(
        "success/unsigned_sub_register_load_passes_through",
        u8_scratch_config()
    );
}

/// LLVM's NVPTX fp8 idiom (`RoPEFloat8Kernel`): a byte loaded into a 16-bit
/// register feeds `cvt.rn.f16x2.e4m3x2`; the low lane is the element's real
/// value and the discarded high lane stays `Undefined`.
#[test]
fn test_e4m3x2_scalar_source_from_a_zero_extended_byte_load() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 1,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 1,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!(
        "success/e4m3x2_scalar_source_from_a_zero_extended_byte_load",
        config
    );
}

/// The `__symexpf` callseq idiom becomes symbolic exp.
#[test]
fn test_symexpf_callseq() {
    analyze!("success/symexpf_callseq", in_out_config(1, 1));
}

/// `tanh.approx.f32` is `(e^2x - 1) / (e^2x + 1)`, staying in the exp
/// fragment (like `Ex2`) instead of an opaque atom: it displays in that form
/// and folds to zero at 0.
#[test]
fn test_tanh_approx_expands_to_exp_fragment() {
    analyze!(
        "success/tanh_approx_expands_to_exp_fragment",
        in_out_config(1, 1)
    );
}

/// `tanh(0)` stays `(exp(0) - 1) / (exp(0) + 1)`: `exp(0)` is not folded to
/// `1` at construction, so it does not collapse to the literal `0`.
#[test]
fn test_tanh_approx_zero_vs_zero() {
    analyze!("success/tanh_approx_zero_vs_zero", out_only_config(4, 1));
    analyze!("success/tanh_approx_zero_vs_zero_2", out_only_config(4, 1));
}

/// shfl.sync.idx exchanges lane values (2 lanes, mask 0x3):
/// out[tid] = in[tid ^ 1].
#[test]
fn test_shfl_sync_idx_exchange() {
    let output = analyze!("success/shfl_sync_idx_exchange", in_out_config(2, 2));
    // Warp syncs count once per fired group.
    assert_eq!(output.stats.warp_syncs, 1);
}

/// Float `.sat` clamps the result to [0, 1]; concrete operands fold all
/// the way to the clamped constant.
#[test]
fn test_add_sat_f32_concrete_clamps() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/add_sat_f32_concrete_clamps", config);
}

/// nvcc's fused-ReLU epilogue `cvt.rn.relu.f16.f32` is the exact value
/// transformation max(x, 0) on a symbolic input.
#[test]
fn test_cvt_relu_symbolic_is_max() {
    analyze!(
        "success/cvt_relu_symbolic_is_max",
        f32_in_f16_out_config(1, 1)
    );
}

/// ReLU via the fused cvt epilogue builds `max(x, 0)`; an explicit max.f32
/// against zero (with flipped operand order) builds `max(0, x)`.
#[test]
fn test_relu_epilogue_vs_explicit_max() {
    analyze!(
        "success/relu_epilogue_vs_explicit_max_fused",
        f32_in_f16_out_config(2, 2)
    );
    analyze!(
        "success/relu_epilogue_vs_explicit_max_explicit",
        f32_in_f16_out_config(2, 2)
    );
}

/// `div.rn.f32 d, 1.0, 3.0` and `rcp.approx.f32 d, 3.0` fold to the same
/// exact rational 1/3.
#[test]
fn test_div_by_three_vs_rcp_of_three() {
    let a = analyze!("success/div_by_three_vs_rcp_of_three", one_elem_config());
    let b = analyze!("success/div_by_three_vs_rcp_of_three_2", one_elem_config());
    assert_eq!(render_outputs(&a), render_outputs(&b));
}

/// `sum / N` vs the strength-reduced `t = 1.0 / N; sum * t` at concrete
/// N = 768: 1/768 is not dyadic, so the old fold rounded `t` to fl(1/768);
/// the exact fold keeps `t` as the rational 1/768.
#[test]
fn test_div_by_n_vs_mul_by_computed_reciprocal() {
    analyze!(
        "success/div_by_n_vs_mul_by_computed_reciprocal",
        one_elem_config()
    );
    analyze!(
        "success/div_by_n_vs_mul_by_computed_reciprocal_2",
        one_elem_config()
    );
}

/// Concrete fma folds exactly as mul-then-add: one algebra, no fused
/// rounding (the old f64 folds could disagree between the two spellings).
#[test]
fn test_concrete_fma_vs_mul_add() {
    let a = analyze!("success/concrete_fma_vs_mul_add", f64_out_config());
    let b = analyze!("success/concrete_fma_vs_mul_add_2", f64_out_config());
    assert_eq!(render_outputs(&a), render_outputs(&b));
}

/// Model-faithful: 0.1 + 0.2 computed at runtime is the exact rational sum,
/// NOT the pre-rounded f64 literal 0d3FD3333333333334 the hardware would
/// produce.
#[test]
fn test_runtime_sum_differs_from_prerounded_literal() {
    analyze!(
        "success/runtime_sum_differs_from_prerounded_literal",
        f64_out_config()
    );
    analyze!(
        "success/runtime_sum_differs_from_prerounded_literal_2",
        f64_out_config()
    );
}

/// Tail-exit warp reduction: lanes 16..31 exit and the survivors run a
/// full-mask `shfl.sync.down` tree; exited lanes count as arrived (paper's
/// Sync rule, and the ISA's), so it sums in[0..16].
#[test]
fn test_tail_exit_warp_shfl_reduction() {
    let a = analyze!(
        "success/tail_exit_warp_shfl_reduction",
        in_out_config(32, 16)
    );
    assert_eq!(a.stats.warp_syncs, 4);

    // Reference: one thread sums in[0..16] sequentially.
    analyze!(
        "success/tail_exit_warp_shfl_reduction_reference",
        in_out_config(1, 16)
    );
}

/// bar.warp.sync end-to-end (previously UnsupportedInstruction at
/// lowering): the neighbor exchange synchronized by a warp barrier instead
/// of a CTA barrier.
#[test]
fn test_bar_warp_sync_neighbor_exchange() {
    let output = analyze!(
        "success/bar_warp_sync_neighbor_exchange",
        in_out_config(2, 2)
    );
    assert_eq!(output.stats.block_syncs, 0);
    assert_eq!(output.stats.warp_syncs, 1);
}

/// `barrier.sync{.aligned} a` (no thread count) is the same full-CTA
/// barrier as `bar.sync a` (ISA: "bar{.cta}.sync is equivalent to
/// barrier{.cta}.sync.aligned").
#[test]
fn test_barrier_sync_is_bar_sync() {
    for (form, src) in [
        ptx_case!("success/barrier_sync_is_bar_sync"),
        ptx_case!("success/barrier_sync_is_bar_sync_cta_aligned"),
    ] {
        let output = analyze_case(form, &src, in_out_config(2, 2));
        assert_eq!(output.stats.block_syncs, 2);
    }
}

/// Without `.aligned`, a warp may reach a barrier from two instructions: lanes 0-15 and 16-31 at
/// two `barrier.sync 0` complete one barrier, which orders thread 0's store before thread 20's
/// load.
#[test]
fn test_unaligned_barrier_sync_split_across_two_instructions_in_one_warp() {
    analyze!(
        "success/unaligned_barrier_sync_split_across_two_instructions_in_one_warp",
        AnalysisConfig::new((32, 1, 1))
    );
}

/// Aligned in-bounds accesses at region edges still pass: a shared array's
/// last scalar element (adjacent array following) and an exact-fit v4 ending
/// at the region end.
#[test]
fn test_region_edge_exact_fit_accesses_pass() {
    analyze!(
        "success/region_edge_exact_fit_accesses_pass",
        in_out_config(1, 2)
    );
}

/// An array at 0x7FFF_FFFF_FFFF_FFF0: the +16 access crosses the i64 sign
/// boundary without u64 wrap. Addresses are u64 mod 2^64 (as on hardware), so
/// this is in bounds.
#[test]
fn test_upper_half_address_space_access_in_bounds() {
    let mut config = in_out_config(1, 8);
    config.arrays[0].base = 0x7FFF_FFFF_FFFF_FFF0;
    analyze!("success/upper_half_address_space_access_in_bounds", config);
}

/// The corpus's one cvta form is accepted as the identity.
#[test]
fn test_cvta_to_global_accepted() {
    analyze!("success/cvta_to_global_accepted", in_out_config(1, 1));
}

/// The happy path: `cp.async` + `commit_group` + `wait_group 0` correctly
/// deposits the source value into shared memory, readable once waited on.
#[test]
fn test_cp_async_wait_group_completes_copy() {
    analyze!(
        "success/cp_async_wait_group_completes_copy",
        in_out_config(1, 1)
    );
}

/// Same as above, but with the required `bar.sync` between thread 0's
/// `wait_group` and thread 1's read: this must succeed, confirming the
/// race in the previous test is exactly about the missing synchronization.
#[test]
fn test_cp_async_post_wait_cross_thread_read_with_sync_succeeds() {
    analyze!(
        "success/cp_async_post_wait_cross_thread_read_with_sync_succeeds",
        in_out_config(2, 1)
    );
}

/// `cp.async` -> `wait_group` -> `ld.shared` with no fence:
/// `cp.async` is a generic-proxy op (PTX ISA 9.7.10.28.3), so no
/// `fence.proxy.async` is needed.
#[test]
fn test_cp_async_without_fence_proxy_async_is_clean() {
    analyze!(
        "success/cp_async_without_fence_proxy_async_is_clean",
        in_out_config(1, 1)
    );
}

/// Same kernel with a (redundant)
/// `fence.proxy.async.shared::cta;` between `wait_group` and the read -
/// must pass clean too.
#[test]
fn test_cp_async_with_fence_proxy_async_succeeds() {
    analyze!(
        "success/cp_async_with_fence_proxy_async_succeeds",
        in_out_config(1, 1)
    );
}

/// Regression guard for a real astra2 MatrixVectorMultiplicationFloat16
/// kernel: `cp.async`, `wait_group`, `bar.sync`, cross-thread read, no fence;
/// `cp.async` is generic-proxy, so it must never be flagged.
#[test]
fn test_cp_async_cross_thread_pattern_without_fence_is_clean() {
    analyze!(
        "success/cp_async_cross_thread_pattern_without_fence_is_clean",
        in_out_config(2, 1)
    );
}

/// TMA's async-proxy write needs no `fence.proxy.async` either: the
/// completion carries an implicit proxy fence (PTX ISA 9.7.9.25.2). Same body
/// as the bulk-tensor test.
#[test]
fn test_cp_async_bulk_tensor_without_fence_proxy_async_is_clean() {
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
    analyze!(
        "success/cp_async_bulk_tensor_without_fence_proxy_async_is_clean",
        config
    );
}

/// The control for `tma_uses_tensormap_built_by_other_thread_without_sync`: `bar.sync` orders
/// thread 0's release of the tensor map before thread 32's acquire.
#[test]
fn test_tma_tensormap_built_by_other_thread_ordered_by_bar_sync_is_accepted() {
    analyze!(
        "success/tma_tensormap_built_by_other_thread_ordered_by_bar_sync_is_accepted",
        tma_config(64)
    );
}

/// The control for `tma_uses_another_warps_cp_fenceproxy_copy_without_sync`: `bar.sync` orders
/// warp 0's copy and release of the tensor map before thread 32's acquire, as the B200 matmul
/// kernel does.
#[test]
fn test_tma_uses_another_warps_cp_fenceproxy_copy_ordered_by_bar_sync_is_accepted() {
    analyze!(
        "success/tma_uses_another_warps_cp_fenceproxy_copy_ordered_by_bar_sync_is_accepted",
        tma_config(64)
    );
}

/// The control for `tensormap_replace_while_tma_in_flight`, and the PTX ISA's own pattern for
/// a tensor map modified in global memory: replace, release, acquire, copy, and the rewrite
/// only once the copy's completion is observed.
#[test]
fn test_tensormap_replace_after_tma_completes_is_accepted() {
    analyze!(
        "success/tensormap_replace_after_tma_completes_is_accepted",
        tma_config(32)
    );
}

/// The control: a `bar.sync` *after* warp 0 observed the completion does
/// order the copy before warp 1's read.
#[test]
fn test_cp_async_bulk_bar_sync_after_completion_orders_the_read() {
    analyze!(
        "success/cp_async_bulk_bar_sync_after_completion_orders_the_read",
        bulk_copy_config()
    );
}

/// The control: every reader waiting on `full` itself is ordered after the
/// copy, whatever `bar.sync` ran before it.
#[test]
fn test_cp_async_bulk_every_reader_waiting_is_accepted() {
    analyze!(
        "success/cp_async_bulk_every_reader_waiting_is_accepted",
        bulk_copy_config()
    );
}

/// The control for `bulk_copy_complete_tx_lands_in_earlier_phase`: the copy for
/// phase 1 is issued after the parity-0 wait.
#[test]
fn test_bulk_copy_issued_after_the_previous_phase_completes() {
    analyze!(
        "success/bulk_copy_issued_after_the_previous_phase_completes",
        in_out_config(1, 8)
    );
}

/// `stmatrix.x1.m8n8.shared.b16`: lane `l`'s value lands at `row_addr[l/4] +
/// (l%4)*4`, a bijection onto the 128 bytes; lane 5's value is read back at
/// `src+20`.
#[test]
fn test_stmatrix_writes_the_expected_byte_per_lane() {
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!("success/stmatrix_writes_the_expected_byte_per_lane", config);
}

/// `out[i] = in[i] * in[i] + in[i]` over two threads, two f32 elements each:
/// the scalar form of the lane math the `f32x2` kernels below compute.
#[test]
fn test_f32x2_scalar_reference() {
    analyze!("success/f32x2_scalar_reference", in_out_config(2, 4));
}

/// `mov.b64 %rd, {%f_lo, %f_hi}` packs two f32 registers, `fma.rn.f32x2`
/// works per lane, `mov.b64 {%f_lo, %f_hi}, %rd` unpacks the result.
#[test]
fn test_f32x2_fma_via_register_pack() {
    analyze!("success/f32x2_fma_via_register_pack", in_out_config(2, 4));
}

/// `mul.f32x2` then `add.f32x2`, the unfused form of the lane math.
#[test]
fn test_f32x2_mul_add_via_register_pack() {
    analyze!(
        "success/f32x2_mul_add_via_register_pack",
        in_out_config(2, 4)
    );
}

/// A 64-bit load over two adjacent f32 inputs yields the pair directly,
/// and a 64-bit store of the pair writes both output elements.
#[test]
fn test_f32x2_fma_via_64bit_memory_access() {
    analyze!(
        "success/f32x2_fma_via_64bit_memory_access",
        in_out_config(2, 4)
    );
}

/// A concrete 64-bit pattern used as an f32x2 operand decodes into its two
/// lanes (1.0f each); the point is that the constant lanes read correctly.
#[test]
fn test_f32x2_constant_bit_pattern_operand() {
    analyze!(
        "success/f32x2_constant_bit_pattern_operand",
        in_out_config(2, 4)
    );
}

/// The f32x2 lane math with the addend dropped.
#[test]
fn test_f32x2_wrong_lane_math() {
    analyze!("success/f32x2_wrong_lane_math", in_out_config(2, 4));
}

/// `mov.b64 %rd, {%r_lo, %r_hi}` with concrete integer halves still builds
/// the 64-bit integer (here a byte offset of 8) when read as a scalar.
#[test]
fn test_mov_b64_integer_pack_recombines_as_scalar() {
    let a = analyze!(
        "success/mov_b64_integer_pack_recombines_as_scalar_packed",
        in_out_config(1, 4)
    );
    let b = analyze!(
        "success/mov_b64_integer_pack_recombines_as_scalar_direct",
        in_out_config(1, 4)
    );
    assert_eq!(render_outputs(&a), render_outputs(&b));
}

/// nvcc/Triton's own way of building an `f32x2` operand: two 32-bit loads
/// zero-extended into 64-bit registers, `shl.b64` by 32 and `or.b64` to
/// place them in the two lanes (with an `and.b64` lane mask thrown in).
#[test]
fn test_f32x2_operand_assembled_with_shift_and_or() {
    analyze!(
        "success/f32x2_operand_assembled_with_shift_and_or",
        in_out_config(2, 4)
    );
}

/// `shr.u64` by 32 moves the high lane down; the low lane is then read
/// through a 64-bit-to-32-bit unpack.
#[test]
fn test_f32x2_lane_extracted_with_shift() {
    analyze!(
        "success/f32x2_lane_extracted_with_shift",
        in_out_config(2, 4)
    );
}

/// `cvt.u64.u32` zero-extension is the other way nvcc/Triton feed one f32
/// into an `f32x2` lane, and `cvt.u32.u64` truncation reads a lane back.
#[test]
fn test_f32x2_operand_assembled_with_cvt_zero_extension() {
    analyze!(
        "success/f32x2_operand_assembled_with_cvt_zero_extension",
        in_out_config(2, 4)
    );
}

/// A concrete 32-bit word in shared memory (here the zero a `cp.async`
/// zero-fill or a plain store leaves behind) can be overwritten and read
/// back one 16-bit half at a time: its halves are known bit patterns.
#[test]
fn test_concrete_scalar_granule_splits_for_half_width_access() {
    analyze!(
        "success/concrete_scalar_granule_splits_for_half_width_access",
        in_out_config(1, 1)
    );
}

/// `copysign.type d, a, b` (PTX ISA): `d = |b|` with `a`'s sign - opposite of
/// a naive operand reading. Pins all four sign combinations and the
/// `copysign.f32 %v0, %x0, %v0` reuse idiom.
#[test]
fn test_copysign_combines_the_sign_of_a_with_the_magnitude_of_b() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/copysign_combines_the_sign_of_a_with_the_magnitude_of_b",
        config
    );
}

/// The fp8-elementwise idiom: `ld.global.v2.b32` (a `Value::Quad`) ->
/// `mov.b32 {h,h}` -> `cvt.rn.f16x2.e4m3x2` is the identity over symbolic
/// reals: `x[0]`..`x[3]` stay distinct.
#[test]
fn test_e4m3x2_vector_load_keeps_four_symbolic_bytes_independent() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 8,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 4,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!(
        "success/e4m3x2_vector_load_keeps_four_symbolic_bytes_independent",
        config
    );
}

/// LLVM's NVPTX backend extracts a `Quad` register's low 16 bits via
/// `cvt.u16.u32` (`GELUFloat8Kernel`); like `truncates_pair`, this must keep
/// the low `Pair` of byte lanes.
#[test]
fn test_e4m3x2_low_half_extracted_via_cvt_u16_u32_truncation_of_a_quad() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 4,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!(
        "success/e4m3x2_low_half_extracted_via_cvt_u16_u32_truncation_of_a_quad",
        config
    );
}

/// `ld.b16` of two fp8 elements yields a 2-byte `Value::Pair`; storing or
/// reloading it at that native width is not a half-extraction - only a
/// narrower store truncates.
#[test]
fn test_byte_pair_round_trips_through_shared_memory_at_native_16_bit_width() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.dynamic_shared_bytes = 16;
    config.arrays = vec![
        ArrayDef {
            name: "x".to_string(),
            base: 0x10000,
            elem_width: 1,
            len: 2,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 2,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("x".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze!(
        "success/byte_pair_round_trips_through_shared_memory_at_native_16_bit_width",
        config
    );
}

/// A concrete 16-bit source (e.g. `mov.u16`) gets a real `.e4m3` bit decode:
/// `0xB838` packs -1.0 high and +1.0 low (PTX ISA 9.7.9.22: low byte of `a`
/// -> low half of `d`).
#[test]
fn test_e4m3x2_decodes_a_concrete_scalar_bit_pattern() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/e4m3x2_decodes_a_concrete_scalar_bit_pattern",
        config
    );
}

/// Same concrete `0xB838` pattern as above, but with `.relu`: the
/// already-positive lower byte (+1.0) is untouched, the negative upper
/// byte (-1.0) clamps to 0.
#[test]
fn test_e4m3x2_relu_clamps_a_negative_decoded_lane_to_zero() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    analyze!(
        "success/e4m3x2_relu_clamps_a_negative_decoded_lane_to_zero",
        config
    );
}

/// Two threads storing the same value to one shared address are not a race once a
/// `bar.sync` orders the stores: thread 0 stores before it, thread 1 after it.
#[test]
fn test_same_value_stores_separated_by_bar_sync_are_not_a_race() {
    analyze!(
        "success/same_value_stores_separated_by_bar_sync_are_not_a_race",
        in_out_config(2, 1)
    );
}

/// Extern-only kernels are unaffected by extern-window placement: the window
/// starts at offset 0 and a sized buffer round-trips at `buf[0]`.
#[test]
fn test_extern_only_shared_roundtrip() {
    let mut config = in_out_config(1, 1);
    config.dynamic_shared_bytes = 16;
    analyze!("success/extern_only_shared_placement_and_bounds", config);
}

/// `membar.cta`/`.gl`/`.sys` lower (PTX ISA 9.7.15.4).
#[test]
fn test_membar_valid_levels_lower() {
    for (name, src) in [
        ptx_case!("success/membar_levels_cta"),
        ptx_case!("success/membar_levels_gl"),
        ptx_case!("success/membar_levels_sys"),
    ] {
        analyze_case(name, &src, AnalysisConfig::new((1, 1, 1)));
    }
}

/// Concrete integer division (index math) evaluates exactly.
#[test]
fn test_concrete_integer_div_evaluates() {
    analyze!(
        "success/symbolic_integer_div_is_unsupported_concrete",
        in_out_config(1, 1)
    );
}

/// The module-global window is half-open: an array ending exactly at its
/// base does not overlap it.
#[test]
fn test_array_ending_at_module_global_window_is_disjoint() {
    const MODULE_GLOBAL_BASE: u64 = 0x7000_0000_0000_0000;
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays.push(ArrayDef {
        name: "in".to_string(),
        base: MODULE_GLOBAL_BASE - 16,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    });
    analyze!(
        "success/array_overlapping_module_global_window_rejected",
        config
    );
}

/// Boundary `tcgen05.mma` encodings that are valid and modeled: M = 32 under
/// `.ws`, the B-reuse max shift under `.ws` (a performance hint), and D at
/// lane 0 with a column offset.
#[test]
fn test_tcgen05_mma_accepts_boundary_encodings() {
    for (name, src) in [
        ptx_case!("success/tcgen05_mma_encoding_shape_ws_m32_n64"),
        ptx_case!("success/tcgen05_mma_encoding_idesc_max_shift_ws"),
        ptx_case!("success/tcgen05_mma_encoding_d_lane0_col8"),
    ] {
        analyze_case(name, &src, AnalysisConfig::new((32, 1, 1)));
    }
}

/// Cluster launch control under the never-steal assumption: thread 0's
/// `try_cancel` is always declined, so each of the 64 threads processes only
/// its own CTA's tile and the persistent loop exits after one pass.
#[test]
fn test_clusterlaunchcontrol_declined_cancel_ends_the_persistent_loop() {
    analyze!(
        "success/clusterlaunchcontrol_declined_cancel_ends_the_persistent_loop",
        in_out_config(64, 64)
    );
}

/// Gluon reads the response as two 64-bit halves packed by `mov.b128`; the
/// 16 zero bytes are still the declined response.
#[test]
fn test_clusterlaunchcontrol_declined_response_read_as_two_halves_ends_the_loop() {
    analyze!(
        "success/clusterlaunchcontrol_declined_response_read_as_two_halves_ends_the_loop",
        in_out_config(64, 64)
    );
}

/// Clusters are assumed to hold a single CTA, so `mapa` into rank 0 returns
/// each thread's own shared address unchanged.
#[test]
fn test_mapa_rank_zero_is_the_identity() {
    analyze!(
        "success/mapa_rank_zero_is_the_identity",
        in_out_config(4, 4)
    );
}

/// Every cluster is assumed to hold a single CTA, so the cluster special
/// registers are hardcoded: rank 0 of an implicit 1x1x1 cluster, cluster grid =
/// CTA grid.
#[test]
fn test_cluster_special_registers_describe_a_single_cta_cluster() {
    let mut config = in_out_config(1, 15);
    config.grid_dim = (2, 3, 4);
    analyze!(
        "success/cluster_special_registers_describe_a_single_cta_cluster",
        config
    );
}

/// `setmaxnreg` is a full-warp rendezvous whose effect on the register count is not modeled:
/// warp 0's `.inc` beyond `.maxnreg` proceeds with no registers released, and each warp
/// converges at its own `setmaxnreg`.
#[test]
fn test_setmaxnreg_converges_its_warp_and_has_no_effect() {
    let mut config = out_only_config(4, 64);
    config.block_dim = (64, 1, 1);
    analyze!(
        "success/setmaxnreg_converges_its_warp_and_has_no_effect",
        config
    );
}

/// `.kind::mxf8f6f4.block_scale.block32`: every warp stores the same UE8M0 scale words in its
/// 32-lane partition, and the MMA scales row m of A by byte SFA_ID of the word at lane m % 32,
/// column m / 32 (column n of B likewise, byte SFB_ID): out = {204, 6528, 408, 13056}.
#[test]
fn test_tcgen05_mma_kind_mxf8f6f4_block_scale_numeric_correctness() {
    let mut config = out_only_config(4, 4);
    config.block_dim = (128, 1, 1);
    analyze!(
        "success/tcgen05_mma_kind_mxf8f6f4_block_scale_numeric_correctness",
        config
    );
}

/// `.kind::mxf8f6f4` scales that are kernel inputs, loaded as packed words like Gluon's:
/// D[0][0] = 2^(sa[1] - 127) * 2^(sb[2] - 127), each factor Volta's `ex2`.
#[test]
fn test_tcgen05_mma_kind_mxf8f6f4_symbolic_scales() {
    let mut config = AnalysisConfig::new((128, 1, 1));
    config.arrays = vec![
        array("sa", 0x10000, 1, 512, ArrayKind::Input),
        array("sb", 0x11000, 1, 512, ArrayKind::Input),
        array("out", 0x20000, 4, 1, ArrayKind::Output),
    ];
    config.params = ["sa", "sb", "out"]
        .map(|name| ParamValue::ArrayPtr(name.to_string()))
        .to_vec();
    analyze!("success/tcgen05_mma_kind_mxf8f6f4_symbolic_scales", config);
}
