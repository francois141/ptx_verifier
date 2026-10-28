//! Analysis configuration: launch dimensions, parameter values, and the
//! input/output arrays that define the kernel's memory interface.

use crate::ir::tensor_map::{
    TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorSwizzleAtomicity,
    TensorSwizzleMode,
};

/// Value bound to a kernel parameter, positional by `ParamId` order.
#[derive(Debug, Clone)]
pub enum ParamValue {
    /// Concrete integer (also used for raw pointer values)
    Int(i64),
    /// Concrete float
    Float(f64),
    /// Symbolic float input with the given name (e.g. "alpha")
    SymFloat(String),
    /// Pointer to a named array from `AnalysisConfig::arrays`
    ArrayPtr(String),
    /// A by-value struct (a `.param .b8 name[N]` aggregate) as the concrete
    /// bytes of its fields; the bytes no field covers read `Undefined`
    Struct(Vec<StructField>),
}

/// One field of a struct parameter, at a byte offset inside it.
#[derive(Debug, Clone)]
pub struct StructField {
    pub offset: u64,
    pub value: FieldValue,
}

#[derive(Debug, Clone)]
pub enum FieldValue {
    /// A little-endian integer; `value` holds its two's-complement bits, so a
    /// signed and an unsigned field of one width store alike
    Int { value: i64, width: IntWidth },
    /// The 8-byte base address of a named array from `AnalysisConfig::arrays`
    ArrayPtr(String),
    /// A 128-byte `CUtensorMap` (a TMA descriptor the host encoded), given
    /// by its fields since its bytes are opaque (PTX ISA 5.5.8)
    TensorMap(Box<TensorMapValue>),
}

/// The fields of a tensor map, as `tensormap.replace` names them (PTX ISA 9.7.9.27).
#[derive(Debug, Clone)]
pub struct TensorMapValue {
    /// The array whose base is the map's global address
    pub array: String,
    pub elemtype: TensorElemType,
    /// Each dimension's size in elements, innermost first
    pub dims: Vec<u64>,
    /// The byte stride of each dimension but the innermost
    pub strides: Vec<u64>,
    pub box_dims: Vec<u32>,
    pub element_strides: Vec<u32>,
    pub interleave: TensorInterleaveLayout,
    pub swizzle: TensorSwizzleMode,
    pub swizzle_atomicity: TensorSwizzleAtomicity,
    pub fill: TensorFillMode,
}

/// The size of a tensor-map object (`.b1024`).
pub const TENSOR_MAP_BYTES: u64 = 128;

impl FieldValue {
    pub fn width_bytes(&self) -> u64 {
        match self {
            FieldValue::Int { width, .. } => width.bytes(),
            FieldValue::ArrayPtr(_) => 8,
            FieldValue::TensorMap(_) => TENSOR_MAP_BYTES,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum IntWidth {
    W1,
    W2,
    W4,
    W8,
}

impl IntWidth {
    pub fn bytes(self) -> u64 {
        match self {
            IntWidth::W1 => 1,
            IntWidth::W2 => 2,
            IntWidth::W4 => 4,
            IntWidth::W8 => 8,
        }
    }

    /// Whether `value` is the bits of a signed or an unsigned integer of this width.
    pub fn holds(self, value: i64) -> bool {
        let bits = 8 * self.bytes();
        bits == 64 || (-(1i64 << (bits - 1))..(1i64 << bits)).contains(&value)
    }
}

/// Whether an array is a kernel input (pre-initialized with fresh symbols),
/// an output (extracted after execution), or both.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ArrayKind {
    Input,
    Output,
    InputOutput,
    /// An input of concrete integers where element i holds i, for index arrays
    /// feeding addresses (OpenMM's `posq[particles[i]]`): symbolic elements
    /// would make the addresses symbolic and violate structured-CTA.
    IndexInput,
}

impl ArrayKind {
    pub fn is_input(self) -> bool {
        matches!(self, Self::Input | Self::InputOutput | Self::IndexInput)
    }

    pub fn is_output(self) -> bool {
        matches!(self, Self::Output | Self::InputOutput)
    }
}

/// A global-memory array visible to the kernel. Inputs read as `name[i]`
/// symbols at `elem_width`. Must not overlap the module-global window
/// (`ir::symbols::MODULE_GLOBAL_BASE`); `Interpreter::new` rejects that.
#[derive(Debug, Clone)]
pub struct ArrayDef {
    pub name: String,
    pub base: u64,
    /// Element width in bytes (2 for f16, 4 for f32/int, 8 for f64)
    pub elem_width: u64,
    /// Number of elements
    pub len: u64,
    pub kind: ArrayKind,
}

impl ArrayDef {
    pub fn size_bytes(&self) -> u64 {
        self.elem_width * self.len
    }
}

/// Full configuration for analyzing one kernel.
#[derive(Debug, Clone)]
pub struct AnalysisConfig {
    /// Threads per block; the CTA under analysis is block (0,0,0)
    pub block_dim: (u32, u32, u32),
    /// Grid dimensions (only used for `%nctaid`)
    pub grid_dim: (u32, u32, u32),
    /// Parameter values in `ParamId` (declaration) order
    pub params: Vec<ParamValue>,
    /// Global-memory arrays
    pub arrays: Vec<ArrayDef>,
    /// Concrete values for module-scope `.global` variables, by PTX name
    pub global_values: Vec<(String, i64)>,
    /// Size of dynamic (extern) shared memory in bytes
    pub dynamic_shared_bytes: u64,
    /// Abort analysis after this many executed instructions
    pub max_instructions: u64,
}

impl AnalysisConfig {
    pub fn new(block_dim: (u32, u32, u32)) -> Self {
        Self {
            block_dim,
            grid_dim: (1, 1, 1),
            params: Vec::new(),
            arrays: Vec::new(),
            global_values: Vec::new(),
            dynamic_shared_bytes: 0,
            max_instructions: 2_000_000_000,
        }
    }

    pub fn num_threads(&self) -> u32 {
        self.block_dim.0 * self.block_dim.1 * self.block_dim.2
    }

    pub fn array(&self, name: &str) -> Option<&ArrayDef> {
        self.arrays.iter().find(|a| a.name == name)
    }

    /// Reject configs whose identities are ambiguous: duplicate array/`sym:`
    /// names or overlapping ranges would silently conflate distinct values.
    /// Overlap with the module-global window is checked in `Interpreter::new`.
    pub fn validate(&self) -> Result<(), String> {
        // Per-array checks first, so the pairwise pass below may safely
        // form `base + size_bytes()` for every array.
        for a in &self.arrays {
            if a.elem_width == 0 || a.len == 0 {
                return Err(format!(
                    "array '{}' has zero element width or length",
                    a.name
                ));
            }
            // The byte range must fit in u64 (checked, release-active): every
            // later use of `[base, base + size_bytes())` relies on the end
            // being representable.
            let end = a
                .elem_width
                .checked_mul(a.len)
                .and_then(|size| a.base.checked_add(size));
            if end.is_none() {
                return Err(format!(
                    "array '{}' (base {:#x}, {} elements of {} bytes) overflows the \
                     address space",
                    a.name, a.base, a.len, a.elem_width
                ));
            }
            // PTX requires naturally aligned accesses (ISA 6.4.1); a base that
            // is not a multiple of the element width misaligns every element.
            if a.base % a.elem_width != 0 {
                return Err(format!(
                    "array '{}' base address {:#x} is not a multiple of its element \
                     width {}; every element access would be misaligned (PTX requires \
                     naturally aligned accesses)",
                    a.name, a.base, a.elem_width
                ));
            }
        }
        for (i, a) in self.arrays.iter().enumerate() {
            for b in &self.arrays[i + 1..] {
                if a.name == b.name {
                    return Err(format!(
                        "two arrays share the name '{}'; array names are identities \
                         and must be unique",
                        a.name
                    ));
                }
                let (a_end, b_end) = (a.base + a.size_bytes(), b.base + b.size_bytes());
                if a.base < b_end && b.base < a_end {
                    return Err(format!(
                        "arrays '{}' and '{}' overlap in memory \
                         ([{:#x}, {:#x}) vs [{:#x}, {:#x}))",
                        a.name, b.name, a.base, a_end, b.base, b_end
                    ));
                }
            }
        }
        let mut sym_names = std::collections::BTreeSet::new();
        for (i, value) in self.params.iter().enumerate() {
            // NaN denotes no real number: it cannot enter the analysis
            // model (the infinities can - they are running-max/min seeds).
            if let ParamValue::Float(v) = value
                && v.is_nan()
            {
                return Err(format!(
                    "parameter {} is NaN; NaN is outside the analysis model (reals)",
                    i
                ));
            }
            if let ParamValue::Struct(fields) = value {
                validate_struct(i, fields)?;
            }
            if let ParamValue::SymFloat(name) = value {
                if name.is_empty() {
                    return Err("sym: parameter name is empty".to_string());
                }
                if name.contains('[') || name.contains(']') {
                    return Err(format!(
                        "sym: parameter name '{}' contains brackets; bracketed names \
                         are reserved for array elements",
                        name
                    ));
                }
                if !sym_names.insert(name) {
                    return Err(format!(
                        "two sym: parameters share the name '{}'; parameter names are \
                         identities and must be unique (a duplicate would silently \
                         constrain the check to inputs where both parameters are equal)",
                        name
                    ));
                }
            }
        }
        Ok(())
    }
}

/// A struct parameter's fields fit their widths and their byte ranges are disjoint.
fn validate_struct(param: usize, fields: &[StructField]) -> Result<(), String> {
    let mut ranges = Vec::new();
    for field in fields {
        if let FieldValue::Int { value, width } = field.value
            && !width.holds(value)
        {
            return Err(format!(
                "parameter {param}: the field at byte {} holds {value}, which does not fit in {} bytes",
                field.offset,
                width.bytes()
            ));
        }
        if let FieldValue::TensorMap(map) = &field.value {
            validate_tensor_map_field(param, field.offset, map)?;
        }
        let end = field
            .offset
            .checked_add(field.value.width_bytes())
            .ok_or_else(|| {
                format!(
                    "parameter {param}: the field at byte {} overflows",
                    field.offset
                )
            })?;
        ranges.push((field.offset, end));
    }
    ranges.sort();
    for pair in ranges.windows(2) {
        if pair[1].0 < pair[0].1 {
            return Err(format!(
                "parameter {param}: the fields at bytes {} and {} overlap",
                pair[0].0, pair[1].0
            ));
        }
    }
    Ok(())
}

fn validate_tensor_map_field(
    param: usize,
    offset: u64,
    map: &TensorMapValue,
) -> Result<(), String> {
    let rank = map.dims.len();
    let consistent = (1..=5).contains(&rank)
        && map.strides.len() + 1 == rank
        && map.box_dims.len() == rank
        && map.element_strides.len() == rank;
    if consistent {
        Ok(())
    } else {
        Err(format!(
            "parameter {param}: the tensor map at byte {offset} needs 1 to 5 dims, one stride \
             fewer, and as many box dims and element strides"
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn array(name: &str, base: u64, len: u64) -> ArrayDef {
        ArrayDef {
            name: name.to_string(),
            base,
            elem_width: 4,
            len,
            kind: ArrayKind::Input,
        }
    }

    #[test]
    fn validate_accepts_disjoint_arrays_and_plain_sym_names() {
        let mut config = AnalysisConfig::new((1, 1, 1));
        config.arrays.push(array("in", 0x1000, 16));
        config.arrays.push(array("out", 0x2000, 16));
        config
            .params
            .push(ParamValue::SymFloat("alpha".to_string()));
        assert_eq!(config.validate(), Ok(()));
    }

    /// Identity ambiguities are rejected: shared names would give unrelated
    /// storage the same `InputElement` symbols, and overlapping ranges would
    /// give one address two identities.
    #[test]
    fn validate_rejects_ambiguous_identities() {
        let mut dup = AnalysisConfig::new((1, 1, 1));
        dup.arrays.push(array("x", 0x1000, 16));
        dup.arrays.push(array("x", 0x2000, 16));
        assert!(dup.validate().is_err());

        let mut overlap = AnalysisConfig::new((1, 1, 1));
        overlap.arrays.push(array("a", 0x1000, 16));
        overlap.arrays.push(array("b", 0x1020, 16));
        assert!(overlap.validate().is_err());

        let mut bracketed = AnalysisConfig::new((1, 1, 1));
        bracketed
            .params
            .push(ParamValue::SymFloat("x[0]".to_string()));
        assert!(bracketed.validate().is_err());

        let mut dup_sym = AnalysisConfig::new((1, 1, 1));
        dup_sym
            .params
            .push(ParamValue::SymFloat("alpha".to_string()));
        dup_sym
            .params
            .push(ParamValue::SymFloat("alpha".to_string()));
        assert!(dup_sym.validate().is_err());
    }

    /// NaN float parameters are rejected at validation: NaN denotes no
    /// real number, so it has no place in the reals model. The infinities
    /// are fine (running-max/min seeds).
    #[test]
    fn validate_rejects_nan_float_param() {
        let mut nan = AnalysisConfig::new((1, 1, 1));
        nan.params.push(ParamValue::Float(f64::NAN));
        let err = nan.validate().unwrap_err();
        assert!(err.contains("NaN"), "unexpected message: {}", err);

        let mut inf = AnalysisConfig::new((1, 1, 1));
        inf.params.push(ParamValue::Float(f64::NEG_INFINITY));
        assert_eq!(inf.validate(), Ok(()));
    }

    #[test]
    fn validate_rejects_overlapping_or_overflowing_struct_fields() {
        let int = |offset, value, width| StructField {
            offset,
            value: FieldValue::Int { value, width },
        };
        let config = |fields| {
            let mut config = AnalysisConfig::new((1, 1, 1));
            config.params.push(ParamValue::Struct(fields));
            config.validate()
        };
        assert_eq!(
            config(vec![int(0, -1, IntWidth::W4), int(4, 255, IntWidth::W1)]),
            Ok(())
        );
        assert!(config(vec![int(0, 1, IntWidth::W8), int(4, 1, IntWidth::W4)]).is_err());
        assert!(config(vec![int(0, 256, IntWidth::W1)]).is_err());
    }

    /// A base that is not a multiple of the element width would make every
    /// element access misaligned (PTX ISA 6.4.1), so it is rejected once at
    /// config time rather than per access.
    #[test]
    fn validate_rejects_misaligned_array_base() {
        let mut misaligned = AnalysisConfig::new((1, 1, 1));
        misaligned.arrays.push(array("in", 2, 4));
        assert!(misaligned.validate().is_err());

        // The same base is fine for a 2-byte-element array: natural
        // alignment is relative to the element width, not any fixed size.
        let mut halves = AnalysisConfig::new((1, 1, 1));
        halves.arrays.push(ArrayDef {
            name: "in".to_string(),
            base: 2,
            elem_width: 2,
            len: 4,
            kind: ArrayKind::Input,
        });
        assert_eq!(halves.validate(), Ok(()));
    }
}
