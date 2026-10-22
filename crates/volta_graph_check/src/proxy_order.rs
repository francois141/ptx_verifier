//! **Proxy ordering verification** (§1.3, Algorithm 4): every ordered conflicting pair of `M`
//! whose effects use different proxies has a covering proxy fence ordered between them.
//!
//! ```text
//! require: validated H; memory-conflict check passed
//! R <- TRANSITIVECLOSURE(H);  F <- {f in V(H) | ISPROXYFENCE(f)}
//! for all (a, b) in ORDEREDCONFLICTS(M, R):
//!     if SAMEPROXY(a, b) then continue
//!     found <- false
//!     for all f in F with (a, f) in R:
//!         if (f, b) in R and COVERS(f, a, b) then found <- true; break
//!     if not found then return UNPROVEDPROXYORDER(a, b)
//! return SUCCESS
//! ```
//!
//! * `H = G_HB` ([`ValidatedGraph`]); [`MemoryConflictFree`] is the prerequisite, so every
//!   overlapping pair with a write is ordered and `ORDEREDCONFLICTS` orients it by trace order.
//! * `SAMEPROXY`: both effects use the same proxy. The check never consults the target: a
//!   proxy is a property of the instruction alone. Virtual aliases are not modeled.
//! * `ISPROXYFENCE`: an explicit `fence.proxy.async` (over one space, or every space), and,
//!   implicitly, a validated completion observation: a release of a generation that joins an
//!   async operation's completion, for that operation's effects.
//! * `COVERS(f, a, b)`: an explicit fence covers either direction between the generic and the
//!   async proxy in its space, when the thread of `a` or of `b` executes it; a completion
//!   observation covers its operation's async-proxy effects before later generic accesses.
//!   Every `R` path out of an async effect passes through such an observation, so an ordered
//!   async-proxy -> generic pair is always covered; the search below runs for the generic ->
//!   async-proxy pairs, where only an explicit fence can cover.
//! * Search: for a later async-proxy effect `b`, it suffices to try, per actor (a thread, or one
//!   async op) with conflicting generic effects on `b`'s bytes, its latest such effect `a`, and
//!   on each candidate thread only its latest suitable fence `f` with `(f, b) ∈ R`: if that
//!   pair is uncovered, so is the search, and if it is covered, program order (or the
//!   operation's shared observers) covers the actor's earlier effects through the same `f`.
//! * `Pass`: SUCCESS. `Fail`: the first UNPROVEDPROXYORDER(a, b). The design reports it as an
//!   unproved obligation; Volta reports a race, since the memory model orders no cross-proxy
//!   pair that no proxy fence covers.

use std::collections::{BTreeMap, HashMap, HashSet};

use volta_graph::{
    AccessMode, AsyncOpId, EventGraph, EventId, EventKind, ExecContext, FenceKind, Proxy, Space,
    ThreadIx,
};

use crate::domain::{ByteLocation, ConflictKind, bytes, in_m, written_bytes};
use crate::memory_conflict::MemoryConflictFree;
use crate::relation::{ThreadPoint, ValidatedGraph, thread_points};
use crate::result::PropertyResult;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProxyEvidence {
    /// Generic -> async-proxy pairs found covered (one per actor and later effect).
    pub covered_pairs: u64,
}

/// UNPROVEDPROXYORDER(a, b): the generic-proxy effect `generic` and the later async-proxy
/// effect `asynchronous` conflict at `location`, and no proxy fence covers the pair.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ProxyOrderViolation {
    pub kind: ConflictKind,
    pub location: ByteLocation,
    pub generic: EventId,
    pub asynchronous: EventId,
}

pub type ProxyOrderResult = PropertyResult<ProxyEvidence, ProxyOrderViolation>;

/// Who performed a generic-proxy effect.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
enum Actor {
    Thread(ThreadIx),
    Op(AsyncOpId),
}

/// An actor's latest generic-proxy effects on one byte.
#[derive(Debug, Clone, Copy, Default)]
struct Latest {
    read: Option<EventId>,
    write: Option<EventId>,
}

/// One explicit proxy fence and the clock it was visited with.
#[derive(Debug, Clone)]
struct Fence {
    index: u32,
    space: Option<Space>,
    clock: Vec<u32>,
}

pub fn check_proxy_order(
    h: &ValidatedGraph,
    prerequisite: &MemoryConflictFree,
) -> ProxyOrderResult {
    let graph = h.graph();
    assert!(
        std::ptr::eq(graph, prerequisite.graph()),
        "the memory-conflict certificate is for another graph"
    );
    let points = thread_points(graph);
    let written = written_bytes(graph);
    let mut fences: HashMap<ThreadIx, Vec<Fence>> = HashMap::new();
    let mut generic: HashMap<ByteLocation, BTreeMap<Actor, Latest>> = HashMap::new();
    let mut checked: HashSet<(EventId, EventId)> = HashSet::new();
    let mut covered_pairs = 0;
    let mut unproved: Option<ProxyOrderViolation> = None;
    h.sweep(|e, view| {
        if unproved.is_some() {
            return;
        }
        let ev = graph.event(e);
        if let (ExecContext::Thread(t), EventKind::Fence(FenceKind::ProxyAsync { space })) =
            (ev.ctx, ev.kind)
        {
            fences.entry(t).or_default().push(Fence {
                index: points[e.0 as usize].expect("a thread event").index,
                space,
                clock: view.clock().to_vec(),
            });
            return;
        }
        let EventKind::Access(acc) = ev.kind else {
            return;
        };
        let access = graph.access(acc);
        if !in_m(access) {
            return;
        }
        match access.proxy {
            Proxy::Generic => {
                let actor = match ev.ctx {
                    ExecContext::Async(op) => Actor::Op(op),
                    _ => Actor::Thread(access.attributed),
                };
                for location in bytes(access).filter(|l| written.contains(l)) {
                    let latest = generic
                        .entry(location)
                        .or_default()
                        .entry(actor)
                        .or_default();
                    match access.mode {
                        AccessMode::Read => latest.read = Some(e),
                        AccessMode::Write => latest.write = Some(e),
                    }
                }
            }
            Proxy::Async => {
                for location in bytes(access) {
                    let Some(actors) = generic.get(&location) else {
                        continue;
                    };
                    for latest in actors.values() {
                        let a = match access.mode {
                            AccessMode::Read => latest.write,
                            AccessMode::Write => latest.read.max(latest.write),
                        };
                        let Some(a) = a else {
                            continue;
                        };
                        let earlier = if latest.write == Some(a) {
                            AccessMode::Write
                        } else {
                            AccessMode::Read
                        };
                        if !checked.insert((a, e)) {
                            continue;
                        }
                        let candidates = [graph.acting_thread(a), Some(access.attributed)];
                        let covered = candidates.into_iter().flatten().any(|t| {
                            latest_fence(&fences, t, location.space, view.clock()[t.0 as usize])
                                .is_some_and(|f| reaches_fence(graph, &points, view, a, f))
                        });
                        if covered {
                            covered_pairs += 1;
                        } else {
                            unproved = Some(ProxyOrderViolation {
                                kind: ConflictKind::of(earlier, access.mode)
                                    .expect("one side of the pair writes"),
                                location,
                                generic: a,
                                asynchronous: e,
                            });
                            return;
                        }
                    }
                }
            }
        }
    });
    match unproved {
        Some(v) => PropertyResult::Fail(vec![v]),
        None => PropertyResult::Pass(ProxyEvidence { covered_pairs }),
    }
}

/// The latest fence of `thread` over `space` with `(f, b) ∈ R`, i.e. within `known` of the
/// thread's events.
fn latest_fence(
    fences: &HashMap<ThreadIx, Vec<Fence>>,
    thread: ThreadIx,
    space: Space,
    known: u32,
) -> Option<&Fence> {
    fences
        .get(&thread)?
        .iter()
        .rev()
        .filter(|f| f.index <= known)
        .find(|f| f.space.is_none_or(|s| s == space))
}

/// `(a, f) ∈ R`: `a`'s thread event, or one observer of its operation, is within `f`'s clock.
fn reaches_fence(
    graph: &EventGraph,
    points: &[Option<ThreadPoint>],
    view: &crate::relation::HbView,
    a: EventId,
    f: &Fence,
) -> bool {
    let within = |p: ThreadPoint| f.clock[p.thread.0 as usize] >= p.index;
    match graph.event(a).ctx {
        ExecContext::Thread(_) => within(points[a.0 as usize].expect("a thread event")),
        ExecContext::Async(op) => view.observers(op).iter().any(|&p| within(p)),
        ExecContext::Generation(_) => false,
    }
}
