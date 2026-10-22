//! **Tensor-operation ordering** (§1.3, Algorithm 5): every conflicting pair of Tensor Memory
//! effects of `tcgen05` operations is pipelined, or synchronized by the `tcgen05` fence
//! protocol (Algorithm 6).
//!
//! ```text
//! require: TMEM effects A; validated acyclic event graph D
//! τ <- TOPOLOGICALSORT(D);  B <- {}
//! for all {a, b} in Conflicts(A):
//!     (a, b) <- EARLIERISSUEFIRST(a, b, τ)
//!     if PIPELINED(a, b) then continue
//!     t <- Issue(Op(b))
//!     if PIPELINABLE(a, b) and SEARCH(Issue(Op(a)), 0, t, a, b) then continue
//!     s <- 1 if Op(a) is an MMA else 0
//!     if not SEARCH(Complete(Op(a)), s, t, a, b) then B <- B ∪ {{a, b}}
//! return B
//! ```
//!
//! * `A` ([`crate::domain`]): the Tensor Memory effects of `tcgen05.mma`, `.ld` and `.st`;
//!   shared-memory `tcgen05` effects are Algorithm 3's. `Conflicts(A)` pairs overlapping
//!   effects (lane x column rectangles) of distinct operations with at least one write.
//! * `D` is [`ValidatedGraph`], without pipeline edges; `τ` is trace order. Orienting a pair
//!   by its issue events selects a direction, not an ordering proof.
//! * `PIPELINED(a, b)`: `(a, b) ∈ E_pipeline` ([`crate::pipeline`]), whose rule covers the pair's
//!   opcodes, operand roles, warp, CTA group, address, shape and issue order over the whole
//!   shared footprint: same-thread MMA accumulator chains, and same-warp `tcgen05.st`/`.ld`
//!   pairs with the earlier one's `tcgen05.wait` in between.
//! * `PIPELINABLE(a, b)`: [`crate::pipeline::pipelinable`], a pair the ISA pipelines within one
//!   warp. Only such a pair may be ordered by its issues (9.7.18.6.4.3); the design searches
//!   every pair from `Issue(Op(a))`, but any other pair is ordered only once `Op(a)`'s completion
//!   is observed (9.7.18.6.4.4), so its search starts there ([`Origin::Completion`]). That
//!   stronger witness orders a pipelinable pair too.
//! * `SEARCH` is [`crate::sync_search::search`], run once per pair of operations and origin.
//! * `Pass`: `B = {}`. `Fail`: `B`, each pair with its first shared cell, ordered by the later
//!   issue (at most [`CONFLICT_CAP`] pairs are listed). `Unknown`: a Tensor Memory effect of
//!   an operation no modeled rule covers.

use std::collections::HashMap;

use volta_graph::{AccessMode, AsyncOpId};

use crate::domain::{ConflictKind, TmemCell, TmemEffect, first_shared_cell, tensor_effects};
use crate::memory_conflict::CONFLICT_CAP;
use crate::pipeline::{pipelinable, pipeline_edges};
use crate::relation::ValidatedGraph;
use crate::result::{PropertyResult, Unresolved};
use crate::sync_search::{Origin, SearchGraph, search};

/// One pair of `B`: `earlier` is the effect whose operation issued first.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TensorConflict {
    pub kind: ConflictKind,
    pub cell: TmemCell,
    pub earlier: volta_graph::EventId,
    pub later: volta_graph::EventId,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TensorOrderEvidence {
    /// `|Conflicts(A)|`.
    pub conflicts: u64,
    /// Pairs `PIPELINED` covers.
    pub pipelined: u64,
    /// Pairs a synchronization witness orders.
    pub synchronized: u64,
}

pub type TensorOrderResult = PropertyResult<TensorOrderEvidence, TensorConflict>;

pub fn check_tensor_order(d: &ValidatedGraph) -> TensorOrderResult {
    let graph = d.graph();
    let (mut a, unsupported) = tensor_effects(graph);
    let unresolved: Vec<Unresolved> = unsupported
        .into_iter()
        .map(|e| {
            Unresolved::at(
                e,
                "a Tensor Memory effect of an operation no modeled tcgen05 rule covers",
            )
        })
        .collect();

    let reads = |e: &TmemEffect| e.access.mode == AccessMode::Read;
    let issue = |e: &TmemEffect| graph.async_op(e.op).issue;
    a.sort_by_key(|x| (x.rectangle().1.0, x.event));
    let mut conflicts: Vec<(TmemEffect, TmemEffect, TmemCell)> = Vec::new();
    for (i, x) in a.iter().enumerate() {
        let col_end = x.rectangle().1.1;
        for y in &a[i + 1..] {
            if y.rectangle().1.0 >= col_end {
                break;
            }
            if x.op == y.op || (reads(x) && reads(y)) {
                continue;
            }
            if let Some(cell) = first_shared_cell(x.rectangle(), y.rectangle()) {
                let (earlier, later) = if issue(x) < issue(y) {
                    (*x, *y)
                } else {
                    (*y, *x)
                };
                conflicts.push((earlier, later, cell));
            }
        }
    }

    let pipeline = pipeline_edges(graph);
    let search_graph = SearchGraph::new(d);
    let mut searched: HashMap<(AsyncOpId, AsyncOpId, Origin), bool> = HashMap::new();
    let mut evidence = TensorOrderEvidence {
        conflicts: conflicts.len() as u64,
        pipelined: 0,
        synchronized: 0,
    };
    let mut unproved = Vec::new();
    for (earlier, later, cell) in conflicts {
        if pipeline.edge(graph, earlier.event, later.event).is_some() {
            evidence.pipelined += 1;
            continue;
        }
        let mut ordered_from = |origin| {
            *searched
                .entry((earlier.op, later.op, origin))
                .or_insert_with(|| search(&search_graph, earlier.op, later.op, origin))
        };
        let ordered = (pipelinable(graph, earlier.event, later.event)
            && ordered_from(Origin::Issue))
            || ordered_from(Origin::Completion);
        if ordered {
            evidence.synchronized += 1;
        } else {
            let conflict = TensorConflict {
                kind: ConflictKind::of(earlier.access.mode, later.access.mode)
                    .expect("a conflict has a write"),
                cell,
                earlier: earlier.event,
                later: later.event,
            };
            unproved.push((issue(&later), conflict));
        }
    }
    unproved.sort_by_key(|&(issued, c)| (issued, c.later, c.earlier));
    let unproved: Vec<TensorConflict> = unproved
        .into_iter()
        .take(CONFLICT_CAP)
        .map(|(_, c)| c)
        .collect();
    PropertyResult::from_findings(evidence, unproved, unresolved)
}
