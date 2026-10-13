//! The spec-to-spec harness shared by the integration tests: load `.spec`
//! files, unfold both sides and check them, with and without a `.vexpr` round trip.

#![allow(dead_code)]

use std::collections::HashMap;

use volta_equivalence::check::Mismatch;
use volta_equivalence::{EquivOutcome, check_output_equivalence};
use volta_expr::SymbolicOutputs;
use volta_expr::spec::unfold;
use volta_expr::text::{read_text, to_text};

/// The source of `tests/specs/<name>.spec`.
macro_rules! spec {
    ($name:expr) => {
        include_str!(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/tests/specs/",
            $name,
            ".spec"
        ))
    };
}

/// Two spec sources checked under the same dim values.
pub struct SpecPair {
    pub name: &'static str,
    pub dims: &'static [(&'static str, u64)],
    pub reference: &'static str,
    pub other: &'static str,
}

pub fn unfold_spec(name: &str, src: &str, dims: &[(&str, u64)]) -> SymbolicOutputs {
    let parsed = volta_spec::parse_spec(src)
        .unwrap_or_else(|e| panic!("{name}: spec parse error: {}\n{src}", e.error));
    let dims: HashMap<String, u64> = dims.iter().map(|&(d, v)| (d.to_string(), v)).collect();
    let (env, specs) = volta_spec::instantiate(&parsed, &dims)
        .unwrap_or_else(|e| panic!("{name}: instantiate: {e}"));
    unfold(&specs, &env, 0).unwrap_or_else(|e| panic!("{name}: unfold: {e}"))
}

/// The verdict along the reference's output arrays, after asserting that a
/// `.vexpr` round trip of both sides yields the same verdict.
pub fn check(pair: &SpecPair) -> EquivOutcome {
    let reference = unfold_spec(pair.name, pair.reference, pair.dims);
    let other = unfold_spec(pair.name, pair.other, pair.dims);
    let arrays: Vec<String> = reference.outputs.iter().map(|(n, _)| n.clone()).collect();
    let verdict = |a: &SymbolicOutputs, b: &SymbolicOutputs| {
        check_output_equivalence(a, b, &arrays)
            .unwrap_or_else(|e| panic!("{}: equivalence check errored: {}", pair.name, e))
    };
    let reread = |exprs: &SymbolicOutputs| {
        read_text(&to_text(exprs)).unwrap_or_else(|e| panic!("{}: reread .vexpr: {e}", pair.name))
    };
    let outcome = verdict(&reference, &other);
    let from_text = verdict(&reread(&reference), &reread(&other));
    assert_eq!(
        format!("{from_text:?}"),
        format!("{outcome:?}"),
        "{}: the .vexpr round trip changed the verdict",
        pair.name
    );
    outcome
}

pub fn assert_equivalent(pair: &SpecPair) {
    let outcome = check(pair);
    assert!(
        matches!(outcome, EquivOutcome::Equivalent),
        "'{}' must be Equivalent, got {outcome:?}",
        pair.name
    );
}

/// Not equivalent, with exactly `expected` (in check order) as the mismatches.
pub fn assert_not_equivalent(pair: &SpecPair, expected: &[(&str, u64)]) {
    let EquivOutcome::NotEquivalent { mismatches } = check(pair) else {
        panic!("SOUNDNESS BUG: '{}' was proved Equivalent", pair.name);
    };
    let found: Vec<(&str, u64)> = mismatches
        .iter()
        .map(|Mismatch { array, index }| (array.as_str(), *index))
        .collect();
    assert_eq!(found, expected, "'{}' mismatches", pair.name);
}
