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

/// A tensor map modified through the generic proxy is used by a TMA with no
/// `fence.proxy.tensormap::generic.acquire`.
#[test]
fn test_tma_without_tensormap_acquire_fence() {
    assert_not_verified(
        &ptx!(parse "false_positive/tma_without_tensormap_acquire_fence"),
        tma_config(32),
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
