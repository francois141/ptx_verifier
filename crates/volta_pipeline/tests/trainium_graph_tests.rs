//! NKI kernels' event graphs through the graph branch. Each instruction is a graph thread,
//! ordered after another only where `OrderingPolicy::DataFlowOnly` says the Neuron compiler
//! orders them: after the latest earlier writer of what it reads, outside different
//! `affine_range` iterations. Race-free kernels must conclude `Verified`; racy ones must fail
//! the memory-conflict check with exactly the expected pairs of instructions.

use std::collections::BTreeSet;

use volta_graph::{EventGraph, EventId, ExecContext};
use volta_graph_check::domain::ConflictKind::{self, ReadWrite, WriteRead, WriteWrite};
use volta_graph_check::{GraphConclusion, GraphReport, check_graph};
use volta_trainium_analysis::frontend::parse::{
    KernelCall, TileSizes, parse_kernel, parse_kernel_for_call,
};
use volta_trainium_analysis::{OrderingPolicy, lower_kernel, record_graph};

const FIXTURES: &str = concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../volta_trainium_analysis/tests/fixtures/"
);

/// Each parameter's name and shape.
type Shapes<'a> = &'a [(&'a str, &'a [u64])];

/// Kernel `kernel` of fixture `<name>.py`, called with `shapes`, recorded and checked.
fn check(name: &str, shapes: Shapes) -> (EventGraph, GraphReport) {
    let source = std::fs::read_to_string(format!("{FIXTURES}{name}.py")).unwrap();
    let parsed = parse_kernel(&source, "kernel", shapes).unwrap_or_else(|e| panic!("{name}: {e}"));
    let lowered = lower_kernel(&parsed).unwrap_or_else(|e| panic!("{name}: {e}"));
    let graph = record_graph(&lowered, OrderingPolicy::DataFlowOnly);
    let report = check_graph(&graph);
    (graph, report)
}

/// The instruction an event belongs to (its graph thread).
fn instruction(graph: &EventGraph, event: EventId) -> u32 {
    match graph.event(event).ctx {
        ExecContext::Thread(thread) => thread.0,
        ctx => panic!("an NKI access is its instruction's: {ctx:?}"),
    }
}

/// Each conflicting pair, as its earlier and later instruction and how they conflict.
fn conflicts(graph: &EventGraph, report: &GraphReport) -> BTreeSet<(u32, u32, ConflictKind)> {
    report
        .memory_conflict
        .violations()
        .iter()
        .map(|c| {
            let earlier = instruction(graph, c.earlier);
            (earlier, instruction(graph, c.later), c.kind)
        })
        .collect()
}

/// Race fixture `races/<name>.py` over `a` of `rows` rows of 4, `out` of one row fewer.
fn check_race(name: &str, rows: u64) -> (EventGraph, GraphReport) {
    let shapes: [(&str, &[u64]); 2] = [("a", &[rows, 4]), ("out", &[rows - 1, 4])];
    check(&format!("races/{name}"), &shapes)
}

// Test that kernels whose every reuse of a location is read-after-write verify: each tile
// is written once, or rewritten only by an instruction that reads it first.
#[test]
fn nki_kernels_ordered_by_data_flow_are_verified() {
    let matmul: [(&str, &[u64]); 3] = [("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])];
    let pair: [(&str, &[u64]); 2] = [("a", &[2, 4]), ("b", &[2, 4])];
    let softmax: [(&str, &[u64]); 1] = [("x", &[2, 3])];
    let kernels: [(&str, Shapes); 15] = [
        (
            "add",
            &[("a", &[16, 16]), ("b", &[16, 16]), ("out", &[16, 16])],
        ),
        ("sigmoid", &[("a", &[2, 4]), ("out", &[2, 4])]),
        ("transpose", &[("a", &[2, 3]), ("out", &[3, 2])]),
        ("matmul", &matmul),
        (
            "gemm_relu",
            &[("a_t", &[8, 4]), ("b", &[8, 4]), ("out", &[4, 4])],
        ),
        ("tiled_copy", &[("a", &[8, 4]), ("out", &[8, 4])]),
        ("rms_norm", &[("a", &[4, 8]), ("out", &[4, 8])]),
        ("returned_output", &pair),
        ("call_shapes", &pair),
        ("softmax", &softmax),
        ("accumulate", &matmul),
        ("regions_matmul", &matmul),
        ("subscripts_softmax", &softmax),
        ("fused_softmax", &[("x", &[2, 4])]),
        ("access_patterns", &[("a", &[2, 6])]),
    ];
    for (name, shapes) in kernels {
        let (graph, report) = check(name, shapes);
        assert_eq!(
            report.conclusion(),
            GraphConclusion::Verified,
            "{name}: {:?}",
            conflicts(&graph, &report)
        );
    }
}

// Test that two DMAs writing one tile race with each other, and the first with the read
// after them: only the second is the read's data-flow source (R0). In a sequential_range or
// an affine_range alike, a tile rewritten each iteration races the same way.
#[test]
fn nki_writes_to_one_tile_without_data_flow_between_them_race() {
    for name in [
        "back_to_back_dmas",
        "affine_overwrite",
        "sequential_overwrite",
    ] {
        let (graph, report) = check_race(name, 2);
        assert_eq!(
            conflicts(&graph, &report),
            BTreeSet::from([(0, 1, WriteWrite), (0, 2, WriteRead)]),
            "{name}"
        );
    }
}

// Test that a value carried through a rewritten tile races its rewrites (write after read and
// write after write) in a sequential_range, and in an affine_range also the read of the value
// the previous iteration wrote, as the iterations' data flow gives no order (R1).
#[test]
fn nki_values_carried_across_loop_iterations_race() {
    let rewrites = [
        (0, 2, WriteWrite),
        (1, 2, ReadWrite),
        (0, 3, WriteRead),
        (0, 4, WriteWrite),
        (1, 4, ReadWrite),
        (2, 4, WriteWrite),
        (3, 4, ReadWrite),
    ];
    let (graph, report) = check_race("sequential_carried", 3);
    assert_eq!(conflicts(&graph, &report), BTreeSet::from(rewrites));

    let (graph, report) = check_race("affine_carried", 3);
    let mut affine = BTreeSet::from(rewrites);
    affine.insert((2, 3, WriteRead));
    assert_eq!(conflicts(&graph, &report), affine);
}

// Test that accumulating into one tile across affine_range iterations races, with an add as
// mamba accumulates and with an nc_matmul into PSUM alike: a reduction is ordinary reads and
// writes, and the second iteration's read of the first's result is unordered.
#[test]
fn nki_accumulations_across_affine_range_iterations_race() {
    let (graph, report) = check_race("affine_vector_sum", 2);
    assert_eq!(
        conflicts(&graph, &report),
        BTreeSet::from([
            (0, 4, WriteRead),
            (0, 4, WriteWrite),
            (2, 4, WriteRead),
            (2, 4, ReadWrite),
            (2, 4, WriteWrite),
            (0, 5, WriteRead),
            (2, 5, WriteRead),
        ])
    );

    let shapes: [(&str, &[u64]); 3] = [("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])];
    let (graph, report) = check("races/affine_matmul_accumulate", &shapes);
    assert_eq!(
        conflicts(&graph, &report),
        BTreeSet::from([
            (0, 6, WriteRead),
            (0, 6, WriteWrite),
            (3, 6, WriteRead),
            (3, 6, ReadWrite),
            (3, 6, WriteWrite),
            (0, 7, WriteRead),
            (3, 7, WriteRead),
        ])
    );
}

// Test that a memset its tile's next writer overwrites unread races that write, as in
// scan.py's `scale`: nothing reads the memset, so no data flow orders the two.
#[test]
fn nki_an_overwritten_unread_memset_races_its_overwrite() {
    let shapes: [(&str, &[u64]); 3] = [("a", &[2, 3]), ("b", &[1, 3]), ("c", &[2, 1])];
    let (graph, report) = check("scan", &shapes);
    assert!(
        conflicts(&graph, &report).contains(&(2, 3, WriteWrite)),
        "{:?}",
        conflicts(&graph, &report)
    );
}

const SAMPLES: &str = concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../volta_trainium_analysis/tests/fixtures/nki_samples/"
);

fn sample(file: &str) -> String {
    std::fs::read_to_string(format!("{SAMPLES}{file}.py")).unwrap()
}

/// Sample `kernel` of `source` for `call`, recorded and checked.
fn check_sample(
    source: &str,
    modules: &[(&str, &str)],
    kernel: &str,
    call: &KernelCall,
) -> GraphReport {
    let parsed = parse_kernel_for_call(source, modules, kernel, call)
        .unwrap_or_else(|e| panic!("{kernel}: {e}"));
    let lowered = lower_kernel(&parsed).unwrap_or_else(|e| panic!("{kernel}: {e}"));
    check_graph(&record_graph(&lowered, OrderingPolicy::DataFlowOnly))
}

const fn tiles(pmax: u64, gemm_moving_fmax: u64) -> TileSizes {
    TileSizes {
        pmax,
        gemm_stationary_fmax: pmax,
        gemm_moving_fmax,
        sbuf_fmax_bytes: TileSizes::HARDWARE.sbuf_fmax_bytes,
    }
}

// Test that the attention samples v1 to v8a verify, each tile written once or rewritten only
// by its own readers, and that v10 races: it reuses PSUM banks (`address=` tiles) across its
// pipelined QK matmuls with no data flow between the reuses. v3 to v10 run at reduced tile
// sizes, their `seqlen_q >= 512` asserts stated as `>= FMAX_MOVING`.
#[test]
fn nki_attention_samples_verify_except_v10_reusing_psum_banks() {
    let kernels = sample("attention_kernels");
    let tileable = kernels.replace("assert seqlen_q >= 512", "assert seqlen_q >= FMAX_MOVING");
    let utils = sample("attention_kernel_utils");
    let modules = [("attention_kernel_utils", utils.as_str())];

    let full: &[u64] = &[128, 128];
    let shapes = [("q", full), ("k", full), ("v", full)];
    for kernel in ["attn_fwd_v1", "attn_fwd_v2"] {
        let report = check_sample(&kernels, &modules, kernel, &KernelCall::new(&shapes));
        assert_eq!(report.conclusion(), GraphConclusion::Verified, "{kernel}");
    }

    let reduced: &[u64] = &[4, 16];
    let shapes = [("q", reduced), ("k", reduced), ("v", reduced)];
    for kernel in [
        "attn_fwd_v3",
        "attn_fwd_v4",
        "attn_fwd_v5",
        "attn_fwd_v6",
        "attn_fwd_v7",
        "attn_fwd_v8",
        "attn_fwd_v8a",
        "attn_fwd_v10",
    ] {
        let dtype = if kernel == "attn_fwd_v10" {
            "bfloat16"
        } else {
            "float32"
        };
        let dtypes = [("q", dtype), ("k", dtype), ("v", dtype)];
        let call = KernelCall {
            dtypes: &dtypes,
            tile_sizes: tiles(4, 8),
            ..KernelCall::new(&shapes)
        };
        let report = check_sample(&tileable, &modules, kernel, &call);
        let verified = report.conclusion() == GraphConclusion::Verified;
        assert_eq!(verified, kernel != "attn_fwd_v10", "{kernel}");
        assert_eq!(
            report.memory_conflict.violations().is_empty(),
            verified,
            "{kernel}"
        );
    }
}

// Test that the tutorials accumulating inside an affine_range race: the tiled matmul's
// nc_matmuls into one PSUM tile, and mamba's tensor_tensor adds into `scanC_accum`.
#[test]
fn nki_tutorials_accumulating_across_affine_range_iterations_race() {
    let (lhs_t, rhs): (&[u64], &[u64]) = (&[8, 4], &[8, 8]);
    let shapes = [("lhsT", lhs_t), ("rhs", rhs)];
    let call = KernelCall {
        tile_sizes: tiles(2, 4),
        ..KernelCall::new(&shapes)
    };
    let source = sample("matrix_multiplication_nki_kernels");
    let report = check_sample(&source, &[], "nki_matmul_tiled_", &call);
    assert!(!report.memory_conflict.violations().is_empty());

    let (sequence, a, by_state): (&[u64], &[u64], &[u64]) = (&[2, 128, 8], &[128, 2], &[2, 2, 8]);
    let shapes = [
        ("delta", sequence),
        ("u", sequence),
        ("A", a),
        ("B", by_state),
        ("C", by_state),
    ];
    let dtypes = ["delta", "u", "A", "B", "C"].map(|param| (param, "float32"));
    let call = KernelCall {
        dtypes: &dtypes,
        tile_sizes: tiles(64, 4),
        ..KernelCall::new(&shapes)
    };
    let source = sample("mamba_nki_kernels");
    let report = check_sample(&source, &[], "mamba_v1", &call);
    assert!(!report.memory_conflict.violations().is_empty());
}
