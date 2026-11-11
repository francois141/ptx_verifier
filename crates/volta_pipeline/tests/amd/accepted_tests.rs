//! AMD kernels expected to complete: each fixture kernel's symbolic outputs, compared with
//! `amd/success/<name>.out`, and the launch and grid behavior around them.

use crate::common;

use common::amd::{CK_GEMM_KERNEL, array, array_of, ck_gemm_kernarg};
use volta_amd_analysis::OutputType::{F32, U32};
use volta_amd_analysis::frontend::ast::{Kernel, Operand};
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{
    AnalysisError, AnalysisResult, ArrayKind, EvalError, InstrId, StoreConflict, Terminal, WaveId,
    WorkgroupLaunch, analyze, analyze_grid,
};
use volta_expr::SymbolicOutputs;

// Test nonzero X/Y/Z coordinates in every lane, including descriptors with unused axes.
#[test]
fn workgroup_ids_follow_the_kernel_descriptor() {
    let cases: [(&str, &[u32]); 4] = [
        ("workgroup_x", &[2]),
        ("workgroup_y", &[3]),
        ("workgroup_z", &[5]),
        ("workgroup_xyz", &[2, 3, 5]),
    ];
    for (name, expected) in cases {
        let actual = run_workgroup_id_kernel(name).symbolic_outputs.unwrap();
        assert_eq!(actual.outputs.len(), 1);
        let (array, elements) = &actual.outputs[0];
        assert_eq!(array, "out");
        assert_eq!(elements.len(), expected.len() * 64);

        // Each coordinate must reach all 64 lanes, with no missing or extra stores.
        for (i, &(index, value)) in elements.iter().enumerate() {
            assert_eq!(index, i as u64);
            assert_eq!(
                actual.arena.as_int_const(value),
                Some(i64::from(expected[i / 64])),
                "{name}[{index}]"
            );
        }
    }
}

// Test that graph metadata identifies the selected workgroup and the full launch grid.
#[test]
fn workgroup_graph_records_selected_launch() {
    let result = run_workgroup_id_kernel("workgroup_xyz");
    let provenance = result.graph.provenance();
    assert_eq!(provenance.grid_dim, (3, 4, 6));
    assert!(provenance.assumes(volta_graph::Assumption::SingleWorkgroupAnalyzed { id: (2, 3, 5) }));
}

/// Run a coordinate fixture in workgroup (2, 3, 5) with room for all three coordinates per lane.
fn run_workgroup_id_kernel(name: &str) -> AnalysisResult {
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (64, 1, 1),
        workgroup_id: (2, 3, 5),
        grid_size: (3, 4, 6),
    };
    let kernel = parse_kernel(include_str!("success/workgroup_ids.s"), name).unwrap();
    let out = array_of("out", 0x10000, 3 * 64, ArrayKind::Output(U32));
    let result = analyze(&kernel, &launch, &out.base.to_le_bytes(), &[out]).unwrap();
    assert_eq!(result.terminal, Terminal::Completed, "{name}");
    result
}

// Test that one run over a 2 x 2 x 2 grid gives every workgroup the coordinates a run of that
// workgroup alone stores, and reports each element that later workgroups store again.
#[test]
fn a_grid_run_gives_each_workgroup_its_own_outputs() {
    let grid_size = (2, 2, 2);
    let launch = |workgroup_id| WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (64, 1, 1),
        workgroup_id,
        grid_size,
    };
    let kernel = parse_kernel(include_str!("success/workgroup_ids.s"), "workgroup_xyz").unwrap();
    let out = array_of("out", 0x10000, 3 * 64, ArrayKind::Output(U32));
    let arrays = std::slice::from_ref(&out);
    let kernarg = out.base.to_le_bytes();
    // A grid run ignores the selected coordinate, even when it lies outside the grid.
    let grid = analyze_grid(
        &kernel,
        &launch((u32::MAX, u32::MAX, u32::MAX)),
        &kernarg,
        arrays,
    )
    .unwrap();
    assert_eq!(grid.terminal, Terminal::Completed);
    assert_eq!(grid.workgroups.len(), 8);

    // Each workgroup's stored words must equal those of a run that selects it.
    for (id, outputs) in &grid.workgroups {
        let alone = analyze(&kernel, &launch(*id), &kernarg, arrays).unwrap();
        let expected = alone.symbolic_outputs.unwrap();
        assert_eq!(output_words(outputs), output_words(&expected), "{id:?}");
    }

    // All eight workgroups store the same 192 elements, so each later one conflicts with the first.
    assert_eq!(grid.conflicts.len(), 7 * 192);
    assert_eq!(
        grid.conflicts[0],
        StoreConflict {
            array: "out".into(),
            index: 0,
            workgroups: [(0, 0, 0), (1, 0, 0)],
        }
    );
}

/// Each written element of the first output array with its concrete word, if it has one.
fn output_words(outputs: &SymbolicOutputs) -> Vec<(u64, Option<i64>)> {
    outputs.outputs[0]
        .1
        .iter()
        .map(|&(index, value)| (index, outputs.arena.as_int_const(value)))
        .collect()
}

// Test that equal LDS addresses can depend on workgroup IDs, while each workgroup's words
// retain their bits through LDS, XOR and lane exchange, and convert numerically to floats.
#[test]
fn grid_lds_words_keep_their_integer_bits() {
    let kernel = parse_kernel(include_str!("success/workgroup_ids.s"), "grid_lds_words").unwrap();
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (64, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (2, 1, 1),
    };
    let arrays = [
        array_of("out", 0x10000, 2 * 192, ArrayKind::Output(U32)),
        array_of("converted", 0x20000, 2 * 64, ArrayKind::Output(F32)),
    ];
    let kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    let grid = analyze_grid(&kernel, &launch, &kernarg, &arrays).unwrap();
    assert_eq!(grid.terminal, Terminal::Completed);
    assert_eq!(grid.workgroups.len(), 2);
    assert!(grid.conflicts.is_empty());

    for (id, outputs) in &grid.workgroups {
        let group = u64::from(id.0);
        assert_eq!(outputs.outputs.len(), 2);
        let (name, words) = &outputs.outputs[0];
        assert_eq!(name, "out");
        assert_eq!(words.len(), 192);
        for (local, &(index, value)) in words.iter().enumerate() {
            assert_eq!(index, group * 192 + local as u64);
            let lane = local as u64 % 64;
            let read = group * 64 + (lane ^ 1) + 1;
            let expected = match local / 64 {
                0 => read,
                1 => read ^ 85,
                2 => group * 64 + (lane ^ 3) + 1,
                _ => unreachable!(),
            };
            assert_eq!(outputs.arena.as_int_const(value), Some(expected as i64));
        }

        let (name, converted) = &outputs.outputs[1];
        assert_eq!(name, "converted");
        assert_eq!(converted.len(), 64);
        for (lane, &(index, value)) in converted.iter().enumerate() {
            assert_eq!(index, group * 64 + lane as u64);
            let expected = group * 64 + (lane as u64 ^ 1) + 1;
            assert_eq!(outputs.arena.as_f64(value), Some(expected as f64));
        }
    }
}

// Test that differing VCC masks may take the same branch and still select different lanes.
#[test]
fn grid_branches_compare_taken_paths_not_individual_vcc_bits() {
    let kernel = parse_kernel(include_str!("success/workgroup_ids.s"), "grid_vcc_branch").unwrap();
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (64, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (2, 1, 1),
    };
    let out = array_of("out", 0x10000, 128, ArrayKind::Output(U32));
    let grid = analyze_grid(&kernel, &launch, &out.base.to_le_bytes(), &[out]).unwrap();
    assert_eq!(grid.terminal, Terminal::Completed);
    assert_eq!(grid.workgroups.len(), 2);
    assert!(grid.conflicts.is_empty());
    for (id, outputs) in &grid.workgroups {
        let expected: Vec<_> = (0..64)
            .map(|lane| {
                (
                    u64::from(id.0) * 64 + lane,
                    Some(if lane == u64::from(id.0) { 17 } else { 0 }),
                )
            })
            .collect();
        assert_eq!(output_words(outputs), expected, "{id:?}");
    }
}

#[test]
fn the_copy_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/copy",
        &[
            array("in", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output(F32)),
        ],
    );
}

#[test]
fn the_add_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/add",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array("out", 0x30000, ArrayKind::Output(F32)),
        ],
    );
}

#[test]
fn the_relu_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/relu",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output(F32)),
        ],
    );
}

#[test]
fn the_sigmoid_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/sigmoid",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output(F32)),
        ],
    );
}

// Test eight independent 16-element softmax rows across two waves.
#[test]
fn the_softmax_kernel_writes_its_expected_outputs() {
    common::amd::check_run_on(
        "success/softmax",
        128,
        &[
            array_of("input", 0x10000, 128, ArrayKind::Input),
            array_of("output", 0x20000, 128, ArrayKind::Output(F32)),
        ],
    );
}

/// The elements of each 8 x 8 matrix; work-item `i` computes element `i` of the product.
const MATMUL_ELEMENTS: u32 = 8 * 8;

#[test]
fn the_matmul_kernel_writes_its_expected_outputs() {
    let len = u64::from(MATMUL_ELEMENTS);
    common::amd::check_run_on(
        "success/matmul",
        MATMUL_ELEMENTS,
        &[
            array_of("a", 0x10000, len, ArrayKind::Input),
            array_of("b", 0x20000, len, ArrayKind::Input),
            array_of("c", 0x30000, len, ArrayKind::Output(F32)),
        ],
    );
}

// Test that each element of an 8 x 8 matrix is written to its transposed position.
#[test]
fn the_transpose_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/transpose",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output(F32)),
        ],
    );
}

/// Each work-item writes one result per operation to its own row of 32 floats.
const FLOAT_OPS_ROW: u64 = 32;

// Test packed add, multiply and FMA with selectors, negation and overlapping sources.
// The expected expressions are derived from the source operations for both components.
#[test]
fn the_packed_float_ops_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/packed_float_ops",
        &[
            array_of("a", 0x10000, 128, ArrayKind::Input),
            array_of("b", 0x20000, 128, ArrayKind::Input),
            array_of("c", 0x30000, 128, ArrayKind::Input),
            array_of("out", 0x40000, 64 * 32, ArrayKind::Output(F32)),
        ],
    );
}

// Test float arithmetic, source modifiers and selects against their expected expressions.
#[test]
fn the_float_ops_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/float_ops",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array_of("out", 0x30000, 64 * FLOAT_OPS_ROW, ArrayKind::Output(F32)),
        ],
    );
}

// Test that each f32 comparison keeps its symbolic predicate per lane in an SGPR mask,
// so a select on that mask reads as `(a op b) ? b : a`.
#[test]
fn the_compare_ops_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/compare_ops",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array_of("out", 0x30000, 64 * 12, ArrayKind::Output(F32)),
            array_of("out_e32", 0x40000, 64 * 12, ArrayKind::Output(F32)),
        ],
    );
}

// Test that accumulator writes preserve symbolic VGPR and SGPR sources and inline constants,
// and that reading the original accumulator back preserves each lane's input.
#[test]
fn the_accvgpr_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/accvgpr",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array_of("out", 0x20000, 4 * 64, ArrayKind::Output(F32)),
            array("back", 0x30000, ArrayKind::Output(F32)),
        ],
    );
}

/// The four waves of a 32 x 32 product with an inner dimension of 8, each one 16 x 16 tile.
const MFMA_MATMUL_WORKITEMS: u32 = 4 * 64;

#[test]
fn the_mfma_matmul_kernel_writes_its_expected_outputs() {
    common::amd::check_run_on(
        "success/mfma_matmul",
        MFMA_MATMUL_WORKITEMS,
        &[
            array_of("a", 0x10000, 32 * 8, ArrayKind::Input),
            array_of("b", 0x20000, 8 * 32, ArrayKind::Input),
            array_of("c", 0x30000, 32 * 32, ArrayKind::Output(F32)),
        ],
    );
}

/// Each work-item writes integer and float results to separate rows of 64 elements.
const BIT_OPS_ROW: u64 = 64;

// Test concrete bit operations, including NOT in both encodings, and symbolic float arithmetic
// against independently calculated outputs for all 64 lanes.
#[test]
fn the_bit_ops_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/bit_ops",
        &[
            array_of("a", 0x10000, 2 * 64, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array_of("out", 0x30000, 64 * BIT_OPS_ROW, ArrayKind::Output(U32)),
            array_of(
                "float_out",
                0x40000,
                64 * BIT_OPS_ROW,
                ArrayKind::Output(F32),
            ),
        ],
    );
}

// Test signed arithmetic, comparisons of 64-bit values with equal low words,
// and a two-iteration scalar loop.
#[test]
fn the_scalar_ops_kernel_writes_its_expected_outputs() {
    let out = 0x10000_u64;
    let mut kernarg = out.to_le_bytes().to_vec();
    for value in [-(1_i32 << 30), -8] {
        kernarg.extend(value.to_le_bytes());
    }
    // The OR is 3 << 32; x and y differ only in their high words.
    for value in [1_u64 << 32, 2_u64 << 32, 3_u64 << 32] {
        kernarg.extend(value.to_le_bytes());
    }
    kernarg.extend(2_i32.to_le_bytes());
    common::amd::check_run_kernel(
        "success/scalar_ops",
        "scalar_ops",
        64,
        &kernarg,
        &[array_of("out", out, 64 * 8, ArrayKind::Output(U32))],
    );
}

/// Launch the scalar fixture with concrete arithmetic operands, comparison
/// words and loop count.
fn run_scalar_ops(
    kernel: &Kernel,
    signed: [i32; 2],
    words: [u64; 3],
    count: i32,
) -> Result<AnalysisResult, AnalysisError> {
    let out = 0x10000_u64;
    let mut kernarg = out.to_le_bytes().to_vec();
    for value in signed {
        kernarg.extend(value.to_le_bytes());
    }
    for value in words {
        kernarg.extend(value.to_le_bytes());
    }
    kernarg.extend(count.to_le_bytes());
    analyze(
        kernel,
        &WorkgroupLaunch {
            kernarg_address: 0x1000,
            workgroup_size: (64, 1, 1),
            workgroup_id: (0, 0, 0),
            grid_size: (1, 1, 1),
        },
        &kernarg,
        &[array_of("out", out, 64 * 8, ArrayKind::Output(U32))],
    )
}

/// Check all six written words in every lane's row, with no extra output
/// elements.
fn assert_scalar_rows(result: AnalysisResult, expected: [u32; 6]) {
    assert_eq!(result.terminal, Terminal::Completed);
    let outputs = result.symbolic_outputs.unwrap();
    assert_eq!(outputs.outputs.len(), 1);
    assert_eq!(outputs.outputs[0].0, "out");
    assert_eq!(outputs.outputs[0].1.len(), 64 * 6);
    for lane in 0..64 {
        for (column, word) in expected.iter().enumerate() {
            let index = lane * 8 + column as u64;
            let actual = outputs
                .element("out", index)
                .and_then(|id| outputs.arena.as_int_const(id));
            assert_eq!(actual, Some(i64::from(*word)), "out[{index}]");
        }
    }
}

// Test arithmetic boundaries, 64-bit comparisons and loop counts. The zero comparison
// adds one to the loop result only when x is zero, exercising both branch outcomes.
#[test]
fn scalar_ops_handles_boundary_arguments() {
    let kernel = parse_kernel(include_str!("success/scalar_ops.s"), "scalar_ops").unwrap();
    // Require the compiled fixture to retain both instruction forms under test.
    assert!(kernel.instructions.iter().any(|instr| {
        instr.opcode == "s_cmp_eq_u64" && instr.operands.last() == Some(&Operand::Imm(0))
    }));
    assert!(
        kernel
            .instructions
            .iter()
            .any(|instr| instr.opcode == "s_cbranch_scc0")
    );
    for (signed, words, count, expected) in [
        // Zero OR differs from a word with a nonzero high half; x = 0 adds one to the loop result.
        (
            [i32::MIN, -1],
            [0, 0, 1 << 32],
            1,
            [0, u32::MAX, 1, 0, 1, 27],
        ),
        // Equal full-width words and three iterations of the recurrence.
        (
            [i32::MAX, i32::MAX],
            [0x8000_0001_0000_0001; 3],
            3,
            [0x3fff_ffff, 0xc000_0000, i32::MAX as u32, 1, 1, 480_266],
        ),
        // Equal signed maximum operands; comparison words differ only in
        // their low halves.
        (
            [-8, 8],
            [0x1_0000_0001, 0x1_0000_0002, 0x1_0000_0003],
            2,
            [u32::MAX, 0, 0xffff_fff8, 1, 0, 693],
        ),
    ] {
        assert_scalar_rows(
            run_scalar_ops(&kernel, signed, words, count).unwrap(),
            expected,
        );
    }
}

// Test integer multiplication, bit counts, 64-bit and packed moves, and signed comparisons.
// Check all 64 lanes against the expected outputs in vector_int_ops.out.
#[test]
fn the_vector_int_ops_kernel_writes_its_expected_outputs() {
    let out = 0x10000_u64;
    let mut kernarg = out.to_le_bytes().to_vec();
    // The multiplication factor, then the mask for the masked bit counts.
    for value in [0x1_0001_u32, 0xaaaa_aaaa] {
        kernarg.extend(value.to_le_bytes());
    }
    // Compare values above, below and equal to 0x7fffffff, including a negative value.
    for value in [1_u64 << 32, 0x8000_0000, 0x7fff_fffe, u64::MAX, 0x7fff_ffff] {
        kernarg.extend(value.to_le_bytes());
    }
    common::amd::check_run_kernel(
        "success/vector_int_ops",
        "vector_int_ops",
        64,
        &kernarg,
        &[array_of("out", out, 64 * 64, ArrayKind::Output(U32))],
    );
}

// Test every 64-bit integer comparison in its e32 and e64 encodings across lanes whose values
// are below, equal to and above zero, and 64-bit moves from a VGPR pair.
#[test]
fn the_compare64_ops_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/compare64_ops",
        &[array_of("out", 0x10000, 64 * 32, ArrayKind::Output(U32))],
    );
}

// Test the scalar ALU results and the SCC each one leaves, every scalar comparison in both
// operand orders, bit comparisons, branches on VCC and EXEC, and 64-bit literal sources.
#[test]
fn the_scalar_alu_ops_kernel_writes_its_expected_outputs() {
    let out = 0x10000_u64;
    let mut kernarg = out.to_le_bytes().to_vec();
    // Two operands whose signed and unsigned orders differ, then two shift counts and bit indices.
    for value in [0xf0f0_f00f_u32, 0x1234_5678, 36, 32] {
        kernarg.extend(value.to_le_bytes());
    }
    for value in [0xf0f0_f0f0_0000_ffff_u64, 0x0ff0_0ff0_1234_5678] {
        kernarg.extend(value.to_le_bytes());
    }
    common::amd::check_run_kernel(
        "success/scalar_alu_ops",
        "scalar_alu_ops",
        64,
        &kernarg,
        &[array_of("out", out, 64 * 128, ArrayKind::Output(U32))],
    );
}

// Test f64 arithmetic, modifiers, constants, conversions, comparisons, moves and overlapping
// registers. Check all 64 lanes against the expected outputs in f64_ops.out.
#[test]
fn the_f64_ops_kernel_writes_its_expected_outputs() {
    let arrays = [
        array("a", 0x10000, ArrayKind::Input),
        array("b", 0x20000, ArrayKind::Input),
        array("c", 0x30000, ArrayKind::Input),
        array_of("out", 0x40000, 64 * 64, ArrayKind::Output(F32)),
        array_of("int_out", 0x50000, 64 * 8, ArrayKind::Output(U32)),
    ];
    let mut kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    kernarg.extend(1.5_f64.to_bits().to_le_bytes());
    common::amd::check_run_kernel("success/f64_ops", "f64_ops", 64, &kernarg, &arrays);
}

/// `CK_GEMM_KERNEL` with the C element op `$op`, mangled, in place of the third `PassThrough`,
/// which shifts every later substitution index by one.
macro_rules! ck_gemm_kernel_with_c_op {
    ($op:literal) => {
        concat!(
            "_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4",
            "gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThrough",
            "ES8_",
            $op,
            "LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8",
            "SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2",
            "ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_",
            "24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_",
            "10TailNumberE10EEEvNT_8ArgumentE",
        )
    };
}

/// Run a `ck_gemm.hip`-style instance on an 8 x 8 x 8 problem.
fn check_ck_gemm(fixture: &str, kernel: &str) {
    let (a, b, c) = (0x10000, 0x20000, 0x30000);
    common::amd::check_run_kernel(
        fixture,
        kernel,
        128,
        &ck_gemm_kernarg(a, b, c, [8, 8, 8]),
        &[
            array_of("a", a, 8 * 8, ArrayKind::Input),
            array_of("b", b, 8 * 8, ArrayKind::Input),
            array_of("c", c, 8 * 8, ArrayKind::Output(F32)),
        ],
    );
}

#[test]
fn the_ck_gemm_kernel_writes_its_expected_outputs() {
    check_ck_gemm("success/ck_gemm", CK_GEMM_KERNEL);
}

// Test the fused sigmoid epilogue: its exp's underflow guard compares symbolic accumulators into
// SGPR lane masks and selects a negated source on them.
#[test]
fn the_ck_gemm_sigmoid_kernel_writes_its_expected_outputs() {
    check_ck_gemm(
        "success/ck_gemm_sigmoid",
        ck_gemm_kernel_with_c_op!("NS7_7SigmoidE"),
    );
}

// Test that each output sums 25 adjacent input values weighted by the shared filter.
#[test]
fn the_convolution_1d_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/convolution_1d",
        &[
            array_of("input", 0x10000, 64 + 25 - 1, ArrayKind::Input),
            array_of("filter", 0x20000, 25, ArrayKind::Input),
            array("output", 0x30000, ArrayKind::Output(F32)),
        ],
    );
}

// Test that each output of the 8 x 8 image sums its 3 x 3 window of the 10 x 10 input,
// weighted by the shared filter.
#[test]
fn the_convolution_2d_kernel_writes_its_expected_outputs() {
    common::amd::check_run(
        "success/convolution_2d",
        &[
            array_of("input", 0x10000, 10 * 10, ArrayKind::Input),
            array_of("filter", 0x20000, 3 * 3, ArrayKind::Input),
            array("output", 0x30000, ArrayKind::Output(F32)),
        ],
    );
}

// Test that the same stored bits become real constants in float outputs and words in integer outputs.
#[test]
fn constant_outputs_follow_their_declared_types() {
    common::amd::check_run(
        "success/output_constants",
        &[
            array("floats", 0x10000, ArrayKind::Output(F32)),
            array("words", 0x20000, ArrayKind::Output(U32)),
        ],
    );
}

// Test that lgkmcnt(1) completes every DS instruction in flight but the last, writes included,
// and that a partial wait with a scalar load in flight is rejected (issue #19).
#[test]
fn a_partial_lgkm_wait_completes_all_but_the_last_instructions() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output(F32)),
    ];
    let kernarg: Vec<u8> = arrays.iter().flat_map(|a| a.base.to_le_bytes()).collect();
    common::amd::check_run_kernel("success/lgkm_wait", "partial_wait", 64, &kernarg, &arrays);

    let expected = Terminal::Aborted {
        wave: WaveId(0),
        pc: InstrId(8),
        error: EvalError::UnsupportedInstruction,
    };
    let kernel = "partial_wait_with_scalar_load";
    common::amd::check_rejected_kernel("success/lgkm_wait", kernel, &arrays, |result| {
        result.as_ref().is_ok_and(|run| run.terminal == expected)
    });
}
