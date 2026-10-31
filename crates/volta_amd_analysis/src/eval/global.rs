//! Global memory: the launch's input arrays, which vector loads read.

use volta_expr::{ExprArena, ExprId, StringId};

use super::EvalError;
use super::scalar::KernargBuffer;

/// An input array of 32-bit words in global memory: element `i` is at `base + 4i`, and its
/// value is the symbol for element `i` of `name`.
#[derive(Debug, Clone)]
pub struct InputArray {
    pub name: String,
    pub base: u64,
    pub len: u64,
}

/// An input array whose name is interned in the interpreter's arena.
#[derive(Debug)]
struct Region {
    name: StringId,
    base: u64,
    len: u64,
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

/// The input arrays of a launch, disjoint from each other and from the argument buffer.
#[derive(Debug, Default)]
pub(super) struct GlobalMemory {
    regions: Vec<Region>,
}

impl GlobalMemory {
    /// Validate `arrays` and intern their names in `arena`.
    pub fn new(
        arrays: &[InputArray],
        kernarg: &KernargBuffer,
        arena: &mut ExprArena,
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
            });
        }
        Ok(Self { regions })
    }

    /// The symbol of the input element whose four bytes start at `address`.
    pub fn load_dword(&self, address: u64, arena: &mut ExprArena) -> Result<ExprId, EvalError> {
        for region in &self.regions {
            if let Some(index) = region.element_at(address) {
                return Ok(arena.input_element(region.name, index));
            }
        }
        Err(EvalError::GlobalRead { address })
    }
}

/// The bytes `start..end` of the argument buffer or of an input array, labeled for errors.
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

fn array_range(array: &InputArray) -> Result<ByteRange, EvalError> {
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

fn check_unique_names(arrays: &[InputArray]) -> Result<(), EvalError> {
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

fn array_label(array: &InputArray) -> String {
    format!("input array {:?}", array.name)
}

fn launch_error(message: String) -> EvalError {
    EvalError::Launch { message }
}
