//! **Resource lifetime.**
//!
//! * Resources with a lifetime in the graph: Tensor Memory allocations (`tcgen05.alloc` to
//!   the `tcgen05.dealloc` it overlaps; the interpreter requires an exact match) and mbarrier
//!   objects (`init` to `inval`; a re-initialization is a new object). Shared and global
//!   memory live for the CTA and the launch: reusing them is a memory conflict, the
//!   memory-conflict checker's obligation.
//! * Rules. Each lifts to every schedule a check the interpreter applies to its own schedule
//!   (no access to unallocated columns, no operation on a non-live mbarrier, no ordinary data
//!   over a live mbarrier), or the removed detector's rule that a dealloc must not race
//!   in-flight `tcgen05` operations:
//!   (T1) every effect on columns a dealloc frees happens before the dealloc, an async effect
//!   through its observed completion; (T2) the allocation providing a column happens before
//!   every effect on it; (M1) every operation on an mbarrier happens before its inval; (M2)
//!   every memory effect on an mbarrier's 8 bytes happens before its init or after its inval.
//!   An operation not ordered after its mbarrier's init is unresolved, not failed: how an
//!   init is published to other threads (`fence.mbarrier_init`, a barrier) is not modeled,
//!   and the interpreter's semantics accept a wait that races the init.
//! * Unresolved by design, since no justified theory is available: Tensor Memory still allocated,
//!   and async operations never observed complete, when the execution completes (whether CTA
//!   exit frees or waits for them is not modeled); an mbarrier re-initialized without an
//!   `inval`. These end-of-execution obligations arise only for a completed execution; the
//!   progress checker reports the others. Not recorded, so not checked:
//!   `tcgen05.relinquish_alloc_permit`, and the allocator's ordering of a dealloc before a
//!   later allocation of the same columns.
//! * Uses: `TmemAlloc`/`TmemDealloc` events, Tensor Memory and shared-memory effects, mbarrier
//!   objects and their init/inval events, generations' contributions and releases,
//!   `WaitStart` events, async ops' tracking, the terminal state.
//! * Prerequisites: a well-formed graph; the barrier and async-completion certificates.
//! * `Pass`: every rule holds through validated edges (vacuously without such resources).
//!   `Fail`: a rule broken through every candidate edge, once per obligation and actor, with
//!   the resource event and the use. `Unknown`: a rule that holds only through unvalidated
//!   edges, or an unresolved obligation above.

use std::collections::{BTreeMap, HashMap, HashSet};

use volta_graph::{
    AccessMode, Assumption, AsyncOpId, ContributionKind, EventGraph, EventId, EventKind,
    ExecContext, Footprint, Space, SyncObjectId, SyncObjectKind, Terminal, ThreadIx,
};

use crate::async_completion::CompletionCertificate;
use crate::barrier::SyncCertificate;
use crate::hb::{Admission, HbView, ThreadPoint, sweep, thread_points};
use crate::result::{PropertyResult, Unresolved};

/// The size of an mbarrier object (`.b64`).
const MBARRIER_BYTES: u64 = 8;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum LifetimeViolation {
    /// (T1) `effect`, on columns `dealloc` frees, is not ordered before it.
    FreedWhileInUse { dealloc: EventId, effect: EventId },
    /// (T2) `effect` is not ordered after the allocation `alloc` providing its columns.
    UsedBeforeAllocation { alloc: EventId, effect: EventId },
    /// (T2) `effect` touches columns no live allocation provides in the candidate trace.
    Unallocated { effect: EventId },
    /// A dealloc of columns no live allocation holds in the candidate trace.
    FreesUnallocated { dealloc: EventId },
    /// (M1) `event` operates on `object` but is not ordered after its init or before its
    /// inval (`bound`).
    OutsideObjectLifetime {
        object: SyncObjectId,
        bound: EventId,
        event: EventId,
    },
    /// (M2) `effect` on `object`'s bytes is not ordered before its init or after its inval
    /// (`bound`), or lies inside its lifetime in the candidate trace (`bound` is `None`).
    ObjectMemoryAccess {
        object: SyncObjectId,
        bound: Option<EventId>,
        effect: EventId,
    },
}

impl LifetimeViolation {
    /// The trace position at which the violation is observable.
    pub fn position(&self) -> EventId {
        match *self {
            LifetimeViolation::FreedWhileInUse { dealloc, effect } => dealloc.max(effect),
            LifetimeViolation::UsedBeforeAllocation { alloc, effect } => alloc.max(effect),
            LifetimeViolation::Unallocated { effect } => effect,
            LifetimeViolation::FreesUnallocated { dealloc } => dealloc,
            LifetimeViolation::OutsideObjectLifetime { bound, event, .. } => bound.max(event),
            LifetimeViolation::ObjectMemoryAccess { bound, effect, .. } => {
                bound.map_or(effect, |b| b.max(effect))
            }
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LifetimeEvidence {
    pub tmem_allocations: usize,
    pub mbarrier_objects: usize,
    /// Ordering obligations discharged.
    pub obligations: u64,
}

pub type LifetimeResult = PropertyResult<LifetimeEvidence, LifetimeViolation>;

pub fn check_lifetimes(
    graph: &EventGraph,
    sync: &SyncCertificate,
    completion: &CompletionCertificate,
) -> LifetimeResult {
    if graph.validate().is_err() {
        return PropertyResult::Unknown(vec![Unresolved::global("the graph is not well-formed")]);
    }
    let exited_threads = graph.provenance().assumes(Assumption::ExitedThreadsArrive);
    let admitted = Admission {
        generations: sync.generations.clone(),
        completions: completion.completions.clone(),
        exited_threads,
    };
    let resources = Resources::of(graph);
    let (found, evidence) = resources.run(graph, &admitted);
    let fully_validated = sync.generations.is_all() && completion.completions.is_all();
    let definite = if fully_validated || found.is_empty() {
        found.clone()
    } else {
        let candidate = Admission {
            exited_threads,
            ..Admission::candidate()
        };
        resources.run(graph, &candidate).0
    };
    let (unpublished, found): (Vec<_>, Vec<_>) =
        found.into_iter().partition(|v| races_the_init(graph, v));
    let definite: Vec<_> = definite
        .into_iter()
        .filter(|v| !races_the_init(graph, v))
        .collect();
    let definite_keys: HashSet<_> = definite.iter().map(|&v| key(graph, v)).collect();
    let mut unresolved = resources.unresolved(graph);
    for v in &unpublished {
        unresolved.push(Unresolved::at(
            v.position(),
            format!(
                "{v:?}: the operation is not ordered after the mbarrier's init, and how an init \
                 is published to other threads is not modeled"
            ),
        ));
    }
    for &v in &found {
        if !definite_keys.contains(&key(graph, v)) {
            unresolved.push(Unresolved::at(
                v.position(),
                format!("{v:?} is ordered only through unvalidated synchronization"),
            ));
        }
    }
    unresolved.sort_by_key(|u| u.event);
    PropertyResult::from_findings(evidence, definite, unresolved)
}

/// An (M1) violation whose bound is the object's init.
fn races_the_init(graph: &EventGraph, v: &LifetimeViolation) -> bool {
    matches!(*v, LifetimeViolation::OutsideObjectLifetime { bound, .. }
        if matches!(graph.event(bound).kind, EventKind::ObjectInit(_)))
}

/// Who performed a use: a thread at a point, or an async op.
#[derive(Debug, Clone, Copy)]
enum By {
    Thread(ThreadPoint),
    Op(AsyncOpId),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Actor {
    Thread(ThreadIx),
    Op(AsyncOpId),
}

impl By {
    fn actor(self) -> Actor {
        match self {
            By::Thread(p) => Actor::Thread(p.thread),
            By::Op(op) => Actor::Op(op),
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct Use {
    event: EventId,
    by: By,
    write: bool,
}

impl Use {
    /// Whether the use happens before the visited event; an async use through its observed
    /// completion.
    fn before(&self, view: &HbView) -> bool {
        match self.by {
            By::Thread(p) => view.thread_hb(p),
            By::Op(op) => view.effects_hb(op),
        }
    }
}

/// Uses, one per actor: a thread's latest (program order orders its earlier ones), an op's
/// first write or else its first effect (its effects are ordered alike).
#[derive(Debug, Clone, Default)]
struct UseSet {
    uses: Vec<Use>,
    slot: HashMap<Actor, usize>,
}

impl UseSet {
    fn insert(&mut self, u: Use) {
        match self.slot.get(&u.by.actor()) {
            Some(&i) => {
                let kept = &mut self.uses[i];
                if matches!(u.by, By::Thread(_)) || (u.write && !kept.write) {
                    *kept = u;
                }
            }
            None => {
                self.slot.insert(u.by.actor(), self.uses.len());
                self.uses.push(u);
            }
        }
    }
}

struct Allocation {
    event: EventId,
    point: ThreadPoint,
    start: u16,
    cols: u16,
    uses: UseSet,
}

impl Allocation {
    fn overlap(&self, col: u16, cols: u16) -> u32 {
        let lo = u32::from(self.start).max(u32::from(col));
        let hi =
            (u32::from(self.start) + u32::from(self.cols)).min(u32::from(col) + u32::from(cols));
        hi.saturating_sub(lo)
    }
}

struct MbarrierObject {
    id: SyncObjectId,
    addr: u64,
    init: Option<EventId>,
    inval: Option<EventId>,
    /// Its inval, or else the next init at its address (a re-initialization).
    end: Option<EventId>,
}

impl MbarrierObject {
    fn contains(&self, e: EventId) -> bool {
        self.init.is_some_and(|i| i < e) && self.end.is_none_or(|end| e < end)
    }
}

/// The resources of a graph and which events use them, independent of any admission.
struct Resources {
    points: Vec<Option<ThreadPoint>>,
    objects: Vec<MbarrierObject>,
    /// Per mbarrier address, its objects in init order.
    by_addr: BTreeMap<u64, Vec<usize>>,
    /// (M1) Per event, the objects it operates on.
    operations: HashMap<EventId, Vec<usize>>,
    tmem: bool,
    allocations: usize,
}

impl Resources {
    fn of(graph: &EventGraph) -> Self {
        let mut objects: Vec<MbarrierObject> = Vec::new();
        let mut index: HashMap<SyncObjectId, usize> = HashMap::new();
        for (id, o) in graph.objects().iter() {
            if let SyncObjectKind::Mbarrier { addr, .. } = o.kind {
                index.insert(id, objects.len());
                objects.push(MbarrierObject {
                    id,
                    addr,
                    init: o.init,
                    inval: o.inval,
                    end: o.inval,
                });
            }
        }
        let mut by_addr: BTreeMap<u64, Vec<usize>> = BTreeMap::new();
        for (i, o) in objects.iter().enumerate() {
            by_addr.entry(o.addr).or_default().push(i);
        }
        for list in by_addr.values_mut() {
            list.sort_by_key(|&i| objects[i].init);
            for w in 0..list.len().saturating_sub(1) {
                let (this, next) = (list[w], list[w + 1]);
                if objects[this].inval.is_none() {
                    objects[this].end = objects[next].init;
                }
            }
        }
        let mut operations: HashMap<EventId, Vec<usize>> = HashMap::new();
        for g in graph.generations().values() {
            let Some(&i) = index.get(&g.object) else {
                continue;
            };
            for c in &g.contributions {
                if c.kind != ContributionKind::Exited {
                    operations.entry(c.event).or_default().push(i);
                }
            }
            for &r in &g.releases {
                operations.entry(r).or_default().push(i);
            }
        }
        let mut tmem = false;
        let mut allocations = 0;
        for (id, ev) in graph.events().iter() {
            match ev.kind {
                EventKind::WaitStart { object, .. } | EventKind::ObjectInval(object) => {
                    if let Some(&i) = index.get(&object) {
                        operations.entry(id).or_default().push(i);
                    }
                }
                EventKind::TmemAlloc { .. } => {
                    tmem = true;
                    allocations += 1;
                }
                EventKind::TmemDealloc { .. } => tmem = true,
                EventKind::Access(a) if graph.access(a).space == Space::Tensor => tmem = true,
                _ => {}
            }
        }
        Resources {
            points: thread_points(graph),
            objects,
            by_addr,
            operations,
            tmem,
            allocations,
        }
    }

    fn point(&self, e: EventId) -> ThreadPoint {
        self.points[e.0 as usize].expect("a thread event")
    }

    fn by(&self, graph: &EventGraph, e: EventId) -> By {
        match graph.event(e).ctx {
            ExecContext::Thread(_) => By::Thread(self.point(e)),
            ExecContext::Async(op) => By::Op(op),
            ExecContext::Generation(_) => unreachable!("uses are thread or async events"),
        }
    }

    /// The mbarrier addresses whose 8 bytes `[addr, addr + width)` overlaps.
    fn slots(&self, addr: u64, width: u32) -> impl Iterator<Item = u64> + '_ {
        let from = addr.saturating_sub(MBARRIER_BYTES - 1);
        let to = addr.saturating_add(u64::from(width));
        self.by_addr.range(from..to).map(|(&a, _)| a)
    }

    /// The violations under `admission`, deduplicated per obligation and actor (first in
    /// trace order), and the evidence.
    fn run(
        &self,
        graph: &EventGraph,
        admission: &Admission,
    ) -> (Vec<LifetimeViolation>, LifetimeEvidence) {
        let mut evidence = LifetimeEvidence {
            tmem_allocations: self.allocations,
            mbarrier_objects: self.objects.len(),
            obligations: 0,
        };
        if !self.tmem && self.objects.is_empty() {
            return (Vec::new(), evidence);
        }
        let mut violations = Vec::new();
        let mut live: Vec<Allocation> = Vec::new();
        let mut object_uses: Vec<UseSet> = vec![UseSet::default(); self.objects.len()];
        let mut data_effects: HashMap<u64, UseSet> = HashMap::new();
        sweep(graph, admission, |e, view| {
            let mut obligation = |holds: bool, violation: LifetimeViolation| {
                evidence.obligations += 1;
                if !holds {
                    violations.push(violation);
                }
            };
            match graph.event(e).kind {
                EventKind::TmemAlloc {
                    start_col,
                    num_cols,
                } => live.push(Allocation {
                    event: e,
                    point: self.point(e),
                    start: start_col,
                    cols: num_cols,
                    uses: UseSet::default(),
                }),
                EventKind::TmemDealloc {
                    start_col,
                    num_cols,
                } => {
                    let before = live.len();
                    for a in live.iter().filter(|a| a.overlap(start_col, num_cols) > 0) {
                        for u in &a.uses.uses {
                            obligation(
                                u.before(view),
                                LifetimeViolation::FreedWhileInUse {
                                    dealloc: e,
                                    effect: u.event,
                                },
                            );
                        }
                    }
                    live.retain(|a| a.overlap(start_col, num_cols) == 0);
                    if live.len() == before {
                        obligation(false, LifetimeViolation::FreesUnallocated { dealloc: e });
                    }
                }
                EventKind::Access(a) => {
                    let access = graph.access(a);
                    let u = Use {
                        event: e,
                        by: self.by(graph, e),
                        write: access.mode == AccessMode::Write,
                    };
                    match (access.space, access.footprint) {
                        (Space::Tensor, Footprint::Tensor { col, cols, .. }) => {
                            let mut covered = 0;
                            for alloc in live.iter_mut() {
                                let overlap = alloc.overlap(col, cols);
                                if overlap == 0 {
                                    continue;
                                }
                                covered += overlap;
                                obligation(
                                    view.thread_hb(alloc.point),
                                    LifetimeViolation::UsedBeforeAllocation {
                                        alloc: alloc.event,
                                        effect: e,
                                    },
                                );
                                alloc.uses.insert(u);
                            }
                            if covered < u32::from(cols) {
                                obligation(false, LifetimeViolation::Unallocated { effect: e });
                            }
                        }
                        (Space::Shared, Footprint::Bytes { addr, width }) => {
                            for slot in self.slots(addr, width) {
                                for &i in &self.by_addr[&slot] {
                                    let o = &self.objects[i];
                                    if o.contains(e) {
                                        obligation(
                                            false,
                                            LifetimeViolation::ObjectMemoryAccess {
                                                object: o.id,
                                                bound: None,
                                                effect: e,
                                            },
                                        );
                                    } else if let Some(inval) = o.inval
                                        && inval < e
                                    {
                                        obligation(
                                            view.thread_hb(self.point(inval)),
                                            LifetimeViolation::ObjectMemoryAccess {
                                                object: o.id,
                                                bound: Some(inval),
                                                effect: e,
                                            },
                                        );
                                    }
                                }
                                data_effects.entry(slot).or_default().insert(u);
                            }
                        }
                        _ => {}
                    }
                }
                EventKind::ObjectInit(object) => {
                    for o in self.objects.iter().filter(|o| o.id == object) {
                        for u in data_effects.get(&o.addr).map_or(&[][..], |s| &s.uses) {
                            obligation(
                                u.before(view),
                                LifetimeViolation::ObjectMemoryAccess {
                                    object,
                                    bound: Some(e),
                                    effect: u.event,
                                },
                            );
                        }
                    }
                }
                _ => {}
            }
            for &i in self.operations.get(&e).map_or(&[][..], Vec::as_slice) {
                let o = &self.objects[i];
                if let Some(init) = o.init {
                    obligation(
                        init < e && view.thread_hb(self.point(init)),
                        LifetimeViolation::OutsideObjectLifetime {
                            object: o.id,
                            bound: init,
                            event: e,
                        },
                    );
                }
                match o.inval {
                    Some(inval) if inval == e => {
                        for u in &object_uses[i].uses {
                            obligation(
                                u.before(view),
                                LifetimeViolation::OutsideObjectLifetime {
                                    object: o.id,
                                    bound: e,
                                    event: u.event,
                                },
                            );
                        }
                    }
                    Some(inval) if inval < e => obligation(
                        false,
                        LifetimeViolation::OutsideObjectLifetime {
                            object: o.id,
                            bound: inval,
                            event: e,
                        },
                    ),
                    _ => object_uses[i].insert(Use {
                        event: e,
                        by: self.by(graph, e),
                        write: false,
                    }),
                }
            }
        });
        let mut seen = HashSet::new();
        violations.retain(|&v| seen.insert(key(graph, v)));
        violations.sort_by_key(LifetimeViolation::position);
        (violations, evidence)
    }

    /// The obligations no rule here can discharge.
    fn unresolved(&self, graph: &EventGraph) -> Vec<Unresolved> {
        let mut unresolved = Vec::new();
        for list in self.by_addr.values() {
            for w in list.windows(2) {
                let (this, next) = (&self.objects[w[0]], &self.objects[w[1]]);
                if this.inval.is_none()
                    && let Some(init) = next.init
                {
                    unresolved.push(Unresolved::at(
                        init,
                        format!(
                            "the mbarrier at {:#x} is re-initialized without mbarrier.inval \
                             (not modeled)",
                            next.addr
                        ),
                    ));
                }
            }
        }
        if *graph.terminal() != Terminal::Completed {
            return unresolved;
        }
        let mut live: Vec<(EventId, u16, u16)> = Vec::new();
        for (id, ev) in graph.events().iter() {
            match ev.kind {
                EventKind::TmemAlloc {
                    start_col,
                    num_cols,
                } => live.push((id, start_col, num_cols)),
                EventKind::TmemDealloc {
                    start_col,
                    num_cols,
                } => live.retain(|&(_, s, n)| {
                    let (s, n, d, dn) = (
                        u32::from(s),
                        u32::from(n),
                        u32::from(start_col),
                        u32::from(num_cols),
                    );
                    s + n <= d || d + dn <= s
                }),
                _ => {}
            }
        }
        for (alloc, start, cols) in live {
            unresolved.push(Unresolved::at(
                alloc,
                format!(
                    "Tensor Memory columns {start}..{} are still allocated when the execution \
                     completes; deallocation before CTA exit is not checked",
                    u32::from(start) + u32::from(cols)
                ),
            ));
        }
        for op in graph.async_ops().values() {
            let observed = op
                .tracking
                .iter()
                .any(|&g| !graph.generation(g).releases.is_empty());
            if !observed {
                unresolved.push(Unresolved::at(
                    op.issue,
                    format!(
                        "{:?} is never observed complete; whether CTA exit waits for it is not \
                         modeled",
                        op.kind
                    ),
                ));
            }
        }
        unresolved
    }
}

/// One finding per obligation and actor: the violation with its use erased, and who used.
fn key(graph: &EventGraph, v: LifetimeViolation) -> (LifetimeViolation, Actor) {
    const ERASED: EventId = EventId(u32::MAX);
    let actor = |e: EventId| match graph.event(e).ctx {
        ExecContext::Async(op) => Actor::Op(op),
        _ => Actor::Thread(graph.acting_thread(e).unwrap_or(ThreadIx(u32::MAX))),
    };
    match v {
        LifetimeViolation::FreedWhileInUse { dealloc, effect } => (
            LifetimeViolation::FreedWhileInUse {
                dealloc,
                effect: ERASED,
            },
            actor(effect),
        ),
        LifetimeViolation::UsedBeforeAllocation { alloc, effect } => (
            LifetimeViolation::UsedBeforeAllocation {
                alloc,
                effect: ERASED,
            },
            actor(effect),
        ),
        LifetimeViolation::Unallocated { effect } => (
            LifetimeViolation::Unallocated { effect: ERASED },
            actor(effect),
        ),
        LifetimeViolation::FreesUnallocated { dealloc } => (v, actor(dealloc)),
        LifetimeViolation::OutsideObjectLifetime {
            object,
            bound,
            event,
        } => (
            LifetimeViolation::OutsideObjectLifetime {
                object,
                bound,
                event: ERASED,
            },
            actor(event),
        ),
        LifetimeViolation::ObjectMemoryAccess {
            object,
            bound,
            effect,
        } => (
            LifetimeViolation::ObjectMemoryAccess {
                object,
                bound,
                effect: ERASED,
            },
            actor(effect),
        ),
    }
}
