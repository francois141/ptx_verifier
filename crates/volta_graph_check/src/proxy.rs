//! **Cross-proxy ordering.**
//!
//! * Property: every async-proxy read of shared memory that reads from a generic-proxy write
//!   (its candidate read-from: the last write to the byte before the read, in trace order) is
//!   covered by a `fence.proxy.async` over shared memory, issued by the writer or by the
//!   reading thread, with the write happening before the fence and the fence happening before
//!   the read. The writer's fence before the synchronization that publishes the write (the
//!   PTX ISA's TMA pattern) and the reader's fence after synchronizing with it both qualify;
//!   neither is required textually.
//! * Scope: targets with an async proxy (`Assumption::AsyncProxy`, sm_90+); elsewhere there
//!   is no obligation. Not modeled, so not obligations here: async-proxy writes after generic
//!   accesses, and the tensormap proxy. An async write needs no fence before a generic read:
//!   its observed completion makes it visible (PTX ISA 9.7.9.25.2).
//! * Uses: shared-memory effects' proxy, mode, footprint and context, `fence.proxy.async`
//!   events, happens-before through the certified edges.
//! * Prerequisites: the barrier and async-completion certificates (happens-before admits only
//!   their edges); a well-formed graph.
//! * `Pass`: every obligation covered (vacuously when the target has no async proxy, or no
//!   async read observes a generic write). `Fail`: an obligation uncovered even through every
//!   candidate edge, with the write, the read and the byte. `Unknown`: covered only through
//!   unvalidated edges. The certificate lists the covered (write, read) pairs.

use std::collections::{BTreeMap, HashMap, HashSet};

use volta_graph::{
    AccessId, AccessMode, Assumption, EventGraph, EventId, EventKind, ExecContext, FenceKind,
    Footprint, Proxy, Space, ThreadIx,
};

use crate::async_completion::CompletionCertificate;
use crate::barrier::SyncCertificate;
use crate::hb::{Admission, ThreadPoint, sweep, thread_points};
use crate::result::{PropertyResult, Unresolved};

/// The generic-write -> async-read pairs whose proxy transition is covered.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct ProxyCertificate {
    pub covered: HashSet<(AccessId, AccessId)>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProxyEvidence {
    pub obligations: usize,
    /// No async proxy on the target, so nothing was required.
    pub vacuous: bool,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProxyViolation {
    pub write: EventId,
    pub read: EventId,
    pub addr: u64,
}

pub type ProxyResult = PropertyResult<ProxyEvidence, ProxyViolation>;

/// One generic write observed by one async-proxy read.
#[derive(Debug, Clone, Copy)]
struct Obligation {
    write: EventId,
    read: EventId,
    addr: u64,
}

pub fn check_proxy(
    graph: &EventGraph,
    sync: &SyncCertificate,
    completion: &CompletionCertificate,
) -> (ProxyResult, ProxyCertificate) {
    if graph.validate().is_err() {
        return (
            PropertyResult::Unknown(vec![Unresolved::global("the graph is not well-formed")]),
            ProxyCertificate::default(),
        );
    }
    if !graph.provenance().assumes(Assumption::AsyncProxy) {
        return (
            PropertyResult::Pass(ProxyEvidence {
                obligations: 0,
                vacuous: true,
            }),
            ProxyCertificate::default(),
        );
    }
    let obligations = collect_obligations(graph);
    let admitted = Admission {
        generations: sync.generations.clone(),
        completions: completion.completions.clone(),
        exited_threads: true,
    };
    let covered = covered_obligations(graph, &obligations, &admitted);
    let mut certificate = ProxyCertificate::default();
    let mut uncovered = Vec::new();
    for (i, o) in obligations.iter().enumerate() {
        if covered.contains(&i) {
            certificate
                .covered
                .insert((access_of(graph, o.write), access_of(graph, o.read)));
        } else {
            uncovered.push(i);
        }
    }
    let candidate =
        if uncovered.is_empty() || (sync.generations.is_all() && completion.completions.is_all()) {
            HashSet::new()
        } else {
            covered_obligations(graph, &obligations, &Admission::candidate())
        };
    let mut violations = Vec::new();
    let mut unresolved = Vec::new();
    for i in uncovered {
        let o = obligations[i];
        if candidate.contains(&i) {
            unresolved.push(Unresolved::at(
                o.read,
                "the proxy fence covers this async read only through unvalidated synchronization",
            ));
        } else {
            violations.push(ProxyViolation {
                write: o.write,
                read: o.read,
                addr: o.addr,
            });
        }
    }
    violations.sort_by_key(|v| v.read);
    (
        PropertyResult::from_findings(
            ProxyEvidence {
                obligations: obligations.len(),
                vacuous: false,
            },
            violations,
            unresolved,
        ),
        certificate,
    )
}

fn access_of(graph: &EventGraph, event: EventId) -> AccessId {
    match graph.event(event).kind {
        EventKind::Access(a) => a,
        _ => unreachable!("obligations name access events"),
    }
}

/// Every (generic write, async read) read-from pair over shared bytes, one per pair with its
/// lowest byte, in trace order.
fn collect_obligations(graph: &EventGraph) -> Vec<Obligation> {
    let mut last_write: HashMap<u64, (EventId, Proxy)> = HashMap::new();
    let mut obligations = Vec::new();
    for (id, ev) in graph.events().iter() {
        let EventKind::Access(a) = ev.kind else {
            continue;
        };
        let access = graph.access(a);
        let Footprint::Bytes { addr, width } = access.footprint else {
            continue;
        };
        if access.space != Space::Shared {
            continue;
        }
        match access.mode {
            AccessMode::Write => {
                for byte in addr..addr + u64::from(width) {
                    last_write.insert(byte, (id, access.proxy));
                }
            }
            AccessMode::Read if access.proxy == Proxy::Async => {
                let mut seen: BTreeMap<EventId, u64> = BTreeMap::new();
                for byte in addr..addr + u64::from(width) {
                    if let Some(&(w, Proxy::Generic)) = last_write.get(&byte) {
                        seen.entry(w).or_insert(byte);
                    }
                }
                for (write, byte) in seen {
                    obligations.push(Obligation {
                        write,
                        read: id,
                        addr: byte,
                    });
                }
            }
            AccessMode::Read => {}
        }
    }
    obligations
}

/// Shared-memory proxy fences, per thread, as `(event, point)` in program order.
fn proxy_fences(
    graph: &EventGraph,
    points: &[Option<ThreadPoint>],
) -> HashMap<ThreadIx, Vec<(EventId, ThreadPoint)>> {
    let mut fences: HashMap<ThreadIx, Vec<(EventId, ThreadPoint)>> = HashMap::new();
    for (id, ev) in graph.events().iter() {
        if let (ExecContext::Thread(t), EventKind::Fence(FenceKind::ProxyAsync { space })) =
            (ev.ctx, ev.kind)
            && space.is_none_or(|s| s == Space::Shared)
        {
            fences
                .entry(t)
                .or_default()
                .push((id, points[id.0 as usize].expect("a thread event")));
        }
    }
    fences
}

/// The obligations some writer or reader fence covers under `admission`: write hb fence and
/// fence hb read.
fn covered_obligations(
    graph: &EventGraph,
    obligations: &[Obligation],
    admission: &Admission,
) -> HashSet<usize> {
    let points = thread_points(graph);
    let fences = proxy_fences(graph, &points);
    // fence event -> obligations asking "does the write happen before this fence?"
    let mut at_fence: HashMap<EventId, Vec<usize>> = HashMap::new();
    for (i, o) in obligations.iter().enumerate() {
        let threads = [graph.acting_thread(o.write), graph.acting_thread(o.read)];
        for t in threads.into_iter().flatten() {
            for &(f, _) in fences.get(&t).map_or(&[][..], Vec::as_slice) {
                if o.write < f && f < o.read {
                    at_fence.entry(f).or_default().push(i);
                }
            }
        }
    }
    let mut write_before_fence: HashMap<usize, Vec<ThreadPoint>> = HashMap::new();
    let mut at_read: HashMap<EventId, Vec<usize>> = HashMap::new();
    for (i, o) in obligations.iter().enumerate() {
        at_read.entry(o.read).or_default().push(i);
    }
    let mut covered = HashSet::new();
    sweep(graph, admission, |e, view| {
        if let Some(asked) = at_fence.get(&e) {
            for &i in asked {
                let write = obligations[i].write;
                let ordered = match graph.event(write).ctx {
                    ExecContext::Thread(_) => view.thread_hb(points[write.0 as usize].unwrap()),
                    ExecContext::Async(op) => view.effects_hb(op),
                    ExecContext::Generation(_) => false,
                };
                if ordered {
                    write_before_fence
                        .entry(i)
                        .or_default()
                        .push(points[e.0 as usize].unwrap());
                }
            }
        }
        if let Some(asked) = at_read.get(&e) {
            for &i in asked {
                if write_before_fence
                    .get(&i)
                    .is_some_and(|fs| fs.iter().any(|&f| view.thread_hb(f)))
                {
                    covered.insert(i);
                }
            }
        }
    });
    covered
}
