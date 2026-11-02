//! The interpreter of workgroup 0: its run over every wave, and its execution of vector
//! instructions in one lane of a wave.

use id_collections::IdVec;
use volta_expr::{ExprArena, SymbolicOutputs};

use crate::ir::{InstrId, LoweredInstr, LoweredKernel};

use super::EvalError;
use super::arithm::{evaluate_bin_op, evaluate_cmp, evaluate_cndmask, evaluate_unary_op, shl32};
use super::global::{ArrayDef, GlobalMemory};
use super::launch::{WorkgroupLaunch, initialize_waves};
use super::mfma::execute_mfma_16x16x4_f32;
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
    /// and `arrays` in global memory.
    pub(crate) fn new(
        kernel: &LoweredKernel,
        launch: &WorkgroupLaunch,
        kernarg: &'a [u8],
        arrays: &[ArrayDef],
    ) -> Result<Self, EvalError> {
        let mut arena = ExprArena::new();
        let waves = initialize_waves(kernel, launch, &mut arena)?;
        let kernarg = KernargBuffer {
            address: launch.kernarg_address,
            bytes: kernarg,
        };
        let global = GlobalMemory::new(arrays, &kernarg, &mut arena)?;
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
            LoweredInstr::ScalarLoadDwordx2 { .. }
            | LoweredInstr::ScalarLoadDwordx4 { .. }
            | LoweredInstr::MovScalar32 { .. }
            | LoweredInstr::WaitCnt { .. }
            | LoweredInstr::Nop => {
                self.execute_scalar(wave, instruction)?;
            }
            LoweredInstr::Mfma16x16x4F32 {
                dst,
                src_a,
                src_b,
                src_c,
            } => execute_mfma_16x16x4_f32(
                &mut self.arena,
                &mut self.waves[wave].registers,
                *dst,
                *src_a,
                *src_b,
                *src_c,
            )?,
            // EXEC holds every lane: launches are full waves and no supported instruction writes it.
            LoweredInstr::Shl32 { .. }
            | LoweredInstr::LShr32 { .. }
            | LoweredInstr::AddShl32 { .. }
            | LoweredInstr::Bfe32 { .. }
            | LoweredInstr::ShlOr32 { .. }
            | LoweredInstr::Or3_32 { .. }
            | LoweredInstr::BinOp { .. }
            | LoweredInstr::UnaryOp { .. }
            | LoweredInstr::Cmp { .. }
            | LoweredInstr::CndMask32 { .. }
            | LoweredInstr::AccvgprWrite32 { .. }
            | LoweredInstr::AccvgprRead32 { .. }
            | LoweredInstr::FmaF32 { .. }
            | LoweredInstr::FmacF32 { .. }
            | LoweredInstr::GlobalLoadDword { .. }
            | LoweredInstr::GlobalLoadDwordx3 { .. }
            | LoweredInstr::GlobalLoadDwordx4 { .. }
            | LoweredInstr::GlobalStoreDword { .. }
            | LoweredInstr::GlobalStoreDwordx2 { .. }
            | LoweredInstr::GlobalStoreDwordx3 { .. }
            | LoweredInstr::GlobalStoreDwordx4 { .. } => {
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
                let result = shl32(&mut self.arena, value, *shift);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::LShr32 { dst, src, shift } => {
                let value = registers.read_vgpr(lane, *src)?;
                let amount = self.arena.int(i64::from(shift & 31));
                let result = self.arena.lshr(value, amount);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::AddShl32 {
                dst,
                src0,
                src1,
                shift,
            } => {
                let a = registers.read_vgpr(lane, *src0)?;
                let b = registers.read_vgpr(lane, *src1)?;
                let sum = self.arena.add(a, b);
                let result = shl32(&mut self.arena, sum, *shift);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::Bfe32 {
                dst,
                src,
                offset,
                width,
            } => {
                let value = registers.read_vgpr(lane, *src)?;
                let amount = self.arena.int(i64::from(offset & 31));
                let shifted = self.arena.lshr(value, amount);
                let mask = self.arena.int((1i64 << (width & 31)) - 1);
                let result = self.arena.bit_and(shifted, mask);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::ShlOr32 {
                dst,
                src0,
                shift,
                src2,
            } => {
                let value = registers.read_vgpr(lane, *src0)?;
                let other = registers.read_vgpr(lane, *src2)?;
                let shifted = shl32(&mut self.arena, value, *shift);
                let result = self.arena.bit_or(shifted, other);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::Or3_32 { dst, srcs } => {
                let [a, b, c] = srcs.map(|src| registers.read_vgpr(lane, src));
                let ab = self.arena.bit_or(a?, b?);
                let result = self.arena.bit_or(ab, c?);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::BinOp {
                op,
                dst,
                src0,
                src1,
            } => {
                let result = evaluate_bin_op(&mut self.arena, registers, lane, *op, *src0, *src1)?;
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::UnaryOp { op, dst, src } => {
                let result = evaluate_unary_op(&mut self.arena, registers, lane, *op, *src)?;
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::Cmp { op, src0, src1 } => {
                let condition = evaluate_cmp(&mut self.arena, registers, lane, *op, *src0, *src1)?;
                registers.write_vcc(lane, condition)
            }
            LoweredInstr::CndMask32 { dst, src0, src1 } => {
                let result = evaluate_cndmask(&mut self.arena, registers, lane, *src0, *src1)?;
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::AccvgprWrite32 { dst, src } => {
                let value = registers.read_vgpr(lane, *src)?;
                registers.write_agpr(lane, *dst, value)
            }
            LoweredInstr::AccvgprRead32 { dst, src } => {
                let value = registers.read_agpr(lane, *src)?;
                registers.write_vgpr(lane, *dst, value)
            }
            LoweredInstr::FmaF32 {
                dst,
                src0,
                src1,
                src2,
            } => {
                let a = registers.read_f32_src(&mut self.arena, lane, *src0)?;
                let b = registers.read_f32_src(&mut self.arena, lane, *src1)?;
                let c = registers.read_f32_src(&mut self.arena, lane, *src2)?;
                let result = self.arena.fma(a, b, c);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::FmacF32 { dst, src0, src1 } => {
                let a = registers.read_f32(&mut self.arena, lane, *src0)?;
                let b = registers.read_f32(&mut self.arena, lane, *src1)?;
                let c = registers.read_f32(&mut self.arena, lane, *dst)?;
                let result = self.arena.fma(a, b, c);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::GlobalLoadDword { dst, address } => {
                registers.global_load(&mut self.arena, &self.global, lane, &[*dst], *address)
            }
            LoweredInstr::GlobalLoadDwordx3 { dst, address } => {
                registers.global_load(&mut self.arena, &self.global, lane, dst, *address)
            }
            LoweredInstr::GlobalLoadDwordx4 { dst, address } => {
                registers.global_load(&mut self.arena, &self.global, lane, dst, *address)
            }
            LoweredInstr::GlobalStoreDword { src, address } => {
                registers.global_store(&self.arena, &mut self.global, lane, &[*src], *address)
            }
            LoweredInstr::GlobalStoreDwordx2 { src, address } => {
                registers.global_store(&self.arena, &mut self.global, lane, &src.regs(), *address)
            }
            LoweredInstr::GlobalStoreDwordx3 { src, address } => {
                registers.global_store(&self.arena, &mut self.global, lane, &src.regs(), *address)
            }
            LoweredInstr::GlobalStoreDwordx4 { src, address } => {
                registers.global_store(&self.arena, &mut self.global, lane, &src.regs(), *address)
            }
            _ => Err(EvalError::UnsupportedInstruction),
        }
    }

    /// The written output elements, together with the arena that holds their expressions.
    pub(crate) fn into_outputs(self) -> SymbolicOutputs {
        self.global.into_outputs(self.arena)
    }
}
