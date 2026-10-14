//! **Memory-conflict freedom (data races, including async read-before-write and buffer reuse).**
//!
//! * Property: for every two co-executable ordinary effects on an overlapping canonical
//!   location (a global or shared byte, a Tensor Memory cell), at least one a write, a valid
//!   typed ordering exists in one direction. Write-read, write-write and read-write (buffer
//!   reuse) conflicts are each obligations; read-read needs none.
//! * Valid typed ordering `a -> b`: `a` happens before `b` through admitted edges (program
//!   order; generations the barrier checker validated; completions the async-completion
//!   checker validated, so an async effect is ordered after its issue's predecessors and
//!   before the observers of its completion; exited threads' arrival only under
//!   `Assumption::ExitedThreadsArrive`), or a certified pipeline pair (same-issuer MMAs on one
//!   accumulator, `a`'s first), extended transitively through such a pair's later op; and a
//!   generic-proxy write read by the async proxy also needs its proxy coverage. Untyped
//!   reachability is never used. Effects of one async operation are ordered by that
//!   instruction's own semantics.
//! * Benign stores: two ordinary synchronous writes of identical footprint storing the same
//!   real value (same node, structurally equal, or equal per the explicit `ValueEquality`
//!   oracle over the producer's arena) do not conflict; a read ordered after any of a set of
//!   such equal concurrent writes reads their common value. Async writes are never benign.
//! * Co-executable: both in the candidate trace, whose control flow the structured-CTA
//!   assumption fixes. One candidate execution is checked; schedule independence follows only
//!   from the ordering obligations discharged here together with the validated certificates.
//! * Prerequisites: the barrier, async-completion, pipeline and proxy certificates, the
//!   symbolic facts for the benign rule, and a well-formed graph.
//! * `Pass`: every conflict ordered through validated edges. `Fail`: conflicts unordered
//!   through every candidate edge (definite races of the candidate execution), each with both
//!   effects and the first conflicting location, in trace order of the later effect.
//!   `Unknown`: conflicts ordered only through unvalidated edges or uncertified proxy coverage,
//!   or atomic/reduction effects, which are kept out of the shadow state (not modeled).

use std::collections::{HashMap, HashSet};

use volta_expr::{ExprArena, ExprId, ValueEquality, structurally_equal};
use volta_graph::{
    AccessId, AccessMode, Assumption, AsyncOpId, EventGraph, EventId, EventKind, ExecContext,
    Footprint, OrderingKind, Proxy, Space, StoredValue,
};

use crate::async_completion::CompletionCertificate;
use crate::barrier::SyncCertificate;
use crate::hb::{Admission, HbView, ThreadPoint, sweep, thread_points};
use crate::pipeline::PipelineCertificate;
use crate::proxy::ProxyCertificate;
use crate::result::{PropertyResult, Unresolved};

/// Read-only symbolic facts the benign-store rule needs.
pub struct SymbolicFacts<'a> {
    pub arena: &'a ExprArena,
    pub value_equality: &'a dyn ValueEquality,
}

/// The certificates the memory-conflict checker depends on.
pub struct RaceInputs<'a> {
    pub sync: &'a SyncCertificate,
    pub completion: &'a CompletionCertificate,
    pub pipeline: &'a PipelineCertificate,
    pub proxy: &'a ProxyCertificate,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum ConflictKind {
    WriteRead,
    WriteWrite,
    ReadWrite,
}

/// A conflicting location: a byte of global/shared memory or a Tensor Memory cell.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub enum Location {
    Byte(Space, u64),
    Cell { lane: u8, col: u16 },
}

/// One unordered conflict: `prior` (earlier in trace order) and `current`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Conflict {
    pub kind: ConflictKind,
    pub location: Location,
    pub prior: EventId,
    pub current: EventId,
}

/// Counts are per conflicting (prior, current, location) triple.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RaceEvidence {
    pub effects: usize,
    pub ordered_conflicts: u64,
    pub benign_equal_stores: u64,
}

pub type RaceResult = PropertyResult<RaceEvidence, Conflict>;

/// Conflicts reported per run beyond which checking stops (the first ones are the witness).
const CONFLICT_CAP: usize = 4096;

pub fn check_races(graph: &EventGraph, facts: &SymbolicFacts, inputs: &RaceInputs) -> RaceResult {
    if graph.validate().is_err() {
        return PropertyResult::Unknown(vec![Unresolved::global("the graph is not well-formed")]);
    }
    let mut unresolved = Vec::new();
    for (id, ev) in graph.events().iter() {
        if let EventKind::Access(a) = ev.kind
            && graph.access(a).ordering != OrderingKind::Ordinary
        {
            unresolved.push(Unresolved::at(
                id,
                format!("{:?} effects are not modeled", graph.access(a).ordering),
            ));
        }
    }
    let exited = graph.provenance().assumes(Assumption::ExitedThreadsArrive);
    let admitted = Admission {
        generations: inputs.sync.generations.clone(),
        completions: inputs.completion.completions.clone(),
        exited_threads: exited,
    };
    let run = Run::new(graph, facts, inputs.pipeline, Some(inputs.proxy));
    let (conflicts, evidence) = run.execute(&admitted);
    let fully_validated =
        inputs.sync.generations.is_all() && inputs.completion.completions.is_all();
    let mut violations = Vec::new();
    if fully_validated {
        violations = conflicts
            .iter()
            .filter(|c| !c.proxy_only)
            .map(|c| c.conflict)
            .collect();
        for c in conflicts.iter().filter(|c| c.proxy_only) {
            unresolved.push(proxy_unresolved(c.conflict));
        }
    } else if !conflicts.is_empty() {
        let candidate = Admission {
            exited_threads: exited,
            ..Admission::candidate()
        };
        let ordered = ordered_pairs(graph, &candidate, inputs.pipeline, &conflicts);
        for (i, c) in conflicts.iter().enumerate() {
            if c.proxy_only {
                unresolved.push(proxy_unresolved(c.conflict));
            } else if ordered.contains(&i) {
                unresolved.push(Unresolved::at(
                    c.conflict.current,
                    format!(
                        "conflict with event {} is ordered only through unvalidated synchronization",
                        c.conflict.prior.0
                    ),
                ));
            } else {
                violations.push(c.conflict);
            }
        }
    }
    unresolved.sort_by_key(|u| u.event);
    PropertyResult::from_findings(evidence, violations, unresolved)
}

fn proxy_unresolved(c: Conflict) -> Unresolved {
    Unresolved::at(
        c.current,
        format!(
            "the async-proxy read of event {}'s generic write is ordered only if its proxy \
             fence covers it (see cross-proxy ordering)",
            c.prior.0
        ),
    )
}

/// Who performed a recorded effect, for ordering queries.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Actor {
    Thread(ThreadPoint),
    Effect(AsyncOpId),
}

impl Actor {
    /// One read per actor is kept: a thread's later read subsumes its earlier one.
    fn key(self) -> (bool, u32) {
        match self {
            Actor::Thread(p) => (false, p.thread.0),
            Actor::Effect(op) => (true, op.0),
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct Rec {
    event: EventId,
    access: AccessId,
    actor: Actor,
}

#[derive(Debug, Default)]
struct Cell {
    /// The last write, or several pairwise-unordered equal benign writes.
    writes: Vec<Rec>,
    /// Reads since the last write, one per actor.
    reads: Vec<Rec>,
}

/// A found conflict; `proxy_only` when happens-before orders it but proxy coverage is missing.
#[derive(Debug, Clone, Copy)]
struct Found {
    conflict: Conflict,
    proxy_only: bool,
}

/// Sorted, merged written byte ranges per space and written Tensor Memory cells: reads of
/// locations nobody writes cannot conflict.
struct Written {
    bytes: HashMap<Space, Vec<(u64, u64)>>,
}

impl Written {
    fn of(graph: &EventGraph) -> Self {
        let mut bytes: HashMap<Space, Vec<(u64, u64)>> = HashMap::new();
        for a in graph.accesses().values() {
            if a.mode != AccessMode::Write {
                continue;
            }
            if let Footprint::Bytes { addr, width } = a.footprint {
                bytes
                    .entry(a.space)
                    .or_default()
                    .push((addr, addr.saturating_add(u64::from(width))));
            }
        }
        for ranges in bytes.values_mut() {
            ranges.sort_unstable();
            let mut merged: Vec<(u64, u64)> = Vec::with_capacity(ranges.len());
            for &(s, e) in ranges.iter() {
                match merged.last_mut() {
                    Some(last) if s <= last.1 => last.1 = last.1.max(e),
                    _ => merged.push((s, e)),
                }
            }
            *ranges = merged;
        }
        Written { bytes }
    }

    fn contains(&self, space: Space, byte: u64) -> bool {
        let Some(ranges) = self.bytes.get(&space) else {
            return false;
        };
        let i = ranges.partition_point(|&(s, _)| s <= byte);
        i > 0 && byte < ranges[i - 1].1
    }
}

struct Run<'a> {
    graph: &'a EventGraph,
    facts: &'a SymbolicFacts<'a>,
    pipeline: &'a PipelineCertificate,
    proxy: Option<&'a ProxyCertificate>,
    points: Vec<Option<ThreadPoint>>,
    written: Written,
}

impl<'a> Run<'a> {
    fn new(
        graph: &'a EventGraph,
        facts: &'a SymbolicFacts<'a>,
        pipeline: &'a PipelineCertificate,
        proxy: Option<&'a ProxyCertificate>,
    ) -> Self {
        Run {
            graph,
            facts,
            pipeline,
            proxy,
            points: thread_points(graph),
            written: Written::of(graph),
        }
    }

    fn actor(&self, event: EventId) -> Actor {
        match self.graph.event(event).ctx {
            ExecContext::Thread(_) => Actor::Thread(self.points[event.0 as usize].unwrap()),
            ExecContext::Async(op) => Actor::Effect(op),
            ExecContext::Generation(_) => unreachable!("effects live in threads or async ops"),
        }
    }

    fn execute(&self, admission: &Admission) -> (Vec<Found>, RaceEvidence) {
        let mut cells: HashMap<Location, Cell> = HashMap::new();
        let mut found: Vec<Found> = Vec::new();
        let mut reported: HashSet<(EventId, EventId, bool)> = HashSet::new();
        let mut equal_cache: HashMap<(AccessId, AccessId), bool> = HashMap::new();
        let mut evidence = RaceEvidence {
            effects: 0,
            ordered_conflicts: 0,
            benign_equal_stores: 0,
        };
        sweep(self.graph, admission, |e, view| {
            if found.len() >= CONFLICT_CAP {
                return;
            }
            let EventKind::Access(a) = self.graph.event(e).kind else {
                return;
            };
            let access = *self.graph.access(a);
            if access.ordering != OrderingKind::Ordinary {
                return;
            }
            evidence.effects += 1;
            let current = Rec {
                event: e,
                access: a,
                actor: self.actor(e),
            };
            for location in locations(&access) {
                if access.mode == AccessMode::Read
                    && let Location::Byte(space, byte) = location
                    && !self.written.contains(space, byte)
                {
                    continue;
                }
                let cell = cells.entry(location).or_default();
                match access.mode {
                    AccessMode::Read => {
                        if !cell.writes.is_empty() {
                            let mut best = None;
                            for w in &cell.writes {
                                let o = self.order(w, &current, view);
                                best = Some(match (best, o) {
                                    (Some(Order::Ordered), _) | (_, Order::Ordered) => {
                                        Order::Ordered
                                    }
                                    (Some(Order::ProxyOnly), _) | (_, Order::ProxyOnly) => {
                                        Order::ProxyOnly
                                    }
                                    _ => Order::Unordered,
                                });
                            }
                            let last = *cell.writes.iter().max_by_key(|w| w.event).unwrap();
                            match best.unwrap() {
                                Order::Ordered => evidence.ordered_conflicts += 1,
                                o => report(
                                    &mut found,
                                    &mut reported,
                                    Conflict {
                                        kind: ConflictKind::WriteRead,
                                        location,
                                        prior: last.event,
                                        current: e,
                                    },
                                    o,
                                ),
                            }
                        }
                        let key = current.actor.key();
                        match cell.reads.iter_mut().find(|r| r.actor.key() == key) {
                            Some(r) => *r = current,
                            None => cell.reads.push(current),
                        }
                    }
                    AccessMode::Write => {
                        let mut reads = cell.reads.clone();
                        reads.sort_by_key(|r| (r.actor.key(), r.event));
                        for r in &reads {
                            match self.order(r, &current, view) {
                                Order::Ordered => evidence.ordered_conflicts += 1,
                                o => report(
                                    &mut found,
                                    &mut reported,
                                    Conflict {
                                        kind: ConflictKind::ReadWrite,
                                        location,
                                        prior: r.event,
                                        current: e,
                                    },
                                    o,
                                ),
                            }
                        }
                        let mut kept = Vec::new();
                        for w in &cell.writes {
                            match self.order(w, &current, view) {
                                Order::Ordered => evidence.ordered_conflicts += 1,
                                o => {
                                    if self.benign(w, &current, &mut equal_cache) {
                                        evidence.benign_equal_stores += 1;
                                        kept.push(*w);
                                    } else {
                                        report(
                                            &mut found,
                                            &mut reported,
                                            Conflict {
                                                kind: ConflictKind::WriteWrite,
                                                location,
                                                prior: w.event,
                                                current: e,
                                            },
                                            o,
                                        );
                                    }
                                }
                            }
                        }
                        kept.push(current);
                        cell.writes = kept;
                        cell.reads.clear();
                    }
                }
            }
        });
        found.sort_by_key(|f| (f.conflict.current, f.conflict.location));
        (found, evidence)
    }

    /// Whether `prior` is ordered before the visited `current` effect.
    fn order(&self, prior: &Rec, current: &Rec, view: &HbView) -> Order {
        let hb = match (prior.actor, current.actor) {
            (Actor::Effect(a), Actor::Effect(b)) if a == b => true,
            (Actor::Thread(p), _) => view.thread_hb(p),
            (Actor::Effect(a), current_actor) => {
                view.effects_hb(a)
                    || matches!(current_actor, Actor::Effect(b) if self.pipeline.orders(a, b))
                    || self
                        .pipeline
                        .successors(a)
                        .iter()
                        .rev()
                        .any(|&s| view.effects_hb(s))
            }
        };
        if !hb {
            return Order::Unordered;
        }
        let prior_access = self.graph.access(prior.access);
        let current_access = self.graph.access(current.access);
        let cross_proxy = prior_access.mode == AccessMode::Write
            && prior_access.proxy == Proxy::Generic
            && current_access.mode == AccessMode::Read
            && current_access.proxy == Proxy::Async
            && current_access.space == Space::Shared;
        match self.proxy {
            Some(proxy)
                if cross_proxy
                    && self.graph.provenance().assumes(Assumption::AsyncProxy)
                    && !proxy.covered.contains(&(prior.access, current.access)) =>
            {
                Order::ProxyOnly
            }
            _ => Order::Ordered,
        }
    }

    /// Equal-valued ordinary stores of one footprint (the warp-uniform store idiom).
    fn benign(&self, a: &Rec, b: &Rec, cache: &mut HashMap<(AccessId, AccessId), bool>) -> bool {
        if matches!(a.actor, Actor::Effect(_)) || matches!(b.actor, Actor::Effect(_)) {
            return false;
        }
        let (x, y) = (self.graph.access(a.access), self.graph.access(b.access));
        if x.footprint != y.footprint {
            return false;
        }
        *cache.entry((a.access, b.access)).or_insert_with(|| {
            let (Some(vx), Some(vy)) = (x.value, y.value) else {
                return false;
            };
            let lanes: Vec<(ExprId, ExprId)> = match (self.graph.value(vx), self.graph.value(vy)) {
                (StoredValue::Scalar(p), StoredValue::Scalar(q)) => vec![(p, q)],
                (StoredValue::Pair(p0, p1), StoredValue::Pair(q0, q1)) => vec![(p0, q0), (p1, q1)],
                (StoredValue::Quad(p), StoredValue::Quad(q)) => p.into_iter().zip(q).collect(),
                _ => return false,
            };
            lanes.into_iter().all(|(p, q)| {
                p == q
                    || structurally_equal(self.facts.arena, p, self.facts.arena, q)
                    || self.facts.value_equality.same_value(self.facts.arena, p, q)
            })
        })
    }
}

/// Records an unordered conflict once per effect pair and classification, at its lowest
/// location (locations are visited in ascending order).
fn report(
    found: &mut Vec<Found>,
    reported: &mut HashSet<(EventId, EventId, bool)>,
    conflict: Conflict,
    order: Order,
) {
    let proxy_only = order == Order::ProxyOnly;
    if reported.insert((conflict.prior, conflict.current, proxy_only)) {
        found.push(Found {
            conflict,
            proxy_only,
        });
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Order {
    Ordered,
    ProxyOnly,
    Unordered,
}

/// The canonical locations of an effect, in ascending order.
fn locations(access: &volta_graph::MemAccess) -> Vec<Location> {
    match access.footprint {
        Footprint::Bytes { addr, width } => (addr..addr + u64::from(width))
            .map(|b| Location::Byte(access.space, b))
            .collect(),
        Footprint::Tensor {
            lane,
            lanes,
            col,
            cols,
        } => (u32::from(lane)..u32::from(lane) + u32::from(lanes))
            .flat_map(|l| {
                (u32::from(col)..u32::from(col) + u32::from(cols)).map(move |c| Location::Cell {
                    lane: l as u8,
                    col: c as u16,
                })
            })
            .collect(),
    }
}

/// Which of `found` are ordered (prior before current) through `admission`'s edges.
fn ordered_pairs(
    graph: &EventGraph,
    admission: &Admission,
    pipeline: &PipelineCertificate,
    found: &[Found],
) -> HashSet<usize> {
    let points = thread_points(graph);
    let mut at: HashMap<EventId, Vec<usize>> = HashMap::new();
    for (i, f) in found.iter().enumerate() {
        at.entry(f.conflict.current).or_default().push(i);
    }
    let mut ordered = HashSet::new();
    sweep(graph, admission, |e, view| {
        let Some(asked) = at.get(&e) else {
            return;
        };
        for &i in asked {
            let prior = found[i].conflict.prior;
            let hb = match graph.event(prior).ctx {
                ExecContext::Thread(_) => view.thread_hb(points[prior.0 as usize].unwrap()),
                ExecContext::Async(a) => {
                    let same = matches!(graph.event(e).ctx, ExecContext::Async(b) if a == b);
                    let pipelined = matches!(graph.event(e).ctx, ExecContext::Async(b) if pipeline.orders(a, b));
                    same || pipelined
                        || view.effects_hb(a)
                        || pipeline.successors(a).iter().any(|&s| view.effects_hb(s))
                }
                ExecContext::Generation(_) => false,
            };
            if hb {
                ordered.insert(i);
            }
        }
    });
    ordered
}
