//! **Mbarrier release-order check**, beyond the design's seven: the waits of each mbarrier
//! lifetime observe its phases one after another, from its pre-init phase or phase 0, over `G0`.
//!
//! ```text
//! G0+ <- TRANSITIVECLOSURE(INDEPENDENTEDGES(G));  B <- {}
//! for all mbarrier lifetimes b:
//!   K <- the phases of b that released a thread, ascending (the pre-init phase is -1)
//!   if K[0] > 0 then REPORT(B, LATESTART(K[0]))
//!   for all consecutive k, k' in K:
//!     if k' != k + 1 then REPORT(B, SKIPPEDPHASE(k, k'))
//!     else for all r' in RELEASES(b, k'):
//!       if some r in RELEASES(b, k) has (r, r') not in G0+ then REPORT(B, UNORDERED(r, r'))
//! return B
//! ```
//!
//! * A release is the `Resume` of a wait. The releases of one phase need no order among
//!   themselves, but those of consecutive phases must be ordered, so along `G0` the released
//!   phases run 0, 1, 2, ... and their parities 0, 1, 0, 1, .... They may start one phase
//!   earlier, at the pre-init phase (odd): the CUTLASS producer's first parity-1 wait on a fresh
//!   `empty` barrier returns through it, and the barrier-epoch check orders that release before
//!   every operation of phase 0.
//! * A parity wait tells only the current phase from the one before it: a wait of phase
//!   `k + 1` started before phase `k` completes returns through phase `k - 1`. The barrier-epoch
//!   check's completion rule sees `k` complete when a release of `k` reaches the wait; a phase
//!   that released no thread leaves it only the separation rule, which an async copy's
//!   `complete_tx` escapes (it is no synchronization). Here every phase before a released one
//!   released a thread, so the completion rule always applies.
//! * `G0` is [`IndependentGraph`], the execution order the barrier-epoch checks use; no
//!   certificate is needed, and none is issued.
//! * `Pass`: `B = {}` (vacuous without a released mbarrier phase). `Fail`: `B`, by lifetime, then
//!   phase, then release, in trace order (`UNORDERED` names the first `r` not reaching `r'`).
//!   `Unknown`: the graph violates its representation invariants.

use std::collections::{BTreeMap, HashMap};

use volta_graph::{EventGraph, EventId, GenerationId, SyncObjectId, SyncObjectKind};

use crate::barrier_epoch::{logical_index, malformed};
use crate::relation::{IndependentGraph, thread_points};
use crate::result::PropertyResult;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ReleaseOrderViolation {
    /// `release`, the first release of `phase`, the lifetime's first released phase, which is
    /// later than phase 0: phase 0 released no thread.
    LateStart {
        phase: GenerationId,
        release: EventId,
    },
    /// `release`, the first release of `phase`, follows released phase `previous`, which is not
    /// the phase right before it: that phase released no thread.
    SkippedPhase {
        previous: GenerationId,
        phase: GenerationId,
        release: EventId,
    },
    /// `earlier`, a release of one phase, does not reach `later`, a release of the next, in
    /// `G0`.
    Unordered { earlier: EventId, later: EventId },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ReleaseOrderEvidence {
    pub lifetimes: usize,
    pub released_phases: usize,
    pub releases: usize,
}

pub type ReleaseOrderResult = PropertyResult<ReleaseOrderEvidence, ReleaseOrderViolation>;

pub fn check_mbarrier_release_order(graph: &EventGraph) -> ReleaseOrderResult {
    let g0 = match IndependentGraph::new(graph) {
        Ok(g0) => g0,
        Err(defects) => return malformed(&defects),
    };
    let mut lifetimes: BTreeMap<SyncObjectId, Vec<GenerationId>> = BTreeMap::new();
    for (g, generation) in graph.generations().iter() {
        let mbarrier = matches!(
            graph.object(generation.object).kind,
            SyncObjectKind::Mbarrier { .. }
        );
        if mbarrier && !generation.releases.is_empty() {
            lifetimes.entry(generation.object).or_default().push(g);
        }
    }
    let index = |g: GenerationId| logical_index(graph.generation(g));
    for phases in lifetimes.values_mut() {
        phases.sort_by_key(|&g| index(g));
    }
    let releases = |g: GenerationId| graph.generation(g).releases.as_slice();

    let mut previous_phase: HashMap<EventId, GenerationId> = HashMap::new();
    for phases in lifetimes.values() {
        for w in phases.windows(2) {
            if index(w[0]) + 1 == index(w[1]) {
                previous_phase.extend(releases(w[1]).iter().map(|&r| (r, w[0])));
            }
        }
    }
    let points = thread_points(graph);
    let point = |e: EventId| points[e.0 as usize].expect("a release is a thread event");
    let mut unreached: HashMap<EventId, EventId> = HashMap::new();
    g0.sweep(|e, view| {
        let Some(&previous) = previous_phase.get(&e) else {
            return;
        };
        if let Some(&r) = releases(previous)
            .iter()
            .find(|&&r| !view.thread_hb(point(r)))
        {
            unreached.insert(e, r);
        }
    });

    let mut violations = Vec::new();
    for phases in lifetimes.values() {
        if index(phases[0]) > 0 {
            violations.push(ReleaseOrderViolation::LateStart {
                phase: phases[0],
                release: releases(phases[0])[0],
            });
        }
        for w in phases.windows(2) {
            if index(w[0]) + 1 != index(w[1]) {
                violations.push(ReleaseOrderViolation::SkippedPhase {
                    previous: w[0],
                    phase: w[1],
                    release: releases(w[1])[0],
                });
                continue;
            }
            violations.extend(releases(w[1]).iter().filter_map(|later| {
                unreached
                    .get(later)
                    .map(|&earlier| ReleaseOrderViolation::Unordered {
                        earlier,
                        later: *later,
                    })
            }));
        }
    }
    PropertyResult::from_findings(
        ReleaseOrderEvidence {
            lifetimes: lifetimes.len(),
            released_phases: lifetimes.values().map(Vec::len).sum(),
            releases: lifetimes
                .values()
                .flatten()
                .map(|&g| releases(g).len())
                .sum(),
        },
        violations,
        Vec::new(),
    )
}
