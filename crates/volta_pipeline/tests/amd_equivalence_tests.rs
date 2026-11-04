//! Functional equivalence of compiled AMD kernels against mathematical specifications.

use std::collections::HashMap;

use volta_amd_analysis::OutputType::F32;
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, ArrayKind, Terminal, WorkgroupLaunch, analyze};
use volta_equivalence::check::EquivCheckOptions;
use volta_pipeline::{EquivalenceVerdict, check_equivalence};

const A_BASE: u64 = 0x10000;
const B_BASE: u64 = 0x20000;
const C_BASE: u64 = 0x30000;
const MATMUL_SPEC: &str = include_str!("../../volta_equivalence/tests/specs/matmul.spec");

fn check_gemm(
    source: &str,
    kernel_name: &str,
    workitems: u32,
    dims: [u64; 3],
    kernarg: &[u8],
    spec: &str,
) -> EquivalenceVerdict {
    // Allocate A, B, and C for an M x K by K x N matrix product.
    let [m, n, k] = dims;
    let arrays = [
        ("A", A_BASE, m * k, ArrayKind::Input),
        ("B", B_BASE, k * n, ArrayKind::Input),
        ("C", C_BASE, m * n, ArrayKind::Output(F32)),
    ]
    .map(|(name, base, len, kind)| ArrayDef {
        name: name.into(),
        base,
        len,
        kind,
    });
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (workitems, 1, 1),
    };

    // Execute the compiled fixture with its argument layout and workgroup size.
    let kernel = parse_kernel(source, kernel_name).unwrap();
    let result = analyze(&kernel, &launch, kernarg, &arrays).unwrap();
    assert!(
        matches!(&result.terminal, Terminal::Completed),
        "{kernel_name} did not complete: {:?}",
        result.terminal
    );
    let actual = result.symbolic_outputs.expect("completed GEMM outputs");

    // Derive the reference from the specification, independently of the kernel execution.
    let dims = HashMap::from([("M".into(), m), ("N".into(), n), ("K".into(), k)]);
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();

    check_equivalence(
        &reference,
        &actual,
        &["C".into()],
        &EquivCheckOptions::default(),
    )
    .0
}

fn check_matmul(input_bases: [u64; 2]) -> EquivalenceVerdict {
    let kernarg = [input_bases[0], input_bases[1], C_BASE]
        .map(u64::to_le_bytes)
        .concat();
    check_gemm(
        include_str!("../../volta_amd_analysis/tests/fixtures/matmul.s"),
        "matmul",
        64,
        [8, 8, 8],
        &kernarg,
        MATMUL_SPEC,
    )
}

// Test that every output of the compiled matmul agrees with C = A @ B.
#[test]
fn amd_matmul_matches_its_specification() {
    assert_eq!(
        check_matmul([A_BASE, B_BASE]),
        EquivalenceVerdict::Equivalent {
            checked: 64,
            total: 64,
        }
    );
}

// Test that swapping the input pointers is refuted, even though the output indices match.
#[test]
fn amd_matmul_with_swapped_input_arguments_is_refuted() {
    // Keep the array names fixed: this invocation computes B @ A instead of A @ B.
    let verdict = check_matmul([B_BASE, A_BASE]);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

// Test that the four waves' MFMA tiles form the full 32 x 32 matrix product.
#[test]
fn amd_mfma_matmul_matches_its_specification() {
    let kernarg = [A_BASE, B_BASE, C_BASE].map(u64::to_le_bytes).concat();
    let verdict = check_gemm(
        include_str!("../../volta_amd_analysis/tests/fixtures/mfma_matmul.s"),
        "mfma_matmul",
        256,
        [32, 32, 8],
        &kernarg,
        MATMUL_SPEC,
    );
    assert_eq!(
        verdict,
        EquivalenceVerdict::Equivalent {
            checked: 1024,
            total: 1024,
        }
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

// Test that CK's padded GEMM produces the requested 8 x 8 matrix product.
#[test]
fn amd_ck_gemm_matches_its_specification() {
    let kernarg = ck_gemm_kernarg(A_BASE, B_BASE, C_BASE);
    // CK stores B column-major: element (k, j) is B[j * 8 + k]. The transposed
    // specification uses that physical indexing for this square B matrix.
    let spec = include_str!("../../volta_equivalence/tests/specs/matmul_transposed.spec");
    let verdict = check_gemm(
        include_str!("../../volta_amd_analysis/tests/fixtures/ck_gemm.s"),
        CK_GEMM_KERNEL,
        128,
        [8, 8, 8],
        &kernarg,
        spec,
    );
    assert_eq!(
        verdict,
        EquivalenceVerdict::Equivalent {
            checked: 64,
            total: 64,
        }
    );
}
