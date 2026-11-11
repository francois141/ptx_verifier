//! DS instructions as the LDS performs them for one wave: issued in order into the wave's
//! `lgkmcnt` queue, which `Interpreter::wait_lgkm` completes. Their data moves at issue; a read's
//! or lane exchange's destinations stay pending until it completes.

use crate::ir::{InstrId, LoweredInstr, Vgpr};

use super::wave::{LgkmInFlight, LoadCounter, WaveId, active_lanes, lane_bit};
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
                registers.read_vgpr(source_lane, src)?
            } else {
                self.arena.int(0)
            };
            values.push((lane, value));
        }

        for (lane, value) in values {
            registers.start_vector_load(lane, &[dst], &[value], LoadCounter::Lgkm)?;
        }
        Ok(())
    }
}
