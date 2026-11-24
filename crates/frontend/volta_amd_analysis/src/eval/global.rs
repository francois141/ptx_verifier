//! Global memory: the launch's input arrays, which scalar and vector loads read, and output
//! arrays, which vector stores write.

use std::collections::BTreeMap;
use std::sync::Arc;

use volta_expr::FullOutputs;
use volta_expr::symbolic_full::{ExprArena, ExprId, StringId};

use super::EvalError;
use super::scalar::KernargBuffer;
use super::wave::{as_f32, concrete_word};
use super::word::Word;

/// How each 32-bit output element is interpreted.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OutputType {
    F32,
    U32,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ArrayKind {
    Input,
    /// A read-only input of concrete words, one per `Element::Word` element: integer data
    /// such as counts and indices, which symbolic elements cannot address or divide.
    Integers(Arc<[u32]>),
    Output(OutputType),
}

/// How an array's bytes hold its elements.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Element {
    /// A 32-bit word per element, read and written whole; an output's `OutputType` says how a
    /// stored word is interpreted.
    Word,
    /// A bf16 real per two bytes, two to a word, the lower address in the low half. Every
    /// element is a real, so an output's `OutputType` must be `F32`.
    Bf16,
}

impl Element {
    fn bytes(self) -> u64 {
        match self {
            Element::Word => 4,
            Element::Bf16 => 2,
        }
    }
}

/// An array in global memory: element `i` is at `base + i * element bytes`. An input
/// element's value is the symbol for element `i` of `name`; output elements start
/// unwritten, and the kernel can load only the ones its workgroup has stored.
#[derive(Debug, Clone)]
pub struct ArrayDef {
    pub name: String,
    pub base: u64,
    pub len: u64,
    pub kind: ArrayKind,
    pub element: Element,
}

/// An array whose name is interned in the interpreter's arena.
#[derive(Debug)]
struct Region {
    name: StringId,
    base: u64,
    len: u64,
    kind: ArrayKind,
    element: Element,
}

impl Region {
    /// The index of the first element of the word at `address`, if the word lies in the array.
    /// A bf16 word may start at any element: ROCm runs gfx9 queues in unaligned access mode.
    fn element_at(&self, address: u64) -> Option<u64> {
        let offset = address.checked_sub(self.base)?;
        if !offset.is_multiple_of(self.element.bytes()) {
            return None;
        }
        let index = offset / self.element.bytes();
        let elements_per_word = 4 / self.element.bytes();
        (index + elements_per_word <= self.len).then_some(index)
    }

    /// The index of the element that starts at `address`, if there is one.
    fn index_of_element(&self, address: u64) -> Option<u64> {
        let offset = address.checked_sub(self.base)?;
        let bytes = self.element.bytes();
        let index = offset / bytes;
        (offset.is_multiple_of(bytes) && index < self.len).then_some(index)
    }
}

/// The arrays of a launch, disjoint from each other and from the argument buffer.
#[derive(Debug)]
pub(super) struct GlobalMemory {
    regions: Vec<Region>,
    /// The argument buffer's address and bytes: read-only device memory that vector loads may
    /// also read, as OpenCL's `get_local_size` reads a group size it selects at run time.
    kernarg: (u64, Vec<u8>),
    /// Each workgroup's written output elements by address; a selected workgroup's run has one.
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
            if array.element == Element::Bf16 && array.kind == ArrayKind::Output(OutputType::U32) {
                let label = array_label(array);
                return Err(launch_error(format!(
                    "{label} holds bf16 reals, not u32 words"
                )));
            }
            if let ArrayKind::Integers(words) = &array.kind
                && (array.element != Element::Word || words.len() as u64 != array.len)
            {
                let label = array_label(array);
                return Err(launch_error(format!(
                    "{label} needs exactly one 32-bit word per element"
                )));
            }
            ranges.push(array_range(array)?);
        }
        check_disjoint(&ranges)?;

        let mut regions = Vec::new();
        for array in arrays {
            regions.push(Region {
                name: arena.intern_string(array.name.clone()),
                base: array.base,
                len: array.len,
                kind: array.kind.clone(),
                element: array.element,
            });
        }
        Ok(Self {
            regions,
            kernarg: (kernarg.address, kernarg.bytes.to_vec()),
            written: vec![BTreeMap::new(); workgroups],
            selected: None,
        })
    }

    /// The input word at `address`: its element's symbol, or the two symbols of a bf16 array.
    pub fn load_dword(&self, address: u64, arena: &mut ExprArena) -> Result<Word, EvalError> {
        for region in &self.regions {
            let Some(index) = region.element_at(address) else {
                continue;
            };
            if let ArrayKind::Integers(words) = &region.kind {
                return Ok(Word::Value(arena.int(i64::from(words[index as usize]))));
            }
            if region.kind == ArrayKind::Input {
                return Ok(match region.element {
                    Element::Word => Word::Value(arena.input_element(region.name, index)),
                    Element::Bf16 => Word::Bf16 {
                        low: arena.input_element(region.name, index),
                        high: arena.input_element(region.name, index + 1),
                    },
                });
            }
        }
        if let Some(word) = self.load_kernarg(address) {
            return Ok(Word::Value(arena.int(i64::from(word))));
        }
        self.load_written(address)
            .ok_or(EvalError::GlobalRead { address })
    }

    /// The argument word at `address`, if all four of its bytes are in the argument buffer.
    fn load_kernarg(&self, address: u64) -> Option<u32> {
        let (base, bytes) = &self.kernarg;
        let start = usize::try_from(address.checked_sub(*base)?).ok()?;
        let word = bytes.get(start..start.checked_add(4)?)?;
        Some(u32::from_le_bytes(word.try_into().expect("four bytes")))
    }

    /// An output word this workgroup has already stored in full, read back as it was stored.
    fn load_written(&self, address: u64) -> Option<Word> {
        let region = self.regions.iter().find(|region| {
            matches!(region.kind, ArrayKind::Output(_)) && region.element_at(address).is_some()
        })?;
        let written = self.written.get(self.selected.unwrap_or(0))?;
        Some(match region.element {
            Element::Word => Word::Value(*written.get(&address)?),
            Element::Bf16 => Word::Bf16 {
                low: *written.get(&address)?,
                high: *written.get(&(address + 2))?,
            },
        })
    }

    /// Record one element of a bf16 output at the 2-byte aligned `address`.
    pub fn store_bf16(&mut self, address: u64, value: ExprId) -> Result<(), EvalError> {
        let is_bf16_output = |region: &&Region| {
            matches!(region.kind, ArrayKind::Output(_)) && region.element == Element::Bf16
        };
        self.regions
            .iter()
            .filter(is_bf16_output)
            .find_map(|region| region.index_of_element(address))
            .ok_or(EvalError::GlobalWrite { address })?;
        let workgroups = match self.selected {
            Some(workgroup) => workgroup..workgroup + 1,
            None => 0..self.written.len(),
        };
        for workgroup in workgroups {
            if let Some(written) = self.written.get_mut(workgroup) {
                written.insert(address, value);
            }
        }
        Ok(())
    }

    /// Interpret a stored word according to the output's elements and record their
    /// mathematical values. Output elements cannot be loaded; a later store replaces them.
    pub fn store_dword(
        &mut self,
        address: u64,
        word: Word,
        arena: &mut ExprArena,
    ) -> Result<(), EvalError> {
        let (element, output_type) = self
            .regions
            .iter()
            .find_map(|region| match region.kind {
                ArrayKind::Output(ty) if region.element_at(address).is_some() => {
                    Some((region.element, ty))
                }
                _ => None,
            })
            .ok_or(EvalError::GlobalWrite { address })?;

        // Decode float constants without changing real expressions; integer outputs need known bits.
        let elements = match (element, word) {
            (Element::Bf16, word) => {
                let [low, high] = word
                    .bf16_halves(arena)
                    .ok_or(EvalError::InvalidBf16Output { address })?;
                vec![(address, low), (address + 2, high)]
            }
            (Element::Word, word) => {
                let value = word
                    .value(arena)
                    .ok_or(EvalError::InvalidFloatOutput { address })?;
                let value = match output_type {
                    OutputType::F32 => {
                        as_f32(arena, value).ok_or(EvalError::InvalidFloatOutput { address })?
                    }
                    OutputType::U32 => {
                        concrete_word(arena, value)
                            .ok_or(EvalError::InvalidIntegerOutput { address })?;
                        value
                    }
                };
                vec![(address, value)]
            }
        };
        let workgroups = match self.selected {
            Some(workgroup) => workgroup..workgroup + 1,
            None => 0..self.written.len(),
        };
        for workgroup in workgroups {
            if let Some(written) = self.written.get_mut(workgroup) {
                written.extend(elements.iter().copied());
            }
        }
        Ok(())
    }

    /// Apply later stores to `workgroup` only, or to every workgroup for `None`.
    pub fn select(&mut self, workgroup: Option<usize>) {
        self.selected = workgroup;
    }

    /// Export the first workgroup's output arrays with only their written elements.
    pub fn into_outputs(self, arena: ExprArena) -> FullOutputs {
        let outputs = match self.written.first() {
            Some(written) => self.outputs_of(written, &arena),
            None => Vec::new(),
        };
        FullOutputs { arena, outputs }
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
                    if let Some(index) = region.index_of_element(address) {
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
                        region.index_of_element(address).map(|index| (index, value))
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
    let end = match array.len.checked_mul(array.element.bytes()) {
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
