//! Recording the execution into its event graph (`volta_graph`), one graph thread per wave, in
//! three sections: the issue of each DS instruction, the `s_waitcnt lgkmcnt` wait that completes
//! it, and the workgroup barrier. Nothing here feeds back into execution.

use volta_graph::{
    AsyncOpId, AsyncOpKind, BarrierArrivals, BarrierWait, Effect, Footprint, GroupWait,
    OperandRole, OrdinaryAccess, ProgramPoint, Proxy, Space, StoredValue, ThreadIx,
};

use crate::ir::{InstrId, LaneReg, LoweredInstr};

use super::EvalError;
use super::interp::Interpreter;
use super::wave::WaveId;

/// Graph threads are waves (`ThreadUnit::Wave`).
fn thread(wave: WaveId) -> ThreadIx {
    ThreadIx(wave.0)
}

fn point(pc: InstrId) -> ProgramPoint {
    ProgramPoint(pc.0)
}

// ===== Record issue =====
// Each DS instruction is an async operation over its lanes' LDS words.

/// One LDS word a DS instruction accesses, with the source lane and register for a write.
#[derive(Debug, Clone, Copy)]
struct LdsWord {
    address: u32,
    source: Option<(usize, LaneReg)>,
}

impl Interpreter<'_> {
    /// `wave` issues the DS instruction at `pc`: an async operation with one effect per LDS word
    /// it accesses, completed by a later `s_waitcnt lgkmcnt`.
    pub(super) fn record_ds_issue(
        &mut self,
        wave: WaveId,
        pc: InstrId,
        instruction: &LoweredInstr,
    ) -> Result<AsyncOpId, EvalError> {
        // Resolve addresses without selecting a workgroup: a varying address rejects the run.
        let words = self.ds_words(wave, instruction)?;
        // The graph uses representative stored values; execution keeps each workgroup's data.
        self.waves[wave].registers.set_view(Some(0));
        let accesses = words
            .into_iter()
            .map(|word| self.lds_access(wave, word))
            .collect::<Result<Vec<_>, _>>();
        self.waves[wave].registers.set_view(None);
        let accesses = accesses?;
        let op = self
            .graph
            .async_issue(thread(wave), point(pc), AsyncOpKind::Ds);

        for access in accesses {
            self.graph.ordinary_async_effect(op, thread(wave), access);
        }

        Ok(op)
    }

    /// The LDS words the instruction accesses in every lane, in lane order. A lane exchange
    /// accesses no LDS memory.
    fn ds_words(
        &self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<Vec<LdsWord>, EvalError> {
        let mut words = Vec::new();
        match *instruction {
            LoweredInstr::DsWrite { addr, accesses } => {
                for lane in 0..64 {
                    for (offset, data) in accesses.accesses() {
                        let start = self.lds_address(wave, lane, addr, offset)?;
                        let regs = data.regs();
                        let addresses = self.lds.word_addresses(start, regs.len() as u32)?;
                        for (address, reg) in addresses.into_iter().zip(regs) {
                            words.push(LdsWord {
                                address,
                                source: Some((lane, reg)),
                            });
                        }
                    }
                }
            }
            LoweredInstr::DsRead { addr, accesses } => {
                for lane in 0..64 {
                    for (offset, destination) in accesses.accesses() {
                        let start = self.lds_address(wave, lane, addr, offset)?;
                        let count = destination.regs().len() as u32;
                        for address in self.lds.word_addresses(start, count)? {
                            words.push(LdsWord {
                                address,
                                source: None,
                            });
                        }
                    }
                }
            }
            LoweredInstr::DsBPermute { .. } => {}
            _ => unreachable!("only DS instructions are issued to the LDS"),
        }
        Ok(words)
    }

    /// `wave`'s ordinary access of one LDS word.
    fn lds_access(&self, wave: WaveId, word: LdsWord) -> Result<OrdinaryAccess, EvalError> {
        let effect = match word.source {
            Some((lane, reg)) => {
                let stored = self.waves[wave].registers.read_lane_reg(lane, reg)?;
                Effect::Write(StoredValue::Scalar(stored))
            }
            None => Effect::Read,
        };

        Ok(OrdinaryAccess {
            space: Space::Shared,
            footprint: Footprint::Bytes {
                addr: u64::from(word.address),
                width: 4,
            },
            proxy: Proxy::Generic,
            role: OperandRole::Plain,
            effect,
        })
    }
}

// ===== Record wait =====
// Each `s_waitcnt lgkmcnt` completes DS instructions in a generation of the wave's wait object.

impl Interpreter<'_> {
    /// `wave`'s `s_waitcnt lgkmcnt(outstanding)` at `pc` completed the DS instructions `ops`: a
    /// generation of the wave's wait object tracks them, then releases the wave.
    pub(super) fn record_lgkm_wait(
        &mut self,
        wave: WaveId,
        pc: InstrId,
        outstanding: usize,
        ops: &[AsyncOpId],
    ) {
        let wait = GroupWait::Async {
            keep_pending: outstanding as u32,
        };
        self.graph.group_wait(thread(wave), point(pc), wait, ops);
    }
}

// ===== Record barrier =====
// Each `s_barrier` release is a generation of the workgroup barrier that the waves gather into
// and are scattered from; each `s_endpgm` ends its wave's program order.

/// The workgroup's one barrier. AMD has a single `s_barrier`, recorded as named barrier 0.
const WORKGROUP_BARRIER: u8 = 0;

impl Interpreter<'_> {
    /// `wave` arrives at the workgroup barrier at `pc` and waits in its forming generation.
    pub(super) fn record_barrier_arrival(&mut self, wave: WaveId, pc: InstrId) {
        let arrivals = BarrierArrivals::FullCta;
        let wait = BarrierWait::Blocking;
        self.graph
            .barrier_arrive(thread(wave), point(pc), WORKGROUP_BARRIER, arrivals, wait);
    }

    /// The barrier fires: every exited wave counts as arrived, the generation completes, and its
    /// waiting waves resume.
    pub(super) fn record_barrier_release(&mut self) {
        self.graph.barrier_fire(WORKGROUP_BARRIER);
    }

    /// `wave` ends at `pc`: nothing follows in its program order.
    pub(super) fn record_exit(&mut self, wave: WaveId, pc: InstrId) {
        self.graph.exit(thread(wave), point(pc));
    }
}
