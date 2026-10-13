//! Specs as one side of the equivalence pipeline: an unfolded spec's
//! `AnalysisOutput` checks equivalent to a hand-built reference.

use std::collections::HashMap;

use volta_equivalence::{EquivCheckOptions, EquivOutcome, check_output_equivalence_with};
use volta_expr::spec::{Bound, IndexExpr, OutputSpec, Shape, SpecEnv, SpecExpr, unfold};
use volta_expr::{ExprArena, SymbolicOutputs};

/// `C[i,j] = sum_k A[i,k] * B[k,j]` over an M x N x K env.
fn matmul_spec() -> Vec<OutputSpec> {
    let body = SpecExpr::sum(
        "k",
        Bound::Named("K".to_string()),
        SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("k")])
            * SpecExpr::index("B", vec![IndexExpr::var("k"), IndexExpr::var("j")]),
    );
    vec![OutputSpec {
        array: "C".to_string(),
        shape: Shape::new(vec![2, 2]),
        vars: vec!["i".to_string(), "j".to_string()],
        body,
    }]
}

fn matmul_env() -> SpecEnv {
    SpecEnv {
        dims: HashMap::from([("K".to_string(), 3)]),
        arrays: HashMap::from([
            ("A".to_string(), Shape::new(vec![2, 3])),
            ("B".to_string(), Shape::new(vec![3, 2])),
        ]),
    }
}

/// A spec's unfolded `AnalysisOutput` must work as one side of the kernel equivalence
/// pipeline: a manual `Fma` chain over the same `InputElement`s must check equivalent
/// to the matmul spec through `check_output_equivalence_with`.
#[test]
fn unfolded_matmul_is_equivalent_to_a_hand_built_reference() {
    let spec_output = unfold(&matmul_spec(), &matmul_env(), 0).unwrap();

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
    let hand_built = SymbolicOutputs {
        arena,
        outputs: vec![("C".to_string(), elems)],
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

/// A `dim`'s concrete value must be usable as a plain value in an expression body (e.g.
/// a mean's divisor), not just as a bound or shape: `SpecExpr::Var`/`IndexExpr::Var` must
/// fall back to `SpecEnv::dims`.
#[test]
fn dim_value_is_usable_directly_in_an_expression() {
    // mean[i] = sum(j in 0..N, A[i,j]) / N
    let body = SpecExpr::sum(
        "j",
        Bound::Named("N".to_string()),
        SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("j")]),
    ) / SpecExpr::var("N");
    let specs = vec![OutputSpec {
        array: "mean".to_string(),
        shape: Shape::new(vec![2]),
        vars: vec!["i".to_string()],
        body,
    }];
    let env = SpecEnv {
        dims: HashMap::from([("N".to_string(), 4)]),
        arrays: HashMap::from([("A".to_string(), Shape::new(vec![2, 4]))]),
    };
    let output = unfold(&specs, &env, 0).unwrap();

    let mut hand_arena = ExprArena::new();
    let a = hand_arena.intern_string("A");
    let mut elems = Vec::new();
    for i in 0u64..2 {
        let mut acc = hand_arena.int(0);
        for j in 0u64..4 {
            let term = hand_arena.input_element(a, i * 4 + j);
            acc = hand_arena.add(acc, term);
        }
        let n = hand_arena.int(4);
        elems.push((i, hand_arena.div(acc, n)));
    }
    let hand_built = SymbolicOutputs {
        arena: hand_arena,
        outputs: vec![("mean".to_string(), elems)],
    };

    let report = check_output_equivalence_with(
        &output,
        &hand_built,
        &["mean".to_string()],
        &EquivCheckOptions::default(),
    )
    .unwrap();
    assert!(matches!(report.outcome, EquivOutcome::Equivalent));
}

/// `max` reduction computes the same value as a hand-built running-max
/// chain (`M[i] = max(j in 0..N, A[i,j])`), including the empty-range
/// identity built into `ExprArena::max`'s own chain convention.
#[test]
fn max_reduction_matches_a_hand_built_running_max() {
    let body = SpecExpr::max_reduce(
        "j",
        Bound::Named("N".to_string()),
        SpecExpr::index("A", vec![IndexExpr::var("i"), IndexExpr::var("j")]),
    );
    let specs = vec![OutputSpec {
        array: "M".to_string(),
        shape: Shape::new(vec![2]),
        vars: vec!["i".to_string()],
        body,
    }];
    let env = SpecEnv {
        dims: HashMap::from([("N".to_string(), 3)]),
        arrays: HashMap::from([("A".to_string(), Shape::new(vec![2, 3]))]),
    };
    let spec_output = unfold(&specs, &env, 0).unwrap();

    let mut arena = ExprArena::new();
    let a = arena.intern_string("A");
    let mut elems = Vec::new();
    for i in 0u64..2 {
        let mut acc = arena.float_from_f64(f64::NEG_INFINITY).unwrap();
        for j in 0u64..3 {
            let v = arena.input_element(a, i * 3 + j);
            acc = arena.max(acc, v);
        }
        elems.push((i, acc));
    }
    let hand_built = SymbolicOutputs {
        arena,
        outputs: vec![("M".to_string(), elems)],
    };

    let report = check_output_equivalence_with(
        &spec_output,
        &hand_built,
        &["M".to_string()],
        &EquivCheckOptions::default(),
    )
    .unwrap();
    assert!(matches!(report.outcome, EquivOutcome::Equivalent));
}
