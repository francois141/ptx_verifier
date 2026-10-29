//! **Proxy ordering verification** (§1.3, Algorithm 4): every ordered write -> read pair of `M`
//! whose effects use different proxies has a covering proxy fence ordered between them.
//!
//! ```text
//! require: validated H; memory-conflict check passed
//! R <- TRANSITIVECLOSURE(H);  F <- {f in V(H) | ISPROXYFENCE(f)}
//! for all (a, b) in ORDEREDCONFLICTS(M, R) with a a write and b a read:
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
//! * Only a read of bytes the other proxy wrote needs a fence: a read -> write or write -> write
//!   pair across proxies is taken as ordered by the synchronization that orders it in `H`
//!   (a TMA load refilling a buffer that `ldmatrix` read, or an async read before a generic write).
//! * `SAMEPROXY`: both effects use the same proxy. The check never consults the target: a
//!   proxy is a property of the instruction alone. Virtual aliases are not modeled.
//! * `ISPROXYFENCE`: an explicit `fence.proxy.async` (over one space, or every space), a
//!   tensor-map release (`fence.proxy.tensormap::generic.release`, or the one
//!   `tensormap.cp_fenceproxy` ends with) or acquire (`...acquire [map], 128`), and,
//!   implicitly, a validated completion observation: a release of a generation that joins the
//!   completion of a bulk copy, a TMA copy or a CLC response (PTX ISA 9.7.9.25.2), for that
//!   operation's effects. Other async operations' completions imply no proxy fence.
//! * `COVERS(f, a, b)`: an explicit `fence.proxy.async` covers either direction between the
//!   generic and the async proxy in its space, when the thread of `a` or of `b` executes it; a
//!   completion observation covers its operation's effects before later generic accesses.
//!   Every `R` path out of an async effect passes through such an observation, so an ordered
//!   async-write -> generic-read pair of an implicitly fenced operation is always covered. The
//!   search below runs for an async write of another operation before a generic read, and for
//!   a generic write before an async-proxy or tensor-map-proxy read, where only explicit fences
//!   can cover.
//! * The tensor-map proxy fences are one-directional and come in pairs (PTX ISA 9.7.14.4):
//!   a generic write `a` before a `cp.async.bulk.tensor`'s read `b` of its tensor map is
//!   covered by a release on `a`'s thread that `a` reaches, ordered before an acquire of `b`'s
//!   map on `b`'s issuing thread, which reaches `b`.
//! * Search: for a later async-proxy read `b`, it suffices to try, per actor (a thread, or one
//!   async op) with generic writes to `b`'s bytes, its latest such write `a`, and
//!   on each candidate thread only its latest suitable fence `f` with `(f, b) ∈ R`: if that
//!   pair is uncovered, so is the search, and if it is covered, program order (or the
//!   operation's shared observers) covers the actor's earlier effects through the same `f`.
//!   A tensor-map read tries the latest acquire of its map before it, then the writer's latest
//!   release ordered before that acquire, the two whose clocks are the largest.
//! * `Pass`: SUCCESS. `Fail`: the first UNPROVEDPROXYORDER(a, b). The design reports it as an
//!   unproved obligation; Volta reports a race, since the memory model orders no cross-proxy
//!   pair that no proxy fence covers.

use std::collections::{BTreeMap, HashMap, HashSet};

use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, EventGraph, EventId, EventKind, ExecContext, FenceKind,
    Proxy, Space, ThreadIx,
};

use crate::domain::{ByteLocation, ConflictKind, bytes, in_m, written_bytes};
use crate::memory_conflict::MemoryConflictFree;
use crate::relation::{ThreadPoint, ValidatedGraph, thread_points};
use crate::result::PropertyResult;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProxyEvidence {
    /// Cross-proxy write -> read pairs found covered (one per actor and later read).
    pub covered_pairs: u64,
}

/// UNPROVEDPROXYORDER(a, b): the generic-proxy effect `generic` and the effect `asynchronous` of
/// an async op, through the async or the tensor-map proxy, conflict at `location`, and no proxy
/// fence covers the pair. `kind` orders the two sides by trace order.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ProxyOrderViolation {
    pub kind: ConflictKind,
    pub location: ByteLocation,
    pub generic: EventId,
    pub asynchronous: EventId,
    pub missing: MissingFence,
}

/// The fence an uncovered pair lacks.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MissingFence {
    /// A `fence.proxy.async` on the thread of either side, ordered between them.
    ProxyAsync,
    /// A tensor-map release on the writer's thread, after its write and ordered before the
    /// acquire.
    TensormapRelease,
    /// A `fence.proxy.tensormap::generic.acquire` of the map on the copy's thread, before it.
    TensormapAcquire,
}

pub type ProxyOrderResult = PropertyResult<ProxyEvidence, ProxyOrderViolation>;

/// Who performed a generic-proxy effect.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
enum Actor {
    Thread(ThreadIx),
    Op(AsyncOpId),
}

/// One explicit proxy fence's program-order index and the clock it was visited with.
#[derive(Debug, Clone)]
struct Fence {
    index: u32,
    clock: Vec<u32>,
}

/// The bytes a tensor-map acquire covers, from its map's address.
const TENSOR_MAP_BYTES: u64 = 128;

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
    let mut fences: HashMap<ThreadIx, Vec<(Option<Space>, Fence)>> = HashMap::new();
    let mut releases: HashMap<ThreadIx, Vec<Fence>> = HashMap::new();
    let mut acquires: HashMap<ThreadIx, Vec<(u64, Fence)>> = HashMap::new();
    // Each actor's latest generic write of each byte.
    let mut generic: HashMap<ByteLocation, BTreeMap<Actor, EventId>> = HashMap::new();
    let mut unfenced: HashMap<ByteLocation, BTreeMap<AsyncOpId, EventId>> = HashMap::new();
    let mut checked: HashSet<(EventId, EventId)> = HashSet::new();
    let mut covered_pairs = 0;
    let mut unproved: Option<ProxyOrderViolation> = None;
    h.sweep(|e, view| {
        if unproved.is_some() {
            return;
        }
        let ev = graph.event(e);
        if let (ExecContext::Thread(t), EventKind::Fence(kind)) = (ev.ctx, ev.kind) {
            let fence = Fence {
                index: points[e.0 as usize].expect("a thread event").index,
                clock: view.clock().to_vec(),
            };
            match kind {
                FenceKind::ProxyAsync { space } => {
                    fences.entry(t).or_default().push((space, fence))
                }
                FenceKind::TensormapRelease => releases.entry(t).or_default().push(fence),
                FenceKind::TensormapAcquire { addr } => {
                    acquires.entry(t).or_default().push((addr, fence))
                }
                FenceKind::Tcgen05BeforeThreadSync | FenceKind::Tcgen05AfterThreadSync => {}
            }
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
                    if access.mode == AccessMode::Write {
                        generic.entry(location).or_default().insert(actor, e);
                        continue;
                    }
                    for &a in unfenced.get(&location).into_iter().flat_map(|w| w.values()) {
                        if !checked.insert((a, e)) {
                            continue;
                        }
                        let threads = [graph.acting_thread(a), graph.acting_thread(e)];
                        if fence_covers(graph, &points, &fences, view, a, threads, location.space) {
                            covered_pairs += 1;
                        } else {
                            unproved = Some(ProxyOrderViolation {
                                kind: ConflictKind::WriteRead,
                                location,
                                generic: e,
                                asynchronous: a,
                                missing: MissingFence::ProxyAsync,
                            });
                            return;
                        }
                    }
                }
            }
            Proxy::Async => {
                if let ExecContext::Async(op) = ev.ctx
                    && access.mode == AccessMode::Write
                    && !completion_implies_proxy_fence(graph.async_op(op).kind)
                {
                    for location in bytes(access) {
                        unfenced.entry(location).or_default().insert(op, e);
                    }
                }
                if access.mode == AccessMode::Write {
                    return;
                }
                for location in bytes(access) {
                    let Some(writers) = generic.get(&location) else {
                        continue;
                    };
                    for &a in writers.values() {
                        if !checked.insert((a, e)) {
                            continue;
                        }
                        let threads = [graph.acting_thread(a), Some(access.attributed)];
                        if fence_covers(graph, &points, &fences, view, a, threads, location.space) {
                            covered_pairs += 1;
                        } else {
                            unproved = Some(ProxyOrderViolation {
                                kind: ConflictKind::WriteRead,
                                location,
                                generic: a,
                                asynchronous: e,
                                missing: MissingFence::ProxyAsync,
                            });
                            return;
                        }
                    }
                }
            }
            Proxy::TensorMap => {
                let reader = access.attributed;
                for location in bytes(access) {
                    let Some(writers) = generic.get(&location) else {
                        continue;
                    };
                    let acquire = acquires.get(&reader).and_then(|fs| {
                        fs.iter()
                            .rev()
                            .filter(|(_, f)| f.index <= view.clock()[reader.0 as usize])
                            .find(|&&(map, _)| {
                                location.space == Space::Global
                                    && (map..map + TENSOR_MAP_BYTES).contains(&location.addr)
                            })
                            .map(|(_, f)| f)
                    });
                    for &a in writers.values() {
                        if !checked.insert((a, e)) {
                            continue;
                        }
                        let missing = match acquire {
                            None => Some(MissingFence::TensormapAcquire),
                            Some(q) => {
                                let writer = graph.acting_thread(a).expect("an access acts");
                                let release = releases.get(&writer).and_then(|fs| {
                                    fs.iter()
                                        .rev()
                                        .find(|r| r.index <= q.clock[writer.0 as usize])
                                });
                                match release {
                                    Some(r) if reaches_fence(graph, &points, view, a, r) => None,
                                    _ => Some(MissingFence::TensormapRelease),
                                }
                            }
                        };
                        match missing {
                            None => covered_pairs += 1,
                            Some(missing) => {
                                unproved = Some(ProxyOrderViolation {
                                    kind: ConflictKind::WriteRead,
                                    location,
                                    generic: a,
                                    asynchronous: e,
                                    missing,
                                });
                                return;
                            }
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

/// Whether observing the operation's completion orders its async-proxy writes before later
/// generic accesses: the PTX ISA (9.7.9.25.2) states the implicit fence for bulk async copies.
fn completion_implies_proxy_fence(kind: AsyncOpKind) -> bool {
    match kind {
        // A bulk async-group wait completes a TMA store's reads (or its writes)
        // for the waiting thread like the mbarrier completion of the loads.
        AsyncOpKind::BulkCopy
        | AsyncOpKind::TensorCopy
        | AsyncOpKind::TensorStoreRead
        | AsyncOpKind::TensorStoreWrite
        | AsyncOpKind::ClcResponse => true,
        AsyncOpKind::CpAsync
        | AsyncOpKind::Tcgen05Mma
        | AsyncOpKind::Tcgen05Ld
        | AsyncOpKind::Tcgen05St
        | AsyncOpKind::WgmmaMma { .. } => false,
    }
}

/// The latest fence of `thread` over `space` with `(f, b) ∈ R`, i.e. within `known` of the
/// thread's events.
fn latest_fence(
    fences: &HashMap<ThreadIx, Vec<(Option<Space>, Fence)>>,
    thread: ThreadIx,
    space: Space,
    known: u32,
) -> Option<&Fence> {
    fences
        .get(&thread)?
        .iter()
        .rev()
        .filter(|(_, f)| f.index <= known)
        .find(|(s, _)| s.is_none_or(|s| s == space))
        .map(|(_, f)| f)
}

/// Some `fence.proxy.async` over `space` on one of `threads` lies between `a` and the effect
/// being visited: `(a, f) ∈ R` and `(f, b) ∈ R`.
fn fence_covers(
    graph: &EventGraph,
    points: &[Option<ThreadPoint>],
    fences: &HashMap<ThreadIx, Vec<(Option<Space>, Fence)>>,
    view: &crate::relation::HbView,
    a: EventId,
    threads: [Option<ThreadIx>; 2],
    space: Space,
) -> bool {
    threads.into_iter().flatten().any(|t| {
        latest_fence(fences, t, space, view.clock()[t.0 as usize])
            .is_some_and(|f| reaches_fence(graph, points, view, a, f))
    })
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
