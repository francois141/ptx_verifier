//! Functional equivalence of compiled AMD kernels against mathematical specifications.

use std::collections::HashMap;

use volta_amd_analysis::OutputType::F32;
use volta_amd_analysis::{ArrayDef, ArrayKind, WorkgroupLaunch};
use volta_equivalence::check::EquivCheckOptions;
use volta_pipeline::{
    EquivalenceVerdict, KernelEvidence, Spec, Verdict, check_against_spec, check_equivalence,
    decide,
};

use crate::common;

use common::amd::{
    AmdChecked, AvgPool2d, CK_AVGPOOL2D_KERNEL, CK_FMHA_KERNEL, CK_GEMM_KERNEL,
    CK_GEMM_MAIN_LOOP_KERNEL, CK_RMSNORM_KERNEL, FMHA_K_BASE as K_BASE, FMHA_Q_BASE as Q_BASE,
    GEMM_A_BASE as A_BASE, GEMM_B_BASE as B_BASE, GEMM_C_BASE as C_BASE, amd_fixture,
    avgpool_arrays, check_amd, check_amd_launch, ck_avgpool2d_kernarg, ck_fmha_kernarg,
    ck_gemm_kernarg, ck_rmsnorm_kernarg, fmha_arrays, gemm_arrays, rmsnorm_arrays,
};
const MATMUL_SPEC: &str = include_str!("../../../volta_equivalence/tests/specs/matmul.spec");

/// Kernel `kernel_name` of `source` (the fixture `file`) against `spec`'s `C = A @ B` at dims
/// `[M, N, K]`, once its run verified.
fn check_gemm(
    file: &str,
    source: &str,
    kernel_name: &str,
    workitems: u32,
    dims: [u64; 3],
    kernarg: &[u8],
    spec: &str,
) -> EquivalenceVerdict {
    let [m, n, k] = dims;
    let arrays = gemm_arrays(dims);
    let actual =
        check_amd(file, source, kernel_name, workitems, kernarg, &arrays).verified_outputs();

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
        "success/matmul.s",
        amd_fixture!("success/matmul"),
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
        "success/mfma_matmul.s",
        amd_fixture!("success/mfma_matmul"),
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
        "success/ck_gemm.s",
        amd_fixture!("success/ck_gemm"),
        kernel,
        128,
        dims.map(|d| d as u64),
        &kernarg,
        include_str!("../../../volta_equivalence/tests/specs/matmul_transposed.spec"),
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
    let mut actual = check_amd_launch(
        "success/ck_fmha.s",
        amd_fixture!("success/ck_fmha"),
        CK_FMHA_KERNEL,
        &launch,
        kernarg,
        &arrays,
    )
    .verified_outputs();

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
    let spec = include_str!("../../../volta_equivalence/tests/specs/attention_batch_head.spec");
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
    let kernarg = [A_BASE, B_BASE].map(u64::to_le_bytes).concat();
    let actual = check_amd(
        "success/softmax.s",
        amd_fixture!("success/softmax"),
        "softmax",
        workitems,
        &kernarg,
        &arrays,
    )
    .verified_outputs();

    // The reference defines each row's maximum and sum independently of the lane exchanges.
    let [rows, columns] = dims;
    let dims = HashMap::from([("R".into(), rows), ("C".into(), columns)]);
    let spec = include_str!("../../../volta_equivalence/tests/specs/row_softmax.spec");
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

/// The specification's epsilon, 2^-20, which an f32 holds exactly.
const RMSNORM_EPSILON: f32 = 1.0 / 1_048_576.0;

/// Check one row's full output footprint and its values against the RMSNorm formula. The kernel
/// normalizes row `row` of `rows` rows of `columns` elements with `epsilon`.
fn check_ck_rmsnorm(rows: u32, row: u32, columns: u32, epsilon: f32) -> EquivalenceVerdict {
    let arrays = rmsnorm_arrays(u64::from(rows), u64::from(columns));
    let kernarg = ck_rmsnorm_kernarg(rows as i32, columns as i32, epsilon);
    // CK launches one workgroup of four waves per row, along X.
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (256, 1, 1),
        workgroup_id: (row, 0, 0),
        grid_size: (rows, 1, 1),
    };
    let mut actual = check_amd_launch(
        "success/ck_rmsnorm2d.s",
        amd_fixture!("success/ck_rmsnorm2d"),
        CK_RMSNORM_KERNEL,
        &launch,
        &kernarg,
        &arrays,
    )
    .verified_outputs();

    // Require exactly this row's output slice before renumbering it for the local spec.
    let output_start = u64::from(row) * u64::from(columns);
    assert_eq!(actual.outputs.len(), 1);
    let (name, elements) = &mut actual.outputs[0];
    assert_eq!(name.as_str(), "y");
    assert_eq!(elements.len(), columns as usize);
    for (local, (index, _)) in elements.iter_mut().enumerate() {
        assert_eq!(*index, output_start + local as u64, "row {row}");
        *index -= output_start;
    }

    // The reference selects the row independently of CK's strides and its reduction order.
    let dims = HashMap::from([
        ("M".into(), u64::from(rows)),
        ("N".into(), u64::from(columns)),
        ("Row".into(), u64::from(row)),
    ]);
    let spec = include_str!("../../../volta_equivalence/tests/specs/row_rms_norm.spec");
    let reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();
    check_equivalence(
        &reference,
        &actual,
        &["y".into()],
        &EquivCheckOptions::default(),
    )
    .0
}

// Test every output of both rows of a 2 x 1,024 tensor, one workgroup at a time, and of a
// 1,000-element row, whose last 24 columns the kernel masks as padding.
#[test]
fn amd_ck_rmsnorm_rows_match_their_specification() {
    for (rows, row, columns) in [(2, 0, 1024), (2, 1, 1024), (1, 0, 1000)] {
        assert_eq!(
            check_ck_rmsnorm(rows, row, columns, RMSNORM_EPSILON),
            EquivalenceVerdict::Equivalent {
                checked: u64::from(columns),
                total: u64::from(columns),
            },
            "row {row} of {rows}, {columns} columns"
        );
    }
}

// Test that a kernel run with twice the specification's epsilon is refuted.
#[test]
fn amd_ck_rmsnorm_with_wrong_epsilon_is_refuted() {
    let verdict = check_ck_rmsnorm(1, 0, 1024, 2.0 * RMSNORM_EPSILON);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

const AVG_POOL2D_SPEC: &str =
    include_str!("../../../volta_equivalence/tests/specs/avg_pool2d_nhwc.spec");

/// Run workgroup `workgroup` of CK's average pooling of `pool` and check its graph.
fn launch_ck_avgpool2d(pool: &AvgPool2d, workgroup: u32) -> AmdChecked {
    // CK launches one workgroup of 256 work-items along X for every 256 output elements.
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (256, 1, 1),
        workgroup_id: (workgroup, 0, 0),
        grid_size: ((pool.output_len() as u32).div_ceil(256), 1, 1),
    };
    check_amd_launch(
        "success/ck_avgpool2d.s",
        amd_fixture!("success/ck_avgpool2d"),
        CK_AVGPOOL2D_KERNEL,
        &launch,
        &ck_avgpool2d_kernarg(pool),
        &avgpool_arrays(pool),
    )
}

/// The dims of `avg_pool2d_nhwc.spec` for `pool`.
fn avgpool2d_dims(pool: &AvgPool2d) -> HashMap<String, u64> {
    let [output_height, output_width] = pool.output();
    let dims = [
        ("N", pool.batch),
        ("H", pool.input[0]),
        ("W", pool.input[1]),
        ("C", pool.channels),
        ("HOUT", output_height),
        ("WOUT", output_width),
        ("KH", pool.window[0]),
        ("KW", pool.window[1]),
        ("SH", pool.stride[0]),
        ("SW", pool.stride[1]),
        ("DH", pool.dilation[0]),
        ("DW", pool.dilation[1]),
        ("PH", pool.left_pad[0]),
        ("PW", pool.left_pad[1]),
    ];
    HashMap::from(dims.map(|(name, value)| (name.to_string(), value as u64)))
}

/// Check one workgroup of CK's average pooling of `launched` against `spec` at the parameters
/// of `specified`. The kernel must write exactly the outputs that workgroup's work-items own.
fn check_ck_avgpool2d(
    launched: &AvgPool2d,
    workgroup: u32,
    spec: &str,
    specified: &AvgPool2d,
) -> EquivalenceVerdict {
    let actual = launch_ck_avgpool2d(launched, workgroup).verified_outputs();

    // The reference states every output from the pooling parameters, not CK's descriptors.
    let dims = avgpool2d_dims(specified);
    let mut reference = volta_spec::extract_expressions_from_spec(spec, &dims).unwrap();

    // Work-item i of a workgroup owns output 256 * workgroup + i: keep those of the reference.
    let first = 256 * u64::from(workgroup);
    for (_, elements) in &mut reference.outputs {
        elements.retain(|(index, _)| (first..first + 256).contains(index));
    }
    check_equivalence(
        &reference,
        &actual,
        &["output".into()],
        &EquivCheckOptions::default(),
    )
    .0
}

/// Require each workgroup of `pool`'s launch to write its outputs, all equal to the formula's.
fn assert_ck_avgpool2d_matches(pool: &AvgPool2d) {
    let outputs = pool.output_len() as u64;
    for workgroup in 0..outputs.div_ceil(256) {
        let owned = (outputs - 256 * workgroup).min(256);
        assert_eq!(
            check_ck_avgpool2d(pool, workgroup as u32, AVG_POOL2D_SPEC, pool),
            EquivalenceVerdict::Equivalent {
                checked: owned,
                total: owned,
            },
            "workgroup {workgroup} of {pool:?}"
        );
    }
}

/// A launch without padding or dilation.
fn unpadded_pool(
    batch: i32,
    channels: i32,
    input: [i32; 2],
    window: [i32; 2],
    stride: [i32; 2],
) -> AvgPool2d {
    AvgPool2d {
        batch,
        channels,
        input,
        window,
        stride,
        dilation: [1, 1],
        left_pad: [0, 0],
        right_pad: [0, 0],
    }
}

// Test every output of three unpadded launches: disjoint 2 x 2 windows whose 18 outputs fill
// part of a workgroup, overlapping 3 x 2 windows, and 450 outputs across two workgroups.
#[test]
fn amd_ck_avgpool2d_matches_its_specification() {
    for pool in [
        unpadded_pool(1, 2, [6, 6], [2, 2], [2, 2]),
        // Lengths that are not powers of two give CK's division multipliers distinct values.
        unpadded_pool(2, 3, [7, 9], [3, 2], [2, 1]),
        unpadded_pool(1, 5, [10, 12], [2, 3], [1, 1]),
    ] {
        assert_ck_avgpool2d_matches(&pool);
    }
}

// Test every output where windows reach into the zero padding or skip elements: 3 x 3 windows
// over one row and column of padding on each side, 2 x 2 windows dilated by 2, and padding
// that differs before and after the input.
#[test]
fn amd_ck_avgpool2d_with_padding_and_dilation_matches_its_specification() {
    let padded = AvgPool2d {
        left_pad: [1, 1],
        right_pad: [1, 1],
        ..unpadded_pool(1, 3, [5, 6], [3, 3], [2, 2])
    };
    let dilated = AvgPool2d {
        window: [2, 2],
        stride: [1, 1],
        dilation: [2, 2],
        ..padded
    };
    let uneven = AvgPool2d {
        left_pad: [1, 0],
        right_pad: [0, 2],
        ..unpadded_pool(2, 2, [4, 5], [2, 3], [1, 2])
    };
    for pool in [padded, dilated, uneven] {
        assert_ck_avgpool2d_matches(&pool);
    }
}

// Test that the kernel is refuted against the window sum without its division.
#[test]
fn amd_ck_avgpool2d_against_the_undivided_sum_is_refuted() {
    let undivided = AVG_POOL2D_SPEC.replace("/ (KH * KW)", "");
    assert_ne!(undivided, AVG_POOL2D_SPEC);
    let pool = unpadded_pool(1, 2, [6, 6], [2, 2], [2, 2]);
    let verdict = check_ck_avgpool2d(&pool, 0, &undivided, &pool);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

// Test that padding before the input is refuted against a formula that pads after it. Both
// have 6 x 6 outputs, but each window lies one row and one column apart.
#[test]
fn amd_ck_avgpool2d_with_padding_on_the_other_side_is_refuted() {
    let launched = AvgPool2d {
        left_pad: [1, 1],
        ..unpadded_pool(1, 2, [6, 6], [2, 2], [1, 1])
    };
    let specified = AvgPool2d {
        left_pad: [0, 0],
        right_pad: [1, 1],
        ..launched
    };
    assert_eq!(launched.output(), specified.output());
    let verdict = check_ck_avgpool2d(&launched, 0, AVG_POOL2D_SPEC, &specified);
    assert!(
        matches!(&verdict, EquivalenceVerdict::Refuted { elements } if !elements.is_empty()),
        "expected a confirmed difference, got {verdict:?}"
    );
}

// Test that a launch whose 3 x 3 output is larger than its 2 x 2 input is rejected. CK sizes
// the output buffer as if the output had the input's height and width, here five elements,
// so the kernel's stores of outputs 5 to 8 fall outside the buffer and are dropped.
#[test]
fn amd_ck_avgpool2d_with_outputs_beyond_cks_output_bound_is_rejected() {
    let pool = AvgPool2d {
        left_pad: [1, 1],
        right_pad: [1, 1],
        ..unpadded_pool(1, 1, [2, 2], [2, 2], [1, 1])
    };
    assert_eq!(pool.output_len(), 9);
    let checked = launch_ck_avgpool2d(&pool, 0);
    let report = checked.report.clone();
    let assumptions = checked.analysis.graph.provenance().assumptions.clone();
    let mut actual = checked.verified_outputs();

    // The formula defines all nine outputs, so the comparison names the four never written.
    let parsed = volta_spec::parse_spec(AVG_POOL2D_SPEC).unwrap();
    let spec = Spec::new(&parsed, &avgpool2d_dims(&pool)).unwrap();
    let (verdict, _) =
        check_against_spec(&mut actual, &spec, &EquivCheckOptions::default()).unwrap();
    assert_eq!(
        verdict,
        EquivalenceVerdict::IndexSetMismatch {
            array: "output".into(),
            unwritten: vec![5, 6, 7, 8],
            unexpected: vec![],
        }
    );

    // The run's graph verified, so the unwritten outputs alone make the verdict a rejection.
    let kernel = KernelEvidence {
        label: "kernel",
        graph: &report,
        assumptions: &assumptions,
    };
    assert_eq!(decide(&verdict, &[kernel]).verdict, Verdict::Reject);
}
