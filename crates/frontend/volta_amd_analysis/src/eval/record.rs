//! Recording the execution into its event graph (`volta_graph`), one graph thread per wave, in
//! three sections: the issue of each DS instruction, the `s_waitcnt lgkmcnt` wait that completes
//! it, and the workgroup barrier. Nothing here feeds back into execution.

use volta_graph::{
    AsyncOpId, AsyncOpKind, BarrierArrivals, BarrierWait, Effect, Footprint, GroupWait,
    OperandRole, OrdinaryAccess, ProgramPoint, Proxy, Space, StoredValue, ThreadIx,
};

use std::collections::BTreeMap;

use crate::ir::{InstrId, LaneReg, LoweredInstr, WordHalf};

use super::EvalError;
use super::interp::Interpreter;
use super::wave::{WaveId, active_lanes, same_value, same_word};

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
    /// 4, or 2 for a half-word store.
    width: u32,
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
        let accesses = self
            .distinct_writes(wave, instruction, words)
            .and_then(|words| {
                words
                    .into_iter()
                    .map(|word| self.lds_access(wave, word))
                    .collect::<Result<Vec<_>, _>>()
            });
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

    /// `words` without a lane's write of a word an earlier lane writes with the same value: one
    /// store of a value, as execution lets it be. Two lanes storing different values both stay.
    fn distinct_writes(
        &mut self,
        wave: WaveId,
        instruction: &LoweredInstr,
        words: Vec<LdsWord>,
    ) -> Result<Vec<LdsWord>, EvalError> {
        let half = match *instruction {
            LoweredInstr::DsWriteB16 { src, half, .. } => Some((src, half)),
            _ => None,
        };
        let mut first: BTreeMap<u32, (usize, LaneReg)> = BTreeMap::new();
        let mut kept = Vec::new();
        for word in words {
            if let Some((lane, reg)) = word.source {
                match first.get(&word.address) {
                    Some(&(earlier, earlier_reg)) if earlier != lane => {
                        if self.same_store(wave, half, (earlier, earlier_reg), (lane, reg))? {
                            continue;
                        }
                    }
                    Some(_) => {}
                    None => {
                        first.insert(word.address, (lane, reg));
                    }
                }
            }
            kept.push(word);
        }
        Ok(kept)
    }

    /// Whether two lanes' sources store the same value: their words, or for a 16-bit store
    /// (`half`), the halves it takes.
    fn same_store(
        &mut self,
        wave: WaveId,
        half: Option<(crate::ir::Vgpr, WordHalf)>,
        (a, a_reg): (usize, LaneReg),
        (b, b_reg): (usize, LaneReg),
    ) -> Result<bool, EvalError> {
        if let Some((src, half)) = half {
            let a = self.stored_half(wave, a, src, half)?;
            let b = self.stored_half(wave, b, src, half)?;
            return Ok(same_value(&self.arena, a, b));
        }
        let registers = &self.waves[wave].registers;
        let (a, b) = (
            registers.read_lane_word(a, a_reg)?,
            registers.read_lane_word(b, b_reg)?,
        );
        Ok(same_word(&self.arena, a, b))
    }

    /// The LDS words the instruction accesses in every active lane, in lane order. A lane
    /// exchange accesses no LDS memory.
    fn ds_words(
        &self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<Vec<LdsWord>, EvalError> {
        let exec = self.waves[wave].exec;
        let mut words = Vec::new();
        match *instruction {
            LoweredInstr::DsWrite { addr, accesses } => {
                for lane in active_lanes(exec) {
                    for (offset, data) in accesses.accesses() {
                        let start = self.lds_address(wave, lane, addr, offset)?;
                        let regs = data.regs();
                        let addresses = self.lds.word_addresses(start, regs.len() as u32)?;
                        for (address, reg) in addresses.into_iter().zip(regs) {
                            words.push(LdsWord {
                                address,
                                width: 4,
                                source: Some((lane, reg)),
                            });
                        }
                    }
                }
            }
            LoweredInstr::DsRead { addr, accesses } => {
                for lane in active_lanes(exec) {
                    for (offset, destination) in accesses.accesses() {
                        let start = self.lds_address(wave, lane, addr, offset)?;
                        let count = destination.regs().len() as u32;
                        for address in self.lds.word_addresses(start, count)? {
                            words.push(LdsWord {
                                address,
                                width: 4,
                                source: None,
                            });
                        }
                    }
                }
            }
            LoweredInstr::DsReadTrB16 { addr, offset, .. } => {
                for lane in active_lanes(exec) {
                    let start = self.lds_address(wave, lane, addr, u32::from(offset))?;
                    for address in self.lds.word_addresses(start, 2)? {
                        words.push(LdsWord {
                            address,
                            width: 4,
                            source: None,
                        });
                    }
                }
            }
            LoweredInstr::DsWriteB16 {
                addr, offset, src, ..
            } => {
                for lane in active_lanes(exec) {
                    let address = self.lds_address(wave, lane, addr, u32::from(offset))?;
                    words.push(LdsWord {
                        address: address as u32,
                        width: 2,
                        source: Some((lane, LaneReg::Vgpr(src))),
                    });
                }
            }
            LoweredInstr::DsBPermute { .. } | LoweredInstr::DsSwizzle { .. } => {}
            _ => unreachable!("only DS instructions are issued to the LDS"),
        }
        Ok(words)
    }

    /// `wave`'s ordinary access of one LDS word.
    fn lds_access(&self, wave: WaveId, word: LdsWord) -> Result<OrdinaryAccess, EvalError> {
        let effect = match word.source {
            Some((lane, reg)) => {
                let stored = self.waves[wave].registers.read_lane_word(lane, reg)?;
                Effect::Write(stored.stored())
            }
            None => Effect::Read,
        };

        Ok(OrdinaryAccess {
            space: Space::Shared,
            footprint: Footprint::Bytes {
                addr: u64::from(word.address),
                width: word.width,
            },
            proxy: Proxy::Generic,
            role: OperandRole::Plain,
            effect,
        })
    }
}

// ===== Record loads to LDS =====
// Each buffer load to LDS is an async operation over the LDS words its active lanes write.

impl Interpreter<'_> {
    /// `wave` issues the load to LDS at `pc`: an async operation writing each active lane's
    /// words, completed by a later `s_waitcnt vmcnt`. Its stored values are the first
    /// workgroup's, as the event graph's are for DS writes.
    pub(super) fn record_lds_load_issue(
        &mut self,
        wave: WaveId,
        pc: InstrId,
        writes: Vec<(u32, StoredValue)>,
    ) -> AsyncOpId {
        let op = self
            .graph
            .async_issue(thread(wave), point(pc), AsyncOpKind::LdsLoad);
        for (address, stored) in writes {
            let access = OrdinaryAccess {
                space: Space::Shared,
                footprint: Footprint::Bytes {
                    addr: u64::from(address),
                    width: 4,
                },
                proxy: Proxy::Generic,
                role: OperandRole::Plain,
                effect: Effect::Write(stored),
            };
            self.graph.ordinary_async_effect(op, thread(wave), access);
        }
        op
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

impl Interpreter<'_> {
    /// `wave`'s `s_waitcnt vmcnt(outstanding)` at `pc` completed the loads to LDS `ops`.
    pub(super) fn record_vm_wait(
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
