//! Evaluator tests on kernels with a data race or an async-ordering
//! hazard (unwaited async copy, tcgen05/wgmma op still in flight),
//! which the analysis must report.

#[macro_use]
mod common;

use volta_analysis::AnalysisError;
use volta_analysis::driver::analyze_kernel;
use volta_analysis::eval::{AnalysisConfig, ArrayDef, ArrayKind, EvalError, ParamValue, ThreadId};
use volta_analysis::lowered::MemSpace;
use volta_equivalence::CanonValueEquality;

use common::*;

/// Two threads write the same shared address without synchronization.
#[test]
fn test_shared_write_write_race() {
    let module = ptx!(parse "execution_error/shared_write_write_race");
    let config = AnalysisConfig::new((2, 1, 1));
    let err = analyze_kernel(&module, None, config, &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected data race, got: {}",
        err
    );
}

#[test]
fn test_shared_exchange_without_barrier_races() {
    let module = ptx!(parse "execution_error/shared_exchange_without_barrier_races");
    let err = analyze_kernel(&module, None, in_out_config(2, 2), &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected data race, got: {}",
        err
    );
}

/// Same write/read pair, but thread 1 reads without waiting: must race, so
/// the sibling test's success comes from the mbarrier edge, not the kernel
/// shape.
#[test]
fn test_same_write_read_without_the_wait_still_races() {
    let module = ptx!(parse "execution_error/same_write_read_without_the_wait_still_races");
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((2, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected a data race, got: {}",
        err
    );
}

// One warp allocates Tensor Memory, then runs its body with `%r1` its
// quadrant-0 base, `%r2` a stored value, and `%r4` a `count = 32` mbarrier
// (the `tcgen05.wait` tests below).

/// A `tcgen05.wait::ld` placed *after* a barrier arrival is too late: the
/// wait is what completes the `.ld` for its issuer, so the barrier orders
/// nothing about it for the other participants. The arrival is rejected.
#[test]
fn test_tcgen05_wait_ld_after_bar_sync_is_rejected() {
    let module = parse(&ptx!(
        "execution_error/tcgen05_wait_ld_after_bar_sync_is_rejected"
    ));
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((32, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05UnwaitedAtSync { pending, .. }) => {
            assert!(!pending.is_write);
        }
        other => panic!("expected Tcgen05UnwaitedAtSync, got: {}", other),
    }
}

/// Same for `tcgen05.wait::st` after an mbarrier arrive.
#[test]
fn test_tcgen05_wait_st_after_mbarrier_arrive_is_rejected() {
    let module = parse(&ptx!(
        "execution_error/tcgen05_wait_st_after_mbarrier_arrive_is_rejected"
    ));
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((32, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05UnwaitedAtSync { pending, .. }) => {
            assert!(pending.is_write);
        }
        other => panic!("expected Tcgen05UnwaitedAtSync, got: {}", other),
    }
}

/// `tcgen05.dealloc` with an un-waited `tcgen05.ld`/`.st` still
/// outstanding on the range is rejected: the async op would touch columns
/// that are no longer allocated.
#[test]
fn test_tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected() {
    for (is_write, (op, src)) in [
        (
            false,
            ptx_case!("execution_error/tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected_ld"),
        ),
        (
            true,
            ptx_case!("execution_error/tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected_st"),
        ),
    ] {
        let module = parse(&src);
        let err = analyze_kernel(
            &module,
            None,
            AnalysisConfig::new((32, 1, 1)),
            &CanonValueEquality,
        )
        .unwrap_err();
        match &err {
            AnalysisError::Eval(EvalError::Tcgen05AsyncHazard { prior, current, .. }) => {
                assert_eq!(prior.is_write, is_write, "{op}");
                assert!(current.is_write);
            }
            other => panic!("{op}: expected Tcgen05AsyncHazard, got: {}", other),
        }
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
    let module = parse(&ptx!(
        "execution_error/tcgen05_mma_bar_sync_before_completion_orders_nothing"
    ));
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((64, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::TensorMemoryRace {
            lane,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*lane, 32);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert_eq!(current.thread.warp(), ThreadId(32).warp());
        }
        other => panic!("expected TensorMemoryRace, got: {}", other),
    }
}

/// The commit only attaches the completing mbarrier phase: `D` stays locked
/// until a waiter observes it, so warp 0 reading `D` right after the commit
/// hits the in-flight record.
#[test]
fn test_tcgen05_mma_read_after_commit_without_waiting_is_an_inflight_hazard() {
    let module = parse(&ptx!(
        "execution_error/tcgen05_mma_read_after_commit_without_waiting_is_an_inflight_hazard"
    ));
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((64, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05AsyncHazard {
            quadrant,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*quadrant, 0);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert!(!current.is_write);
        }
        other => panic!("expected Tcgen05AsyncHazard, got: {}", other),
    }
}

/// The MMA's shared operands stay write-locked from issue until a waiter
/// observes completion, even across a `bar.sync`: warp 1 overwriting `A` must
/// race.
#[test]
fn test_tcgen05_mma_operand_write_after_bar_sync_is_an_inflight_hazard() {
    let module = parse(&ptx!(
        "execution_error/tcgen05_mma_operand_write_after_bar_sync_is_an_inflight_hazard"
    ));
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((64, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::AsyncCopyHazard {
            space,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*space, MemSpace::Shared);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(!prior.is_write);
            assert_eq!(current.thread, ThreadId(32));
            assert!(current.is_write);
        }
        other => panic!("expected AsyncCopyHazard, got: {}", other),
    }
}

/// The MMA may write `D` any time after issue, so a `bar.sync` before the
/// commit orders nothing: warp 1's earlier read of `D`, ordered by a bare
/// `complete_tx` only, races the write.
#[test]
fn test_tcgen05_mma_bar_sync_between_issue_and_commit_orders_nothing() {
    let module = parse(&ptx!(
        "execution_error/tcgen05_mma_bar_sync_between_issue_and_commit_orders_nothing"
    ));
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((64, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::TensorMemoryRace {
            lane,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*lane, 32);
            assert_eq!(prior.thread, ThreadId(32));
            assert!(!prior.is_write);
            assert_eq!(current.thread, ThreadId(0));
            assert!(current.is_write);
        }
        other => panic!("expected TensorMemoryRace, got: {}", other),
    }
}

/// `tcgen05.dealloc` of `D`'s columns while the MMA writing them is still
/// in flight - committed, but no thread has observed `mma_bar` - is
/// rejected.
#[test]
fn test_tcgen05_dealloc_with_an_mma_in_flight_is_rejected() {
    let module = parse(&ptx!(
        "execution_error/tcgen05_dealloc_with_an_mma_in_flight_is_rejected"
    ));
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((64, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05AsyncHazard { prior, current, .. }) => {
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert!(current.is_write);
        }
        other => panic!("expected Tcgen05AsyncHazard, got: {}", other),
    }
}

/// Reading one's own `cp.async` destination before `wait_group` is a hazard
/// even same-thread: the destination lock also blocks the issuer, unlike
/// χ-tracking.
#[test]
fn test_cp_async_same_thread_peek_before_wait_is_hazard() {
    let module = ptx!(parse "execution_error/cp_async_same_thread_peek_before_wait_is_hazard");
    let err = analyze_kernel(&module, None, in_out_config(1, 1), &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an async-copy hazard, got: {}",
        err
    );
}

/// Another thread touching the destination while thread 0's copy is in flight
/// is a hazard; the barrier exposes the interleaving (otherwise thread 0
/// would finish first).
#[test]
fn test_cp_async_cross_thread_read_of_locked_destination_is_hazard() {
    let module =
        ptx!(parse "execution_error/cp_async_cross_thread_read_of_locked_destination_is_hazard");
    let err = analyze_kernel(&module, None, in_out_config(2, 1), &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an async-copy hazard, got: {}",
        err
    );
}

/// A different thread writing the source while thread 0's copy is still in
/// flight must also be a hazard (the source-lock half, not just the
/// destination half).
#[test]
fn test_cp_async_cross_thread_write_of_locked_source_is_hazard() {
    let module =
        ptx!(parse "execution_error/cp_async_cross_thread_write_of_locked_source_is_hazard");
    let err = analyze_kernel(&module, None, in_out_config(2, 1), &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an async-copy hazard, got: {}",
        err
    );
}

/// `wait_group` orders only the issuer's own later instructions: another
/// thread reading the destination after it, unsynchronized, is still a data
/// race (via χ, not the lock).
#[test]
fn test_cp_async_post_wait_cross_thread_read_without_sync_is_data_race() {
    let module = ptx!(parse "execution_error/cp_async_post_wait_cross_thread_read_without_sync_is_data_race");
    let err = analyze_kernel(&module, None, in_out_config(2, 1), &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected an ordinary data race (missing sync after wait_group), got: {}",
        err
    );
}

/// A TMA destination read does require the copy's completion: without the
/// `mbarrier.try_wait.parity`, the reads race the in-flight copy's
/// destination lock.
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
    let err = analyze_kernel(&module, None, config, &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::AsyncCopyHazard { .. })),
        "expected an in-flight async-copy hazard, got: {}",
        err
    );
}

/// A `bar.sync` after the issue orders nothing about the copy's write: warp
/// 1, released by `gate`'s bare `complete_tx`, reads `buf` unordered with it
/// (a χ race, not the lock).
#[test]
fn test_cp_async_bulk_bar_sync_before_completion_orders_nothing() {
    let module = parse(&ptx!(
        "execution_error/cp_async_bulk_bar_sync_before_completion_orders_nothing"
    ));
    let err = analyze_kernel(&module, None, bulk_copy_config(), &CanonValueEquality).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::DataRace {
            space,
            prior,
            current,
            ..
        }) => {
            assert_eq!(*space, MemSpace::Shared);
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert_eq!(current.thread.warp(), ThreadId(32).warp());
            assert!(!current.is_write);
        }
        other => panic!("expected DataRace, got: {}", other),
    }
}

/// The copy's destination stays locked against every access from the
/// issue until a waiter observes `full` - a `bar.sync` in between lifts
/// nothing. Nobody waits here, and warp 1 reads `buf` after the barrier.
#[test]
fn test_cp_async_bulk_read_after_bar_sync_is_an_inflight_hazard() {
    let module = parse(&ptx!(
        "execution_error/cp_async_bulk_read_after_bar_sync_is_an_inflight_hazard"
    ));
    let err = analyze_kernel(&module, None, bulk_copy_config(), &CanonValueEquality).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::AsyncCopyHazard { prior, current, .. }) => {
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert_eq!(current.thread, ThreadId(32));
        }
        other => panic!("expected AsyncCopyHazard, got: {}", other),
    }
}

/// Hazard A (`WgmmaFenceHazard`): an ordinary register write between the two
/// calls breaks the same-shape chain, and the second call's accumulator read
/// has no `wgmma.fence`.
#[test]
fn test_wgmma_fence_hazard_ordinary_write_breaks_chain() {
    let module = ptx!(parse "execution_error/wgmma_fence_hazard_ordinary_write_breaks_chain");
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((128, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
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
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((128, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
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
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((128, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::WgmmaWaitGroupHazard { .. })
        ),
        "expected a wgmma wait_group hazard, got: {}",
        err
    );
}

/// A `wgmma.mma_async`'s shared `A`/`B` stay write-locked until every live
/// member's `wgmma.wait_group` releases it: thread 0 overwriting `A` before
/// waiting (`_before_wait_group`), or under a `wait_group 1` that keeps the
/// group pending (`_after_wait_group_1`), trips the lock.
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
        let err = analyze_kernel(&parse(&src), None, config, &CanonValueEquality).unwrap_err();
        match &err {
            AnalysisError::Eval(EvalError::AsyncCopyHazard {
                space,
                prior,
                current,
                ..
            }) => {
                assert_eq!(*space, MemSpace::Shared, "{name}");
                assert_eq!(prior.thread, ThreadId(0), "{name}");
                assert!(!prior.is_write, "{name}");
                assert_eq!(current.thread, ThreadId(0), "{name}");
                assert!(current.is_write, "{name}");
            }
            other => panic!("{name}: expected AsyncCopyHazard, got: {}", other),
        }
    }
}

/// Two threads storing different values to one shared address race (unlike
/// the same-value store in `accepted_tests.rs`).
#[test]
fn test_different_value_store_to_one_address_races() {
    let differ = ptx!(parse "execution_error/same_value_warp_uniform_store_is_not_a_race_differ");
    let err = analyze_kernel(&differ, None, in_out_config(2, 1), &CanonValueEquality).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::DataRace { .. })),
        "expected data race, got: {}",
        err
    );
}

/// A `try_cancel` response is an async write locked until a waiter observes
/// its mbarrier: warp 1 reads it after `bar.sync` alone and trips the lock.
#[test]
fn test_clusterlaunchcontrol_response_read_without_waiting_is_an_inflight_hazard() {
    let module = ptx!(
        parse "execution_error/clusterlaunchcontrol_response_read_without_waiting_is_an_inflight_hazard"
    );
    let err = analyze_kernel(
        &module,
        None,
        AnalysisConfig::new((64, 1, 1)),
        &CanonValueEquality,
    )
    .unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::AsyncCopyHazard { prior, current, .. }) => {
            assert_eq!(prior.thread, ThreadId(0));
            assert!(prior.is_write);
            assert_eq!(current.thread, ThreadId(32));
        }
        other => panic!("expected AsyncCopyHazard, got: {}", other),
    }
}
