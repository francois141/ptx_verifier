//! The interpreter of workgroup 0 and its execution of vector instructions in one lane of a wave.

use id_collections::IdVec;
use volta_expr::ExprArena;

use crate::ir::{LoweredInstr, LoweredKernel};

use super::EvalError;
use super::launch::{WorkgroupLaunch, initialize_waves};
use super::scalar::KernargBuffer;
use super::wave::{WaveId, WaveState};

/// The symbolic execution state of workgroup 0: one `WaveState` per wave, each holding that
/// wave's scalar and vector registers, whose values are expressions of `arena`.
pub(crate) struct Interpreter<'a> {
    pub(super) arena: ExprArena,
    pub(super) kernarg: KernargBuffer<'a>,
    pub(super) waves: IdVec<WaveId, WaveState>,
}

impl<'a> Interpreter<'a> {
    /// Launch workgroup 0 with `kernarg` as the argument buffer at `launch.kernarg_address`.
    pub(crate) fn new(
        kernel: &LoweredKernel,
        launch: &WorkgroupLaunch,
        kernarg: &'a [u8],
    ) -> Result<Self, EvalError> {
        let mut arena = ExprArena::new();
        let waves = initialize_waves(kernel, launch, &mut arena)?;
        Ok(Self {
            arena,
            kernarg: KernargBuffer {
                address: launch.kernarg_address,
                bytes: kernarg,
            },
            waves,
        })
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
            _ => Err(EvalError::UnsupportedInstruction),
        }
    }
}
