//! **Progress.**
//!
//! * Property: every thread of the CTA terminates in every schedule. The candidate execution
//!   must complete, and every generation that released a thread must have a
//!   schedule-independent binding, as must every async completion such a generation counted:
//!   then every schedule completes the same generations and no thread blocks forever (Weft's
//!   Theorem 1 for named barriers; Volta's adaptation, without a theorem, for mbarriers).
//! * Model: the interpreter collapses mbarrier retry loops into blocking waits and applies
//!   async completions eagerly, so when no thread can run, no pending work can enable one.
//! * Uses: the terminal state (blocked threads and their wait conditions), generations'
//!   releases and `AsyncCompletion` contributions.
//! * Prerequisites: a well-formed graph; the barrier and async-completion certificates.
//! * `Pass`: completed, through validated generations and completions only. `Fail`: stuck,
//!   a deadlock of the candidate execution, with every blocked thread and its condition.
//!   `Unknown`: the producer stopped the execution (an unsupported instruction, invalid
//!   behavior or a budget is not a deadlock), or a releasing generation or a completion it
//!   counted is not validated.

use volta_graph::{BlockedThread, ContributionKind, EventGraph, Terminal};

use crate::async_completion::CompletionCertificate;
use crate::barrier::SyncCertificate;
use crate::result::{PropertyResult, Unresolved};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProgressEvidence {
    pub threads: u32,
    /// Generations that released a thread, all validated.
    pub releasing_generations: usize,
}

/// The candidate execution's deadlock: no thread can run.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Deadlock {
    pub blocked: Vec<BlockedThread>,
}

pub type ProgressResult = PropertyResult<ProgressEvidence, Deadlock>;

pub fn check_progress(
    graph: &EventGraph,
    sync: &SyncCertificate,
    completion: &CompletionCertificate,
) -> ProgressResult {
    if graph.validate().is_err() {
        return PropertyResult::Unknown(vec![Unresolved::global("the graph is not well-formed")]);
    }
    match graph.terminal() {
        Terminal::Stuck { blocked } if !blocked.is_empty() => {
            return PropertyResult::Fail(vec![Deadlock {
                blocked: blocked.clone(),
            }]);
        }
        Terminal::Stuck { .. } => {
            return PropertyResult::Unknown(vec![Unresolved::global(
                "the execution is stuck without a blocked thread",
            )]);
        }
        Terminal::Aborted { reason, .. } => {
            return PropertyResult::Unknown(vec![Unresolved::global(format!(
                "the execution stopped before completing ({reason}); that is not a deadlock, \
                 but termination is not established"
            ))]);
        }
        Terminal::Completed => {}
    }
    let mut unresolved = Vec::new();
    let mut releasing = 0;
    for (id, g) in graph.generations().iter() {
        let Some(&first) = g.releases.first() else {
            continue;
        };
        releasing += 1;
        if !sync.generations.contains(&id) {
            unresolved.push(Unresolved::at(
                first,
                format!(
                    "generation {} of object {} released this thread without a validated \
                     binding; another schedule may bind it differently",
                    g.index, g.object.0
                ),
            ));
        }
        for c in &g.contributions {
            if let ContributionKind::AsyncCompletion { op, .. } = c.kind
                && !completion.completions.contains(&op)
            {
                unresolved.push(Unresolved::at(
                    graph.async_op(op).issue,
                    format!(
                        "generation {} of object {} counted this operation's completion \
                         without a validated association",
                        g.index, g.object.0
                    ),
                ));
            }
        }
    }
    unresolved.sort_by_key(|u| u.event);
    PropertyResult::from_findings(
        ProgressEvidence {
            threads: graph.threads(),
            releasing_generations: releasing,
        },
        Vec::new(),
        unresolved,
    )
}
