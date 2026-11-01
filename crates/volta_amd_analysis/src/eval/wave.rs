//! The execution state of one wave of workgroup 0.

use std::collections::VecDeque;

use id_collections::id_type;
use volta_expr::{ExprArena, ExprId};

use crate::ir::{GlobalAddress, InstrId, Sgpr, Src0, Vgpr, Vop3Src};

use super::EvalError;
use super::global::GlobalMemory;

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
    scalar: [RegValue; 102],    // Scalar registers are shared by the wave.
    vector: Vec<LaneRegisters>, // Vector registers have a value per lane.
}

/// One lane's vector registers, and the destinations of each of its loads still pending,
/// oldest first.
#[derive(Debug, Clone)]
struct LaneRegisters {
    values: [RegValue; 256],
    pending_loads: VecDeque<Vec<Vgpr>>,
}

// Initialize the wave with all registers unwritten.
impl Default for WaveRegisters {
    fn default() -> Self {
        let lane = LaneRegisters {
            values: [RegValue::Uninitialized; 256],
            pending_loads: VecDeque::new(),
        };
        Self {
            scalar: [RegValue::Uninitialized; 102],
            vector: vec![lane; 64],
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
        match registers.values[usize::from(reg.0)] {
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
        as_f32(arena, value).ok_or(EvalError::InvalidFloatVgpr { lane, reg })
    }

    /// `lane`'s value of a first source, as its 32 bits.
    pub fn read_src0(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: Src0,
    ) -> Result<ExprId, EvalError> {
        match src {
            Src0::Vgpr(reg) => self.read_vgpr(lane, reg),
            Src0::Sgpr(reg) => self.read_sgpr(reg),
            Src0::Const(bits) => Ok(arena.int(i64::from(bits))),
        }
    }

    /// `lane`'s value of a first source as an f32 operand, read as `read_f32` reads a VGPR.
    pub fn read_f32_src0(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: Src0,
    ) -> Result<ExprId, EvalError> {
        let value = self.read_src0(arena, lane, src)?;
        as_f32(arena, value).ok_or(match src {
            Src0::Vgpr(reg) => EvalError::InvalidFloatVgpr { lane, reg },
            Src0::Sgpr(reg) => EvalError::InvalidFloatSgpr(reg),
            Src0::Const(bits) => EvalError::InvalidFloatConstant(bits),
        })
    }

    /// `lane`'s value of a VOP3 f32 source; a constant is the float its bits encode.
    pub fn read_f32_src(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: Vop3Src,
    ) -> Result<ExprId, EvalError> {
        match src {
            Vop3Src::Vgpr(reg) => self.read_f32(arena, lane, reg),
            Vop3Src::Inline(bits) => {
                f32_from_bits(arena, bits).ok_or(EvalError::InvalidFloatConstant(bits))
            }
        }
    }

    /// The address `lane` accesses in a global instruction: an SGPR-pair base plus a 32-bit
    /// VGPR offset (CDNA4 §10.4), zero-extended as in LLVM 21.1.8's `SelectGlobalSAddr`, plus
    /// the instruction's immediate offset.
    pub fn global_address(
        &self,
        arena: &ExprArena,
        lane: usize,
        address: GlobalAddress,
    ) -> Result<u64, EvalError> {
        let base = self.read_address(arena, address.saddr)?;
        let offset = self.read_vgpr(lane, address.vaddr)?;
        let offset = arena
            .as_int_const(offset)
            .and_then(|offset| u32::try_from(offset).ok())
            .ok_or(EvalError::InvalidAddressVgpr {
                lane,
                reg: address.vaddr,
            })?;
        base.checked_add(u64::from(offset))
            .and_then(|sum| sum.checked_add_signed(i64::from(address.offset)))
            .ok_or(EvalError::AddressOverflow)
    }

    /// Write a vector register in one lane unless the lane is invalid or a load is still writing
    /// to the register.
    pub fn write_vgpr(&mut self, lane: usize, reg: Vgpr, value: ExprId) -> Result<(), EvalError> {
        *self.vector_destination(lane, reg)? = RegValue::Ready(value);
        Ok(())
    }

    /// Load one input word per register of `dst` from consecutive addresses, keeping the results
    /// unreadable until a wait establishes the load's completion.
    pub(super) fn global_load(
        &mut self,
        arena: &mut ExprArena,
        global: &GlobalMemory,
        lane: usize,
        dst: &[Vgpr],
        address: GlobalAddress,
    ) -> Result<(), EvalError> {
        let start = self.global_address(arena, lane, address)?;
        let mut values = Vec::with_capacity(dst.len());
        for i in 0..dst.len() as u64 {
            let word_address = start.checked_add(4 * i).ok_or(EvalError::AddressOverflow)?;
            values.push(global.load_dword(word_address, arena)?);
        }

        // Check every destination before changing any register.
        for &reg in dst {
            self.vector_destination(lane, reg)?;
        }

        let registers = &mut self.vector[lane];
        for (&reg, value) in dst.iter().zip(values) {
            registers.values[usize::from(reg.0)] = RegValue::Pending(value);
        }
        registers.pending_loads.push_back(dst.to_vec());
        Ok(())
    }

    fn vector_destination(&mut self, lane: usize, reg: Vgpr) -> Result<&mut RegValue, EvalError> {
        let registers = self
            .vector
            .get_mut(lane)
            .ok_or(EvalError::InvalidLane(lane))?;
        let slot = &mut registers.values[usize::from(reg.0)];
        match slot {
            RegValue::Pending(_) => Err(EvalError::PendingVgpr { lane, reg }),
            _ => Ok(slot),
        }
    }

    /// Wait until at most `outstanding` loads per lane are in flight. Loads return in issue order,
    /// so only the most recent ones stay pending; stores are assumed to have completed.
    pub(super) fn finish_vector_loads(&mut self, outstanding: usize) {
        for registers in &mut self.vector {
            let completed = registers.pending_loads.len().saturating_sub(outstanding);

            for load in registers.pending_loads.drain(..completed) {
                for reg in load {
                    let slot = &mut registers.values[usize::from(reg.0)];

                    if let RegValue::Pending(value) = *slot {
                        *slot = RegValue::Ready(value);
                    }
                }
            }
        }
    }
}

/// `value` as an f32 operand: a concrete word is the float its bits encode, and a symbolic value
/// is a real; `None` for a NaN or a concrete value wider than 32 bits.
fn as_f32(arena: &mut ExprArena, value: ExprId) -> Option<ExprId> {
    match arena.as_int_const(value) {
        Some(word) => u32::try_from(word)
            .ok()
            .and_then(|bits| f32_from_bits(arena, bits)),
        None => Some(value),
    }
}

/// The f32 that `bits` encode, as an exact real; `None` for a NaN.
fn f32_from_bits(arena: &mut ExprArena, bits: u32) -> Option<ExprId> {
    arena.float_from_f64(f64::from(f32::from_bits(bits))).ok()
}
