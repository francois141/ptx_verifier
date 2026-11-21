//! DS instructions as the LDS performs them for one wave: issued in order into the wave's
//! `lgkmcnt` queue, which `Interpreter::wait_lgkm` completes. Their data moves at issue; a read's
//! or lane exchange's destinations stay pending until it completes.

use crate::ir::{BufferAddress, BufferLdsWidth, InstrId, LoweredInstr, Vgpr};

use super::wave::{LgkmInFlight, LoadCounter, WaveId, active_lanes, lane_bit};
use super::word::Word;
use super::{EvalError, Interpreter};

impl Interpreter<'_> {
    /// Issue the DS instruction at `pc` for the active lanes of `wave`, in flight until a wait
    /// completes it. Its words enter the event graph before any lane runs, so an access the run
    /// rejects still appears in the graph.
    pub(super) fn execute_ds(
        &mut self,
        wave: WaveId,
        pc: InstrId,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        let op = self.record_ds_issue(wave, pc, instruction)?;
        self.execute_each_workgroup(wave, instruction)?;
        let dst = match instruction {
            LoweredInstr::DsBPermute { dst, .. } => vec![*dst],
            LoweredInstr::DsRead { accesses, .. } => accesses
                .accesses()
                .into_iter()
                .flat_map(|(_, destination)| destination.regs().to_vec())
                .collect(),
            LoweredInstr::DsReadTrB16 { dst, .. } => dst.to_vec(),
            LoweredInstr::DsWrite { .. } => Vec::new(),
            _ => unreachable!("only DS instructions are issued to the LDS"),
        };
        let lanes = self.waves[wave].exec;
        self.waves[wave]
            .lgkm_in_flight
            .push_back(LgkmInFlight::Ds { op, dst, lanes });
        Ok(())
    }

    /// Gather register values across the wave's active lanes, pending until an LGKM wait
    /// completes the exchange.
    pub(super) fn execute_ds_bpermute(
        &mut self,
        wave: WaveId,
        dst: Vgpr,
        addr: Vgpr,
        src: Vgpr,
        offset: u16,
    ) -> Result<(), EvalError> {
        let exec = self.waves[wave].exec;
        let registers = &mut self.waves[wave].registers;
        let mut values = Vec::with_capacity(64);

        // Read every source before changing destinations, which may overlap `addr` or `src`.
        for lane in active_lanes(exec) {
            let address = registers.read_concrete_address_vgpr(&self.arena, lane, addr)?;
            // CDNA4 §12.12: bits [7:2] select the source lane; no LDS memory is accessed.
            let source_lane = ((address.wrapping_add(u32::from(offset)) >> 2) & 63) as usize;
            // EXEC applies to the source read as well: an inactive source lane delivers 0.
            let value = if lane_bit(exec, source_lane) {
                registers.read_vgpr_word(source_lane, src)?
            } else {
                Word::Value(self.arena.int(0))
            };
            values.push((lane, value));
        }

        for (lane, value) in values {
            registers.start_vector_load(lane, &[dst], &[value], LoadCounter::Lgkm)?;
        }
        Ok(())
    }

    /// Issue a buffer load to LDS for the active lanes of `wave`: its LDS words enter the event
    /// graph, then each workgroup's data lands at issue, and each lane counts it under `vmcnt`.
    pub(super) fn execute_buffer_load_lds(
        &mut self,
        wave: WaveId,
        pc: InstrId,
        width: BufferLdsWidth,
        address: BufferAddress,
    ) -> Result<(), EvalError> {
        let instruction = LoweredInstr::BufferLoadLds { width, address };
        self.execute_each_workgroup(wave, &instruction)?;
        // The graph records the first workgroup's words, as it does for DS writes.
        self.lds.select(0);
        let exec = self.waves[wave].exec;
        let mut writes = Vec::new();
        for lane in active_lanes(exec) {
            let start = self.lds_load_address(wave, lane, width)?;
            let addresses = self.lds.word_addresses(start, width.words())?;
            let words = self.lds.read(start, width.words())?;
            writes.extend(
                addresses
                    .into_iter()
                    .zip(words.into_iter().map(Word::stored)),
            );
        }
        let op = self.record_lds_load_issue(wave, pc, writes);
        for lane in active_lanes(exec) {
            self.waves[wave].registers.start_lds_load(lane, op);
        }
        Ok(())
    }
}
