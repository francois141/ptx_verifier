//! Happens-before over a graph's typed edges, computed by a vector-clock sweep in trace order.
//!
//! A derived view, not a checker: it orders events only through the edge kinds an
//! [`Admission`] admits, so it certifies nothing by itself. Admitted edges:
//!
//! * program order within a thread (always);
//! * contribution -> generation completion -> release, for admitted generations, where the
//!   contribution is `Blocking`, an `Arrival`, an `Exited` thread (only when exited-thread
//!   arrival is admitted) or an `AsyncCompletion` of an op whose completion is admitted;
//!   `CompleteTx` (`.relaxed`) orders nothing;
//! * spawn: an async op's effects are ordered after everything before its issue;
//! * completion: an admitted op's effects are ordered before every release of the admitted
//!   generations tracking it (those releases are the op's *observers*).
//!
//! Clocks count each thread's events from 1 in program order (0 = nothing known), so a thread
//! event `(p, i)` happens before a point whose clock has `c[p] >= i`.

use std::collections::{HashMap, HashSet};

use volta_graph::{
    AsyncOpId, ContributionKind, EventGraph, EventId, EventKind, ExecContext, GenerationId,
    ThreadIx,
};

/// The subset of identities whose edges a caller has validated.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Validated<I: std::hash::Hash + Eq> {
    All,
    Only(HashSet<I>),
}

impl<I: std::hash::Hash + Eq> Validated<I> {
    pub fn none() -> Self {
        Validated::Only(HashSet::new())
    }

    pub fn contains(&self, id: &I) -> bool {
        match self {
            Validated::All => true,
            Validated::Only(set) => set.contains(id),
        }
    }

    pub fn is_all(&self) -> bool {
        matches!(self, Validated::All)
    }
}

/// Which edges may order events.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Admission {
    pub generations: Validated<GenerationId>,
    pub completions: Validated<AsyncOpId>,
    /// Exited threads' contributions (the paper's Sync' rule, an explicit model assumption).
    pub exited_threads: bool,
}

impl Admission {
    /// Every candidate edge of the trace, unvalidated (what the execution actually did).
    pub fn candidate() -> Self {
        Admission {
            generations: Validated::All,
            completions: Validated::All,
            exited_threads: true,
        }
    }
}

/// A thread event's position: thread and 1-based program-order index.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct ThreadPoint {
    pub thread: ThreadIx,
    pub index: u32,
}

/// The ordering point of the event being visited.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Point {
    /// A thread event.
    Thread(ThreadPoint),
    /// An effect of an async op (ordered after its issue only).
    Effect(AsyncOpId),
    /// A generation completion.
    Generation(GenerationId),
}

/// The sweep's knowledge at the visited event; queries ask whether something happens before it.
pub struct HbView<'s> {
    point: Point,
    clock: &'s [u32],
    state: &'s SweepState,
}

impl HbView<'_> {
    pub fn point(&self) -> Point {
        self.point
    }

    /// The visited event's clock: per thread, the last of its events ordered before it.
    pub fn clock(&self) -> &[u32] {
        self.clock
    }

    /// Whether thread event `a` happens before the visited event (non-strict: a thread's
    /// visited event is ordered after itself).
    pub fn thread_hb(&self, a: ThreadPoint) -> bool {
        self.clock[a.thread.0 as usize] >= a.index
    }

    /// Whether `op`'s effects happen before the visited event: some observer of its admitted
    /// completion does.
    pub fn effects_hb(&self, op: AsyncOpId) -> bool {
        self.state
            .observers
            .get(&op)
            .is_some_and(|obs| obs.iter().any(|&p| self.thread_hb(p)))
    }

    /// Whether admitted generation `g`'s completion happens before the visited event: one of
    /// its releases does.
    pub fn generation_hb(&self, g: GenerationId) -> bool {
        self.state
            .releases
            .get(&g)
            .is_some_and(|rel| rel.iter().any(|&p| self.thread_hb(p)))
    }

    /// The observers of `op`'s completion released so far.
    pub fn observers(&self, op: AsyncOpId) -> &[ThreadPoint] {
        self.state.observers.get(&op).map_or(&[], Vec::as_slice)
    }
}

#[derive(Debug, Default)]
struct SweepState {
    observers: HashMap<AsyncOpId, Vec<ThreadPoint>>,
    releases: HashMap<GenerationId, Vec<ThreadPoint>>,
}

/// One trace-order pass computing happens-before through admitted edges, handing each event
/// with its [`HbView`] to `visit`.
pub fn sweep(graph: &EventGraph, admission: &Admission, mut visit: impl FnMut(EventId, &HbView)) {
    let n = graph.threads() as usize;
    let mut clocks: Vec<Vec<u32>> = vec![vec![0; n]; n];
    let mut index = vec![0u32; n];
    let mut generation_clock: HashMap<GenerationId, Vec<u32>> = HashMap::new();
    let mut issue_clock: HashMap<AsyncOpId, Vec<u32>> = HashMap::new();
    let mut state = SweepState::default();

    let mut contribution_of: HashMap<EventId, ContributionKind> = HashMap::new();
    let mut tracked_ops: HashMap<GenerationId, Vec<AsyncOpId>> = HashMap::new();
    let mut unreleased: HashMap<GenerationId, usize> = HashMap::new();
    for (g, generation) in graph.generations().iter() {
        if !admission.generations.contains(&g) {
            continue;
        }
        unreleased.insert(g, generation.releases.len());
        for c in &generation.contributions {
            match c.kind {
                ContributionKind::AsyncCompletion { op, .. } => {
                    if admission.completions.contains(&op) {
                        tracked_ops.entry(g).or_default().push(op);
                    }
                }
                kind => {
                    if graph.event(c.event).kind == EventKind::Contribute(g) {
                        contribution_of.insert(c.event, kind);
                    }
                }
            }
        }
    }

    let join = |into: &mut Vec<u32>, from: &[u32]| {
        for (a, &b) in into.iter_mut().zip(from) {
            *a = (*a).max(b);
        }
    };

    for (id, ev) in graph.events().iter() {
        match ev.ctx {
            ExecContext::Thread(t) => {
                let ti = t.0 as usize;
                index[ti] += 1;
                clocks[ti][ti] = index[ti];
                match ev.kind {
                    EventKind::Contribute(g) => {
                        if let Some(kind) = contribution_of.get(&id)
                            && matches!(
                                kind,
                                ContributionKind::Blocking | ContributionKind::Arrival { .. }
                            )
                        {
                            let acc = generation_clock.entry(g).or_insert_with(|| vec![0; n]);
                            join(acc, &clocks[ti]);
                        }
                    }
                    EventKind::Resume(g) if admission.generations.contains(&g) => {
                        let left = unreleased.get_mut(&g).expect("an admitted generation");
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
                        state.releases.entry(g).or_default().push(p);
                        for &op in tracked_ops.get(&g).map_or(&[][..], Vec::as_slice) {
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
                let empty = vec![0; n];
                let clock = issue_clock.get(&op).unwrap_or(&empty);
                let view = HbView {
                    point: Point::Effect(op),
                    clock,
                    state: &state,
                };
                visit(id, &view);
            }
            ExecContext::Generation(g) => {
                if admission.generations.contains(&g) {
                    let mut acc = generation_clock.remove(&g).unwrap_or_else(|| vec![0; n]);
                    for c in &graph.generation(g).contributions {
                        match c.kind {
                            ContributionKind::Exited if admission.exited_threads => {
                                if let Some(t) = graph.thread_of(c.event) {
                                    join(&mut acc, &clocks[t.0 as usize]);
                                }
                            }
                            ContributionKind::AsyncCompletion { op, .. }
                                if admission.completions.contains(&op) =>
                            {
                                if let Some(ic) = issue_clock.get(&op) {
                                    join(&mut acc, ic);
                                }
                            }
                            _ => {}
                        }
                    }
                    generation_clock.insert(g, acc);
                }
                let empty = vec![0; n];
                let clock = generation_clock.get(&g).unwrap_or(&empty);
                let view = HbView {
                    point: Point::Generation(g),
                    clock,
                    state: &state,
                };
                visit(id, &view);
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
