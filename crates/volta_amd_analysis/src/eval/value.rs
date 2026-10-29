//! Register storage for one CDNA4 wave.

use volta_expr::ExprId;

use crate::ir::{Sgpr, Vgpr};

use super::EvalError;

#[derive(Debug)]
pub(crate) struct WaveRegisters {
    scalar: [Option<ExprId>; 102], // Scalar registers are shared by the wave.
    vector: Vec<[Option<ExprId>; 256]>, // Vector registers have a value per lane.
}

// Initialize the wave with all registers unwritten.
impl Default for WaveRegisters {
    fn default() -> Self {
        Self {
            scalar: [None; 102],
            vector: vec![[None; 256]; 64],
        }
    }
}

impl WaveRegisters {
    /// Read a scalar register; distinguish invalid indices from valid but unwritten registers.
    pub fn read_sgpr(&self, reg: Sgpr) -> Result<ExprId, EvalError> {
        self.scalar
            .get(usize::from(reg.0))
            .ok_or(EvalError::InvalidSgpr(reg))?
            .ok_or(EvalError::UninitializedSgpr(reg))
    }

    /// Write a scalar register, rejecting indices outside the supported range.
    pub fn write_sgpr(&mut self, reg: Sgpr, value: ExprId) -> Result<(), EvalError> {
        let slot = self
            .scalar
            .get_mut(usize::from(reg.0))
            .ok_or(EvalError::InvalidSgpr(reg))?;
        *slot = Some(value);
        Ok(())
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
