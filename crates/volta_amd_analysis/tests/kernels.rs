//! Each fixture kernel's symbolic outputs, compared with `fixtures/<name>.out`.

mod common;

use common::{array, array_of};
use volta_amd_analysis::{
    AnalysisError, AnalysisResult, ArrayKind, EvalError, LowerError, Terminal,
};

#[test]
fn the_copy_kernel_writes_its_expected_outputs() {
    common::check_run(
        "copy",
        &[
            array("in", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output),
        ],
    );
}

#[test]
fn the_add_kernel_writes_its_expected_outputs() {
    common::check_run(
        "add",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array("out", 0x30000, ArrayKind::Output),
        ],
    );
}

#[test]
fn the_relu_kernel_writes_its_expected_outputs() {
    common::check_run(
        "relu",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output),
        ],
    );
}

#[test]
fn the_sigmoid_kernel_writes_its_expected_outputs() {
    common::check_run(
        "sigmoid",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output),
        ],
    );
}

// Test eight independent 16-element softmax rows across two waves.
#[test]
fn the_softmax_kernel_writes_its_expected_outputs() {
    common::check_run_on(
        "softmax",
        128,
        &[
            array_of("input", 0x10000, 128, ArrayKind::Input),
            array_of("output", 0x20000, 128, ArrayKind::Output),
        ],
    );
}

/// The elements of each 8 x 8 matrix; work-item `i` computes element `i` of the product.
const MATMUL_ELEMENTS: u32 = 8 * 8;

#[test]
fn the_matmul_kernel_writes_its_expected_outputs() {
    let len = u64::from(MATMUL_ELEMENTS);
    common::check_run_on(
        "matmul",
        MATMUL_ELEMENTS,
        &[
            array_of("a", 0x10000, len, ArrayKind::Input),
            array_of("b", 0x20000, len, ArrayKind::Input),
            array_of("c", 0x30000, len, ArrayKind::Output),
        ],
    );
}

// Test that each element of an 8 x 8 matrix is written to its transposed position.
#[test]
fn the_transpose_kernel_writes_its_expected_outputs() {
    common::check_run(
        "transpose",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output),
        ],
    );
}

/// Each work-item writes one result per operation to its own row of 32 floats.
const FLOAT_OPS_ROW: u64 = 32;

#[test]
fn the_float_ops_kernel_writes_its_expected_outputs() {
    common::check_run(
        "float_ops",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array_of("out", 0x30000, 64 * FLOAT_OPS_ROW, ArrayKind::Output),
        ],
    );
}

#[test]
fn the_accvgpr_kernel_writes_its_expected_outputs() {
    common::check_run(
        "accvgpr",
        &[
            array("a", 0x10000, ArrayKind::Input),
            array("out", 0x20000, ArrayKind::Output),
            array("back", 0x30000, ArrayKind::Output),
        ],
    );
}

/// The four waves of a 32 x 32 product with an inner dimension of 8, each one 16 x 16 tile.
const MFMA_MATMUL_WORKITEMS: u32 = 4 * 64;

#[test]
fn the_mfma_matmul_kernel_writes_its_expected_outputs() {
    common::check_run_on(
        "mfma_matmul",
        MFMA_MATMUL_WORKITEMS,
        &[
            array_of("a", 0x10000, 32 * 8, ArrayKind::Input),
            array_of("b", 0x20000, 8 * 32, ArrayKind::Input),
            array_of("c", 0x30000, 32 * 32, ArrayKind::Output),
        ],
    );
}

/// Each work-item writes one result per word or f32 operation to its own row of 64 words.
const BIT_OPS_ROW: u64 = 64;

#[test]
fn the_bit_ops_kernel_writes_its_expected_outputs() {
    common::check_run(
        "bit_ops",
        &[
            array_of("a", 0x10000, 2 * 64, ArrayKind::Input),
            array("b", 0x20000, ArrayKind::Input),
            array_of("out", 0x30000, 64 * BIT_OPS_ROW, ArrayKind::Output),
        ],
    );
}

/// The `ck::kernel_gemm_xdl_cshuffle_v3` instance `ck_gemm.hip` compiles: two waves, each
/// accumulating a 32 x 64 slice of a 64 x 64 tile with `v_mfma_f32_16x16x4_f32`.
const CK_GEMM_KERNEL: &str = concat!(
    "_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4",
    "gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThrough",
    "ES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4",
    "ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2",
    "ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_",
    "24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_",
    "10TailNumberE10EEEvNT_8ArgumentE",
);

/// The kernel's `GridwiseGemm::Argument` for an 8 x 8 x 8 problem, as CK's host constructor
/// lays it out: a vtable pointer and a workspace pointer, the `Problem`'s fifteen `index_t`s
/// padded to the 64 x 64 x 64 block tile, the three empty element ops, then the pointers.
fn ck_gemm_kernarg(a: u64, b: u64, c: u64) -> Vec<u8> {
    let (m, n, k) = (8, 8, 8);
    let problem: [i32; 15] = [
        m, n, k, // M, N, K
        k, k, n, // StrideA (row-major A), StrideB (column-major B), StrideC (row-major C)
        1, // KBatch
        64, 64, // MPadded, NPadded
        8,  // KRead
        64, // KPadded
        16, 16, // AK0, BK0: KPadded / K1
        1, 1, // MBlock, NBlock
    ];
    let mut bytes = vec![0u8; 16];
    bytes.extend(problem.iter().flat_map(|field| field.to_le_bytes()));
    bytes.resize(80, 0);
    for pointer in [a, b, c] {
        bytes.extend(pointer.to_le_bytes());
    }
    bytes.resize(112, 0); // is_reduce = false, then padding.
    bytes
}

#[test]
fn the_ck_gemm_kernel_writes_its_expected_outputs() {
    let (a, b, c) = (0x10000, 0x20000, 0x30000);
    common::check_run_kernel(
        "ck_gemm",
        CK_GEMM_KERNEL,
        128,
        &ck_gemm_kernarg(a, b, c),
        &[
            array_of("a", a, 8 * 8, ArrayKind::Input),
            array_of("b", b, 8 * 8, ArrayKind::Input),
            array_of("c", c, 8 * 8, ArrayKind::Output),
        ],
    );
}

// Test that each output sums 25 adjacent input values weighted by the shared filter.
#[test]
fn the_convolution_1d_kernel_writes_its_expected_outputs() {
    common::check_run(
        "convolution_1d",
        &[
            array_of("input", 0x10000, 64 + 25 - 1, ArrayKind::Input),
            array_of("filter", 0x20000, 25, ArrayKind::Input),
            array("output", 0x30000, ArrayKind::Output),
        ],
    );
}

// Test that each output of the 8 x 8 image sums its 3 x 3 window of the 10 x 10 input,
// weighted by the shared filter.
#[test]
fn the_convolution_2d_kernel_writes_its_expected_outputs() {
    common::check_run(
        "convolution_2d",
        &[
            array_of("input", 0x10000, 10 * 10, ArrayKind::Input),
            array_of("filter", 0x20000, 3 * 3, ArrayKind::Input),
            array("output", 0x30000, ArrayKind::Output),
        ],
    );
}

// Test that a shift, a sign-bit trick and an integer addition each reject a symbolic input,
// because symbolic values are floats without known bits.
#[test]
fn integer_operations_on_symbolic_values_are_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output),
    ];
    for kernel in ["symbolic_shift", "symbolic_negation", "symbolic_add"] {
        common::check_rejected_kernel("unsupported", kernel, &arrays, |result| {
            matches!(
                result,
                Ok(AnalysisResult {
                    terminal: Terminal::Aborted {
                        error: EvalError::SymbolicWord { lane: 0 },
                        ..
                    },
                    symbolic_outputs: None,
                    ..
                })
            )
        });
    }
}

// Test that a float comparison choosing between two constants is rejected, because the
// chosen words could encode floats or integers.
#[test]
fn selecting_between_constants_under_a_symbolic_condition_is_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output),
    ];
    common::check_rejected_kernel("unsupported", "symbolic_select", &arrays, |result| {
        matches!(
            result,
            Ok(AnalysisResult {
                terminal: Terminal::Aborted {
                    error: EvalError::AmbiguousSelect { lane: 0 },
                    ..
                },
                symbolic_outputs: None,
                ..
            })
        )
    });
}

// Test that a store executed by only the odd lanes is rejected for changing EXEC.
#[test]
fn intra_wave_divergence_is_rejected() {
    let arrays = [
        array("input", 0x10000, ArrayKind::Input),
        array("output", 0x20000, ArrayKind::Output),
    ];
    common::check_rejected_kernel("unsupported", "divergent_store", &arrays, |result| {
        matches!(
            result,
            Err(AnalysisError::Lower(LowerError::Instruction { opcode, reason, .. }))
                if opcode == "s_and_saveexec_b64"
                    && *reason == "EXEC changes are unsupported: intra-wave divergence is not modeled"
        )
    });
}
