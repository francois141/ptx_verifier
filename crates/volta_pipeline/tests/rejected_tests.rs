//! End-to-end tests on ill-formed or unsupported kernels other than conflicts:
//! invalid instructions and encodings, deadlocks (the trace generator's
//! diagnostic, not a graph check), out-of-bounds or misaligned accesses,
//! reads of uninitialized memory, undefined outputs, and unmodeled forms.

#[macro_use]
mod common;

use volta_equivalence::check_output_equivalence;
use volta_graph_check::{Deadlock, GraphConclusion};
use volta_ptx_analysis::{
    AnalysisConfig, AnalysisError, ArrayDef, ArrayKind, ClcMisuse, EvalError, LowerError,
    ParamValue, ThreadId,
};

use common::*;

/// Run a one-`tcgen05.mma` kernel from `tests/ptx/failing/tcgen05_mma_encoding_*`
/// (thread 0 issues it, D in a fresh 512-column allocation). The variants
/// differ only in the `idesc`, the descriptors, `.ws`, and D's offset.
fn run_tcgen05_mma(src: &str) -> Result<Completed, AnalysisError> {
    run_kernel(&parse(src), None, AnalysisConfig::new((32, 1, 1)))
}

/// Assert `result` is an `InvalidEncoding` whose message contains `needle`.
fn expect_invalid_encoding(result: Result<Completed, AnalysisError>, needle: &str) {
    match result {
        Err(AnalysisError::Eval(EvalError::InvalidEncoding { what, .. })) => {
            assert!(what.contains(needle), "expected {needle:?} in: {what}");
        }
        Err(other) => panic!("expected InvalidEncoding ({needle}), got: {other}"),
        Ok(_) => panic!("expected InvalidEncoding ({needle}), got Ok"),
    }
}

fn expect_invalid_instruction(module: &Ptx, needle: &str) {
    match run_kernel(module, None, AnalysisConfig::new((32, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::InvalidInstruction { reason, .. })) => {
            assert!(reason.contains(needle), "expected {needle:?} in: {reason}");
        }
        Err(other) => panic!("expected InvalidInstruction ({needle}), got: {other}"),
        Ok(_) => panic!("expected InvalidInstruction ({needle}), got Ok"),
    }
}

/// Assert running `module` under `config` ends with its first read of never-written memory, at
/// `addr`.
fn expect_uninitialized_read(module: &Ptx, config: AnalysisConfig, addr: u64) {
    match run_kernel(module, None, config) {
        Err(AnalysisError::Eval(EvalError::UninitializedMemory { addr: read, .. })) => {
            assert_eq!(read, addr, "the first uninitialized read");
        }
        Err(other) => panic!("expected an uninitialized read at {addr:#x}, got: {other}"),
        Ok(_) => panic!("expected an uninitialized read at {addr:#x}, got Ok"),
    }
}

/// A store through the `.extern .shared` window must not be visible through a
/// static `.shared` variable (the dynamic segment follows all static ones),
/// so the `lut` read at shared address 0 reads never-written memory.
#[test]
fn test_extern_shared_store_invisible_through_static_shared() {
    let mut config = in_out_config(1, 1);
    config.dynamic_shared_bytes = 16;
    expect_uninitialized_read(
        &ptx!(parse "failing/extern_shared_store_invisible_through_static_shared"),
        config,
        0,
    );
}

/// An extern-only kernel needs `dynamic_shared_bytes`, which also bounds its
/// window: a missing size errors and a store past the end is out of bounds.
#[test]
fn test_extern_only_shared_placement_and_bounds() {
    let module = ptx!(parse "failing/extern_only_shared_placement_and_bounds");
    // Without dynamic_shared_bytes the launch is rejected.
    let err = run_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Config { message })
                if message.contains("dynamic_shared_bytes")
        ),
        "expected missing dynamic_shared_bytes error, got: {}",
        err
    );

    // A store ending one byte past the window end is out of bounds.
    let module = ptx!(parse "failing/extern_only_shared_placement_and_bounds_past_end");
    let mut config = in_out_config(1, 1);
    config.dynamic_shared_bytes = 16;
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::OutOfBounds { .. })),
        "expected out-of-bounds, got: {}",
        err
    );
}

/// The trace generator's deadlock for `module` on `threads` threads.
fn deadlock(module: &Ptx, threads: u32) -> Deadlock {
    let checked = check(module, None, AnalysisConfig::new((threads, 1, 1)));
    checked.report.deadlock().unwrap_or_else(|| {
        panic!(
            "expected a deadlock, got the terminal state {:?}",
            checked.report.terminal
        )
    })
}

/// Threads waiting on different barrier ids never fire: deadlock.
#[test]
fn test_mismatched_barriers_deadlock() {
    let blocked = deadlock(&ptx!(parse "failing/mismatched_barriers_deadlock"), 2).blocked;
    assert!(!blocked.is_empty());
}

/// `bar.sync` is `.aligned`, so a warp executes it as one collective: lanes 0-15 and 16-31 of
/// the one warp at two `bar.sync 0` instructions wait at two barriers, and neither fires.
#[test]
fn test_bar_sync_split_across_two_instructions_in_one_warp() {
    let blocked = deadlock(
        &ptx!(parse "failing/bar_sync_split_across_two_instructions_in_one_warp"),
        32,
    )
    .blocked;
    assert_eq!(blocked.len(), 32, "every lane stays blocked: {blocked:?}");
}

/// The same split between a `bar.arrive` and a `bar.sync`: barrier 1's 64 arrivals do not fire
/// it, since warp 0's lanes arrive at two aligned instructions.
#[test]
fn test_bar_arrive_and_bar_sync_split_in_one_warp() {
    let blocked: Vec<u32> = deadlock(
        &ptx!(parse "failing/bar_arrive_and_bar_sync_split_in_one_warp"),
        64,
    )
    .blocked
    .iter()
    .map(|b| b.thread.0)
    .collect();
    assert_eq!(blocked, (16..64).collect::<Vec<_>>());
}

/// Same shape, but only thread 0 arrives: `count = 2` is never satisfied, so
/// its `try_wait.parity` blocks forever - a genuine deadlock of the whole
/// CTA.
#[test]
fn test_mbarrier_wait_never_satisfied_deadlocks() {
    let blocked = deadlock(
        &ptx!(parse "failing/mbarrier_wait_never_satisfied_deadlocks"),
        2,
    )
    .blocked;
    assert!(!blocked.is_empty());
}

/// Warp 1 `bar.arrive`s twice while warp 0 waits in its first `bar.sync`:
/// nothing keeps the second arrival out of the first generation, so which
/// generation it completes depends on the schedule.
#[test]
fn test_bar_arrive_twice_before_the_barrier_fires() {
    let module = ptx!(parse "failing/bar_arrive_twice_before_the_barrier_fires");
    let err = run_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::BarrierMismatch { reason, .. })
                if reason.contains("96 threads arrived at barrier 1")
        ),
        "expected a barrier mismatch, got: {}",
        err
    );
}

/// The 16 live lanes of each of two warps arrive at `barrier.cta.sync 1, 32`: each warp counts as
/// 32 threads (PTX ISA 9.7.13.1), so either completes the barrier alone, in an order the schedule
/// decides, and thread 0's store is unordered with thread 32's load.
#[test]
fn test_half_warps_count_as_whole_warps_at_a_counted_barrier() {
    let module = ptx!(parse "failing/half_warps_count_as_whole_warps_at_a_counted_barrier");
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    match run_kernel(&module, None, config) {
        Err(AnalysisError::Eval(EvalError::BarrierMismatch { reason, .. })) => assert!(
            reason.contains("64 threads arrived at barrier 1 (whole warps), which fires on 32"),
            "{reason}"
        ),
        Err(other) => panic!("expected a barrier mismatch, got: {other}"),
        Ok(_) => panic!("expected a barrier mismatch, got Ok"),
    }
}

/// Assert running `module` on 64 threads aborts with a barrier mismatch whose reason contains
/// `needle`, and that the graph branch concludes it inconclusive.
fn expect_inconclusive_barrier_mismatch(module: &Ptx, needle: &str) {
    match run_kernel(module, None, AnalysisConfig::new((64, 1, 1))) {
        Err(AnalysisError::Eval(EvalError::BarrierMismatch { reason, .. })) => {
            assert!(reason.contains(needle), "expected {needle:?} in: {reason}");
            assert!(
                reason.ends_with("so the result is inconclusive"),
                "{reason}"
            );
        }
        Err(other) => panic!("expected a barrier mismatch ({needle}), got: {other}"),
        Ok(_) => panic!("expected a barrier mismatch ({needle}), got Ok"),
    }
    let conclusion = check(module, None, AnalysisConfig::new((64, 1, 1)))
        .report
        .conclusion();
    assert!(
        matches!(conclusion, GraphConclusion::Unknown { .. }),
        "expected an inconclusive result, got: {conclusion:?}"
    );
}

/// Barrier 0 is reached with count 32 through a register id and with count 64: lowering cannot
/// compare a register id with an immediate one, so the run stops at warp 1's arrival.
#[test]
fn test_bar_sync_register_id_count_mismatch() {
    expect_inconclusive_barrier_mismatch(
        &ptx!(parse "failing/bar_sync_register_id_count_mismatch"),
        "t32 arrives at barrier 0 expecting 64 threads, but an earlier arrival at it expected \
         32 threads",
    );
}

/// The same mismatch on a `bar.arrive`: warp 1 arrives through a register id with count 32 at
/// the barrier warp 0 waits on for 64 threads.
#[test]
fn test_bar_arrive_register_id_count_mismatch() {
    expect_inconclusive_barrier_mismatch(
        &ptx!(parse "failing/bar_arrive_register_id_count_mismatch"),
        "t32 arrives at barrier 1 expecting 32 threads, but an earlier arrival at it expected \
         64 threads",
    );
}

/// A barrier id's count is pinned for the whole run, not per phase: reusing barrier 0 with a
/// new count after a completed phase is legal PTX, but Volta's result is inconclusive.
#[test]
fn test_bar_sync_register_id_count_changes_between_phases() {
    expect_inconclusive_barrier_mismatch(
        &ptx!(parse "failing/bar_sync_register_id_count_changes_between_phases"),
        "t0 arrives at barrier 0 expecting 32 threads, but an earlier arrival at it expected \
         64 threads",
    );
}

/// `.relaxed` on `mbarrier.arrive`/`try_wait.parity` is rejected at lowering:
/// it has no ordering semantics (9.7.14.16.16/.19), so accepting it would
/// make the happens-before edge unsound.
#[test]
fn test_mbarrier_relaxed_semantics_rejected() {
    for (expect, (form, src)) in [
        (
            "mbarrier.arrive",
            ptx_case!("failing/mbarrier_relaxed_semantics_rejected_arrive"),
        ),
        (
            "mbarrier.try_wait",
            ptx_case!("failing/mbarrier_relaxed_semantics_rejected_try_wait"),
        ),
    ] {
        let module = parse(&src);
        let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
        match &err {
            AnalysisError::Lower(LowerError::UnsupportedInstruction { instruction, .. }) => {
                assert_eq!(instruction, expect, "wrong instruction name for {}", form);
            }
            other => panic!(
                "expected UnsupportedInstruction for {}, got: {}",
                form, other
            ),
        }
    }
}

/// The warp-collective `tcgen05.*` instructions require `.sync.aligned`
/// (PTX ISA: "The mandatory .sync qualifier" / "The mandatory .aligned
/// qualifier"); dropping either is invalid PTX.
#[test]
fn test_tcgen05_rejects_missing_sync_aligned() {
    for (src, missing) in [
        (
            ptx!("failing/tcgen05_rejects_missing_sync_aligned_alloc_sync"),
            ".sync",
        ),
        (
            ptx!("failing/tcgen05_rejects_missing_sync_aligned_alloc_aligned"),
            ".aligned",
        ),
        (
            ptx!("failing/tcgen05_rejects_missing_sync_aligned_ld"),
            ".sync",
        ),
        (
            ptx!("failing/tcgen05_rejects_missing_sync_aligned_st"),
            ".aligned",
        ),
        (
            ptx!("failing/tcgen05_rejects_missing_sync_aligned_wait_ld"),
            ".sync",
        ),
        (
            ptx!("failing/tcgen05_rejects_missing_sync_aligned_dealloc"),
            ".aligned",
        ),
        (
            ptx!("failing/tcgen05_rejects_missing_sync_aligned_relinquish"),
            ".aligned",
        ),
    ] {
        let module = parse(&src);
        expect_invalid_instruction(&module, &format!("mandatory {missing} qualifier"));
    }
}

/// `bar` and `barrier` have no default operation (PTX ISA: only `.cta` and `.aligned` are
/// optional), so a bare `bar 0` or `barrier 0` is invalid PTX, not an implicit `.sync`.
#[test]
fn test_bar_and_barrier_reject_a_missing_operation() {
    for (expect, (form, src)) in [
        (
            "Bar",
            ptx_case!("failing/bar_and_barrier_reject_a_missing_operation_bar"),
        ),
        (
            "Barrier",
            ptx_case!("failing/bar_and_barrier_reject_a_missing_operation_barrier"),
        ),
    ] {
        let err = run_kernel(&parse(&src), None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
        match &err {
            AnalysisError::Lower(LowerError::UnsupportedInstruction {
                instruction,
                reason,
            }) => {
                assert_eq!(instruction, expect, "wrong instruction name for {form}");
                assert!(
                    reason.as_deref().is_some_and(|r| r.contains("MissingModifier")),
                    "expected a missing operation modifier for {form}, got: {reason:?}"
                );
            }
            other => panic!("expected {form} rejected for its missing operation, got: {other}"),
        }
    }
}

/// `nCols` below the 32-column allocation unit is invalid even when it is
/// a power of 2, and the column count must not increase between two
/// allocations (PTX ISA 9.7.18.7.1).
#[test]
fn test_tcgen05_alloc_rejects_invalid_sizes_and_order() {
    let err = run_kernel(
        &parse(&ptx!(
            "failing/tcgen05_alloc_rejects_invalid_sizes_and_order_16"
        )),
        None,
        AnalysisConfig::new((32, 1, 1)),
    )
    .unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Tcgen05InvalidColumnCount { num_cols: 16, .. })
        ),
        "{err}"
    );
    let err = run_kernel(
        &parse(&ptx!(
            "failing/tcgen05_alloc_rejects_invalid_sizes_and_order_32_then_64"
        )),
        None,
        AnalysisConfig::new((32, 1, 1)),
    )
    .unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Tcgen05IncreasingColumnCount {
                previous: 32,
                requested: 64,
                ..
            })
        ),
        "{err}"
    );
}

/// `.exclusive` allocation and deallocation (PTX ISA 9.4+) are rejected as
/// unsupported naming `.exclusive`, not judged by the non-exclusive rules (96
/// columns is not a power of 2).
#[test]
fn test_tcgen05_exclusive_alloc_and_dealloc_are_not_implemented() {
    for src in [
        ptx!("failing/tcgen05_exclusive_alloc_and_dealloc_are_not_implemented_alloc"),
        ptx!("failing/tcgen05_exclusive_alloc_and_dealloc_are_not_implemented_dealloc"),
    ] {
        let err = run_kernel(&parse(&src), None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
        match &err {
            AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. }) => {
                let reason = reason.as_deref().unwrap_or("");
                assert!(
                    reason.contains(".exclusive") && reason.contains("not implemented"),
                    "{reason}"
                );
            }
            other => panic!("expected UnsupportedInstruction, got: {other}"),
        }
    }
}

/// A `tcgen05.st` whose column range starts in one allocation and runs
/// past its end is rejected, even though the next columns belong to an
/// adjacent live allocation (so every cell it touches is allocated).
#[test]
fn test_tcgen05_access_past_an_allocation_into_an_adjacent_one_is_rejected() {
    let module = parse(&ptx!(
        "failing/tcgen05_access_past_an_allocation_into_an_adjacent_one_is_rejected"
    ));
    let err = run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Tcgen05AccessOutsideAllocation {
                start_col: 31,
                num_cols: 2,
                ..
            })
        ),
        "{err}"
    );
}

/// A `taddr` naming a lane quadrant other than the issuing warp's (PTX ISA
/// 9.7.17.8.1) must error, not be silently "corrected" by deriving the lane
/// from `ThreadId`.
#[test]
fn test_tcgen05_st_rejects_wrong_quadrant_address() {
    let module = ptx!(parse "failing/tcgen05_st_rejects_wrong_quadrant_address");
    let err = run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Tcgen05LaneRestrictionViolation {
            lane_base,
            expected_quadrant_base,
            ..
        }) => {
            assert_eq!(*lane_base, 32);
            assert_eq!(*expected_quadrant_base, 0);
        }
        other => panic!("expected Tcgen05LaneRestrictionViolation, got: {}", other),
    }
}

/// `tensormap.cp_fenceproxy` is `.sync.aligned`: thread 0 executes it while lanes 1-31 of its
/// warp exit, so the warp never executes it as one.
#[test]
fn test_cp_fenceproxy_by_one_lane_of_a_warp_is_rejected() {
    let module = ptx!(parse "failing/cp_fenceproxy_by_one_lane_of_a_warp_is_rejected");
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
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::WarpMismatch { reason, .. })
                if reason.contains("tensormap.cp_fenceproxy is .aligned")
        ),
        "expected a warp mismatch, got: {}",
        err
    );
}

/// `cp.async.bulk.tensor` on a tensor-map missing a field (`.fill_mode`) must
/// error naming it: an incomplete map is a kernel bug, not a gap to fill with
/// a default.
#[test]
fn test_cp_async_bulk_tensor_rejects_an_incomplete_tensor_map() {
    let module = ptx!(parse "failing/cp_async_bulk_tensor_rejects_an_incomplete_tensor_map");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "in".to_string(),
        base: 0x10000,
        elem_width: 2,
        len: 64,
        kind: ArrayKind::Input,
    }];
    config.params = vec![ParamValue::ArrayPtr("in".to_string())];
    let err = run_kernel(&module, None, config).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::TensorMapFieldMissing { field, .. }) => {
            assert_eq!(field, "fill_mode");
        }
        other => panic!("expected TensorMapFieldMissing, got: {}", other),
    }
}

/// Like `test_tcgen05_mma_numeric_correctness`, but `disable-output-lane`
/// masks lane 0 (PTX ISA 9.7.17.10.9.1): `D[0][0]` is never written, so the
/// `tcgen05.ld` of it reads uninitialized Tensor Memory instead of `136`.
#[test]
fn test_tcgen05_mma_disable_output_lane_skips_the_write() {
    let module = ptx!(parse "failing/tcgen05_mma_disable_output_lane_skips_the_write");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Tcgen05UninitializedRead {
                lane: 0,
                col: 0,
                ..
            })
        ),
        "expected an uninitialized read of D[0][0] (lane 0 must never be written), got: {}",
        err
    );
}

/// Only `.kind::f16` and `.kind::f8f6f4` are modeled; other kinds are
/// rejected at lowering naming the rejected and modeled kinds, not the
/// generic "not yet implemented".
#[test]
fn test_tcgen05_mma_rejects_unmodeled_kind() {
    let module = ptx!(parse "failing/tcgen05_mma_rejects_unmodeled_kind");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason,
        }) => {
            assert_eq!(instruction, "tcgen05.mma");
            let reason = reason.as_deref().unwrap_or("");
            for expected in ["kind::tf32", ".kind::f16", ".kind::f8f6f4"] {
                assert!(
                    reason.contains(expected),
                    "expected the reason to mention {expected}, got: {reason:?}"
                );
            }
        }
        other => panic!("expected UnsupportedInstruction, got: {}", other),
    }
}

/// An unmodeled `idesc` operand type (`.kind::f16` A type 2, neither f16 nor
/// bf16) is rejected at eval with a message specific to that gap, proving
/// validation reports the actual problem, not the descriptor-addressing error.
#[test]
fn test_tcgen05_mma_rejects_unmodeled_idesc_fields() {
    let module = ptx!(parse "failing/tcgen05_mma_rejects_unmodeled_idesc_fields");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(
                what.contains("A type field 2 is not modeled"),
                "expected the A-type error, got: {}",
                what
            );
        }
        other => panic!("expected EvalError::Unsupported, got: {}", other),
    }
}

/// An `idesc` with the K Dimension bit (29) set is rejected rather than
/// run at the kind's base `K`: the corpus f16 descriptor (dense, D=f32,
/// A/B=f16, M=128, N=256 - otherwise fully modeled) plus `1 << 29`.
#[test]
fn test_tcgen05_mma_rejects_k_dimension_bit() {
    let module = ptx!(parse "failing/tcgen05_mma_rejects_k_dimension_bit");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(
                what.contains("K Dimension bit (29)") && what.contains("K = 16"),
                "expected the K-dimension error, got: {}",
                what
            );
        }
        other => panic!("expected EvalError::Unsupported, got: {}", other),
    }
}

/// Shapes outside PTX ISA Table 48's `.cta_group::1` dense set are invalid:
/// `M = 32` is `.ws`-only, N <= 256, `.ws` takes N = 64/128/256, and Table
/// 63's 8-bit transposed B needs N % 16 == 0.
#[test]
fn test_tcgen05_mma_rejects_invalid_shapes() {
    for (shape, src) in [
        (
            "M=32 N=64",
            ptx!("failing/tcgen05_mma_encoding_shape_m32_n64"),
        ),
        (
            "M=128 N=264",
            ptx!("failing/tcgen05_mma_encoding_shape_m128_n264"),
        ),
        (
            ".ws M=128 N=16",
            ptx!("failing/tcgen05_mma_encoding_shape_ws_m128_n16"),
        ),
        (
            ".ws M=128 N=0",
            ptx!("failing/tcgen05_mma_encoding_shape_ws_m128_n0"),
        ),
    ] {
        match run_tcgen05_mma(&src) {
            Err(AnalysisError::Eval(EvalError::InvalidEncoding { what, .. })) => {
                let needle = "is not a valid .cta_group::1 dense shape";
                assert!(
                    what.contains(needle),
                    "{shape}: expected {needle:?} in: {what}"
                );
            }
            other => panic!("{shape}: expected InvalidEncoding, got: {other:?}"),
        }
    }
    // The fp8 corpus idesc (M = 128) with B transposed and N = 8.
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_shape_fp8_n8")),
        "steps of 16",
    );
}

/// Reserved/limited `idesc` fields: bits 6 and 23 must be 0, saturate (bit 3)
/// is integer-only, B-reuse shift (bits 30-31) is `.ws`-only, and D type
/// (bits 4-5) must be at most f32 = 1.
#[test]
fn test_tcgen05_mma_rejects_invalid_idesc_fields() {
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_idesc_reserved_bit6")),
        "reserved bit 6",
    );
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_idesc_reserved_bit23")),
        "reserved bit 23",
    );
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_idesc_saturate")),
        "saturate",
    );
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_idesc_max_shift")),
        "maximum shift",
    );
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_idesc_dtype2")),
        "D type field",
    );
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_idesc_dtype3")),
        "D type field",
    );
}

/// Malformed shared-memory descriptors (PTX ISA Table 49) are rejected: a
/// reserved bit, or the fixed `0b001` at bits 46-48 missing.
#[test]
fn test_tcgen05_mma_rejects_malformed_descriptors() {
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_a_desc_bit15")),
        "a-desc",
    );
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_b_desc_no_bit46")),
        "fixed-constant field at bit 46",
    );
}

/// `D` must start at Tensor Memory lane 0: a `[d-tmem]` address with a
/// nonzero lane field (bits 31-16) is rejected as unmodeled, naming the
/// lane, rather than read as a column far outside the allocation.
#[test]
fn test_tcgen05_mma_rejects_a_d_address_off_lane_0() {
    for (lane, src) in [
        (32, ptx!("failing/tcgen05_mma_encoding_d_lane32")),
        (128, ptx!("failing/tcgen05_mma_encoding_d_lane128")),
    ] {
        match run_tcgen05_mma(&src) {
            Err(AnalysisError::Eval(EvalError::Unsupported { what, .. })) => {
                let needle = format!("[d-tmem] at lane {lane}");
                assert!(what.contains(&needle), "expected {needle:?} in: {what}");
            }
            Err(other) => panic!("lane {lane}: expected Unsupported, got: {other}"),
            Ok(_) => panic!("lane {lane}: expected Unsupported, got Ok"),
        }
    }
}

/// PTX ISA Table 65: for 8- and 16-bit operands a transposed matrix may
/// use every swizzling mode except 128B with 32B atomicity.
#[test]
fn test_tcgen05_mma_rejects_invalid_layout_combinations() {
    // The f16 idesc transposes B; B's descriptor is 128B-with-32B-atomicity.
    expect_invalid_encoding(
        run_tcgen05_mma(&ptx!("failing/tcgen05_mma_encoding_b_swizzle128b_atom32")),
        "transposed B with 128B swizzling with 32B atomicity",
    );
}

/// `membar.level` is mandatory `.cta`/`.gl`/`.sys` (PTX ISA 9.7.15.4):
/// `.cluster`/`.gpu` or no level fail to parse; `membar.proxy` parses but is
/// unimplemented.
#[test]
fn test_membar_levels() {
    let analyze = |src: String| run_kernel(&parse(&src), None, AnalysisConfig::new((1, 1, 1)));
    for (level, src) in [
        (".cluster", ptx!("failing/membar_levels_cluster")),
        (".gpu", ptx!("failing/membar_levels_gpu")),
        ("", ptx!("failing/membar_levels_none")),
    ] {
        match analyze(src) {
            Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
                let reason = reason.unwrap_or_default();
                assert!(reason.contains("parsing failed"), "membar{level}: {reason}");
            }
            other => panic!("membar{level}: expected a parse failure, got {other:?}"),
        }
    }
    for (proxy, src) in [
        ("alias", ptx!("failing/membar_levels_proxy_alias")),
        ("async", ptx!("failing/membar_levels_proxy_async")),
    ] {
        match analyze(src) {
            Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
                let reason = reason.unwrap_or_default();
                assert!(reason.contains("not implemented yet"), "{proxy}: {reason}");
            }
            other => panic!("membar.proxy.{proxy}: expected unsupported, got {other:?}"),
        }
    }
}

/// `mbarrier.inval` is rejected until a check orders an mbarrier's other operations before its
/// invalidation: a late `arrive` racing with the reuse of the object's bytes would go unnoticed.
#[test]
fn test_mbarrier_inval_is_not_implemented() {
    let module = parse(&ptx!("failing/mbarrier_inval_is_not_implemented"));
    match run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
            let reason = reason.unwrap_or_default();
            assert!(
                reason.contains("mbarrier.inval") && reason.contains("not implemented"),
                "{reason}"
            );
        }
        other => panic!("expected unsupported, got {other:?}"),
    }
}

/// A second `mbarrier.init` of a live object, with no `mbarrier.inval` between, is undefined
/// behavior even when one thread issues both and the fresh object is then used correctly.
#[test]
fn test_mbarrier_init_of_live_object_is_rejected() {
    let module = ptx!(parse "failing/mbarrier_init_of_live_object_is_rejected");
    match run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Eval(EvalError::MbarrierReinit {
            thread: ThreadId(0),
            addr: 0,
            ..
        })) => {}
        other => panic!("expected MbarrierReinit, got {other:?}"),
    }
}

/// `activemask` is rejected until warp divergence is modeled: within each side of this kernel's
/// divergent branch it holds only that side's lanes, so lanes 0 and 16 both elect themselves and
/// store `s[0]`, a race that reporting every non-exited lane would hide.
#[test]
fn test_activemask_is_not_implemented() {
    let module = parse(&ptx!("failing/activemask_is_not_implemented"));
    match run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
            let reason = reason.unwrap_or_default();
            assert!(
                reason.contains("activemask") && reason.contains("not implemented"),
                "{reason}"
            );
        }
        other => panic!("expected unsupported, got {other:?}"),
    }
}

/// Volta does not support wgmma at the moment: this kernel, whose `shf` overwrites a pending
/// accumulator, is rejected at its first wgmma instruction.
#[test]
fn test_wgmma_is_not_supported() {
    let module = parse(&ptx!("failing/wgmma_is_not_supported"));
    match run_kernel(&module, None, AnalysisConfig::new((128, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction {
            instruction,
            reason,
        })) => {
            assert_eq!(instruction, "wgmma.fence");
            assert_eq!(
                reason.as_deref(),
                Some("wgmma is not supported by Volta at the moment")
            );
        }
        other => panic!("expected unsupported, got {other:?}"),
    }
}

/// `mbarrier.init`/`inval`/`test_wait`/`try_wait` take only `.shared{::cta}`
/// (PTX ISA 9.7.15.16), so `.shared::cluster` is invalid; on `arrive` it is
/// valid but unmodeled.
#[test]
fn test_mbarrier_shared_cluster_validity() {
    for src in [
        ptx!("failing/mbarrier_shared_cluster_validity_init"),
        ptx!("failing/mbarrier_shared_cluster_validity_inval"),
        ptx!("failing/mbarrier_shared_cluster_validity_test_wait"),
        ptx!("failing/mbarrier_shared_cluster_validity_try_wait"),
    ] {
        expect_invalid_instruction(&parse(&src), "has no .shared::cluster form");
    }
    let arrive = parse(&ptx!("failing/mbarrier_shared_cluster_validity_arrive"));
    match run_kernel(&arrive, None, AnalysisConfig::new((1, 1, 1))) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
            let reason = reason.unwrap_or_default();
            assert!(reason.contains("single-CTA analysis only"), "{reason}");
        }
        other => panic!("expected unsupported, got {other:?}"),
    }
}

/// A read of never-written shared memory aborts the run once its trace completes: the abort
/// waits so that a read racing a later write (the paper's race example) keeps its race witness.
#[test]
fn test_uninitialized_shared_read_flows_to_output() {
    expect_uninitialized_read(
        &ptx!(parse "failing/uninitialized_shared_read_flows_to_output"),
        in_out_config(1, 1),
        0,
    );
}

/// The read aborts the run even when its value reaches the output only nested in an
/// expression (`out[0] = undefined + 1`), which the output check alone does not catch.
#[test]
fn test_undefined_value_nested_in_output() {
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    expect_uninitialized_read(
        &ptx!(parse "failing/undefined_value_nested_in_output"),
        config,
        0,
    );
}

#[test]
fn test_out_of_bounds_shared_access() {
    let module = ptx!(parse "failing/out_of_bounds_shared_access");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::OutOfBounds { .. })),
        "expected out-of-bounds, got: {}",
        err
    );
}

/// A 4-byte load at an address 2 mod 4 is misaligned.
#[test]
fn test_misaligned_scalar_load() {
    let module = ptx!(parse "failing/misaligned_scalar_load");
    let err = run_kernel(&module, None, in_out_config(1, 4)).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 4, .. })
        ),
        "expected misaligned access, got: {}",
        err
    );
}

/// A 4-byte store at an address 2 mod 4 is misaligned (write side of the
/// same chokepoint).
#[test]
fn test_misaligned_scalar_store() {
    let module = ptx!(parse "failing/misaligned_scalar_store");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 4, .. })
        ),
        "expected misaligned access, got: {}",
        err
    );
}

/// The access size of a vector load is the *total* bytes accessed
/// (ld.v4.f32 is one 16-byte access), so an address 4 mod 16 is misaligned
/// even though every element taken alone is 4-aligned.
#[test]
fn test_misaligned_vector_load() {
    let module = ptx!(parse "failing/misaligned_vector_load");
    let err = run_kernel(&module, None, in_out_config(1, 8)).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 16, .. })
        ),
        "expected misaligned vector access, got: {}",
        err
    );
}

/// A row address 8 mod 16 violates ldmatrix's 16-byte row alignment
/// (PTX ISA 9.7.14.5.15) even though each lane's own 4-byte read would be
/// 4-aligned.
#[test]
fn test_misaligned_ldmatrix_row_address() {
    let module = parse(&ptx!("failing/misaligned_ldmatrix_row_address"));
    let err = run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 16, .. })
        ),
        "expected misaligned ldmatrix row, got: {}",
        err
    );
}

/// A wmma base address 8 mod 32 violates the 32-byte fragment alignment
/// (PTX ISA 9.7.14.4.2) even though each f16 element read is 2-aligned.
#[test]
fn test_wmma_load_base_misaligned() {
    let module = parse(&ptx!("failing/wmma_load_base_misaligned"));
    let err = run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 32, .. })
        ),
        "expected misaligned wmma base, got: {}",
        err
    );
}

/// The store side enforces the same base alignment.
#[test]
fn test_wmma_store_base_misaligned() {
    let module = parse(&ptx!("failing/wmma_store_base_misaligned"));
    let err = run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 32, .. })
        ),
        "expected misaligned wmma store base, got: {}",
        err
    );
}

/// A stride below the leading dimension (16 elements for m16n16k16) is
/// undefined behavior by itself (PTX ISA 9.7.14.4.3).
#[test]
fn test_wmma_stride_below_default() {
    let module = parse(&ptx!("failing/wmma_stride_below_default"));
    let err = run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::WmmaStrideTooSmall {
                stride: 8,
                minimum: 16,
                ..
            })
        ),
        "expected wmma stride below default, got: {}",
        err
    );
}

/// A stride that is legal in *size* but whose byte pitch breaks the
/// 16-byte stride granularity leaves rows past the first misaligned:
/// 20 f16 elements = 40 bytes.
#[test]
fn test_wmma_stride_misaligned() {
    let module = parse(&ptx!("failing/wmma_stride_misaligned"));
    let err = run_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::Misaligned { required: 16, .. })
        ),
        "expected misaligned wmma stride, got: {}",
        err
    );
}

/// An array base that is not a multiple of the element width is rejected
/// when the analysis is configured, not per access.
#[test]
fn test_config_rejects_misaligned_array_base() {
    let module = ptx!(parse "failing/config_rejects_misaligned_array_base");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "in".to_string(),
        base: 2,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    }];
    config.params = vec![ParamValue::ArrayPtr("in".to_string())];
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::Config { .. })),
        "expected config error, got: {}",
        err
    );
}

/// A raw bit pattern that decodes to NaN is rejected loudly rather than
/// left in place as an integer: Volta's real-valued model has no NaN.
#[test]
fn test_float_op_rejects_nan_bit_pattern() {
    let module = ptx!(parse "failing/float_op_rejects_nan_bit_pattern");
    let err = run_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(what.contains("NaN"), "{what}");
        }
        other => panic!("expected Unsupported NaN, got: {}", other),
    }
}

/// Symbolic integer division is rejected rather than modeled as exact
/// rational division, which would prove `(x / 2) * 2` equal to `x`.
#[test]
fn test_symbolic_integer_div_is_unsupported() {
    let module = parse(&ptx!("failing/symbolic_integer_div_is_unsupported"));
    let err = run_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(
                what.contains("div.u32"),
                "expected the integer-division error, got: {}",
                what
            );
        }
        other => panic!("expected EvalError::Unsupported, got: {}", other),
    }
}

/// A symbolic value stored below its source register's width would need
/// a truncation node we do not model: loud error, not silent nonsense.
#[test]
fn test_symbolic_sub_register_store_rejected() {
    let src = ptx!("failing/symbolic_sub_register_store_rejected");
    let err = run_kernel(&parse(&src), None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Unsupported { what, .. })
                if what.contains("symbolic value stored")
        ),
        "expected symbolic sub-register store rejection, got: {}",
        err
    );
}

/// A symbolic scalar loaded at a type narrower than the destination
/// register would need an extension node we do not model: loud error.
#[test]
fn test_symbolic_sub_register_load_rejected() {
    let src = ptx!("failing/symbolic_sub_register_load_rejected");
    // The byte array serves as the kernel's input here: loading one of
    // its symbolic elements at s8 into a 32-bit register would need an
    // extension.
    let err = run_kernel(&parse(&src), None, u8_scratch_config()).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Unsupported { what, .. })
                if what.contains("symbolic value loaded")
        ),
        "expected symbolic sub-register load rejection, got: {}",
        err
    );
}

/// The flip side: a kernel that *keeps* that high lane (from the load's
/// `Undefined` upper byte) must get a loud `UndefinedOutput`, not a
/// fabricated `0.0`.
#[test]
fn test_e4m3x2_scalar_source_high_lane_is_undefined_not_fabricated() {
    let module = ptx!(parse "failing/e4m3x2_scalar_source_high_lane_is_undefined_not_fabricated");
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
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(&err, AnalysisError::Eval(EvalError::UndefinedOutput { .. })),
        "expected UndefinedOutput for the discarded/kept high lane, got: {}",
        err
    );
}

/// Storing a packed f16x2 pair (a 32-bit value) at a sub-4-byte width would
/// stuff both halves into one 2-byte granule: a loud error, not silent
/// nonsense.
#[test]
fn test_pair_sub_width_store_rejected() {
    let module = ptx!(parse "failing/pair_sub_width_store_rejected");
    let err = run_kernel(&module, None, u8_scratch_config()).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Unsupported { what, .. })
                if what.contains("pair stored")
        ),
        "expected pair sub-width store rejection, got: {}",
        err
    );
}

/// Branching on input data violates structured-CTA.
#[test]
fn test_symbolic_branch_rejected() {
    let module = ptx!(parse "failing/symbolic_branch_rejected");
    let err = run_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::NotConcrete { .. })),
        "expected structured-CTA violation, got: {}",
        err
    );
}

/// A NaN literal (0f7FC00000) is rejected at lowering: NaN denotes no
/// real number, so it cannot enter the analysis model.
#[test]
fn test_nan_literal_rejected_at_lowering() {
    let module = ptx!(parse "failing/nan_literal_rejected_at_lowering");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Lower(_)),
        "expected lowering rejection of the NaN literal, got: {}",
        err
    );
    assert!(
        err.to_string().contains("NaN literal"),
        "unexpected message: {}",
        err
    );
}

/// A NaN float parameter is a config validation error.
#[test]
fn test_nan_float_param_rejected() {
    let src = ptx!("failing/nan_float_param_rejected");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.params = vec![ParamValue::Float(f64::NAN)];
    let err = run_kernel(&parse(&src), None, config).unwrap_err();
    assert!(
        matches!(&err, AnalysisError::Eval(EvalError::Config { message }) if message.contains("NaN")),
        "expected NaN config validation error, got: {}",
        err
    );
}

/// `0.0 / 0.0` no longer mints a NaN: the division stays a symbolic node
/// and the decision procedure errors loudly on the formally-zero
/// denominator when the element is checked.
#[test]
fn test_zero_over_zero_is_a_loud_equivalence_error() {
    let src = ptx!("failing/zero_over_zero_is_a_loud_equivalence_error");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let a = run_kernel(&parse(&src), None, config.clone()).unwrap();
    // The output expression is the unfolded division, not a constant.
    assert_eq!(display_output(&a, "out", 0), "(0 / 0)");
    let b = run_kernel(&parse(&src), None, config).unwrap();
    let arrays: Vec<String> = a.exprs.outputs.iter().map(|(n, _)| n.clone()).collect();
    let err = check_output_equivalence(&a.exprs, &b.exprs, &arrays).unwrap_err();
    assert!(
        err.to_string().contains("division"),
        "expected a division-by-zero equivalence error, got: {}",
        err
    );
}

/// A shfl value sourced from an exited in-mask lane is Undefined (ISA:
/// "results are undefined if a thread sources a register from an inactive
/// thread"); the group still fires.
#[test]
fn test_shfl_from_exited_lane_is_undefined() {
    let module = ptx!(parse "failing/shfl_from_exited_lane_is_undefined");
    // Lanes 8..15 source exited lanes 16..23 and store the Undefined result.
    let err = run_kernel(&module, None, in_out_config(32, 16)).unwrap_err();
    assert!(
        matches!(err, AnalysisError::Eval(EvalError::UndefinedOutput { .. })),
        "expected undefined output from exited source lane, got: {}",
        err
    );
}

/// The paper's own §6.2 pattern: `__shared__ int A[48]` read at
/// `A[tid]` by 64 threads - threads 48..63 read out of bounds and must be
/// caught (hardware happens to tolerate this; the model must not).
#[test]
fn test_shared_array_overflow_read_is_out_of_bounds() {
    let module = ptx!(parse "failing/shared_array_overflow_read_is_out_of_bounds");
    let err = run_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::OutOfBounds { addr: 192, .. })
        ),
        "expected out-of-bounds at A+192, got: {}",
        err
    );
}

/// A v4 load starting in shared array A whose tail runs into adjacent B: the
/// whole-footprint ownership check makes it a loud OutOfBounds, not a silent
/// neighbor read.
#[test]
fn test_vector_straddling_adjacent_shared_arrays() {
    let module = ptx!(parse "failing/vector_straddling_adjacent_shared_arrays");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::OutOfBounds {
                addr: 32,
                width: 16,
                ..
            })
        ),
        "expected the v4 straddle to be out of bounds, got: {}",
        err
    );
}

/// `x[tid - 1]` at tid = 0 with the array at address 0 wraps to
/// 0xFFFF_FFFF_FFFF_FFFC; the subtraction-form bounds check rejects it in
/// every build profile, including release.
#[test]
fn test_negative_index_wrap_is_out_of_bounds() {
    let module = ptx!(parse "failing/negative_index_wrap_is_out_of_bounds");
    let mut config = in_out_config(1, 4);
    config.arrays[0].base = 0; // x based at 0: base + (-4) wraps
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(
            err,
            AnalysisError::Eval(EvalError::OutOfBounds { addr, width: 4, .. })
                if addr == u64::MAX - 3
        ),
        "expected the wrapped address to be out of bounds, got: {}",
        err
    );
}

/// A config array overlapping the reserved module-global window is a loud
/// setup error, not a silent shadowing: both families land in the one
/// global region list, whose disjointness `check_bounds` relies on.
#[test]
fn test_array_overlapping_module_global_window_rejected() {
    const MODULE_GLOBAL_BASE: u64 = 0x7000_0000_0000_0000;
    let module = ptx!(parse "failing/array_overlapping_module_global_window_rejected");

    // The probe scenario: an array based exactly at the module-global
    // base, covering the global `g`.
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays.push(ArrayDef {
        name: "in".to_string(),
        base: MODULE_GLOBAL_BASE,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    });
    let err = run_kernel(&module, None, config.clone()).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Config { message })
                if message.contains("module-global")
        ),
        "expected a module-global overlap config error, got: {}",
        err
    );

    // Range overlap, not just base membership: an array based below the
    // window whose tail reaches into it is rejected too.
    config.arrays[0].base = MODULE_GLOBAL_BASE - 8;
    let err = run_kernel(&module, None, config).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Eval(EvalError::Config { message })
                if message.contains("module-global")
        ),
        "expected a module-global overlap config error, got: {}",
        err
    );
}

/// A shared declaration whose byte size overflows u64 (2^31 * 2^31 u32
/// elements) is rejected at lowering; release-wrapping would silently give it
/// a tiny size.
#[test]
fn test_hostile_shared_declaration_size_rejected() {
    let module = ptx!(parse "failing/hostile_shared_declaration_size_rejected");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    assert!(
        matches!(
            &err,
            AnalysisError::Lower(LowerError::VariableSizeOverflow { what }) if what.contains("A")
        ),
        "expected a variable-size overflow error, got: {}",
        err
    );
}

/// Other cvta forms are rejected by name: `cvta.global` is compatible but
/// unused by the corpus, while shared/local forms would mint addresses in the
/// wrong space.
#[test]
fn test_cvta_other_forms_rejected() {
    for (expect, reason_fragment, (form, src)) in [
        (
            "cvta.global",
            "corpus",
            ptx_case!("failing/cvta_other_forms_rejected_global"),
        ),
        (
            "cvta.shared",
            "per-space windows",
            ptx_case!("failing/cvta_other_forms_rejected_shared"),
        ),
        (
            "cvta.to.shared",
            "per-space windows",
            ptx_case!("failing/cvta_other_forms_rejected_to_shared"),
        ),
    ] {
        let module = parse(&src);
        let err = run_kernel(&module, None, in_out_config(1, 1)).unwrap_err();
        match &err {
            AnalysisError::Lower(LowerError::UnsupportedInstruction {
                instruction,
                reason,
            }) => {
                assert_eq!(instruction, expect, "wrong instruction name for {}", form);
                assert!(
                    reason.as_deref().unwrap_or("").contains(reason_fragment),
                    "reason for {} should mention '{}', got: {:?}",
                    form,
                    reason_fragment,
                    reason
                );
            }
            other => panic!(
                "expected UnsupportedInstruction for {}, got: {}",
                form, other
            ),
        }
    }
}

/// `copysign.f16` parses (the type parser accepts any `ScalarType`), so
/// `lower_copysign`'s `.f32`/`.f64` restriction must reject it with a
/// specific reason.
#[test]
fn test_copysign_rejects_a_type_other_than_f32_f64() {
    let module = ptx!(parse "failing/copysign_rejects_a_type_other_than_f32_f64");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Lower(LowerError::UnsupportedInstruction { instruction, .. }) => {
            assert_eq!(instruction, "copysign");
        }
        other => panic!("expected UnsupportedInstruction, got: {}", other),
    }
}

/// `0x7F` is `.e4m3`'s NaN (PTX ISA 5.2.3); Volta's real-valued model cannot
/// represent NaN, so a concrete byte hitting it must error loudly.
#[test]
fn test_e4m3x2_rejects_the_concrete_nan_byte_pattern() {
    let module = ptx!(parse "failing/e4m3x2_rejects_the_concrete_nan_byte_pattern");
    let err = run_kernel(&module, None, AnalysisConfig::new((1, 1, 1))).unwrap_err();
    match &err {
        AnalysisError::Eval(EvalError::Unsupported { what, .. }) => {
            assert!(what.contains("NaN"), "unexpected message: {}", what);
        }
        other => panic!("expected Unsupported (NaN byte), got: {}", other),
    }
}

fn analyze_one_thread(module: &Ptx) -> Result<Completed, AnalysisError> {
    run_kernel(module, None, AnalysisConfig::new((1, 1, 1)))
}

/// Every `try_cancel` response is declined, so an unguarded `get_first_ctaid`
/// decodes a declined response: undefined behavior.
#[test]
fn test_clusterlaunchcontrol_unguarded_get_first_ctaid_is_rejected() {
    let module = ptx!(parse "failing/clusterlaunchcontrol_unguarded_get_first_ctaid_is_rejected");
    match analyze_one_thread(&module) {
        Err(AnalysisError::Eval(EvalError::ClusterLaunchControlMisuse { misuse, .. })) => {
            assert_eq!(misuse, ClcMisuse::CtaidOfDeclinedResponse);
        }
        other => panic!("expected ClusterLaunchControlMisuse, got {other:?}"),
    }
}

/// A second `try_cancel` after `is_canceled` observed the first one declined
/// is undefined behavior.
#[test]
fn test_clusterlaunchcontrol_try_cancel_after_observed_decline_is_rejected() {
    let module =
        ptx!(parse "failing/clusterlaunchcontrol_try_cancel_after_observed_decline_is_rejected");
    match analyze_one_thread(&module) {
        Err(AnalysisError::Eval(EvalError::ClusterLaunchControlMisuse { misuse, .. })) => {
            assert!(
                matches!(
                    misuse,
                    ClcMisuse::RequestAfterObservedDecline {
                        observer: ThreadId(0),
                        ..
                    }
                ),
                "{misuse:?}"
            );
        }
        other => panic!("expected ClusterLaunchControlMisuse, got {other:?}"),
    }
}

/// `query_cancel` only decodes the declined response a `try_cancel` wrote;
/// anything else would be a successful cancel, outside the never-steal model.
#[test]
fn test_clusterlaunchcontrol_query_of_a_fabricated_response_is_rejected() {
    let module =
        ptx!(parse "failing/clusterlaunchcontrol_query_of_a_fabricated_response_is_rejected");
    match analyze_one_thread(&module) {
        Err(AnalysisError::Eval(EvalError::Unsupported { what, .. })) => {
            assert!(
                what.contains("not a declined try_cancel response"),
                "{what}"
            );
        }
        other => panic!("expected Unsupported, got {other:?}"),
    }
}

/// `.multicast::cluster::all` writes the response into every CTA of the
/// cluster, beyond the single CTA Volta analyzes.
#[test]
fn test_clusterlaunchcontrol_multicast_try_cancel_is_rejected() {
    let module = ptx!(parse "failing/clusterlaunchcontrol_multicast_try_cancel_is_rejected");
    match analyze_one_thread(&module) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
            let reason = reason.unwrap_or_default();
            assert!(reason.contains("multicast::cluster::all"), "{reason}");
        }
        other => panic!("expected UnsupportedInstruction, got {other:?}"),
    }
}

/// Clusters are assumed to hold a single CTA, so `mapa` into rank 1 names a
/// CTA outside the cluster.
#[test]
fn test_mapa_nonzero_rank_is_rejected() {
    let module = ptx!(parse "failing/mapa_nonzero_rank_is_rejected");
    match analyze_one_thread(&module) {
        Err(AnalysisError::Eval(EvalError::MapaRankOutsideCluster { rank: 1, .. })) => {}
        other => panic!("expected MapaRankOutsideCluster, got {other:?}"),
    }
}

/// Generic addresses have no per-space windows, so generic `mapa` is rejected.
#[test]
fn test_mapa_generic_is_rejected() {
    let module = ptx!(parse "failing/mapa_generic_is_rejected");
    match analyze_one_thread(&module) {
        Err(AnalysisError::Lower(LowerError::UnsupportedInstruction { reason, .. })) => {
            let reason = reason.unwrap_or_default();
            assert!(reason.contains("generic addressing"), "{reason}");
        }
        other => panic!("expected UnsupportedInstruction, got {other:?}"),
    }
}
