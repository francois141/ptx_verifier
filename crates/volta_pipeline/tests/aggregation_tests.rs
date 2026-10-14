//! Aggregation over real kernels: both branches run on the analysis stage's artifacts and only
//! `decide` combines them.

use volta_analysis::eval::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};
use volta_equivalence::CanonValueEquality;
use volta_equivalence::check::EquivCheckOptions;
use volta_frontend::ascii::AsAscii;
use volta_frontend::ast::Module;
use volta_frontend::parse::Parser;
use volta_graph_check::{GraphConclusion, Property, Verdict as PropertyVerdict};
use volta_pipeline::{
    Decision, EquivalenceVerdict, KernelEvidence, KernelVerification, Verdict, check_equivalence,
    decide, verify_kernel,
};

/// `out[tid] = in[tid] <op>` for 4 threads; `store_to_zero` makes every thread write `out[0]`.
fn kernel(body: &str) -> String {
    format!(
        r#"
.version 8.0
.target sm_80
.address_size 64

.visible .entry k(.param .u64 in, .param .u64 out)
{{
    .reg .pred %p<2>;
    .reg .b32 %r<4>;
    .reg .b64 %rd<8>;
    .reg .f32 %f<4>;
    .shared .align 8 .b64 bar;
    ld.param.u64 %rd1, [in];
    ld.param.u64 %rd2, [out];
    mov.u32 %r1, %tid.x;
    mul.wide.u32 %rd3, %r1, 4;
    add.u64 %rd4, %rd1, %rd3;
    add.u64 %rd5, %rd2, %rd3;
    ld.global.f32 %f1, [%rd4];
{body}
    ret;
}}
"#
    )
}

const COPY: &str = "    st.global.f32 [%rd5], %f1;";
const PLUS_ONE: &str = "    add.f32 %f2, %f1, 0f3F800000;\n    st.global.f32 [%rd5], %f2;";
const ALL_TO_ZERO: &str = "    st.global.f32 [%rd2], %f1;";
/// Thread 0 initializes an mbarrier every thread then arrives on and waits for.
const THROUGH_MBARRIER: &str = r#"
    mov.u32 %r2, bar;
    setp.eq.u32 %p1, %r1, 0;
    @%p1 mbarrier.init.shared.b64 [%r2], 4;
    bar.sync 0;
    mbarrier.arrive.shared.b64 %rd6, [%r2];
WAIT:
    mbarrier.try_wait.parity.shared.b64 %p1, [%r2], 0;
    @!%p1 bra WAIT;
    st.global.f32 [%rd5], %f1;"#;

fn parse(src: &str) -> Module {
    Parser::new(src.as_bytes().as_ascii_slice().unwrap())
        .parse_module()
        .unwrap_or_else(|e| panic!("{:?}", e.error))
}

fn config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((4, 1, 1));
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
            len: 4,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

fn run(body: &str) -> KernelVerification {
    verify_kernel(&parse(&kernel(body)), None, config(), &CanonValueEquality).unwrap()
}

fn equivalence(a: &KernelVerification, b: &KernelVerification) -> EquivalenceVerdict {
    check_equivalence(
        a.analysis.symbolic_outputs().unwrap(),
        b.analysis.symbolic_outputs().unwrap(),
        &["out".to_string()],
        &EquivCheckOptions::default(),
    )
    .0
}

fn decide_pair(
    eq: &EquivalenceVerdict,
    a: &KernelVerification,
    b: &KernelVerification,
) -> Decision {
    let kernels = [
        KernelEvidence {
            label: "reference",
            graph: &a.graph,
            assumptions: &a.analysis.graph.provenance().assumptions,
        },
        KernelEvidence {
            label: "optimized",
            graph: &b.graph,
            assumptions: &b.analysis.graph.provenance().assumptions,
        },
    ];
    decide(eq, &kernels)
}

#[test]
fn equivalent_verified_kernels_are_accepted() {
    let (a, b) = (run(COPY), run(COPY));
    assert_eq!(a.graph.conclusion(), GraphConclusion::Verified);
    let eq = equivalence(&a, &b);
    assert_eq!(
        eq,
        EquivalenceVerdict::Equivalent {
            checked: 4,
            total: 4
        }
    );
    let decision = decide_pair(&eq, &a, &b);
    assert_eq!(decision.verdict, Verdict::Accept, "{decision:?}");
    assert!(!decision.assumptions.is_empty());
}

#[test]
fn a_sampled_proof_is_not_an_acceptance() {
    let (a, b) = (run(COPY), run(COPY));
    let sampled = EquivalenceVerdict::Equivalent {
        checked: 2,
        total: 4,
    };
    let decision = decide_pair(&sampled, &a, &b);
    assert_eq!(decision.verdict, Verdict::Unknown);
    assert!(decision.evidence[0].contains("sampled"), "{decision:?}");
}

#[test]
fn a_numerically_confirmed_difference_rejects() {
    let (a, b) = (run(COPY), run(PLUS_ONE));
    let eq = equivalence(&a, &b);
    assert!(matches!(&eq, EquivalenceVerdict::Refuted { elements } if elements.len() == 4));
    assert_eq!(decide_pair(&eq, &a, &b).verdict, Verdict::Reject);
}

#[test]
fn an_unconfirmed_difference_is_unknown() {
    let (a, b) = (run(COPY), run(COPY));
    let unproven = EquivalenceVerdict::Unproven {
        elements: vec![("out".to_string(), 0)],
    };
    assert_eq!(decide_pair(&unproven, &a, &b).verdict, Verdict::Unknown);
}

#[test]
fn a_failed_graph_property_rejects_whatever_the_equivalence() {
    let (a, b) = (run(COPY), run(ALL_TO_ZERO));
    assert_eq!(
        b.graph.verdict(Property::MemoryConflicts),
        PropertyVerdict::Fail
    );
    let decision = decide_pair(
        &EquivalenceVerdict::Equivalent {
            checked: 4,
            total: 4,
        },
        &a,
        &b,
    );
    assert_eq!(decision.verdict, Verdict::Reject);
    assert!(
        decision.evidence[0].starts_with("optimized: memory-conflict freedom failed"),
        "{decision:?}"
    );
}

#[test]
fn candidate_only_passes_are_reported_as_unknown() {
    let (a, b) = (run(COPY), run(THROUGH_MBARRIER));
    assert_eq!(b.graph.verdict_overall(), PropertyVerdict::Pass);
    let eq = equivalence(&a, &b);
    let decision = decide_pair(&eq, &a, &b);
    assert_eq!(decision.verdict, Verdict::Unknown);
    assert!(
        decision
            .evidence
            .iter()
            .any(|e| e.contains("candidate execution only") && e.contains("mbarrier")),
        "{decision:?}"
    );
}
