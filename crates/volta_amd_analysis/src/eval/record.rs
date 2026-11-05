//! Recording the execution into its event graph (`volta_graph`), one graph thread per wave, in
//! three sections: the issue of each DS instruction, the `s_waitcnt lgkmcnt` wait that completes
//! it, and the workgroup barrier. Execution never reads this bookkeeping.

use std::collections::HashMap;

use volta_expr::ExprId;
use volta_graph::{
    AccessMode, AsyncOpId, AsyncOpKind, BarrierArrivals, ContributionKind, Footprint,
    GenerationEvidence, GenerationId, GenerationKind, MemAccess, OperandRole, OrderingKind,
    ProgramPoint, Proxy, Space, StoredValue, SyncObjectId, SyncObjectKind, ThreadIx,
};

use crate::ir::{InstrId, LoweredInstr};

use super::EvalError;
use super::interp::Interpreter;
use super::wave::{Status, WaveId};

/// A barrier generation the waves are gathering into, and each waiting wave with the `pc` of its
/// `s_barrier`.
#[derive(Debug)]
struct FormingBarrier {
    generation: GenerationId,
    waiting: Vec<(WaveId, InstrId)>,
}

#[derive(Debug, Default)]
pub(super) struct Recording {
    /// The workgroup barrier, once a wave reaches `s_barrier`.
    barrier: Option<SyncObjectId>,

    /// How many barrier generations have opened: the next one's index.
    barrier_generations: u32,

    /// The generation the waves are gathering into, until the barrier releases them.
    forming: Option<FormingBarrier>,

    /// Each wave's `s_waitcnt lgkmcnt` object, and how many of its generations have opened.
    lgkm_waits: HashMap<WaveId, (SyncObjectId, u32)>,
}

/// Graph threads are waves (`ThreadUnit::Wave`).
fn thread(wave: WaveId) -> ThreadIx {
    ThreadIx(wave.0)
}

fn point(pc: InstrId) -> ProgramPoint {
    ProgramPoint(pc.0)
}

// ===== Record issue =====
// Each DS instruction is an async operation over its lanes' LDS words.

/// One LDS word a DS instruction accesses, with the value a write stores.
#[derive(Debug, Clone, Copy)]
struct LdsWord {
    address: u32,
    stored: Option<ExprId>,
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
        let words = self.ds_words(wave, instruction)?;
        let op = self
            .graph
            .async_issue(thread(wave), point(pc), AsyncOpKind::Ds);

        for word in words {
            let access = self.lds_access(wave, word);
            self.graph.async_effect(op, access);
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
                let registers = &self.waves[wave].registers;
                for lane in 0..64 {
                    for (offset, data) in accesses.accesses() {
                        let start = self.lds_address(wave, lane, addr, offset)?;
                        let regs = data.regs();
                        let addresses = self.lds.word_addresses(start, regs.len() as u32)?;
                        for (address, reg) in addresses.into_iter().zip(regs) {
                            let stored = Some(registers.read_lane_reg(lane, reg)?);
                            words.push(LdsWord { address, stored });
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
                                stored: None,
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

    /// `wave`'s access of one LDS word, storing a value if it writes.
    fn lds_access(&mut self, wave: WaveId, word: LdsWord) -> MemAccess {
        let (mode, value) = match word.stored {
            Some(stored) => {
                let value = self.graph.value(StoredValue::Scalar(stored));
                (AccessMode::Write, Some(value))
            }
            None => (AccessMode::Read, None),
        };

        MemAccess {
            space: Space::Shared,
            mode,
            ordering: OrderingKind::Ordinary,
            proxy: Proxy::Generic,
            footprint: Footprint::Bytes {
                addr: u64::from(word.address),
                width: 4,
            },
            role: OperandRole::Plain,
            attributed: thread(wave),
            value,
        }
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
        if ops.is_empty() {
            return;
        }

        let generation = self.open_lgkm_generation(wave, outstanding);
        for &op in ops {
            self.graph.track(op, generation, 0);
        }

        let evidence = GenerationEvidence::default();
        self.graph.complete_generation(generation, evidence);
        self.graph.resume(thread(wave), point(pc), generation);
    }

    /// The next generation of `wave`'s `lgkmcnt` wait object, which its first wait creates.
    fn open_lgkm_generation(&mut self, wave: WaveId, outstanding: usize) -> GenerationId {
        let (object, index) = match self.rec.lgkm_waits.get(&wave) {
            Some(&known) => known,
            None => {
                let kind = SyncObjectKind::AsyncGroupWait {
                    thread: thread(wave),
                };
                (self.graph.sync_object(kind), 0)
            }
        };
        self.rec.lgkm_waits.insert(wave, (object, index + 1));

        let kind = GenerationKind::AsyncGroupWait {
            keep_pending: outstanding as u32,
        };
        self.graph.open_generation(object, index, kind)
    }
}

// ===== Record barrier =====
// Each `s_barrier` release is a generation of the workgroup barrier that the waves gather into
// and are scattered from; each `s_endpgm` ends its wave's program order.

impl Interpreter<'_> {
    /// `wave` arrives at the workgroup barrier at `pc` and waits in its forming generation.
    pub(super) fn record_barrier_arrival(&mut self, wave: WaveId, pc: InstrId) {
        let mut forming = match self.rec.forming.take() {
            Some(forming) => forming,
            None => self.open_barrier_generation(),
        };

        let blocking = ContributionKind::Blocking;
        self.graph
            .contribute(thread(wave), point(pc), forming.generation, blocking);
        forming.waiting.push((wave, pc));

        self.rec.forming = Some(forming);
    }

    /// The next generation of the workgroup barrier, which no wave has joined yet.
    fn open_barrier_generation(&mut self) -> FormingBarrier {
        let object = self.barrier_object();
        let index = self.rec.barrier_generations;
        self.rec.barrier_generations += 1;

        let arrivals = BarrierArrivals::FullCta;
        let kind = GenerationKind::Barrier { arrivals };
        let generation = self.graph.open_generation(object, index, kind);

        FormingBarrier {
            generation,
            waiting: Vec::new(),
        }
    }

    /// The workgroup's one barrier. AMD has a single `s_barrier`, recorded as named barrier 0.
    fn barrier_object(&mut self) -> SyncObjectId {
        if let Some(object) = self.rec.barrier {
            return object;
        }

        let object = self
            .graph
            .sync_object(SyncObjectKind::NamedBarrier { id: 0 });
        self.rec.barrier = Some(object);
        object
    }

    /// The barrier fires: every exited wave counts as arrived, the generation completes, and its
    /// waiting waves resume.
    pub(super) fn record_barrier_release(&mut self) {
        let Some(forming) = self.rec.forming.take() else {
            return;
        };

        for (wave, state) in self.waves.iter() {
            if state.status == Status::Exited
                && let Some(exit) = self.graph.exit_event(thread(wave))
            {
                self.graph.contribute_exited(forming.generation, exit);
            }
        }

        let evidence = GenerationEvidence::default();
        self.graph.complete_generation(forming.generation, evidence);

        for (wave, pc) in forming.waiting {
            self.graph
                .resume(thread(wave), point(pc), forming.generation);
        }
    }

    /// `wave` ends at `pc`: nothing follows in its program order.
    pub(super) fn record_exit(&mut self, wave: WaveId, pc: InstrId) {
        self.graph.exit(thread(wave), point(pc));
    }
}
