//! **Three-state synchronization search** (§1.3, Algorithm 6): Algorithm 5's search for an
//! explicit synchronization witness between two `tcgen05` operations.
//!
//! ```text
//! require: D, τ from Algorithm 5
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
//! 0 --source-thread before fence--> 1 --destination-thread after fence or mbarrier acquire--> 2
//! ```
//!
//! * `D` is [`ValidatedGraph`]'s explicit successor lists; `τ` is trace order, a topological
//!   order of `D` because every edge runs forward in the trace.
//! * `BEFOREONSOURCETHREAD(v, a)`: `v`, on the thread that issued `a`'s operation, is a
//!   `tcgen05.fence::before_thread_sync`, or a *tracking commit* supplying the before role: an
//!   arrival of that thread, after the issue, on an mbarrier phase that tracks the operation
//!   (`tcgen05.commit`). `AFTERONTARGETTHREAD(v, b)`: `v`, on the thread that issued `b`'s
//!   operation, is a `tcgen05.fence::after_thread_sync`. Every other vertex keeps the state.
//! * The path may instead step from an mbarrier phase's completion to that thread's release
//!   from it: the wait is an acquire, as lowering rejects `.relaxed`, and a release-acquire
//!   pair orders `tcgen05` ops without the after fence, which the PTX ISA's canonical pattern
//!   places only after a `.relaxed` wait (<https://github.com/NVIDIA/cutlass/issues/2974>). A
//!   release by any other synchronization (`bar.sync`) still needs the fence.
//! * The search accepts only at `t` in state 2. It checks the fence protocol along a path of
//!   `D`; synchronization and completion validation are the other passes' (§1.3).
//! * [`Origin`]: the design always starts at `Issue(Op(a))` in state 0, which only orders the
//!   issues. That suffices for a pipelinable pair, but any other pair needs the producer's
//!   completion observed first (PTX ISA 9.7.18.6.4.4), so its search starts at that completion.
//! * A visited `(v, s)` is never searched again: `SEARCH`'s answer depends on nothing else.

use std::collections::HashSet;

use volta_graph::{
    AsyncOpId, AsyncOpKind, ContributionKind, EventGraph, EventId, EventKind, FenceKind,
    GenerationKind,
};

use crate::relation::{Successors, ValidatedGraph};

/// The search's state: how much of the fence protocol the path has seen.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum SearchState {
    /// 0: no source-thread before fence yet.
    Unfenced,
    /// 1: the source thread fenced (or committed) before synchronizing.
    SourceFenced,
    /// 2: the destination thread fenced, or acquired an mbarrier phase, after synchronizing.
    TargetFenced,
}

/// `D` and `τ`, as Algorithm 5 hands them to the search.
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

/// The edge `v -> w` releases `target`'s issuer from the mbarrier phase `v` completes: an acquire
/// wait (lowering rejects `.relaxed`), whose release-acquire pair orders `tcgen05` ops without an
/// after fence (<https://github.com/NVIDIA/cutlass/issues/2974>).
pub fn acquired_on_target_thread(
    graph: &EventGraph,
    v: EventId,
    w: EventId,
    target: AsyncOpId,
) -> bool {
    let (EventKind::GenerationComplete(phase), EventKind::Resume(released_by)) =
        (graph.event(v).kind, graph.event(w).kind)
    else {
        return false;
    };

    phase == released_by
        && graph.generation(phase).kind == GenerationKind::MbarrierPhase
        && graph.thread_of(w) == Some(graph.async_op(target).issuer)
}

/// Where a witness path out of the source operation starts.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Origin {
    /// `Issue(source)` in state 0, as the design has it: the witness orders the two issues,
    /// which orders the Tensor Memory accesses of a pipelinable pair.
    Issue,
    /// `source`'s completion, so the path passes a release observing it. An MMA's tracking
    /// `tcgen05.commit` performs the before fence (PTX ISA 9.7.18.6.4.2), so its path starts in
    /// state 1; a `tcgen05.ld`/`.st` still needs one after its `tcgen05.wait`.
    Completion,
}

/// `SEARCH(u, s, Issue(target), a, b)` over `d`, from `origin`'s vertex `u` and state `s`; an
/// operation never completed has no completion origin.
pub fn search(d: &SearchGraph, source: AsyncOpId, target: AsyncOpId, origin: Origin) -> bool {
    let graph = d.graph;
    let op = graph.async_op(source);
    let start = match origin {
        Origin::Issue => (op.issue, SearchState::Unfenced),
        Origin::Completion => {
            let Some(done) = op.completion else {
                return false;
            };
            match op.kind {
                AsyncOpKind::Tcgen05Mma => (done, SearchState::SourceFenced),
                _ => (done, SearchState::Unfenced),
            }
        }
    };
    let t = graph.async_op(target).issue;
    let mut visited: HashSet<(EventId, SearchState)> = HashSet::new();
    let mut stack = vec![start];
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
            if w > t {
                continue;
            }

            let s = if s == SearchState::SourceFenced
                && acquired_on_target_thread(graph, v, w, target)
            {
                SearchState::TargetFenced
            } else {
                s
            };
            stack.push((w, s));
        }
    }
    false
}
