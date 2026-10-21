//! **Resource-lifetime checks** (§1.3, Algorithm 6, the design's proposal): every use of a
//! resource lies between its allocation and its deallocation in `G_HB`.
//!
//! ```text
//! B <- {}
//! phase 1: every use reaches its deallocation
//!   R <- TRANSITIVECLOSURE(G_HB)
//!   for all e in M: if (e, d_e) not in R then REPORT(B, e, use not ordered before deallocation)
//! phase 2: every use is reached from its allocation
//!   G_rev <- REVERSE(G_HB);  R_rev <- TRANSITIVECLOSURE(G_rev)
//!   for all e in M: if (e, a_e) not in R_rev then REPORT(B, e, allocation not ordered before use)
//! return B
//! ```
//!
//! * Resources: Tensor Memory allocations, the resources with allocation and deallocation
//!   events (`tcgen05.alloc` / `tcgen05.dealloc`); each allocation event is fresh, a
//!   re-allocation of the same columns included. Static shared and global memory have no such
//!   events in the trace. `M` here is `A`: every Tensor Memory effect, asynchronous ones at
//!   their effect events.
//! * Static trace: each effect `e` identifies its allocation `a_e`, the latest allocation before
//!   it in trace order overlapping its columns, which must cover its entire footprint; each
//!   allocation has exactly one deallocation `d_e` (the latest allocation overlapping a
//!   deallocation is the one it frees), which excludes double frees.
//! * `R` is [`ValidatedGraph`]'s closure; an async use reaches `d_e` only through a validated
//!   observation of its completion (every path out of an effect passes through one).
//!   `(e, a_e) ∈ R_rev` iff `(a_e, e) ∈ R`, so phase 2 asks the same sweep whether `a_e` reaches
//!   `e`.
//! * `Pass`: `B = {}` (vacuous without Tensor Memory). `Fail`: the static-trace violations,
//!   then phase 1's and phase 2's reports, each in trace order. `Unknown`: an allocation
//!   without a deallocation in an incomplete trace, whose deallocation may lie past its end.

use std::collections::HashMap;

use volta_graph::{AsyncOpId, EventId, EventKind, ExecContext, Footprint, Space, Terminal};

use crate::relation::{ValidatedGraph, thread_points};
use crate::result::{PropertyResult, Unresolved};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LifetimeViolation {
    /// The trace deallocates `alloc` more than once.
    DoubleFree {
        alloc: EventId,
        deallocs: Vec<EventId>,
    },
    /// The completed trace never deallocates `alloc`.
    NeverDeallocated { alloc: EventId },
    /// `dealloc` frees columns no earlier allocation provides.
    UnmatchedDeallocation { dealloc: EventId },
    /// No allocation covers `effect`'s entire footprint; `alloc` is the one overlapping it.
    Uncovered {
        effect: EventId,
        alloc: Option<EventId>,
    },
    /// Phase 1: `(e, d_e) ∉ R`.
    UseNotBeforeDeallocation {
        effect: EventId,
        alloc: EventId,
        dealloc: EventId,
    },
    /// Phase 2: `(e, a_e) ∉ R_rev`.
    AllocationNotBeforeUse { effect: EventId, alloc: EventId },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LifetimeEvidence {
    pub allocations: usize,
    /// `|M|`.
    pub uses: usize,
}

pub type LifetimeResult = PropertyResult<LifetimeEvidence, LifetimeViolation>;

/// One allocation of the static trace and the deallocations matched to it.
#[derive(Debug, Clone)]
struct Allocation {
    event: EventId,
    cols: (u32, u32),
    deallocs: Vec<EventId>,
}

/// One use with its allocation.
#[derive(Debug, Clone, Copy)]
struct Use {
    effect: EventId,
    op: AsyncOpId,
    alloc: usize,
}

fn overlaps((a, b): (u32, u32), (c, d): (u32, u32)) -> bool {
    a < d && c < b
}

pub fn check_resource_lifetimes(h: &ValidatedGraph) -> LifetimeResult {
    let graph = h.graph();
    let mut allocations: Vec<Allocation> = Vec::new();
    let mut uses: Vec<Use> = Vec::new();
    let mut static_violations = Vec::new();
    let latest_overlapping = |allocations: &[Allocation], cols: (u32, u32)| {
        allocations.iter().rposition(|a| overlaps(a.cols, cols))
    };
    for (id, ev) in graph.events().iter() {
        match ev.kind {
            EventKind::TmemAlloc {
                start_col,
                num_cols,
            } => allocations.push(Allocation {
                event: id,
                cols: (
                    u32::from(start_col),
                    u32::from(start_col) + u32::from(num_cols),
                ),
                deallocs: Vec::new(),
            }),
            EventKind::TmemDealloc {
                start_col,
                num_cols,
            } => {
                let cols = (
                    u32::from(start_col),
                    u32::from(start_col) + u32::from(num_cols),
                );
                match latest_overlapping(&allocations, cols) {
                    Some(i) => allocations[i].deallocs.push(id),
                    None => static_violations
                        .push(LifetimeViolation::UnmatchedDeallocation { dealloc: id }),
                }
            }
            EventKind::Access(acc) => {
                let access = graph.access(acc);
                let Footprint::Tensor { col, cols, .. } = access.footprint else {
                    continue;
                };
                if access.space != Space::Tensor {
                    continue;
                }
                let ExecContext::Async(op) = ev.ctx else {
                    continue;
                };
                let span = (u32::from(col), u32::from(col) + u32::from(cols));
                match latest_overlapping(&allocations, span) {
                    Some(i)
                        if allocations[i].cols.0 <= span.0 && span.1 <= allocations[i].cols.1 =>
                    {
                        uses.push(Use {
                            effect: id,
                            op,
                            alloc: i,
                        })
                    }
                    found => static_violations.push(LifetimeViolation::Uncovered {
                        effect: id,
                        alloc: found.map(|i| allocations[i].event),
                    }),
                }
            }
            _ => {}
        }
    }
    let mut unresolved = Vec::new();
    for a in &allocations {
        match a.deallocs.len() {
            1 => {}
            0 if *graph.terminal() == Terminal::Completed => {
                static_violations.push(LifetimeViolation::NeverDeallocated { alloc: a.event })
            }
            0 => unresolved.push(Unresolved::at(
                a.event,
                "the allocation is not deallocated within the incomplete trace",
            )),
            _ => static_violations.push(LifetimeViolation::DoubleFree {
                alloc: a.event,
                deallocs: a.deallocs.clone(),
            }),
        }
    }

    let points = thread_points(graph);
    let point = |e: EventId| points[e.0 as usize].expect("allocation events are thread events");
    let mut at_dealloc: HashMap<EventId, Vec<usize>> = HashMap::new();
    let mut at_use: HashMap<EventId, Vec<usize>> = HashMap::new();
    for (i, u) in uses.iter().enumerate() {
        at_use.entry(u.effect).or_default().push(i);
        if let [d] = allocations[u.alloc].deallocs[..] {
            at_dealloc.entry(d).or_default().push(i);
        }
    }
    let mut before_dealloc = vec![false; uses.len()];
    let mut after_alloc = vec![false; uses.len()];
    h.sweep(|e, view| {
        for &i in at_use.get(&e).map_or(&[][..], Vec::as_slice) {
            after_alloc[i] = view.thread_hb(point(allocations[uses[i].alloc].event));
        }
        for &i in at_dealloc.get(&e).map_or(&[][..], Vec::as_slice) {
            before_dealloc[i] = uses[i].effect < e && view.effects_hb(uses[i].op);
        }
    });

    let mut violations = static_violations;
    violations.sort_by_key(|v| match v {
        LifetimeViolation::DoubleFree { alloc, .. }
        | LifetimeViolation::NeverDeallocated { alloc } => *alloc,
        LifetimeViolation::UnmatchedDeallocation { dealloc } => *dealloc,
        LifetimeViolation::Uncovered { effect, .. }
        | LifetimeViolation::UseNotBeforeDeallocation { effect, .. }
        | LifetimeViolation::AllocationNotBeforeUse { effect, .. } => *effect,
    });
    for (i, u) in uses.iter().enumerate() {
        let alloc = &allocations[u.alloc];
        if let [dealloc] = alloc.deallocs[..]
            && !before_dealloc[i]
        {
            violations.push(LifetimeViolation::UseNotBeforeDeallocation {
                effect: u.effect,
                alloc: alloc.event,
                dealloc,
            });
        }
    }
    for (i, u) in uses.iter().enumerate() {
        if !after_alloc[i] {
            violations.push(LifetimeViolation::AllocationNotBeforeUse {
                effect: u.effect,
                alloc: allocations[u.alloc].event,
            });
        }
    }
    PropertyResult::from_findings(
        LifetimeEvidence {
            allocations: allocations.len(),
            uses: uses.len(),
        },
        violations,
        unresolved,
    )
}
