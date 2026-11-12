//! The execution state of one wave of the selected workgroup.

use std::collections::{HashMap, HashSet, VecDeque};

use id_collections::id_type;
use volta_expr::{ExprArena, ExprId, ExprNode};
use volta_graph::AsyncOpId;

use crate::ir::{
    Agpr, F64Src, GlobalAddress, InstrId, LaneMask, LaneReg, ModifiedSrc, Sgpr, Src0, Vgpr, Vop3Src,
};

use super::EvalError;
use super::global::GlobalMemory;

/// A wave of the selected workgroup, identified by its index.
/// Wave `w` holds work-items `64w` to `64w + 63`.
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
    /// EXEC: the lanes that run vector, memory and LDS instructions, one bit per lane. Scalar
    /// instructions and branches run whatever it holds (CDNA4 §3.3). It is a concrete mask,
    /// the same in every workgroup of the run.
    pub exec: u64,
    /// The instructions `lgkmcnt` counts that no wait has completed, oldest first.
    pub lgkm_in_flight: VecDeque<LgkmInFlight>,
}

impl WaveState {
    /// A ready wave at the kernel's first instruction, with every lane active.
    pub fn new(registers: WaveRegisters) -> Self {
        Self {
            pc: InstrId(0),
            registers,
            status: Status::Ready,
            exec: u64::MAX,
            lgkm_in_flight: VecDeque::new(),
        }
    }
}

/// An instruction `lgkmcnt` counts, in flight, with the destinations pending until it completes.
#[derive(Debug)]
pub(crate) enum LgkmInFlight {
    /// A DS instruction, the event graph's `op`. A read's or lane exchange's destinations `dst`
    /// are pending in `lanes`, the lanes that ran it; a write has no destinations.
    Ds {
        op: AsyncOpId,
        dst: Vec<Vgpr>,
        lanes: u64,
    },
    /// A scalar load.
    Scalar { dst: Vec<Sgpr> },
}

/// A register's value; a pending value is a load's result, which the wave may neither read nor
/// overwrite before a wait completes the load.
#[derive(Debug, Clone, Copy, PartialEq)]
enum RegValue {
    Uninitialized,
    Ready(ExprId),
    Pending(ExprId),
}

/// A vector register holds a word, or one half of an f64 stored as a single real across a pair.
/// Both halves name the real, so a pair is one f64 only while its halves still match.
#[derive(Debug, Clone, Copy, PartialEq)]
enum VectorValue {
    Word(RegValue),
    F64Low(ExprId),
    F64High(ExprId),
}

/// ScalarValue distinguishes one stored value from 32 separate lane predicates.
/// For a single value, the inner RegValue tracks whether it can be read.
/// Storing each mask half in its own SGPR makes overwrites replace the affected predicates.
#[derive(Debug, Clone, PartialEq)]
enum ScalarValue {
    /// One value, with RegValue tracking whether it is ready, pending or unwritten.
    /// The wrapper leaves the value unchanged; it may be concrete or symbolic.
    Word(RegValue),
    LaneMask(Box<[ExprId]>),
}

/// Register storage for one CDNA4 wave, apart from EXEC, which `WaveState` holds.
#[derive(Debug)]
pub(crate) struct WaveRegisters {
    scalar: [ScalarValue; 102], // Scalar registers are shared by the wave.
    scc: Option<bool>,          // The scalar condition code, once an instruction writes it.
    vector: Vec<LaneRegisters>, // Vector registers have a value per lane.
    /// Locations whose state differs between the launch's workgroups, one state per workgroup.
    varying: HashMap<Slot, Box<[Stored]>>,
    /// The workgroup whose state a read of a varying location returns. Without one, such a
    /// read is rejected, so the instruction runs again once per workgroup.
    view: Option<usize>,
    /// While an execution may still be undone, each location's state before it wrote it.
    undo: Option<Undo>,
    /// Whether this execution repeats an instruction for a later workgroup, so the load it
    /// issues, which every workgroup issues alike, is counted only once.
    repeat: bool,
}

/// A register location: a scalar register, SCC, or one lane's VGPR, AGPR or VCC bit.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
enum Slot {
    Scalar(u8),
    Scc,
    Vector { lane: u8, reg: u8 },
    Agpr { lane: u8, reg: u8 },
    Vcc(u8),
}

/// The stored state of one location.
#[derive(Debug, Clone, PartialEq)]
enum Stored {
    Scalar(ScalarValue),
    Scc(Option<bool>),
    Vector(VectorValue),
    Agpr(Option<ExprId>),
    Vcc(Option<ExprId>),
}

/// What undoing an execution restores: each written location's earlier states, and each
/// lane's count of pending vector loads.
#[derive(Debug)]
struct Undo {
    writes: Vec<EarlierState>,
    pending_loads: Vec<usize>,
}

/// A location's stored state and per-workgroup states before an execution wrote it.
#[derive(Debug)]
struct EarlierState {
    slot: Slot,
    state: Stored,
    varying: Option<Box<[Stored]>>,
}

/// The locations one workgroup's execution of an instruction wrote, with their new states.
#[derive(Debug)]
pub(super) struct WorkgroupWrites(Vec<(Slot, Stored)>);

/// The counter whose wait completes a vector register load: `vmcnt` for global and buffer
/// loads, `lgkmcnt` for LDS reads and lane exchanges, which the wave's `lgkm_in_flight` tracks.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) enum LoadCounter {
    Vm,
    Lgkm,
}

/// One lane's vector and accumulation registers, its VCC bit as a boolean expression, and the
/// destinations of each of its `vmcnt` loads still pending, oldest first; only VGPRs are loaded.
#[derive(Debug, Clone)]
struct LaneRegisters {
    values: [VectorValue; 256],
    accumulators: [Option<ExprId>; 256],
    vcc: Option<ExprId>,
    pending_loads: VecDeque<Vec<Vgpr>>,
}

// Initialize the wave with all registers unwritten.
impl Default for WaveRegisters {
    fn default() -> Self {
        let lane = LaneRegisters {
            values: [VectorValue::Word(RegValue::Uninitialized); 256],
            accumulators: [None; 256],
            vcc: None,
            pending_loads: VecDeque::new(),
        };
        Self {
            scalar: std::array::from_fn(|_| ScalarValue::Word(RegValue::Uninitialized)),
            scc: None,
            vector: vec![lane; 64],
            varying: HashMap::new(),
            view: None,
            undo: None,
            repeat: false,
        }
    }
}

// Track values that differ between workgroups, and execute an instruction once per workgroup.
impl WaveRegisters {
    /// Whether any location holds a different state in different workgroups.
    pub(super) fn has_varying(&self) -> bool {
        !self.varying.is_empty()
    }

    /// Give `reg` one word per workgroup, such as each workgroup's own coordinate.
    pub(super) fn set_varying_sgpr(&mut self, reg: Sgpr, words: &[ExprId]) {
        let states: Box<[Stored]> = words
            .iter()
            .map(|&word| Stored::Scalar(ScalarValue::Word(RegValue::Ready(word))))
            .collect();
        if let Some(first) = states.first() {
            self.assign(Slot::Scalar(reg.0), first.clone());
        }
        self.varying.insert(Slot::Scalar(reg.0), states);
    }

    /// Start an execution that `undo_execution` can reverse.
    pub(super) fn begin_undoable(&mut self) {
        let pending_loads = self
            .vector
            .iter()
            .map(|lane| lane.pending_loads.len())
            .collect();
        self.undo = Some(Undo {
            writes: Vec::new(),
            pending_loads,
        });
    }

    /// Keep everything the execution wrote.
    pub(super) fn commit(&mut self) {
        self.undo = None;
    }

    /// Restore every location the execution wrote and forget the loads it issued.
    pub(super) fn undo_execution(&mut self) {
        let Some(undo) = self.undo.take() else {
            return;
        };
        self.restore(undo.writes);
        for (lane, count) in self.vector.iter_mut().zip(undo.pending_loads) {
            lane.pending_loads.truncate(count);
        }
    }

    /// Execute as `workgroup`: reads of varying locations return that workgroup's states.
    pub(super) fn begin_workgroup(&mut self, workgroup: usize) {
        self.begin_undoable();
        self.view = Some(workgroup);
        self.repeat = workgroup > 0;
    }

    /// Collect what the workgroup's execution wrote, then restore the earlier states so the
    /// next workgroup starts from the same registers. The first workgroup's loads stay issued.
    pub(super) fn end_workgroup(&mut self) -> WorkgroupWrites {
        let mut written = Vec::new();
        if let Some(undo) = &self.undo {
            let mut seen = HashSet::new();
            for earlier in &undo.writes {
                if seen.insert(earlier.slot) {
                    written.push((earlier.slot, self.base_state(earlier.slot)));
                }
            }
        }
        if let Some(undo) = self.undo.take() {
            self.restore(undo.writes);
        }
        self.view = None;
        self.repeat = false;
        WorkgroupWrites(written)
    }

    /// Keep one state when every workgroup agrees, otherwise retain each workgroup's state.
    /// Concrete words and symbolic expressions keep the same representation as in a single run.
    pub(super) fn combine(&mut self, arena: &ExprArena, results: Vec<WorkgroupWrites>) {
        let results: Vec<HashMap<Slot, Stored>> = results
            .into_iter()
            .map(|writes| writes.0.into_iter().collect())
            .collect();
        let mut slots: Vec<Slot> = results
            .iter()
            .flat_map(|writes| writes.keys().copied())
            .collect();
        slots.sort();
        slots.dedup();
        for slot in slots {
            // A location some workgroup did not write keeps its current state there.
            let states: Vec<Stored> = results
                .iter()
                .map(|writes| {
                    writes
                        .get(&slot)
                        .cloned()
                        .unwrap_or_else(|| self.base_state(slot))
                })
                .collect();
            let Some(first) = states.first().cloned() else {
                continue;
            };
            self.varying.remove(&slot);
            if states.iter().all(|state| same_state(arena, state, &first)) {
                self.assign(slot, first);
            } else {
                self.assign(slot, first);
                self.varying.insert(slot, states.into());
            }
        }
    }

    /// Read varying locations as `workgroup`'s, or reject reads of them for `None`.
    pub(super) fn set_view(&mut self, workgroup: Option<usize>) {
        self.view = workgroup;
    }

    /// A varying location's state in the viewed workgroup, or `None` for a uniform location.
    fn varying_state(&self, slot: Slot) -> Result<Option<&Stored>, EvalError> {
        if self.varying.is_empty() {
            return Ok(None);
        }
        match (self.varying.get(&slot), self.view) {
            (None, _) => Ok(None),
            (Some(states), Some(workgroup)) => Ok(states.get(workgroup)),
            (Some(_), None) => Err(EvalError::DependsOnWorkgroup),
        }
    }

    /// A location's state for a pending-load check, which every workgroup shares because
    /// loads are issued alike; a varying location reports the viewed or first workgroup's.
    fn state_for_write(&self, slot: Slot) -> Option<&Stored> {
        let states = self.varying.get(&slot)?;
        states.get(self.view.unwrap_or(0))
    }

    fn scalar_at(&self, index: usize) -> Result<Option<&ScalarValue>, EvalError> {
        if let Ok(reg) = u8::try_from(index)
            && let Some(Stored::Scalar(value)) = self.varying_state(Slot::Scalar(reg))?
        {
            return Ok(Some(value));
        }
        Ok(self.scalar.get(index))
    }

    fn scalar_for_write(&self, index: usize) -> Option<&ScalarValue> {
        if let Ok(reg) = u8::try_from(index)
            && let Some(Stored::Scalar(value)) = self.state_for_write(Slot::Scalar(reg))
        {
            return Some(value);
        }
        self.scalar.get(index)
    }

    fn scc_at(&self) -> Result<Option<bool>, EvalError> {
        match self.varying_state(Slot::Scc)? {
            Some(Stored::Scc(scc)) => Ok(*scc),
            _ => Ok(self.scc),
        }
    }

    fn vector_at(&self, lane: usize, reg: Vgpr) -> Result<VectorValue, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        match self.varying_state(vector_slot(lane, reg))? {
            Some(Stored::Vector(value)) => Ok(*value),
            _ => Ok(registers.values[usize::from(reg.0)]),
        }
    }

    fn vector_for_write(&self, lane: usize, reg: Vgpr) -> Result<VectorValue, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        match self.state_for_write(vector_slot(lane, reg)) {
            Some(Stored::Vector(value)) => Ok(*value),
            _ => Ok(registers.values[usize::from(reg.0)]),
        }
    }

    fn agpr_at(&self, lane: usize, reg: Agpr) -> Result<Option<ExprId>, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        let slot = Slot::Agpr {
            lane: lane as u8,
            reg: reg.0,
        };
        match self.varying_state(slot)? {
            Some(Stored::Agpr(value)) => Ok(*value),
            _ => Ok(registers.accumulators[usize::from(reg.0)]),
        }
    }

    fn vcc_at(&self, lane: usize) -> Result<Option<ExprId>, EvalError> {
        let registers = self.vector.get(lane).ok_or(EvalError::InvalidLane(lane))?;
        match self.varying_state(Slot::Vcc(lane as u8))? {
            Some(Stored::Vcc(value)) => Ok(*value),
            _ => Ok(registers.vcc),
        }
    }

    /// A location's stored state, ignoring per-workgroup states.
    fn base_state(&self, slot: Slot) -> Stored {
        match slot {
            Slot::Scalar(reg) => Stored::Scalar(
                self.scalar
                    .get(usize::from(reg))
                    .cloned()
                    .unwrap_or(ScalarValue::Word(RegValue::Uninitialized)),
            ),
            Slot::Scc => Stored::Scc(self.scc),
            Slot::Vector { lane, reg } => Stored::Vector(
                self.vector
                    .get(usize::from(lane))
                    .map_or(VectorValue::Word(RegValue::Uninitialized), |registers| {
                        registers.values[usize::from(reg)]
                    }),
            ),
            Slot::Agpr { lane, reg } => Stored::Agpr(
                self.vector
                    .get(usize::from(lane))
                    .and_then(|registers| registers.accumulators[usize::from(reg)]),
            ),
            Slot::Vcc(lane) => Stored::Vcc(
                self.vector
                    .get(usize::from(lane))
                    .and_then(|registers| registers.vcc),
            ),
        }
    }

    /// Overwrite a location's stored state without recording the write.
    fn assign(&mut self, slot: Slot, state: Stored) {
        match (slot, state) {
            (Slot::Scalar(reg), Stored::Scalar(value)) => {
                if let Some(stored) = self.scalar.get_mut(usize::from(reg)) {
                    *stored = value;
                }
            }
            (Slot::Scc, Stored::Scc(value)) => self.scc = value,
            (Slot::Vector { lane, reg }, Stored::Vector(value)) => {
                if let Some(registers) = self.vector.get_mut(usize::from(lane)) {
                    registers.values[usize::from(reg)] = value;
                }
            }
            (Slot::Agpr { lane, reg }, Stored::Agpr(value)) => {
                if let Some(registers) = self.vector.get_mut(usize::from(lane)) {
                    registers.accumulators[usize::from(reg)] = value;
                }
            }
            (Slot::Vcc(lane), Stored::Vcc(value)) => {
                if let Some(registers) = self.vector.get_mut(usize::from(lane)) {
                    registers.vcc = value;
                }
            }
            _ => {}
        }
    }

    /// Restore the states an undo log recorded, latest write first.
    fn restore(&mut self, writes: Vec<EarlierState>) {
        for earlier in writes.into_iter().rev() {
            self.assign(earlier.slot, earlier.state);
            match earlier.varying {
                Some(states) => {
                    self.varying.insert(earlier.slot, states);
                }
                None => {
                    self.varying.remove(&earlier.slot);
                }
            }
        }
    }

    /// Before writing `slot`: it no longer differs between workgroups, and an execution that
    /// may be undone remembers its earlier state.
    fn note_write(&mut self, slot: Slot) {
        let varying = self.varying.remove(&slot);
        if self.undo.is_some() {
            let state = self.base_state(slot);
            if let Some(undo) = &mut self.undo {
                undo.writes.push(EarlierState {
                    slot,
                    state,
                    varying,
                });
            }
        }
    }

    fn set_scalar(&mut self, index: usize, value: ScalarValue) {
        if let Ok(reg) = u8::try_from(index) {
            self.note_write(Slot::Scalar(reg));
            self.assign(Slot::Scalar(reg), Stored::Scalar(value));
        }
    }

    /// Make a completed load's destination readable, in every workgroup's state.
    fn finish_slot(&mut self, slot: Slot) {
        let finish = |state: &mut Stored| {
            if let Stored::Scalar(ScalarValue::Word(value))
            | Stored::Vector(VectorValue::Word(value)) = state
                && let RegValue::Pending(loaded) = *value
            {
                *value = RegValue::Ready(loaded);
            }
        };
        let mut state = self.base_state(slot);
        finish(&mut state);
        self.assign(slot, state);
        if let Some(states) = self.varying.get_mut(&slot) {
            for state in states.iter_mut() {
                finish(state);
            }
        }
    }
}

/// Whether two expressions are the same value: one node, or equal constants, input elements
/// or parameters, which separate executions create as separate nodes.
fn same_value(arena: &ExprArena, a: ExprId, b: ExprId) -> bool {
    if a == b {
        return true;
    }
    let (a, b) = (arena.node(a), arena.node(b));
    let atom = matches!(
        a,
        ExprNode::IntConst(_)
            | ExprNode::RealConst(_)
            | ExprNode::BoolConst(_)
            | ExprNode::InputElement { .. }
            | ExprNode::ParamSymbol(_)
    );
    atom && a == b
}

fn same_reg_value(arena: &ExprArena, a: RegValue, b: RegValue) -> bool {
    match (a, b) {
        (RegValue::Uninitialized, RegValue::Uninitialized) => true,
        (RegValue::Ready(a), RegValue::Ready(b)) | (RegValue::Pending(a), RegValue::Pending(b)) => {
            same_value(arena, a, b)
        }
        _ => false,
    }
}

/// Whether two workgroups' states of a location hold the same values.
fn same_state(arena: &ExprArena, a: &Stored, b: &Stored) -> bool {
    let same_option = |a: &Option<ExprId>, b: &Option<ExprId>| match (a, b) {
        (Some(a), Some(b)) => same_value(arena, *a, *b),
        (None, None) => true,
        _ => false,
    };
    match (a, b) {
        (Stored::Scalar(ScalarValue::Word(a)), Stored::Scalar(ScalarValue::Word(b)))
        | (Stored::Vector(VectorValue::Word(a)), Stored::Vector(VectorValue::Word(b))) => {
            same_reg_value(arena, *a, *b)
        }
        (Stored::Scalar(ScalarValue::LaneMask(a)), Stored::Scalar(ScalarValue::LaneMask(b))) => {
            a.len() == b.len()
                && a.iter()
                    .zip(b.iter())
                    .all(|(a, b)| same_value(arena, *a, *b))
        }
        (Stored::Scc(a), Stored::Scc(b)) => a == b,
        (Stored::Vector(VectorValue::F64Low(a)), Stored::Vector(VectorValue::F64Low(b)))
        | (Stored::Vector(VectorValue::F64High(a)), Stored::Vector(VectorValue::F64High(b))) => {
            same_value(arena, *a, *b)
        }
        (Stored::Agpr(a), Stored::Agpr(b)) | (Stored::Vcc(a), Stored::Vcc(b)) => same_option(a, b),
        _ => false,
    }
}

fn vector_slot(lane: usize, reg: Vgpr) -> Slot {
    Slot::Vector {
        lane: lane as u8,
        reg: reg.0,
    }
}

impl WaveRegisters {
    /// Read an initialized scalar value whose load has completed.
    /// Reject symbolic lane masks, which must be read as individual lane predicates,
    /// because their comparison results are not yet known.
    pub fn read_sgpr(&self, reg: Sgpr) -> Result<ExprId, EvalError> {
        match self.scalar_at(usize::from(reg.0))? {
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
        self.set_scalar(
            usize::from(reg.0),
            ScalarValue::Word(RegValue::Ready(value)),
        );
        Ok(())
    }

    /// Allow a write to replace a value or mask, but not an unfinished load.
    fn check_scalar_destination(&self, reg: Sgpr) -> Result<(), EvalError> {
        match self.scalar_for_write(usize::from(reg.0)) {
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
            self.set_scalar(
                usize::from(reg.0),
                ScalarValue::Word(RegValue::Pending(value)),
            );
        }
        Ok(())
    }

    /// A completed scalar load makes `dst` readable; the stored expression stays the same.
    pub(super) fn finish_scalar_load(&mut self, dst: &[Sgpr]) {
        for reg in dst {
            self.finish_slot(Slot::Scalar(reg.0));
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
        self.scc_at()?.ok_or(EvalError::UninitializedScc)
    }

    pub fn write_scc(&mut self, scc: bool) {
        self.note_write(Slot::Scc);
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
            let value = match word {
                Some(word) => ScalarValue::Word(RegValue::Ready(arena.int(i64::from(word)))),
                None => ScalarValue::LaneMask(bits.into()),
            };
            self.set_scalar(usize::from(reg.0), value);
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
                if let Some(ScalarValue::LaneMask(bits)) = self.scalar_at(usize::from(reg.0))? {
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
        match self.vector_at(lane, reg)? {
            VectorValue::Word(RegValue::Ready(value)) => Ok(value),
            VectorValue::Word(RegValue::Pending(_)) => Err(EvalError::PendingVgpr { lane, reg }),
            VectorValue::Word(RegValue::Uninitialized) => {
                Err(EvalError::UninitializedVgpr { lane, reg })
            }
            VectorValue::F64Low(_) | VectorValue::F64High(_) => {
                Err(EvalError::F64Half { lane, reg })
            }
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
        self.agpr_at(lane, reg)?
            .ok_or(EvalError::UninitializedAgpr { lane, reg })
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
        Ok(apply_modifiers(arena, value, src.abs, src.neg))
    }

    /// `lane`'s value of an f64 source. A VGPR pair holds one f64 value or two concrete words
    /// that encode one; a broken pair and a pair of symbolic f32 words are not an f64.
    pub fn read_f64_src(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: F64Src,
    ) -> Result<ExprId, EvalError> {
        let bits = match src {
            F64Src::Vgprs(pair) => {
                let low = self.vector_at(lane, pair[0])?;
                let high = self.vector_at(lane, pair[1])?;
                if let (VectorValue::F64Low(value), VectorValue::F64High(other)) = (low, high)
                    && value == other
                {
                    return Ok(value);
                }
                let low = self.read_vgpr(lane, pair[0])?;
                let high = self.read_vgpr(lane, pair[1])?;
                let (Some(low), Some(high)) =
                    (concrete_word(arena, low), concrete_word(arena, high))
                else {
                    return Err(EvalError::InvalidF64Vgpr { lane, reg: pair[0] });
                };
                u64::from(low) | (u64::from(high) << 32)
            }
            F64Src::Sgprs(pair) => self.read_sgpr_pair(arena, pair)?,
            F64Src::Const(bits) => bits,
        };
        arena
            .float_from_f64(f64::from_bits(bits))
            .map_err(|_| EvalError::InvalidF64Bits(bits))
    }

    /// `lane`'s value of an f64 source after its input modifiers.
    pub fn read_modified_f64(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: ModifiedSrc<F64Src>,
    ) -> Result<ExprId, EvalError> {
        let value = self.read_f64_src(arena, lane, src.src)?;
        Ok(apply_modifiers(arena, value, src.abs, src.neg))
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
        self.vcc_at(lane)?
            .ok_or(EvalError::UninitializedVcc { lane })
    }

    pub fn write_vcc(&mut self, lane: usize, condition: ExprId) -> Result<(), EvalError> {
        if lane >= self.vector.len() {
            return Err(EvalError::InvalidLane(lane));
        }
        self.note_write(Slot::Vcc(lane as u8));
        self.assign(Slot::Vcc(lane as u8), Stored::Vcc(Some(condition)));
        Ok(())
    }

    /// Write a vector register in one lane unless the lane is invalid or a load is still writing
    /// to the register.
    pub fn write_vgpr(&mut self, lane: usize, reg: Vgpr, value: ExprId) -> Result<(), EvalError> {
        self.check_vector_destination(lane, reg)?;
        self.set_vector(lane, reg, VectorValue::Word(RegValue::Ready(value)));
        Ok(())
    }

    /// Write one f64 value across a VGPR pair, unless a load is still writing either half.
    pub fn write_f64(
        &mut self,
        lane: usize,
        dst: [Vgpr; 2],
        value: ExprId,
    ) -> Result<(), EvalError> {
        self.check_vector_destination(lane, dst[0])?;
        self.check_vector_destination(lane, dst[1])?;
        self.set_vector(lane, dst[1], VectorValue::F64High(value));
        self.set_vector(lane, dst[0], VectorValue::F64Low(value));
        Ok(())
    }

    /// Copy two source words to a VGPR pair, reading both before writing either. An f64 half
    /// stays a half, so a whole copy keeps the f64 and a copy that splits it leaves none.
    pub fn move_words(
        &mut self,
        arena: &mut ExprArena,
        lane: usize,
        dst: [Vgpr; 2],
        src: [Src0; 2],
    ) -> Result<(), EvalError> {
        let low = self.move_source(arena, lane, src[0])?;
        let high = self.move_source(arena, lane, src[1])?;
        self.check_vector_destination(lane, dst[0])?;
        self.check_vector_destination(lane, dst[1])?;
        self.set_vector(lane, dst[1], high);
        self.set_vector(lane, dst[0], low);
        Ok(())
    }

    /// A moved source's stored form: an f64 half stays a half, and anything else is a word.
    fn move_source(
        &self,
        arena: &mut ExprArena,
        lane: usize,
        src: Src0,
    ) -> Result<VectorValue, EvalError> {
        if let Src0::Vgpr(reg) = src {
            let value = self.vector_at(lane, reg)?;
            if matches!(value, VectorValue::F64Low(_) | VectorValue::F64High(_)) {
                return Ok(value);
            }
        }
        let value = self.read_src0(arena, lane, src)?;
        Ok(VectorValue::Word(RegValue::Ready(value)))
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
        if lane >= self.vector.len() {
            return Err(EvalError::InvalidLane(lane));
        }
        let slot = Slot::Agpr {
            lane: lane as u8,
            reg: reg.0,
        };
        self.note_write(slot);
        self.assign(slot, Stored::Agpr(Some(value)));
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
            self.check_vector_destination(lane, reg)?;
        }

        for (&reg, &value) in dst.iter().zip(values) {
            self.set_vector(lane, reg, VectorValue::Word(RegValue::Pending(value)));
        }
        // A repeated execution for a later workgroup issues the load the first one counted.
        if counter == LoadCounter::Vm
            && !self.repeat
            && let Some(registers) = self.vector.get_mut(lane)
        {
            registers.pending_loads.push_back(dst.to_vec());
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

    /// Reject an invalid lane, or a register a load is still writing.
    fn check_vector_destination(&self, lane: usize, reg: Vgpr) -> Result<(), EvalError> {
        match self.vector_for_write(lane, reg)? {
            VectorValue::Word(RegValue::Pending(_)) => Err(EvalError::PendingVgpr { lane, reg }),
            _ => Ok(()),
        }
    }

    /// Write `reg` in a lane that `check_vector_destination` accepted.
    fn set_vector(&mut self, lane: usize, reg: Vgpr, value: VectorValue) {
        let slot = vector_slot(lane, reg);
        self.note_write(slot);
        self.assign(slot, Stored::Vector(value));
    }

    /// Wait until at most `outstanding` `vmcnt` loads are in flight per lane. Loads return in
    /// issue order, so the most recent stay pending; counting neither stores nor the loads EXEC
    /// kept from a lane keeps more loads pending than the hardware does.
    pub(super) fn finish_vm_loads(&mut self, outstanding: usize) {
        for lane in 0..self.vector.len() {
            let completed: Vec<Vec<Vgpr>> = match self.vector.get_mut(lane) {
                Some(registers) => {
                    let count = registers.pending_loads.len().saturating_sub(outstanding);
                    registers.pending_loads.drain(..count).collect()
                }
                None => Vec::new(),
            };
            for reg in completed.into_iter().flatten() {
                self.finish_slot(vector_slot(lane, reg));
            }
        }
    }

    /// A completed DS read or lane exchange makes `dst` readable in `lanes`, the lanes that ran
    /// it. In another lane, `dst` may be pending on a load this completion does not cover.
    pub(super) fn finish_ds_load(&mut self, dst: &[Vgpr], lanes: u64) {
        for lane in active_lanes(lanes) {
            for &reg in dst {
                self.finish_slot(vector_slot(lane, reg));
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

/// A float `value` after its input modifiers: the absolute value, then the negation.
pub(super) fn apply_modifiers(
    arena: &mut ExprArena,
    value: ExprId,
    abs: bool,
    neg: bool,
) -> ExprId {
    let value = if abs { arena.abs(value) } else { value };
    if neg { arena.neg(value) } else { value }
}

/// The f32 that `bits` encode, as an exact real; `None` for a NaN.
pub(super) fn f32_from_bits(arena: &mut ExprArena, bits: u32) -> Option<ExprId> {
    arena.float_from_f64(f64::from(f32::from_bits(bits))).ok()
}

/// Whether `lane`'s bit of a 64-bit lane mask is set.
pub(super) fn lane_bit(mask: u64, lane: usize) -> bool {
    (mask >> lane) & 1 == 1
}

/// The lanes whose bit of `mask` is set, in lane order.
pub(super) fn active_lanes(mask: u64) -> impl Iterator<Item = usize> {
    (0..64).filter(move |&lane| lane_bit(mask, lane))
}
