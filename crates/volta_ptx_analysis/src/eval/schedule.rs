//! The scheduler of the candidate execution: run one ready thread until it
//! blocks or exits, then fire whatever group is complete (a warp rendezvous,
//! an mbarrier phase, a named barrier).

use std::collections::HashMap;

use crate::eval::error::{EvalError, EvalResult};
use crate::eval::interp::{
    ArrivedThread, BarrierArrivals, Interpreter, NUM_BARRIERS, PendingArrivals, Status,
};
use crate::eval::value::{MbarrierId, Value};
use crate::eval::{ThreadId, WARP_SIZE};
use crate::ir::{BarrierAlignment, InstrId, LoweredInstr, Operand};
use crate::logging::trace;

impl<'p> Interpreter<'p> {
    pub(in crate::eval) fn next_ready(&self) -> Option<ThreadId> {
        self.threads
            .iter()
            .find(|(_, t)| t.status == Status::Ready)
            .map(|(id, _)| id)
    }

    /// Run one thread until it blocks or exits.
    pub(in crate::eval) fn run_thread(&mut self, t: ThreadId) -> EvalResult<()> {
        while self.threads[t].status == Status::Ready {
            self.step(t)?;
        }
        Ok(())
    }

    /// Try to fire complete warp groups and barriers. Returns whether any
    /// group made progress.
    pub(in crate::eval) fn try_fire(&mut self) -> EvalResult<bool> {
        let mut any = false;
        loop {
            if let Some((pc, mask, members)) = self.find_ready_warp_group()? {
                trace!(
                    "warp op at pc {} fired (mask {:#010x}, {} lanes)",
                    pc.0,
                    mask,
                    members.len()
                );
                self.execute_warp_op(pc, mask, &members)?;
                any = true;
                continue;
            }
            if self.try_fire_barrier()? {
                any = true;
                continue;
            }
            if self.try_fire_mbarrier()? {
                any = true;
                continue;
            }
            return Ok(any);
        }
    }

    /// Wake every `AtMbarrier` thread whose phase parity now holds. Returns
    /// whether any woke.
    fn try_fire_mbarrier(&mut self) -> EvalResult<bool> {
        let ready: Vec<(ThreadId, MbarrierId)> = self
            .threads
            .iter()
            .filter_map(|(tid, state)| match state.status {
                Status::AtMbarrier { id, phase_parity }
                    if self.mbarriers.parity_complete(id, phase_parity) =>
                {
                    Some((tid, id))
                }
                _ => None,
            })
            .collect();
        for &(tid, id) in &ready {
            let pc = self.threads[tid].pc;
            self.record_mbarrier_wake(tid, pc, id);
        }
        for (tid, _) in &ready {
            let pc = self.threads[*tid].pc;
            let Some(LoweredInstr::MbarrierWaitParity { wait_complete, .. }) =
                self.program.instruction(pc)
            else {
                unreachable!("a thread AtMbarrier must be blocked at its own wait instruction");
            };
            let wait_complete = *wait_complete;
            let token = self.arena.bool_val(true);
            self.threads[*tid]
                .regs
                .write(wait_complete, Value::Scalar(token));
            self.threads[*tid].status = Status::Ready;
            self.threads[*tid].pc = InstrId(pc.0 + 1);
        }
        Ok(!ready.is_empty())
    }

    /// Find a warp group whose live members have all arrived at the same pc
    /// with the same mask. Returns (pc, mask, live member threads).
    fn find_ready_warp_group(&self) -> EvalResult<Option<(InstrId, u32, Vec<ThreadId>)>> {
        'candidates: for (leader, state) in self.threads.iter() {
            let Status::AtWarpOp { mask } = state.status else {
                continue;
            };
            let pc = state.pc;
            let warp_base = (leader.0 / WARP_SIZE) * WARP_SIZE;
            let mut members = Vec::new();
            for lane in 0..WARP_SIZE {
                if mask & (1 << lane) == 0 {
                    continue;
                }
                let tid = warp_base + lane;
                if tid >= self.n_threads {
                    return Err(EvalError::WarpMismatch {
                        pc,
                        reason: format!(
                            "mask {:#010x} includes lane {} but the CTA has only {} threads",
                            mask, lane, self.n_threads
                        ),
                    });
                }
                let member = &self.threads[ThreadId(tid)];
                match member.status {
                    Status::AtWarpOp { mask: m } if m == mask && member.pc == pc => {
                        members.push(ThreadId(tid));
                    }
                    // An exited lane counts as arrived at every warp op (the
                    // paper's Sync rule; the ISA's "all non-exited threads" for
                    // shfl.sync): it executes nothing.
                    Status::Exited => {}
                    // A live lane elsewhere: not ready. Matching only at one pc
                    // is a deliberate conservative deviation from paper and
                    // ISA; unconverged groups surface as Deadlock.
                    _ => continue 'candidates,
                }
            }
            return Ok(Some((pc, mask, members)));
        }
        Ok(None)
    }

    /// Fire whichever named barrier can: a counted barrier once its arrival
    /// count is met (`bar.arrive` included), the full-CTA barrier once every
    /// live thread waits on its id. Returns whether one fired.
    fn try_fire_barrier(&mut self) -> EvalResult<bool> {
        // Blocked arrivals, per barrier id. Warps at a counted barrier need not
        // share a pc (warp-specialized producers and consumers arrive at their
        // own `bar.sync`); `warps_converge` constrains the lanes of one warp.
        let mut waiters: [Vec<ArrivedThread>; NUM_BARRIERS] = std::array::from_fn(|_| Vec::new());
        // What each barrier fires on, seeded with what its `bar.arrive`
        // arrivals named. `barrier_operands` pins one arrival count per
        // barrier id, so any one arrival gives the count.
        let mut arrivals: [Option<BarrierArrivals>; NUM_BARRIERS] =
            std::array::from_fn(|id| self.barriers[id].arrivals);
        let mut live_waiters = 0usize;
        let mut every_live_thread_waits = true;
        for (t, state) in self.threads.iter() {
            match state.status {
                Status::Exited => {}
                Status::AtBarrier {
                    id,
                    arrivals: at,
                    alignment,
                } => {
                    arrivals[id as usize] = Some(at);
                    waiters[id as usize].push(ArrivedThread {
                        thread: t,
                        pc: state.pc,
                        alignment,
                    });
                    live_waiters += 1;
                }
                _ => every_live_thread_waits = false,
            }
        }

        for (id, waiting) in waiters.iter().enumerate() {
            let arrivals = match arrivals[id] {
                Some(arrivals) => arrivals,
                None => continue,
            };
            let count = match arrivals {
                // The full-CTA barrier fires on the paper's Sync rule: it
                // needs every live thread, and exited threads count as
                // arrived (see `sync_all` below).
                BarrierArrivals::FullCta => {
                    // Every live thread must be waiting, and on this id -
                    // threads split across ids are waiting on different
                    // barriers, so none of them can fire.
                    if !every_live_thread_waits
                        || waiting.len() != live_waiters
                        || !warps_converge(waiting)
                    {
                        continue;
                    }
                    trace!("fired bar.sync {} (full CTA)", id);
                    let waiting: Vec<ThreadId> = waiting.iter().map(|w| w.thread).collect();
                    self.record_barrier_fire(id as u32, BarrierArrivals::FullCta, &waiting);
                    self.advance_thread_group(&waiting);
                    return Ok(true);
                }
                BarrierArrivals::Count(count) => count,
            };

            let mut participants = self.barriers[id].threads.clone();
            participants.extend_from_slice(waiting);
            let (total, lanes) = self.warp_arrivals(&participants);
            if total < count as usize {
                continue;
            }
            let pc = participants[0].pc;
            if total > count as usize {
                return Err(EvalError::BarrierMismatch {
                    pc,
                    reason: format!(
                        "{} threads arrived at barrier {} (whole warps), which fires on {} - \
                         which threads it releases would depend on the schedule",
                        total, id, count
                    ),
                });
            }
            if lanes == LaneArrivals::Partial {
                return Err(EvalError::BarrierMismatch {
                    pc,
                    reason: format!(
                        "whole warps arrived at barrier {} for its {} while some live lanes of \
                         another warp have not - whether that warp joins this phase would \
                         depend on the schedule",
                        id, count
                    ),
                });
            }
            if !warps_converge(&participants) {
                continue;
            }
            self.barriers[id] = PendingArrivals::default();
            trace!("fired bar.sync {} ({} threads)", id, count);
            let waiting: Vec<ThreadId> = waiting.iter().map(|w| w.thread).collect();
            self.record_barrier_fire(id as u32, BarrierArrivals::Count(count), &waiting);
            self.advance_thread_group(&waiting);
            return Ok(true);
        }
        Ok(false)
    }

    /// The threads the warps among `participants` count for at a counted barrier, which marks a
    /// warp's arrival once all its non-exited threads arrive and counts it as the warp size
    /// (PTX ISA 9.7.13.1), and whether some warp's lanes arrived only in part.
    fn warp_arrivals(&self, participants: &[ArrivedThread]) -> (usize, LaneArrivals) {
        let mut per_warp: HashMap<u32, HashMap<u32, usize>> = HashMap::new();
        for p in participants {
            *per_warp
                .entry(p.thread.0 / WARP_SIZE)
                .or_default()
                .entry(p.thread.0)
                .or_default() += 1;
        }
        let mut rounds = 0;
        let mut lanes = LaneArrivals::Whole;
        for (warp, arrivals) in &per_warp {
            let base = warp * WARP_SIZE;
            let counts: Vec<usize> = (base..(base + WARP_SIZE).min(self.n_threads))
                .filter_map(|t| match arrivals.get(&t) {
                    Some(&n) => Some(n),
                    None if self.threads[ThreadId(t)].status == Status::Exited => None,
                    None => Some(0),
                })
                .collect();
            let whole = counts.iter().copied().min().unwrap_or(0);
            if counts.iter().sum::<usize>() != whole * counts.len() {
                lanes = LaneArrivals::Partial;
            }
            rounds += whole;
        }
        (rounds * WARP_SIZE as usize, lanes)
    }

    /// Resolve a named-barrier instruction's operands: the barrier id and
    /// how many arrivals fire it. Both may be registers, so both are
    /// range-checked here rather than at lowering time.
    pub(in crate::eval) fn barrier_operands(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        barrier_id: &Operand,
        thread_count: Option<&Operand>,
    ) -> EvalResult<(u32, BarrierArrivals)> {
        let id = self.concrete_operand(t, pc, barrier_id, "barrier id")?;
        if !(0..NUM_BARRIERS as i64).contains(&id) {
            return Err(EvalError::BarrierMismatch {
                pc,
                reason: format!("barrier id {} is outside the CTA's 16 barriers (0-15)", id),
            });
        }
        let arrivals = match thread_count {
            None => BarrierArrivals::FullCta,
            Some(thread_count) => {
                let count = self.concrete_operand(t, pc, thread_count, "barrier thread count")?;
                // PTX ISA 9.7.13.1: the count is a multiple of the warp size, and
                // no barrier can wait for more threads than the CTA has.
                if count <= 0
                    || count % i64::from(WARP_SIZE) != 0
                    || count > i64::from(self.n_threads)
                {
                    return Err(EvalError::BarrierMismatch {
                        pc,
                        reason: format!(
                            "barrier {} arrival count {} must be a positive multiple of {} \
                             no larger than the CTA's {} threads",
                            id, count, WARP_SIZE, self.n_threads
                        ),
                    });
                }
                BarrierArrivals::Count(count as u32)
            }
        };
        // Stricter than the ISA, which only needs the arrivals of one phase to
        // agree: which arrivals share a phase depends on the schedule.
        match *self.barrier_counts[id as usize].get_or_insert(arrivals) {
            pinned if pinned == arrivals => Ok((id as u32, arrivals)),
            pinned => Err(EvalError::BarrierMismatch {
                pc,
                reason: format!(
                    "{} arrives at barrier {} expecting {}, but an earlier arrival at it \
                     expected {}; Volta pins one count per barrier id for the whole run, \
                     so the result is inconclusive",
                    t, id, arrivals, pinned
                ),
            }),
        }
    }

    /// Unblock the members of a fired group of threads and advance their
    /// pcs past the instruction they were blocked at.
    pub(in crate::eval) fn advance_thread_group(&mut self, members: &[ThreadId]) {
        for &m in members {
            let state = &mut self.threads[m];
            state.status = Status::Ready;
            state.pc = InstrId(state.pc.0 + 1);
        }
    }

    /// Block `t` at a warp-cooperative instruction with the given lane mask.
    pub(in crate::eval) fn block_at_warp_op(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        mask: u32,
    ) -> EvalResult<()> {
        if mask == 0 {
            return Err(EvalError::WarpMismatch {
                pc,
                reason: "empty lane mask".to_string(),
            });
        }
        let lane = t.0 % WARP_SIZE;
        if mask & (1 << lane) == 0 {
            return Err(EvalError::WarpMismatch {
                pc,
                reason: format!("executing lane {} is not in mask {:#010x}", lane, mask),
            });
        }
        self.record_warp_op_arrival(t, pc, mask);
        self.threads[t].status = Status::AtWarpOp { mask };
        Ok(())
    }
}

/// Whether each warp's arrivals at one barrier generation sit at one instruction wherever any is
/// `.aligned`: a warp executes an aligned barrier as one collective, so its lanes at two aligned
/// barrier instructions arrive at two barriers.
/// Whether every warp at a counted barrier has all its live lanes there as often as each other.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum LaneArrivals {
    Whole,
    Partial,
}

fn warps_converge(arrivals: &[ArrivedThread]) -> bool {
    let mut warps: HashMap<u32, Vec<&ArrivedThread>> = HashMap::new();
    for arrival in arrivals {
        warps
            .entry(arrival.thread.0 / WARP_SIZE)
            .or_default()
            .push(arrival);
    }
    warps.values().all(|lanes| {
        lanes
            .iter()
            .all(|a| a.alignment == BarrierAlignment::Unaligned)
            || lanes.iter().all(|a| a.pc == lanes[0].pc)
    })
}
