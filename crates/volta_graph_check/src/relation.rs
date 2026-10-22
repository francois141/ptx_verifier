//! The typed candidate graph and its composable projections (§1.2, "Edge types and
//! validation"): `E = E_PO ∪ E_causal ∪ E_pipeline ∪ E_sync`, never used untyped.
//!
//! * `E_PO`: each thread's events in program order.
//! * `E_causal`: an asynchronous operation's issue before its effects and its effects before
//!   its completion (`Issue(o) -> Effects(o) -> Complete(o)`); the issuer's program order
//!   continues from the issue, so nothing orders the effects before the issuer's later events.
//! * `E_sync`: each generation's joins: a thread contribution (`Blocking`, `Arrival`, and an
//!   exit only under the Sync' assumption, `Assumption::ExitedThreadsArrive`) or a tracked
//!   async completion before the generation completes, the completion before each release.
//!   A relaxed `expect_tx` or `complete_tx` joins nothing, and neither do the members of a
//!   collective other than `bar.warp.sync` (`MemberOrdering::ExecutionOnly`): only its tracked
//!   async completions join it.
//! * `E_pipeline`: [`crate::pipeline`]. No projection here contains it.
//!
//! Projections:
//!
//! * [`IndependentGraph`] (`G0`, the barrier-epoch checks' input): `E_PO ∪ E_causal` and every
//!   thread join of the candidate execution, which Weft's separation criterion, as the design
//!   applies it, orders the next generation's operations through. It excludes the
//!   associations still under verification, the async completions joined into mbarrier
//!   phases ("this candidate join becomes ordering evidence only after the barrier-epoch check
//!   validates the phase association"); completions joined into a warp's wait collective or a
//!   thread's `cp.async` wait-group are independently fixed by that warp's or thread's program
//!   order.
//! * [`ValidatedGraph`] (`G_HB`, and Algorithm 5's `D`): `G0` plus the validated mbarrier
//!   completion joins. Only the two barrier-epoch certificates and the mbarrier ordering
//!   certificate construct it ("accept completion joins only after epoch separation and this
//!   check pass"). With one CTA and
//!   no memory scope narrower than it, the happens-before projection keeps every such edge.
//!
//! Transitive-closure queries (`(x, y) ∈ G+`) are answered by one vector-clock sweep in trace
//! order, which is a topological order because every edge runs forward in the trace. A thread
//! event `(t, i)` reaches the visited event when its clock has `c[t] >= i`; an async effect
//! reaches it when one of its operation's *observers* (a release of a generation that joins the
//! operation's completion) does, since every path out of an effect passes through one.

use std::collections::HashMap;

use volta_graph::{
    AsyncOpId, ContributionKind, EventGraph, EventId, EventKind, ExecContext, GenerationId,
    GenerationKind, GraphDefect, MemberOrdering,
};

use crate::barrier_epoch::{MbarrierEpochs, NamedBarrierEpochs};
use crate::mbarrier_ordering::MbarrierOrdering;

/// Which synchronization edges a projection admits.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Admission {
    mbarrier_completions: bool,
    exited_threads: bool,
}

impl Admission {
    fn of(graph: &EventGraph, mbarrier_completions: bool) -> Self {
        Admission {
            mbarrier_completions,
            exited_threads: graph
                .provenance()
                .assumes(volta_graph::Assumption::ExitedThreadsArrive),
        }
    }

    /// Whether `kind`, a contribution to `generation`, joins it.
    fn joins(self, graph: &EventGraph, generation: GenerationId, kind: ContributionKind) -> bool {
        let members_join = !matches!(
            graph.generation(generation).kind,
            GenerationKind::Collective {
                ordering: MemberOrdering::ExecutionOnly,
                ..
            }
        );
        match kind {
            ContributionKind::Blocking | ContributionKind::Arrival { .. } => members_join,
            ContributionKind::Exited => self.exited_threads && members_join,
            ContributionKind::AsyncCompletion { .. } => {
                self.mbarrier_completions
                    || graph.generation(generation).kind != GenerationKind::MbarrierPhase
            }
            ContributionKind::CompleteTx { .. } | ContributionKind::ExpectTx { .. } => false,
        }
    }
}

/// `G0`: program order, causal edges and the independently justified synchronization edges.
#[derive(Debug, Clone, Copy)]
pub struct IndependentGraph<'g> {
    graph: &'g EventGraph,
    admission: Admission,
}

impl<'g> IndependentGraph<'g> {
    /// `G0` of a graph that satisfies its representation invariants.
    pub fn new(graph: &'g EventGraph) -> Result<Self, Vec<GraphDefect>> {
        graph.validate()?;
        Ok(IndependentGraph {
            graph,
            admission: Admission::of(graph, false),
        })
    }

    pub fn graph(&self) -> &'g EventGraph {
        self.graph
    }

    /// One trace-order pass over `G0+`, handing each event and its view to `visit`.
    pub fn sweep(&self, visit: impl FnMut(EventId, &HbView)) {
        sweep(self.graph, self.admission, visit);
    }
}

/// `G_HB` (= `D`): `G0` plus the candidate joins both barrier-epoch checks validated.
#[derive(Debug, Clone, Copy)]
pub struct ValidatedGraph<'g> {
    graph: &'g EventGraph,
    admission: Admission,
}

impl<'g> ValidatedGraph<'g> {
    /// The validated graph both barrier-epoch checks and the mbarrier ordering check
    /// certified.
    pub fn from_certificates(
        named: NamedBarrierEpochs<'g>,
        mbarrier: MbarrierEpochs<'g>,
        ordering: MbarrierOrdering<'g>,
    ) -> Self {
        let graph = named.graph();
        assert!(
            std::ptr::eq(graph, mbarrier.graph()) && std::ptr::eq(graph, ordering.graph()),
            "the certificates are for different graphs"
        );
        ValidatedGraph {
            graph,
            admission: Admission::of(graph, true),
        }
    }

    /// The validated graph under the caller's assertion that both barrier-epoch checks and the
    /// mbarrier ordering check passed, for running a later check in isolation.
    pub fn assuming_epochs(graph: &'g EventGraph) -> Result<Self, Vec<GraphDefect>> {
        graph.validate()?;
        Ok(ValidatedGraph {
            graph,
            admission: Admission::of(graph, true),
        })
    }

    pub fn graph(&self) -> &'g EventGraph {
        self.graph
    }

    /// One trace-order pass over `G_HB+`, handing each event and its view to `visit`.
    pub fn sweep(&self, visit: impl FnMut(EventId, &HbView)) {
        sweep(self.graph, self.admission, visit);
    }

    /// `D`'s edges as explicit successor lists, for Algorithm 6's search.
    pub fn successors(&self) -> Successors {
        successors(self.graph, self.admission)
    }
}

/// A thread event's position: thread and 1-based program-order index.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct ThreadPoint {
    pub thread: volta_graph::ThreadIx,
    pub index: u32,
}

/// The ordering point of the event being visited.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Point {
    /// A thread event.
    Thread(ThreadPoint),
    /// An effect or the completion of an async op (ordered after its issue only).
    Async(AsyncOpId),
    /// A generation completion.
    Generation(GenerationId),
}

/// The sweep's knowledge at the visited event: which events reach it.
pub struct HbView<'s> {
    point: Point,
    clock: &'s [u32],
    state: &'s SweepState,
}

impl HbView<'_> {
    pub fn point(&self) -> Point {
        self.point
    }

    /// The visited event's clock: per thread, the last of its events that reaches it.
    pub fn clock(&self) -> &[u32] {
        self.clock
    }

    /// Whether thread event `a` reaches the visited event, non-strictly: a thread's visited
    /// event is reached by itself.
    pub fn thread_hb(&self, a: ThreadPoint) -> bool {
        self.clock[a.thread.0 as usize] >= a.index
    }

    /// Whether the effects of `op` reach the visited event: one of its observers does.
    pub fn effects_hb(&self, op: AsyncOpId) -> bool {
        self.observers(op).iter().any(|&p| self.thread_hb(p))
    }

    /// The releases, recorded so far, of generations that join `op`'s completion.
    pub fn observers(&self, op: AsyncOpId) -> &[ThreadPoint] {
        self.state.observers.get(&op).map_or(&[], Vec::as_slice)
    }
}

#[derive(Debug, Default)]
struct SweepState {
    observers: HashMap<AsyncOpId, Vec<ThreadPoint>>,
}

fn sweep(graph: &EventGraph, admission: Admission, mut visit: impl FnMut(EventId, &HbView)) {
    let n = graph.threads() as usize;
    let mut clocks: Vec<Vec<u32>> = vec![vec![0; n]; n];
    let mut index = vec![0u32; n];
    let mut generation_clock: HashMap<GenerationId, Vec<u32>> = HashMap::new();
    let mut issue_clock: HashMap<AsyncOpId, Vec<u32>> = HashMap::new();
    let mut state = SweepState::default();

    let mut thread_joins: HashMap<EventId, GenerationId> = HashMap::new();
    let mut joined_ops: HashMap<GenerationId, Vec<AsyncOpId>> = HashMap::new();
    let mut unreleased: HashMap<GenerationId, usize> = HashMap::new();
    for (g, generation) in graph.generations().iter() {
        unreleased.insert(g, generation.releases.len());
        for c in &generation.contributions {
            if !admission.joins(graph, g, c.kind) {
                continue;
            }
            match c.kind {
                ContributionKind::AsyncCompletion { op, .. } => {
                    joined_ops.entry(g).or_default().push(op);
                }
                ContributionKind::Blocking | ContributionKind::Arrival { .. } => {
                    thread_joins.insert(c.event, g);
                }
                ContributionKind::Exited
                | ContributionKind::CompleteTx { .. }
                | ContributionKind::ExpectTx { .. } => {}
            }
        }
    }

    let join = |into: &mut Vec<u32>, from: &[u32]| {
        for (a, &b) in into.iter_mut().zip(from) {
            *a = (*a).max(b);
        }
    };
    let empty = vec![0; n];

    for (id, ev) in graph.events().iter() {
        match ev.ctx {
            ExecContext::Thread(t) => {
                let ti = t.0 as usize;
                index[ti] += 1;
                clocks[ti][ti] = index[ti];
                match ev.kind {
                    EventKind::Contribute(g) if thread_joins.get(&id) == Some(&g) => {
                        let acc = generation_clock.entry(g).or_insert_with(|| vec![0; n]);
                        join(acc, &clocks[ti]);
                    }
                    EventKind::Resume(g) => {
                        let left = unreleased.get_mut(&g).expect("a release of a generation");
                        *left -= 1;
                        let gc = if *left == 0 {
                            generation_clock.remove(&g)
                        } else {
                            generation_clock.get(&g).cloned()
                        };
                        if let Some(gc) = gc {
                            join(&mut clocks[ti], &gc);
                        }
                        let p = ThreadPoint {
                            thread: t,
                            index: index[ti],
                        };
                        for &op in joined_ops.get(&g).map_or(&[][..], Vec::as_slice) {
                            state.observers.entry(op).or_default().push(p);
                        }
                    }
                    EventKind::AsyncIssue(op) => {
                        issue_clock.insert(op, clocks[ti].clone());
                    }
                    _ => {}
                }
                let view = HbView {
                    point: Point::Thread(ThreadPoint {
                        thread: t,
                        index: index[ti],
                    }),
                    clock: &clocks[ti],
                    state: &state,
                };
                visit(id, &view);
            }
            ExecContext::Async(op) => {
                let view = HbView {
                    point: Point::Async(op),
                    clock: issue_clock.get(&op).unwrap_or(&empty),
                    state: &state,
                };
                visit(id, &view);
            }
            ExecContext::Generation(g) => {
                let mut acc = generation_clock.remove(&g).unwrap_or_else(|| vec![0; n]);
                for c in &graph.generation(g).contributions {
                    if !admission.joins(graph, g, c.kind) {
                        continue;
                    }
                    match c.kind {
                        ContributionKind::Exited => {
                            if let Some(t) = graph.thread_of(c.event) {
                                join(&mut acc, &clocks[t.0 as usize]);
                            }
                        }
                        ContributionKind::AsyncCompletion { op, .. } => {
                            if let Some(ic) = issue_clock.get(&op) {
                                join(&mut acc, ic);
                            }
                        }
                        _ => {}
                    }
                }
                let view = HbView {
                    point: Point::Generation(g),
                    clock: &acc,
                    state: &state,
                };
                visit(id, &view);
                generation_clock.insert(g, acc);
            }
        }
    }
}

/// Each thread event's [`ThreadPoint`], indexed by event (`None` for other contexts).
pub fn thread_points(graph: &EventGraph) -> Vec<Option<ThreadPoint>> {
    let mut index = vec![0u32; graph.threads() as usize];
    graph
        .events()
        .values()
        .map(|ev| match ev.ctx {
            ExecContext::Thread(t) => {
                index[t.0 as usize] += 1;
                Some(ThreadPoint {
                    thread: t,
                    index: index[t.0 as usize],
                })
            }
            _ => None,
        })
        .collect()
}

/// A projection's edges as successor lists over events.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Successors {
    succ: Vec<Vec<EventId>>,
}

impl Successors {
    /// The events `v` has an edge to, in trace order.
    pub fn of(&self, v: EventId) -> &[EventId] {
        &self.succ[v.0 as usize]
    }
}

fn successors(graph: &EventGraph, admission: Admission) -> Successors {
    let mut succ: Vec<Vec<EventId>> = vec![Vec::new(); graph.events().len()];
    for t in 0..graph.threads() {
        for pair in graph.program_order(volta_graph::ThreadIx(t)).windows(2) {
            succ[pair[0].0 as usize].push(pair[1]);
        }
    }
    let mut effect_events: HashMap<AsyncOpId, Vec<EventId>> = HashMap::new();
    for (id, ev) in graph.events().iter() {
        if let (ExecContext::Async(op), EventKind::Access(_)) = (ev.ctx, ev.kind) {
            effect_events.entry(op).or_default().push(id);
        }
    }
    for (op, a) in graph.async_ops().iter() {
        let effects = effect_events.get(&op).map_or(&[][..], Vec::as_slice);
        for &e in effects {
            succ[a.issue.0 as usize].push(e);
            if let Some(done) = a.completion {
                succ[e.0 as usize].push(done);
            }
        }
        if let (Some(done), true) = (a.completion, effects.is_empty()) {
            succ[a.issue.0 as usize].push(done);
        }
    }
    for (g, generation) in graph.generations().iter() {
        let Some(done) = generation.completion else {
            continue;
        };
        for c in &generation.contributions {
            if admission.joins(graph, g, c.kind) {
                succ[c.event.0 as usize].push(done);
            }
        }
        for &r in &generation.releases {
            succ[done.0 as usize].push(r);
        }
    }
    for list in &mut succ {
        list.sort_unstable();
        list.dedup();
    }
    Successors { succ }
}
