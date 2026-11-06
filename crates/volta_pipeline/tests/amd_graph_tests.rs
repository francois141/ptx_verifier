//! AMD kernels' event graphs through the graph branch. Each wave is a graph thread; each DS
//! instruction is an async operation that branches off its wave at issue and joins it at the
//! `s_waitcnt lgkmcnt` that completes it; each `s_barrier` gathers the waves into a generation
//! and scatters them from it. Race-free kernels must conclude `Verified`, and racy ones must fail
//! the memory-conflict check with the expected pair of waves.

mod common;

use volta_amd_analysis::ArrayKind::{Input, Output};
use volta_amd_analysis::OutputType::F32;
use volta_amd_analysis::{ArrayDef, ArrayKind};
use volta_graph::AccessMode::{Read, Write};
use volta_graph::{AsyncOpKind, GenerationKind, Space};
use volta_graph_check::domain::ConflictKind;
use volta_graph_check::{GraphConclusion, PropertyResult};

use common::Side;
use common::amd::{
    AmdChecked, CK_GEMM_KERNEL, CK_GEMM_MAIN_LOOP_KERNEL, GEMM_A_BASE, GEMM_B_BASE, GEMM_C_BASE,
    amd_fixture, check_amd, ck_gemm_kernarg, gemm_arrays,
};

/// Two waves over 128-word `input` and `output` arrays, the kernel's two pointer arguments.
fn run_lds_sync(kernel: &str) -> AmdChecked {
    let arrays = [("input", 0x10000, Input), ("output", 0x20000, Output(F32))].map(
        |(name, base, kind): (&str, u64, ArrayKind)| ArrayDef {
            name: name.into(),
            base,
            len: 128,
            kind,
        },
    );
    let kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    check_amd(
        "lds_sync.s",
        amd_fixture!("lds_sync"),
        kernel,
        128,
        &kernarg,
        &arrays,
    )
}

/// A wave's DS access.
fn ds(wave: u32, mode: volta_graph::AccessMode) -> Side {
    Side::effect(wave, mode, AsyncOpKind::Ds)
}

// Test that LDS exchanges verify when waits complete the accesses before each barrier.
#[test]
fn lds_accesses_ordered_by_waits_and_barriers_are_verified() {
    for kernel in ["exchange", "two_rounds"] {
        let run = run_lds_sync(kernel);
        assert_eq!(
            run.report.conclusion(),
            GraphConclusion::Verified,
            "{kernel}"
        );
        assert!(run.analysis.symbolic_outputs.is_some(), "{kernel}");
    }
}

// Test that a read of another wave's word races its write when no barrier orders them, when the
// barrier comes before the s_waitcnt that completes the write, and when a wave overwrites a word
// before the barrier that would keep the other wave's read ahead of it.
#[test]
fn lds_accesses_no_wait_and_barrier_order_race() {
    for (kernel, earlier, later) in [
        ("no_barrier", ds(0, Write), ds(1, Read)),
        ("barrier_without_wait", ds(1, Write), ds(0, Read)),
        ("overwrite_without_barrier", ds(0, Write), ds(1, Read)),
    ] {
        let run = run_lds_sync(kernel);
        let graph = &run.analysis.graph;
        let pairs = run.report.memory_conflict.violations();
        assert!(
            pairs.iter().any(|c| c.kind == ConflictKind::WriteRead
                && c.location.space == Space::Shared
                && common::side(graph, c.earlier) == earlier
                && common::side(graph, c.later) == later),
            "{kernel}: expected an LDS write of {earlier:?} racing a read of {later:?}, got \
             {:?}",
            run.report.memory_conflict
        );
        assert!(
            pairs
                .iter()
                .all(|c| common::side(graph, c.earlier).thread
                    != common::side(graph, c.later).thread),
            "{kernel}: a wave's DS instructions run in issue order, got {pairs:?}"
        );
        assert!(
            matches!(run.report.conclusion(), GraphConclusion::Rejected { .. }),
            "{kernel}"
        );
    }
}

/// Run either CK GEMM specialization with the same array layout and kernel argument builder.
fn run_ck_gemm(kernel: &str, dims: [i32; 3]) -> AmdChecked {
    let arrays = gemm_arrays(dims.map(|d| d as u64));
    check_amd(
        "ck_gemm.s",
        amd_fixture!("ck_gemm"),
        kernel,
        128,
        &ck_gemm_kernarg(GEMM_A_BASE, GEMM_B_BASE, GEMM_C_BASE, dims),
        &arrays,
    )
}

// Test that three K tiles reuse the same LDS storage as one tile, with more accesses and
// four extra barrier generations, and that both executions verify.
#[test]
fn ck_gemm_main_loop_lds_accesses_are_ordered() {
    let no_loop = run_ck_gemm(CK_GEMM_KERNEL, [40, 40, 64]);
    let main_loop = run_ck_gemm(CK_GEMM_MAIN_LOOP_KERNEL, [40, 40, 192]);
    for run in [&no_loop, &main_loop] {
        assert_eq!(run.report.conclusion(), GraphConclusion::Verified);
    }

    // Repeated tiles add LDS accesses while still writing the same 32 KiB of LDS.
    let (PropertyResult::Pass(no_loop_memory), PropertyResult::Pass(main_loop_memory)) = (
        &no_loop.report.memory_conflict,
        &main_loop.report.memory_conflict,
    ) else {
        panic!("both CK GEMM memory-conflict checks must pass");
    };
    assert!(no_loop_memory.effects > 0);
    assert_eq!(no_loop_memory.written_bytes, 32 * 1024);
    assert_eq!(main_loop_memory.written_bytes, no_loop_memory.written_bytes);
    assert!(main_loop_memory.effects > no_loop_memory.effects);

    // Each of the two main-loop iterations adds two workgroup barriers.
    let barrier_count = |run: &AmdChecked| {
        run.analysis
            .graph
            .generations()
            .values()
            .filter(|generation| matches!(generation.kind, GenerationKind::Barrier { .. }))
            .count()
    };
    assert_eq!(barrier_count(&main_loop), barrier_count(&no_loop) + 4);
}

// Test that a barrier alone leaves an LDS read racing another wave's overwrite, while a
// wait before that barrier orders the read and makes the same exchange verify.
#[test]
fn lds_reads_must_complete_before_the_reuse_barrier() {
    let waited = run_lds_sync("read_wait_before_reuse_barrier");
    assert_eq!(waited.report.conclusion(), GraphConclusion::Verified);

    let run = run_lds_sync("read_pending_across_reuse_barrier");
    assert!(run.analysis.symbolic_outputs.is_some());
    assert!(matches!(
        run.report.conclusion(),
        GraphConclusion::Rejected { .. }
    ));
    let graph = &run.analysis.graph;
    assert!(
        run.report
            .memory_conflict
            .violations()
            .iter()
            .any(|conflict| {
                conflict.kind == ConflictKind::ReadWrite
                    && conflict.location.space == Space::Shared
                    && common::side(graph, conflict.earlier) == ds(0, Read)
                    && common::side(graph, conflict.later) == ds(1, Write)
            }),
        "expected wave 0's pending LDS read to race wave 1's overwrite: {:?}",
        run.report.memory_conflict
    );
}
