//! An if/else on a symbolic comparison: EXEC becomes a predicate per lane, and a vector
//! instruction writes each guarded lane as `select(p, new, old)`. EXEC's bit is set wherever a
//! predicate may hold, so `s_cbranch_execz` runs the code it would skip, every write guarded.

use volta_expr::symbolic_full::ExprId;

use crate::ir::LoweredInstr;

use super::wave::WaveId;
use super::{EvalError, Interpreter};

impl Interpreter<'_> {
    /// Each lane's predicate of being active.
    pub(super) fn exec_predicates(&mut self, wave: WaveId) -> Vec<ExprId> {
        let state = &self.waves[wave];
        let (exec, conditions) = (state.exec, state.conditions.clone());

        (0..64)
            .map(|lane| match (exec >> lane & 1 == 1, &conditions) {
                (false, _) => self.arena.bool_val(false),
                (true, None) => self.arena.bool_val(true),
                (true, Some(conditions)) => conditions[lane],
            })
            .collect()
    }

    /// Make `predicates` the wave's active lanes: EXEC holds the lanes whose predicate is not
    /// false, and the predicates stay only while one of them is symbolic.
    pub(super) fn set_exec_predicates(
        &mut self,
        wave: WaveId,
        predicates: Vec<ExprId>,
    ) -> Result<(), EvalError> {
        let mut exec = 0u64;
        let mut symbolic = false;

        for (lane, &predicate) in predicates.iter().enumerate() {
            match self.arena.as_bool(predicate) {
                Some(false) => {}
                Some(true) => exec |= 1 << lane,
                None => {
                    exec |= 1 << lane;
                    symbolic = true;
                }
            }
        }

        if symbolic && self.waves[wave].registers.has_varying() {
            return Err(EvalError::SymbolicExec);
        }

        let state = &mut self.waves[wave];
        state.exec = exec;
        state.conditions = symbolic.then(|| predicates.into());

        Ok(())
    }

    /// Run a value instruction, guarding a vector instruction's writes by each lane's symbolic
    /// predicate; scalar instructions run whatever EXEC holds.
    pub(super) fn execute_guarded(
        &mut self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        let Some(conditions) = self.waves[wave].conditions.clone() else {
            return self.execute_for_workgroups(wave, instruction);
        };

        match guard_kind(instruction) {
            GuardKind::Scalar => return self.execute_for_workgroups(wave, instruction),
            GuardKind::Unguardable => {
                return Err(EvalError::UnderLanePredicate {
                    instruction: instruction.name(),
                });
            }
            GuardKind::Vector => {}
        }

        let lanes: Vec<usize> = (0..64)
            .filter(|&lane| self.arena.as_bool(conditions[lane]).is_none())
            .collect();
        let before = self.waves[wave]
            .registers
            .guard(&self.arena, &lanes, &conditions);

        self.execute_for_workgroups(wave, instruction)?;

        let registers = &mut self.waves[wave].registers;
        registers.apply_guard(&mut self.arena, before, &conditions)
    }

    /// Reject an instruction no lane predicate can guard while one is symbolic.
    pub(super) fn reject_under_predicate(
        &self,
        wave: WaveId,
        instruction: &LoweredInstr,
    ) -> Result<(), EvalError> {
        match self.waves[wave].conditions {
            Some(_) => Err(EvalError::UnderLanePredicate {
                instruction: instruction.name(),
            }),
            None => Ok(()),
        }
    }
}

/// How an instruction runs while a lane's activity is symbolic.
enum GuardKind {
    /// It ignores EXEC.
    Scalar,
    /// It writes registers lane by lane.
    Vector,
    /// Its effect depends on which lanes run in a way no register select can express.
    Unguardable,
}

fn guard_kind(instruction: &LoweredInstr) -> GuardKind {
    match instruction {
        LoweredInstr::ScalarLoad { .. }
        | LoweredInstr::MovScalar32 { .. }
        | LoweredInstr::MovScalar64 { .. }
        | LoweredInstr::ScalarUnary32 { .. }
        | LoweredInstr::ScalarBitCount64 { .. }
        | LoweredInstr::ScalarBitSet32 { .. }
        | LoweredInstr::ScalarOp32 { .. }
        | LoweredInstr::ScalarOp64 { .. }
        | LoweredInstr::ExecOp64 { .. }
        | LoweredInstr::ShiftScalar64 { .. }
        | LoweredInstr::BfeI64Scalar { .. }
        | LoweredInstr::ScalarCmp { .. }
        | LoweredInstr::ScalarCmp64 { .. }
        | LoweredInstr::BitCmpScalar64 { .. }
        | LoweredInstr::ReadLane { .. }
        | LoweredInstr::WriteLane { .. } => GuardKind::Scalar,

        LoweredInstr::ReadFirstLane { .. }
        | LoweredInstr::GlobalLoad { .. }
        | LoweredInstr::GlobalStore { .. }
        | LoweredInstr::ScratchLoad { .. }
        | LoweredInstr::ScratchStore { .. }
        | LoweredInstr::GlobalStoreHigh16 { .. }
        | LoweredInstr::GlobalLoadUshort { .. }
        | LoweredInstr::GlobalStoreShort { .. }
        | LoweredInstr::BufferLoad { .. }
        | LoweredInstr::BufferStore { .. }
        | LoweredInstr::Dpp { .. }
        | LoweredInstr::Permlane32Swap { .. }
        | LoweredInstr::Permlane16Swap { .. }
        | LoweredInstr::Mfma16x16x4F32 { .. }
        | LoweredInstr::Mfma32x32x16Bf16 { .. }
        | LoweredInstr::Mfma16x16x32Bf16 { .. } => GuardKind::Unguardable,

        _ => GuardKind::Vector,
    }
}
