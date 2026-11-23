//! A lane's private (scratch) dwords, which compilers spill registers to: each a location of
//! the wave's register state, so undoing an execution and per-workgroup states cover it.

use crate::ir::{LaneReg, Vgpr};

use super::{EvalError, LoadCounter, Slot, Stored, WaveRegisters, Word};

impl WaveRegisters {
    /// Load the lane's private dwords from byte `offset`, one per register of `dst`, unreadable
    /// until a `vmcnt` wait completes the load.
    pub(in crate::eval) fn scratch_load(
        &mut self,
        lane: usize,
        dst: &[Vgpr],
        offset: u16,
    ) -> Result<(), EvalError> {
        let words = scratch_dwords(offset, dst.len())
            .map(|dword| {
                self.scratch_at(lane, dword)?
                    .ok_or(EvalError::UninitializedScratch {
                        lane,
                        offset: 4 * u32::from(dword),
                    })
            })
            .collect::<Result<Vec<_>, _>>()?;
        self.start_vector_load(lane, dst, &words, LoadCounter::Vm)
    }

    /// Store the word of each register of `src` to the lane's private dwords from byte `offset`.
    pub(in crate::eval) fn scratch_store(
        &mut self,
        lane: usize,
        src: &[LaneReg],
        offset: u16,
    ) -> Result<(), EvalError> {
        let words = src
            .iter()
            .map(|&reg| self.read_lane_word(lane, reg))
            .collect::<Result<Vec<_>, _>>()?;
        for (dword, word) in scratch_dwords(offset, words.len()).zip(words) {
            let slot = scratch_slot(lane, dword);
            self.note_write(slot);
            self.assign(slot, Stored::Scratch(Some(word)));
        }
        Ok(())
    }

    fn scratch_at(&self, lane: usize, dword: u16) -> Result<Option<Word>, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        match self.varying_state(scratch_slot(lane, dword))? {
            Some(Stored::Scratch(word)) => Ok(*word),
            _ => Ok(registers.scratch.get(usize::from(dword)).copied().flatten()),
        }
    }
}

fn scratch_slot(lane: usize, dword: u16) -> Slot {
    Slot::Scratch {
        lane: lane as u8,
        dword,
    }
}

/// The indices of `count` consecutive private dwords from the dword-aligned byte `offset`.
fn scratch_dwords(offset: u16, count: usize) -> impl Iterator<Item = u16> {
    (offset / 4..).take(count)
}
