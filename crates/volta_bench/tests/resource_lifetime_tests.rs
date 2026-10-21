//! Kernels that free Tensor Memory while a use of it is not ordered before the deallocation:
//! the resource-lifetime check (Algorithm 6) must fail, phase 1 reporting those uses.

#[macro_use]
mod common;

use volta_analysis::eval::AnalysisConfig;
use volta_frontend::ast::Module;
use volta_graph::{AccessMode, AsyncOpKind};
use volta_graph_check::resource_lifetime::LifetimeViolation;

use common::*;

/// The uses phase 1 reports as not ordered before their deallocation.
fn freed_while_in_use(module: &Module, config: AnalysisConfig) -> Vec<Side> {
    let checked = check(module, None, config);
    let effects: Vec<Side> = checked
        .report
        .resource_lifetime
        .violations()
        .iter()
        .filter_map(|v| match *v {
            LifetimeViolation::UseNotBeforeDeallocation { effect, .. } => {
                Some(side(&checked.analysis.graph, effect))
            }
            _ => None,
        })
        .collect();
    assert!(
        !effects.is_empty(),
        "expected a use not ordered before its deallocation, got: {:?}",
        checked.report.resource_lifetime
    );
    effects
}

use AccessMode::{Read, Write};

/// `tcgen05.dealloc` with an un-waited `tcgen05.ld`/`.st` still outstanding on the range:
/// the use is not ordered before the deallocation.
#[test]
fn test_tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected() {
    for (expected, (name, src)) in [
        (
            Side::effect(0, Read, AsyncOpKind::Tcgen05Ld),
            ptx_case!("execution_error/tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected_ld"),
        ),
        (
            Side::effect(0, Write, AsyncOpKind::Tcgen05St),
            ptx_case!("execution_error/tcgen05_dealloc_with_an_unwaited_ld_or_st_is_rejected_st"),
        ),
    ] {
        let effects = freed_while_in_use(&parse(&src), AnalysisConfig::new((32, 1, 1)));
        assert!(
            effects
                .iter()
                .any(|e| e.op == expected.op && e.mode == expected.mode),
            "{name}: expected a freed {expected:?}, got: {effects:?}"
        );
    }
}

/// `tcgen05.dealloc` of `D`'s columns while the MMA writing them is still in flight -
/// committed, but no thread has observed `mma_bar` - is rejected.
#[test]
fn test_tcgen05_dealloc_with_an_mma_in_flight_is_rejected() {
    let effects = freed_while_in_use(
        &parse(&ptx!(
            "execution_error/tcgen05_dealloc_with_an_mma_in_flight_is_rejected"
        )),
        AnalysisConfig::new((64, 1, 1)),
    );
    assert!(
        effects.contains(&Side::effect(0, Write, AsyncOpKind::Tcgen05Mma)),
        "expected the MMA's write of D freed, got: {effects:?}"
    );
}
