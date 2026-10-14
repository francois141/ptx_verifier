//! **Barrier protocol and generation stability.**
//!
//! * Property: every synchronization generation's binding (which contributions and waits
//!   belong to it) is the same in every schedule, and each object's protocol is respected.
//!   Only generations this checker validates may order effects for later checkers.
//! * Uses: generations, their contributions, releases and evidence, sync objects, `WaitStart`
//!   events, the terminal state; happens-before over all *candidate* edges.
//! * Prerequisites: a well-formed graph (else `Unknown`).
//! * Named barriers (Weft, PLDI'15, Fig. 4 and Theorem 1): a completed `Count(n)` generation
//!   has exactly `n` arrivals, a full-CTA one an arrival or exit of every thread; a forming
//!   generation with more arrivals than its count is over-subscribed (`Fail`); and for every
//!   operation `v` of generation `k + 1` on a barrier, the event before `v` in its thread must
//!   be ordered (non-strictly, as Weft's `R`) after generation `k` completes (`Fail` otherwise:
//!   `v` could join generation `k` in another schedule). Weft's Theorem 1 makes passing these
//!   checks over the candidate relation sufficient for a schedule-independent assignment.
//! * mbarrier phases (Volta's adaptation; no published theorem, so failures are `Unknown`):
//!   every contribution and wait lies in the object's lifetime and a completed phase met its
//!   count with no outstanding transaction bytes (`Fail` otherwise); and, for phase `k`:
//!   (A1) each contribution to `k >= 1` is ordered after phase `k - 1` completes, (A2) each
//!   wait released by `k >= 1` started after phase `k - 1` completed, (A3) if phase `k + 1`
//!   completed with exactly its expected arrivals, each waiter released by `k` is ordered
//!   before one of those arrivals.
//! * Collectives (warp/warpgroup ops): entry contributions are the live members plus exited
//!   mask lanes, the exit's are the released members (`Fail` otherwise); Volta's rule that
//!   all live lanes converge at one pc and mask makes the binding schedule-independent.
//! * cp.async group waits: thread-local, released into their own thread only.
//! * `Pass`: every generation validated (the certificate admits all). `Fail`: a violation
//!   above, earliest first. `Unknown`: an unproven mbarrier stability condition.

use std::collections::{HashMap, HashSet};

use volta_graph::{
    BarrierArrivals, CollectiveSide, ContributionKind, EventGraph, EventId, EventKind,
    GenerationId, GenerationKind, SyncObjectId, SyncObjectKind, ThreadIx,
};

use crate::hb::{Admission, ThreadPoint, Validated, sweep, thread_points};
use crate::result::{PropertyResult, Unresolved};

/// The generations whose binding was validated: the ordering edges later checkers may use.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SyncCertificate {
    pub generations: Validated<GenerationId>,
}

impl SyncCertificate {
    /// Every generation, for testing later checkers in isolation.
    pub fn assume_all() -> Self {
        SyncCertificate {
            generations: Validated::All,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BarrierEvidence {
    pub named_barrier_generations: usize,
    pub mbarrier_phases: usize,
    pub collective_generations: usize,
    pub group_waits: usize,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum BarrierViolation {
    /// `op`, a contribution to generation `next`, could run before generation `previous`
    /// completes: its predecessor `predecessor` (none: the thread's start) is not ordered after it.
    Unseparated {
        previous: GenerationId,
        next: GenerationId,
        op: EventId,
        predecessor: Option<EventId>,
    },
    /// `arrivals` arrived at a generation firing on `count`.
    OverSubscribed {
        generation: GenerationId,
        arrivals: usize,
        count: u32,
        at: EventId,
    },
    /// A completed generation's contributions disagree with what completes it.
    Miscounted {
        generation: GenerationId,
        reason: String,
    },
    /// A contribution or wait on an mbarrier outside its init..inval lifetime.
    OutsideLifetime {
        generation: GenerationId,
        event: EventId,
    },
}

impl BarrierViolation {
    /// The trace position at which the violation is observable.
    pub fn position(&self, graph: &EventGraph) -> EventId {
        match self {
            BarrierViolation::Unseparated { op, .. } => *op,
            BarrierViolation::OverSubscribed { at, .. } => *at,
            BarrierViolation::Miscounted { generation, .. } => graph
                .generation(*generation)
                .completion
                .unwrap_or(EventId(graph.events().len() as u32)),
            BarrierViolation::OutsideLifetime { event, .. } => *event,
        }
    }
}

pub type BarrierResult = PropertyResult<BarrierEvidence, BarrierViolation>;

/// A happens-before question asked at one event.
enum Query {
    /// Weft separation of `op` (generation `next`) after generation `previous`.
    Separation {
        previous: GenerationId,
        next: GenerationId,
        op: EventId,
    },
    /// (A1)/(A2): `phase - 1` completes before the event.
    AfterPrevious {
        phase: GenerationId,
        previous: GenerationId,
        what: &'static str,
    },
}

pub fn check_barriers(graph: &EventGraph) -> (BarrierResult, SyncCertificate) {
    if graph.validate().is_err() {
        return (
            PropertyResult::Unknown(vec![Unresolved::global("the graph is not well-formed")]),
            SyncCertificate {
                generations: Validated::none(),
            },
        );
    }
    let mut violations = Vec::new();
    let mut unresolved = Vec::new();
    let mut tainted: HashSet<GenerationId> = HashSet::new();
    let mut queries: HashMap<EventId, Vec<Query>> = HashMap::new();
    let points = thread_points(graph);
    let mut evidence = BarrierEvidence {
        named_barrier_generations: 0,
        mbarrier_phases: 0,
        collective_generations: 0,
        group_waits: 0,
    };

    let mut by_object: HashMap<SyncObjectId, Vec<GenerationId>> = HashMap::new();
    for (g, generation) in graph.generations().iter() {
        by_object.entry(generation.object).or_default().push(g);
    }
    for gens in by_object.values_mut() {
        gens.sort_by_key(|&g| graph.generation(g).index);
    }

    let mut objects: Vec<_> = by_object.into_iter().collect();
    objects.sort_by_key(|(o, _)| *o);
    for (object, gens) in &objects {
        match &graph.object(*object).kind {
            SyncObjectKind::NamedBarrier { .. } => {
                evidence.named_barrier_generations += gens.len();
                check_named_barrier(graph, gens, &mut violations, &mut tainted, &mut queries);
            }
            SyncObjectKind::Mbarrier {
                expected_arrivals, ..
            } => {
                evidence.mbarrier_phases += gens.len();
                check_mbarrier(
                    graph,
                    (*object, *expected_arrivals),
                    gens,
                    (&mut violations, &mut tainted),
                    &mut queries,
                );
            }
            SyncObjectKind::WarpCollective { .. } | SyncObjectKind::WarpgroupCollective { .. } => {
                evidence.collective_generations += gens.len();
                check_collective(graph, gens, &mut violations, &mut tainted);
            }
            SyncObjectKind::AsyncGroupWait { thread } => {
                evidence.group_waits += gens.len();
                check_group_waits(graph, *thread, gens, &mut violations, &mut tainted);
            }
        }
    }

    sweep(graph, &Admission::candidate(), |e, view| {
        let Some(asked) = queries.remove(&e) else {
            return;
        };
        for q in asked {
            match q {
                Query::Separation { previous, next, op } => {
                    if !view.generation_hb(previous) {
                        tainted.insert(next);
                        violations.push(BarrierViolation::Unseparated {
                            previous,
                            next,
                            op,
                            predecessor: Some(e),
                        });
                    }
                }
                Query::AfterPrevious {
                    phase,
                    previous,
                    what,
                } => {
                    if !view.generation_hb(previous) {
                        tainted.insert(phase);
                        unresolved.push(Unresolved::at(
                            e,
                            format!(
                                "mbarrier {}: not ordered after the previous phase completes, so \
                                 it could bind to another phase",
                                what
                            ),
                        ));
                    }
                }
            }
        }
    });

    // (A3): every waiter of phase k needs one later arrival of phase k + 1 it precedes.
    let mut before_next: HashMap<(GenerationId, EventId), bool> = HashMap::new();
    let mut a3_points: HashMap<EventId, Vec<(GenerationId, ThreadPoint, EventId)>> = HashMap::new();
    for (object, gens) in &objects {
        if let SyncObjectKind::Mbarrier {
            expected_arrivals, ..
        } = graph.object(*object).kind
        {
            plan_upper_bound(
                graph,
                expected_arrivals,
                gens,
                &points,
                &mut before_next,
                &mut a3_points,
            );
        }
    }
    if !a3_points.is_empty() {
        sweep(graph, &Admission::candidate(), |e, view| {
            if let Some(asked) = a3_points.get(&e) {
                for &(phase, waiter, waiter_event) in asked {
                    if view.thread_hb(waiter) {
                        before_next.insert((phase, waiter_event), true);
                    }
                }
            }
        });
    }
    let mut a3: Vec<_> = before_next.into_iter().collect();
    a3.sort();
    for ((phase, waiter_event), ordered) in a3 {
        if !ordered {
            tainted.insert(phase);
            unresolved.push(Unresolved::at(
                waiter_event,
                "mbarrier wait: not ordered before any arrival the next phase needs, so a later \
                 phase could overtake it",
            ));
        }
    }

    violations.sort_by_key(|v| v.position(graph));
    unresolved.sort_by_key(|u| u.event);
    let certificate = SyncCertificate {
        generations: if tainted.is_empty() {
            Validated::All
        } else {
            Validated::Only(
                graph
                    .generations()
                    .count()
                    .into_iter()
                    .filter(|g| !tainted.contains(g))
                    .collect(),
            )
        },
    };
    (
        PropertyResult::from_findings(evidence, violations, unresolved),
        certificate,
    )
}

fn arrivals_of(graph: &EventGraph, g: GenerationId) -> usize {
    graph
        .generation(g)
        .contributions
        .iter()
        .filter(|c| {
            matches!(
                c.kind,
                ContributionKind::Blocking | ContributionKind::Arrival { .. }
            )
        })
        .count()
}

fn check_named_barrier(
    graph: &EventGraph,
    gens: &[GenerationId],
    violations: &mut Vec<BarrierViolation>,
    tainted: &mut HashSet<GenerationId>,
    queries: &mut HashMap<EventId, Vec<Query>>,
) {
    for (k, &g) in gens.iter().enumerate() {
        let generation = graph.generation(g);
        let GenerationKind::Barrier { arrivals } = generation.kind else {
            continue;
        };
        let arrived = arrivals_of(graph, g);
        let exited = generation
            .contributions
            .iter()
            .filter(|c| c.kind == ContributionKind::Exited)
            .count();
        let last = generation.contributions.iter().map(|c| c.event).max();
        match (arrivals, generation.completion) {
            (BarrierArrivals::Count(n), None) if arrived > n as usize => {
                tainted.insert(g);
                violations.push(BarrierViolation::OverSubscribed {
                    generation: g,
                    arrivals: arrived,
                    count: n,
                    at: last.expect("an over-subscribed generation has arrivals"),
                });
            }
            (BarrierArrivals::Count(n), Some(_)) if arrived != n as usize || exited != 0 => {
                tainted.insert(g);
                violations.push(BarrierViolation::Miscounted {
                    generation: g,
                    reason: format!(
                        "{} arrivals and {} exits at a barrier of {}",
                        arrived, exited, n
                    ),
                });
            }
            (BarrierArrivals::FullCta, Some(_)) if arrived + exited != graph.threads() as usize => {
                tainted.insert(g);
                violations.push(BarrierViolation::Miscounted {
                    generation: g,
                    reason: format!(
                        "{} arrivals and {} exits at a full-CTA barrier of {} threads",
                        arrived,
                        exited,
                        graph.threads()
                    ),
                });
            }
            _ => {}
        }
        if k == 0 {
            continue;
        }
        let previous = gens[k - 1];
        for c in &generation.contributions {
            if !matches!(
                c.kind,
                ContributionKind::Blocking | ContributionKind::Arrival { .. }
            ) {
                continue;
            }
            match predecessor(graph, c.event) {
                Some(p) => queries.entry(p).or_default().push(Query::Separation {
                    previous,
                    next: g,
                    op: c.event,
                }),
                None => {
                    tainted.insert(g);
                    violations.push(BarrierViolation::Unseparated {
                        previous,
                        next: g,
                        op: c.event,
                        predecessor: None,
                    });
                }
            }
        }
    }
}

/// The event before `event` in its thread's program order.
fn predecessor(graph: &EventGraph, event: EventId) -> Option<EventId> {
    let t = graph.thread_of(event)?;
    let order = graph.program_order(t);
    let at = order.binary_search(&event).ok()?;
    at.checked_sub(1).map(|i| order[i])
}

/// The `WaitStart` on `object` right before release `resume` in its thread.
fn wait_start(graph: &EventGraph, object: SyncObjectId, resume: EventId) -> Option<EventId> {
    let t = graph.thread_of(resume)?;
    let order = graph.program_order(t);
    let at = order.binary_search(&resume).ok()?;
    let p = *order.get(at.checked_sub(1)?)?;
    matches!(graph.event(p).kind, EventKind::WaitStart { object: o, .. } if o == object)
        .then_some(p)
}

fn check_mbarrier(
    graph: &EventGraph,
    (object, expected): (SyncObjectId, u64),
    gens: &[GenerationId],
    (violations, tainted): (&mut Vec<BarrierViolation>, &mut HashSet<GenerationId>),
    queries: &mut HashMap<EventId, Vec<Query>>,
) {
    let obj = graph.object(object);
    let live = |e: EventId| obj.init.is_some_and(|i| i < e) && obj.inval.is_none_or(|v| e < v);
    for (k, &g) in gens.iter().enumerate() {
        let generation = graph.generation(g);
        for c in &generation.contributions {
            if !live(c.event) {
                tainted.insert(g);
                violations.push(BarrierViolation::OutsideLifetime {
                    generation: g,
                    event: c.event,
                });
            }
        }
        for &r in &generation.releases {
            if !live(r) {
                tainted.insert(g);
                violations.push(BarrierViolation::OutsideLifetime {
                    generation: g,
                    event: r,
                });
            }
        }
        if generation.completion.is_some() {
            let arrived: u64 = generation
                .contributions
                .iter()
                .map(|c| match c.kind {
                    ContributionKind::Arrival { count, .. } => count,
                    _ => 0,
                })
                .sum();
            if arrived < expected || generation.evidence.pending_tx > 0 {
                tainted.insert(g);
                violations.push(BarrierViolation::Miscounted {
                    generation: g,
                    reason: format!(
                        "phase completed with {} of {} arrivals and {} pending transaction bytes",
                        arrived, expected, generation.evidence.pending_tx
                    ),
                });
            }
        }
        if k == 0 {
            continue;
        }
        let previous = gens[k - 1];
        for c in &generation.contributions {
            queries
                .entry(c.event)
                .or_default()
                .push(Query::AfterPrevious {
                    phase: g,
                    previous,
                    what: "contribution",
                });
        }
        for &r in &generation.releases {
            match wait_start(graph, object, r) {
                Some(ws) => queries.entry(ws).or_default().push(Query::AfterPrevious {
                    phase: g,
                    previous,
                    what: "wait",
                }),
                None => {
                    tainted.insert(g);
                    violations.push(BarrierViolation::Miscounted {
                        generation: g,
                        reason: "a release without a wait start".to_string(),
                    });
                }
            }
        }
    }
}

/// Plan (A3) for one mbarrier: each waiter of a phase whose successor completed must precede
/// one of the successor's arrivals, all of which are needed when they sum to `expected`.
fn plan_upper_bound(
    graph: &EventGraph,
    expected: u64,
    gens: &[GenerationId],
    points: &[Option<ThreadPoint>],
    before_next: &mut HashMap<(GenerationId, EventId), bool>,
    a3_points: &mut HashMap<EventId, Vec<(GenerationId, ThreadPoint, EventId)>>,
) {
    for pair in gens.windows(2) {
        let (phase, next) = (pair[0], pair[1]);
        let next_gen = graph.generation(next);
        if next_gen.completion.is_none() {
            continue;
        }
        let arrivals: Vec<(EventId, u64)> = next_gen
            .contributions
            .iter()
            .filter_map(|c| match c.kind {
                ContributionKind::Arrival { count, .. } if count > 0 => Some((c.event, count)),
                _ => None,
            })
            .collect();
        let exact = arrivals.iter().map(|&(_, n)| n).sum::<u64>() == expected;
        for &r in &graph.generation(phase).releases {
            before_next.insert((phase, r), false);
            if !exact {
                continue;
            }
            let waiter = points[r.0 as usize].expect("a release is a thread event");
            for &(arrival, _) in &arrivals {
                a3_points
                    .entry(arrival)
                    .or_default()
                    .push((phase, waiter, r));
            }
        }
    }
}

fn check_collective(
    graph: &EventGraph,
    gens: &[GenerationId],
    violations: &mut Vec<BarrierViolation>,
    tainted: &mut HashSet<GenerationId>,
) {
    let mut entries: HashMap<u32, GenerationId> = HashMap::new();
    for &g in gens {
        let generation = graph.generation(g);
        let GenerationKind::Collective { mask, side, .. } = generation.kind else {
            continue;
        };
        let members: HashSet<ThreadIx> = generation
            .contributions
            .iter()
            .filter(|c| c.kind == ContributionKind::Blocking)
            .filter_map(|c| graph.thread_of(c.event))
            .collect();
        let released: HashSet<ThreadIx> = generation
            .releases
            .iter()
            .filter_map(|&r| graph.thread_of(r))
            .collect();
        let mut fail = |reason: String| {
            tainted.insert(g);
            violations.push(BarrierViolation::Miscounted {
                generation: g,
                reason,
            });
        };
        if generation.completion.is_some() && members != released {
            fail("a collective releases other threads than its members".to_string());
        }
        match side {
            CollectiveSide::Entry => {
                entries.insert(generation.index, g);
                if generation.completion.is_none() {
                    continue;
                }
                let exited: HashSet<ThreadIx> = generation
                    .contributions
                    .iter()
                    .filter(|c| c.kind == ContributionKind::Exited)
                    .filter_map(|c| graph.thread_of(c.event))
                    .collect();
                let lanes = collective_lanes(graph, g, mask);
                if !members.is_disjoint(&exited) || members.len() + exited.len() != lanes {
                    fail(format!(
                        "{} live members and {} exited lanes for {} mask lanes",
                        members.len(),
                        exited.len(),
                        lanes
                    ));
                }
            }
            CollectiveSide::Exit => {
                let Some(&entry) = entries.get(&generation.index) else {
                    fail("a collective exit without its entry".to_string());
                    continue;
                };
                let entered: HashSet<ThreadIx> = graph
                    .generation(entry)
                    .releases
                    .iter()
                    .filter_map(|&r| graph.thread_of(r))
                    .collect();
                if generation.completion.is_some() && members != entered {
                    fail("a collective exit's members differ from its entry's".to_string());
                }
            }
        }
    }
}

/// How many threads of the CTA a collective's `mask` covers.
fn collective_lanes(graph: &EventGraph, g: GenerationId, mask: u32) -> usize {
    match graph.object(graph.generation(g).object).kind {
        SyncObjectKind::WarpCollective { warp } => (0..32)
            .filter(|lane| mask & (1u32 << lane) != 0)
            .filter(|lane| warp * 32 + lane < graph.threads())
            .count(),
        SyncObjectKind::WarpgroupCollective { warpgroup } => (warpgroup * 128
            ..warpgroup * 128 + 128)
            .filter(|&t| t < graph.threads())
            .count(),
        _ => 0,
    }
}

fn check_group_waits(
    graph: &EventGraph,
    thread: ThreadIx,
    gens: &[GenerationId],
    violations: &mut Vec<BarrierViolation>,
    tainted: &mut HashSet<GenerationId>,
) {
    for &g in gens {
        let generation = graph.generation(g);
        let foreign_release = generation
            .releases
            .iter()
            .any(|&r| graph.thread_of(r) != Some(thread));
        let thread_contribution = generation
            .contributions
            .iter()
            .any(|c| !matches!(c.kind, ContributionKind::AsyncCompletion { .. }));
        if foreign_release || thread_contribution {
            tainted.insert(g);
            violations.push(BarrierViolation::Miscounted {
                generation: g,
                reason: "a cp.async wait-group involving another thread or a thread arrival"
                    .to_string(),
            });
        }
    }
}
