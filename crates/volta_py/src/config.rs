//! Python-facing mirror of `volta_analysis::eval::config`. These wrap the
//! Rust types 1:1 rather than round-tripping through the CLI's flat
//! string mini-DSL (`"in:0x10000:4:128:in"`) - that format exists only
//! because clap needs flat string args; Python has real constructors.

use pyo3::prelude::*;

use volta_analysis::eval::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};

#[pyclass(name = "ArrayKind", eq, eq_int, from_py_object)]
#[derive(Clone, Copy, PartialEq, Eq)]
pub enum ArrayKindPy {
    Input,
    Output,
    InputOutput,
    IndexInput,
}

impl From<ArrayKindPy> for ArrayKind {
    fn from(kind: ArrayKindPy) -> Self {
        match kind {
            ArrayKindPy::Input => ArrayKind::Input,
            ArrayKindPy::Output => ArrayKind::Output,
            ArrayKindPy::InputOutput => ArrayKind::InputOutput,
            ArrayKindPy::IndexInput => ArrayKind::IndexInput,
        }
    }
}

/// A value bound to a kernel parameter. Built via the static constructors
/// (`Param.int(5)`, `Param.array_ptr("A")`, ...) rather than exposed as a
/// Python-visible tagged union.
#[pyclass(name = "Param", from_py_object)]
#[derive(Clone)]
pub struct ParamPy(pub(crate) ParamValue);

#[pymethods]
impl ParamPy {
    #[staticmethod]
    fn int(value: i64) -> Self {
        ParamPy(ParamValue::Int(value))
    }

    #[staticmethod]
    fn float(value: f64) -> Self {
        ParamPy(ParamValue::Float(value))
    }

    #[staticmethod]
    fn sym_float(name: String) -> Self {
        ParamPy(ParamValue::SymFloat(name))
    }

    #[staticmethod]
    fn array_ptr(name: String) -> Self {
        ParamPy(ParamValue::ArrayPtr(name))
    }

    fn __repr__(&self) -> String {
        format!("{:?}", self.0)
    }
}

#[pyclass(name = "ArrayDef", from_py_object)]
#[derive(Clone)]
pub struct ArrayDefPy(pub(crate) ArrayDef);

#[pymethods]
impl ArrayDefPy {
    #[new]
    fn new(name: String, base: u64, elem_width: u64, len: u64, kind: ArrayKindPy) -> Self {
        ArrayDefPy(ArrayDef {
            name,
            base,
            elem_width,
            len,
            kind: kind.into(),
        })
    }

    fn __repr__(&self) -> String {
        format!("{:?}", self.0)
    }
}

/// Full launch/memory configuration for analyzing one kernel; mirrors
/// `AnalysisConfig` field-for-field.
#[pyclass(name = "Config", from_py_object)]
#[derive(Clone)]
pub struct ConfigPy(pub(crate) AnalysisConfig);

#[pymethods]
impl ConfigPy {
    #[new]
    #[pyo3(signature = (block, grid=(1, 1, 1), dynamic_shared_bytes=0, max_instructions=2_000_000_000))]
    fn new(
        block: (u32, u32, u32),
        grid: (u32, u32, u32),
        dynamic_shared_bytes: u64,
        max_instructions: u64,
    ) -> Self {
        let mut config = AnalysisConfig::new(block);
        config.grid_dim = grid;
        config.dynamic_shared_bytes = dynamic_shared_bytes;
        config.max_instructions = max_instructions;
        ConfigPy(config)
    }

    /// Declare a global-memory array visible to the kernel.
    fn add_array(&mut self, array: ArrayDefPy) {
        self.0.arrays.push(array.0);
    }

    /// Bind the next kernel parameter (in declaration order).
    fn add_param(&mut self, param: ParamPy) {
        self.0.params.push(param.0);
    }

    /// Set a module-scope `.global` variable's concrete value.
    fn set_global(&mut self, name: String, value: i64) {
        self.0.global_values.push((name, value));
    }

    fn __repr__(&self) -> String {
        format!("{:?}", self.0)
    }
}
