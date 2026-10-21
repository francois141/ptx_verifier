//! **Memory-conflict obligations** (§1.3, Algorithm 2): every overlapping pair of effects of
//! `M` with at least one write is ordered in `G_HB`, in one direction.
//!
//! ```text
//! B <- {};  R <- TRANSITIVECLOSURE(G_HB)
//! for all unordered pairs {a, b} ⊆ M, a != b:
//!     if not OVERLAP(a, b) then continue
//!     if not WRITE(a) and not WRITE(b) then continue
//!     if (a, b) not in R and (b, a) not in R then B <- B ∪ {{a, b}}
//! return B
//! ```
//!
//! * `M` ([`crate::domain`]): the ordinary effects on global and shared memory, asynchronous
//!   ones at their memory-effect events; Tensor Memory effects belong to Algorithm 4.
//!   `OVERLAP` intersects byte ranges in one space (one CTA, so one owner).
//! * `R` is [`ValidatedGraph`]'s closure. Every edge runs forward in the trace, so of a pair
//!   only the earlier effect can reach the later one. Equal values stored concurrently are
//!   still a conflict: the algorithm has no exception for them.
//! * The pairs are enumerated per byte without visiting every ordered one: each location keeps
//!   its effects as a forest in which an effect's children were ordered before it when it
//!   arrived, so an earlier effect reaching the new one vouches for its whole subtree. `B` is
//!   still exact: every unordered pair is found, each once, at its lowest shared byte.
//! * `Pass`: `B = {}`; only then is [`MemoryConflictFree`] issued (Algorithm 3's
//!   prerequisite). `Fail`: `B`, ordered by the later effect (at most [`CONFLICT_CAP`]
//!   pairs are listed). `Unknown`: an atomic or reduction effect, outside the initial
//!   contract (§2).

use std::collections::{HashMap, HashSet};

use volta_graph::{AccessMode, AsyncOpId, EventGraph, EventId, EventKind, ExecContext};

use crate::domain::{ByteLocation, ConflictKind, bytes, in_m, outside_contract, written_bytes};
use crate::relation::{HbView, ThreadPoint, ValidatedGraph, thread_points};
use crate::result::{PropertyResult, Unresolved};

/// Pairs listed beyond which a failing check stops collecting.
pub const CONFLICT_CAP: usize = 4096;

/// One pair of `B`: `earlier` and `later` in trace order, first overlapping at `location`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct MemoryConflict {
    pub kind: ConflictKind,
    pub location: ByteLocation,
    pub earlier: EventId,
    pub later: EventId,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MemoryConflictEvidence {
    /// `|M|`.
    pub effects: usize,
    /// Bytes some effect of `M` writes.
    pub written_bytes: usize,
}

pub type MemoryConflictResult = PropertyResult<MemoryConflictEvidence, MemoryConflict>;

/// Algorithm 2 returned `B = {}` on `graph`.
#[derive(Debug, Clone, Copy)]
pub struct MemoryConflictFree<'g> {
    graph: &'g EventGraph,
}

impl<'g> MemoryConflictFree<'g> {
    /// The certificate under the caller's assertion that Algorithm 2 passed on `h`, for
    /// running Algorithm 3 in isolation.
    pub fn assuming(h: &ValidatedGraph<'g>) -> Self {
        MemoryConflictFree { graph: h.graph() }
    }

    pub fn graph(&self) -> &'g EventGraph {
        self.graph
    }
}

/// Who performed an effect, for reachability queries.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Actor {
    Thread(ThreadPoint),
    Effect(AsyncOpId),
}

impl Actor {
    fn reaches(self, view: &HbView) -> bool {
        match self {
            Actor::Thread(p) => view.thread_hb(p),
            Actor::Effect(op) => view.effects_hb(op),
        }
    }
}

/// One effect at one byte; its children reached it when it arrived.
#[derive(Debug)]
struct Node {
    event: EventId,
    actor: Actor,
    mode: AccessMode,
    children: Vec<usize>,
}

pub fn check_memory_conflicts<'g>(
    h: &ValidatedGraph<'g>,
) -> (MemoryConflictResult, Option<MemoryConflictFree<'g>>) {
    let graph = h.graph();
    let mut unresolved = Vec::new();
    for (id, ev) in graph.events().iter() {
        if let EventKind::Access(a) = ev.kind
            && outside_contract(graph.access(a))
        {
            unresolved.push(Unresolved::at(
                id,
                format!(
                    "{:?} effects are outside the initial contract",
                    graph.access(a).ordering
                ),
            ));
        }
    }
    let effects = graph.accesses().values().filter(|a| in_m(a)).count();
    let written = written_bytes(graph);

    let points = thread_points(graph);
    let mut nodes: Vec<Node> = Vec::new();
    let mut maximal: HashMap<ByteLocation, Vec<usize>> = HashMap::new();
    let mut found: Vec<MemoryConflict> = Vec::new();
    let mut reported: HashSet<(EventId, EventId)> = HashSet::new();
    h.sweep(|e, view| {
        let EventKind::Access(a) = graph.event(e).kind else {
            return;
        };
        let access = graph.access(a);
        if !in_m(access) || found.len() >= CONFLICT_CAP {
            return;
        }
        let actor = match graph.event(e).ctx {
            ExecContext::Thread(_) => Actor::Thread(points[e.0 as usize].expect("a thread event")),
            ExecContext::Async(op) => Actor::Effect(op),
            ExecContext::Generation(_) => unreachable!("effects live in threads or async ops"),
        };
        for location in bytes(access) {
            if !written.contains(&location) {
                continue;
            }
            let roots = maximal.remove(&location).unwrap_or_default();
            let node = nodes.len();
            let mut children = Vec::new();
            let mut kept = Vec::new();
            let mut unordered = Vec::new();
            for root in roots {
                if nodes[root].actor.reaches(view) {
                    children.push(root);
                } else {
                    kept.push(root);
                    unordered.push(root);
                }
            }
            while let Some(n) = unordered.pop() {
                let earlier = &nodes[n];
                if let Some(kind) = ConflictKind::of(earlier.mode, access.mode)
                    && reported.insert((earlier.event, e))
                {
                    found.push(MemoryConflict {
                        kind,
                        location,
                        earlier: earlier.event,
                        later: e,
                    });
                }
                for &c in &earlier.children {
                    if !nodes[c].actor.reaches(view) {
                        unordered.push(c);
                    }
                }
            }
            nodes.push(Node {
                event: e,
                actor,
                mode: access.mode,
                children,
            });
            kept.push(node);
            maximal.insert(location, kept);
        }
    });

    found.sort_by_key(|c| (c.later, c.earlier));
    found.truncate(CONFLICT_CAP);
    let result = PropertyResult::from_findings(
        MemoryConflictEvidence {
            effects,
            written_bytes: written.len(),
        },
        found,
        unresolved,
    );
    let certificate =
        matches!(result, PropertyResult::Pass(_)).then_some(MemoryConflictFree { graph });
    (result, certificate)
}
