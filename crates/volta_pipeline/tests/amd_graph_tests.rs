//! AMD kernels' event graphs through the graph branch: one graph thread per wave, and each
//! `s_barrier` a generation the waves gather into and are scattered from.

use std::path::{Path, PathBuf};

use volta_amd_analysis::ArrayKind::{Input, Output};
use volta_amd_analysis::OutputType::F32;
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, WorkgroupLaunch, analyze};
use volta_expr::SymbolicOutputs;
use volta_graph::{BarrierArrivals, ContributionKind, EventId, GenerationKind, ThreadIx};
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

// Test that `exchange` writes lds_sync.out, that its two waves gather into one s_barrier generation
// and are scattered from it, and that the graph checks find no race (vacuously for now: no memory
// access is recorded yet).
#[test]
fn the_waves_gather_into_a_barrier_generation_and_are_scattered_from_it() {
    let source = std::fs::read_to_string(fixture("lds_sync.s")).unwrap();
    let kernel = parse_kernel(&source, "exchange").unwrap();
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
    let result = analyze(&kernel, &launch, &kernarg, &arrays).unwrap();
    assert_out_file(
        &fixture("lds_sync.out"),
        result.symbolic_outputs.as_ref().unwrap(),
    );

    let graph = &result.graph;
    let generations: Vec<_> = graph.generations().values().collect();
    let [barrier] = generations[..] else {
        panic!("expected one barrier generation, got {generations:?}");
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
}
