//! Global memory: the launch's input arrays, which scalar and vector loads read, and output
//! arrays, which vector stores write.

use std::collections::BTreeMap;

use volta_expr::{ExprArena, ExprId, StringId, SymbolicOutputs};

use super::EvalError;
use super::scalar::KernargBuffer;
use super::wave::{as_f32, concrete_word};

/// How each 32-bit output element is interpreted.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OutputType {
    F32,
    U32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ArrayKind {
    Input,
    Output(OutputType),
}

/// An array of 32-bit words in global memory: element `i` is at `base + 4i`. An input
/// element's value is the symbol for element `i` of `name`; output elements start
/// unwritten, and the kernel can store to them but cannot load them.
#[derive(Debug, Clone)]
pub struct ArrayDef {
    pub name: String,
    pub base: u64,
    pub len: u64,
    pub kind: ArrayKind,
}

/// An array whose name is interned in the interpreter's arena.
#[derive(Debug)]
struct Region {
    name: StringId,
    base: u64,
    len: u64,
    kind: ArrayKind,
}

impl Region {
    /// The index of the element whose four bytes start at `address`, if there is one.
    fn element_at(&self, address: u64) -> Option<u64> {
        if address < self.base {
            return None;
        }
        let offset = address - self.base;
        if !offset.is_multiple_of(4) {
            return None;
        }
        let index = offset / 4;
        if index < self.len { Some(index) } else { None }
    }
}

/// The arrays of a launch, disjoint from each other and from the argument buffer.
#[derive(Debug, Default)]
pub(super) struct GlobalMemory {
    regions: Vec<Region>,
    /// Each workgroup's written output words by address; a selected workgroup's run has one.
    written: Vec<BTreeMap<u64, ExprId>>,
    /// The workgroup a store applies to; `None` applies it to every workgroup.
    selected: Option<usize>,
}

/// Every output array with its written elements, in index order.
pub(crate) type OutputArrays = Vec<(String, Vec<(u64, ExprId)>)>;

/// An output element that more than one workgroup stores.
pub(crate) struct OutputConflict {
    pub array: String,
    pub index: u64,
    /// The first workgroup to store the element and a later one that also stores it.
    pub workgroups: [usize; 2],
}

impl GlobalMemory {
    /// Validate `arrays` and intern their names in `arena`.
    pub fn new(
        arrays: &[ArrayDef],
        kernarg: &KernargBuffer,
        arena: &mut ExprArena,
        workgroups: usize,
    ) -> Result<Self, EvalError> {
        check_unique_names(arrays)?;
        let mut ranges = vec![kernarg_range(kernarg)?];
        for array in arrays {
            ranges.push(array_range(array)?);
        }
        check_disjoint(&ranges)?;

        let mut regions = Vec::new();
        for array in arrays {
            regions.push(Region {
                name: arena.intern_string(array.name.clone()),
                base: array.base,
                len: array.len,
                kind: array.kind,
            });
        }
        Ok(Self {
            regions,
            written: vec![BTreeMap::new(); workgroups],
            selected: None,
        })
    }

    /// The symbol of the input element whose four bytes start at `address`.
    pub fn load_dword(&self, address: u64, arena: &mut ExprArena) -> Result<ExprId, EvalError> {
        for region in &self.regions {
            if region.kind == ArrayKind::Input
                && let Some(index) = region.element_at(address)
            {
                return Ok(arena.input_element(region.name, index));
            }
        }
        Err(EvalError::GlobalRead { address })
    }

    /// Interpret a stored word according to the output type and record its mathematical value.
    /// Output elements cannot be loaded; a later store replaces the recorded value.
    pub fn store_dword(
        &mut self,
        address: u64,
        value: ExprId,
        arena: &mut ExprArena,
    ) -> Result<(), EvalError> {
        let output_type = self
            .regions
            .iter()
            .find_map(|region| match region.kind {
                ArrayKind::Output(ty) if region.element_at(address).is_some() => Some(ty),
                _ => None,
            })
            .ok_or(EvalError::GlobalWrite { address })?;

        // Decode float constants without changing real expressions; integer outputs need known bits.
        let value = match output_type {
            OutputType::F32 => {
                as_f32(arena, value).ok_or(EvalError::InvalidFloatOutput { address })?
            }
            OutputType::U32 => {
                concrete_word(arena, value).ok_or(EvalError::InvalidIntegerOutput { address })?;
                value
            }
        };
        match self.selected {
            Some(workgroup) => {
                if let Some(written) = self.written.get_mut(workgroup) {
                    written.insert(address, value);
                }
            }
            None => {
                for written in &mut self.written {
                    written.insert(address, value);
                }
            }
        }
        Ok(())
    }

    /// Apply later stores to `workgroup` only, or to every workgroup for `None`.
    pub fn select(&mut self, workgroup: Option<usize>) {
        self.selected = workgroup;
    }

    /// Export the first workgroup's output arrays with only their written elements.
    pub fn into_outputs(self, arena: ExprArena) -> SymbolicOutputs {
        let outputs = match self.written.first() {
            Some(written) => self.outputs_of(written, &arena),
            None => Vec::new(),
        };
        SymbolicOutputs { arena, outputs }
    }

    /// Each workgroup's output arrays with only their written elements.
    pub fn workgroup_outputs(&self, arena: &ExprArena) -> Vec<OutputArrays> {
        self.written
            .iter()
            .map(|written| self.outputs_of(written, arena))
            .collect()
    }

    /// Every output element a later workgroup stores after an earlier one stored it.
    pub fn conflicts(&self, arena: &ExprArena) -> Vec<OutputConflict> {
        let mut first_writer = BTreeMap::new();
        let mut conflicts = Vec::new();
        for (workgroup, written) in self.written.iter().enumerate() {
            for &address in written.keys() {
                let Some(&first) = first_writer.get(&address) else {
                    first_writer.insert(address, workgroup);
                    continue;
                };
                // Only output elements are ever written, so each address names one.
                for region in &self.regions {
                    if let Some(index) = region.element_at(address) {
                        conflicts.push(OutputConflict {
                            array: arena.string(region.name).to_owned(),
                            index,
                            workgroups: [first, workgroup],
                        });
                    }
                }
            }
        }
        conflicts
    }

    /// Every output array with the elements `written` holds, in index order.
    fn outputs_of(&self, written: &BTreeMap<u64, ExprId>, arena: &ExprArena) -> OutputArrays {
        self.regions
            .iter()
            .filter(|region| matches!(region.kind, ArrayKind::Output(_)))
            .map(|region| {
                let elements = written
                    .iter()
                    .filter_map(|(&address, &value)| {
                        region.element_at(address).map(|index| (index, value))
                    })
                    .collect();
                (arena.string(region.name).to_owned(), elements)
            })
            .collect()
    }
}

/// The bytes `start..end` of the argument buffer or of an array, labeled for errors.
struct ByteRange {
    label: String,
    start: u64,
    end: u64,
}

impl ByteRange {
    /// `end` is `None` when the range would end past the address space.
    fn new(label: String, start: u64, end: Option<u64>) -> Result<Self, EvalError> {
        match end {
            Some(end) => Ok(Self { label, start, end }),
            None => Err(launch_error(format!("{label} ends past the address space"))),
        }
    }

    /// An empty range shares no byte with any range.
    fn overlaps(&self, other: &ByteRange) -> bool {
        let shared_start = self.start.max(other.start);
        let shared_end = self.end.min(other.end);
        shared_start < shared_end
    }
}

fn kernarg_range(kernarg: &KernargBuffer) -> Result<ByteRange, EvalError> {
    let end = kernarg.address.checked_add(kernarg.bytes.len() as u64);
    ByteRange::new(
        "the kernel argument buffer".to_owned(),
        kernarg.address,
        end,
    )
}

fn array_range(array: &ArrayDef) -> Result<ByteRange, EvalError> {
    let label = array_label(array);
    if !array.base.is_multiple_of(4) {
        return Err(launch_error(format!("{label} must start 4-byte aligned")));
    }
    let end = match array.len.checked_mul(4) {
        Some(size) => array.base.checked_add(size),
        None => None,
    };
    ByteRange::new(label, array.base, end)
}

fn check_unique_names(arrays: &[ArrayDef]) -> Result<(), EvalError> {
    for (i, array) in arrays.iter().enumerate() {
        for earlier in &arrays[..i] {
            if earlier.name == array.name {
                let label = array_label(array);
                return Err(launch_error(format!("{label} is declared twice")));
            }
        }
    }
    Ok(())
}

fn check_disjoint(ranges: &[ByteRange]) -> Result<(), EvalError> {
    for (i, first) in ranges.iter().enumerate() {
        for second in &ranges[i + 1..] {
            if first.overlaps(second) {
                let message = format!("{} and {} overlap", first.label, second.label);
                return Err(launch_error(message));
            }
        }
    }
    Ok(())
}

fn array_label(array: &ArrayDef) -> String {
    format!("array {:?}", array.name)
}

fn launch_error(message: String) -> EvalError {
    EvalError::Launch { message }
}
