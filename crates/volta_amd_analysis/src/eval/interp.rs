//! The interpreter of workgroup 0: its run over every wave, and its execution of vector
//! instructions in one lane of a wave.

use id_collections::IdVec;
use volta_expr::ExprArena;

use crate::ir::{InstrId, LoweredInstr, LoweredKernel};

use super::EvalError;
use super::global::{GlobalMemory, InputArray};
use super::launch::{WorkgroupLaunch, initialize_waves};
use super::scalar::KernargBuffer;
use super::wave::{Status, WaveId, WaveState};

/// The symbolic execution state of workgroup 0: one `WaveState` per wave, each holding that
/// wave's scalar and vector registers, whose values are expressions of `arena`.
pub(crate) struct Interpreter<'a> {
    pub(super) arena: ExprArena,
    pub(super) kernarg: KernargBuffer<'a>,
    pub(super) global: GlobalMemory,
    pub(super) waves: IdVec<WaveId, WaveState>,
}

/// How the execution of workgroup 0 ended.
#[derive(Debug, PartialEq, Eq)]
pub enum Terminal {
    /// Every wave executed `s_endpgm`.
    Completed,
    /// `wave` could not execute the instruction at `pc`, which ended the run.
    Aborted {
        wave: WaveId,
        pc: InstrId,
        error: EvalError,
    },
}

impl<'a> Interpreter<'a> {
    /// Launch workgroup 0 with `kernarg` as the argument buffer at `launch.kernarg_address`
    /// and `inputs` in global memory.
    pub(crate) fn new(
        kernel: &LoweredKernel,
        launch: &WorkgroupLaunch,
        kernarg: &'a [u8],
        inputs: &[InputArray],
    ) -> Result<Self, EvalError> {
        let mut arena = ExprArena::new();
        let waves = initialize_waves(kernel, launch, &mut arena)?;
        let kernarg = KernargBuffer {
            address: launch.kernarg_address,
            bytes: kernarg,
        };
        let global = GlobalMemory::new(inputs, &kernarg, &mut arena)?;
        Ok(Self {
            arena,
            kernarg,
            global,
            waves,
        })
    }

    /// Run each ready wave until it exits, stopping at the first instruction a wave cannot
    /// execute. `kernel` must be the kernel `new` launched.
    pub(crate) fn run(&mut self, kernel: &LoweredKernel) -> Terminal {
        while let Some(wave) = self.next_ready() {
            let pc = self.waves[wave].pc;
            if let Err(error) = self.step(wave, kernel) {
                return Terminal::Aborted { wave, pc, error };
            }
        }
        Terminal::Completed
    }

    fn next_ready(&self) -> Option<WaveId> {
        self.waves
            .iter()
            .find(|(_, state)| state.status == Status::Ready)
            .map(|(wave, _)| wave)
    }

    /// Execute the instruction at `wave`'s pc and move past it.
    pub(super) fn step(&mut self, wave: WaveId, kernel: &LoweredKernel) -> Result<(), EvalError> {
        let pc = self.waves[wave].pc;
        let instruction = kernel
            .instructions
            .get(pc)
            .ok_or(EvalError::MissingEndPgm)?;
        match instruction {
            LoweredInstr::EndPgm => {
                self.waves[wave].status = Status::Exited;
                return Ok(());
            }
            LoweredInstr::ScalarLoadDwordx4 { .. } | LoweredInstr::WaitCnt { .. } => {
                self.execute_scalar(wave, instruction)?;
            }
            // EXEC holds every lane: launches are full waves and no supported instruction writes it.
            LoweredInstr::Shl32 { .. }
            | LoweredInstr::GlobalLoadDword { .. }
            | LoweredInstr::GlobalStoreDword { .. } => {
                for lane in 0..64 {
                    self.execute_lane(wave, lane, instruction)?;
                }
            }
        }
        self.waves[wave].pc = InstrId(pc.0 + 1);
        Ok(())
    }

    /// Execute one instruction for an active lane of `wave` selected by the caller.
    pub(crate) fn execute_lane(
        &mut self,
        wave: WaveId,
        lane: usize,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        let registers = &mut self.waves[wave].registers;
        match instruction {
            LoweredInstr::Shl32 { dst, src, shift } => {
                // Read before writing because the source and destination may be the same register.
                let value = registers.read_vgpr(lane, *src)?;

                // AMD uses only the low five bits of the shift count: 34 becomes 2, and 32 becomes 0.
                let amount = self.arena.int(i64::from(shift & 31));
                let shifted = self.arena.shl(value, amount);

                // For a known numeric value, keep only the low 32 bits of the result.
                // For symbolic values, follow PTX's model and keep the shift expression without truncation.
                // TODO: Should this be handled differently?
                let result = if self.arena.as_int_const(value).is_some() {
                    let mask = self.arena.int(i64::from(u32::MAX));
                    self.arena.bit_and(shifted, mask)
                } else {
                    shifted
                };
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::GlobalLoadDword { dst, vaddr, saddr } => {
                // An SGPR-pair base plus a 32-bit VGPR offset (CDNA4 §10.4), zero-extended as in
                // LLVM 21.1.8's `SelectGlobalSAddr`.
                let base = registers.read_address(&self.arena, *saddr)?;
                let offset = registers.read_vgpr(lane, *vaddr)?;
                let offset = self
                    .arena
                    .as_int_const(offset)
                    .and_then(|offset| u32::try_from(offset).ok())
                    .ok_or(EvalError::InvalidAddressVgpr { lane, reg: *vaddr })?;
                let address = base
                    .checked_add(u64::from(offset))
                    .ok_or(EvalError::AddressOverflow)?;
                let value = self.global.load_dword(address, &mut self.arena)?;
                registers.start_vector_load(lane, *dst, value)
            }
            _ => Err(EvalError::UnsupportedInstruction),
        }
    }
}
