//! The scheduler of the candidate execution: run one ready thread until it
//! blocks or exits, then fire whatever group is complete (a warp or warpgroup
//! rendezvous, an mbarrier phase, a named barrier).

use crate::eval::error::{EvalError, EvalResult};
use crate::eval::interp::{BarrierArrivals, Interpreter, NUM_BARRIERS, PendingArrivals, Status};
use crate::eval::value::{MbarrierId, Value};
use crate::eval::{ThreadId, WARP_SIZE, WARPGROUP_SIZE};
use crate::logging::trace;
use crate::lowered::{InstrId, LoweredInstr, Operand};

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
            if let Some((pc, members)) = self.find_ready_warpgroup_op()? {
                trace!(
                    "warpgroup op at pc {} fired ({} lanes)",
                    pc.0,
                    members.len()
                );
                self.execute_warpgroup_op(pc, &members)?;
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

    /// Find a warpgroup whose live members all arrived at one pc, with
    /// `find_ready_warp_group`'s rules but no mask: membership is always the
    /// 128-thread range at `group_base`.
    fn find_ready_warpgroup_op(&self) -> EvalResult<Option<(InstrId, Vec<ThreadId>)>> {
        'candidates: for (leader, state) in self.threads.iter() {
            if state.status != Status::AtWarpgroupOp {
                continue;
            }
            let pc = state.pc;
            let group_base = (leader.0 / WARPGROUP_SIZE) * WARPGROUP_SIZE;
            if group_base + WARPGROUP_SIZE > self.n_threads {
                return Err(EvalError::WarpMismatch {
                    pc,
                    reason: format!(
                        "wgmma.mma_async warpgroup [{}, {}) exceeds the CTA's {} threads",
                        group_base,
                        group_base + WARPGROUP_SIZE,
                        self.n_threads
                    ),
                });
            }
            let mut members = Vec::new();
            for lane in 0..WARPGROUP_SIZE {
                let tid = ThreadId(group_base + lane);
                match self.threads[tid].status {
                    Status::AtWarpgroupOp if self.threads[tid].pc == pc => {
                        members.push(tid);
                    }
                    Status::Exited => {}
                    _ => continue 'candidates,
                }
            }
            return Ok(Some((pc, members)));
        }
        Ok(None)
    }

    /// Fire whichever named barrier can: a counted barrier once its arrival
    /// count is met (`bar.arrive` included), the full-CTA barrier once every
    /// live thread waits on its id. Returns whether one fired.
    fn try_fire_barrier(&mut self) -> EvalResult<bool> {
        // Blocked arrivals, per barrier id. Threads at a counted barrier
        // need not share a pc (warp-specialized producers and consumers
        // arrive at their own `bar.sync`), so they are grouped by id only.
        let mut waiters: [Vec<ThreadId>; NUM_BARRIERS] = std::array::from_fn(|_| Vec::new());
        // What each barrier fires on, seeded with what its `bar.arrive`
        // arrivals named. Lowering pins one arrival count per barrier id
        // (`check_barrier_arrivals`), so any one arrival gives the count.
        let mut arrivals: [Option<BarrierArrivals>; NUM_BARRIERS] =
            std::array::from_fn(|id| self.barriers[id].arrivals);
        let mut live_waiters = 0usize;
        let mut every_live_thread_waits = true;
        for (t, state) in self.threads.iter() {
            match state.status {
                Status::Exited => {}
                Status::AtBarrier { id, arrivals: at } => {
                    arrivals[id as usize] = Some(at);
                    waiters[id as usize].push(t);
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
                    if !every_live_thread_waits || waiting.len() != live_waiters {
                        continue;
                    }
                    trace!("fired bar.sync {} (full CTA)", id);
                    let waiting = waiting.clone();
                    self.record_barrier_fire(id as u32, BarrierArrivals::FullCta, &waiting);
                    self.advance_thread_group(&waiting);
                    return Ok(true);
                }
                BarrierArrivals::Count(count) => count,
            };

            let arrived = &self.barriers[id].threads;
            let total = arrived.len() + waiting.len();
            if total < count as usize {
                continue;
            }
            if total > count as usize {
                return Err(EvalError::BarrierMismatch {
                    pc: self.threads[waiting.first().copied().unwrap_or(arrived[0])].pc,
                    reason: format!(
                        "{} threads arrived at barrier {}, which fires on {} - which \
                         threads it releases would depend on the schedule",
                        total, id, count
                    ),
                });
            }
            self.barriers[id] = PendingArrivals::default();
            trace!("fired bar.sync {} ({} threads)", id, count);
            let waiting = waiting.clone();
            self.record_barrier_fire(id as u32, BarrierArrivals::Count(count), &waiting);
            self.advance_thread_group(&waiting);
            return Ok(true);
        }
        Ok(false)
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
        let Some(thread_count) = thread_count else {
            return Ok((id as u32, BarrierArrivals::FullCta));
        };
        let count = self.concrete_operand(t, pc, thread_count, "barrier thread count")?;
        // PTX ISA 9.7.13.1: the count is a multiple of the warp size, and
        // no barrier can wait for more threads than the CTA has.
        if count <= 0 || count % i64::from(WARP_SIZE) != 0 || count > i64::from(self.n_threads) {
            return Err(EvalError::BarrierMismatch {
                pc,
                reason: format!(
                    "barrier {} arrival count {} must be a positive multiple of {} \
                     no larger than the CTA's {} threads",
                    id, count, WARP_SIZE, self.n_threads
                ),
            });
        }
        Ok((id as u32, BarrierArrivals::Count(count as u32)))
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

    /// Block `t` at a warpgroup-cooperative instruction. Membership is
    /// implicit; `find_ready_warpgroup_op` checks the warpgroup's range once
    /// the whole group arrives.
    pub(in crate::eval) fn block_at_warpgroup_op(
        &mut self,
        t: ThreadId,
        pc: InstrId,
    ) -> EvalResult<()> {
        self.record_warpgroup_op_arrival(t, pc);
        self.threads[t].status = Status::AtWarpgroupOp;
        Ok(())
    }
}
