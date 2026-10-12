//! End-to-end NEGATIVE check: a kernel pair with a dropped reduction term
//! must be NotEquivalent under BOTH canon and Z3 (`Equivalent` is a soundness
//! bug). No exp, so Z3's `sat` is a real countermodel.

use std::time::Duration;

use volta_analysis::driver::{
    EquivOutcome, analyze_kernel, check_output_equivalence, paired_elements, sampled_elements,
};
use volta_analysis::eval::{AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, ParamValue};
use volta_frontend::ascii::AsAscii;
use volta_frontend::parse::Parser;
use volta_z3::{ExpMode, Z3Verdict};

/// Wire the worker entry for this test binary (real binaries call
/// `volta_z3::init_worker()` at the top of `main`; libtest owns this
/// binary's `main`, so the hook runs pre-main).
#[ctor::ctor]
fn worker_hook() {
    volta_z3::init_worker();
}

/// out[0] = the sum of the first `terms` elements of the symbolic input
/// array (loads are identical either way; only the accumulation chain
/// shortens).
fn sum_kernel(terms: u32) -> String {
    assert!((2..=4).contains(&terms));
    let mut src = String::from(
        ".version 8.0
.target sm_80
.address_size 64

.visible .entry k(
    .param .u64 k_param_0,
    .param .u64 k_param_1
)
{
    .reg .f32 %f<9>;
    .reg .b64 %rd<3>;

    ld.param.u64 %rd1, [k_param_0];
    ld.param.u64 %rd2, [k_param_1];
    cvta.to.global.u64 %rd1, %rd1;
    cvta.to.global.u64 %rd2, %rd2;
    ld.global.f32 %f1, [%rd1];
    ld.global.f32 %f2, [%rd1+4];
    ld.global.f32 %f3, [%rd1+8];
    ld.global.f32 %f4, [%rd1+12];
    add.f32 %f5, %f1, %f2;
",
    );
    for i in 3..=terms {
        src.push_str(&format!("    add.f32 %f{}, %f{}, %f{};\n", i + 3, i + 2, i));
    }
    src.push_str(&format!(
        "    st.global.f32 [%rd2], %f{};
    ret;
}}
",
        terms + 3
    ));
    src
}

fn analyze(src: &str) -> AnalysisOutput {
    let ascii = src.as_bytes().as_ascii_slice().expect("ascii source");
    let module = Parser::new(ascii)
        .parse_module()
        .unwrap_or_else(|e| panic!("parse error: {:?}", e.error));
    let mut config = AnalysisConfig::new((1, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len: 4,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 1,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    analyze_kernel(&module, None, config).unwrap_or_else(|e| panic!("analysis failed: {}", e))
}

/// Sum of 4 inputs vs sum of 3: NotEquivalent under the decision procedure
/// AND `sat` (a genuine countermodel) under Z3, on the exact same paired
/// element.
#[test]
fn dropped_term_is_not_equivalent_under_both_backends() {
    let reference = analyze(&sum_kernel(4));
    let mutant = analyze(&sum_kernel(3));
    let arrays = vec!["out".to_string()];

    // Decision procedure: NotEquivalent, naming the one element.
    let outcome = check_output_equivalence(&reference, &mutant, &arrays)
        .expect("decision procedure must decide this polynomial VC");
    let EquivOutcome::NotEquivalent { mismatches } = outcome else {
        panic!("SOUNDNESS BUG: dropped-term pair was proved Equivalent by canon");
    };
    assert_eq!(mismatches.len(), 1);
    assert_eq!(
        (mismatches[0].array.as_str(), mismatches[0].index),
        ("out", 0)
    );

    // Z3, on the same element pairing the decision procedure used.
    let paired =
        paired_elements(&reference, &mutant, &arrays).expect("footprints pair by construction");
    let elements = sampled_elements(&paired, 0);
    assert_eq!(elements.len(), 1, "one written output element");
    let (_, _, r, o) = elements[0];
    let result = volta_z3::check_equivalent(
        &reference.arena,
        r,
        &mutant.arena,
        o,
        Some(Duration::from_secs(60)),
        ExpMode::PowerBounded,
    )
    .expect("polynomial fragment is fully supported by the Z3 translation");
    assert_eq!(
        result.verdict,
        Z3Verdict::NotEquivalent,
        "SOUNDNESS BUG: dropped-term pair was proved Equivalent by Z3"
    );
}
