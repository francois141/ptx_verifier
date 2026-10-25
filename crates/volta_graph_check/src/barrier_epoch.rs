//! **Barrier-epoch checks** (§1.3, Algorithm 1): Weft's named-barrier separation criterion
//! (Sharma, Bauer, Aiken, PLDI'15), applied to named barriers and to mbarrier phases, where a
//! wait of the next phase follows the completion rule below instead. Two checks, one per
//! barrier family: [`check_named_barrier_epochs`] (`bar.arrive`, `bar.sync`) and
//! [`check_mbarrier_epochs`].
//!
//! ```text
//! G0 <- INDEPENDENTEDGES(G);  G0+ <- TRANSITIVECLOSURE(G0)
//! for all b in BARRIERS(G), k such that b has generations k and k+1,
//!         v in BARRIEROPERATIONS(b, k+1):
//!     p <- PROGRAMPREDECESSOR(v)
//!     if v is a wait and RELEASES(b, k) is not empty:                  -- completion rule
//!         if no r in RELEASES(b, k) has r = p or (r, p) in G0+ then return VIOLATION(r0, v)
//!     else for all s in SYNCHRONIZATIONS(b, k):                        -- separation rule
//!         if s != p and (s, p) not in G0+ then return VIOLATION(s, v)
//! return SUCCESS
//! ```
//!
//! * `G0` is [`IndependentGraph`]; `(s, p) ∈ G0+` (or `s = p`) is its non-strict
//!   happens-before. `BARRIERS(G)` are the family's sync objects (an mbarrier lifetime is one
//!   object), with their generations by logical index; an mbarrier's pre-init phase is its
//!   generation -1, so the waits it releases must precede every operation of phase 0, and so
//!   must the `mbarrier.init` that completes it: any other mbarrier operation on a location
//!   without a valid object is undefined (PTX ISA 9.7.15.16.13).
//! * A *barrier operation* is a thread's instruction instance bound to a generation: a
//!   contribution (`bar.arrive`, `bar.sync`, `mbarrier.arrive`, `complete_tx`, `tcgen05.commit`,
//!   `cp.async.mbarrier.arrive`), an async copy's `complete_tx` (`cp.async.bulk{.tensor}`, a
//!   `clusterlaunchcontrol.try_cancel` response) or an mbarrier wait. `SYNCHRONIZATIONS(b, k)`
//!   holds the event through which each thread operation of generation `k` takes part in it (a
//!   contribution's `Contribute`, a wait's release; for a pre-init phase, also the init),
//!   `RELEASES(b, k)` the releases among them; a copy's completion is none, since `G0` orders
//!   nothing after it.
//!   `BARRIEROPERATIONS(b, k + 1)` the event each operation of generation `k + 1` begins with
//!   (a contribution's `Contribute`, a copy's issue, a wait's `WaitStart`), whose program
//!   predecessor `p` may be on another thread than `s`. Exited threads are not thread
//!   operations, nor are the completions an arrive-on tracks (`tcgen05.commit`,
//!   `cp.async.mbarrier.arrive`): the arrive-on is. A `v` that begins its thread has no `p`.
//! * The separation rule binds a contribution of `k + 1` to its phase (it follows every
//!   arrival of `k`) and keeps a wait of `k` from starting after phase `k + 1` completes (it
//!   would then bind phase `k + 2`). A copy's `complete_tx` lands at any time after its issue,
//!   so the rule binds its issue: a copy issued before phase `k` is observed complete can
//!   complete `k` with its bytes. A parity wait of `k + 1` instead needs phase `k`
//!   complete when it starts, or it returns through phase `k - 1` (the ISA's "immediately
//!   preceding phase" of the same parity). A completion reaches a thread only through the
//!   phase's releases, so one release of `k` reaching `p` suffices, and the other waiters of
//!   `k` need not precede the wait. A phase that released no thread offers no such witness,
//!   and the separation rule stays.
//! * `Pass`: SUCCESS; only then is the family's certificate issued, so the candidate joins
//!   become ordering evidence ([`crate::relation::ValidatedGraph`]). `Fail`: the first
//!   VIOLATION(s, v) in the algorithm's iteration order (barriers by object, `k` ascending,
//!   `s` and `v` in trace order; under the completion rule `s` is the first release of `k`).
//!   `Unknown`: the graph violates its representation invariants.

use std::collections::{BTreeMap, HashMap};

use volta_graph::{
    ContributionKind, EventGraph, EventId, EventKind, Generation, GenerationId, GenerationKind,
    SyncObjectId, SyncObjectKind,
};

use crate::relation::{IndependentGraph, thread_points};
use crate::result::{PropertyResult, Unresolved};

/// The barrier family a check runs Algorithm 1 over.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum BarrierFamily {
    NamedBarrier,
    Mbarrier,
}

impl BarrierFamily {
    fn contains(self, kind: &SyncObjectKind) -> bool {
        match self {
            BarrierFamily::NamedBarrier => matches!(kind, SyncObjectKind::NamedBarrier { .. }),
            BarrierFamily::Mbarrier => matches!(kind, SyncObjectKind::Mbarrier { .. }),
        }
    }
}

/// VIOLATION(s, v): `v`, an operation of generation `next` = k + 1 of `barrier`, does not
/// follow `s` of generation `generation` = k: a synchronization that does not reach `v`'s
/// predecessor or, for a wait under the completion rule, the first release, none of which does.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct EpochViolation {
    pub barrier: SyncObjectId,
    pub generation: GenerationId,
    pub next: GenerationId,
    pub synchronization: EventId,
    pub operation: EventId,
    /// `PROGRAMPREDECESSOR(v)`; `None` when `v` begins its thread.
    pub predecessor: Option<EventId>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct EpochEvidence {
    pub barriers: usize,
    pub generation_pairs: usize,
    /// `(s, v)` pairs found separated.
    pub separations: u64,
}

pub type EpochResult = PropertyResult<EpochEvidence, EpochViolation>;

/// Algorithm 1 returned SUCCESS on `graph`'s named barriers.
#[derive(Debug, Clone, Copy)]
pub struct NamedBarrierEpochs<'g> {
    graph: &'g EventGraph,
}

impl<'g> NamedBarrierEpochs<'g> {
    pub fn graph(&self) -> &'g EventGraph {
        self.graph
    }
}

/// Algorithm 1 returned SUCCESS on `graph`'s mbarrier phases.
#[derive(Debug, Clone, Copy)]
pub struct MbarrierEpochs<'g> {
    graph: &'g EventGraph,
}

impl<'g> MbarrierEpochs<'g> {
    pub fn graph(&self) -> &'g EventGraph {
        self.graph
    }
}

/// Algorithm 1 over the named barriers (`bar.arrive`, `bar.sync`).
pub fn check_named_barrier_epochs(
    graph: &EventGraph,
) -> (EpochResult, Option<NamedBarrierEpochs<'_>>) {
    let result = barrier_epochs(graph, BarrierFamily::NamedBarrier);
    let certificate =
        matches!(result, PropertyResult::Pass(_)).then_some(NamedBarrierEpochs { graph });
    (result, certificate)
}

/// Algorithm 1 over the mbarrier phases.
pub fn check_mbarrier_epochs(graph: &EventGraph) -> (EpochResult, Option<MbarrierEpochs<'_>>) {
    let result = barrier_epochs(graph, BarrierFamily::Mbarrier);
    let certificate = matches!(result, PropertyResult::Pass(_)).then_some(MbarrierEpochs { graph });
    (result, certificate)
}

/// Generations k and k + 1 of one barrier.
struct GenerationPair {
    barrier: SyncObjectId,
    generation: GenerationId,
    next: GenerationId,
    /// `SYNCHRONIZATIONS(b, k)`, in trace order.
    synchronizations: Vec<EventId>,
    /// `RELEASES(b, k)`, as ascending indexes into `synchronizations`.
    releases: Vec<usize>,
    /// `BARRIEROPERATIONS(b, k + 1)`, in trace order.
    operations: Vec<Operation>,
}

impl GenerationPair {
    fn rule(&self, j: usize) -> Rule<'_> {
        match self.operations[j].kind {
            OperationKind::Wait if !self.releases.is_empty() => Rule::Any(&self.releases),
            _ => Rule::All(self.synchronizations.len()),
        }
    }
}

/// Which synchronizations of k (indexes into `synchronizations`) an operation of k + 1 must
/// follow.
#[derive(Debug, Clone, Copy)]
enum Rule<'a> {
    /// Every one of the `n` synchronizations (the separation rule).
    All(usize),
    /// At least one of these releases (the completion rule); never empty.
    Any(&'a [usize]),
}

/// Algorithm 1 over the barriers of `family`.
pub fn barrier_epochs(graph: &EventGraph, family: BarrierFamily) -> EpochResult {
    let g0 = match IndependentGraph::new(graph) {
        Ok(g0) => g0,
        Err(defects) => return malformed(&defects),
    };
    let mut barriers: BTreeMap<SyncObjectId, Vec<GenerationId>> = BTreeMap::new();
    for (g, generation) in graph.generations().iter() {
        if family.contains(&graph.object(generation.object).kind) {
            barriers.entry(generation.object).or_default().push(g);
        }
    }
    let mut pairs = Vec::new();
    for (&barrier, gens) in &mut barriers {
        gens.sort_by_key(|&g| logical_index(graph.generation(g)));
        for w in gens.windows(2) {
            if logical_index(graph.generation(w[0])) + 1 != logical_index(graph.generation(w[1])) {
                continue;
            }
            let mut synchronizations: Vec<EventId> = operations(graph, w[0])
                .into_iter()
                .filter(|o| o.kind != OperationKind::CopyCompleteTx)
                .map(|o| o.binds)
                .collect();
            if graph.generation(w[0]).kind == GenerationKind::MbarrierPreInit {
                synchronizations.extend(graph.object(barrier).init);
            }
            synchronizations.sort_unstable();
            let releases = synchronizations
                .iter()
                .enumerate()
                .filter(|(_, s)| matches!(graph.event(**s).kind, EventKind::Resume(_)))
                .map(|(si, _)| si)
                .collect();
            pairs.push(GenerationPair {
                barrier,
                generation: w[0],
                next: w[1],
                synchronizations,
                releases,
                operations: operations(graph, w[1]),
            });
        }
    }

    // `first[i]`: the first failing (s, v) of pair `i`, as indexes, s outermost.
    let mut first: Vec<Option<(usize, usize)>> = vec![None; pairs.len()];
    let earliest = |f: &mut Option<(usize, usize)>, failing: (usize, usize)| {
        *f = Some(f.map_or(failing, |f| f.min(failing)));
    };
    let mut at: HashMap<EventId, Vec<(usize, usize)>> = HashMap::new();
    for (i, pair) in pairs.iter().enumerate() {
        for (j, v) in pair.operations.iter().enumerate() {
            match (predecessor(graph, v.begins), pair.rule(j)) {
                (Some(p), _) => at.entry(p).or_default().push((i, j)),
                (None, Rule::All(0)) => {}
                (None, Rule::All(_)) => earliest(&mut first[i], (0, j)),
                (None, Rule::Any(releases)) => earliest(&mut first[i], (releases[0], j)),
            }
        }
    }
    let points = thread_points(graph);
    let mut separations = 0u64;
    g0.sweep(|e, view| {
        let Some(queries) = at.get(&e) else {
            return;
        };
        for &(i, j) in queries {
            let pair = &pairs[i];
            let reaches = |si: usize| {
                let s = pair.synchronizations[si];
                view.thread_hb(points[s.0 as usize].expect("a synchronization is a thread event"))
            };
            let (failing, separated) = match pair.rule(j) {
                Rule::All(n) => ((0..n).find(|&si| !reaches(si)), n as u64),
                Rule::Any(releases) => {
                    let witnessed = releases.iter().any(|&si| reaches(si));
                    ((!witnessed).then(|| releases[0]), 1)
                }
            };
            match failing {
                Some(si) => earliest(&mut first[i], (si, j)),
                None => separations += separated,
            }
        }
    });

    let violation = pairs.iter().zip(&first).find_map(|(pair, f)| {
        f.map(|(si, j)| {
            let v = pair.operations[j].begins;
            EpochViolation {
                barrier: pair.barrier,
                generation: pair.generation,
                next: pair.next,
                synchronization: pair.synchronizations[si],
                operation: v,
                predecessor: predecessor(graph, v),
            }
        })
    });
    match violation {
        Some(v) => PropertyResult::Fail(vec![v]),
        None => PropertyResult::Pass(EpochEvidence {
            barriers: barriers.len(),
            generation_pairs: pairs.len(),
            separations,
        }),
    }
}

fn logical_index(generation: &Generation) -> i64 {
    match generation.kind {
        GenerationKind::MbarrierPreInit => -1,
        _ => i64::from(generation.index),
    }
}

/// A check's `Unknown` for a graph that violates its representation invariants.
pub(crate) fn malformed<E, V>(defects: &[volta_graph::GraphDefect]) -> PropertyResult<E, V> {
    PropertyResult::Unknown(
        defects
            .iter()
            .map(|d| {
                let reason = format!("the graph is not well-formed: {}", d.message);
                match d.event {
                    Some(e) => Unresolved::at(e, reason),
                    None => Unresolved::global(reason),
                }
            })
            .collect(),
    )
}

/// A barrier operation bound to a generation: the event it begins with in its thread, the
/// event through which it takes part in the generation, and the rule that binds it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Operation {
    begins: EventId,
    binds: EventId,
    kind: OperationKind,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum OperationKind {
    /// A thread contribution, bound to its phase by the separation rule.
    Contribution,
    /// An async copy's `complete_tx`: it begins at the copy's issue, bound there by the
    /// separation rule, and takes part at the copy's completion, which is no synchronization.
    CopyCompleteTx,
    /// An mbarrier wait, bound to its phase by the completion rule.
    Wait,
}

/// The barrier operations of generation `g`, in trace order: its thread contributions, the
/// `complete_tx` of the copies it tracks, and the waits it releases (a release right after
/// the thread's own blocking contribution is that contribution's).
fn operations(graph: &EventGraph, g: GenerationId) -> Vec<Operation> {
    let generation = graph.generation(g);
    let mut ops: Vec<Operation> = generation
        .contributions
        .iter()
        .filter_map(|c| match c.kind {
            ContributionKind::AsyncCompletion { op, tx_bytes } if tx_bytes > 0 => Some(Operation {
                begins: graph.async_op(op).issue,
                binds: c.event,
                kind: OperationKind::CopyCompleteTx,
            }),
            _ => (graph.event(c.event).kind == EventKind::Contribute(g)).then_some(Operation {
                begins: c.event,
                binds: c.event,
                kind: OperationKind::Contribution,
            }),
        })
        .collect();
    for &r in &generation.releases {
        let before = predecessor(graph, r);
        match before.map(|p| graph.event(p).kind) {
            Some(EventKind::Contribute(h)) if h == g => {}
            Some(EventKind::WaitStart { object, .. }) if object == generation.object => {
                ops.push(Operation {
                    begins: before.expect("a predecessor"),
                    binds: r,
                    kind: OperationKind::Wait,
                })
            }
            _ => ops.push(Operation {
                begins: r,
                binds: r,
                kind: OperationKind::Wait,
            }),
        }
    }
    ops.sort_by_key(|o| o.begins);
    ops
}

/// `PROGRAMPREDECESSOR(event)`: the event before it in its thread's program order.
pub fn predecessor(graph: &EventGraph, event: EventId) -> Option<EventId> {
    let t = graph.thread_of(event)?;
    let order = graph.program_order(t);
    let at = order.binary_search(&event).ok()?;
    at.checked_sub(1).map(|i| order[i])
}
