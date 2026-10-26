//! Analysis configuration: launch dimensions, parameter values, and the
//! input/output arrays that define the kernel's memory interface.

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
