//! **Allocation-order check**, beyond the design's seven: the PTX ISA's `tcgen05.alloc` rule
//! that "the number of columns allocated should not increase between any two allocations in the
//! execution order within the CTA", over a total order of the allocations in `G_HB`.
//!
//! ```text
//! B <- {}
//! for all consecutive allocations (a, b) in trace order:
//!   if (a, b) not in R then REPORT(B, a, b, allocations unordered)
//!   else if cols(b) > cols(a) then REPORT(B, a, b, column count increases)
//! return B
//! ```
//!
//! * Allocations: the `tcgen05.alloc` events (`TmemAlloc`), each with its column count.
//! * `R` is [`ValidatedGraph`]'s closure. Its edges run forward in trace order, so the
//!   allocations are totally ordered iff each reaches the next, and that order is the trace's:
//!   checking consecutive pairs decides both the order and the rule.
//! * The total order is stricter than the ISA, which lets two allocations of one size come in
//!   either order: the columns the trace assigns them hold for its own order only.
//! * `Pass`: `B = {}` (vacuous with at most one allocation). `Fail`: `B`, in trace order. Never
//!   `Unknown`.

use std::collections::HashMap;

use volta_graph::{EventId, EventKind};

use crate::relation::{ValidatedGraph, thread_points};
use crate::result::PropertyResult;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AllocationOrderViolation {
    /// `later` follows `earlier` in the trace, but `earlier` does not reach it in `G_HB`: a
    /// schedule can run them the other way around.
    Unordered { earlier: EventId, later: EventId },
    /// `earlier` reaches `later`, which allocates more columns.
    IncreasingColumnCount {
        earlier: EventId,
        earlier_cols: u16,
        later: EventId,
        later_cols: u16,
    },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AllocationOrderEvidence {
    pub allocations: usize,
}

pub type AllocationOrderResult = PropertyResult<AllocationOrderEvidence, AllocationOrderViolation>;

pub fn check_allocation_order(h: &ValidatedGraph) -> AllocationOrderResult {
    let graph = h.graph();
    let allocations: Vec<(EventId, u16)> = graph
        .events()
        .iter()
        .filter_map(|(id, ev)| match ev.kind {
            EventKind::TmemAlloc { num_cols, .. } => Some((id, num_cols)),
            _ => None,
        })
        .collect();
    let position: HashMap<EventId, usize> = allocations
        .iter()
        .enumerate()
        .map(|(i, &(e, _))| (e, i))
        .collect();
    let points = thread_points(graph);
    let point = |e: EventId| points[e.0 as usize].expect("allocation events are thread events");
    let mut reached_by_previous = vec![true; allocations.len()];
    h.sweep(|e, view| {
        if let Some(&i) = position.get(&e)
            && i > 0
        {
            reached_by_previous[i] = view.thread_hb(point(allocations[i - 1].0));
        }
    });

    let mut violations = Vec::new();
    for (i, pair) in allocations.windows(2).enumerate() {
        let [(earlier, earlier_cols), (later, later_cols)] = *pair else {
            unreachable!("windows of two")
        };
        if !reached_by_previous[i + 1] {
            violations.push(AllocationOrderViolation::Unordered { earlier, later });
        } else if later_cols > earlier_cols {
            violations.push(AllocationOrderViolation::IncreasingColumnCount {
                earlier,
                earlier_cols,
                later,
                later_cols,
            });
        }
    }
    PropertyResult::from_findings(
        AllocationOrderEvidence {
            allocations: allocations.len(),
        },
        violations,
        Vec::new(),
    )
}
