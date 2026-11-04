//! The interpreter of workgroup 0: its run over every wave, and its execution of vector
//! instructions in one lane of a wave.

use id_collections::IdVec;
use volta_expr::{ExprArena, SymbolicOutputs};

use crate::ir::{
    BranchCondition, CmpOp, DsReadDst, DsWriteData, InstrId, LdsAccesses, LoweredInstr,
    LoweredKernel, Sgpr, Vgpr, Vop3Src,
};

use super::EvalError;
use super::arithm::{
    evaluate_bin_op, evaluate_cmp, evaluate_cmp_e64, evaluate_cndmask, evaluate_cndmask_e64,
    evaluate_ternary_op, evaluate_unary_op,
};
use super::global::{ArrayDef, GlobalMemory};
use super::launch::{WorkgroupLaunch, initialize_waves};
use super::lds::Lds;
use super::mfma::execute_mfma_16x16x4_f32;
use super::scalar::KernargBuffer;
use super::wave::{LoadCounter, Status, WaveId, WaveState, concrete_word};

/// The symbolic execution state of workgroup 0: one `WaveState` per wave, each holding that
/// wave's scalar and vector registers, whose values are expressions of `arena`, and the
/// workgroup's LDS.
pub(crate) struct Interpreter<'a> {
    pub(super) arena: ExprArena,
    pub(super) kernarg: KernargBuffer<'a>,
    pub(super) global: GlobalMemory,
    pub(super) lds: Lds,
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
        let lds_size = kernel
            .descriptor
            .get("group_segment_fixed_size")
            .and_then(|&size| u32::try_from(size).ok())
            .filter(|&size| size <= 65536)
            .ok_or_else(|| EvalError::Launch {
                message: "expected .amdhsa_group_segment_fixed_size of at most 64 KiB".into(),
            })?;
        Ok(Self {
            arena,
            kernarg,
            global,
            lds: Lds::new(lds_size),
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
            | LoweredInstr::CmpEqScalar64 { .. }
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
            LoweredInstr::DsBPermute {
                dst,
                addr,
                src,
                offset,
            } => self.execute_ds_bpermute(wave, *dst, *addr, *src, *offset)?,
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
            | LoweredInstr::BufferStore { .. }
            | LoweredInstr::DsWrite { .. }
            | LoweredInstr::DsRead { .. } => {
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
            BranchCondition::Scc0 => Ok(!registers.read_scc()?),
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
                let a = registers.read_f32_src0(&mut self.arena, lane, *src0)?;
                let b = registers.read_f32(&mut self.arena, lane, *src1)?;
                let c = registers.read_f32(&mut self.arena, lane, *dst)?;
                let result = self.arena.fma(a, b, c);
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::GlobalLoad { dst, address } => {
                registers.global_load(&mut self.arena, &self.global, lane, dst.regs(), *address)
            }
            LoweredInstr::GlobalStore { src, address } => registers.global_store(
                &mut self.arena,
                &mut self.global,
                lane,
                &src.regs(),
                *address,
            ),
            LoweredInstr::BufferLoad { dst, address } => {
                self.buffer_load(wave, lane, *address, dst.regs())
            }
            LoweredInstr::BufferStore { src, address } => {
                self.buffer_store(wave, lane, *address, &src.regs())
            }
            LoweredInstr::DsWrite { addr, accesses } => self.ds_write(wave, lane, *addr, *accesses),
            LoweredInstr::DsRead { addr, accesses } => self.ds_read(wave, lane, *addr, *accesses),
            _ => Err(EvalError::UnsupportedInstruction),
        }
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

    /// `lane`'s byte address: its address VGPR plus `offset`.
    fn lds_address(
        &self,
        wave: WaveId,
        lane: usize,
        address_reg: Vgpr,
        offset: u32,
    ) -> Result<u64, EvalError> {
        let registers = &self.waves[wave].registers;
        let base = registers.read_concrete_address_vgpr(&self.arena, lane, address_reg)?;
        Ok(u64::from(base) + u64::from(offset))
    }

    /// Store each access's registers, one access after the other.
    pub(super) fn ds_write(
        &mut self,
        wave: WaveId,
        lane: usize,
        address_reg: Vgpr,
        accesses: LdsAccesses<DsWriteData>,
    ) -> Result<(), EvalError> {
        for (offset, data) in accesses.accesses() {
            let start_address = self.lds_address(wave, lane, address_reg, offset)?;
            let registers = &self.waves[wave].registers;
            let mut values = Vec::new();
            for source_reg in data.regs() {
                let value = registers.read_lane_reg(lane, source_reg)?;
                values.push(value);
            }
            self.lds.write(start_address, &values)?;
        }
        Ok(())
    }

    /// Load every access's words, pending until `lgkmcnt` establishes the read's completion.
    pub(super) fn ds_read(
        &mut self,
        wave: WaveId,
        lane: usize,
        address_reg: Vgpr,
        accesses: LdsAccesses<DsReadDst>,
    ) -> Result<(), EvalError> {
        let mut destinations = Vec::new();
        let mut values = Vec::new();

        for (offset, destination) in accesses.accesses() {
            let start_address = self.lds_address(wave, lane, address_reg, offset)?;
            let destination_regs = destination.regs();
            let word_count = destination_regs.len() as u32;
            let loaded_values = self.lds.read(start_address, word_count)?;

            destinations.extend_from_slice(destination_regs);
            values.extend(loaded_values);
        }

        self.waves[wave].registers.start_vector_load(
            lane,
            &destinations,
            &values,
            LoadCounter::Lgkm,
        )
    }

    /// The written output elements, together with the arena that holds their expressions.
    pub(crate) fn into_outputs(self) -> SymbolicOutputs {
        self.global.into_outputs(self.arena)
    }
}
