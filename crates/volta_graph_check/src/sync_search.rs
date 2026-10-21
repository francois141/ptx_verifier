//! **Three-state synchronization search** (§1.3, Algorithm 5): Algorithm 4's search for an
//! explicit synchronization witness between two `tcgen05` operations.
//!
//! ```text
//! require: D, τ from Algorithm 4
//! function SEARCH(v, s, t, a, b):
//!     if s = 0 and BEFOREONSOURCETHREAD(v, a) then s <- 1
//!     else if s = 1 and AFTERONTARGETTHREAD(v, b) then s <- 2
//!     if v = t then return s = 2
//!     for all w in Succ_D(v) with τ(w) <= τ(t):
//!         if SEARCH(w, s, t, a, b) then return true
//!     return false
//! ```
//!
//! ```text
//! 0 --source-thread before fence--> 1 --destination-thread after fence--> 2
//! ```
//!
//! * `D` is [`ValidatedGraph`]'s explicit successor lists; `τ` is trace order, a topological
//!   order of `D` because every edge runs forward in the trace.
//! * `BEFOREONSOURCETHREAD(v, a)`: `v`, on the thread that issued `a`'s operation, is a
//!   `tcgen05.fence::before_thread_sync`, or a *tracking commit* supplying the before role: an
//!   arrival of that thread, after the issue, on an mbarrier phase that tracks the operation
//!   (`tcgen05.commit`). `AFTERONTARGETTHREAD(v, b)`: `v`, on the thread that issued `b`'s
//!   operation, is a `tcgen05.fence::after_thread_sync`. Every other vertex keeps the state.
//! * The search accepts only at `t` in state 2. It checks the fence protocol along a path of
//!   `D`; synchronization and completion validation are the other passes' (§1.3).
//! * A visited `(v, s)` is never searched again: `SEARCH`'s answer depends on nothing else.

use std::collections::HashSet;

use volta_graph::{
    AsyncOpId, ContributionKind, EventGraph, EventId, EventKind, FenceKind, GenerationKind,
};

use crate::relation::{Successors, ValidatedGraph};

/// The search's state: how much of the fence protocol the path has seen.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum SearchState {
    /// 0: no source-thread before fence yet.
    Unfenced,
    /// 1: the source thread fenced (or committed) before synchronizing.
    SourceFenced,
    /// 2: the destination thread fenced after synchronizing.
    TargetFenced,
}

/// `D` and `τ`, as Algorithm 4 hands them to the search.
pub struct SearchGraph<'g> {
    graph: &'g EventGraph,
    successors: Successors,
}

impl<'g> SearchGraph<'g> {
    pub fn new(d: &ValidatedGraph<'g>) -> Self {
        SearchGraph {
            graph: d.graph(),
            successors: d.successors(),
        }
    }

    pub fn graph(&self) -> &'g EventGraph {
        self.graph
    }
}

/// `BEFOREONSOURCETHREAD(v, a)` for `a` an effect of `source`.
pub fn before_on_source_thread(graph: &EventGraph, v: EventId, source: AsyncOpId) -> bool {
    let op = graph.async_op(source);
    if graph.thread_of(v) != Some(op.issuer) {
        return false;
    }
    match graph.event(v).kind {
        EventKind::Fence(FenceKind::Tcgen05BeforeThreadSync) => true,
        EventKind::Contribute(g) => {
            v > op.issue
                && op.tracking.contains(&g)
                && graph.generation(g).kind == GenerationKind::MbarrierPhase
                && graph
                    .generation(g)
                    .contributions
                    .iter()
                    .any(|c| c.event == v && matches!(c.kind, ContributionKind::Arrival { .. }))
        }
        _ => false,
    }
}

/// `AFTERONTARGETTHREAD(v, b)` for `b` an effect of `target`.
pub fn after_on_target_thread(graph: &EventGraph, v: EventId, target: AsyncOpId) -> bool {
    graph.thread_of(v) == Some(graph.async_op(target).issuer)
        && graph.event(v).kind == EventKind::Fence(FenceKind::Tcgen05AfterThreadSync)
}

/// `SEARCH(Issue(source), 0, Issue(target), a, b)` over `d`.
pub fn search(d: &SearchGraph, source: AsyncOpId, target: AsyncOpId) -> bool {
    let graph = d.graph;
    let u = graph.async_op(source).issue;
    let t = graph.async_op(target).issue;
    let mut visited: HashSet<(EventId, SearchState)> = HashSet::new();
    let mut stack = vec![(u, SearchState::Unfenced)];
    while let Some((v, s)) = stack.pop() {
        if !visited.insert((v, s)) {
            continue;
        }
        let s = match s {
            SearchState::Unfenced if before_on_source_thread(graph, v, source) => {
                SearchState::SourceFenced
            }
            SearchState::SourceFenced if after_on_target_thread(graph, v, target) => {
                SearchState::TargetFenced
            }
            s => s,
        };
        if v == t {
            if s == SearchState::TargetFenced {
                return true;
            }
            continue;
        }
        for &w in d.successors.of(v) {
            if w <= t {
                stack.push((w, s));
            }
        }
    }
    false
}
