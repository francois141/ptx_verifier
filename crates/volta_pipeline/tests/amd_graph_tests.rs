//! AMD kernels' event graphs through the graph branch: one graph thread per wave, each DS
//! instruction an async operation that `s_waitcnt lgkmcnt` completes, and each `s_barrier` a
//! generation the waves gather into and are scattered from.

use std::path::{Path, PathBuf};

use volta_amd_analysis::ArrayKind::{Input, Output};
use volta_amd_analysis::OutputType::F32;
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{AnalysisResult, ArrayDef, WorkgroupLaunch, analyze};
use volta_expr::SymbolicOutputs;
use volta_graph::{BarrierArrivals, ContributionKind, EventId, GenerationKind, ThreadIx};
use volta_graph_check::domain::ConflictKind;
use volta_graph_check::{GraphConclusion, check_graph};

fn fixture(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../volta_amd_analysis/tests/fixtures")
        .join(name)
}

/// Compare `outputs`, one `array[index] = expr` line per element, with `path`; `VOLTA_BLESS=1`
/// rewrites it.
fn assert_out_file(path: &Path, outputs: &SymbolicOutputs) {
    let lines = outputs.outputs.iter().flat_map(|(array, elements)| {
        elements.iter().map(move |&(index, value)| {
            format!("{array}[{index}] = {}\n", outputs.arena.display_expr(value))
        })
    });
    let actual: String = lines.collect();
    if std::env::var_os("VOLTA_BLESS").is_some_and(|v| v == "1") {
        return std::fs::write(path, actual).unwrap();
    }
    let expected = std::fs::read_to_string(path).expect("no .out file (VOLTA_BLESS=1 writes it)");
    assert_eq!(
        actual, expected,
        "outputs differ (VOLTA_BLESS=1 accepts them)"
    );
}

/// Run `kernel` of lds_sync.s on two waves over 128-word `input` and `output` arrays.
fn run_lds_sync(kernel: &str) -> AnalysisResult {
    let source = std::fs::read_to_string(fixture("lds_sync.s")).unwrap();
    let kernel = parse_kernel(&source, kernel).unwrap();
    let arrays =
        [("input", 0x10000, Input), ("output", 0x20000, Output(F32))].map(|(name, base, kind)| {
            ArrayDef {
                name: name.into(),
                base,
                len: 128,
                kind,
            }
        });
    let kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (128, 1, 1),
    };
    analyze(&kernel, &launch, &kernarg, &arrays).unwrap()
}

// Test that `exchange` writes lds_sync.out and verifies: each wave's s_waitcnt completes its LDS
// write before both gather into one s_barrier generation. In `barrier_without_wait` the writes are
// still in flight at the barrier, so wave 0's read races wave 1's write.
#[test]
fn lds_accesses_of_two_waves_are_ordered_by_a_wait_then_a_barrier() {
    let result = run_lds_sync("exchange");
    assert_out_file(
        &fixture("lds_sync.out"),
        result.symbolic_outputs.as_ref().unwrap(),
    );

    let graph = &result.graph;
    let barriers: Vec<_> = graph
        .generations()
        .values()
        .filter(|g| matches!(g.kind, GenerationKind::Barrier { .. }))
        .collect();
    let [barrier] = barriers[..] else {
        panic!("expected one barrier generation, got {barriers:?}");
    };
    let arrivals = BarrierArrivals::FullCta;
    assert_eq!(barrier.kind, GenerationKind::Barrier { arrivals });
    assert!(
        barrier
            .contributions
            .iter()
            .all(|c| c.kind == ContributionKind::Blocking)
    );
    let waves = [Some(ThreadIx(0)), Some(ThreadIx(1))];
    let threads = |events: &[EventId]| {
        events
            .iter()
            .map(|&e| graph.thread_of(e))
            .collect::<Vec<_>>()
    };
    let gathered: Vec<_> = barrier.contributions.iter().map(|c| c.event).collect();
    assert_eq!(threads(&gathered), waves);
    assert_eq!(threads(&barrier.releases), waves);
    assert_eq!(graph.threads(), 2);
    assert_eq!(check_graph(graph).conclusion(), GraphConclusion::Verified);

    let racy = run_lds_sync("barrier_without_wait");
    let report = check_graph(&racy.graph);
    let conflicts = report.memory_conflict.violations();
    let thread = |event| racy.graph.acting_thread(event);
    assert!(
        conflicts.iter().any(|c| c.kind == ConflictKind::WriteRead
            && thread(c.earlier) == Some(ThreadIx(1))
            && thread(c.later) == Some(ThreadIx(0))),
        "expected wave 1's write racing wave 0's read, got {conflicts:?}"
    );
    assert!(matches!(
        report.conclusion(),
        GraphConclusion::Rejected { .. }
    ));
}
