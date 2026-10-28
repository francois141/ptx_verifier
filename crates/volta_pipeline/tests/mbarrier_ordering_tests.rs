//! Kernels with mbarrier byte announcements: the mbarrier ordering check (Algorithm 2) is
//! inconclusive, naming the announcement no arrival of its phase is ordered after, and the
//! kernel is not verified; the announcements program order protects are accepted.

#[macro_use]
mod common;

use volta_graph::{ArrivalOrdering, ContributionKind, EventGraph, EventId, EventKind, ThreadIx};
use volta_graph_check::{GraphConclusion, Property, Verdict};
use volta_ptx_analysis::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};

use common::*;

/// `in` as eight `u32`s (two 16-byte bulk copies) and one `out` word per thread.
fn two_copies_config() -> AnalysisConfig {
    let mut config = AnalysisConfig::new((64, 1, 1));
    config.arrays = vec![
        ArrayDef {
            name: "in".to_string(),
            base: 0x10000,
            elem_width: 4,
            len: 8,
            kind: ArrayKind::Input,
        },
        ArrayDef {
            name: "out".to_string(),
            base: 0x20000,
            elem_width: 4,
            len: 64,
            kind: ArrayKind::Output,
        },
    ];
    config.params = vec![
        ParamValue::ArrayPtr("in".to_string()),
        ParamValue::ArrayPtr("out".to_string()),
    ];
    config
}

/// The contribution event `e` makes to its mbarrier phase.
fn contribution(g: &EventGraph, e: EventId) -> ContributionKind {
    let EventKind::Contribute(phase) = g.event(e).kind else {
        panic!("event {} is no contribution: {:?}", e.0, g.event(e).kind);
    };
    g.generation(phase)
        .contributions
        .iter()
        .find(|c| c.event == e)
        .expect("the phase lists its contribution")
        .kind
}

/// Thread 0 announces each copy with a bare `expect_tx`, thread 1 alone arrives: no path of
/// `G0` orders either announcement before the arrival, so on another schedule phase 0 would
/// complete before any byte is announced. The trace is the benign schedule, so the epoch
/// check passes, and the checks over `G_HB` wait for the ordering certificate it withholds.
#[test]
fn test_announcements_unordered_before_another_threads_arrival_are_inconclusive() {
    let checked = check(
        &ptx!(parse "failing/mbarrier_announcement_unordered_before_another_threads_arrival"),
        None,
        two_copies_config(),
    );
    let g = &checked.analysis.graph;
    let report = &checked.report;
    let unresolved = report.mbarrier_ordering.unresolved();
    assert_eq!(unresolved.len(), 2, "{:?}", report.mbarrier_ordering);
    for u in unresolved {
        let [announcement, arrival] = u.events[..] else {
            panic!("one announcement and the phase's one arrival: {u:?}");
        };
        assert_eq!(g.thread_of(announcement), Some(ThreadIx(0)));
        assert_eq!(
            contribution(g, announcement),
            ContributionKind::ExpectTx { bytes: 16 }
        );
        assert_eq!(g.thread_of(arrival), Some(ThreadIx(1)));
        assert_eq!(
            contribution(g, arrival),
            ContributionKind::Arrival {
                count: 1,
                expect_tx: 0,
                ordering: ArrivalOrdering::Release,
            }
        );
        assert!(
            u.reason.contains("can complete before it is announced"),
            "{}",
            u.reason
        );
    }
    assert_eq!(report.verdict(Property::MbarrierEpoch), Verdict::Pass);
    assert_eq!(report.verdict(Property::MemoryConflict), Verdict::Unknown);
    assert!(
        report.summary(Property::MemoryConflict).findings[0]
            .text
            .contains("not checked"),
        "{:?}",
        report.summary(Property::MemoryConflict)
    );
    let GraphConclusion::Unknown { reasons } = report.conclusion() else {
        panic!("{:?}", report.conclusion());
    };
    assert!(reasons[0].starts_with("mbarrier ordering:"), "{reasons:?}");
}

/// The same copies announced by the thread that arrives, after both announcements.
#[test]
fn test_announcements_before_the_same_threads_arrival_are_accepted() {
    let output = analyze!(
        "success/mbarrier_announcements_before_the_same_threads_arrival_are_accepted",
        two_copies_config()
    );
    assert_eq!(display_output(&output, "out", 0), "in[4]");
    assert_eq!(display_output(&output, "out", 63), "in[4]");
}
