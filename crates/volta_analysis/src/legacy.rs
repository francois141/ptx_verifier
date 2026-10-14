//! The legacy facade's verdict: the graph-verification branch's first failure, rendered in the
//! removed embedded detector's error format and chosen with its precedence. That detector
//! raised the first hazard in trace order and, within one access, an in-flight lock hit (a
//! destination lock before a source lock) before a proxy-fence hazard before a χ race (bytes
//! ascending, conflicting readers before the last writer).

use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, EventGraph, EventId, EventKind, ExecContext, Footprint,
    Space,
};
use volta_graph_check::async_completion::CompletionViolation;
use volta_graph_check::lifetime::LifetimeViolation;
use volta_graph_check::race::{Conflict, Location};
use volta_graph_check::{GraphConclusion, GraphReport, Property};

use crate::eval::error::AccessSite;
use crate::eval::{EvalError, RaceVerification, ThreadId};
use crate::lowered::{InstrId, MemSpace};

/// How the removed detector ordered hazards found at one access.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
enum Rank {
    InFlight,
    Proxy,
    Race,
    Protocol,
}

/// A failure at a trace position, with its place in the detector's order there.
struct Candidate {
    key: (EventId, Rank, (u8, u64), u8, usize),
    error: EvalError,
}

/// The first failure of `report` in the removed detector's format, if any property failed.
pub(crate) fn first_failure(graph: &EventGraph, report: &GraphReport) -> Option<EvalError> {
    let mut candidates = Vec::new();
    for (i, c) in report.memory_conflicts.violations().iter().enumerate() {
        candidates.push(conflict(graph, c, i));
    }
    for (i, v) in report.proxy.violations().iter().enumerate() {
        candidates.push(Candidate {
            key: (v.read, Rank::Proxy, (0, v.addr), 0, i),
            error: EvalError::GenericProxyFenceHazard {
                space: MemSpace::Shared,
                addr: v.addr,
                prior: site(graph, v.write),
                current: site(graph, v.read),
            },
        });
    }
    for (i, v) in report.async_completion.violations().iter().enumerate() {
        let error = match v {
            CompletionViolation::UnwaitedAtSync { op, thread, sync } => {
                let a = graph.async_op(*op);
                EvalError::Tcgen05UnwaitedAtSync {
                    thread: ThreadId(thread.0),
                    pc: pc_of(graph, *sync),
                    pending: AccessSite {
                        thread: ThreadId(a.issuer.0),
                        pc: InstrId(a.pc.0),
                        is_write: a.kind == AsyncOpKind::Tcgen05St,
                    },
                }
            }
            CompletionViolation::Misassociated { op, reason } => violation(
                graph,
                Property::AsyncCompletion,
                graph.async_op(*op).issue,
                reason.clone(),
            ),
        };
        candidates.push(Candidate {
            key: (v.position(graph), Rank::Protocol, (0, 0), 0, i),
            error,
        });
    }
    for (i, v) in report.lifetime.violations().iter().enumerate() {
        candidates.push(lifetime(graph, v, i));
    }
    for (i, v) in report.barrier.violations().iter().enumerate() {
        let at = v.position(graph);
        candidates.push(Candidate {
            key: (at, Rank::Protocol, (0, 0), 0, i),
            error: EvalError::BarrierMismatch {
                pc: pc_of(graph, at),
                reason: format!("{v:?}"),
            },
        });
    }
    let end = EventId(graph.events().len() as u32);
    for (i, d) in report.well_formed.violations().iter().enumerate() {
        candidates.push(Candidate {
            key: (EventId(0), Rank::Protocol, (0, 0), 0, i),
            error: EvalError::GraphPropertyViolation {
                property: Property::WellFormed.name(),
                thread: None,
                pc: None,
                witness: format!("{d:?}"),
            },
        });
    }
    for (i, d) in report.progress.violations().iter().enumerate() {
        candidates.push(Candidate {
            key: (end, Rank::Protocol, (0, 0), 0, i),
            error: EvalError::Deadlock {
                blocked: d
                    .blocked
                    .iter()
                    .map(|b| (ThreadId(b.thread.0), InstrId(b.pc.0)))
                    .collect(),
            },
        });
    }
    candidates
        .into_iter()
        .min_by_key(|c| c.key)
        .map(|c| c.error)
}

/// The facade's verification status for an execution no property failed on.
pub(crate) fn race_verification(report: &GraphReport) -> RaceVerification {
    match report.conclusion() {
        GraphConclusion::Verified => RaceVerification::Verified,
        GraphConclusion::Unknown { reasons } => RaceVerification::Unknown { reasons },
        GraphConclusion::Rejected { failed } => RaceVerification::Unknown {
            reasons: failed
                .iter()
                .map(|s| format!("{} failed", s.property.name()))
                .collect(),
        },
    }
}

fn pc_of(graph: &EventGraph, e: EventId) -> InstrId {
    graph
        .events()
        .get(e)
        .and_then(|ev| ev.pc)
        .map_or(InstrId(0), |p| InstrId(p.0))
}

fn site(graph: &EventGraph, e: EventId) -> AccessSite {
    let is_write = match graph.event(e).kind {
        EventKind::Access(a) => graph.access(a).mode == AccessMode::Write,
        _ => false,
    };
    AccessSite {
        thread: ThreadId(graph.acting_thread(e).map_or(0, |t| t.0)),
        pc: pc_of(graph, e),
        is_write,
    }
}

fn violation(graph: &EventGraph, property: Property, at: EventId, witness: String) -> EvalError {
    EvalError::GraphPropertyViolation {
        property: property.name(),
        thread: graph.acting_thread(at).map(|t| ThreadId(t.0)),
        pc: graph.event(at).pc.map(|p| InstrId(p.0)),
        witness,
    }
}

/// The async op an effect belongs to, while `at` lies in its in-flight window: from issue to
/// the first release observing its completion (the removed detector's lock lifetime).
fn in_flight(graph: &EventGraph, effect: EventId, at: EventId) -> Option<AsyncOpId> {
    let ExecContext::Async(op) = graph.event(effect).ctx else {
        return None;
    };
    let observed = graph
        .async_op(op)
        .tracking
        .iter()
        .flat_map(|&g| graph.generation(g).releases.iter().copied())
        .min();
    observed.is_none_or(|o| at < o).then_some(op)
}

fn mem_space(space: Space) -> MemSpace {
    match space {
        Space::Global => MemSpace::Global,
        Space::Shared | Space::Tensor => MemSpace::Shared,
    }
}

fn columns(graph: &EventGraph, e: EventId) -> (u32, u32) {
    match graph.event(e).kind {
        EventKind::Access(a) => match graph.access(a).footprint {
            Footprint::Tensor { col, cols, .. } => (u32::from(col), u32::from(cols)),
            Footprint::Bytes { .. } => (0, 0),
        },
        EventKind::TmemDealloc {
            start_col,
            num_cols,
        } => (u32::from(start_col), u32::from(num_cols)),
        _ => (0, 0),
    }
}

fn conflict(graph: &EventGraph, c: &Conflict, index: usize) -> Candidate {
    let (prior, current) = (site(graph, c.prior), site(graph, c.current));
    let in_window = in_flight(graph, c.prior, c.current).is_some();
    let rank = if in_window {
        Rank::InFlight
    } else {
        Rank::Race
    };
    let writer_first = u8::from(in_window && !prior.is_write);
    let (location, error) = match (c.location, in_window) {
        (Location::Byte(space, addr), true) => (
            (space as u8, addr),
            EvalError::AsyncCopyHazard {
                space: mem_space(space),
                addr,
                prior,
                current,
            },
        ),
        (Location::Byte(space, addr), false) => (
            (space as u8, addr),
            EvalError::DataRace {
                space: mem_space(space),
                addr,
                prior,
                current,
            },
        ),
        (Location::Cell { lane, col }, true) => {
            let (start_col, num_cols) = columns(graph, c.current);
            (
                (u8::MAX, u64::from(lane) << 16 | u64::from(col)),
                EvalError::Tcgen05AsyncHazard {
                    quadrant: (u32::from(lane) % 128) / 32,
                    start_col,
                    num_cols,
                    prior,
                    current,
                },
            )
        }
        (Location::Cell { lane, col }, false) => (
            (u8::MAX, u64::from(lane) << 16 | u64::from(col)),
            EvalError::TensorMemoryRace {
                lane: u32::from(lane),
                col: u32::from(col),
                prior,
                current,
            },
        ),
    };
    Candidate {
        key: (c.current, rank, location, writer_first, index),
        error,
    }
}

fn lifetime(graph: &EventGraph, v: &LifetimeViolation, index: usize) -> Candidate {
    let at = v.position();
    let error = match *v {
        LifetimeViolation::FreedWhileInUse { dealloc, effect } => {
            let prior = site(graph, effect);
            let current = AccessSite {
                is_write: true,
                ..site(graph, dealloc)
            };
            let (lane, lanes_col) = match graph.event(effect).kind {
                EventKind::Access(a) => match graph.access(a).footprint {
                    Footprint::Tensor { lane, col, .. } => (u32::from(lane), u32::from(col)),
                    Footprint::Bytes { .. } => (0, 0),
                },
                _ => (0, 0),
            };
            if in_flight(graph, effect, dealloc).is_some() {
                let (start_col, num_cols) = columns(graph, dealloc);
                EvalError::Tcgen05AsyncHazard {
                    quadrant: (lane % 128) / 32,
                    start_col,
                    num_cols,
                    prior,
                    current,
                }
            } else {
                EvalError::TensorMemoryRace {
                    lane,
                    col: lanes_col,
                    prior,
                    current,
                }
            }
        }
        other => violation(graph, Property::ResourceLifetime, at, format!("{other:?}")),
    };
    Candidate {
        key: (at, Rank::InFlight, (0, 0), 0, index),
        error,
    }
}
