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

/// Lanes 0-15 and 16-31 reach the `.aligned` `bar.sync` on different loop iterations (UB).
#[test]
fn test_aligned_bar_sync_reached_on_different_iterations() {
    assert_not_verified(
        &ptx!(parse "false_positive/aligned_bar_sync_reached_on_different_iterations"),
        out_config(32, 4, 1),
    );
}
