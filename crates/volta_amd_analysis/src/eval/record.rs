//! Recording the execution into its event graph (`volta_graph`), one graph thread per wave: each
//! `s_barrier` release is a generation of the workgroup barrier that the waves gather into and
//! are scattered from, and each `s_endpgm` ends its wave's program order. Execution never reads
//! this bookkeeping.

use volta_graph::{
    BarrierArrivals, ContributionKind, GenerationEvidence, GenerationId, GenerationKind,
    ProgramPoint, SyncObjectId, SyncObjectKind, ThreadIx,
};

use crate::ir::InstrId;

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
}

/// Graph threads are waves (`ThreadUnit::Wave`).
fn thread(wave: WaveId) -> ThreadIx {
    ThreadIx(wave.0)
}

fn point(pc: InstrId) -> ProgramPoint {
    ProgramPoint(pc.0)
}

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
