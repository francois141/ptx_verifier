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
use volta_graph::{AsyncOpKind, Space};
use volta_graph_check::GraphConclusion;
use volta_graph_check::domain::ConflictKind;

use common::Side;
use common::amd::{AmdChecked, CK_GEMM_KERNEL, amd_fixture, check_amd, ck_gemm_kernarg};

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

// Test that LDS words exchanged across barriers, each write completed by the wait before it,
// verify, and that CK's GEMM, which stages both tiles through LDS, does too.
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

    let (a, b, c) = (0x10000, 0x20000, 0x30000);
    let arrays = [("a", a, Input), ("b", b, Input), ("c", c, Output(F32))].map(
        |(name, base, kind): (&str, u64, ArrayKind)| ArrayDef {
            name: name.into(),
            base,
            len: 8 * 8,
            kind,
        },
    );
    let run = check_amd(
        "ck_gemm.s",
        amd_fixture!("ck_gemm"),
        CK_GEMM_KERNEL,
        128,
        &ck_gemm_kernarg(a, b, c),
        &arrays,
    );
    assert_eq!(run.report.conclusion(), GraphConclusion::Verified);
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
