//! **Allocation-permit check**, beyond the design's seven: the PTX ISA's
//! `tcgen05.relinquish_alloc_permit` rule that "it is illegal for a CTA to perform
//! `tcgen05.alloc` after any of its constituent warps have executed
//! `tcgen05.relinquish_alloc_permit`", over `G_HB`.
//!
//! ```text
//! B <- {}
//! for all relinquishes r, in trace order:
//!   for all allocations a, in trace order:
//!     if (a, r) not in R then REPORT(B, a, r)
//! return B
//! ```
//!
//! * Allocations: the `tcgen05.alloc` events (`TmemAlloc`). Relinquishes: the
//!   `tcgen05.relinquish_alloc_permit` events (`TmemRelinquish`).
//! * `R` is [`ValidatedGraph`]'s closure: an allocation it does not order before a relinquish
//!   runs after it in some schedule. Its edges run forward in trace order, so an allocation the
//!   trace runs after a relinquish is reported too.
//! * `Pass`: `B = {}` (vacuous without a relinquish). `Fail`: `B`, by relinquish, then by
//!   allocation, in trace order. Never `Unknown`.

use volta_graph::{EventId, EventKind};

use crate::relation::{ValidatedGraph, thread_points};
use crate::result::PropertyResult;

/// `allocation` does not reach `relinquish` in `G_HB`: a schedule can relinquish the CTA's
/// permit first, then allocate.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct AllocationPermitViolation {
    pub allocation: EventId,
    pub relinquish: EventId,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct AllocationPermitEvidence {
    pub allocations: usize,
    pub relinquishes: usize,
}

pub type AllocationPermitResult =
    PropertyResult<AllocationPermitEvidence, AllocationPermitViolation>;

pub fn check_allocation_permit(h: &ValidatedGraph) -> AllocationPermitResult {
    let graph = h.graph();
    let allocations: Vec<EventId> = graph
        .events()
        .iter()
        .filter(|(_, ev)| matches!(ev.kind, EventKind::TmemAlloc { .. }))
        .map(|(id, _)| id)
        .collect();
    let points = thread_points(graph);
    let point = |e: EventId| points[e.0 as usize].expect("allocation events are thread events");
    let mut relinquishes = 0;
    let mut violations = Vec::new();
    h.sweep(|e, view| {
        if graph.event(e).kind == EventKind::TmemRelinquish {
            relinquishes += 1;
            violations.extend(
                allocations
                    .iter()
                    .filter(|&&a| !view.thread_hb(point(a)))
                    .map(|&allocation| AllocationPermitViolation {
                        allocation,
                        relinquish: e,
                    }),
            );
        }
    });
    PropertyResult::from_findings(
        AllocationPermitEvidence {
            allocations: allocations.len(),
            relinquishes,
        },
        violations,
        Vec::new(),
    )
}
