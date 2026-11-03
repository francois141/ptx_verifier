//! Each fixture kernel's symbolic outputs stated against the formula in
//! `fixtures/<name>.spec`, as a Lean challenge written to `target/lean/<name>.lean`
//! (`just extract-lean`).

mod common;

use std::collections::HashMap;
use std::path::Path;

use common::array;
use rug::Rational;
use volta_amd_analysis::{ArrayDef, ArrayKind};
use volta_expr::lean::{Claim, to_lean};
use volta_spec::extract_expressions_from_spec;

/// Within 1/1000 rather than equal: past `a > 87.34` the kernel rescales by f32(e^-64), not e^-64.
#[test]
fn the_sigmoid_kernel_is_stated_within_a_thousandth_of_its_formula() {
    let arrays = [
        array("a", 0x10000, ArrayKind::Input),
        array("out", 0x20000, ArrayKind::Output),
    ];
    let claim = Claim::Within(Rational::from((1, 1000)));
    let lean = write_challenge("sigmoid", &arrays, &claim)
        .unwrap_or_else(|error| panic!("sigmoid: {error}"));

    let statements = common::WORKITEMS as usize;
    assert_eq!(lean.matches("\ndef out_").count(), statements);
    assert_eq!(lean.matches("| ≤ (0.001 : ℝ)\n").count(), statements);
}

/// Kernel `name`'s outputs against `fixtures/<name>.spec` (dim `N` = the work-item count),
/// written to `target/lean/<name>.lean` and returned.
fn write_challenge(name: &str, arrays: &[ArrayDef], claim: &Claim) -> Result<String, String> {
    let candidate = common::outputs(name, arrays)?;
    let path = common::fixture(name).with_extension("spec");
    let source =
        std::fs::read_to_string(&path).map_err(|e| format!("read {}: {e}", path.display()))?;
    let dims = HashMap::from([("N".to_string(), u64::from(common::WORKITEMS))]);
    let baseline = extract_expressions_from_spec(&source, &dims).map_err(|e| e.to_string())?;

    let checked: Vec<String> = baseline.outputs.iter().map(|(a, _)| a.clone()).collect();

    let lean = to_lean(&candidate, &baseline, &checked, claim, "VoltaChallenge")
        .map_err(|e| e.to_string())?;

    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("../../target/lean");
    std::fs::create_dir_all(&dir).map_err(|e| format!("create {}: {e}", dir.display()))?;
    let path = dir.join(format!("{name}.lean"));
    std::fs::write(&path, &lean).map_err(|e| format!("write {}: {e}", path.display()))?;
    Ok(lean)
}
