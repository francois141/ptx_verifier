//! **Sufficient mbarrier ordering check** (§1.3, Algorithm 2): a phase completes only when
//! its pending arrivals and its pending transaction bytes are both zero, so every byte
//! announcement must precede an arrival of its phase, or be combined with one: while the
//! announcement is unexecuted an arrival is still pending and keeps the phase open.
//!
//! ```text
//! R <- TRANSITIVECLOSURE(G0)
//! for all candidate mbarrier phases k:
//!     D <- Σ d(u) over U_k;  T <- Σ t(u) over U_k
//!     if not COMPLETEDINTRACE(k):
//!         if D < n_k then continue
//!         return INCONCLUSIVE
//!     if D != n_k or T != 0 then return INVALIDPHASEBALANCE(k)
//!     E <- {u in U_k : t(u) > 0};  A <- {u in U_k : d(u) > 0}
//!     for all e in E:
//!         P <- {a in A : e = a or (e, a) in R}
//!         if P = {} then return INCONCLUSIVE
//! return SUCCESS
//! ```
//!
//! * `U_k` are phase `k`'s contributions and `n_k` its object's arrival count. An update's
//!   `(d, t)`: `arrive(c)` `(c, 0)`, `expect_tx(q)` `(0, q)`, `arrive.expect_tx(q)` `(1, q)`
//!   (indivisible, so it is its own protecting arrival), `complete_tx(q)` and a tracked
//!   completion of `q` bytes `(0, -q)`; `tcgen05.commit` and `cp.async.mbarrier.arrive.noinc`
//!   are arrivals of one. The pre-init phase has no updates and is no candidate.
//! * `R` is [`IndependentGraph`]'s closure: `(e, a) ∈ R` orders the announcement before the
//!   arrival in every execution, independently of the phase under check. Initialization and
//!   counter ranges are the design's separate checks.
//! * `Pass`: SUCCESS; only then is [`MbarrierOrdering`] issued, which with the barrier-epoch
//!   certificates admits the mbarrier completion joins into `G_HB`. `Fail`:
//!   INVALIDPHASEBALANCE, every completed phase whose arrivals or bytes do not balance.
//!   `Unknown`, as the design leaves both inconclusive: an open phase that has all its
//!   arrivals and still outstanding bytes, and every announcement no arrival protects (its
//!   phase can complete before it is announced, unless other outstanding bytes hold it open).

use std::collections::HashMap;

use volta_graph::{
    ContributionKind, EventGraph, EventId, GenerationId, GenerationKind, SyncObjectId,
    SyncObjectKind,
};

use crate::barrier_epoch::malformed;
use crate::relation::{IndependentGraph, ThreadPoint, thread_points};
use crate::result::{PropertyResult, Unresolved};

/// INVALIDPHASEBALANCE(k): a phase completed in the trace whose updates do not balance.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PhaseBalanceViolation {
    pub barrier: SyncObjectId,
    pub phase: GenerationId,
    /// `n_k`.
    pub expected_arrivals: u64,
    /// `D`: the arrivals the phase's updates count.
    pub arrivals: u64,
    /// `T`: the net transaction bytes the phase's updates leave.
    pub net_tx: i64,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct OrderingEvidence {
    /// Completed phases whose updates balance.
    pub completed_phases: usize,
    /// Open phases certified by a positive remaining arrival count.
    pub open_phases: usize,
    /// Announcements, each with a protecting arrival.
    pub announcements: usize,
}

pub type MbarrierOrderingResult = PropertyResult<OrderingEvidence, PhaseBalanceViolation>;

/// Algorithm 2 returned SUCCESS on `graph`'s mbarrier phases.
#[derive(Debug, Clone, Copy)]
pub struct MbarrierOrdering<'g> {
    graph: &'g EventGraph,
}

impl<'g> MbarrierOrdering<'g> {
    pub fn graph(&self) -> &'g EventGraph {
        self.graph
    }
}

/// Algorithm 2 over the mbarrier phases.
pub fn check_mbarrier_ordering(
    graph: &EventGraph,
) -> (MbarrierOrderingResult, Option<MbarrierOrdering<'_>>) {
    let result = mbarrier_ordering(graph);
    let certificate =
        matches!(result, PropertyResult::Pass(_)).then_some(MbarrierOrdering { graph });
    (result, certificate)
}

/// One update `u` of a phase: `d(u)` arrivals and `t(u)` bytes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Update {
    event: EventId,
    arrivals: u64,
    tx: i64,
}

impl Update {
    /// `None` for a contribution kind that is no mbarrier update.
    fn of(event: EventId, kind: ContributionKind) -> Option<Update> {
        let (arrivals, tx) = match kind {
            ContributionKind::Arrival {
                count, expect_tx, ..
            } => (count, i64::try_from(expect_tx)),
            ContributionKind::ExpectTx { bytes } => (0, i64::try_from(bytes)),
            ContributionKind::CompleteTx { bytes } => (0, i64::try_from(bytes).map(|b| -b)),
            ContributionKind::AsyncCompletion { tx_bytes, .. } => {
                (0, i64::try_from(tx_bytes).map(|b| -b))
            }
            ContributionKind::Blocking | ContributionKind::Exited => return None,
        };
        Some(Update {
            event,
            arrivals,
            tx: tx.unwrap_or(i64::MAX),
        })
    }
}

/// A candidate phase: its object, `n_k` and `U_k`.
struct Phase {
    barrier: SyncObjectId,
    addr: u64,
    id: GenerationId,
    index: u32,
    expected_arrivals: u64,
    completed: bool,
    updates: Vec<Update>,
}

/// An announcement `e` of a balanced phase, awaiting a protecting arrival.
struct Announcement {
    event: EventId,
    point: ThreadPoint,
    bytes: i64,
    protected: bool,
}

/// `E` and `A` of a balanced completed phase.
struct Obligation {
    phase: usize,
    announcements: Vec<Announcement>,
    arrivals: Vec<EventId>,
}

fn mbarrier_ordering(graph: &EventGraph) -> MbarrierOrderingResult {
    let g0 = match IndependentGraph::new(graph) {
        Ok(g0) => g0,
        Err(defects) => return malformed(&defects),
    };
    let mut violations = Vec::new();
    let mut unresolved = Vec::new();
    let mut evidence = OrderingEvidence {
        completed_phases: 0,
        open_phases: 0,
        announcements: 0,
    };

    let phases = candidate_phases(graph, &mut unresolved);
    let points = thread_points(graph);
    let mut obligations: Vec<Obligation> = Vec::new();
    let mut arrival_of: HashMap<EventId, usize> = HashMap::new();
    for (i, phase) in phases.iter().enumerate() {
        let arrivals: u64 = phase.updates.iter().map(|u| u.arrivals).sum();
        let net_tx: i64 = phase.updates.iter().map(|u| u.tx).sum();
        if !phase.completed {
            if arrivals < phase.expected_arrivals {
                evidence.open_phases += 1;
            } else {
                unresolved.push(Unresolved {
                    events: phase.updates.iter().map(|u| u.event).collect(),
                    reason: format!(
                        "{}: open at the end of the trace with all {} arrival(s) made and \
                         {net_tx} transaction byte(s) outstanding",
                        phase.describe(),
                        phase.expected_arrivals
                    ),
                });
            }
            continue;
        }
        if arrivals != phase.expected_arrivals || net_tx != 0 {
            violations.push(PhaseBalanceViolation {
                barrier: phase.barrier,
                phase: phase.id,
                expected_arrivals: phase.expected_arrivals,
                arrivals,
                net_tx,
            });
            continue;
        }
        evidence.completed_phases += 1;
        let announcements: Vec<Announcement> = phase
            .updates
            .iter()
            .filter(|u| u.tx > 0)
            .map(|u| Announcement {
                event: u.event,
                point: points[u.event.0 as usize].expect("an announcement is a thread event"),
                bytes: u.tx,
                protected: false,
            })
            .collect();
        if announcements.is_empty() {
            continue;
        }
        let arrivals: Vec<EventId> = phase
            .updates
            .iter()
            .filter(|u| u.arrivals > 0)
            .map(|u| u.event)
            .collect();
        for &a in &arrivals {
            arrival_of.insert(a, obligations.len());
        }
        obligations.push(Obligation {
            phase: i,
            announcements,
            arrivals,
        });
    }

    g0.sweep(|a, view| {
        let Some(&i) = arrival_of.get(&a) else {
            return;
        };
        for e in &mut obligations[i].announcements {
            if !e.protected && view.thread_hb(e.point) {
                e.protected = true;
            }
        }
    });

    for obligation in &obligations {
        let phase = &phases[obligation.phase];
        for e in &obligation.announcements {
            if e.protected {
                evidence.announcements += 1;
                continue;
            }
            let mut events = vec![e.event];
            events.extend(obligation.arrivals.iter().copied());
            events.sort_unstable();
            unresolved.push(Unresolved {
                events,
                reason: format!(
                    "{}: no arrival of the phase is ordered after this announcement of {} \
                     byte(s), so the phase can complete before it is announced",
                    phase.describe(),
                    e.bytes
                ),
            });
        }
    }
    unresolved.sort_by_key(|u| u.events.first().copied());
    PropertyResult::from_findings(evidence, violations, unresolved)
}

impl Phase {
    fn describe(&self) -> String {
        format!("mbarrier at shared {:#x}, phase {}", self.addr, self.index)
    }
}

/// Every mbarrier phase of `graph` with its updates; a contribution that is no mbarrier
/// update is reported into `unresolved`.
fn candidate_phases(graph: &EventGraph, unresolved: &mut Vec<Unresolved>) -> Vec<Phase> {
    let mut phases = Vec::new();
    for (g, generation) in graph.generations().iter() {
        if generation.kind != GenerationKind::MbarrierPhase {
            continue;
        }
        let SyncObjectKind::Mbarrier {
            addr,
            expected_arrivals,
        } = graph.object(generation.object).kind
        else {
            continue;
        };
        let mut phase = Phase {
            barrier: generation.object,
            addr,
            id: g,
            index: generation.index,
            expected_arrivals,
            completed: generation.completion.is_some(),
            updates: Vec::new(),
        };
        for c in &generation.contributions {
            match Update::of(c.event, c.kind) {
                Some(u) => phase.updates.push(u),
                None => unresolved.push(Unresolved::at(
                    c.event,
                    format!(
                        "{}: {:?} is not a supported mbarrier update",
                        phase.describe(),
                        c.kind
                    ),
                )),
            }
        }
        phase.updates.sort_by_key(|u| u.event);
        phases.push(phase);
    }
    phases
}
