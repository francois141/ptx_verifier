//! Functional equivalence of compiled AMD kernels against mathematical specifications.

use std::collections::HashMap;

use volta_amd_analysis::frontend::parse::parse_kernel;
use volta_amd_analysis::{ArrayDef, ArrayKind, Terminal, WorkgroupLaunch, analyze};
use volta_equivalence::check::EquivCheckOptions;
use volta_pipeline::{EquivalenceVerdict, check_equivalence};

const A_BASE: u64 = 0x10000;
const B_BASE: u64 = 0x20000;
const C_BASE: u64 = 0x30000;

fn check_matmul(input_bases: [u64; 2]) -> EquivalenceVerdict {
    // Bind the compiled kernel's pointer arguments to three row-major 8 x 8 matrices.
    let arrays = [
        ("A", A_BASE, ArrayKind::Input),
        ("B", B_BASE, ArrayKind::Input),
        ("C", C_BASE, ArrayKind::Output),
    ]
    .map(|(name, base, kind)| ArrayDef {
        name: name.into(),
        base,
        len: 64,
        kind,
    });
    let kernarg: Vec<u8> = [input_bases[0], input_bases[1], C_BASE]
        .into_iter()
        .flat_map(u64::to_le_bytes)
        .collect();
    let launch = WorkgroupLaunch {
        kernarg_address: 0x1000,
        workgroup_size: (64, 1, 1),
    };

    // Execute the existing assembly fixture, with one work-item per output element.
    let source = include_str!("../../volta_amd_analysis/tests/fixtures/matmul.s");
    let kernel = parse_kernel(source, "matmul").unwrap();
    let result = analyze(&kernel, &launch, &kernarg, &arrays).unwrap();
    assert!(
        matches!(&result.terminal, Terminal::Completed),
        "AMD matmul did not complete: {:?}",
        result.terminal
    );
    let actual = result.symbolic_outputs.expect("completed matmul outputs");

    // Derive the reference independently from C[i, j] = sum_k A[i, k] * B[k, j].
    let spec = include_str!("../../volta_equivalence/tests/specs/matmul.spec");
    let parsed = volta_spec::parse_spec(spec).unwrap();
    let dims = HashMap::from([("M".into(), 8), ("N".into(), 8), ("K".into(), 8)]);
    let (env, outputs) = volta_spec::instantiate(&parsed, &dims).unwrap();
    let reference = volta_spec::unfold(&outputs, &env, 0).unwrap();

    check_equivalence(
        &reference,
        &actual,
        &["C".into()],
        &EquivCheckOptions::default(),
    )
    .0
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
