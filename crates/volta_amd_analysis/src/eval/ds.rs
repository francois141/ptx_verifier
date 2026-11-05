//! DS instructions as the LDS performs them for one wave: issued in order into the wave's
//! `lgkmcnt` queue, which `Interpreter::wait_lgkm` completes. Their data moves at issue; a read's
//! or lane exchange's destinations stay pending until it completes.

use crate::ir::{LoweredInstr, Vgpr};

use super::wave::{LgkmInFlight, LoadCounter, WaveId};
use super::{EvalError, Interpreter};

impl Interpreter<'_> {
    /// Issue the DS instruction for every lane of `wave`, in flight until a wait completes it.
    pub(super) fn execute_ds(
        &mut self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        let dst = match *instruction {
            LoweredInstr::DsBPermute {
                dst,
                addr,
                src,
                offset,
            } => {
                self.execute_ds_bpermute(wave, dst, addr, src, offset)?;
                vec![dst]
            }
            LoweredInstr::DsRead { accesses, .. } => {
                for lane in 0..64 {
                    self.execute_lane(wave, lane, instruction)?;
                }
                let mut dst: Vec<Vgpr> = Vec::new();
                for (_, destination) in accesses.accesses() {
                    dst.extend_from_slice(destination.regs());
                }
                dst
            }
            LoweredInstr::DsWrite { addr, accesses } => {
                self.ds_write(wave, addr, accesses)?;
                Vec::new()
            }
            _ => unreachable!("only DS instructions are issued to the LDS"),
        };
        self.waves[wave]
            .lgkm_in_flight
            .push_back(LgkmInFlight::Ds { dst });
        Ok(())
    }

    /// Gather register values across the wave, pending until an LGKM wait completes the exchange.
    fn execute_ds_bpermute(
        &mut self,
        wave: WaveId,
        dst: Vgpr,
        addr: Vgpr,
        src: Vgpr,
        offset: u16,
    ) -> Result<(), EvalError> {
        let registers = &mut self.waves[wave].registers;
        let mut values = Vec::with_capacity(64);

        // Read every source before changing destinations, which may overlap `addr` or `src`.
        for lane in 0..64 {
            let address = registers.read_concrete_address_vgpr(&self.arena, lane, addr)?;
            // CDNA4 §12.12: bits [7:2] select the source lane; no LDS memory is accessed.
            let source_lane = ((address.wrapping_add(u32::from(offset)) >> 2) & 63) as usize;
            values.push(registers.read_vgpr(source_lane, src)?);
        }

        for (lane, value) in values.into_iter().enumerate() {
            registers.start_vector_load(lane, &[dst], &[value], LoadCounter::Lgkm)?;
        }
        Ok(())
    }
}
