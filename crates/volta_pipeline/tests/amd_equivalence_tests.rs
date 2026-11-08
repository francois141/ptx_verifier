//! Functional equivalence of compiled AMD kernels against mathematical specifications.

use std::collections::HashMap;

use volta_amd_analysis::OutputType::F32;
use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, ArrayKind, Terminal, WorkgroupLaunch, analyze};
use volta_equivalence::check::EquivCheckOptions;
use volta_pipeline::{EquivalenceVerdict, check_equivalence};

mod common;

use common::amd::{
    CK_FMHA_KERNEL, CK_GEMM_KERNEL, CK_GEMM_MAIN_LOOP_KERNEL, FMHA_K_BASE as K_BASE,
    FMHA_Q_BASE as Q_BASE, GEMM_A_BASE as A_BASE, GEMM_B_BASE as B_BASE, GEMM_C_BASE as C_BASE,
    amd_fixture, ck_fmha_kernarg, ck_gemm_kernarg, fmha_arrays, gemm_arrays,
};
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
    let arrays = gemm_arrays(dims);
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (workitems, 1, 1),
        workgroup_id: (0, 0, 0),
        grid_size: (1, 1, 1),
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

/// Check CK's column-major B using the specification's physical layout B[j * K + k].
fn check_ck_gemm(kernel: &str, dims: [i32; 3], input_bases: [u64; 2]) -> EquivalenceVerdict {
    let kernarg = ck_gemm_kernarg(input_bases[0], input_bases[1], C_BASE, dims);
    check_gemm(
        amd_fixture!("ck_gemm"),
        kernel,
        128,
        dims.map(|d| d as u64),
        &kernarg,
        include_str!("../../volta_equivalence/tests/specs/matmul_transposed.spec"),
    )
}

// Test that CK's padded GEMM produces the requested 8 x 8 matrix product.
#[test]
fn amd_ck_gemm_matches_its_specification() {
    assert_eq!(
        check_ck_gemm(CK_GEMM_KERNEL, [8, 8, 8], [A_BASE, B_BASE]),
        EquivalenceVerdict::Equivalent {
            checked: 64,
            total: 64,
        }
    );
}

// Test all three K tiles and padding, with live inputs exchanged between both waves.
#[test]
fn amd_ck_gemm_main_loop_matches_its_specification() {
    assert_eq!(
        check_ck_gemm(CK_GEMM_MAIN_LOOP_KERNEL, [40, 40, 192], [A_BASE, B_BASE]),
        EquivalenceVerdict::Equivalent {
            checked: 1600,
            total: 1600,
        }
    );
}

// Test that swapping CK's equal-sized input arrays is refuted against the intended product.
#[test]
fn amd_ck_gemm_main_loop_with_swapped_input_arguments_is_refuted() {
    let verdict = check_ck_gemm(CK_GEMM_MAIN_LOOP_KERNEL, [40, 40, 192], [B_BASE, A_BASE]);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

/// Check one batch/head's full output footprint and its values against the attention formula.
fn check_ck_fmha(
    kernarg: &[u8],
    grid_size: (u32, u32, u32),
    workgroup_id: (u32, u32, u32),
    sample: u64,
) -> EquivalenceVerdict {
    // This gfx950 instance maps X to head, Y to query tile, and Z to batch.
    let (heads, tiles, batches) = grid_size;
    let (head, tile, batch) = workgroup_id;
    assert_eq!((tiles, tile), (1, 0));
    let arrays = fmha_arrays(u64::from(batches) * u64::from(heads) * 4096);
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (256, 1, 1),
        workgroup_id,
        grid_size,
    };

    // Each invocation executes one workgroup; its input symbols retain global tensor indices.
    let source = include_str!("../../volta_amd_analysis/tests/fixtures/ck_fmha.s");
    let kernel = parse_kernel(source, CK_FMHA_KERNEL).unwrap();
    let result = analyze(&kernel, &launch, kernarg, &arrays).unwrap();
    assert!(
        matches!(&result.terminal, Terminal::Completed),
        "ck_fmha {workgroup_id:?} did not complete: {:?}",
        result.terminal
    );
    let mut actual = result
        .symbolic_outputs
        .expect("completed attention outputs");

    // Require exactly this block's output slice before renumbering it for the local spec.
    let output_start = (u64::from(batch) * u64::from(heads) + u64::from(head)) * 4096;
    assert_eq!(actual.outputs.len(), 1);
    let (name, elements) = &mut actual.outputs[0];
    assert_eq!(name.as_str(), "O");
    assert_eq!(elements.len(), 4096);
    for (local, (index, _)) in elements.iter_mut().enumerate() {
        assert_eq!(
            *index,
            output_start + local as u64,
            "workgroup {workgroup_id:?}"
        );
        *index -= output_start;
    }

    // The reference selects the batch/head independently of CK's strides and register values.
    let dims = HashMap::from([
        ("B".into(), u64::from(batches)),
        ("G".into(), u64::from(heads)),
        ("N".into(), 64),
        ("H".into(), 64),
        ("Batch".into(), u64::from(batch)),
        ("Head".into(), u64::from(head)),
    ]);
    let spec = include_str!("../../volta_equivalence/tests/specs/attention_batch_head.spec");
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

// Test all 16,384 attention outputs across two batches and two heads, one workgroup at a time.
#[test]
fn amd_ck_fmha_batches_and_heads_match_their_specification() {
    let kernarg = ck_fmha_kernarg(Q_BASE, K_BASE, 2);
    for batch in 0..2 {
        for head in 0..2 {
            assert_eq!(
                check_ck_fmha(&kernarg, (2, 1, 2), (head, 0, batch), 0),
                EquivalenceVerdict::Equivalent {
                    checked: 4096,
                    total: 4096,
                },
                "batch {batch}, head {head}"
            );
        }
    }
}

// Test that swapping the query and key tensors is refuted in the first output row, since
// attention is not symmetric.
#[test]
fn amd_ck_fmha_with_swapped_query_and_key_is_refuted() {
    let kernarg = ck_fmha_kernarg(K_BASE, Q_BASE, 1);
    let verdict = check_ck_fmha(&kernarg, (1, 1, 1), (0, 0, 0), 64);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

// Test that reading the previous head's Q is refuted even though the output slice is correct.
#[test]
fn amd_ck_fmha_with_wrong_head_stride_is_refuted() {
    let mut kernarg = ck_fmha_kernarg(Q_BASE, K_BASE, 2);
    // nhead_stride_q is at byte 84 in FmhaFwdCommonKargs; zero makes both heads read head 0.
    kernarg[84..88].copy_from_slice(&0_i32.to_le_bytes());
    let verdict = check_ck_fmha(&kernarg, (2, 1, 2), (1, 0, 1), 64);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a wrong-head read to be refuted, got {verdict:?}"
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
        workgroup_id: (0, 0, 0),
        grid_size: (1, 1, 1),
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
