//! NKI kernels' event graphs through the graph branch. Each instruction is a graph thread,
//! ordered after another only where the `OrderingPolicy` says the Neuron compiler orders
//! them. Every policy orders read after write and write after read outside different
//! `affine_range` iterations, where `nc_matmul` accumulations commute instead; `BASELINE`, the
//! pipeline's, tracks hazards by address, through the bytes placed tiles share, lets
//! `tensor_tensor` add accumulations commute too, and orders nothing more. The others order
//! write after write, track hazards per tensor only, order `no_reorder` blocks in program
//! order, or let only `nc_matmul` accumulations commute. Race-free kernels must conclude `Verified`; racy ones must fail the
//! memory-conflict check with exactly the expected pairs of instructions.

use std::collections::BTreeSet;
use std::fmt::Write;

use volta_graph::{Assumption, EventGraph, EventId, ExecContext, Terminal, ThreadIx};
use volta_graph_check::domain::ConflictKind::{self, ReadWrite, WriteRead, WriteWrite};
use volta_graph_check::{GraphConclusion, GraphReport, check_graph};
use volta_trainium_analysis::frontend::parse::{
    Constant, KernelCall, TileSizes, parse_kernel, parse_kernel_for_call,
};
use volta_trainium_analysis::{
    Execution, InstrId, LoweredKernel, NoReorder, OrderingPolicy, PlacedTiles, Reductions,
    Reordering, WriteAfterWrite, evaluate, footprints, lower_kernel, record_graph,
};

const FIXTURES: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/tests/trainium/");

/// Each parameter's name and shape.
type Shapes<'a> = &'a [(&'a str, &'a [u64])];

const WAW: OrderingPolicy = OrderingPolicy {
    write_after_write: WriteAfterWrite::Ordered,
    ..OrderingPolicy::BASELINE
};

const BY_TENSOR: OrderingPolicy = OrderingPolicy {
    placed_tiles: PlacedTiles::ByTensor,
    ..OrderingPolicy::BASELINE
};

const NO_REORDER: OrderingPolicy = OrderingPolicy {
    no_reorder: NoReorder::ProgramOrder,
    ..OrderingPolicy::BASELINE
};

/// Kernel `kernel` of fixture `<name>.py`, called with `shapes`, recorded under `policy`
/// and checked.
fn check_under(policy: OrderingPolicy, name: &str, shapes: Shapes) -> (EventGraph, GraphReport) {
    let source = std::fs::read_to_string(format!("{FIXTURES}{name}.py")).unwrap();
    let parsed = parse_kernel(&source, "kernel", shapes).unwrap_or_else(|e| panic!("{name}: {e}"));
    let lowered = lower_kernel(&parsed).unwrap_or_else(|e| panic!("{name}: {e}"));
    let graph = record(&lowered, policy);
    let report = check_graph(&graph);
    (graph, report)
}

/// `kernel`'s graph under `policy`, ending as its program-order run did.
fn record(kernel: &LoweredKernel, policy: OrderingPolicy) -> EventGraph {
    record_graph(kernel, policy, &Execution::of(&evaluate(kernel)))
}

/// `check_under` the pipeline's policy, `BASELINE`.
fn check(name: &str, shapes: Shapes) -> (EventGraph, GraphReport) {
    check_under(OrderingPolicy::BASELINE, name, shapes)
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

/// Race fixture `check_failure/<name>.py` over `a` of `rows` rows of 4, `out` of one row
/// fewer, under `policy`.
fn check_race_under(policy: OrderingPolicy, name: &str, rows: u64) -> (EventGraph, GraphReport) {
    let shapes: [(&str, &[u64]); 2] = [("a", &[rows, 4]), ("out", &[rows - 1, 4])];
    check_under(policy, &format!("check_failure/{name}"), &shapes)
}

// Test that kernels whose every reuse of a location is read or rewritten in order verify:
// each tile is written once, or rewritten after its readers, sequential_carried across the
// iterations of a sequential_range.
#[test]
fn nki_kernels_rewriting_tiles_only_after_reading_them_are_verified() {
    let matmul: [(&str, &[u64]); 3] = [("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])];
    let pair: [(&str, &[u64]); 2] = [("a", &[2, 4]), ("b", &[2, 4])];
    let softmax: [(&str, &[u64]); 1] = [("x", &[2, 3])];
    let kernels: [(&str, Shapes); 17] = [
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
        ("placed_tiles", &[("a_t", &[4, 2]), ("b", &[4, 3])]),
        ("sequential_carried", &[("a", &[3, 4]), ("out", &[2, 4])]),
    ];
    for (name, shapes) in kernels {
        let (graph, report) = check(&format!("success/{name}"), shapes);
        assert_eq!(
            report.conclusion(),
            GraphConclusion::Verified,
            "{name}: {:?}",
            conflicts(&graph, &report)
        );
        assert_eq!(
            graph.provenance().assumptions,
            [
                Assumption::NkiReadAfterWriteOrder,
                Assumption::NkiWriteAfterReadOrder,
                Assumption::NkiMatmulAccumulationsCommute,
                Assumption::NkiTensorTensorAddsCommute,
                Assumption::NkiHazardsByPlacedAddress
            ]
        );
    }
}

// Test that two writes to one tile with no read between them race with each other, and the
// first with the read after them (R0), back to back or in a sequential_range, and are ordered
// once the policy orders write after write; across affine_range iterations they race anyway.
#[test]
fn nki_writes_to_one_tile_without_a_read_between_them_race_unless_write_after_write_is_ordered() {
    let races = BTreeSet::from([(0, 1, WriteWrite), (0, 2, WriteRead)]);
    for name in [
        "back_to_back_dmas",
        "affine_overwrite",
        "sequential_overwrite",
    ] {
        let (graph, report) = check_race_under(OrderingPolicy::BASELINE, name, 2);
        assert_eq!(conflicts(&graph, &report), races, "{name}");

        let (graph, report) = check_race_under(WAW, name, 2);
        if name == "affine_overwrite" {
            assert_eq!(conflicts(&graph, &report), races, "{name}");
        } else {
            assert_eq!(report.conclusion(), GraphConclusion::Verified, "{name}");
            assert!(
                graph
                    .provenance()
                    .assumes(Assumption::NkiWriteAfterWriteOrder)
            );
        }
    }
}

// Test that a value carried through a rewritten tile across affine_range iterations races
// under every policy: each iteration's read of what the previous one wrote, and its rewrite
// of what the previous one read and wrote, are unordered (R1). sequential_carried, its twin,
// verifies.
#[test]
fn nki_values_carried_across_affine_range_iterations_race_under_every_policy() {
    for policy in OrderingPolicy::ALL {
        let (graph, report) = check_race_under(policy, "affine_carried", 3);
        assert_eq!(
            conflicts(&graph, &report),
            BTreeSet::from([
                (0, 3, WriteRead),
                (0, 4, WriteWrite),
                (1, 4, ReadWrite),
                (2, 3, WriteRead),
                (2, 4, WriteWrite),
            ]),
            "{policy:?}"
        );
    }
}

// Test that accumulations into one tile across affine_range iterations commute where the
// policy says the docs' reduction exemption covers them: nc_matmuls into PSUM under every
// policy, a tensor_tensor add as mamba accumulates unless the policy is `Reductions::Matmul`.
// A read of the partial sum inside the loop still races the other iteration's accumulation
// (R8) under every policy, while the accumulations themselves do not race.
#[test]
fn nki_accumulations_across_affine_range_iterations_commute_where_the_policy_exempts_them() {
    let matmul: [(&str, &[u64]); 3] = [("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])];
    let partial: [(&str, &[u64]); 3] = [("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[4, 3])];
    let rows: [(&str, &[u64]); 2] = [("a", &[2, 4]), ("out", &[1, 4])];
    for policy in OrderingPolicy::ALL {
        let (graph, report) = check_under(policy, "success/affine_matmul_accumulate", &matmul);
        assert_eq!(
            report.conclusion(),
            GraphConclusion::Verified,
            "{policy:?}: {:?}",
            conflicts(&graph, &report)
        );
        assert!(
            graph
                .provenance()
                .assumes(Assumption::NkiMatmulAccumulationsCommute)
        );

        let (graph, report) =
            check_under(policy, "check_failure/affine_matmul_partial_read", &partial);
        assert_eq!(
            conflicts(&graph, &report),
            BTreeSet::from([(2, 8, WriteRead), (3, 7, ReadWrite)]),
            "{policy:?}"
        );

        let (graph, report) = check_under(policy, "success/affine_vector_sum", &rows);
        if policy.reductions == Reductions::MatmulAndAdd {
            assert_eq!(report.conclusion(), GraphConclusion::Verified, "{policy:?}");
            assert!(
                graph
                    .provenance()
                    .assumes(Assumption::NkiTensorTensorAddsCommute)
            );
        } else {
            assert_eq!(
                conflicts(&graph, &report),
                BTreeSet::from([
                    (0, 4, WriteRead),
                    (0, 4, WriteWrite),
                    (0, 5, WriteRead),
                    (2, 4, WriteRead),
                    (2, 4, WriteWrite),
                    (2, 4, ReadWrite),
                    (2, 5, WriteRead),
                ]),
                "{policy:?}"
            );
        }
    }
}

// Test that a memset its tile's next writer overwrites unread races that write and the reads
// after it, as in scan.py's `scale`, until the policy orders write after write.
#[test]
fn nki_an_overwritten_unread_memset_races_unless_write_after_write_is_ordered() {
    let shapes: [(&str, &[u64]); 3] = [("a", &[2, 3]), ("b", &[1, 3]), ("c", &[2, 1])];
    let (graph, report) = check("check_failure/scan", &shapes);
    assert_eq!(
        conflicts(&graph, &report),
        BTreeSet::from([(2, 3, WriteWrite), (2, 5, WriteRead), (2, 7, WriteRead)])
    );
    let (_, report) = check_under(WAW, "check_failure/scan", &shapes);
    assert_eq!(report.conclusion(), GraphConclusion::Verified);
}

const SAMPLES: &str = concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/tests/trainium/success/nki_samples/"
);

fn sample(file: &str) -> String {
    std::fs::read_to_string(format!("{SAMPLES}{file}.py")).unwrap()
}

/// Sample `kernel` of `source` for `call`, lowered.
fn lower_sample(
    source: &str,
    modules: &[(&str, &str)],
    kernel: &str,
    call: &KernelCall,
) -> LoweredKernel {
    let parsed = parse_kernel_for_call(source, modules, kernel, call)
        .unwrap_or_else(|e| panic!("{kernel}: {e}"));
    lower_kernel(&parsed).unwrap_or_else(|e| panic!("{kernel}: {e}"))
}

const fn tiles(pmax: u64, gemm_moving_fmax: u64) -> TileSizes {
    TileSizes {
        pmax,
        gemm_stationary_fmax: pmax,
        gemm_moving_fmax,
        sbuf_fmax_bytes: TileSizes::HARDWARE.sbuf_fmax_bytes,
    }
}

/// The attention samples' file, its `seqlen_q >= 512` asserts stated as `>= FMAX_MOVING`,
/// and its utilities module.
fn attention_sources() -> (String, String) {
    let kernels = sample("attention_kernels");
    let tileable = kernels.replace("assert seqlen_q >= 512", "assert seqlen_q >= FMAX_MOVING");
    (tileable, sample("attention_kernel_utils"))
}

/// Tiled attention `kernel` (v3 to v10) at `[4, 16]` with tile sizes 4 x 8, lowered.
fn tiled_attention(kernel: &str) -> LoweredKernel {
    let (tileable, utils) = attention_sources();
    let modules = [("attention_kernel_utils", utils.as_str())];
    let reduced: &[u64] = &[4, 16];
    let shapes = [("q", reduced), ("k", reduced), ("v", reduced)];
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
    lower_sample(&tileable, &modules, kernel, &call)
}

// Test that the attention samples verify, each tile written once or rewritten only after its
// readers, v10 because hazards are tracked by address: its `address=` tiles `v_psum_t` and
// `qk_psum` share PSUM bytes, and tracked per tensor only they race.
#[test]
fn nki_attention_samples_verify_v10_only_when_hazards_are_tracked_by_address() {
    let (kernels, utils) = attention_sources();
    let modules = [("attention_kernel_utils", utils.as_str())];
    let full: &[u64] = &[128, 128];
    let shapes = [("q", full), ("k", full), ("v", full)];
    for kernel in ["attn_fwd_v1", "attn_fwd_v2"] {
        let lowered = lower_sample(&kernels, &modules, kernel, &KernelCall::new(&shapes));
        let report = check_graph(&record(&lowered, OrderingPolicy::BASELINE));
        assert_eq!(report.conclusion(), GraphConclusion::Verified, "{kernel}");
    }

    for kernel in [
        "attn_fwd_v3",
        "attn_fwd_v4",
        "attn_fwd_v5",
        "attn_fwd_v6",
        "attn_fwd_v7",
        "attn_fwd_v8",
        "attn_fwd_v8a",
    ] {
        let report = check_graph(&record(&tiled_attention(kernel), OrderingPolicy::BASELINE));
        assert_eq!(report.conclusion(), GraphConclusion::Verified, "{kernel}");
    }

    let v10 = tiled_attention("attn_fwd_v10");
    let report = check_graph(&record(&v10, BY_TENSOR));
    assert!(!report.memory_conflict.violations().is_empty());
    let graph = record(&v10, OrderingPolicy::BASELINE);
    assert_eq!(check_graph(&graph).conclusion(), GraphConclusion::Verified);
    assert!(
        graph
            .provenance()
            .assumes(Assumption::NkiHazardsByPlacedAddress)
    );
}

// Test that attention v10's races with hazards tracked per tensor, with or without its
// no_reorder block in program order, all pair `v_psum_t`, transposed before the block, with `qk_psum`, which the QK matmuls
// inside it place over the same PSUM bytes (R3): every reuse within one tensor is ordered,
// and the block orders nothing against the instructions before it.
#[test]
fn nki_attention_v10_races_only_between_tiles_placed_over_the_same_bytes() {
    let lowered = tiled_attention("attn_fwd_v10");
    let accesses = footprints(&lowered);
    let in_block = |i: u32| lowered.origins[InstrId(i)].reordering != Reordering::Allowed;
    let tensors = |i: u32| -> Vec<&str> {
        accesses[InstrId(i)]
            .iter()
            .map(|access| lowered.tensors[access.tensor].name.as_str())
            .collect()
    };
    let by_tensor_in_order = OrderingPolicy {
        no_reorder: NoReorder::ProgramOrder,
        ..BY_TENSOR
    };
    for policy in [BY_TENSOR, by_tensor_in_order] {
        let graph = record(&lowered, policy);
        let pairs = conflicts(&graph, &check_graph(&graph));
        assert!(!pairs.is_empty(), "{policy:?}");
        for &(earlier, later, kind) in &pairs {
            assert!(
                !in_block(earlier) && in_block(later),
                "{policy:?}: {earlier} -> {later} {kind:?}"
            );
            assert!(tensors(earlier).contains(&"v_psum_t"), "{earlier}");
            assert!(tensors(later).contains(&"qk_psum"), "{later}");
        }
    }
}

// Test that the tutorials accumulating inside an affine_range verify where the policy exempts
// their accumulations: the tiled matmul's nc_matmuls into one PSUM tile under every policy,
// mamba's tensor_tensor adds into `scanC_accum` unless the policy is `Reductions::Matmul`.
#[test]
fn nki_tutorials_accumulating_across_affine_range_iterations_verify_where_exempted() {
    let (lhs_t, rhs): (&[u64], &[u64]) = (&[8, 4], &[8, 8]);
    let shapes = [("lhsT", lhs_t), ("rhs", rhs)];
    let call = KernelCall {
        tile_sizes: tiles(2, 4),
        ..KernelCall::new(&shapes)
    };
    let source = sample("matrix_multiplication_nki_kernels");
    let matmul = lower_sample(&source, &[], "nki_matmul_tiled_", &call);

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
    let mamba = lower_sample(&source, &[], "mamba_v1", &call);

    let (matmul_run, mamba_run) = (
        Execution::of(&evaluate(&matmul)),
        Execution::of(&evaluate(&mamba)),
    );
    for policy in OrderingPolicy::ALL {
        let report = check_graph(&record_graph(&matmul, policy, &matmul_run));
        assert_eq!(report.conclusion(), GraphConclusion::Verified, "{policy:?}");
        let report = check_graph(&record_graph(&mamba, policy, &mamba_run));
        assert_eq!(
            report.conclusion() == GraphConclusion::Verified,
            policy.reductions == Reductions::MatmulAndAdd,
            "{policy:?}"
        );
    }
}

// Test that a no_reorder block orders its own instructions when the policy keeps blocks in
// program order, and nothing otherwise: two DMAs writing one tile in a block, and an
// affine_range's iterations rewriting one tile in a block, race under BASELINE and verify
// under NO_REORDER, which records its assumption. A write before the block still races the
// block's rewrite and read, until write after write is ordered.
#[test]
fn nki_no_reorder_blocks_order_their_own_instructions_when_the_policy_keeps_them() {
    let rows: [(&str, &[u64]); 2] = [("a", &[2, 4]), ("out", &[1, 4])];
    let both: [(&str, &[u64]); 2] = [("a", &[2, 4]), ("out", &[2, 4])];
    for (name, shapes, races) in [
        (
            "no_reorder_back_to_back_dmas",
            &rows,
            vec![(0, 1, WriteWrite), (0, 2, WriteRead)],
        ),
        (
            "no_reorder_affine",
            &both,
            vec![(0, 2, WriteWrite), (1, 2, ReadWrite), (0, 3, WriteRead)],
        ),
    ] {
        let name = format!("check_failure/{name}");
        let (graph, report) = check(&name, shapes);
        assert_eq!(
            conflicts(&graph, &report),
            BTreeSet::from_iter(races),
            "{name}"
        );

        let (graph, report) = check_under(NO_REORDER, &name, shapes);
        assert_eq!(report.conclusion(), GraphConclusion::Verified, "{name}");
        assert_eq!(
            graph.provenance().assumptions,
            [
                Assumption::NkiReadAfterWriteOrder,
                Assumption::NkiWriteAfterReadOrder,
                Assumption::NkiMatmulAccumulationsCommute,
                Assumption::NkiTensorTensorAddsCommute,
                Assumption::NkiHazardsByPlacedAddress,
                Assumption::NkiNoReorderInProgramOrder
            ]
        );
    }

    for policy in [OrderingPolicy::BASELINE, NO_REORDER] {
        let (graph, report) = check_under(policy, "check_failure/no_reorder_boundary", &rows);
        assert_eq!(
            conflicts(&graph, &report),
            BTreeSet::from([(0, 1, WriteWrite), (0, 2, WriteRead)]),
            "{policy:?}"
        );
    }
    let (_, report) = check_under(WAW, "check_failure/no_reorder_boundary", &rows);
    assert_eq!(report.conclusion(), GraphConclusion::Verified);
}

// Test that a run aborting at an instruction ends its graph there, as PTX's and AMD's do, so
// the graph branch is inconclusive, not verified: `accumulate_uninitialized`, race free,
// accumulates into unwritten PSUM at instruction 2.
#[test]
fn nki_graphs_of_aborted_runs_end_at_the_failing_instruction() {
    let source =
        std::fs::read_to_string(format!("{FIXTURES}execution_error/placement_errors.py")).unwrap();
    let parsed = parse_kernel(
        &source,
        "accumulate_uninitialized",
        &[("a_t", &[4, 2]), ("b", &[4, 3])],
    )
    .unwrap();
    let graph = record(&lower_kernel(&parsed).unwrap(), OrderingPolicy::BASELINE);
    assert!(
        matches!(
            graph.terminal(),
            Terminal::Aborted {
                thread: Some(ThreadIx(2)),
                ..
            }
        ),
        "{:?}",
        graph.terminal()
    );
    let last = graph
        .events()
        .iter()
        .map(|(id, _)| id)
        .filter_map(|id| match graph.event(id).ctx {
            ExecContext::Thread(thread) => Some(thread.0),
            _ => None,
        });
    assert_eq!(last.max(), Some(2));
    let conclusion = check_graph(&graph).conclusion();
    assert!(
        matches!(conclusion, GraphConclusion::Unknown { .. }),
        "{conclusion:?}"
    );
}

/// One kernel of the policy table: its fixture or sample and its lowered form.
struct Probe {
    label: String,
    kernel: LoweredKernel,
    execution: Execution,
}

impl Probe {
    fn new(label: String, kernel: LoweredKernel) -> Probe {
        let execution = Execution::of(&evaluate(&kernel));
        Probe {
            label,
            kernel,
            execution,
        }
    }
}

fn probe_fixture(name: &str, call: &KernelCall) -> Probe {
    let source = std::fs::read_to_string(format!("{FIXTURES}{name}.py")).unwrap();
    let parsed = parse_kernel_for_call(&source, &[], "kernel", call)
        .unwrap_or_else(|e| panic!("{name}: {e}"));
    let kernel = lower_kernel(&parsed).unwrap_or_else(|e| panic!("{name}: {e}"));
    Probe::new(name.to_string(), kernel)
}

fn probe_sample(
    file: &str,
    source: &str,
    modules: &[(&str, &str)],
    kernel: &str,
    call: &KernelCall,
) -> Probe {
    let lowered = lower_sample(source, modules, kernel, call);
    Probe::new(format!("{file}::{kernel}"), lowered)
}

/// Every NKI fixture and sample this suite has, at the shapes its other tests call it with.
fn probes() -> Vec<Probe> {
    let mut probes = Vec::new();
    let matmul: [(&str, &[u64]); 3] = [("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[2, 3])];
    let pair: [(&str, &[u64]); 2] = [("a", &[2, 4]), ("b", &[2, 4])];
    let softmax: [(&str, &[u64]); 1] = [("x", &[2, 3])];
    let tile: &[u64] = &[2, 2];
    let language_api: [(&str, &[u64]); 5] = [
        ("a", tile),
        ("b", tile),
        ("mx", &[2, 1]),
        ("rs", &[2, 1]),
        ("tr", tile),
    ];
    let fixtures: [(&str, Shapes); 21] = [
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
        ("loop_origins", &[("a", &[2, 4]), ("out", &[2, 4])]),
        ("tiled_copy", &[("a", &[8, 4]), ("out", &[8, 4])]),
        ("rms_norm", &[("a", &[4, 8]), ("out", &[4, 8])]),
        ("returned_output", &pair),
        ("call_shapes", &pair),
        ("softmax", &softmax),
        ("language_api", &language_api),
        ("accumulate", &matmul),
        ("regions_softmax", &softmax),
        ("regions_matmul", &matmul),
        ("subscripts_softmax", &softmax),
        ("subscripts_matmul", &matmul),
        ("fused_softmax", &[("x", &[2, 4])]),
        ("placed_tiles", &[("a_t", &[4, 2]), ("b", &[4, 3])]),
        ("access_patterns", &[("a", &[2, 6])]),
        ("sequential_carried", &[("a", &[3, 4]), ("out", &[2, 4])]),
    ];
    for (name, shapes) in fixtures {
        probes.push(probe_fixture(
            &format!("success/{name}"),
            &KernelCall::new(shapes),
        ));
    }
    let pipelined = KernelCall {
        dtypes: &[("a", "bfloat16")],
        ..KernelCall::new(&[("a", &[6, 4])])
    };
    probes.push(probe_fixture("success/pipelined_scale", &pipelined));
    let offsets: [u64; 16] = [3, 0, 3, 1, 2, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2];
    let indirect = KernelCall {
        contents: &[("idx", &offsets)],
        ..KernelCall::new(&[("a", &[32, 4]), ("idx", &[16, 1])])
    };
    probes.push(probe_fixture("success/indirect", &indirect));

    let rows = |count: u64| [("a", [count, 4]), ("out", [count - 1, 4])];
    for (name, [a, out]) in [
        ("back_to_back_dmas", rows(2)),
        ("affine_overwrite", rows(2)),
        ("sequential_overwrite", rows(2)),
        ("affine_carried", rows(3)),
        ("no_reorder_back_to_back_dmas", rows(2)),
        ("no_reorder_boundary", rows(2)),
    ] {
        let shapes = [(a.0, a.1.as_slice()), (out.0, out.1.as_slice())];
        probes.push(probe_fixture(
            &format!("check_failure/{name}"),
            &KernelCall::new(&shapes),
        ));
    }
    probes.push(probe_fixture(
        "success/affine_vector_sum",
        &KernelCall::new(&[("a", &[2, 4]), ("out", &[1, 4])]),
    ));
    probes.push(probe_fixture(
        "success/affine_matmul_accumulate",
        &KernelCall::new(&matmul),
    ));
    probes.push(probe_fixture(
        "check_failure/affine_matmul_partial_read",
        &KernelCall::new(&[("a_t", &[4, 2]), ("b", &[4, 3]), ("out", &[4, 3])]),
    ));
    probes.push(probe_fixture(
        "check_failure/no_reorder_affine",
        &KernelCall::new(&[("a", &[2, 4]), ("out", &[2, 4])]),
    ));
    probes.push(probe_fixture(
        "check_failure/scan",
        &KernelCall::new(&[("a", &[2, 3]), ("b", &[1, 3]), ("c", &[2, 1])]),
    ));

    let (kernels, utils) = attention_sources();
    let modules = [("attention_kernel_utils", utils.as_str())];
    let full: &[u64] = &[128, 128];
    let shapes = [("q", full), ("k", full), ("v", full)];
    for kernel in ["attn_fwd_v1", "attn_fwd_v2"] {
        let call = KernelCall::new(&shapes);
        probes.push(probe_sample("attention", &kernels, &modules, kernel, &call));
    }
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
        probes.push(Probe::new(
            format!("attention::{kernel}"),
            tiled_attention(kernel),
        ));
    }

    let add: &[u64] = &[128, 512];
    let shapes = [("a_input", add), ("b_input", add)];
    let call = KernelCall {
        dtypes: &[("a_input", "float32"), ("b_input", "float32")],
        ..KernelCall::new(&shapes)
    };
    let source = sample("tensor_addition_nki_kernels");
    probes.push(probe_sample(
        "tensor_addition",
        &source,
        &[],
        "nki_tensor_add",
        &call,
    ));

    let source = sample("matrix_multiplication_nki_kernels");
    let basic = KernelCall::new(&[("lhsT", &[128, 64]), ("rhs", &[128, 512])]);
    probes.push(probe_sample(
        "matrix_multiplication",
        &source,
        &[],
        "nki_matmul_basic_",
        &basic,
    ));
    let tiled = KernelCall {
        tile_sizes: tiles(2, 4),
        ..KernelCall::new(&[("lhsT", &[16, 32]), ("rhs", &[16, 8])])
    };
    for kernel in [
        "nki_matmul_tiled_",
        "nki_matmul_hoist_load_",
        "nki_matmul_block_free_dimension_",
        "nki_matmul_fully_optimized_",
    ] {
        probes.push(probe_sample(
            "matrix_multiplication",
            &source,
            &[],
            kernel,
            &tiled,
        ));
    }

    let source = sample("transpose2d_nki_kernels");
    let shape_2d = [3, 4];
    let constants = [("shape2D", Constant::Ints(&shape_2d))];
    let call = KernelCall {
        dtypes: &[("in_tensor", "float32")],
        constants: &constants,
        ..KernelCall::new(&[("in_tensor", &[5, 12])])
    };
    probes.push(probe_sample(
        "transpose2d",
        &source,
        &[],
        "tensor_transpose2D_kernel_",
        &call,
    ));

    let source = sample("average_pool2d_nki_kernels");
    let constants = [("pool_size", Constant::Int(2))];
    let call = KernelCall {
        dtypes: &[("in_tensor", "float32")],
        constants: &constants,
        ..KernelCall::new(&[("in_tensor", &[2, 6, 6])])
    };
    probes.push(probe_sample(
        "average_pool2d",
        &source,
        &[],
        "tensor_avgpool_kernel",
        &call,
    ));

    let source = sample("mamba_nki_kernels").replace(
        "seq_len_fsize = 512\n",
        "seq_len_fsize = nl.tile_size.gemm_moving_fmax\n",
    );
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
    for kernel in ["mamba_v1", "mamba_v2", "mamba_v3"] {
        probes.push(probe_sample("mamba", &source, &[], kernel, &call));
    }

    let source = sample("tensor_indirection_nki_kernels");
    let offsets: Vec<u64> = (0..32).map(|i| (i * 7) % 64).collect();
    let call = KernelCall {
        contents: &[("index_tensor", &offsets)],
        ..KernelCall::new(&[("index_tensor", &[1, 32]), ("data_tensor", &[128, 64])])
    };
    probes.push(probe_sample(
        "tensor_indirection",
        &source,
        &[],
        "tensor_indirection_kernel",
        &call,
    ));
    probes
}

/// A policy's column heading: how it differs from `BASELINE`.
fn heading(policy: OrderingPolicy) -> String {
    let mut letters = String::new();
    if policy.write_after_write == WriteAfterWrite::Ordered {
        letters.push('w');
    }
    if policy.placed_tiles == PlacedTiles::ByTensor {
        letters.push('t');
    }
    if policy.no_reorder == NoReorder::ProgramOrder {
        letters.push('n');
    }
    if policy.reductions == Reductions::Matmul {
        letters.push('m');
    }
    if letters.is_empty() {
        "base".to_string()
    } else {
        letters
    }
}

// Test each NKI kernel's verdict under every ordering policy against `ordering_policies.txt`
// (`VOLTA_BLESS=1` rewrites it): which kernels each assumption about the Neuron compiler
// would let through.
#[test]
fn nki_verdicts_under_each_ordering_policy_match_the_table() {
    let mut table = String::from(
        "# Each NKI kernel's graph under each OrderingPolicy: ok (Verified) or its number of\n\
         # conflicting access pairs. Every policy orders read after write and write after read\n\
         # outside affine_range iterations, by address through placed tiles' shared bytes, and\n\
         # lets nc_matmul and tensor_tensor add accumulations commute (base); a column's\n\
         # letters add write after write (w), track hazards per tensor only (t), order\n\
         # no_reorder blocks in program order (n), or let only nc_matmul accumulations\n\
         # commute (m).\n",
    );
    let headings: Vec<String> = OrderingPolicy::ALL.into_iter().map(heading).collect();
    writeln!(
        table,
        "{:56}{}",
        "kernel",
        headings
            .iter()
            .map(|h| format!("{h:>6}"))
            .collect::<String>()
    )
    .unwrap();
    for probe in probes() {
        write!(table, "{:56}", probe.label).unwrap();
        for policy in OrderingPolicy::ALL {
            let report = check_graph(&record_graph(&probe.kernel, policy, &probe.execution));
            let cell = match report.conclusion() {
                GraphConclusion::Verified => "ok".to_string(),
                _ => report.memory_conflict.violations().len().to_string(),
            };
            write!(table, "{cell:>6}").unwrap();
        }
        writeln!(table).unwrap();
    }
    crate::common::trainium::compare(
        crate::common::trainium::fixtures().join("ordering_policies.txt"),
        table,
    );
}
