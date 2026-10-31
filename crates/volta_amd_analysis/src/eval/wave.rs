//! The execution state of one wave of workgroup 0.

use id_collections::id_type;
use volta_expr::{ExprArena, ExprId};

use crate::ir::{InstrId, Sgpr, Vgpr};

use super::EvalError;

/// A wave of workgroup 0, identified by its index: wave `w` holds work-items `64w` to `64w + 63`.
#[id_type]
pub struct WaveId(pub u32);

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum Status {
    Ready,
    /// Executed `s_endpgm`.
    Exited,
}

/// A wave's state; its `WaveId` is its index in the wave table, so the state does not store it.
#[derive(Debug)]
pub(crate) struct WaveState {
    pub pc: InstrId,
    pub registers: WaveRegisters,
    pub status: Status,
}

impl WaveState {
    /// A ready wave at the kernel's first instruction.
    pub fn new(registers: WaveRegisters) -> Self {
        Self {
            pc: InstrId(0),
            registers,
            status: Status::Ready,
        }
    }
}

/// A register's value; a pending value is a load's result, which the wave may neither read nor
/// overwrite before a wait completes the load.
#[derive(Debug, Clone, Copy)]
enum RegValue {
    Uninitialized,
    Ready(ExprId),
    Pending(ExprId),
}

/// Register storage for one CDNA4 wave.
#[derive(Debug)]
pub(crate) struct WaveRegisters {
    scalar: [RegValue; 102],      // Scalar registers are shared by the wave.
    vector: Vec<[RegValue; 256]>, // Vector registers have a value per lane.
}

// Initialize the wave with all registers unwritten.
impl Default for WaveRegisters {
    fn default() -> Self {
        Self {
            scalar: [RegValue::Uninitialized; 102],
            vector: vec![[RegValue::Uninitialized; 256]; 64],
        }
    }
}

impl WaveRegisters {
    /// Read a scalar register, rejecting reads before it is initialized or its pending load finishes.
    pub fn read_sgpr(&self, reg: Sgpr) -> Result<ExprId, EvalError> {
        match self.scalar.get(usize::from(reg.0)) {
            Some(RegValue::Ready(value)) => Ok(*value),
            Some(RegValue::Pending(_)) => Err(EvalError::PendingSgpr(reg)),
            Some(RegValue::Uninitialized) => Err(EvalError::UninitializedSgpr(reg)),
            None => Err(EvalError::InvalidSgpr(reg)),
        }
    }

    /// Write a scalar register unless a load is still writing to it.
    pub fn write_sgpr(&mut self, reg: Sgpr, value: ExprId) -> Result<(), EvalError> {
        self.check_scalar_destination(reg)?;
        self.scalar[usize::from(reg.0)] = RegValue::Ready(value);
        Ok(())
    }

    fn check_scalar_destination(&self, reg: Sgpr) -> Result<(), EvalError> {
        match self.scalar.get(usize::from(reg.0)) {
            Some(RegValue::Pending(_)) => Err(EvalError::PendingSgpr(reg)),
            Some(_) => Ok(()),
            None => Err(EvalError::InvalidSgpr(reg)),
        }
    }

    /// Keep loaded values unreadable until a wait establishes their completion.
    pub(super) fn start_scalar_load<const N: usize>(
        &mut self,
        dst: [Sgpr; N],
        values: [ExprId; N],
    ) -> Result<(), EvalError> {
        // Check every destination before changing any register.
        for reg in dst {
            self.check_scalar_destination(reg)?;
        }
        for (reg, value) in dst.into_iter().zip(values) {
            self.scalar[usize::from(reg.0)] = RegValue::Pending(value);
        }
        Ok(())
    }

    /// Make all pending scalar loads readable after lgkmcnt(0).
    pub(super) fn finish_scalar_loads(&mut self) {
        for slot in &mut self.scalar {
            if let RegValue::Pending(value) = *slot {
                *slot = RegValue::Ready(value);
            }
        }
    }

    /// Read the 64-bit address an SGPR pair holds as two concrete words, low word first.
    pub fn read_address(&self, arena: &ExprArena, base: [Sgpr; 2]) -> Result<u64, EvalError> {
        let mut words = [0u32; 2];
        for (word, reg) in words.iter_mut().zip(base) {
            let value = self.read_sgpr(reg)?;
            *word = arena
                .as_int_const(value)
                .and_then(|value| u32::try_from(value).ok())
                .ok_or(EvalError::InvalidAddressRegister(reg))?;
        }
        Ok(u64::from(words[0]) | (u64::from(words[1]) << 32))
    }

    /// Read a lane's vector register, rejecting an invalid lane, an unwritten register, or a
    /// pending load's destination.
    pub fn read_vgpr(&self, lane: usize, reg: Vgpr) -> Result<ExprId, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        match registers[usize::from(reg.0)] {
            RegValue::Ready(value) => Ok(value),
            RegValue::Pending(_) => Err(EvalError::PendingVgpr { lane, reg }),
            RegValue::Uninitialized => Err(EvalError::UninitializedVgpr { lane, reg }),
        }
    }

    /// `lane`'s `reg` as an f32 operand: a concrete word is the float its bits encode, and a
    /// symbolic value is a real, as floats are exact reals in Volta.
    pub fn read_f32(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        reg: Vgpr,
    ) -> Result<ExprId, EvalError> {
        let value = self.read_vgpr(lane, reg)?;
        let Some(word) = arena.as_int_const(value) else {
            return Ok(value);
        };
        u32::try_from(word)
            .ok()
            .and_then(|bits| arena.float_from_f64(f64::from(f32::from_bits(bits))).ok())
            .ok_or(EvalError::InvalidFloatVgpr { lane, reg })
    }

    /// The address `lane` accesses in a global instruction: an SGPR-pair base plus a 32-bit
    /// VGPR offset (CDNA4 §10.4), zero-extended as in LLVM 21.1.8's `SelectGlobalSAddr`.
    pub fn global_address(
        &self,
        arena: &ExprArena,
        lane: usize,
        vaddr: Vgpr,
        saddr: [Sgpr; 2],
    ) -> Result<u64, EvalError> {
        let base = self.read_address(arena, saddr)?;
        let offset = self.read_vgpr(lane, vaddr)?;
        let offset = arena
            .as_int_const(offset)
            .and_then(|offset| u32::try_from(offset).ok())
            .ok_or(EvalError::InvalidAddressVgpr { lane, reg: vaddr })?;
        let address = base
            .checked_add(u64::from(offset))
            .ok_or(EvalError::AddressOverflow)?;
        Ok(address)
    }

    /// Write a vector register in one lane unless the lane is invalid or a load is still writing
    /// to the register.
    pub fn write_vgpr(&mut self, lane: usize, reg: Vgpr, value: ExprId) -> Result<(), EvalError> {
        *self.vector_destination(lane, reg)? = RegValue::Ready(value);
        Ok(())
    }

    /// Keep a vector load's result unreadable until a wait establishes its completion.
    pub(super) fn start_vector_load(
        &mut self,
        lane: usize,
        reg: Vgpr,
        value: ExprId,
    ) -> Result<(), EvalError> {
        *self.vector_destination(lane, reg)? = RegValue::Pending(value);
        Ok(())
    }

    fn vector_destination(&mut self, lane: usize, reg: Vgpr) -> Result<&mut RegValue, EvalError> {
        let registers = self
            .vector
            .get_mut(lane)
            .ok_or(EvalError::InvalidLane(lane))?;
        let slot = &mut registers[usize::from(reg.0)];
        match slot {
            RegValue::Pending(_) => Err(EvalError::PendingVgpr { lane, reg }),
            _ => Ok(slot),
        }
    }

    /// Make every lane's pending vector loads readable after vmcnt(0).
    pub(super) fn finish_vector_loads(&mut self) {
        for slot in self.vector.iter_mut().flatten() {
            if let RegValue::Pending(value) = *slot {
                *slot = RegValue::Ready(value);
            }
        }
    }
}
