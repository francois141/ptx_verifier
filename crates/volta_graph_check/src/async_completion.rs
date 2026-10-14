//! **Async completion and wait associations.**
//!
//! * Property: each asynchronous operation's completion is tracked by exactly the waits its
//!   instruction's completion mechanism defines, re-derived from the trace rather than taken
//!   from the producer; and a `tcgen05.ld`/`.st` completes before its warp's next CTA-level
//!   synchronization contribution.
//! * Uses: async ops (kind, issuer, issue, effects, tracking), `AsyncCompletion` and
//!   `Arrival` contributions, `GroupCommit` events, generation kinds and objects, program
//!   order. A commit or an arrival is never read as completion: only an `AsyncCompletion`
//!   contribution is.
//! * Prerequisites: a well-formed graph and the barrier checker's [`SyncCertificate`]
//!   (tracking through an unvalidated generation leaves the op unvalidated).
//! * Mechanisms: `cp.async` by the issuer's `wait_group` popping its group (groups
//!   re-derived from `commit_group`s) or by the issuer's `cp.async.mbarrier.arrive` (all its
//!   pending copies); bulk, TMA and CLC copies by the one mbarrier phase forming at issue,
//!   counting exactly the bytes they write; `tcgen05.mma` by phases its issuer committed to
//!   after issuing it; `tcgen05.ld`/`.st` by a later wait collective of the issuing warp;
//!   a `wgmma.mma_async` share by a later `wgmma.wait_group` of its member's warp, after that
//!   member's commit. Which `wait` kind (`::ld`/`::st`) and which `wait_group` depth released
//!   an op is not re-derived (the graph does not record it).
//! * Volta model rule (the PTX ISA leaves no other way for a CTA-level sync to order an
//!   incomplete `tcgen05.ld`/`.st`): no thread of the issuing warp contributes to a named
//!   barrier or mbarrier between the op's issue and its wait.
//! * `Pass`: every op's tracking matches its mechanism, through validated generations, and no
//!   warp synchronizes past an incomplete `tcgen05.ld`/`.st`; the certificate admits every
//!   op. `Fail`: a mismatched association (a producer defect) or a sync past an incomplete
//!   `tcgen05.ld`/`.st`. `Unknown`: an association through an unvalidated generation.

use std::collections::{HashMap, HashSet, VecDeque};

use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, CollectiveSide, ContributionKind, EventGraph, EventId,
    EventKind, Footprint, GenerationId, GenerationKind, GroupFamily, SyncObjectKind, ThreadIx,
};

use crate::barrier::SyncCertificate;
use crate::hb::Validated;
use crate::result::{PropertyResult, Unresolved};

/// The async ops whose completion association was validated: the completion edges later
/// checkers may use.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CompletionCertificate {
    pub completions: Validated<AsyncOpId>,
}

impl CompletionCertificate {
    pub fn assume_all() -> Self {
        CompletionCertificate {
            completions: Validated::All,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CompletionEvidence {
    pub ops: usize,
    pub tracking_associations: usize,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CompletionViolation {
    /// `thread`, of the warp that issued `op` (a `tcgen05.ld`/`.st`), contributed to a
    /// synchronization at `sync` while `op` was still incomplete.
    UnwaitedAtSync {
        op: AsyncOpId,
        thread: ThreadIx,
        sync: EventId,
    },
    /// The recorded tracking of `op` disagrees with its completion mechanism.
    Misassociated { op: AsyncOpId, reason: String },
}

impl CompletionViolation {
    pub fn position(&self, graph: &EventGraph) -> EventId {
        match self {
            CompletionViolation::UnwaitedAtSync { sync, .. } => *sync,
            CompletionViolation::Misassociated { op, .. } => graph.async_op(*op).issue,
        }
    }
}

pub type CompletionResult = PropertyResult<CompletionEvidence, CompletionViolation>;

pub fn check_async_completion(
    graph: &EventGraph,
    sync: &SyncCertificate,
) -> (CompletionResult, CompletionCertificate) {
    if graph.validate().is_err() {
        return (
            PropertyResult::Unknown(vec![Unresolved::global("the graph is not well-formed")]),
            CompletionCertificate {
                completions: Validated::none(),
            },
        );
    }
    let mut violations = Vec::new();
    let mut unresolved = Vec::new();
    let mut bad: HashSet<AsyncOpId> = HashSet::new();
    let mut misassociated = |op: AsyncOpId, reason: String, bad: &mut HashSet<AsyncOpId>| {
        bad.insert(op);
        violations.push(CompletionViolation::Misassociated { op, reason });
    };

    let expected = derive_cp_async_tracking(graph);
    let mut associations = 0;
    for (op, a) in graph.async_ops().iter() {
        associations += a.tracking.len();
        for &g in &a.tracking {
            if !sync.generations.contains(&g) {
                bad.insert(op);
                unresolved.push(Unresolved::at(
                    a.issue,
                    format!(
                        "async op {}'s completion is tracked by an unvalidated generation",
                        op.0
                    ),
                ));
            }
        }
        if let Err(reason) = check_mechanism(graph, op, &expected) {
            misassociated(op, reason, &mut bad);
        }
    }
    violations.extend(unwaited_at_sync(graph));
    violations.sort_by_key(|v| v.position(graph));
    unresolved.sort_by_key(|u| u.event);

    let certificate = CompletionCertificate {
        completions: if bad.is_empty() {
            Validated::All
        } else {
            Validated::Only(
                graph
                    .async_ops()
                    .count()
                    .into_iter()
                    .filter(|op| !bad.contains(op))
                    .collect(),
            )
        },
    };
    (
        PropertyResult::from_findings(
            CompletionEvidence {
                ops: graph.async_ops().len(),
                tracking_associations: associations,
            },
            violations,
            unresolved,
        ),
        certificate,
    )
}

/// Per cp.async op, the generation its issuer's own program order says completes it.
fn derive_cp_async_tracking(graph: &EventGraph) -> HashMap<AsyncOpId, GenerationId> {
    let mut expected = HashMap::new();
    for t in 0..graph.threads() {
        let t = ThreadIx(t);
        let mut uncommitted: Vec<AsyncOpId> = Vec::new();
        let mut groups: VecDeque<Vec<AsyncOpId>> = VecDeque::new();
        for &e in graph.program_order(t) {
            match graph.event(e).kind {
                EventKind::AsyncIssue(op) if graph.async_op(op).kind == AsyncOpKind::CpAsync => {
                    uncommitted.push(op);
                }
                EventKind::GroupCommit(GroupFamily::CpAsync) => {
                    groups.push_back(std::mem::take(&mut uncommitted));
                }
                EventKind::Resume(g) => {
                    if let GenerationKind::AsyncGroupWait { keep_pending } =
                        graph.generation(g).kind
                    {
                        while groups.len() > keep_pending as usize {
                            for op in groups.pop_front().unwrap() {
                                expected.insert(op, g);
                            }
                        }
                    }
                }
                EventKind::Contribute(g) => {
                    let tracks_ours = graph.generation(g).contributions.iter().any(|c| {
                        matches!(c.kind, ContributionKind::AsyncCompletion { op, .. }
                            if graph.async_op(op).kind == AsyncOpKind::CpAsync
                                && graph.async_op(op).issuer == t)
                    });
                    if tracks_ours {
                        for op in groups.drain(..).flatten().chain(uncommitted.drain(..)) {
                            expected.insert(op, g);
                        }
                    }
                }
                _ => {}
            }
        }
    }
    expected
}

fn written_bytes(graph: &EventGraph, op: AsyncOpId) -> u64 {
    graph
        .async_op(op)
        .effects
        .iter()
        .map(|&a| graph.access(a))
        .filter(|a| a.mode == AccessMode::Write)
        .map(|a| match a.footprint {
            Footprint::Bytes { width, .. } => u64::from(width),
            Footprint::Tensor { .. } => 0,
        })
        .sum()
}

fn tx_of(graph: &EventGraph, g: GenerationId, op: AsyncOpId) -> Option<u64> {
    graph
        .generation(g)
        .contributions
        .iter()
        .find_map(|c| match c.kind {
            ContributionKind::AsyncCompletion { op: o, tx_bytes } if o == op => Some(tx_bytes),
            _ => None,
        })
}

/// Whether `g` is the exit of a collective of `warp`.
fn is_warp_exit(graph: &EventGraph, g: GenerationId, warp: u32) -> bool {
    let generation = graph.generation(g);
    matches!(
        generation.kind,
        GenerationKind::Collective {
            side: CollectiveSide::Exit,
            ..
        }
    ) && graph.object(generation.object).kind == SyncObjectKind::WarpCollective { warp }
}

fn is_phase(graph: &EventGraph, g: GenerationId) -> bool {
    graph.generation(g).kind == GenerationKind::MbarrierPhase
}

fn check_mechanism(
    graph: &EventGraph,
    op: AsyncOpId,
    expected: &HashMap<AsyncOpId, GenerationId>,
) -> Result<(), String> {
    let a = graph.async_op(op);
    let after_issue = |g: GenerationId| {
        graph
            .generation(g)
            .completion
            .is_none_or(|done| done > a.issue)
    };
    match a.kind {
        AsyncOpKind::CpAsync => match (a.tracking.as_slice(), expected.get(&op)) {
            ([], None) => Ok(()),
            ([g], Some(e)) if g == e => Ok(()),
            (got, want) => Err(format!(
                "cp.async tracked by {:?}, but its issuer's waits complete it in {:?}",
                got, want
            )),
        },
        AsyncOpKind::BulkCopy | AsyncOpKind::TensorCopy | AsyncOpKind::ClcResponse => {
            let [g] = a.tracking.as_slice() else {
                return Err(format!("tracked by {} phases, not one", a.tracking.len()));
            };
            if !is_phase(graph, *g) || !after_issue(*g) {
                return Err("not tracked by an mbarrier phase forming at its issue".to_string());
            }
            let previous_done = graph
                .generations()
                .values()
                .find(|other| {
                    other.object == graph.generation(*g).object
                        && other.index + 1 == graph.generation(*g).index
                })
                .is_none_or(|prev| prev.completion.is_some_and(|done| done < a.issue));
            if !previous_done {
                return Err("tracked by a phase that formed after its issue".to_string());
            }
            let tx = tx_of(graph, *g, op).unwrap_or(0);
            let bytes = written_bytes(graph, op);
            if tx != bytes {
                return Err(format!(
                    "completes {} transaction bytes but writes {}",
                    tx, bytes
                ));
            }
            Ok(())
        }
        AsyncOpKind::Tcgen05Mma => {
            for &g in &a.tracking {
                let committed = is_phase(graph, g)
                    && graph.generation(g).contributions.iter().any(|c| {
                        matches!(c.kind, ContributionKind::Arrival { .. })
                            && graph.thread_of(c.event) == Some(a.issuer)
                            && c.event > a.issue
                    });
                if !committed {
                    return Err(format!(
                        "tracked by generation {} without a later commit by its issuer",
                        g.0
                    ));
                }
            }
            Ok(())
        }
        AsyncOpKind::Tcgen05Ld | AsyncOpKind::Tcgen05St => match a.tracking.as_slice() {
            [] => Ok(()),
            [g] if is_warp_exit(graph, *g, a.issuer.0 / 32) && after_issue(*g) => Ok(()),
            _ => Err("not tracked by one later wait of its warp".to_string()),
        },
        AsyncOpKind::WgmmaMma { .. } => match a.tracking.as_slice() {
            [] => Ok(()),
            [g] if is_warp_exit(graph, *g, a.issuer.0 / 32) && after_issue(*g) => {
                let done = graph.generation(*g).completion;
                let committed = graph.program_order(a.issuer).iter().any(|&e| {
                    e > a.issue
                        && done.is_none_or(|d| e < d)
                        && graph.event(e).kind == EventKind::GroupCommit(GroupFamily::Wgmma)
                });
                if committed {
                    Ok(())
                } else {
                    Err("released by a wait_group without a commit in between".to_string())
                }
            }
            _ => Err("not tracked by one later wait_group of its member's warp".to_string()),
        },
    }
}

/// `tcgen05.ld`/`.st` ops whose warp contributes to a CTA-level sync before the op's wait.
fn unwaited_at_sync(graph: &EventGraph) -> Vec<CompletionViolation> {
    let mut violations = Vec::new();
    for (op, a) in graph.async_ops().iter() {
        if !matches!(a.kind, AsyncOpKind::Tcgen05Ld | AsyncOpKind::Tcgen05St) {
            continue;
        }
        let done = a
            .tracking
            .first()
            .and_then(|&g| graph.generation(g).completion)
            .unwrap_or(EventId(u32::MAX));
        let warp = a.issuer.0 / 32;
        for lane in 0..32 {
            let t = warp * 32 + lane;
            if t >= graph.threads() {
                break;
            }
            let t = ThreadIx(t);
            let sync = graph.program_order(t).iter().copied().find(|&e| {
                e > a.issue
                    && e < done
                    && matches!(graph.event(e).kind, EventKind::Contribute(g) if synchronizes_cta(graph, g, e))
            });
            if let Some(sync) = sync {
                violations.push(CompletionViolation::UnwaitedAtSync {
                    op,
                    thread: t,
                    sync,
                });
            }
        }
    }
    violations
}

/// Whether contribution event `e` to `g` is a CTA-level synchronization arrival (a named
/// barrier or mbarrier arrival, not a warp collective or a relaxed `complete_tx`).
fn synchronizes_cta(graph: &EventGraph, g: GenerationId, e: EventId) -> bool {
    let generation = graph.generation(g);
    let kind_ok = matches!(
        graph.object(generation.object).kind,
        SyncObjectKind::NamedBarrier { .. } | SyncObjectKind::Mbarrier { .. }
    );
    kind_ok
        && generation.contributions.iter().any(|c| {
            c.event == e
                && matches!(
                    c.kind,
                    ContributionKind::Blocking | ContributionKind::Arrival { .. }
                )
        })
}
