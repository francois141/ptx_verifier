//! Kernels Volta still verifies although the PTX ISA makes them racy or undefined. Each test
//! fails until Volta stops concluding `Verified` on its kernel: a failed check, a deadlock, an
//! execution error or a refusal to lower all count as rejecting it.

#[macro_use]
mod common;

use volta_analysis::{AnalysisConfig, AnalysisError, ArrayDef, ArrayKind, EvalError, ParamValue};
use volta_graph_check::GraphConclusion;

use common::*;

/// Panics if Volta verifies `module` under `config`; a missing kernel or a rejected launch
/// configuration is the test's own error, not a rejection.
fn assert_not_verified(module: &Ptx, config: AnalysisConfig) {
    let name = module.file.unwrap_or("kernel");
    match verify(module, None, config) {
        Err(
            e @ (AnalysisError::KernelNotFound { .. }
            | AnalysisError::Eval(EvalError::Config { .. })),
        ) => panic!("{name}: the test cannot run: {e}"),
        Err(_) => {}
        Ok(verified) => assert!(
            !matches!(verified.graph.conclusion(), GraphConclusion::Verified),
            "{name}: Volta verified a kernel it must reject"
        ),
    }
}

/// One output array `out`, passed as the only parameter.
fn out_config(threads: u32, elem_width: u64, len: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
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

/// f16 `in` and `out` arrays, sized for the tensor-map kernels' 4x4 box over an 8x8 `in`.
fn tma_config(threads: u32) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
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
    config
}

/// Copy B, issued for phase 1 before phase 0 is observed, can land first and complete phase 0
/// while copy A still writes `bufA`: the read of `bufA` after the parity-0 wait races.
#[test]
fn test_bulk_copy_complete_tx_lands_in_earlier_phase() {
    assert_not_verified(
        &ptx!(parse "false_positive/bulk_copy_complete_tx_lands_in_earlier_phase"),
        in_out_config(1, 8),
    );
}

/// While phase 0's bulk copy is in flight, phase 0 is current and the parity-1 wait returns at
/// once through the preceding phase, so thread 1's read of `data` races thread 0's store.
#[test]
fn test_inflight_complete_tx_lets_parity_wait_return_early() {
    assert_not_verified(
        &ptx!(parse "false_positive/inflight_complete_tx_lets_parity_wait_return_early"),
        in_out_config(2, 8),
    );
}

/// Thread 1 arrives on `mbar` with nothing ordering thread 0's `mbarrier.init` first.
#[test]
fn test_mbarrier_init_unordered_with_other_threads_arrive() {
    assert_not_verified(
        &ptx!(parse "false_positive/mbarrier_init_unordered_with_other_threads_arrive"),
        in_out_config(2, 8),
    );
}

/// Thread 0 re-initializes the live `mbar` unordered with thread 1's arrive: an arrive that
/// lands first is wiped and thread 0 waits forever.
#[test]
fn test_mbarrier_reinit_of_live_object_races_arrive() {
    assert_not_verified(
        &ptx!(parse "false_positive/mbarrier_reinit_of_live_object_races_arrive"),
        in_out_config(2, 8),
    );
}

/// Thread 32's TMA reads the tensor map thread 0 is still building; nothing orders them.
#[test]
fn test_tma_uses_tensormap_built_by_other_thread_without_sync() {
    assert_not_verified(
        &ptx!(parse "false_positive/tma_uses_tensormap_built_by_other_thread_without_sync"),
        tma_config(64),
    );
}

/// A tensor map modified through the generic proxy is used by a TMA with no
/// `fence.proxy.tensormap::generic.acquire`.
#[test]
fn test_tma_without_tensormap_acquire_fence() {
    assert_not_verified(
        &ptx!(parse "false_positive/tma_without_tensormap_acquire_fence"),
        tma_config(32),
    );
}

/// The tcgen05 fences do not complete the `tcgen05.st`: the `tcgen05.ld` of its cells needs a
/// `tcgen05.wait::st` in between.
#[test]
fn test_tcgen05_st_then_ld_without_wait_st() {
    assert_not_verified(
        &ptx!(parse "false_positive/tcgen05_st_then_ld_without_wait_st"),
        out_config(32, 4, 256),
    );
}

/// The `tcgen05.ld` destination register is read before `tcgen05.wait::ld`.
#[test]
fn test_tcgen05_ld_result_used_before_wait_ld() {
    assert_not_verified(
        &ptx!(parse "false_positive/tcgen05_ld_result_used_before_wait_ld"),
        out_config(32, 4, 256),
    );
}

/// Lane 1's store and lane 2's load of `x` are ordered only by `tcgen05.alloc`, which orders
/// its own address write, not the lanes' other accesses.
#[test]
fn test_tcgen05_alloc_orders_lanes_plain_accesses() {
    assert_not_verified(
        &ptx!(parse "false_positive/tcgen05_alloc_orders_lanes_plain_accesses"),
        out_config(32, 4, 256),
    );
}

/// Warp 1's `relinquish_alloc_permit` is unordered with warp 0's `tcgen05.alloc`: the schedule
/// that relinquishes first allocates illegally.
#[test]
fn test_tcgen05_relinquish_unordered_with_other_warps_alloc() {
    assert_not_verified(
        &ptx!(parse "false_positive/tcgen05_relinquish_unordered_with_other_warps_alloc"),
        AnalysisConfig::new((64, 1, 1)),
    );
}

/// Lanes 0-15 and 16-31 reach the `.aligned` `bar.sync` on different loop iterations (UB).
#[test]
fn test_aligned_bar_sync_reached_on_different_iterations() {
    assert_not_verified(
        &ptx!(parse "false_positive/aligned_bar_sync_reached_on_different_iterations"),
        out_config(32, 4, 1),
    );
}

/// A never-written shared word reaches the output through an add: `out[0] = undefined + 1`.
#[test]
fn test_undefined_value_nested_in_output() {
    assert_not_verified(
        &ptx!(parse "false_positive/undefined_value_nested_in_output"),
        out_config(1, 4, 1),
    );
}
