//! Functional equivalence of compiled AMD kernels against mathematical specifications.

use std::collections::HashMap;

use volta_amd_analysis::OutputType::F32;
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, ArrayKind, Terminal, WorkgroupLaunch, analyze};
use volta_equivalence::check::EquivCheckOptions;
use volta_pipeline::{EquivalenceVerdict, check_equivalence};

mod common;

use common::amd::{CK_GEMM_KERNEL, ck_gemm_kernarg};

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

/// The `kentry` of the CK attention instance `ck_fmha.hip` compiles: four waves over a 64 x 64
/// query/key tile.
const CK_FMHA_KERNEL: &str = concat!(
    "_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_2",
    "4BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi6",
    "4ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17Compose",
    "dAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsIL",
    "b0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantS",
    "caleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEEL",
    "b0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21Fm",
    "haFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT",
    "2_",
);
const Q_BASE: u64 = 0x10000;
const K_BASE: u64 = 0x20000;
const V_BASE: u64 = 0x30000;
const O_BASE: u64 = 0x40000;

/// The kernel's `FmhaFwdBatchModeKargs` for one batch and one head of 64 x 64 row-major tensors.
fn ck_fmha_kernarg(q: u64, k: u64) -> Vec<u8> {
    let mut bytes = Vec::new();
    // The tensors, then a null sink pointer, which disables the optional sink.
    for pointer in [q, k, V_BASE, O_BASE, 0] {
        bytes.extend(pointer.to_le_bytes());
    }
    // seqlen_q, seqlen_k, hdim_q, hdim_v, num_head_q and nhead_ratio_qk.
    for field in [64_i32, 64, 64, 64, 1, 1] {
        bytes.extend(field.to_le_bytes());
    }
    // The fast-exp2 build takes the host's scale times log2(e), here for the formula's 1 / 8.
    bytes.extend((std::f32::consts::LOG2_E / 8.0).to_le_bytes());
    // Row, head and batch strides of Q, K, V and O around the optional head count and offset.
    for field in [
        64_i32, 64, 64, 64, 64, 64, 64, 64, 0, 0, 4096, 4096, 4096, 4096,
    ] {
        bytes.extend(field.to_le_bytes());
    }
    // Padding, then null cumulative sequence length pointers.
    bytes.resize(144, 0);
    bytes
}

fn check_ck_fmha(q: u64, k: u64, sample: u64) -> EquivalenceVerdict {
    let arrays = [
        ("Q", Q_BASE, ArrayKind::Input),
        ("K", K_BASE, ArrayKind::Input),
        ("V", V_BASE, ArrayKind::Input),
        ("O", O_BASE, ArrayKind::Output(F32)),
    ]
    .map(|(name, base, kind)| ArrayDef {
        name: name.into(),
        base,
        len: 64 * 64,
        kind,
    });
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (256, 1, 1),
    };

    // Execute the compiled kernel on its one workgroup of four waves.
    let source = include_str!("../../volta_amd_analysis/tests/fixtures/ck_fmha.s");
    let kernel = parse_kernel(source, CK_FMHA_KERNEL).unwrap();
    let result = analyze(&kernel, &launch, &ck_fmha_kernarg(q, k), &arrays).unwrap();
    assert!(
        matches!(&result.terminal, Terminal::Completed),
        "ck_fmha did not complete: {:?}",
        result.terminal
    );
    let actual = result
        .symbolic_outputs
        .expect("completed attention outputs");

    // The reference states the formula independently of the kernel execution.
    let dims = HashMap::from([("N".into(), 64), ("H".into(), 64)]);
    let spec = include_str!("../../volta_equivalence/tests/specs/attention.spec");
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();
    check_equivalence(
        &reference,
        &actual,
        &["O".into()],
        &EquivCheckOptions {
            sample,
            ..EquivCheckOptions::default()
        },
    )
    .0
}

// Test that every output of CK attention agrees with softmax(Q K^T / 8) V.
#[test]
fn amd_ck_fmha_matches_its_specification() {
    assert_eq!(
        check_ck_fmha(Q_BASE, K_BASE, 0),
        EquivalenceVerdict::Equivalent {
            checked: 4096,
            total: 4096,
        }
    );
}

// Test that swapping the query and key tensors is refuted in the first output row, since
// attention is not symmetric.
#[test]
fn amd_ck_fmha_with_swapped_query_and_key_is_refuted() {
    let verdict = check_ck_fmha(K_BASE, Q_BASE, 64);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

fn check_softmax(workitems: u32, dims: [u64; 2]) -> EquivalenceVerdict {
    // Run the compiled kernel, which normalizes groups of sixteen, at this workgroup size.
    let arrays = [
        ("input", A_BASE, ArrayKind::Input),
        ("output", B_BASE, ArrayKind::Output(F32)),
    ]
    .map(|(name, base, kind)| ArrayDef {
        name: name.into(),
        base,
        len: u64::from(workitems),
        kind,
    });
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (workitems, 1, 1),
    };
    let kernarg = [A_BASE, B_BASE].map(u64::to_le_bytes).concat();
    let source = include_str!("../../volta_amd_analysis/tests/fixtures/softmax.s");
    let kernel = parse_kernel(source, "softmax").unwrap();
    let result = analyze(&kernel, &launch, &kernarg, &arrays).unwrap();
    assert!(
        matches!(&result.terminal, Terminal::Completed),
        "softmax did not complete: {:?}",
        result.terminal
    );
    let actual = result.symbolic_outputs.expect("completed softmax outputs");

    // The reference defines each row's maximum and sum independently of the lane exchanges.
    let [rows, columns] = dims;
    let dims = HashMap::from([("R".into(), rows), ("C".into(), columns)]);
    let spec = include_str!("../../volta_equivalence/tests/specs/row_softmax.spec");
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();
    check_equivalence(
        &reference,
        &actual,
        &["output".into()],
        &EquivCheckOptions::default(),
    )
    .0
}

// Test that every softmax row agrees with the formula across one, two, and four waves.
#[test]
fn amd_softmax_matches_its_specification() {
    for rows in [4, 8, 16] {
        let workitems = rows * 16;
        let outputs = u64::from(workitems);
        assert_eq!(
            check_softmax(workitems, [u64::from(rows), 16]),
            EquivalenceVerdict::Equivalent {
                checked: outputs,
                total: outputs,
            },
            "{rows} softmax rows"
        );
    }
}

// Test that normalizing groups of eight instead of sixteen is refuted for the same 128 outputs.
#[test]
fn amd_softmax_with_wrong_row_width_is_refuted() {
    let verdict = check_softmax(128, [16, 8]);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}
