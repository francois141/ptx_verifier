//! Register storage for one CDNA4 wave.

use volta_expr::ExprId;

use crate::ir::{Sgpr, Vgpr};

use super::EvalError;

#[derive(Debug, Clone, Copy)]
enum ScalarValue {
    Uninitialized,
    Ready(ExprId),
    Pending(ExprId),
}

#[derive(Debug)]
pub(crate) struct WaveRegisters {
    scalar: [ScalarValue; 102], // Scalar registers are shared by the wave.
    vector: Vec<[Option<ExprId>; 256]>, // Vector registers have a value per lane.
}

// Initialize the wave with all registers unwritten.
impl Default for WaveRegisters {
    fn default() -> Self {
        Self {
            scalar: [ScalarValue::Uninitialized; 102],
            vector: vec![[None; 256]; 64],
        }
    }
}

impl WaveRegisters {
    /// Read a scalar register, rejecting reads before it is initialized or its pending load finishes.
    pub fn read_sgpr(&self, reg: Sgpr) -> Result<ExprId, EvalError> {
        match self.scalar.get(usize::from(reg.0)) {
            Some(ScalarValue::Ready(value)) => Ok(*value),
            Some(ScalarValue::Pending(_)) => Err(EvalError::PendingSgpr(reg)),
            Some(ScalarValue::Uninitialized) => Err(EvalError::UninitializedSgpr(reg)),
            None => Err(EvalError::InvalidSgpr(reg)),
        }
    }

    /// Write a scalar register unless a load is still writing to it.
    pub fn write_sgpr(&mut self, reg: Sgpr, value: ExprId) -> Result<(), EvalError> {
        self.check_scalar_destination(reg)?;
        self.scalar[usize::from(reg.0)] = ScalarValue::Ready(value);
        Ok(())
    }

    fn check_scalar_destination(&self, reg: Sgpr) -> Result<(), EvalError> {
        match self.scalar.get(usize::from(reg.0)) {
            Some(ScalarValue::Pending(_)) => Err(EvalError::PendingSgpr(reg)),
            Some(_) => Ok(()),
            None => Err(EvalError::InvalidSgpr(reg)),
        }
    }

    /// Keep loaded values unreadable until a wait establishes their completion.
    pub(super) fn start_scalar_load(
        &mut self,
        dst: [Sgpr; 4],
        values: [ExprId; 4],
    ) -> Result<(), EvalError> {
        // Check every destination before changing any register.
        for reg in dst {
            self.check_scalar_destination(reg)?;
        }
        for (reg, value) in dst.into_iter().zip(values) {
            self.scalar[usize::from(reg.0)] = ScalarValue::Pending(value);
        }
        Ok(())
    }

    /// Make all pending scalar loads readable after lgkmcnt(0).
    pub(super) fn finish_scalar_loads(&mut self) {
        for slot in &mut self.scalar {
            if let ScalarValue::Pending(value) = *slot {
                *slot = ScalarValue::Ready(value);
            }
        }
    }

    /// Read a lane's vector register; report an invalid lane or a valid but unwritten register.
    pub fn read_vgpr(&self, lane: usize, reg: Vgpr) -> Result<ExprId, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        registers[usize::from(reg.0)].ok_or(EvalError::UninitializedVgpr { lane, reg })
    }

    /// Write a vector register in one lane, rejecting invalid lane indices.
    pub fn write_vgpr(&mut self, lane: usize, reg: Vgpr, value: ExprId) -> Result<(), EvalError> {
        let registers = self
            .vector
            .get_mut(lane)
            .ok_or(EvalError::InvalidLane(lane))?;
        registers[usize::from(reg.0)] = Some(value);
        Ok(())
    }
}
