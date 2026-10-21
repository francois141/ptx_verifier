//! Per-thread `wgmma.mma_async` register hazards (PTX ISA 9.7.17.7): the
//! fence epochs of hazard A, the pending accumulators of hazard B, and the
//! register accesses that check them.

use crate::eval::ThreadId;
use crate::eval::error::{AccessSite, EvalError, EvalResult};
use crate::eval::interp::Interpreter;
use crate::eval::value::Value;
use crate::eval::warpgroup::WgmmaOpId;
use crate::ir::InstrId;
use crate::ir::mma::MmaShape;
use crate::ir::symbols::RegId;
use std::collections::{HashMap, VecDeque};

/// A `wgmma.mma_async` accumulator writeback not yet released by
/// `wgmma.wait_group`. The write already landed eagerly (evaluation is
/// sequential), so only the register is kept.
type PendingWgmmaAccum = RegId;

/// One wgmma-group as one thread sees it: its accumulator writebacks and the
/// `wgmma.mma_async` operations whose shared-memory locks it holds open.
#[derive(Debug, Default)]
struct WgmmaGroup {
    accums: Vec<PendingWgmmaAccum>,
    ops: Vec<WgmmaOpId>,
}

/// Per-thread `wgmma.mma_async` register-hazard state (PTX ISA 9.7.17.7). Lives
/// on `ThreadState`: registers are thread-local, so no cross-thread state is
/// read.
#[derive(Debug, Default)]
pub(in crate::eval) struct WgmmaRegState {
    /// Hazard A (`wgmma.fence`, 9.7.17.7.1): incremented by every
    /// `wgmma.fence` this thread executes.
    fence_epoch: u64,
    /// Hazard A: `(fence_epoch, pc)` as of each register's most recent write.
    /// Absent = never written = epoch 0, so the before-first-`wgmma` rule fires
    /// even for untouched registers.
    reg_epoch: HashMap<RegId, (u64, InstrId)>,
    /// Hazard A: the shape, iff the register's last write was a
    /// `wgmma.mma_async` writeback of that shape. Removed by any ordinary
    /// write; overwritten by another wgmma writeback.
    reg_shape: HashMap<RegId, MmaShape>,
    /// Hazard B (`wgmma.wait_group`, 9.7.17.7.3): writebacks and operations
    /// since the last `wgmma.commit_group`, not yet sealed into a group.
    uncommitted: WgmmaGroup,
    /// Hazard B: committed wgmma-groups, oldest first; `wgmma.wait_group
    /// N` pops from the front while more than `N` remain.
    groups: VecDeque<WgmmaGroup>,
    /// Hazard B: refcount + latest issuing pc per register across `uncommitted`
    /// and `groups`, for O(1) pending checks on the hot path. Counted, since
    /// one register can sit in several outstanding groups.
    pending: HashMap<RegId, (u32, InstrId)>,
}

impl WgmmaRegState {
    /// Hazard B: `Some(prior_pc)` iff `reg` is still pending a
    /// `wgmma.wait_group` release.
    fn pending_since(&self, reg: RegId) -> Option<InstrId> {
        self.pending
            .get(&reg)
            .filter(|&&(count, _)| count > 0)
            .map(|&(_, pc)| pc)
    }

    /// Hazard A: whether a `wgmma.mma_async` of `shape` may use `reg` as
    /// accumulator without a `wgmma.fence`: its last write was a same-shape
    /// writeback, or a fence followed that write.
    fn is_fenced_for(&self, reg: RegId, shape: MmaShape) -> bool {
        if self.reg_shape.get(&reg) == Some(&shape) {
            return true;
        }
        let last_write_epoch = self.reg_epoch.get(&reg).map(|&(e, _)| e).unwrap_or(0);
        self.fence_epoch > last_write_epoch
    }

    /// The pc of `reg`'s most recent write, if any - for a hazard-A
    /// error's `prior_write` (`None` means never written by this thread).
    fn last_write_pc(&self, reg: RegId) -> Option<InstrId> {
        self.reg_epoch.get(&reg).map(|&(_, pc)| pc)
    }

    /// Record an ordinary (non-`wgmma.mma_async`) write: resets `reg`'s
    /// fence gate to "dirty as of now" and breaks any same-shape chain.
    pub(in crate::eval) fn record_write(&mut self, reg: RegId, pc: InstrId) {
        self.reg_epoch.insert(reg, (self.fence_epoch, pc));
        self.reg_shape.remove(&reg);
    }

    /// Record a `wgmma.mma_async` accumulator writeback: `record_write`'s fence
    /// bookkeeping, plus tagging `reg` with `shape` (same-shape chains are
    /// fence-exempt) and marking it pending.
    fn record_wgmma_write(&mut self, reg: RegId, shape: MmaShape, pc: InstrId) {
        self.reg_epoch.insert(reg, (self.fence_epoch, pc));
        self.reg_shape.insert(reg, shape);
        self.uncommitted.accums.push(reg);
        let entry = self.pending.entry(reg).or_insert((0, pc));
        entry.0 += 1;
        entry.1 = pc;
    }

    /// Record that this thread took part in `wgmma.mma_async` `op`: the next
    /// `commit_group` seals it into this thread's group.
    pub(in crate::eval) fn record_wgmma_op(&mut self, op: WgmmaOpId) {
        self.uncommitted.ops.push(op);
    }

    /// `wgmma.fence`: establishes an ordering point for every register.
    pub(in crate::eval) fn fence(&mut self) {
        self.fence_epoch += 1;
    }

    /// `wgmma.commit_group`: seals this thread's uncommitted accumulator
    /// writebacks into a new wgmma-group.
    pub(in crate::eval) fn commit_group(&mut self) {
        let sealed = std::mem::take(&mut self.uncommitted);
        self.groups.push_back(sealed);
    }

    /// `wgmma.wait_group N`: releases wgmma-groups past the `N` most
    /// recent, returning the operations they held.
    pub(in crate::eval) fn wait_group(&mut self, n: u32) -> Vec<WgmmaOpId> {
        let mut released = Vec::new();
        while self.groups.len() > n as usize {
            let group = self.groups.pop_front().unwrap();
            released.extend(group.ops);
            for reg in group.accums {
                if let Some((count, _)) = self.pending.get_mut(&reg) {
                    *count -= 1;
                    if *count == 0 {
                        self.pending.remove(&reg);
                    }
                }
            }
        }
        released
    }
}

impl<'p> Interpreter<'p> {
    /// Hazard B's check (PTX ISA 9.7.17.7.3): is `reg` still pending a
    /// `wgmma.wait_group` release? Used by `read_reg`/`write_reg`, never by
    /// wgmma's own accumulator access.
    pub(in crate::eval) fn check_wgmma_pending(
        &self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
    ) -> EvalResult<()> {
        if let Some(prior_pc) = self.threads[t].wgmma.pending_since(reg) {
            return Err(EvalError::WgmmaWaitGroupHazard {
                thread: t,
                pc,
                reg,
                prior_write: AccessSite {
                    thread: t,
                    pc: prior_pc,
                    is_write: true,
                },
            });
        }
        Ok(())
    }

    /// Hazard A's check (PTX ISA 9.7.17.7.1): is `wgmma.mma_async`'s access to
    /// accumulator `reg` of `shape` fenced? See `WgmmaRegState::is_fenced_for`.
    fn check_wgmma_fence(
        &self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
        shape: MmaShape,
    ) -> EvalResult<()> {
        let w = &self.threads[t].wgmma;
        if w.is_fenced_for(reg, shape) {
            return Ok(());
        }
        let prior_write = w.last_write_pc(reg).map(|p| AccessSite {
            thread: t,
            pc: p,
            is_write: true,
        });
        Err(EvalError::WgmmaFenceHazard {
            thread: t,
            pc,
            reg,
            shape,
            prior_write,
        })
    }

    /// Read a `wgmma.mma_async` accumulator seed (`scale_d` true): hazard A's
    /// check but not hazard B's, since the thread's own same-chain pending
    /// writeback is allowed.
    pub(in crate::eval) fn read_reg_wgmma_accum(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
        shape: MmaShape,
    ) -> EvalResult<Value> {
        self.check_wgmma_fence(t, pc, reg, shape)?;
        Ok(self.threads[t]
            .regs
            .read(reg)
            .unwrap_or(Value::Scalar(self.undefined)))
    }

    /// Write a `wgmma.mma_async` accumulator result: hazard A's check always
    /// (so a chain's leading call is checked), then A's shape tag and B's
    /// pending mark, without B's check.
    pub(in crate::eval) fn write_reg_wgmma_accum(
        &mut self,
        t: ThreadId,
        pc: InstrId,
        reg: RegId,
        shape: MmaShape,
        value: Value,
    ) -> EvalResult<()> {
        self.check_wgmma_fence(t, pc, reg, shape)?;
        self.threads[t].regs.write(reg, value);
        self.threads[t].wgmma.record_wgmma_write(reg, shape, pc);
        Ok(())
    }
}

#[cfg(test)]
mod wgmma_reg_state_tests {
    use id_collections::Id;

    use super::WgmmaRegState;
    use crate::ir::InstrId;
    use crate::ir::mma::MmaShape;
    use crate::ir::symbols::RegId;
    use crate::ir::types::RegClass;

    fn pc(n: u32) -> InstrId {
        InstrId::from_index(n)
    }

    fn reg(n: u32) -> RegId {
        RegId::new(RegClass::Bits32, n)
    }

    const S: MmaShape = MmaShape::new(64, 8, 16);
    const S2: MmaShape = MmaShape::new(64, 16, 16);

    /// Hazard A: a register nothing has ever written is not fenced -
    /// "before the first wgmma.mma_async in a warpgroup" (9.7.17.7.1).
    #[test]
    fn test_fence_hazard_before_first_wgmma_with_no_fence_ever() {
        let w = WgmmaRegState::default();
        assert!(!w.is_fenced_for(reg(0), S));
        assert_eq!(w.last_write_pc(reg(0)), None);
    }

    /// One `wgmma.fence` is enough to satisfy a never-written register.
    #[test]
    fn test_fence_clears_hazard_for_never_written_register() {
        let mut w = WgmmaRegState::default();
        w.fence();
        assert!(w.is_fenced_for(reg(0), S));
    }

    /// An ordinary write, then a wgmma access with no intervening fence,
    /// is a hazard.
    #[test]
    fn test_fence_hazard_ordinary_write_then_wgmma_without_fence() {
        let mut w = WgmmaRegState::default();
        w.record_write(reg(0), pc(1));
        assert!(!w.is_fenced_for(reg(0), S));
        assert_eq!(w.last_write_pc(reg(0)), Some(pc(1)));
    }

    /// The ISA's one exemption: a same-shape wgmma.mma_async accumulator
    /// chain needs zero fences between its own links.
    #[test]
    fn test_fence_exempt_same_shape_chain_needs_no_fence() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        assert!(w.is_fenced_for(reg(0), S));
    }

    /// The exemption is shape-specific: a different-shape wgmma access to
    /// the same register still needs a fence.
    #[test]
    fn test_fence_hazard_different_shape_chain_needs_fence() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        assert!(!w.is_fenced_for(reg(0), S2));
    }

    /// An ordinary write breaks an otherwise-exempt same-shape chain, even
    /// though the shape "would have" matched.
    #[test]
    fn test_fence_hazard_ordinary_write_breaks_same_shape_chain() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        w.record_write(reg(0), pc(2));
        assert!(!w.is_fenced_for(reg(0), S));
    }

    /// A register written after a fence, read by wgmma with no *new*
    /// fence, is still a hazard - the fence must come after the write.
    #[test]
    fn test_fence_hazard_write_after_fence_needs_its_own_fence() {
        let mut w = WgmmaRegState::default();
        w.fence();
        w.record_write(reg(0), pc(1));
        assert!(!w.is_fenced_for(reg(0), S));
        w.fence();
        assert!(w.is_fenced_for(reg(0), S));
    }

    /// Hazard B: a register a wgmma.mma_async wrote is pending until its
    /// wgmma-group is released.
    #[test]
    fn test_wait_group_pending_until_released() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        assert_eq!(w.pending_since(reg(0)), Some(pc(1)));
        w.commit_group();
        w.wait_group(0);
        assert_eq!(w.pending_since(reg(0)), None);
    }

    /// A register appearing in two interleaved, still-outstanding groups
    /// stays pending until *both* are released - releasing only the
    /// older one must not clear it.
    #[test]
    fn test_wait_group_pending_survives_partial_release() {
        let mut w = WgmmaRegState::default();
        w.record_wgmma_write(reg(0), S, pc(1));
        w.commit_group(); // group 0, contains reg(0)
        w.record_wgmma_write(reg(0), S, pc(2));
        w.commit_group(); // group 1, also contains reg(0)
        // Keep 1 group pending (group 1) - releases only group 0.
        w.wait_group(1);
        assert!(w.pending_since(reg(0)).is_some(), "still pending group 1");
        w.wait_group(0);
        assert_eq!(w.pending_since(reg(0)), None);
    }
}
