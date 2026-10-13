//! Evaluator tests on well-formed, race-free kernels: each analysis
//! succeeds and the output expressions, stats or equivalence verdicts
//! are checked.

#[macro_use]
mod common;

use std::path::PathBuf;
use volta_analysis::driver::{EquivOutcome, analyze_kernel, check_output_equivalence};
use volta_analysis::eval::{AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, ParamValue};
use volta_analysis::numeric;
use volta_frontend::ast::Module;

use common::*;

/// Check equivalence along the reference run's output arrays.
fn check_equiv(a: &AnalysisOutput, b: &AnalysisOutput) -> EquivOutcome {
    let arrays: Vec<String> = a.outputs.iter().map(|(n, _)| n.clone()).collect();
    check_output_equivalence(a, b, &arrays).unwrap()
}

/// The volta_bench paper-benchmark kernel tree (PTX + CUDA sources).
const KERNELS_DIR: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/../volta_bench/kernels");

fn parse_file(rel: &str) -> Module {
    let path = PathBuf::from(KERNELS_DIR).join(rel);
    let src =
        std::fs::read_to_string(&path).unwrap_or_else(|e| panic!("read {}: {}", path.display(), e));
    parse(&src)
}

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

/// Config for the reduction kernels: int arrays, `n` input elements.
fn reduction_config(threads: u32, n: u64) -> AnalysisConfig {
    let mut config = AnalysisConfig::new((threads, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len: n,
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
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

fn run_reduction(
    file: &str,
    kernel: &str,
    threads: u32,
    n: u64,
    dynamic_shared: u64,
) -> AnalysisOutput {
    let module = parse_file(file);
    let mut config = reduction_config(threads, n);
    config.dynamic_shared_bytes = dynamic_shared;
    analyze_kernel(&module, Some(kernel), config)
        .unwrap_or_else(|e| panic!("{} failed: {}", file, e))
}

fn red1() -> AnalysisOutput {
    run_reduction(
        "01_reduction/Red-1.ptx",
        "_Z17reduce1024_1blockPKiPi",
        128,
        128,
        0,
    )
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

// Two threads, two f32 elements each: `out[i] = in[i] * in[i] + in[i]`;
// each body maps `{%f1, %f2}` to `{%f3, %f4}`, or `[%rd4]` to `[%rd5]` for
// 64-bit memory variants.
fn f32x2_outcome(candidate: &str) -> EquivOutcome {
    let reference = analyze_kernel(
        &parse(&ptx!("eval/f32x2_scalar_reference")),
        None,
        in_out_config(2, 4),
    )
    .unwrap();
    let candidate = analyze_kernel(&parse(candidate), None, in_out_config(2, 4)).unwrap();
    check_equiv(&reference, &candidate)
}

/// Neighbor exchange through shared memory, correctly synchronized:
/// out[tid] = in[tid ^ 1].
#[test]
fn test_shared_exchange_with_barrier() {
    let module = ptx!(parse "eval/shared_exchange_with_barrier");
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[1]");
    assert_eq!(display_output(&output, "out", 1), "in[0]");
    assert_eq!(output.stats.block_syncs, 2);
}

/// Unsynchronized accesses to the extern window and to a static `.shared`
/// variable from different threads are not a race: the regions are disjoint.
#[test]
fn test_extern_vs_static_shared_no_false_race() {
    let module = ptx!(parse "eval/extern_vs_static_shared_no_false_race");
    let mut config = in_out_config(2, 1);
    config.dynamic_shared_bytes = 16;
    let output = analyze_kernel(&module, None, config)
        .expect("disjoint extern/static shared accesses must not race");
    assert_eq!(display_output(&output, "out", 0), "7");
}

/// A thread that exits counts as having arrived at the barrier (paper's
/// Sync rule allows `return`), so this does NOT deadlock.
#[test]
fn test_exited_thread_releases_barrier() {
    let module = ptx!(parse "eval/exited_thread_releases_barrier");
    analyze_kernel(&module, None, AnalysisConfig::new((2, 1, 1))).unwrap();
}

/// `mbarrier.init` with `count = 2` needs both threads' `arrive` before
/// `try_wait.parity` proceeds: the scheduler wakes a thread when a
/// *different* thread's arrive completes the phase.
#[test]
fn test_mbarrier_wait_wakes_on_another_threads_arrive() {
    let module = ptx!(parse "eval/mbarrier_wait_wakes_on_another_threads_arrive");
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "1");
}

/// `mbarrier.arrive.expect_tx` + `mbarrier.complete_tx` end to end: the wait
/// is not satisfied by the arrival alone, only once `complete_tx` clears the
/// outstanding transaction.
#[test]
fn test_mbarrier_expect_tx_blocks_until_complete_tx() {
    let module = ptx!(parse "eval/mbarrier_expect_tx_blocks_until_complete_tx");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// `mbarrier.arrive`/`try_wait.parity` is a χ happens-before edge (PTX ISA
/// 9.7.14.16.19): thread 0 writes then arrives, thread 1 waits then reads,
/// with no race reported.
#[test]
fn test_mbarrier_arrive_wait_establishes_happens_before() {
    let module = ptx!(parse "eval/mbarrier_arrive_wait_establishes_happens_before");
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 1), "42");
}

/// `tcgen05.fence::before_thread_sync`/`::after_thread_sync` parse (via the
/// `::`-glued trie fallback) and are pure ordering fences: eval just falls
/// through.
#[test]
fn test_tcgen05_fence_is_a_no_op() {
    let module = ptx!(parse "eval/tcgen05_fence_is_a_no_op");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// `tcgen05.commit`'s `.mbarrier::arrive::one` alone satisfies a `count = 1`
/// mbarrier's `try_wait.parity`; `.shared::cluster` covers the optional
/// state-space path.
#[test]
fn test_tcgen05_commit_satisfies_mbarrier_wait() {
    let module = ptx!(parse "eval/tcgen05_commit_satisfies_mbarrier_wait");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// `tcgen05.ld`/`.st` decode `taddr` as a Tensor Memory address (PTX ISA
/// 9.7.17.1.1: `[31:16]=lane, [15:0]=column`): two warps each pack their own
/// quadrant and read back exactly their own value.
#[test]
fn test_tcgen05_st_ld_respects_warp_quadrant_addressing() {
    let module = ptx!(parse "eval/tcgen05_st_ld_respects_warp_quadrant_addressing");
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 64,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "0");
    assert_eq!(display_output(&output, "out", 31), "0");
    assert_eq!(display_output(&output, "out", 32), "1");
    assert_eq!(display_output(&output, "out", 63), "1");
}

/// The control: the same `.ld`/`.st` waited *before* the arrivals pass.
#[test]
fn test_tcgen05_wait_before_sync_is_accepted() {
    let module = parse(&ptx!("eval/tcgen05_wait_before_sync_is_accepted"));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// The control: the same `.ld`/`.st` waited before the `tcgen05.dealloc`
/// pass.
#[test]
fn test_tcgen05_dealloc_after_waiting_is_accepted() {
    let module = parse(&ptx!("eval/tcgen05_dealloc_after_waiting_is_accepted"));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// `tensormap.replace` (8x8 f16 map built in shared) +
/// `cp.async.bulk.tensor`: a 4x4 box at (6, 6) reads input in bounds and
/// `fill_mode` zeros past `global_dim`; `complete_tx` unblocks the wait.
#[test]
fn test_cp_async_bulk_tensor_cta_and_cluster_destinations_copy_in_bounds() {
    for (scope, src) in [
        (
            "cluster",
            ptx!("eval/cp_async_bulk_tensor_cta_and_cluster_destinations_copy_in_bounds"),
        ),
        (
            "cta",
            ptx!("eval/cp_async_bulk_tensor_cta_and_cluster_destinations_copy_in_bounds_cta"),
        ),
    ] {
        let module = parse(&src);
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
        let output = analyze_kernel(&module, None, config).unwrap();
        assert_eq!(display_output(&output, "out", 0), "in[54]", "{scope}");
        assert_eq!(display_output(&output, "out", 1), "0", "{scope}");
    }
}

/// `elect.sync` elects the lowest *live* lane in the mask (PTX ISA
/// 9.7.14.15): with a full warp, lane 0 gets `dst = 0` and `dst_pred` true;
/// each thread encodes both as one f32.
#[test]
fn test_elect_sync_elects_the_lowest_active_lane() {
    let module = ptx!(parse "eval/elect_sync_elects_the_lowest_active_lane");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 32,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1000");
    assert_eq!(display_output(&output, "out", 1), "0");
    assert_eq!(display_output(&output, "out", 31), "0");
}

/// Same shape, but lane 0 exits before `elect.sync`: exited lanes count as
/// arrived but cannot be leader, so lane 1 is elected.
#[test]
fn test_elect_sync_skips_an_already_exited_lane() {
    let module = ptx!(parse "eval/elect_sync_skips_an_already_exited_lane");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 32,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 1), "1001");
    assert_eq!(display_output(&output, "out", 5), "0");
}

/// `tcgen05.mma` with `triton_generated.ptx`'s exact `idesc`/descriptors
/// (`.kind::f16`, M=128, N=256, 128B swizzle) over uninitialized shared
/// buffers: every `(m, n, k)` address must land in bounds.
#[test]
fn test_tcgen05_mma_real_kernel_descriptors_run_to_completion() {
    let module = ptx!(parse "eval/tcgen05_mma_real_kernel_descriptors_run_to_completion");
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// A synthetic `.kind::f16` `tcgen05.mma` (M=128, N=8) with
/// `SwizzleMode::None` K-major descriptors packed at 32 bytes/row reaches
/// `exec_tcgen05_mma`'s addressing end to end.
#[test]
fn test_tcgen05_mma_no_swizzle_mode_runs_to_completion() {
    let module = ptx!(parse "eval/tcgen05_mma_no_swizzle_mode_runs_to_completion");
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).unwrap();
}

/// LLVM's NVPTX backend emits 5-operand `tcgen05.mma` with no
/// `disable-output-lane`, so the mask is optional (no lane disabled): like
/// `test_tcgen05_mma_numeric_correctness`, must produce `136`.
#[test]
fn test_tcgen05_mma_without_an_explicit_disable_output_lane_mask() {
    let module = ptx!(parse "eval/tcgen05_mma_without_an_explicit_disable_output_lane_mask");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "136");
}

/// `tcgen05.mma` decodes concrete operands from their bits: `A`/`B` hold raw
/// f16 `0x3C00` (1.0, not 15360) and `D` is seeded with raw f32 1.0 via
/// `tcgen05.st`, so `D[0][0] = 16 + 1 = 17`.
#[test]
fn test_tcgen05_mma_decodes_raw_operand_and_accumulator_bits() {
    let module = ptx!(parse "eval/tcgen05_mma_decodes_raw_operand_and_accumulator_bits");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "17");
}

/// Numeric check: `A[0][k] = k+1` and `B[k][0] = 1` as f16 at hand-computed
/// 128B-swizzled addresses (B transposed, crossing a stride atom at `k=8`);
/// `D[0][0]` must read back as `136`.
#[test]
fn test_tcgen05_mma_numeric_correctness() {
    let module = ptx!(parse "eval/tcgen05_mma_numeric_correctness");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "136");
}

/// The control: a `bar.sync` *after* warp 0 observed the completion does
/// order the MMA before warp 1's read.
#[test]
fn test_tcgen05_mma_bar_sync_after_completion_orders_the_read() {
    let module = parse(&ptx!(
        "eval/tcgen05_mma_bar_sync_after_completion_orders_the_read"
    ));
    analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap();
}

/// The control: warp 1 waiting on `mma_bar` itself is ordered after the
/// completion, whatever `bar.sync` ran before it.
#[test]
fn test_tcgen05_mma_every_reader_waiting_is_accepted() {
    let module = parse(&ptx!("eval/tcgen05_mma_every_reader_waiting_is_accepted"));
    analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap();
}

/// The control: deallocating after waiting on `mma_bar` is accepted.
#[test]
fn test_tcgen05_dealloc_after_the_mma_completed_is_accepted() {
    let module = parse(&ptx!(
        "eval/tcgen05_dealloc_after_the_mma_completed_is_accepted"
    ));
    analyze_kernel(&module, None, AnalysisConfig::new((64, 1, 1))).unwrap();
}

/// `.kind::f8f6f4` with e4m3 `A`, e5m2 `B`, K = 32, `SwizzleMode::None` (`LBO
/// = 128`): `D[0][0] = 136 + 2 * 136 = 408` holds only with 1-byte elements,
/// `LBO` stepping and per-operand decoders.
#[test]
fn test_tcgen05_mma_kind_f8f6f4_numeric_correctness() {
    let module = ptx!(parse "eval/tcgen05_mma_kind_f8f6f4_numeric_correctness");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "408");
}

/// 2-byte accesses at addresses 2 mod 4 are *naturally aligned* (natural
/// alignment is relative to the access size, not any fixed width): the
/// ordinary f16 access pattern must keep working.
#[test]
fn test_aligned_u16_access_at_2_mod_4() {
    let module = ptx!(parse "eval/aligned_u16_access_at_2_mod_4");
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
    let output = analyze_kernel(&module, None, config).expect("aligned u16 access");
    assert_eq!(display_output(&output, "out", 1), "in[1]");
}

/// The same vector load at a 16-byte boundary is legal.
#[test]
fn test_aligned_vector_load() {
    let module = ptx!(parse "eval/aligned_vector_load");
    let output = analyze_kernel(&module, None, in_out_config(1, 8)).expect("aligned v4 load");
    assert_eq!(display_output(&output, "out", 0), "in[3]");
}

/// A vector store's source list may mix immediates with registers (nvcc's
/// `{%f1, 0f00000000, %f2, 0f3F800000}` init idiom), unlike a vector load's
/// destination.
#[test]
fn test_vector_store_with_immediate_source() {
    let module = ptx!(parse "eval/vector_store_with_immediate_source");
    let mut config = in_out_config(1, 8);
    config.arrays[1].len = 4; // out: exactly the 4 stored elements
    let output = analyze_kernel(&module, None, config).expect("vector store with immediate");
    assert_eq!(display_output(&output, "out", 0), "in[0]");
    assert_eq!(display_output(&output, "out", 1), "0");
    assert_eq!(display_output(&output, "out", 2), "in[1]");
    assert_eq!(display_output(&output, "out", 3), "1");
}

// Full-warp ldmatrix.x4 kernels; each lane supplies the row address
// `sdata + tid*16 + extra` (lane i*8+r owns row r of matrix i).

/// ldmatrix row addresses are legal at 16-byte boundaries: each 8x8 b16
/// matrix row is fetched by four lanes as one 16-byte access.
#[test]
fn test_aligned_ldmatrix() {
    let module = parse(&ptx!("eval/aligned_ldmatrix"));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("aligned ldmatrix");
}

/// `ldmatrix.trans.x1`: lane `l` gets (row `2*(l%4)`, col `l/4`) low and (row
/// `2*(l%4)+1`, col `l/4`) high, the transpose of the plain mapping; outputs
/// are checked against `in[expected_index]`.
#[test]
fn test_ldmatrix_trans_mapping() {
    let module = ptx!(parse "eval/ldmatrix_trans_mapping");
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
    let output = analyze_kernel(&module, None, config).expect("ldmatrix.trans mapping");

    for lane in 0u64..32 {
        let row_lo = 2 * (lane % 4);
        let row_hi = row_lo + 1;
        let col = lane / 4;
        let expect_lo = row_lo * 8 + col;
        let expect_hi = row_hi * 8 + col;
        assert_eq!(
            display_output(&output, "out", 2 * lane),
            format!("in[{}]", expect_lo),
            "lane {} low half",
            lane
        );
        assert_eq!(
            display_output(&output, "out", 2 * lane + 1),
            format!("in[{}]", expect_hi),
            "lane {} high half",
            lane
        );
    }
}

/// `mma.sync`'s accumulator may be an immediate (nvcc's `{0f00000000, ...}`
/// first-tile idiom): with all-zero packed A/B, `D = C`, so thread 0's
/// registers get the literal `{1.0, 0, 0, 0}`.
#[test]
fn test_mma_with_immediate_accumulator() {
    let module = ptx!(parse "eval/mma_with_immediate_accumulator");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 128,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).expect("mma with immediate accumulator");
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "0");
    assert_eq!(display_output(&output, "out", 2), "0");
    assert_eq!(display_output(&output, "out", 3), "0");
}

/// An `mma.sync` f32 accumulator holding a raw bit pattern (`mov.b32`) is
/// decoded as f32 bits: thread 0's `D[0][0]` is 1.0, not 1065353216.
#[test]
fn test_mma_accumulator_register_decodes_raw_bits() {
    let module = ptx!(parse "eval/mma_accumulator_register_decodes_raw_bits");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 128,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).expect("mma with bit-pattern accumulator");
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "0");
}

// Full-warp wmma.load.a / wmma.store.d kernels with base `sdata + extra`
// and a stride in f16 (load) or f32 (store) elements.

/// wmma with a 32-byte-aligned base and the default stride (16 elements)
/// is legal, for both the f16 a-fragment load and the f32 d-fragment store.
#[test]
fn test_aligned_wmma_load_and_store() {
    let module = parse(&ptx!("eval/aligned_wmma_load_and_store_load"));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("aligned wmma.load");

    let module = parse(&ptx!("eval/aligned_wmma_load_and_store_store"));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("aligned wmma.store");
}

/// A stride *larger* than the default is explicitly allowed (a submatrix
/// of a larger matrix) as long as it keeps rows aligned.
#[test]
fn test_wmma_stride_above_default_is_legal() {
    let module = parse(&ptx!("eval/wmma_stride_above_default_is_legal"));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("stride-32 wmma.load");
}

/// nvcc's bank-conflict skew (`half tile[..][16 + 8]`, Conv2D-opt) gives a
/// 48-byte stride: not a multiple of the 32-byte fragment but 16-byte
/// aligned, which must stay legal.
#[test]
fn test_wmma_skewed_stride_is_legal() {
    let module = parse(&ptx!("eval/wmma_skewed_stride_is_legal"));
    analyze_kernel(&module, None, AnalysisConfig::new((32, 1, 1))).expect("stride-24 wmma.load");
}

/// nvcc's u16 magic-number division (Conv2D-opt): the immediate -17873 is u16
/// 47663 = ceil(2^19/11), so `mul.wide.u16` operands are reinterpreted as
/// unsigned.
#[test]
fn test_mul_wide_u16_magic_division() {
    let module = ptx!(parse "eval/mul_wide_u16_magic_division");
    let output = analyze_kernel(&module, None, in_out_config(1, 2)).expect("analysis");
    // 14 / 11 = 1, 14 % 11 = 3.
    assert_eq!(display_output(&output, "out", 0), "1");
    assert_eq!(display_output(&output, "out", 1), "3");
}

/// `mul.hi.u32` must zero-extend a canonically-signed operand: the high
/// half of 0xFFFFFFFF * 2 is 1, not -1's sign fill.
#[test]
fn test_mul_hi_u32_negative_operand() {
    let module = ptx!(parse "eval/mul_hi_u32_negative_operand");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "1");
}

/// `shf`'s shift amount is `.u32`: `-1` is 0xFFFFFFFF, which `.clamp`
/// saturates to 32 (left gives `lo`, right `hi`) - not 0; `.wrap` takes the
/// low 5 bits, i.e. 31.
#[test]
fn test_shf_clamp_negative_shift_amount_saturates() {
    let module = ptx!(parse "eval/shf_clamp_negative_shift_amount_saturates");
    let output = analyze_kernel(&module, None, in_out_config(1, 4)).expect("analysis");
    // shf.l.clamp, n = min(0xFFFFFFFF, 32) = 32: the whole of hi is shifted
    // out and lo fills the result, so d = lo = 0x11111111.
    assert_eq!(
        display_output(&output, "out", 0),
        0x1111_1111u32.to_string()
    );
    // shf.r.clamp, n = 32: the whole of lo is shifted out and hi fills the
    // result, so d = hi = 0x22222222.
    assert_eq!(
        display_output(&output, "out", 1),
        0x2222_2222u32.to_string()
    );
    // shf.l.wrap, n = 0xFFFFFFFF & 0x1f = 31:
    // d = (hi << 31) | (lo >> 1) = 0 | 0x08888888.
    assert_eq!(
        display_output(&output, "out", 2),
        0x0888_8888u32.to_string()
    );
    // shf.r.wrap, n = 31: d = (hi << 1) | (lo >> 31) = 0x44444444 | 0.
    assert_eq!(
        display_output(&output, "out", 3),
        0x4444_4444u32.to_string()
    );
}

/// A shift's amount is `.u32` for every operand type, so a `.b16` shift
/// by 0x10000 is over-wide (>= 16), not a shift by 0x10000 & 0xFFFF = 0.
#[test]
fn test_b16_shift_amount_is_read_as_u32() {
    let module = ptx!(parse "eval/b16_shift_amount_is_read_as_u32");
    let output = analyze_kernel(&module, None, in_out_config(1, 3)).expect("analysis");
    // shl.b16 1 by >= 16: every bit is shifted out, so d = 0 (not 1).
    assert_eq!(display_output(&output, "out", 0), "0");
    // shr.u16 0x8000 by >= 16: logical shift, so d = 0 (not 0x8000).
    assert_eq!(display_output(&output, "out", 1), "0");
    // shr.s16 0x8000 by >= 16: arithmetic shift fills with the sign bit,
    // so d = 0xFFFF (not 0x8000).
    assert_eq!(display_output(&output, "out", 2), 0xFFFFu32.to_string());
}

/// Integer `abs` re-reads a concrete operand at its signed width: 0xFFFFFFFB
/// is -5 to `abs.s32`, and the result wraps (`abs.s32` of i32::MIN is
/// i32::MIN).
#[test]
fn test_int_abs_read_at_signed_width() {
    let module = ptx!(parse "eval/int_abs_read_at_signed_width");
    let output = analyze_kernel(&module, None, in_out_config(1, 2)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "5");
    assert_eq!(
        display_output(&output, "out", 1),
        0x8000_0000u32.to_string()
    );
}

/// `abs.f32` decodes a raw bit pattern first: 0xC0A00000 (-5.0) gives 5.0 and
/// 0xFF800000 (-inf) gives inf. A symbolic operand stays an `abs` node.
#[test]
fn test_float_abs_decodes_raw_bits() {
    let module = ptx!(parse "eval/float_abs_decodes_raw_bits");
    let output = analyze_kernel(&module, None, in_out_config(1, 3)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "5");
    assert_eq!(display_output(&output, "out", 1), "inf");
    assert_eq!(display_output(&output, "out", 2), "abs(in[0])");
}

/// Every float consumer decodes a raw `mov.b32`/`mov.b16` bit pattern
/// (0x3F800000 is 1.0): `fma`, `rcp`/`sqrt`, both `copysign` operands, and
/// float-to-float `cvt` (f16 0x3C00).
#[test]
fn test_float_ops_decode_raw_bit_patterns() {
    let module = ptx!(parse "eval/float_ops_decode_raw_bit_patterns");
    let output = analyze_kernel(&module, None, in_out_config(1, 6)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "2");
    assert_eq!(display_output(&output, "out", 1), "0.25");
    assert_eq!(display_output(&output, "out", 2), "sqrt(4)");
    assert_eq!(display_output(&output, "out", 3), "1");
    assert_eq!(display_output(&output, "out", 4), "-4");
    assert_eq!(display_output(&output, "out", 5), "(-abs(in[0]))");
}

/// Mixed precision `fma.rn.f32.f16` decodes its multiplicands as f16 bits
/// and only its accumulator as f32 bits: `0x3C00 * 0x4000 + 0x3F800000`
/// is `1 * 2 + 1 = 3`.
#[test]
fn test_mixed_precision_fma_decodes_multiplicands_at_their_own_type() {
    let module = ptx!(parse "eval/mixed_precision_fma_decodes_multiplicands_at_their_own_type");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "3");
}

/// `neg` re-reads a concrete operand as its type: 0xFFFFFFFB is -5 to
/// `neg.s32` (i32::MIN wraps to itself); `neg.f32` decodes raw bits
/// (0xC0A00000 is -5.0). Symbolic stays a `neg` node.
#[test]
fn test_neg_reads_operand_as_instruction_type() {
    let module = ptx!(parse "eval/neg_reads_operand_as_instruction_type");
    let output = analyze_kernel(&module, None, in_out_config(1, 5)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "5");
    assert_eq!(
        display_output(&output, "out", 1),
        0x8000_0000u32.to_string()
    );
    assert_eq!(display_output(&output, "out", 2), "5");
    assert_eq!(display_output(&output, "out", 3), "inf");
    assert_eq!(display_output(&output, "out", 4), "(-in[0])");
}

/// `shl.b64`/`shr.b64` take their shift amount in a `.u32` register, as
/// the ISA types it - not rejected as a width mismatch against `.b64`.
#[test]
fn test_b64_shift_by_u32_register() {
    let module = ptx!(parse "eval/b64_shift_by_u32_register");
    let mut config = in_out_config(1, 2);
    for array in &mut config.arrays {
        array.elem_width = 8;
    }
    let output = analyze_kernel(&module, None, config).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), (3u64 << 40).to_string());
    assert_eq!(display_output(&output, "out", 1), "3");
}

/// A constant operand of add/sub/mul only matters mod 2^N, so the
/// instruction's signedness must not change it: `add.s32 x, -1` and
/// `add.u32 x, -1` are the same op, and `-1` stays `-1` under `.u32`.
#[test]
fn test_ring_op_constant_signedness_is_irrelevant() {
    let kernel = |src: String| {
        let module = parse(&src);
        analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis")
    };
    for ((signed, signed_src), (unsigned, unsigned_src)) in [
        (
            ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_add_s32_neg1"),
            ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_add_u32_neg1"),
        ),
        (
            ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_sub_s32_neg7"),
            ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_sub_u32_neg7"),
        ),
        (
            ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_mul_lo_s32_neg3"),
            ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_mul_lo_u32_neg3"),
        ),
    ] {
        assert!(
            matches!(
                check_equiv(&kernel(signed_src), &kernel(unsigned_src)),
                EquivOutcome::Equivalent
            ),
            "`{signed}` not proved equal to `{unsigned}`"
        );
    }

    // A negative constant reads as a subtraction, whatever the signedness.
    for (op, src) in [
        ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_add_u32_neg1"),
        ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_add_s32_neg1"),
        ptx_case!("eval/ring_op_constant_signedness_is_irrelevant_sub_u32_1"),
    ] {
        let rendered = display_output(&kernel(src), "out", 0);
        assert!(
            rendered.contains("- 1") && !rendered.contains("4294967295"),
            "`{op}` rendered as {rendered}"
        );
    }
}

#[test]
fn test_bfe_extract_and_sign_fill() {
    let module = ptx!(parse "eval/bfe_extract_and_sign_fill");
    let output = analyze_kernel(&module, None, out_only_config(4, 4)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "10");
    assert_eq!(display_output(&output, "out", 1), "4294967290");
    assert_eq!(display_output(&output, "out", 2), "4294967295");
    assert_eq!(display_output(&output, "out", 3), "0");
}

#[test]
fn test_bfi_clips_field_to_register_width() {
    let module = ptx!(parse "eval/bfi_clips_field_to_register_width");
    let output = analyze_kernel(&module, None, out_only_config(4, 4)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "48");
    assert_eq!(display_output(&output, "out", 1), "5");
    assert_eq!(display_output(&output, "out", 2), "5");
    assert_eq!(display_output(&output, "out", 3), "7");
}

#[test]
fn test_mov_vector_destination_unpack_values() {
    let module = ptx!(parse "eval/mov_vector_destination_unpack_values");
    let output = analyze_kernel(&module, None, out_only_config(2, 2)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "43981");
    assert_eq!(display_output(&output, "out", 1), "4660");
}

#[test]
fn test_cvt_pack_halves_values() {
    // cvt.rn.f16x2.f32 d, a, b: `a` goes to the *high* half and `b` to the
    // *low* (opposite mov.b32's brace order); also exercises storing a Pair and
    // reading its 2-byte granules back.
    let module = ptx!(parse "eval/cvt_pack_halves_values");
    let output = analyze_kernel(&module, None, out_only_config(2, 2)).expect("analysis");
    let low = display_output(&output, "out", 0);
    let high = display_output(&output, "out", 1);
    assert_eq!(low, "2.5"); // low half: b
    assert_eq!(high, "1.5"); // high half: a
}

#[test]
fn test_mov_unpack_native_pair_source() {
    // `ld.global.b32` over a 2-byte array yields a `Value::Pair`; `mov.b32
    // {lo,hi}` must split its real halves directly, not bit-mask an opaque
    // integer (nvcc/Triton's f16 idiom).
    let module = ptx!(parse "eval/mov_unpack_native_pair_source");
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
    let output = analyze_kernel(&module, None, config).expect("pair unpack analysis");
    assert_eq!(display_output(&output, "out", 0), "in[0]");
    assert_eq!(display_output(&output, "out", 1), "in[1]");
}

#[test]
fn test_mov_pack_b32_always_builds_pair() {
    // The mirror image: `mov.b32 dst, {lo, hi}` always writes `Value::Pair(lo,
    // hi)`, not bit-packing, so packed f16 or integer halves round-trip exactly
    // through memory.
    let module = ptx!(parse "eval/mov_pack_b32_always_builds_pair");
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
    let output = analyze_kernel(&module, None, config).expect("pair pack analysis");
    assert_eq!(display_output(&output, "out", 0), "in[0]");
    assert_eq!(display_output(&output, "out", 1), "in[1]");
}

/// `mov.b64 dst, {lo, hi}` with concrete 32-bit integer halves yields the
/// exact 64-bit integer: the `Value::Pair` is recombined when consumed as a
/// scalar (here, the u64 output).
#[test]
fn test_mov_pack_b64_integer_halves_recombine() {
    let module = ptx!(parse "eval/mov_pack_b64_integer_halves_recombine");
    let output = analyze_kernel(&module, None, out_only_config(8, 1)).expect("b64 pack analysis");
    // 5 | (3 << 32) = 12884901893
    assert_eq!(display_output(&output, "out", 0), "12884901893");
}

/// Value-boundary canonicalization: `mov.u32 %r, -1` and `not.b32 %r, 0` hold
/// the same hardware value, so both kernels must export the same canonical
/// constant.
#[test]
fn test_mov_neg1_equivalent_to_not_zero() {
    let mov_kernel = ptx!("eval/mov_neg1_equivalent_to_not_zero");
    let not_kernel = ptx!("eval/mov_neg1_equivalent_to_not_zero_2");
    let a = analyze_kernel(&parse(&mov_kernel), None, out_only_config(4, 1)).unwrap();
    let b = analyze_kernel(&parse(&not_kernel), None, out_only_config(4, 1)).unwrap();
    assert_eq!(display_output(&a, "out", 0), "4294967295");
    assert_eq!(display_output(&b, "out", 0), "4294967295");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// Value-boundary canonicalization at setp/selp: `-1` and a computed
/// 4294967295 are reinterpreted at the instruction type, so both build
/// identical comparison and select nodes.
#[test]
fn test_setp_selp_canonicalize_operands() {
    let literal = ptx!("eval/setp_selp_canonicalize_operands");
    let computed = ptx!("eval/setp_selp_canonicalize_operands_2");
    let a = analyze_kernel(&parse(&literal), None, in_out_config(1, 1)).unwrap();
    let b = analyze_kernel(&parse(&computed), None, in_out_config(1, 1)).unwrap();
    let da = display_output(&a, "out", 0);
    let db = display_output(&b, "out", 0);
    assert_eq!(da, db);
    assert!(da.contains("== -1"), "compare canonicalized at s32: {}", da);
    assert!(
        da.contains("? 4294967295"),
        "select arm canonicalized at b32: {}",
        da
    );
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// `st.u8` keeps only the low byte of the stored value (hardware chops
/// 300 to 44); `ld.u8` zero-extends it back.
#[test]
fn test_store_u8_truncates_to_low_bits() {
    let module = ptx!(parse "eval/store_u8_truncates_to_low_bits");
    let output = analyze_kernel(&module, None, u8_scratch_config()).unwrap();
    assert_eq!(display_output(&output, "out", 0), "44");
}

/// `ld.s8` sign-extends: byte 0xFF reads as -1, and storing it at 32 bits
/// exports the canonical 4294967295, the same constant as storing -1
/// directly.
#[test]
fn test_load_s8_sign_extends() {
    let via_byte = ptx!("eval/load_s8_sign_extends");
    let direct = ptx!("eval/load_s8_sign_extends_2");
    let a = analyze_kernel(&parse(&via_byte), None, u8_scratch_config()).unwrap();
    let b = analyze_kernel(&parse(&direct), None, u8_scratch_config()).unwrap();
    assert_eq!(display_output(&a, "out", 0), "4294967295");
    assert_eq!(display_output(&b, "out", 0), "4294967295");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// cvt reads its source at the *source* format (ISA Table 15): `cvt.s64.s32`
/// of an `and.b32` result 4294967288 widens -8, and `cvt.u64.u32` of
/// `sub.s32`'s -8 widens 4294967288.
#[test]
fn test_cvt_reinterprets_at_source_format() {
    let src = ptx!("eval/cvt_reinterprets_at_source_format");
    let output = analyze_kernel(&parse(&src), None, out_only_config(8, 2)).unwrap();
    // (-5 & -4) at 32 bits is 0xFFFFFFF8; sign-extended through s32: -8.
    assert_eq!(display_output(&output, "out", 0), "-8");
    // 3 - 11 = -8; zero-extended through u32: 4294967288.
    assert_eq!(display_output(&output, "out", 1), "4294967288");
}

/// A bits-type or unsigned sub-register symbolic load needs no extension
/// node: zero-extension is the identity on the number (PTX's rule for
/// `.b8`/`.u8` loads too).
#[test]
fn test_unsigned_sub_register_load_passes_through() {
    let src = ptx!("eval/unsigned_sub_register_load_passes_through");
    let output = analyze_kernel(&parse(&src), None, u8_scratch_config()).unwrap();
    assert_eq!(display_output(&output, "out", 0), "scratch[0]");
}

/// LLVM's NVPTX fp8 idiom (`RoPEFloat8Kernel`): a byte loaded into a 16-bit
/// register feeds `cvt.rn.f16x2.e4m3x2`; the low lane is the element's real
/// value and the discarded high lane stays `Undefined`.
#[test]
fn test_e4m3x2_scalar_source_from_a_zero_extended_byte_load() {
    let module = ptx!(parse "eval/e4m3x2_scalar_source_from_a_zero_extended_byte_load");
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
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
}

/// The `__symexpf` callseq idiom becomes symbolic exp.
#[test]
fn test_symexpf_callseq() {
    let module = ptx!(parse "eval/symexpf_callseq");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "exp(in[0])");
}

/// `tanh.approx.f32` is `(e^2x - 1) / (e^2x + 1)`, staying in the exp
/// fragment (like `Ex2`) instead of an opaque atom: it displays in that form
/// and folds to zero at 0.
#[test]
fn test_tanh_approx_expands_to_exp_fragment() {
    let module = ptx!(parse "eval/tanh_approx_expands_to_exp_fragment");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(
        display_output(&output, "out", 0),
        "((exp((in[0] * 2)) - 1) / (exp((in[0] * 2)) + 1))"
    );
}

/// `tanh(0) = 0` is checked through canon's equivalence, not display:
/// `exp(0)` is not folded to `1` at construction, so canon's algebra proves
/// the collapse.
#[test]
fn test_tanh_approx_zero_equivalent_to_zero() {
    let tanh_src = ptx!("eval/tanh_approx_zero_equivalent_to_zero");
    let zero_src = ptx!("eval/tanh_approx_zero_equivalent_to_zero_2");
    let a = analyze_kernel(&parse(&tanh_src), None, out_only_config(4, 1)).expect("tanh analysis");
    let b = analyze_kernel(&parse(&zero_src), None, out_only_config(4, 1)).expect("zero analysis");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// shfl.sync.idx exchanges lane values (2 lanes, mask 0x3):
/// out[tid] = in[tid ^ 1].
#[test]
fn test_shfl_sync_idx_exchange() {
    let module = ptx!(parse "eval/shfl_sync_idx_exchange");
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[1]");
    assert_eq!(display_output(&output, "out", 1), "in[0]");
    // Warp syncs count once per fired group.
    assert_eq!(output.stats.warp_syncs, 1);
}

/// `redux.sync.max.u32`/`.min.s32` fold every lane's value (0..31, and
/// its `- 16` shift) across the full warp and broadcast the single result
/// to every lane - one `redux.sync` fires per group.
#[test]
fn test_redux_sync_max_min_full_warp() {
    let module = ptx!(parse "eval/redux_sync_max_min_full_warp");
    let output = analyze_kernel(&module, None, warp_out_config(4, 64)).unwrap();
    // max(0..31) = 31, min(-16..15) = -16, broadcast to lanes 0 and 31;
    // `st.global.u32` stores raw unsigned bits, so -16 reads back as
    // 4294967280.
    assert_eq!(display_output(&output, "out", 0), "31");
    assert_eq!(display_output(&output, "out", 1), "4294967280");
    assert_eq!(display_output(&output, "out", 62), "31");
    assert_eq!(display_output(&output, "out", 63), "4294967280");
    assert_eq!(output.stats.warp_syncs, 2);
}

/// `redux.sync.and`/`.or`/`.add` over the same 0..31 lane values (all
/// `.b32`/`.u32`, no signedness distinction).
#[test]
fn test_redux_sync_and_or_add_full_warp() {
    let module = ptx!(parse "eval/redux_sync_and_or_add_full_warp");
    let output = analyze_kernel(&module, None, warp_out_config(4, 96)).unwrap();
    // AND(0..31) = 0, OR(0..31) = 31, SUM(0..31) = 496.
    assert_eq!(display_output(&output, "out", 0), "0");
    assert_eq!(display_output(&output, "out", 1), "31");
    assert_eq!(display_output(&output, "out", 2), "496");
    assert_eq!(output.stats.warp_syncs, 3);
}

/// A predicated `redux.sync` fires only for lanes that take it: lanes 16..31
/// skip the guarded `max.s32` and keep their sentinel; all lanes get the
/// `min.s32` result.
#[test]
fn test_redux_sync_partial_mask_skips_unguarded_lanes() {
    let module = ptx!(parse "eval/redux_sync_partial_mask_skips_unguarded_lanes");
    let output = analyze_kernel(&module, None, warp_out_config(4, 64)).unwrap();
    // Lane 0 (guarded, mask 0..15): min over 32 lanes is -16, max over 0..15 is
    // -1; stored as raw unsigned bits, they read back as 4294967280/4294967295.
    assert_eq!(display_output(&output, "out", 0), "4294967280");
    assert_eq!(display_output(&output, "out", 1), "4294967295");
    // Lane 16 (not guarded): still gets the full-warp min, but never
    // executes the guarded redux, so its sentinel is untouched.
    assert_eq!(display_output(&output, "out", 32), "4294967280");
    assert_eq!(display_output(&output, "out", 33), "999");
    assert_eq!(output.stats.warp_syncs, 2);
}

/// Float `.sat` clamps the result to [0, 1]; concrete operands fold all
/// the way to the clamped constant.
#[test]
fn test_add_sat_f32_concrete_clamps() {
    let module = ptx!(parse "eval/add_sat_f32_concrete_clamps");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    // 0.75 + 0.75 = 1.5 saturates to 1.0.
    assert_eq!(display_output(&output, "out", 0), "1");
    // -0.75 + 0.25 = -0.5 saturates to 0.0.
    assert_eq!(display_output(&output, "out", 1), "0");
}

/// nvcc's fused-ReLU epilogue `cvt.rn.relu.f16.f32` is the exact value
/// transformation max(x, 0) on a symbolic input.
#[test]
fn test_cvt_relu_symbolic_is_max() {
    let module = ptx!(parse "eval/cvt_relu_symbolic_is_max");
    let output = analyze_kernel(&module, None, f32_in_f16_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "max(in[0], 0)");
}

/// ReLU via the fused cvt epilogue is equivalent to ReLU via an explicit
/// max.f32 against zero (with flipped operand order): the clamp and the
/// max are the same real function, and canon flattens max atoms.
#[test]
fn test_relu_epilogue_equivalent_to_explicit_max() {
    let fused = ptx!("eval/relu_epilogue_equivalent_to_explicit_max_fused");
    let explicit = ptx!("eval/relu_epilogue_equivalent_to_explicit_max_explicit");
    let a = analyze_kernel(&parse(&fused), None, f32_in_f16_out_config(2, 2)).unwrap();
    let b = analyze_kernel(&parse(&explicit), None, f32_in_f16_out_config(2, 2)).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

#[test]
fn test_red1_race_free() {
    let output = red1();
    assert_eq!(output.outputs.len(), 1);
    assert!(output.stats.block_syncs > 0);
}

#[test]
fn test_red1_self_equivalence() {
    let a = red1();
    let b = red1();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

#[test]
fn test_red1_red2_equivalent() {
    let a = red1();
    let b = run_reduction("01_reduction/Red-2.ptx", "_Z7reduce2PiS_", 128, 128, 0);
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

#[test]
fn test_red1_red3_equivalent() {
    let a = red1();
    // Red-3 uses extern (dynamic) shared memory: 128 ints.
    let b = run_reduction("01_reduction/Red-3.ptx", "_Z7reduce3PiS_", 128, 128, 512);
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

#[test]
fn test_red1_red4_equivalent() {
    let a = red1();
    // Red-4 adds `in[i] + in[i + 64]` on load; threads 64..128's `in[128..192)`
    // loads land in sdata's unused half, so the sum covers `in[0..128)` and the
    // input spans 192.
    let b = run_reduction("01_reduction/Red-4.ptx", "_Z7reduce0PiS_", 128, 192, 0);
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// A deliberately wrong reduction (dropping one element) must be caught.
#[test]
fn test_red1_wrong_input_not_equivalent() {
    let a = red1();
    // Same kernel, but with only 127 of the 128 inputs shared: rename the
    // input array so its symbols differ.
    let module = parse_file("01_reduction/Red-1.ptx");
    let mut config = reduction_config(128, 128);
    config.arrays[0].name = "other".to_string();
    config.params[0] = ParamValue::ArrayPtr("other".to_string());
    let b = analyze_kernel(&module, Some("_Z17reduce1024_1blockPKiPi"), config).unwrap();
    assert!(matches!(
        check_equiv(&a, &b),
        EquivOutcome::NotEquivalent { .. }
    ));
}

/// `div.rn.f32 d, 1.0, 3.0` and `rcp.approx.f32 d, 3.0` fold to the same
/// exact rational 1/3, so kernels using either spelling are equivalent.
#[test]
fn test_div_by_three_equivalent_to_rcp_of_three() {
    let div_src = ptx!("eval/div_by_three_equivalent_to_rcp_of_three");
    let rcp_src = ptx!("eval/div_by_three_equivalent_to_rcp_of_three_2");
    let a = analyze_kernel(&parse(&div_src), None, one_elem_config()).unwrap();
    let b = analyze_kernel(&parse(&rcp_src), None, one_elem_config()).unwrap();
    // Both fold to the exact rational 1/3.
    assert_eq!(display_output(&a, "out", 0), "(in[0] * 1/3)");
    assert_eq!(display_output(&b, "out", 0), "(in[0] * 1/3)");
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// `sum / N` vs the strength-reduced `t = 1.0 / N; sum * t` at concrete
/// N = 768: 1/768 is not dyadic, so the old fold rounded `t` to fl(1/768)
/// and reported a false DIFF; the exact fold makes them equivalent.
#[test]
fn test_div_by_n_equivalent_to_mul_by_computed_reciprocal() {
    let div_src = ptx!("eval/div_by_n_equivalent_to_mul_by_computed_reciprocal");
    let recip_src = ptx!("eval/div_by_n_equivalent_to_mul_by_computed_reciprocal_2");
    let a = analyze_kernel(&parse(&div_src), None, one_elem_config()).unwrap();
    let b = analyze_kernel(&parse(&recip_src), None, one_elem_config()).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// Concrete fma folds exactly as mul-then-add: one algebra, no fused
/// rounding (the old f64 folds could disagree between the two spellings).
#[test]
fn test_concrete_fma_equivalent_to_mul_add() {
    let fma_src = ptx!("eval/concrete_fma_equivalent_to_mul_add");
    let mul_add_src = ptx!("eval/concrete_fma_equivalent_to_mul_add_2");
    let a = analyze_kernel(&parse(&fma_src), None, f64_out_config()).unwrap();
    let b = analyze_kernel(&parse(&mul_add_src), None, f64_out_config()).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// Model-faithful: 0.1 + 0.2 computed at runtime is the exact rational sum,
/// NOT the pre-rounded f64 literal 0d3FD3333333333334 the hardware would
/// produce.
#[test]
fn test_runtime_sum_differs_from_prerounded_literal() {
    let sum_src = ptx!("eval/runtime_sum_differs_from_prerounded_literal");
    let literal_src = ptx!("eval/runtime_sum_differs_from_prerounded_literal_2");
    let a = analyze_kernel(&parse(&sum_src), None, f64_out_config()).unwrap();
    let b = analyze_kernel(&parse(&literal_src), None, f64_out_config()).unwrap();
    assert!(matches!(
        check_equiv(&a, &b),
        EquivOutcome::NotEquivalent { .. }
    ));
}

/// Tail-exit warp reduction: lanes 16..31 exit and the survivors run a
/// full-mask `shfl.sync.down` tree; exited lanes count as arrived (paper's
/// Sync rule, and the ISA's), so it sums in[0..16].
#[test]
fn test_tail_exit_warp_shfl_reduction() {
    let module = parse(&ptx!("eval/tail_exit_warp_shfl_reduction"));
    let a = analyze_kernel(&module, None, in_out_config(32, 16)).unwrap();
    assert_eq!(a.stats.warp_syncs, 4);

    // Reference: one thread sums in[0..16] sequentially.
    let reference = ptx!("eval/tail_exit_warp_shfl_reduction_reference");
    let b = analyze_kernel(&parse(&reference), None, in_out_config(1, 16)).unwrap();
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// Not a race: a lane reads shared and exits, then the survivor
/// bar.warp.syncs the full mask and writes the byte; syncMem clears over all
/// of I, the returned lane included.
#[test]
fn test_bar_warp_sync_clears_chi_for_exited_reader() {
    let module = ptx!(parse "eval/bar_warp_sync_clears_chi_for_exited_reader");
    analyze_kernel(&module, None, AnalysisConfig::new((2, 1, 1)))
        .expect("read-then-exit / sync / write must not race under the paper's syncMem");
}

/// Mirrored variant: a lane writes shared memory and exits; the survivor
/// syncs and reads the byte back. No race, and the exited lane's value is
/// visible (syncMem clears ordering state, not memory).
#[test]
fn test_bar_warp_sync_clears_chi_for_exited_writer() {
    let module = ptx!(parse "eval/bar_warp_sync_clears_chi_for_exited_writer");
    let output = analyze_kernel(&module, None, in_out_config(2, 1))
        .expect("write-then-exit / sync / read must not race under the paper's syncMem");
    assert_eq!(display_output(&output, "out", 0), "42");
}

/// bar.warp.sync end-to-end (previously UnsupportedInstruction at
/// lowering): the neighbor exchange synchronized by a warp barrier instead
/// of a CTA barrier.
#[test]
fn test_bar_warp_sync_neighbor_exchange() {
    let module = ptx!(parse "eval/bar_warp_sync_neighbor_exchange");
    let output = analyze_kernel(&module, None, in_out_config(2, 2)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[1]");
    assert_eq!(display_output(&output, "out", 1), "in[0]");
    assert_eq!(output.stats.block_syncs, 0);
    assert_eq!(output.stats.warp_syncs, 1);
}

/// `barrier.sync{.aligned} a` (no thread count) is the same full-CTA
/// barrier as `bar.sync a` (ISA: "bar{.cta}.sync is equivalent to
/// barrier{.cta}.sync.aligned").
#[test]
fn test_barrier_sync_is_bar_sync() {
    for (form, src) in [
        ptx_case!("eval/barrier_sync_is_bar_sync"),
        ptx_case!("eval/barrier_sync_is_bar_sync_cta_aligned"),
    ] {
        let module = parse(&src);
        let output = analyze_kernel(&module, None, in_out_config(2, 2))
            .unwrap_or_else(|e| panic!("{} failed: {}", form, e));
        assert_eq!(display_output(&output, "out", 0), "in[1]");
        assert_eq!(display_output(&output, "out", 1), "in[0]");
        assert_eq!(output.stats.block_syncs, 2);
    }
}

// activemask kernels: each thread records its mask; a CTA barrier after the
// query means no thread has exited yet, making the all-alive answer
// deterministic.

/// All 32 lanes alive: every thread reads 0xFFFFFFFF. The barrier comes
/// *after* activemask here, so each thread queries while all others are
/// alive (blocked or not-yet-run, never exited).
#[test]
fn test_activemask_all_alive_full_warp() {
    let module = parse(&ptx!("eval/activemask_all_alive_full_warp"));
    let output = analyze_kernel(&module, None, in_out_config(32, 32)).unwrap();
    for i in 0..32 {
        assert_eq!(display_output(&output, "out", i), "4294967295");
    }
}

/// A 16-thread block: warp lanes 16..31 do not exist and contribute 0, so
/// every thread reads 0xFFFF (again with the barrier after the query, so
/// all queries happen before any exit).
#[test]
fn test_activemask_16_thread_block() {
    let module = parse(&ptx!("eval/activemask_16_thread_block"));
    let output = analyze_kernel(&module, None, in_out_config(16, 16)).unwrap();
    for i in 0..16 {
        assert_eq!(display_output(&output, "out", i), "65535");
    }
}

/// Tail-exit: threads 16..31 exit before the barrier. Only thread 0 is
/// asserted: later survivors also see earlier survivors' exits, and the model
/// promises nothing about exit order.
#[test]
fn test_activemask_after_tail_exit() {
    let module = parse(&ptx!("eval/activemask_after_tail_exit"));
    let output = analyze_kernel(&module, None, in_out_config(32, 32)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "65535");
}

/// Aligned in-bounds accesses at region edges still pass: a shared array's
/// last scalar element (adjacent array following) and an exact-fit v4 ending
/// at the region end.
#[test]
fn test_region_edge_exact_fit_accesses_pass() {
    let module = ptx!(parse "eval/region_edge_exact_fit_accesses_pass");
    let output = analyze_kernel(&module, None, in_out_config(1, 2))
        .expect("exact-fit edge accesses must stay in bounds");
    // The scalar store at A+44 overwrote the v4's last element; the v4
    // read back yields {1, 2, 3, 7}.
    assert_eq!(display_output(&output, "out", 0), "7");
    assert_eq!(display_output(&output, "out", 1), "1");
}

/// An array at 0x7FFF_FFFF_FFFF_FFF0: the +16 access crosses the i64 sign
/// boundary without u64 wrap. Addresses are u64 mod 2^64 (as on hardware), so
/// this is in bounds.
#[test]
fn test_upper_half_address_space_access_in_bounds() {
    let module = ptx!(parse "eval/upper_half_address_space_access_in_bounds");
    let mut config = in_out_config(1, 8);
    config.arrays[0].base = 0x7FFF_FFFF_FFFF_FFF0;
    let output = analyze_kernel(&module, None, config)
        .expect("crossing 2^63 without wrapping u64 is in bounds");
    assert_eq!(display_output(&output, "out", 0), "in[4]");
}

/// The corpus's one cvta form is accepted as the identity.
#[test]
fn test_cvta_to_global_accepted() {
    let module = parse(&ptx!("eval/cvta_to_global_accepted"));
    analyze_kernel(&module, None, in_out_config(1, 1)).expect("cvta.to.global is the corpus form");
}

/// The happy path: `cp.async` + `commit_group` + `wait_group 0` correctly
/// deposits the source value into shared memory, readable once waited on.
#[test]
fn test_cp_async_wait_group_completes_copy() {
    let module = ptx!(parse "eval/cp_async_wait_group_completes_copy");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// Same as above, but with the required `bar.sync` between thread 0's
/// `wait_group` and thread 1's read: this must succeed, confirming the
/// race in the previous test is exactly about the missing synchronization.
#[test]
fn test_cp_async_post_wait_cross_thread_read_with_sync_succeeds() {
    let module = ptx!(parse "eval/cp_async_post_wait_cross_thread_read_with_sync_succeeds");
    let output = analyze_kernel(&module, None, in_out_config(2, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// `cp.async` -> `wait_group` -> `ld.shared` under `sm_90a` with no fence:
/// `cp.async` is a generic-proxy op (PTX ISA 9.7.10.28.3), so no
/// `fence.proxy.async` is needed.
#[test]
fn test_cp_async_without_fence_proxy_async_is_clean_on_sm90() {
    let module = ptx!(parse "eval/cp_async_without_fence_proxy_async_is_clean_on_sm90");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// Same kernel, same `sm_90a` target, with a (redundant)
/// `fence.proxy.async.shared::cta;` between `wait_group` and the read -
/// must pass clean too.
#[test]
fn test_cp_async_with_fence_proxy_async_succeeds_on_sm90() {
    let module = ptx!(parse "eval/cp_async_with_fence_proxy_async_succeeds_on_sm90");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// Regression guard for a real astra2 sm_89 MatrixVectorMultiplicationFloat16
/// kernel: `cp.async`, `wait_group`, `bar.sync`, cross-thread read, no fence;
/// below sm_90 it must never be flagged.
#[test]
fn test_cp_async_cross_thread_pattern_without_fence_is_clean_on_sm89() {
    let module = ptx!(parse "eval/cp_async_cross_thread_pattern_without_fence_is_clean_on_sm89");
    let output = analyze_kernel(&module, None, in_out_config(2, 1)).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[0]");
}

/// TMA's async-proxy write needs no `fence.proxy.async` either: the
/// completion carries an implicit proxy fence (PTX ISA 9.7.9.25.2). Same body
/// as the bulk-tensor test, under `sm_90a`.
#[test]
fn test_cp_async_bulk_tensor_without_fence_proxy_async_is_clean_on_sm90() {
    let module = ptx!(parse "eval/cp_async_bulk_tensor_without_fence_proxy_async_is_clean_on_sm90");
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
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "in[54]");
    assert_eq!(display_output(&output, "out", 1), "0");
}

/// The control: a `bar.sync` *after* warp 0 observed the completion does
/// order the copy before warp 1's read.
#[test]
fn test_cp_async_bulk_bar_sync_after_completion_orders_the_read() {
    let module = parse(&ptx!(
        "eval/cp_async_bulk_bar_sync_after_completion_orders_the_read"
    ));
    analyze_kernel(&module, None, bulk_copy_config()).unwrap();
}

/// The control: every reader waiting on `full` itself is ordered after the
/// copy, whatever `bar.sync` ran before it.
#[test]
fn test_cp_async_bulk_every_reader_waiting_is_accepted() {
    let module = parse(&ptx!("eval/cp_async_bulk_every_reader_waiting_is_accepted"));
    analyze_kernel(&module, None, bulk_copy_config()).unwrap();
}

/// `wgmma.fence` -> `mma_async.m64n8k16.f32.f16.f16` -> `commit_group` ->
/// `wait_group 0`, unswizzled K-major (LBO 128): thread 0's `%d0` must be
/// `sum(1..=16) = 136`.
#[test]
fn test_wgmma_mma_async_numeric_correctness() {
    let module = ptx!(parse "eval/wgmma_mma_async_numeric_correctness");
    let mut config = AnalysisConfig::new((128, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "136");
}

/// Two chained same-shape `wgmma.mma_async` calls with one fence before and
/// one commit/wait after (the H100 GEMM pattern) must not be flagged (ISA
/// fence exemption): `272`.
#[test]
fn test_wgmma_chained_same_shape_accumulator_needs_no_extra_fence() {
    let module = ptx!(parse "eval/wgmma_chained_same_shape_accumulator_needs_no_extra_fence");
    let mut config = AnalysisConfig::new((128, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "272");
}

/// `stmatrix.x1.m8n8.shared.b16`: lane `l`'s value lands at `row_addr[l/4] +
/// (l%4)*4`, a bijection onto the 128 bytes; lane 5's value is read back at
/// `src+20`.
#[test]
fn test_stmatrix_writes_the_expected_byte_per_lane() {
    let module = ptx!(parse "eval/stmatrix_writes_the_expected_byte_per_lane");
    let mut config = AnalysisConfig::new((32, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "1005");
}

/// `mov.b64 %rd, {%f_lo, %f_hi}` packs two f32 registers, `fma.rn.f32x2`
/// works per lane, `mov.b64 {%f_lo, %f_hi}, %rd` unpacks the result.
#[test]
fn test_f32x2_fma_via_register_pack() {
    let outcome = f32x2_outcome(&ptx!("eval/f32x2_fma_via_register_pack"));
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// `mul.f32x2` then `add.f32x2` compute the same reals as the fused form.
#[test]
fn test_f32x2_mul_add_via_register_pack() {
    let outcome = f32x2_outcome(&ptx!("eval/f32x2_mul_add_via_register_pack"));
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// A 64-bit load over two adjacent f32 inputs yields the pair directly,
/// and a 64-bit store of the pair writes both output elements.
#[test]
fn test_f32x2_fma_via_64bit_memory_access() {
    let outcome = f32x2_outcome(&ptx!("eval/f32x2_fma_via_64bit_memory_access"));
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// A concrete 64-bit pattern used as an f32x2 operand decodes into its two
/// lanes (1.0f each); the point is that the constant lanes read correctly.
#[test]
fn test_f32x2_constant_bit_pattern_operand() {
    let outcome = f32x2_outcome(&ptx!("eval/f32x2_constant_bit_pattern_operand"));
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// The lanes really are computed: dropping the addend changes the result.
#[test]
fn test_f32x2_wrong_lane_math_is_not_equivalent() {
    let outcome = f32x2_outcome(&ptx!("eval/f32x2_wrong_lane_math_is_not_equivalent"));
    assert!(
        matches!(outcome, EquivOutcome::NotEquivalent { .. }),
        "{:?}",
        outcome
    );
}

/// `mov.b64 %rd, {%r_lo, %r_hi}` with concrete integer halves still builds
/// the 64-bit integer (here a byte offset of 8) when read as a scalar.
#[test]
fn test_mov_b64_integer_pack_recombines_as_scalar() {
    let packed = ptx!("eval/mov_b64_integer_pack_recombines_as_scalar_packed");
    let direct = ptx!("eval/mov_b64_integer_pack_recombines_as_scalar_direct");
    let a = analyze_kernel(&parse(&packed), None, in_out_config(1, 4)).unwrap();
    let b = analyze_kernel(&parse(&direct), None, in_out_config(1, 4)).unwrap();
    assert_eq!(display_output(&a, "out", 2), display_output(&b, "out", 2));
    assert!(matches!(check_equiv(&a, &b), EquivOutcome::Equivalent));
}

/// nvcc/Triton's own way of building an `f32x2` operand: two 32-bit loads
/// zero-extended into 64-bit registers, `shl.b64` by 32 and `or.b64` to
/// place them in the two lanes (with an `and.b64` lane mask thrown in).
#[test]
fn test_f32x2_operand_assembled_with_shift_and_or() {
    let outcome = f32x2_outcome(&ptx!("eval/f32x2_operand_assembled_with_shift_and_or"));
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// `shr.u64` by 32 moves the high lane down; the low lane is then read
/// through a 64-bit-to-32-bit unpack.
#[test]
fn test_f32x2_lane_extracted_with_shift() {
    let outcome = f32x2_outcome(&ptx!("eval/f32x2_lane_extracted_with_shift"));
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// `cvt.u64.u32` zero-extension is the other way nvcc/Triton feed one f32
/// into an `f32x2` lane, and `cvt.u32.u64` truncation reads a lane back.
#[test]
fn test_f32x2_operand_assembled_with_cvt_zero_extension() {
    let outcome = f32x2_outcome(&ptx!(
        "eval/f32x2_operand_assembled_with_cvt_zero_extension"
    ));
    assert!(matches!(outcome, EquivOutcome::Equivalent), "{:?}", outcome);
}

/// A concrete 32-bit word in shared memory (here the zero a `cp.async`
/// zero-fill or a plain store leaves behind) can be overwritten and read
/// back one 16-bit half at a time: its halves are known bit patterns.
#[test]
fn test_concrete_scalar_granule_splits_for_half_width_access() {
    let module = ptx!(parse "eval/concrete_scalar_granule_splits_for_half_width_access");
    let out = analyze_kernel(&module, None, in_out_config(1, 1)).expect("split scalar");
    assert_eq!(display_output(&out, "out", 0), "in[0]");
}

/// `copysign.type d, a, b` (PTX ISA): `d = |b|` with `a`'s sign - opposite of
/// a naive operand reading. Pins all four sign combinations and the
/// `copysign.f32 %v0, %x0, %v0` reuse idiom.
#[test]
fn test_copysign_combines_the_sign_of_a_with_the_magnitude_of_b() {
    let module = ptx!(parse "eval/copysign_combines_the_sign_of_a_with_the_magnitude_of_b");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 1,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    // `abs`/`select` don't fold over constants (canon treats `Abs` as opaque),
    // so check via the f64 oracle: (+3) + (-3) + (+3) + (-3) = 0.
    let (_, elems) = output.outputs.iter().find(|(n, _)| n == "out").unwrap();
    let (_, expr) = elems.iter().find(|(i, _)| *i == 0).unwrap();
    let value = numeric::eval_f64(&output.arena, *expr, 0).expect("numeric eval");
    assert_eq!(value, 0.0);
}

/// The fp8-elementwise idiom: `ld.global.v2.b32` (a `Value::Quad`) ->
/// `mov.b32 {h,h}` -> `cvt.rn.f16x2.e4m3x2` is the identity over symbolic
/// reals: `x[0]`..`x[3]` stay distinct.
#[test]
fn test_e4m3x2_vector_load_keeps_four_symbolic_bytes_independent() {
    let module = ptx!(parse "eval/e4m3x2_vector_load_keeps_four_symbolic_bytes_independent");
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
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
    assert_eq!(display_output(&output, "out", 1), "x[1]");
    assert_eq!(display_output(&output, "out", 2), "x[2]");
    assert_eq!(display_output(&output, "out", 3), "x[3]");
}

/// LLVM's NVPTX backend extracts a `Quad` register's low 16 bits via
/// `cvt.u16.u32` (`GELUFloat8Kernel`); like `truncates_pair`, this must keep
/// the low `Pair` of byte lanes.
#[test]
fn test_e4m3x2_low_half_extracted_via_cvt_u16_u32_truncation_of_a_quad() {
    let module = ptx!(parse "eval/e4m3x2_low_half_extracted_via_cvt_u16_u32_truncation_of_a_quad");
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
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
    assert_eq!(display_output(&output, "out", 1), "x[2]");
}

/// `ld.b16` of two fp8 elements yields a 2-byte `Value::Pair`; storing or
/// reloading it at that native width is not a half-extraction - only a
/// narrower store truncates.
#[test]
fn test_byte_pair_round_trips_through_shared_memory_at_native_16_bit_width() {
    let module =
        ptx!(parse "eval/byte_pair_round_trips_through_shared_memory_at_native_16_bit_width");
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
    let output = analyze_kernel(&module, None, config).unwrap();
    assert_eq!(display_output(&output, "out", 0), "x[0]");
    assert_eq!(display_output(&output, "out", 1), "x[1]");
}

/// A concrete 16-bit source (e.g. `mov.u16`) gets a real `.e4m3` bit decode:
/// `0xB838` packs -1.0 high and +1.0 low (PTX ISA 9.7.9.22: low byte of `a`
/// -> low half of `d`).
#[test]
fn test_e4m3x2_decodes_a_concrete_scalar_bit_pattern() {
    let module = ptx!(parse "eval/e4m3x2_decodes_a_concrete_scalar_bit_pattern");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    let (_, elems) = output.outputs.iter().find(|(n, _)| n == "out").unwrap();
    let get = |i: u64| {
        let (_, e) = elems.iter().find(|(idx, _)| *idx == i).unwrap();
        numeric::eval_f64(&output.arena, *e, 0).expect("numeric eval")
    };
    assert_eq!(get(0), 1.0);
    assert_eq!(get(1), -1.0);
}

/// Same concrete `0xB838` pattern as above, but with `.relu`: the
/// already-positive lower byte (+1.0) is untouched, the negative upper
/// byte (-1.0) clamps to 0.
#[test]
fn test_e4m3x2_relu_clamps_a_negative_decoded_lane_to_zero() {
    let module = ptx!(parse "eval/e4m3x2_relu_clamps_a_negative_decoded_lane_to_zero");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![ArrayDef {
        name: "out".to_string(),
        base: 0x20000,
        elem_width: 4,
        len: 2,
        kind: ArrayKind::Output,
    }];
    config.params = vec![ParamValue::ArrayPtr("out".to_string())];
    let output = analyze_kernel(&module, None, config).unwrap();
    let (_, elems) = output.outputs.iter().find(|(n, _)| n == "out").unwrap();
    let get = |i: u64| {
        let (_, e) = elems.iter().find(|(idx, _)| *idx == i).unwrap();
        numeric::eval_f64(&output.arena, *e, 0).expect("numeric eval")
    };
    assert_eq!(get(0), 1.0);
    assert_eq!(get(1), 0.0);
}

/// Every lane storing the same reduced value to one shared address (the
/// post-reduction layout idiom) is not a race.
#[test]
fn test_same_value_warp_uniform_store_is_not_a_race() {
    let same = ptx!(parse "eval/same_value_warp_uniform_store_is_not_a_race_same");
    let out = analyze_kernel(&same, None, in_out_config(2, 1)).expect("same-value store");
    assert_eq!(display_output(&out, "out", 0), "(in[0] * 2)");
}

/// Extern-only kernels are unaffected by extern-window placement: the window
/// starts at offset 0 and a sized buffer round-trips at `buf[0]`.
#[test]
fn test_extern_only_shared_roundtrip() {
    let module = ptx!(parse "eval/extern_only_shared_placement_and_bounds");
    let mut config = in_out_config(1, 1);
    config.dynamic_shared_bytes = 16;
    let output = analyze_kernel(&module, None, config).expect("in-bounds extern access");
    assert_eq!(display_output(&output, "out", 0), "42");
}

/// `membar.cta`/`.gl`/`.sys` lower (PTX ISA 9.7.15.4).
#[test]
fn test_membar_valid_levels_lower() {
    for (level, src) in [
        (".cta", ptx!("eval/membar_levels_cta")),
        (".gl", ptx!("eval/membar_levels_gl")),
        (".sys", ptx!("eval/membar_levels_sys")),
    ] {
        analyze_kernel(&parse(&src), None, AnalysisConfig::new((1, 1, 1)))
            .unwrap_or_else(|e| panic!("membar{level}: {e}"));
    }
}

/// `redux.sync` forms of PTX ISA 9.7.15.13: `.add/.min/.max` on `.u32/.s32`,
/// `.and/.or/.xor` on `.b32`, `.min/.max` on `.f32`.
#[test]
fn test_redux_sync_valid_forms() {
    for (form, src) in [
        ("add.u32", ptx!("eval/redux_sync/add_u32")),
        ("max.s32", ptx!("eval/redux_sync/max_s32")),
        ("xor.b32", ptx!("eval/redux_sync/xor_b32")),
        ("min.f32", ptx!("eval/redux_sync/min_f32")),
        ("max.f32", ptx!("eval/redux_sync/max_f32")),
    ] {
        analyze_kernel(&parse(&src), None, AnalysisConfig::new((32, 1, 1)))
            .unwrap_or_else(|e| panic!("{form}: {e}"));
    }
}

/// Concrete integer division (index math) evaluates exactly.
#[test]
fn test_concrete_integer_div_evaluates() {
    let module = ptx!(parse "eval/symbolic_integer_div_is_unsupported_concrete");
    let output = analyze_kernel(&module, None, in_out_config(1, 1)).expect("analysis");
    assert_eq!(display_output(&output, "out", 0), "3");
}

/// The module-global window is half-open: an array ending exactly at its
/// base does not overlap it.
#[test]
fn test_array_ending_at_module_global_window_is_disjoint() {
    const MODULE_GLOBAL_BASE: u64 = 0x7000_0000_0000_0000;
    let module = ptx!(parse "eval/array_overlapping_module_global_window_rejected");
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays.push(ArrayDef {
        name: "in".to_string(),
        base: MODULE_GLOBAL_BASE - 16,
        elem_width: 4,
        len: 4,
        kind: ArrayKind::Input,
    });
    analyze_kernel(&module, None, config).expect("an array ending at the window base is disjoint");
}

/// Boundary `tcgen05.mma` encodings that are valid and modeled: M = 32 under
/// `.ws`, the B-reuse max shift under `.ws` (a performance hint), and D at
/// lane 0 with a column offset.
#[test]
fn test_tcgen05_mma_accepts_boundary_encodings() {
    for (case, src) in [
        (
            ".ws M=32 N=64",
            ptx!("eval/tcgen05_mma_encoding/shape_ws_m32_n64"),
        ),
        (
            ".ws max shift",
            ptx!("eval/tcgen05_mma_encoding/idesc_max_shift_ws"),
        ),
        (
            "D at lane 0, column 8",
            ptx!("eval/tcgen05_mma_encoding/d_lane0_col8"),
        ),
    ] {
        analyze_kernel(&parse(&src), None, AnalysisConfig::new((32, 1, 1)))
            .unwrap_or_else(|e| panic!("{case}: {e}"));
    }
}
