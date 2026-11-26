//! `barrier.cluster.arrive`/`wait` (PTX ISA 9.7.13.3) of a one-CTA cluster: the barrier's
//! participants are the CTA's threads. A phase completes once every non-exited thread
//! arrived; a wait blocks until the phase of the thread's own preceding arrival completes.
//! Each thread arrives once per phase, so its k-th arrival is phase k under every schedule.

use std::collections::HashMap;

use volta_graph::{ArrivalOrdering, EventId, EventKind, GenerationKind, MemberOrdering};

use crate::eval::ThreadId;
use crate::eval::error::{ClusterBarrierMisuse, EvalError, EvalResult};
use crate::eval::interp::{Interpreter, Status};
use crate::eval::record::tix;
use crate::ir::{ClusterArriveOrdering, FenceRelease, InstrId, LoweredInstr};

/// The cluster barrier's execution state.
#[derive(Debug, Default)]
pub(in crate::eval) struct ClusterBarrier {
    /// Phases completed so far; the forming phase is the next one.
    completed: u64,
    /// Each thread's arrival it has not yet waited for: the phase it arrived in.
    pending: HashMap<ThreadId, u64>,
}

impl<'p> Interpreter<'p> {
    /// `barrier.cluster.arrive` by `t`: a non-blocking arrival in the forming phase.
    pub(in crate::eval) fn cluster_barrier_arrive(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        ordering: ClusterArriveOrdering,
    ) -> EvalResult<()> {
        if self.cluster_barrier.pending.contains_key(&t) {
            return Err(EvalError::ClusterBarrierMisuse {
                thread: t,
                pc,
                misuse: ClusterBarrierMisuse::ArriveTwice,
            });
        }
        let phase = self.cluster_barrier.completed;
        self.cluster_barrier.pending.insert(t, phase);
        let ordering = match ordering {
            ClusterArriveOrdering::Release => ArrivalOrdering::Release,
            ClusterArriveOrdering::Relaxed => ArrivalOrdering::Relaxed,
        };
        self.record_cluster_arrival(t, pc, ordering);
        self.try_complete_cluster_phase();
        Ok(())
    }

    /// `barrier.cluster.wait` by `t`: whether it returned at once (its phase complete); else
    /// `t` blocks until the scheduler completes the phase.
    pub(in crate::eval) fn cluster_barrier_wait(
        &mut self,
        t: ThreadId,
        pc: InstrId,
    ) -> EvalResult<bool> {
        let Some(&phase) = self.cluster_barrier.pending.get(&t) else {
            return Err(EvalError::ClusterBarrierMisuse {
                thread: t,
                pc,
                misuse: ClusterBarrierMisuse::WaitWithoutArrive,
            });
        };
        if phase < self.cluster_barrier.completed {
            self.cluster_barrier.pending.remove(&t);
            self.record_cluster_wake(t, pc, phase);
            return Ok(true);
        }
        self.threads[t].status = Status::AtClusterBarrier { phase };
        Ok(false)
    }

    /// Complete the forming phase if every non-exited thread arrived in it.
    fn try_complete_cluster_phase(&mut self) -> bool {
        let phase = self.cluster_barrier.completed;
        let arrived = |t: ThreadId, state: &crate::eval::interp::ThreadState| {
            self.cluster_barrier.pending.get(&t) == Some(&phase) || state.status == Status::Exited
        };
        let any = self.cluster_barrier.pending.values().any(|&p| p == phase);
        if !any || !self.threads.iter().all(|(t, state)| arrived(t, state)) {
            return false;
        }
        let exited: Vec<ThreadId> = self
            .threads
            .iter()
            .filter(|(t, state)| {
                state.status == Status::Exited
                    && self.cluster_barrier.pending.get(t) != Some(&phase)
            })
            .map(|(t, _)| t)
            .collect();
        self.record_cluster_phase_complete(&exited);
        self.cluster_barrier.completed += 1;
        true
    }

    /// Complete a phase whose last missing threads exited, then wake every waiter whose
    /// phase completed. Returns whether either happened.
    pub(in crate::eval) fn try_fire_cluster_barrier(&mut self) -> EvalResult<bool> {
        let completed = self.try_complete_cluster_phase();
        let ready: Vec<(ThreadId, u64)> = self
            .threads
            .iter()
            .filter_map(|(t, state)| match state.status {
                Status::AtClusterBarrier { phase } if phase < self.cluster_barrier.completed => {
                    Some((t, phase))
                }
                _ => None,
            })
            .collect();
        for &(t, phase) in &ready {
            let pc = self.threads[t].pc;
            debug_assert!(matches!(
                self.program.instruction(pc),
                Some(LoweredInstr::ClusterBarrierWait)
            ));
            self.cluster_barrier.pending.remove(&t);
            self.record_cluster_wake(t, pc, phase);
            self.threads[t].status = Status::Ready;
            self.threads[t].pc = InstrId(pc.0 + 1);
        }
        Ok(completed || !ready.is_empty())
    }

    /// A thread fence by `t` that releases `release`: remember the event before it, which a
    /// later relaxed arrival of `t` releases through (graph bookkeeping only).
    pub(in crate::eval) fn note_release_fence(&mut self, t: ThreadId, release: FenceRelease) {
        let order = self.graph.graph_so_far().program_order(tix(t));
        let Some(&last) = order.last() else {
            return;
        };
        let releases = match release {
            FenceRelease::Nothing => false,
            FenceRelease::Everything => true,
            FenceRelease::MbarrierInits => order.iter().all(|&e| self.only_an_init(e)),
        };
        if releases {
            self.rec.note_cluster_fence(t, last);
        }
    }

    /// Whether releasing everything up to thread event `e` releases only `mbarrier.init`s:
    /// `e` belongs to one, or is an execution-only collective's (`elect.sync`), which
    /// carries no other thread's accesses.
    fn only_an_init(&self, e: EventId) -> bool {
        let graph = self.graph.graph_so_far();
        let event = graph.event(e);
        let execution_only = |g| {
            matches!(
                graph.generation(g).kind,
                GenerationKind::Collective {
                    ordering: MemberOrdering::ExecutionOnly,
                    ..
                }
            )
        };
        match event.kind {
            EventKind::Contribute(g) | EventKind::Resume(g) => execution_only(g),
            EventKind::Access(_) | EventKind::ObjectInit(_) => event.pc.is_some_and(|p| {
                matches!(
                    self.program.instruction(InstrId(p.0)),
                    Some(LoweredInstr::MbarrierInit { .. })
                )
            }),
            _ => false,
        }
    }
}
