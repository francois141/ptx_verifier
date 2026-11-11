//! The interpreter of one selected workgroup: its run over every wave, and its execution of
//! vector instructions in one lane of a wave.

use std::collections::BTreeMap;

use id_collections::IdVec;
use volta_expr::{ExprArena, ExprId, SymbolicOutputs};
use volta_graph::{EventGraph, GraphBuilder, Provenance};

use crate::ir::{
    BranchCondition, DsReadDst, DsWriteData, InstrId, LaneMask, LdsAccesses, LoweredInstr,
    LoweredKernel, Sgpr, Vgpr, Vop3Src,
};

use super::EvalError;
use super::arithm::{
    evaluate_bin_op, evaluate_cmp, evaluate_cmp_e64, evaluate_cmp_f64, evaluate_cmp64,
    evaluate_cndmask, evaluate_cndmask_e64, evaluate_cvt_from_f64, evaluate_cvt_to_f64,
    evaluate_f64_op, evaluate_packed_f32, evaluate_ternary_op, evaluate_unary_op,
    evaluate_vop3_bin_op,
};
use super::global::{ArrayDef, GlobalMemory, OutputArrays, OutputConflict};
use super::launch::{WorkgroupLaunch, grid_workgroups, initialize_waves, vary_workgroup_ids};
use super::lds::{Lds, LdsLaneAccess, LdsRace};
use super::mfma::execute_mfma_16x16x4_f32;
use super::scalar::KernargBuffer;
use super::wave::{
    LgkmInFlight, LoadCounter, Status, WaveId, WaveRegisters, WaveState, active_lanes,
    concrete_word, lane_bit,
};

/// The selected workgroup's symbolic state: one `WaveState` per wave, holding registers whose
/// values are expressions of `arena`, plus the workgroup's LDS and the execution's event graph.
pub(crate) struct Interpreter<'a> {
    pub(super) arena: ExprArena,
    pub(super) kernarg: KernargBuffer<'a>,
    pub(super) global: GlobalMemory,
    pub(super) lds: Lds,
    pub(super) waves: IdVec<WaveId, WaveState>,
    pub(super) graph: GraphBuilder,
    /// How many workgroups the run covers: one for a selected workgroup, or every workgroup
    /// of the launch grid, X fastest.
    pub(super) workgroups: usize,
}

/// A run over every workgroup of a launch grid, as `Interpreter::finish_grid` returns it.
pub(crate) struct GridRun {
    pub graph: EventGraph,
    pub arena: ExprArena,
    /// Each workgroup's output arrays with their written elements.
    pub outputs: Vec<OutputArrays>,
    pub conflicts: Vec<OutputConflict>,
}

/// How the execution of the selected workgroup ended.
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
    /// Launch the selected workgroup with `kernarg` as the argument buffer at `launch.kernarg_address`
    /// and `arrays` in global memory, recording the execution's graph under `provenance`. With
    /// `whole_grid`, the run covers every workgroup of `launch.grid_size` instead: each
    /// workgroup-ID register holds every workgroup's coordinate.
    pub(crate) fn new(
        kernel: &LoweredKernel,
        launch: &WorkgroupLaunch,
        kernarg: &'a [u8],
        arrays: &[ArrayDef],
        provenance: Provenance,
        whole_grid: bool,
    ) -> Result<Self, EvalError> {
        let mut arena = ExprArena::new();
        let mut waves = initialize_waves(kernel, launch, &mut arena)?;
        let workgroups = if whole_grid {
            vary_workgroup_ids(kernel, launch.grid_size, &mut waves, &mut arena)?;
            grid_workgroups(launch.grid_size)?
        } else {
            1
        };
        let kernarg = KernargBuffer {
            address: launch.kernarg_address,
            bytes: kernarg,
        };
        let global = GlobalMemory::new(arrays, &kernarg, &mut arena, workgroups)?;
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
            lds: Lds::new(lds_size, workgroups),
            waves,
            graph: GraphBuilder::new(provenance),
            workgroups,
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

        self.record_barrier_release();
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
                // TODO: confirm in the CDNA4 ISA that `s_endpgm` implicitly performs `s_waitcnt 0`,
                // then also complete the wave's vmcnt and expcnt waits here, not only lgkmcnt.
                self.wait_lgkm(wave, pc, 0);
                self.record_exit(wave, pc);
                self.waves[wave].status = Status::Exited;
                return Ok(());
            }
            LoweredInstr::Barrier => {
                self.record_barrier_arrival(wave, pc);
                self.waves[wave].status = Status::AtBarrier;
            }
            LoweredInstr::Branch { target } => next = *target,
            LoweredInstr::CondBranch { condition, target } => {
                if self.branch_taken_in_every_workgroup(wave, *condition)? {
                    next = *target;
                }
            }
            LoweredInstr::WaitCnt { .. } | LoweredInstr::Nop => {
                self.execute_scalar(wave, instruction)?;
            }
            LoweredInstr::DsWrite { .. }
            | LoweredInstr::DsRead { .. }
            | LoweredInstr::DsBPermute { .. } => {
                self.execute_ds(wave, pc, instruction)?;
            }
            // Every other instruction computes register values or accesses global memory.
            LoweredInstr::ScalarLoad { .. }
            | LoweredInstr::MovScalar32 { .. }
            | LoweredInstr::MovScalar64 { .. }
            | LoweredInstr::AbsScalar32 { .. }
            | LoweredInstr::ScalarOp32 { .. }
            | LoweredInstr::ScalarOp64 { .. }
            | LoweredInstr::ExecOp64 { .. }
            | LoweredInstr::ShiftScalar64 { .. }
            | LoweredInstr::ScalarCmp { .. }
            | LoweredInstr::ScalarCmp64 { .. }
            | LoweredInstr::BitCmpScalar64 { .. }
            | LoweredInstr::ReadFirstLane { .. }
            | LoweredInstr::CmpE64 { .. }
            | LoweredInstr::Cmp64 { .. }
            | LoweredInstr::CmpF64 { .. }
            | LoweredInstr::MadU64U32 { .. }
            | LoweredInstr::Mfma16x16x4F32 { .. }
            | LoweredInstr::BinOp { .. }
            | LoweredInstr::TernaryOp { .. }
            | LoweredInstr::Vop3BinOp { .. }
            | LoweredInstr::UnaryOp { .. }
            | LoweredInstr::Mov64 { .. }
            | LoweredInstr::Cmp { .. }
            | LoweredInstr::CndMask32 { .. }
            | LoweredInstr::CndMask32E64 { .. }
            | LoweredInstr::AccvgprWrite32 { .. }
            | LoweredInstr::AccvgprRead32 { .. }
            | LoweredInstr::FmaF32 { .. }
            | LoweredInstr::FmacF32 { .. }
            | LoweredInstr::F64 { .. }
            | LoweredInstr::CvtToF64 { .. }
            | LoweredInstr::CvtFromF64 { .. }
            | LoweredInstr::PackedF32 { .. }
            | LoweredInstr::GlobalLoad { .. }
            | LoweredInstr::GlobalStore { .. }
            | LoweredInstr::BufferLoad { .. }
            | LoweredInstr::BufferStore { .. } => self.execute_for_workgroups(wave, instruction)?,
        }
        self.waves[wave].pc = next;
        Ok(())
    }

    /// Execute a value instruction. One that reads no workgroup-dependent location runs
    /// once; otherwise it runs once per workgroup from the same registers, and each location it
    /// writes keeps every workgroup's result.
    fn execute_for_workgroups(
        &mut self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        if !self.waves[wave].registers.has_varying() {
            return self.execute_value(wave, instruction);
        }

        // Execute once while rejecting workgroup-dependent reads; undo it if one occurs.
        let issued = self.waves[wave].lgkm_in_flight.len();
        let exec = self.waves[wave].exec;
        self.waves[wave].registers.begin_undoable();
        match self.execute_value(wave, instruction) {
            Err(EvalError::DependsOnWorkgroup) => {
                self.waves[wave].registers.undo_execution();
                self.waves[wave].lgkm_in_flight.truncate(issued);
                self.waves[wave].exec = exec;
            }
            result => {
                self.waves[wave].registers.commit();
                return result;
            }
        }

        self.execute_each_workgroup(wave, instruction)
    }

    /// Execute the data operation in each workgroup, retaining each result and counting a load
    /// only once. LDS instructions also use this path because their memory can differ even
    /// when the wave's registers agree.
    pub(super) fn execute_each_workgroup(
        &mut self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        if self.workgroups == 1 {
            return self.execute_value(wave, instruction);
        }
        let mut results = Vec::with_capacity(self.workgroups);
        let exec = self.waves[wave].exec;
        let mut exec_written = None;
        for workgroup in 0..self.workgroups {
            let issued = self.waves[wave].lgkm_in_flight.len();
            self.waves[wave].registers.begin_workgroup(workgroup);
            self.global.select(Some(workgroup));
            self.lds.select(workgroup);
            // Each workgroup starts from the same EXEC, as it does from the same registers.
            self.waves[wave].exec = exec;
            let outcome = self.execute_value(wave, instruction);
            self.global.select(None);
            self.lds.select(0);
            let writes = self.waves[wave].registers.end_workgroup();
            if workgroup > 0 {
                self.waves[wave].lgkm_in_flight.truncate(issued);
            }
            outcome?;
            // The run keeps one EXEC, so every workgroup must leave the same lanes active.
            let written = self.waves[wave].exec;
            if *exec_written.get_or_insert(written) != written {
                return Err(EvalError::DependsOnWorkgroup);
            }
            results.push(writes);
        }
        self.waves[wave].registers.combine(&self.arena, results);
        Ok(())
    }

    /// Execute the data effects of an instruction; graph recording and DS completion
    /// tracking happen once in `execute_ds`, outside per-workgroup execution.
    fn execute_value(&mut self, wave: WaveId, instruction: &LoweredInstr) -> Result<(), EvalError> {
        match instruction {
            LoweredInstr::ScalarLoad { .. }
            | LoweredInstr::MovScalar32 { .. }
            | LoweredInstr::MovScalar64 { .. }
            | LoweredInstr::AbsScalar32 { .. }
            | LoweredInstr::ScalarOp32 { .. }
            | LoweredInstr::ScalarOp64 { .. }
            | LoweredInstr::ExecOp64 { .. }
            | LoweredInstr::ShiftScalar64 { .. }
            | LoweredInstr::ScalarCmp { .. }
            | LoweredInstr::ScalarCmp64 { .. }
            | LoweredInstr::BitCmpScalar64 { .. }
            | LoweredInstr::ReadFirstLane { .. } => self.execute_scalar(wave, instruction),
            LoweredInstr::CmpE64 {
                op,
                dst,
                src0,
                src1,
            } => self.write_comparison(wave, *dst, |arena, registers, lane| {
                evaluate_cmp_e64(arena, registers, lane, *op, *src0, *src1)
            }),
            LoweredInstr::Cmp64 {
                op,
                signedness,
                dst,
                src0,
                src1,
            } => self.write_comparison(wave, *dst, |arena, registers, lane| {
                evaluate_cmp64(arena, registers, lane, *op, *signedness, *src0, *src1)
            }),
            LoweredInstr::CmpF64 {
                op,
                dst,
                src0,
                src1,
            } => self.write_comparison(wave, *dst, |arena, registers, lane| {
                evaluate_cmp_f64(arena, registers, lane, *op, *src0, *src1)
            }),
            LoweredInstr::Cmp { op, src0, src1 } => {
                self.write_comparison(wave, LaneMask::Vcc, |arena, registers, lane| {
                    evaluate_cmp(arena, registers, lane, *op, *src0, *src1)
                })
            }
            LoweredInstr::MadU64U32 {
                dst,
                carry,
                src0,
                src1,
                src2,
            } => self.execute_mad_u64_u32(wave, *dst, *carry, *src0, *src1, *src2),
            // A matrix multiply runs in every lane, whatever EXEC holds (CDNA4 §7.1).
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
            ),
            LoweredInstr::DsWrite { addr, accesses } => self.ds_write(wave, *addr, *accesses),
            LoweredInstr::DsBPermute {
                dst,
                addr,
                src,
                offset,
            } => self.execute_ds_bpermute(wave, *dst, *addr, *src, *offset),
            // Only the active lanes run these instructions. An inactive lane keeps its registers
            // and accesses no memory (CDNA4 §3.3).
            LoweredInstr::BinOp { .. }
            | LoweredInstr::TernaryOp { .. }
            | LoweredInstr::Vop3BinOp { .. }
            | LoweredInstr::UnaryOp { .. }
            | LoweredInstr::Mov64 { .. }
            | LoweredInstr::CndMask32 { .. }
            | LoweredInstr::CndMask32E64 { .. }
            | LoweredInstr::AccvgprWrite32 { .. }
            | LoweredInstr::AccvgprRead32 { .. }
            | LoweredInstr::FmaF32 { .. }
            | LoweredInstr::FmacF32 { .. }
            | LoweredInstr::F64 { .. }
            | LoweredInstr::CvtToF64 { .. }
            | LoweredInstr::CvtFromF64 { .. }
            | LoweredInstr::PackedF32 { .. }
            | LoweredInstr::GlobalLoad { .. }
            | LoweredInstr::GlobalStore { .. }
            | LoweredInstr::BufferLoad { .. }
            | LoweredInstr::BufferStore { .. }
            | LoweredInstr::DsRead { .. } => {
                for lane in active_lanes(self.waves[wave].exec) {
                    self.execute_lane(wave, lane, instruction)?;
                }
                Ok(())
            }
            // `step` executes control and wait instructions itself.
            LoweredInstr::EndPgm
            | LoweredInstr::Barrier
            | LoweredInstr::Branch { .. }
            | LoweredInstr::CondBranch { .. }
            | LoweredInstr::WaitCnt { .. }
            | LoweredInstr::Nop => Err(EvalError::UnsupportedInstruction),
        }
    }

    /// `s_waitcnt lgkmcnt(outstanding)` at `pc`: every DS instruction and scalar load but the
    /// last `outstanding` completes, in issue order.
    pub(super) fn wait_lgkm(&mut self, wave: WaveId, pc: InstrId, outstanding: usize) {
        let state = &mut self.waves[wave];
        let completed = state.lgkm_in_flight.len().saturating_sub(outstanding);
        let mut ds_ops = Vec::new();
        for instruction in state.lgkm_in_flight.drain(..completed) {
            match instruction {
                LgkmInFlight::Ds { op, dst, lanes } => {
                    state.registers.finish_ds_load(&dst, lanes);
                    ds_ops.push(op);
                }
                LgkmInFlight::Scalar { dst } => state.registers.finish_scalar_load(&dst),
            }
        }
        self.record_lgkm_wait(wave, pc, outstanding, &ds_ops);
    }

    /// Whether a branch is taken, which must be alike in every workgroup. A condition that
    /// differs between workgroups is evaluated in each; differing outcomes are rejected.
    fn branch_taken_in_every_workgroup(
        &mut self,
        wave: WaveId,
        condition: BranchCondition,
    ) -> Result<bool, EvalError> {
        match self.branch_taken(wave, condition) {
            Err(EvalError::DependsOnWorkgroup) => {}
            result => return result,
        }
        let mut taken = None;
        for workgroup in 0..self.workgroups {
            self.waves[wave].registers.set_view(Some(workgroup));
            let outcome = self.branch_taken(wave, condition);
            self.waves[wave].registers.set_view(None);
            let outcome = outcome?;
            if *taken.get_or_insert(outcome) != outcome {
                return Err(EvalError::DependsOnWorkgroup);
            }
        }
        taken.ok_or(EvalError::DependsOnWorkgroup)
    }

    /// Whether `condition` holds for `wave`, with SCC and VCC read in the viewed workgroup.
    fn branch_taken(&self, wave: WaveId, condition: BranchCondition) -> Result<bool, EvalError> {
        let registers = &self.waves[wave].registers;
        match condition {
            BranchCondition::Scc0 => Ok(!registers.read_scc()?),
            BranchCondition::Scc1 => registers.read_scc(),
            BranchCondition::VccNz => Ok(registers.read_vcc_mask(&self.arena)? != 0),
            BranchCondition::VccZ => Ok(registers.read_vcc_mask(&self.arena)? == 0),
            BranchCondition::ExecZ => Ok(self.waves[wave].exec == 0),
            BranchCondition::ExecNz => Ok(self.waves[wave].exec != 0),
        }
    }

    /// Every active lane's result is computed before `dst` and `carry` are written, as either
    /// may overlap a source.
    fn execute_mad_u64_u32(
        &mut self,
        wave: WaveId,
        dst: [Vgpr; 2],
        carry: [Sgpr; 2],
        src0: Vop3Src,
        src1: Vop3Src,
        src2: [Vgpr; 2],
    ) -> Result<(), EvalError> {
        let exec = self.waves[wave].exec;
        let registers = &mut self.waves[wave].registers;

        let mut results = Vec::with_capacity(64);
        // The carry mask is fully written, as VCC is: an inactive lane's bit stays clear
        // (CDNA4 §3.9).
        let mut carries = 0u64;
        for lane in active_lanes(exec) {
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
            results.push((lane, result as u64));
        }

        for (lane, result) in results {
            let low = self.arena.int(i64::from(result as u32));
            let high = self.arena.int(i64::from((result >> 32) as u32));
            registers.write_vgpr(lane, dst[0], low)?;
            registers.write_vgpr(lane, dst[1], high)?;
        }
        registers.write_sgpr_pair(&mut self.arena, carry, carries)
    }

    /// Evaluate a comparison in every active lane before writing `dst`, which may overlap a
    /// source.
    fn write_comparison(
        &mut self,
        wave: WaveId,
        dst: LaneMask,
        evaluate: impl Fn(&mut ExprArena, &WaveRegisters, usize) -> Result<ExprId, EvalError>,
    ) -> Result<(), EvalError> {
        let exec = self.waves[wave].exec;
        let registers = &mut self.waves[wave].registers;
        let conditions = (0..64)
            .map(|lane| {
                if lane_bit(exec, lane) {
                    evaluate(&mut self.arena, registers, lane)
                } else {
                    // The mask is fully written: an inactive lane's bit is clear (CDNA4 §3.9).
                    Ok(self.arena.bool_val(false))
                }
            })
            .collect::<Result<Vec<_>, _>>()?;
        registers.write_lane_mask(&mut self.arena, dst, &conditions)
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
            LoweredInstr::Vop3BinOp {
                op,
                dst,
                src0,
                src1,
            } => {
                let result =
                    evaluate_vop3_bin_op(&mut self.arena, registers, lane, *op, *src0, *src1)?;
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::UnaryOp { op, dst, src } => {
                let result = evaluate_unary_op(&mut self.arena, registers, lane, *op, *src)?;
                registers.write_vgpr(lane, *dst, result)
            }
            LoweredInstr::Mov64 { dst, src } => {
                registers.move_words(&mut self.arena, lane, *dst, *src)
            }
            LoweredInstr::F64 { dst, op } => {
                let result = evaluate_f64_op(&mut self.arena, registers, lane, *op)?;
                registers.write_f64(lane, *dst, result)
            }
            LoweredInstr::CvtToF64 { op, dst, src } => {
                let result = evaluate_cvt_to_f64(&mut self.arena, registers, lane, *op, *src)?;
                registers.write_f64(lane, *dst, result)
            }
            LoweredInstr::CvtFromF64 { op, dst, src } => {
                let result = evaluate_cvt_from_f64(&mut self.arena, registers, lane, *op, *src)?;
                registers.write_vgpr(lane, *dst, result)
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
                let value = registers.read_src(&mut self.arena, lane, *src)?;
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
                let a = registers.read_modified_src(&mut self.arena, lane, *src0)?;
                let b = registers.read_modified_src(&mut self.arena, lane, *src1)?;
                let c = registers.read_modified_src(&mut self.arena, lane, *src2)?;
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
            LoweredInstr::PackedF32 { dst, op } => {
                let [low, high] = evaluate_packed_f32(&mut self.arena, registers, lane, *op)?;
                registers.write_vgpr(lane, dst[0], low)?;
                registers.write_vgpr(lane, dst[1], high)
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
            LoweredInstr::DsRead { addr, accesses } => self.ds_read(wave, lane, *addr, *accesses),
            _ => Err(EvalError::UnsupportedInstruction),
        }
    }

    /// `lane`'s byte address: its address VGPR plus `offset`.
    pub(super) fn lds_address(
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

    /// Store every active lane's accesses, lane after lane and each lane's in order. Two lanes
    /// storing one word in one instruction land in no specified order, so that is a race.
    pub(super) fn ds_write(
        &mut self,
        wave: WaveId,
        address_reg: Vgpr,
        accesses: LdsAccesses<DsWriteData>,
    ) -> Result<(), EvalError> {
        let pc = self.waves[wave].pc;
        let mut writers: BTreeMap<u32, LdsLaneAccess> = BTreeMap::new();
        for lane in active_lanes(self.waves[wave].exec) {
            let access = LdsLaneAccess { wave, lane, pc };
            for (offset, data) in accesses.accesses() {
                let start_address = self.lds_address(wave, lane, address_reg, offset)?;
                let registers = &self.waves[wave].registers;
                let mut values = Vec::new();
                for source_reg in data.regs() {
                    let value = registers.read_lane_reg(lane, source_reg)?;
                    values.push(value);
                }
                for address in self
                    .lds
                    .word_addresses(start_address, values.len() as u32)?
                {
                    if let Some(earlier) = writers.insert(address, access)
                        && earlier.lane != lane
                    {
                        let race = LdsRace {
                            address,
                            earlier,
                            later: access,
                        };
                        return Err(EvalError::LdsRace(race));
                    }
                }
                self.lds.write(start_address, &values)?;
            }
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

    /// End a run over a whole grid, keeping each workgroup's outputs and their conflicts.
    pub(crate) fn finish_grid(self, terminal: volta_graph::Terminal) -> GridRun {
        let outputs = self.global.workgroup_outputs(&self.arena);
        let conflicts = self.global.conflicts(&self.arena);
        GridRun {
            graph: self.graph.finish(terminal),
            arena: self.arena,
            outputs,
            conflicts,
        }
    }

    /// The event graph and output elements, together with the arena holding their expressions.
    pub(crate) fn finish(self, terminal: volta_graph::Terminal) -> (EventGraph, SymbolicOutputs) {
        (
            self.graph.finish(terminal),
            self.global.into_outputs(self.arena),
        )
    }
}
