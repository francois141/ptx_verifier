//! End-to-end: parse a textual matmul spec, instantiate it at a concrete
//! size, unfold it, and check the result against a hand-built reference
//! through the same equivalence pipeline used to compare two kernels -
//! mirroring `volta_analysis::spec`'s own killer test, but starting from
//! spec *source text* instead of a hand-built `SpecExpr` tree.

use std::collections::HashMap;

use volta_analysis::driver::{EquivCheckOptions, EquivOutcome, check_output_equivalence_with};
use volta_analysis::eval::{AnalysisOutput, Stats};
use volta_analysis::spec::unfold;
use volta_analysis::symbolic::ExprArena;

const MATMUL_SPEC: &str = "
dim M;
dim N;
dim K;

array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[k, j]);
";

fn dims(m: u64, n: u64, k: u64) -> HashMap<String, u64> {
    HashMap::from([
        ("M".to_string(), m),
        ("N".to_string(), n),
        ("K".to_string(), k),
    ])
}

#[test]
fn parsed_matmul_spec_matches_a_hand_built_reference() {
    let parsed = volta_spec::parse_spec(MATMUL_SPEC).expect("spec should parse");
    let (env, specs) =
        volta_spec::instantiate(&parsed, &dims(2, 2, 3)).expect("should instantiate");
    let spec_output = unfold(&specs, &env, 0).expect("should unfold");

    let mut arena = ExprArena::new();
    let a = arena.intern_string("A");
    let b = arena.intern_string("B");
    let mut elems = Vec::new();
    for i in 0u64..2 {
        for j in 0u64..2 {
            let mut acc = arena.int(0);
            for k in 0u64..3 {
                let av = arena.input_element(a, i * 3 + k);
                let bv = arena.input_element(b, k * 2 + j);
                let term = arena.mul(av, bv);
                acc = arena.add(acc, term);
            }
            elems.push((i * 2 + j, acc));
        }
    }
    let hand_built = AnalysisOutput {
        arena,
        outputs: vec![("C".to_string(), elems)],
        stats: Stats::default(),
        op_counts: Default::default(),
    };

    let report = check_output_equivalence_with(
        &spec_output,
        &hand_built,
        &["C".to_string()],
        &EquivCheckOptions::default(),
    )
    .unwrap();
    assert!(matches!(report.outcome, EquivOutcome::Equivalent));
    assert_eq!(report.elements_checked, 4);
}

#[test]
fn same_parsed_spec_reinstantiates_at_a_different_size() {
    let parsed = volta_spec::parse_spec(MATMUL_SPEC).expect("spec should parse");
    let (env, specs) =
        volta_spec::instantiate(&parsed, &dims(3, 4, 5)).expect("should instantiate");
    let output = unfold(&specs, &env, 0).unwrap();
    let (name, elems) = &output.outputs[0];
    assert_eq!(name, "C");
    assert_eq!(elems.len(), 12); // 3 x 4
}

#[test]
fn missing_dim_value_is_a_clean_error() {
    let parsed = volta_spec::parse_spec(MATMUL_SPEC).expect("spec should parse");
    let err =
        volta_spec::instantiate(&parsed, &dims(2, 2, 3).into_iter().take(0).collect()).unwrap_err();
    assert!(matches!(
        err,
        volta_spec::InstantiateErrorKind::MissingDimValue(_)
    ));
}
