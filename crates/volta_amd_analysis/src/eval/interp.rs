//! The interpreter of workgroup 0: its run over every wave, and its execution of vector
//! instructions in one lane of a wave.

use id_collections::IdVec;
use volta_expr::{ExprArena, SymbolicOutputs};

use crate::ir::{
    BranchCondition, CmpOp, InstrId, LoweredInstr, LoweredKernel, Sgpr, Vgpr, Vop3Src,
};

use super::EvalError;
use super::arithm::{
    evaluate_bin_op, evaluate_cmp, evaluate_cmp_e64, evaluate_cndmask, evaluate_cndmask_e64,
    evaluate_ternary_op, evaluate_unary_op,
};
use super::global::{ArrayDef, GlobalMemory};
use super::launch::{WorkgroupLaunch, initialize_waves};
use super::mfma::execute_mfma_16x16x4_f32;
use super::scalar::KernargBuffer;
use super::wave::{Status, WaveId, WaveState, concrete_word};

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

    /// Run each ready wave until it exits or reaches a barrier, releasing the barrier once
    /// every wave that has not exited waits there; stop at the first instruction a wave cannot
    /// execute. `kernel` must be the kernel `new` launched.
    pub(crate) fn run(&mut self, kernel: &LoweredKernel) -> Terminal {
        loop {
            if let Some(wave) = self.next_ready() {
                let pc = self.waves[wave].pc;
                if let Err(error) = self.step(wave, kernel) {
                    return Terminal::Aborted { wave, pc, error };
                }
            } else if !self.release_barrier() {
                return Terminal::Completed;
            }
        }
    }

    /// Once every wave that has not exited waits at the barrier, make them ready; whether any
    /// wave was released.
    fn release_barrier(&mut self) -> bool {
        let at_barrier = |state: &WaveState| state.status == Status::AtBarrier;
        let exited = |state: &WaveState| state.status == Status::Exited;
        let arrived = |state: &WaveState| at_barrier(state) || exited(state);

        let all_arrived = self.waves.values().all(arrived);
        let any_waiting = self.waves.values().any(at_barrier);
        if !all_arrived || !any_waiting {
            return false;
        }

        for state in self.waves.values_mut() {
            if at_barrier(state) {
                state.status = Status::Ready;
            }
        }
        true
    }

    fn next_ready(&self) -> Option<WaveId> {
        self.waves
            .iter()
            .find(|(_, state)| state.status == Status::Ready)
            .map(|(wave, _)| wave)
    }

    /// Execute the instruction at `wave`'s pc and move past it, or to a taken branch's target.
    pub(super) fn step(&mut self, wave: WaveId, kernel: &LoweredKernel) -> Result<(), EvalError> {
        let pc = self.waves[wave].pc;
        let instruction = kernel
            .instructions
            .get(pc)
            .ok_or(EvalError::MissingEndPgm)?;
        let mut next = InstrId(pc.0 + 1);
        match instruction {
            LoweredInstr::EndPgm => {
                self.waves[wave].status = Status::Exited;
                return Ok(());
            }
            LoweredInstr::Barrier => self.waves[wave].status = Status::AtBarrier,
            LoweredInstr::Branch { target } => next = *target,
            LoweredInstr::CondBranch { condition, target } => {
                if self.branch_taken(wave, *condition)? {
                    next = *target;
                }
            }
            LoweredInstr::ScalarLoad { .. }
            | LoweredInstr::MovScalar32 { .. }
            | LoweredInstr::MovScalar64 { .. }
            | LoweredInstr::AbsScalar32 { .. }
            | LoweredInstr::ScalarOp32 { .. }
            | LoweredInstr::ScalarOp64 { .. }
            | LoweredInstr::LShlScalar64 { .. }
            | LoweredInstr::ScalarCmp { .. }
            | LoweredInstr::ReadFirstLane { .. }
            | LoweredInstr::WaitCnt { .. }
            | LoweredInstr::Nop => {
                self.execute_scalar(wave, instruction)?;
            }
            LoweredInstr::CmpE64 {
                op,
                dst,
                src0,
                src1,
            } => self.execute_cmp_e64(wave, *op, *dst, *src0, *src1)?,
            LoweredInstr::MadU64U32 {
                dst,
                carry,
                src0,
                src1,
                src2,
            } => self.execute_mad_u64_u32(wave, *dst, *carry, *src0, *src1, *src2)?,
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
            LoweredInstr::BinOp { .. }
            | LoweredInstr::TernaryOp { .. }
            | LoweredInstr::UnaryOp { .. }
            | LoweredInstr::Cmp { .. }
            | LoweredInstr::CndMask32 { .. }
            | LoweredInstr::CndMask32E64 { .. }
            | LoweredInstr::AccvgprWrite32 { .. }
            | LoweredInstr::AccvgprRead32 { .. }
            | LoweredInstr::FmaF32 { .. }
            | LoweredInstr::FmacF32 { .. }
            | LoweredInstr::GlobalLoad { .. }
            | LoweredInstr::GlobalStore { .. }
            | LoweredInstr::BufferLoad { .. }
            | LoweredInstr::BufferStore { .. } => {
                for lane in 0..64 {
                    self.execute_lane(wave, lane, instruction)?;
                }
            }
        }
        self.waves[wave].pc = next;
        Ok(())
    }

    /// Every lane is active, so EXEC is never zero.
    fn branch_taken(&self, wave: WaveId, condition: BranchCondition) -> Result<bool, EvalError> {
        let registers = &self.waves[wave].registers;
        match condition {
            BranchCondition::Scc1 => registers.read_scc(),
            BranchCondition::VccNz => Ok(registers.read_vcc_mask(&self.arena)? != 0),
            BranchCondition::ExecZ => Ok(false),
        }
    }

    /// Every lane's comparison is evaluated before `dst` is written, as a source may be `dst`.
    fn execute_cmp_e64(
        &mut self,
        wave: WaveId,
        op: CmpOp,
        dst: [Sgpr; 2],
        src0: Vop3Src,
        src1: Vop3Src,
    ) -> Result<(), EvalError> {
        let registers = &mut self.waves[wave].registers;
        let mut mask = 0u64;
        for lane in 0..64 {
            let condition = evaluate_cmp_e64(&mut self.arena, registers, lane, op, src0, src1)?;
            match self.arena.as_bool(condition) {
                Some(true) => mask |= 1 << lane,
                Some(false) => {}
                None => return Err(EvalError::SymbolicWord { lane }),
            }
        }
        registers.write_sgpr_pair(&mut self.arena, dst, mask)
    }

    /// Every lane's result is computed before `dst` and `carry` are written, as either may
    /// overlap a source.
    fn execute_mad_u64_u32(
        &mut self,
        wave: WaveId,
        dst: [Vgpr; 2],
        carry: [Sgpr; 2],
        src0: Vop3Src,
        src1: Vop3Src,
        src2: [Vgpr; 2],
    ) -> Result<(), EvalError> {
        let registers = &mut self.waves[wave].registers;

        let mut results = Vec::with_capacity(64);
        let mut carries = 0u64;
        for lane in 0..64 {
            let a = registers.read_src(&mut self.arena, lane, src0)?;
            let b = registers.read_src(&mut self.arena, lane, src1)?;
            let addend_low = registers.read_vgpr(lane, src2[0])?;
            let addend_high = registers.read_vgpr(lane, src2[1])?;

            let non_symbolic_word =
                |value| concrete_word(&self.arena, value).ok_or(EvalError::SymbolicWord { lane });
            let a = u128::from(non_symbolic_word(a)?);
            let b = u128::from(non_symbolic_word(b)?);
            let addend = u128::from(non_symbolic_word(addend_low)?)
                | (u128::from(non_symbolic_word(addend_high)?) << 32);

            let result = a * b + addend;
            if result >> 64 != 0 {
                carries |= 1 << lane;
            }
            results.push(result as u64);
        }

        for (lane, result) in results.into_iter().enumerate() {
            let low = self.arena.int(i64::from(result as u32));
            let high = self.arena.int(i64::from((result >> 32) as u32));
            registers.write_vgpr(lane, dst[0], low)?;
            registers.write_vgpr(lane, dst[1], high)?;
        }
        registers.write_sgpr_pair(&mut self.arena, carry, carries)
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
            LoweredInstr::BinOp {
                op,
                dst,
                src0,
                src1,
            } => {
                let result = evaluate_bin_op(&mut self.arena, registers, lane, *op, *src0, *src1)?;
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::TernaryOp { op, dst, srcs } => {
                let result = evaluate_ternary_op(&mut self.arena, registers, lane, *op, *srcs)?;
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
            LoweredInstr::CndMask32E64 {
                dst,
                src0,
                src1,
                mask,
            } => {
                let result =
                    evaluate_cndmask_e64(&mut self.arena, registers, lane, *src0, *src1, *mask)?;
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
            LoweredInstr::GlobalLoad { dst, address } => {
                registers.global_load(&mut self.arena, &self.global, lane, dst.regs(), *address)
            }
            LoweredInstr::GlobalStore { src, address } => {
                registers.global_store(&self.arena, &mut self.global, lane, &src.regs(), *address)
            }
            LoweredInstr::BufferLoad { dst, address } => {
                self.buffer_load(wave, lane, *address, dst.regs())
            }
            LoweredInstr::BufferStore { src, address } => {
                self.buffer_store(wave, lane, *address, &src.regs())
            }
            _ => Err(EvalError::UnsupportedInstruction),
        }
    }

    /// The written output elements, together with the arena that holds their expressions.
    pub(crate) fn into_outputs(self) -> SymbolicOutputs {
        self.global.into_outputs(self.arena)
    }
}
