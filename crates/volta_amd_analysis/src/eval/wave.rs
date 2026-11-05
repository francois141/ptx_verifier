//! The execution state of one wave of workgroup 0.

use std::collections::VecDeque;

use id_collections::id_type;
use volta_expr::{ExprArena, ExprId};

use crate::ir::{
    Agpr, GlobalAddress, InstrId, LaneMask, LaneReg, ModifiedSrc, Sgpr, Src0, Vgpr, Vop3Src,
};

use super::EvalError;
use super::global::GlobalMemory;

/// A wave of workgroup 0, identified by its index: wave `w` holds work-items `64w` to `64w + 63`.
#[id_type]
pub struct WaveId(pub u32);

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum Status {
    Ready,
    /// Executed `s_barrier` and waits for the workgroup's other waves.
    AtBarrier,
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

/// ScalarValue distinguishes one stored value from 32 separate lane predicates.
/// For a single value, the inner RegValue tracks whether it can be read.
/// Storing each mask half in its own SGPR makes overwrites replace the affected predicates.
#[derive(Debug)]
enum ScalarValue {
    /// One value, with RegValue tracking whether it is ready, pending or unwritten.
    /// The wrapper leaves the value unchanged; it may be concrete or symbolic.
    Word(RegValue),
    LaneMask(Box<[ExprId]>),
}

/// Register storage for one CDNA4 wave. EXEC is not stored: no supported instruction writes
/// it, so every lane of the full waves Volta launches stays active.
#[derive(Debug)]
pub(crate) struct WaveRegisters {
    scalar: [ScalarValue; 102], // Scalar registers are shared by the wave.
    scc: Option<bool>,          // The scalar condition code, once an instruction writes it.
    vector: Vec<LaneRegisters>, // Vector registers have a value per lane.
}

/// The counter whose wait completes a vector register load: `vmcnt` for global and buffer
/// loads, `lgkmcnt` for LDS reads and lane exchanges.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) enum LoadCounter {
    Vm,
    Lgkm,
}

/// One lane's vector and accumulation registers, its VCC bit as a boolean expression, and the
/// destinations of each of its loads still pending per counter, oldest first; only VGPRs are
/// loaded.
#[derive(Debug, Clone)]
struct LaneRegisters {
    values: [RegValue; 256],
    accumulators: [Option<ExprId>; 256],
    vcc: Option<ExprId>,
    pending_loads: VecDeque<Vec<Vgpr>>,
    pending_lds_reads: VecDeque<Vec<Vgpr>>,
}

// Initialize the wave with all registers unwritten.
impl Default for WaveRegisters {
    fn default() -> Self {
        let lane = LaneRegisters {
            values: [RegValue::Uninitialized; 256],
            accumulators: [None; 256],
            vcc: None,
            pending_loads: VecDeque::new(),
            pending_lds_reads: VecDeque::new(),
        };
        Self {
            scalar: std::array::from_fn(|_| ScalarValue::Word(RegValue::Uninitialized)),
            scc: None,
            vector: vec![lane; 64],
        }
    }
}

impl WaveRegisters {
    /// Read an initialized scalar value whose load has completed.
    /// Reject symbolic lane masks, which must be read as individual lane predicates,
    /// because their comparison results are not yet known.
    pub fn read_sgpr(&self, reg: Sgpr) -> Result<ExprId, EvalError> {
        match self.scalar.get(usize::from(reg.0)) {
            Some(ScalarValue::Word(RegValue::Ready(value))) => Ok(*value),
            Some(ScalarValue::Word(RegValue::Pending(_))) => Err(EvalError::PendingSgpr(reg)),
            Some(ScalarValue::Word(RegValue::Uninitialized)) => {
                Err(EvalError::UninitializedSgpr(reg))
            }
            Some(ScalarValue::LaneMask(_)) => Err(EvalError::SymbolicSgpr(reg)),
            None => Err(EvalError::InvalidSgpr(reg)),
        }
    }

    /// Write a scalar register unless a load is still writing to it.
    pub fn write_sgpr(&mut self, reg: Sgpr, value: ExprId) -> Result<(), EvalError> {
        self.check_scalar_destination(reg)?;
        // Writing a value replaces any comparison predicates previously held here.
        self.scalar[usize::from(reg.0)] = ScalarValue::Word(RegValue::Ready(value));
        Ok(())
    }

    /// Allow a write to replace a value or mask, but not an unfinished load.
    fn check_scalar_destination(&self, reg: Sgpr) -> Result<(), EvalError> {
        match self.scalar.get(usize::from(reg.0)) {
            Some(ScalarValue::Word(RegValue::Pending(_))) => Err(EvalError::PendingSgpr(reg)),
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
        // Store each load result, but block reads and overwrites until a wait completes it.
        for (reg, value) in dst.into_iter().zip(values) {
            self.scalar[usize::from(reg.0)] = ScalarValue::Word(RegValue::Pending(value));
        }
        Ok(())
    }

    pub(super) fn has_pending_scalar_loads(&self) -> bool {
        self.scalar
            .iter()
            .any(|slot| matches!(slot, ScalarValue::Word(RegValue::Pending(_))))
    }

    /// Make all pending scalar loads readable after lgkmcnt(0).
    /// The stored expression stays the same; only its readiness changes.
    pub(super) fn finish_scalar_loads(&mut self) {
        for slot in &mut self.scalar {
            if let ScalarValue::Word(RegValue::Pending(value)) = slot {
                *slot = ScalarValue::Word(RegValue::Ready(*value));
            }
        }
    }

    /// A scalar register's concrete 32-bit word.
    pub fn read_sgpr_word(&self, arena: &ExprArena, reg: Sgpr) -> Result<u32, EvalError> {
        let value = self.read_sgpr(reg)?;
        concrete_word(arena, value).ok_or(EvalError::SymbolicSgpr(reg))
    }

    /// The concrete 64-bit word an aligned SGPR pair holds, low word first.
    pub fn read_sgpr_pair(&self, arena: &ExprArena, pair: [Sgpr; 2]) -> Result<u64, EvalError> {
        let low = self.read_sgpr_word(arena, pair[0])?;
        let high = self.read_sgpr_word(arena, pair[1])?;
        Ok(u64::from(low) | (u64::from(high) << 32))
    }

    pub fn write_sgpr_pair(
        &mut self,
        arena: &mut ExprArena,
        pair: [Sgpr; 2],
        value: u64,
    ) -> Result<(), EvalError> {
        // Check both destinations before changing either register.
        for reg in pair {
            self.check_scalar_destination(reg)?;
        }
        let low = arena.int(i64::from(value as u32));
        let high = arena.int(i64::from((value >> 32) as u32));
        self.write_sgpr(pair[0], low)?;
        self.write_sgpr(pair[1], high)
    }

    pub fn read_scc(&self) -> Result<bool, EvalError> {
        self.scc.ok_or(EvalError::UninitializedScc)
    }

    pub fn write_scc(&mut self, scc: bool) {
        self.scc = Some(scc);
    }

    /// VCC as a 64-bit lane mask; every lane's bit must be a concrete boolean.
    pub fn read_vcc_mask(&self, arena: &ExprArena) -> Result<u64, EvalError> {
        let mut mask = 0;
        for lane in 0..self.vector.len() {
            let bit = self.read_vcc(lane)?;
            match arena.as_bool(bit) {
                Some(true) => mask |= 1 << lane,
                Some(false) => {}
                None => return Err(EvalError::SymbolicVcc { lane }),
            }
        }
        Ok(mask)
    }

    pub fn write_vcc_mask(&mut self, arena: &mut ExprArena, mask: u64) -> Result<(), EvalError> {
        for lane in 0..self.vector.len() {
            let bit = arena.bool_val(lane_bit(mask, lane));
            self.write_vcc(lane, bit)?;
        }
        Ok(())
    }

    /// Store one comparison predicate per lane in VCC or an SGPR pair. An SGPR pair retains
    /// concrete halves as ordinary words.
    pub fn write_lane_mask(
        &mut self,
        arena: &mut ExprArena,
        mask: LaneMask,
        conditions: &[ExprId],
    ) -> Result<(), EvalError> {
        let LaneMask::Sgprs(pair) = mask else {
            for (lane, &condition) in conditions.iter().enumerate() {
                self.write_vcc(lane, condition)?;
            }
            return Ok(());
        };
        for reg in pair {
            self.check_scalar_destination(reg)?;
        }
        // The first SGPR holds lanes 0–31; the second holds lanes 32–63.
        for (reg, bits) in pair.into_iter().zip(conditions.chunks_exact(32)) {
            // Pack known comparison results into a word; keep predicates if any bit is unknown.
            let word = bits.iter().enumerate().try_fold(0u32, |word, (i, &bit)| {
                arena.as_bool(bit).map(|bit| word | (u32::from(bit) << i))
            });
            self.scalar[usize::from(reg.0)] = match word {
                Some(word) => ScalarValue::Word(RegValue::Ready(arena.int(i64::from(word)))),
                None => ScalarValue::LaneMask(bits.into()),
            };
        }
        Ok(())
    }

    /// Read a lane's predicate from VCC or an SGPR pair; either may hold symbolic comparisons.
    pub fn read_lane_condition(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        mask: LaneMask,
    ) -> Result<ExprId, EvalError> {
        match mask {
            LaneMask::Vcc => self.read_vcc(lane),
            LaneMask::Sgprs(pair) => {
                // Select the SGPR for this lane, then read its predicate or extract its known bit.
                let reg = *pair.get(lane / 32).ok_or(EvalError::InvalidLane(lane))?;
                if let Some(ScalarValue::LaneMask(bits)) = self.scalar.get(usize::from(reg.0)) {
                    return Ok(bits[lane % 32]);
                }
                let word = self.read_sgpr_word(arena, reg)?;
                Ok(arena.bool_val(lane_bit(u64::from(word), lane % 32)))
            }
        }
    }

    /// Read the 64-bit address an SGPR pair holds as two concrete words, low word first.
    pub fn read_concrete_address(
        &self,
        arena: &ExprArena,
        base: [Sgpr; 2],
    ) -> Result<u64, EvalError> {
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

    pub fn read_agpr(&self, lane: usize, reg: Agpr) -> Result<ExprId, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        registers.accumulators[usize::from(reg.0)].ok_or(EvalError::UninitializedAgpr { lane, reg })
    }

    pub fn read_lane_reg(&self, lane: usize, reg: LaneReg) -> Result<ExprId, EvalError> {
        match reg {
            LaneReg::Vgpr(reg) => self.read_vgpr(lane, reg),
            LaneReg::Agpr(reg) => self.read_agpr(lane, reg),
        }
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

    /// `lane`'s value of a VOP3 source, as its 32 bits.
    pub fn read_src(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: Vop3Src,
    ) -> Result<ExprId, EvalError> {
        match src {
            Vop3Src::Vgpr(reg) => self.read_vgpr(lane, reg),
            Vop3Src::Sgpr(reg) => self.read_sgpr(reg),
            Vop3Src::Inline(bits) => Ok(arena.int(i64::from(bits))),
        }
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
            Vop3Src::Sgpr(reg) => {
                let value = self.read_sgpr(reg)?;
                as_f32(arena, value).ok_or(EvalError::InvalidFloatSgpr(reg))
            }
            Vop3Src::Inline(bits) => {
                f32_from_bits(arena, bits).ok_or(EvalError::InvalidFloatConstant(bits))
            }
        }
    }

    /// `lane`'s value of a VOP3 f32 source after its input modifiers.
    pub fn read_modified_src(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: ModifiedSrc,
    ) -> Result<ExprId, EvalError> {
        let value = self.read_f32_src(arena, lane, src.src)?;
        let value = if src.abs { arena.abs(value) } else { value };
        Ok(if src.neg { arena.neg(value) } else { value })
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
        let base = self.read_concrete_address(arena, address.saddr)?;
        let offset = self.read_concrete_address_vgpr(arena, lane, address.vaddr)?;
        base.checked_add(u64::from(offset))
            .and_then(|sum| sum.checked_add_signed(i64::from(address.offset)))
            .ok_or(EvalError::AddressOverflow)
    }

    /// `lane`'s concrete 32-bit word in an address VGPR.
    pub fn read_concrete_address_vgpr(
        &self,
        arena: &ExprArena,
        lane: usize,
        reg: Vgpr,
    ) -> Result<u32, EvalError> {
        let value = self.read_vgpr(lane, reg)?;
        concrete_word(arena, value).ok_or(EvalError::InvalidAddressVgpr { lane, reg })
    }

    /// `lane`'s VCC bit, which must have been written by a comparison.
    pub fn read_vcc(&self, lane: usize) -> Result<ExprId, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        registers.vcc.ok_or(EvalError::UninitializedVcc { lane })
    }

    pub fn write_vcc(&mut self, lane: usize, condition: ExprId) -> Result<(), EvalError> {
        let registers = self
            .vector
            .get_mut(lane)
            .ok_or(EvalError::InvalidLane(lane))?;
        registers.vcc = Some(condition);
        Ok(())
    }

    /// Write a vector register in one lane unless the lane is invalid or a load is still writing
    /// to the register.
    pub fn write_vgpr(&mut self, lane: usize, reg: Vgpr, value: ExprId) -> Result<(), EvalError> {
        *self.vector_destination(lane, reg)? = RegValue::Ready(value);
        Ok(())
    }

    pub fn write_lane_reg(
        &mut self,
        lane: usize,
        reg: LaneReg,
        value: ExprId,
    ) -> Result<(), EvalError> {
        match reg {
            LaneReg::Vgpr(reg) => self.write_vgpr(lane, reg, value),
            LaneReg::Agpr(reg) => self.write_agpr(lane, reg, value),
        }
    }

    /// AGPRs are never a load's destination, so a write needs no pending check.
    pub fn write_agpr(&mut self, lane: usize, reg: Agpr, value: ExprId) -> Result<(), EvalError> {
        let registers = self
            .vector
            .get_mut(lane)
            .ok_or(EvalError::InvalidLane(lane))?;
        registers.accumulators[usize::from(reg.0)] = Some(value);
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
        self.start_vector_load(lane, dst, &values, LoadCounter::Vm)
    }

    /// Give each register of `dst` its loaded value, unreadable until a wait on `counter`
    /// establishes the load's completion.
    pub(super) fn start_vector_load(
        &mut self,
        lane: usize,
        dst: &[Vgpr],
        values: &[ExprId],
        counter: LoadCounter,
    ) -> Result<(), EvalError> {
        // Check every destination before changing any register.
        for &reg in dst {
            self.vector_destination(lane, reg)?;
        }

        let registers = &mut self.vector[lane];
        for (&reg, &value) in dst.iter().zip(values) {
            registers.values[usize::from(reg.0)] = RegValue::Pending(value);
        }
        match counter {
            LoadCounter::Vm => registers.pending_loads.push_back(dst.to_vec()),
            LoadCounter::Lgkm => registers.pending_lds_reads.push_back(dst.to_vec()),
        }
        Ok(())
    }

    /// Store the word of each register of `src` to consecutive addresses.
    pub(super) fn global_store(
        &self,
        arena: &mut ExprArena,
        global: &mut GlobalMemory,
        lane: usize,
        src: &[LaneReg],
        address: GlobalAddress,
    ) -> Result<(), EvalError> {
        let start = self.global_address(arena, lane, address)?;
        for (i, &reg) in (0u64..).zip(src) {
            let word_address = start.checked_add(4 * i).ok_or(EvalError::AddressOverflow)?;
            global.store_dword(word_address, self.read_lane_reg(lane, reg)?, arena)?;
        }
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

    /// Wait until at most `outstanding` loads counted by `counter` are in flight per lane. Loads
    /// return in issue order, so the most recent stay pending; counting no stores or LDS writes
    /// keeps more loads pending than the hardware does.
    pub(super) fn finish_vector_loads(&mut self, counter: LoadCounter, outstanding: usize) {
        for registers in &mut self.vector {
            let pending = match counter {
                LoadCounter::Vm => &mut registers.pending_loads,
                LoadCounter::Lgkm => &mut registers.pending_lds_reads,
            };
            let completed = pending.len().saturating_sub(outstanding);

            for load in pending.drain(..completed) {
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

/// A concrete value as the 32-bit word it is; `None` for a symbolic or wider value.
pub(super) fn concrete_word(arena: &ExprArena, value: ExprId) -> Option<u32> {
    arena
        .as_int_const(value)
        .and_then(|value| u32::try_from(value).ok())
}

/// `value` as an f32 operand: a concrete word is the float its bits encode, and a symbolic value
/// is a real; `None` for a NaN or a concrete value wider than 32 bits.
pub(super) fn as_f32(arena: &mut ExprArena, value: ExprId) -> Option<ExprId> {
    match arena.as_int_const(value) {
        Some(word) => u32::try_from(word)
            .ok()
            .and_then(|bits| f32_from_bits(arena, bits)),
        None => Some(value),
    }
}

/// The f32 that `bits` encode, as an exact real; `None` for a NaN.
pub(super) fn f32_from_bits(arena: &mut ExprArena, bits: u32) -> Option<ExprId> {
    arena.float_from_f64(f64::from(f32::from_bits(bits))).ok()
}

/// Whether `lane`'s bit of a 64-bit lane mask is set.
pub(super) fn lane_bit(mask: u64, lane: usize) -> bool {
    (mask >> lane) & 1 == 1
}
