//! The JSON launch file: one kernel launch, written to be read by people
//! (`volta analyze --config FILE`).
//!
//! ```json
//! {
//!   "description": "out = x + y over 16 fp32 elements",
//!   "kernel": "add_kernel",
//!   "block": 128,
//!   "grid": [4, 1, 1],
//!   "dynamic_shared_bytes": 0,
//!   "arrays": [
//!     {"name": "x",   "kind": "in",  "dtype": "f32", "shape": [16]},
//!     {"name": "out", "kind": "out", "dtype": "f32", "shape": [16], "base": "0x20000"}
//!   ],
//!   "params": [
//!     {"ptr": "x"},
//!     {"ptr": "out"},
//!     {"name": "n_elements", "int": 16},
//!     {"name": "args", "struct": [
//!       {"name": "x", "offset": 0, "ptr": "x"},
//!       {"name": "n", "offset": 8, "u32": 16}
//!     ]}
//!   ],
//!   "globals": {"NUM_ITERS": 4}
//! }
//! ```
//!
//! Only `block` is required. `block` and `grid` are a number or one to
//! three numbers (missing ones are 1). An array's `kind` is `in`, `out`,
//! `inout` or `index`; its element size is a `dtype` (`f32`, `bf16`, `u8`,
//! `e4m3`, ...) or an `elem_width` in bytes, its length a `shape` or a
//! `len`. Arrays without a `base` (a number or a `"0x..."` string) are laid
//! out in order from `0x10000`, each starting on the first 64 KiB
//! boundary after the previous array. A parameter is exactly one of `int`,
//! `float`, `sym` (a symbolic float), `ptr` (an array's base) or `struct` (a
//! by-value struct, `.param .b8 name[N]`), bound in declaration order; its
//! optional `name` is a label for the reader, not checked against the PTX
//! (whose names are often mangled). A struct field is an `offset` in bytes and
//! exactly one of `ptr`, an integer type (`u32`, `i64`, `b16`, ...) holding
//! its value, or `tensor_map`: a host-encoded TMA descriptor (128 bytes), given
//! by its fields since its encoding is opaque: `array`, `dtype`, `dims`
//! (innermost first), `strides` (bytes, all dims but the innermost), exactly
//! one of `box` (a tiled map) and `im2col` (an im2col map: `lower_corner` and
//! `upper_corner`, one offset per spatial dim innermost first, then
//! `channels_per_pixel` and `pixels_per_column`), and optionally
//! `element_strides` (1s), `swizzle` (`none`, `32B`, `64B`, `128B`),
//! `swizzle_atomicity` (`16B`), `interleave` (`none`) and `fill` (`zero`). Bytes
//! no field gives read as undefined. Unknown keys are errors, so a typo cannot
//! silently fall back to a default.

use std::collections::BTreeMap;

use serde::Deserialize;
use serde_json::Value;

use crate::config::{
    AnalysisConfig, ArrayDef, ArrayKind, FieldValue, IntWidth, ParamValue, StructField,
    TensorMapMode, TensorMapValue,
};
use crate::ir::tensor_map::{
    Im2colBox, TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorSwizzleAtomicity,
    TensorSwizzleMode,
};

/// Where the first array without a `base` starts, and the alignment of every such array.
const ARRAY_ALIGN: u64 = 0x10000;

/// A parsed launch file: the kernel it names (if any) and its configuration.
#[derive(Debug, Clone)]
pub struct LaunchFile {
    pub kernel: Option<String>,
    pub config: AnalysisConfig,
}

impl LaunchFile {
    /// Parse and validate a launch file (see the module docs for the format).
    pub fn from_json(text: &str) -> Result<Self, String> {
        let raw: RawLaunch = serde_json::from_str(text).map_err(|e| e.to_string())?;

        let mut config = AnalysisConfig::new(raw.block.resolve("block")?);

        if let Some(grid) = raw.grid {
            config.grid_dim = grid.resolve("grid")?;
        }

        config.dynamic_shared_bytes = raw.dynamic_shared_bytes;

        if let Some(max) = raw.max_instructions {
            config.max_instructions = max;
        }

        config.arrays = lay_out_arrays(raw.arrays)?;

        for (position, param) in raw.params.into_iter().enumerate() {
            let param = param
                .resolve()
                .map_err(|e| format!("parameter {position}: {e}"))?;

            config.params.push(param);
        }

        config.global_values = raw.globals.into_iter().collect();

        config.validate()?;

        Ok(LaunchFile {
            kernel: raw.kernel,
            config,
        })
    }
}

/// An array without a `base` starts at the first `ARRAY_ALIGN` boundary past
/// every array before it.
fn lay_out_arrays(raw_arrays: Vec<RawArray>) -> Result<Vec<ArrayDef>, String> {
    let mut arrays = Vec::new();
    let mut next_base = ARRAY_ALIGN;

    for raw in raw_arrays {
        let name = raw.name.clone();

        let array = raw
            .resolve(next_base)
            .map_err(|e| format!("array '{name}': {e}"))?;

        let end = array.base.saturating_add(array.size_bytes());
        next_base = next_base.max(align_up(end));

        arrays.push(array);
    }

    Ok(arrays)
}

fn align_up(address: u64) -> u64 {
    address.div_ceil(ARRAY_ALIGN).saturating_mul(ARRAY_ALIGN)
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RawLaunch {
    #[serde(rename = "description")]
    _description: Option<String>,
    kernel: Option<String>,
    block: RawDims,
    grid: Option<RawDims>,
    #[serde(default)]
    dynamic_shared_bytes: u64,
    max_instructions: Option<u64>,
    #[serde(default)]
    arrays: Vec<RawArray>,
    #[serde(default)]
    params: Vec<RawParam>,
    #[serde(default)]
    globals: BTreeMap<String, i64>,
}

#[derive(Deserialize)]
#[serde(untagged)]
enum RawDims {
    One(u32),
    Many(Vec<u32>),
}

impl RawDims {
    fn resolve(self, field: &str) -> Result<(u32, u32, u32), String> {
        let dims = match self {
            RawDims::One(x) => vec![x],
            RawDims::Many(dims) => dims,
        };

        match dims[..] {
            [x] => Ok((x, 1, 1)),
            [x, y] => Ok((x, y, 1)),
            [x, y, z] => Ok((x, y, z)),
            _ => Err(format!(
                "`{field}` takes one to three numbers, got {}",
                dims.len()
            )),
        }
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RawArray {
    name: String,
    kind: RawKind,
    dtype: Option<String>,
    elem_width: Option<u64>,
    shape: Option<Vec<u64>>,
    len: Option<u64>,
    base: Option<RawAddress>,
}

impl RawArray {
    fn resolve(self, default_base: u64) -> Result<ArrayDef, String> {
        let elem_width = match (self.dtype, self.elem_width) {
            (Some(dtype), None) => {
                dtype_width(&dtype).ok_or_else(|| format!("unknown dtype '{dtype}'"))?
            }
            (None, Some(width)) => width,
            _ => return Err("give exactly one of `dtype` and `elem_width`".into()),
        };

        let len = match (self.shape, self.len) {
            (Some(shape), None) => element_count(&shape)?,
            (None, Some(len)) => len,
            _ => return Err("give exactly one of `shape` and `len`".into()),
        };

        let base = match self.base {
            Some(base) => base.resolve()?,
            None => default_base,
        };

        Ok(ArrayDef {
            name: self.name,
            base,
            elem_width,
            len,
            kind: self.kind.into(),
        })
    }
}

fn element_count(shape: &[u64]) -> Result<u64, String> {
    let mut count: u64 = 1;

    for &dim in shape {
        count = count
            .checked_mul(dim)
            .ok_or("`shape` has more elements than fit in u64")?;
    }

    Ok(count)
}

#[derive(Deserialize)]
#[serde(rename_all = "lowercase")]
enum RawKind {
    In,
    Out,
    Inout,
    Index,
}

impl From<RawKind> for ArrayKind {
    fn from(kind: RawKind) -> Self {
        match kind {
            RawKind::In => ArrayKind::Input,
            RawKind::Out => ArrayKind::Output,
            RawKind::Inout => ArrayKind::InputOutput,
            RawKind::Index => ArrayKind::IndexInput,
        }
    }
}

#[derive(Deserialize)]
#[serde(untagged)]
enum RawAddress {
    Number(u64),
    Text(String),
}

impl RawAddress {
    fn resolve(self) -> Result<u64, String> {
        match self {
            RawAddress::Number(address) => Ok(address),
            RawAddress::Text(text) => text
                .strip_prefix("0x")
                .and_then(|hex| u64::from_str_radix(hex, 16).ok())
                .ok_or_else(|| format!("`base` '{text}' is not a 0x-prefixed hex number")),
        }
    }
}

/// Bytes per element of a PTX (`f32`, `b16`), Triton (`fp32`) or fp8 (`e4m3`) type name.
fn dtype_width(dtype: &str) -> Option<u64> {
    match dtype {
        "b8" | "s8" | "u8" | "i8" | "e4m3" | "e5m2" | "fp8" => Some(1),
        "b16" | "s16" | "u16" | "i16" | "f16" | "fp16" | "bf16" => Some(2),
        "b32" | "s32" | "u32" | "i32" | "f32" | "fp32" | "tf32" => Some(4),
        "b64" | "s64" | "u64" | "i64" | "f64" | "fp64" => Some(8),
        _ => None,
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RawParam {
    #[serde(rename = "name")]
    _name: Option<String>,
    int: Option<i64>,
    float: Option<f64>,
    sym: Option<String>,
    ptr: Option<String>,
    #[serde(rename = "struct")]
    fields: Option<Vec<RawField>>,
}

impl RawParam {
    fn resolve(self) -> Result<ParamValue, String> {
        match (self.int, self.float, self.sym, self.ptr, self.fields) {
            (Some(value), None, None, None, None) => Ok(ParamValue::Int(value)),
            (None, Some(value), None, None, None) => Ok(ParamValue::Float(value)),
            (None, None, Some(name), None, None) => Ok(ParamValue::SymFloat(name)),
            (None, None, None, Some(array), None) => Ok(ParamValue::ArrayPtr(array)),
            (None, None, None, None, Some(raw_fields)) => {
                let mut fields = Vec::new();

                for field in raw_fields {
                    fields.push(field.resolve()?);
                }

                Ok(ParamValue::Struct(fields))
            }
            _ => Err("give exactly one of `int`, `float`, `sym`, `ptr` and `struct`".into()),
        }
    }
}

/// A struct field, `{"offset": N, "<type>": value}`: read by hand, since its value's key is its type.
#[derive(Deserialize)]
#[serde(transparent)]
struct RawField(serde_json::Map<String, Value>);

impl RawField {
    fn resolve(self) -> Result<StructField, String> {
        let mut entries = self.0;
        entries.remove("name");

        let offset = entries
            .remove("offset")
            .and_then(|offset| offset.as_u64())
            .ok_or("a struct field needs an `offset` in bytes")?;

        let mut rest = entries.into_iter();
        let (Some((key, value)), None) = (rest.next(), rest.next()) else {
            return Err(format!(
                "the struct field at byte {offset} needs exactly one of `ptr` or an integer type \
                 (`u32`, `i64`, ...) beside its `offset` and `name`"
            ));
        };

        let value = match key.as_str() {
            "ptr" => array_ptr_field(value),
            "tensor_map" => tensor_map_field(value),
            int_type => int_field(int_type, value),
        };

        let value = value.map_err(|e| format!("the struct field at byte {offset}: {e}"))?;

        Ok(StructField { offset, value })
    }
}

fn array_ptr_field(value: Value) -> Result<FieldValue, String> {
    match value {
        Value::String(array) => Ok(FieldValue::ArrayPtr(array)),
        _ => Err("`ptr` names no array".into()),
    }
}

fn tensor_map_field(value: Value) -> Result<FieldValue, String> {
    let map: RawTensorMap =
        serde_json::from_value(value).map_err(|e| format!("tensor map: {e}"))?;

    let map = map.resolve().map_err(|e| format!("tensor map: {e}"))?;

    Ok(FieldValue::TensorMap(Box::new(map)))
}

fn int_field(int_type: &str, value: Value) -> Result<FieldValue, String> {
    let width =
        int_width(int_type).ok_or_else(|| format!("unknown struct field key `{int_type}`"))?;

    // A u64 above i64::MAX is kept as its bits.
    let bits = value
        .as_i64()
        .or_else(|| value.as_u64().map(|unsigned| unsigned as i64))
        .ok_or_else(|| format!("`{int_type}` is no integer"))?;

    Ok(FieldValue::Int { value: bits, width })
}

/// The width of a PTX (`u32`, `b16`, `s8`) or Triton (`i64`) integer type name.
fn int_width(dtype: &str) -> Option<IntWidth> {
    match dtype {
        "b8" | "s8" | "u8" | "i8" => Some(IntWidth::W1),
        "b16" | "s16" | "u16" | "i16" => Some(IntWidth::W2),
        "b32" | "s32" | "u32" | "i32" => Some(IntWidth::W4),
        "b64" | "s64" | "u64" | "i64" => Some(IntWidth::W8),
        _ => None,
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RawTensorMap {
    array: String,
    dtype: String,
    dims: Vec<u64>,
    strides: Vec<u64>,
    #[serde(rename = "box")]
    box_dims: Option<Vec<u32>>,
    im2col: Option<RawIm2col>,
    element_strides: Option<Vec<u32>>,
    swizzle: Option<String>,
    swizzle_atomicity: Option<String>,
    interleave: Option<String>,
    fill: Option<String>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RawIm2col {
    lower_corner: Vec<i32>,
    upper_corner: Vec<i32>,
    channels_per_pixel: u32,
    pixels_per_column: u32,
}

const SWIZZLE_MODES: &[(&str, TensorSwizzleMode)] = &[
    ("none", TensorSwizzleMode::None),
    ("32B", TensorSwizzleMode::Swizzle32B),
    ("64B", TensorSwizzleMode::Swizzle64B),
    ("128B", TensorSwizzleMode::Swizzle128B),
    ("96B", TensorSwizzleMode::Swizzle96B),
];

const SWIZZLE_ATOMICITIES: &[(&str, TensorSwizzleAtomicity)] = &[
    ("16B", TensorSwizzleAtomicity::Atomicity16B),
    ("32B", TensorSwizzleAtomicity::Atomicity32B),
    (
        "32B_flip_8B",
        TensorSwizzleAtomicity::Atomicity32BWith8BFlip,
    ),
    ("64B", TensorSwizzleAtomicity::Atomicity64B),
];

const INTERLEAVE_LAYOUTS: &[(&str, TensorInterleaveLayout)] = &[
    ("none", TensorInterleaveLayout::None),
    ("16B", TensorInterleaveLayout::Interleave16B),
    ("32B", TensorInterleaveLayout::Interleave32B),
];

const FILL_MODES: &[(&str, TensorFillMode)] = &[
    ("zero", TensorFillMode::Zero),
    ("nan", TensorFillMode::OobNan),
];

impl RawTensorMap {
    fn resolve(self) -> Result<TensorMapValue, String> {
        let elemtype = tensor_elem_type(&self.dtype)?;

        let swizzle = choose("swizzle", self.swizzle, SWIZZLE_MODES)?;

        let swizzle_atomicity = choose(
            "swizzle_atomicity",
            self.swizzle_atomicity,
            SWIZZLE_ATOMICITIES,
        )?;

        let interleave = choose("interleave", self.interleave, INTERLEAVE_LAYOUTS)?;

        let fill = choose("fill", self.fill, FILL_MODES)?;

        let element_strides = self
            .element_strides
            .unwrap_or_else(|| vec![1; self.dims.len()]);

        let mode = match (self.box_dims, self.im2col) {
            (Some(box_dims), None) => TensorMapMode::Tiled { box_dims },
            (None, Some(im2col)) => TensorMapMode::Im2col(Im2colBox {
                lower_corner: im2col.lower_corner,
                upper_corner: im2col.upper_corner,
                channels_per_pixel: im2col.channels_per_pixel,
                pixels_per_column: im2col.pixels_per_column,
            }),
            _ => return Err("give exactly one of `box` and `im2col`".into()),
        };

        Ok(TensorMapValue {
            array: self.array,
            elemtype,
            dims: self.dims,
            strides: self.strides,
            mode,
            element_strides,
            interleave,
            swizzle,
            swizzle_atomicity,
            fill,
        })
    }
}

/// The value `choices` gives the name `given`; an absent name picks the first choice.
fn choose<T: Copy>(field: &str, given: Option<String>, choices: &[(&str, T)]) -> Result<T, String> {
    let Some(given) = given else {
        return Ok(choices[0].1);
    };

    for &(name, value) in choices {
        if name == given {
            return Ok(value);
        }
    }

    let names: Vec<&str> = choices.iter().map(|(name, _)| *name).collect();

    Err(format!(
        "`{field}` is one of {}, not `{given}`",
        names.join(", ")
    ))
}

fn tensor_elem_type(dtype: &str) -> Result<TensorElemType, String> {
    match dtype {
        "u8" => Ok(TensorElemType::U8),
        "u16" => Ok(TensorElemType::U16),
        "u32" => Ok(TensorElemType::U32),
        "s32" | "i32" => Ok(TensorElemType::S32),
        "u64" => Ok(TensorElemType::U64),
        "s64" | "i64" => Ok(TensorElemType::S64),
        "f16" => Ok(TensorElemType::F16),
        "f32" => Ok(TensorElemType::F32),
        "f32_ftz" => Ok(TensorElemType::F32Ftz),
        "f64" => Ok(TensorElemType::F64),
        "bf16" => Ok(TensorElemType::Bf16),
        "tf32" => Ok(TensorElemType::Tf32),
        _ => Err(format!("unknown tensor-map dtype `{dtype}`")),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reads_the_documented_example() {
        let launch = LaunchFile::from_json(
            r#"{
                "description": "out = x + y",
                "kernel": "add_kernel",
                "block": 128,
                "grid": [4],
                "arrays": [
                    {"name": "x", "kind": "in", "dtype": "f32", "shape": [4, 4]},
                    {"name": "big", "kind": "in", "elem_width": 2, "len": 40000},
                    {"name": "out", "kind": "out", "dtype": "f32", "len": 16, "base": "0x100000"}
                ],
                "params": [{"ptr": "x"}, {"name": "n", "int": 16}, {"float": 0.5}, {"sym": "alpha"}],
                "globals": {"G": 3}
            }"#,
        )
        .unwrap();

        assert_eq!(launch.kernel.as_deref(), Some("add_kernel"));

        let config = &launch.config;

        assert_eq!(
            (config.block_dim, config.grid_dim),
            ((128, 1, 1), (4, 1, 1))
        );

        let layout: Vec<_> = config
            .arrays
            .iter()
            .map(|a| (a.name.as_str(), a.base, a.elem_width, a.len))
            .collect();

        assert_eq!(
            layout,
            [
                ("x", 0x10000, 4, 16),
                ("big", 0x20000, 2, 40000),
                ("out", 0x100000, 4, 16)
            ]
        );

        assert!(matches!(
            config.params[..],
            [
                ParamValue::ArrayPtr(_),
                ParamValue::Int(16),
                ParamValue::Float(_),
                ParamValue::SymFloat(_),
            ]
        ));

        assert_eq!(config.global_values, [("G".to_string(), 3)]);
    }

    #[test]
    fn reads_a_struct_parameter() {
        let launch = LaunchFile::from_json(
            r#"{"block": 1, "arrays": [{"name": "a", "kind": "in", "dtype": "f32", "len": 4}],
                "params": [{"name": "g", "struct": [
                    {"name": "a.ptr", "offset": 0, "ptr": "a"},
                    {"offset": 8, "u64": 18446744073709551615},
                    {"offset": 16, "i32": -4}
                ]}]}"#,
        )
        .unwrap();

        let ParamValue::Struct(fields) = &launch.config.params[0] else {
            panic!("not a struct: {:?}", launch.config.params[0]);
        };

        assert!(matches!(&fields[0].value, FieldValue::ArrayPtr(a) if a == "a"));

        assert!(matches!(
            fields[1].value,
            FieldValue::Int {
                value: -1,
                width: IntWidth::W8
            }
        ));

        assert!(matches!(
            fields[2].value,
            FieldValue::Int {
                value: -4,
                width: IntWidth::W4
            }
        ));

        let error = |text: &str| LaunchFile::from_json(text).unwrap_err();

        assert!(
            error(r#"{"block": 1, "params": [{"struct": [{"offset": 0, "u33": 1}]}]}"#)
                .contains("unknown struct field key `u33`")
        );

        assert!(
            error(r#"{"block": 1, "params": [{"struct": [{"offset": 0, "u8": 1, "u16": 1}]}]}"#)
                .contains("needs exactly one of `ptr` or an integer type")
        );

        assert!(
            error(r#"{"block": 1, "params": [{"struct": [{"offset": 0, "u8": 256}]}]}"#)
                .contains("does not fit in 1 bytes")
        );
    }

    #[test]
    fn reads_a_tensor_map_field() {
        let launch = LaunchFile::from_json(
            r#"{"block": 1, "arrays": [{"name": "a", "kind": "in", "dtype": "bf16", "len": 4096}],
                "params": [{"struct": [{"offset": 64, "tensor_map": {
                    "array": "a", "dtype": "bf16", "dims": [64, 64], "strides": [128],
                    "box": [64, 8], "swizzle": "128B"}}]}]}"#,
        )
        .unwrap();

        let ParamValue::Struct(fields) = &launch.config.params[0] else {
            panic!("not a struct");
        };

        let FieldValue::TensorMap(map) = &fields[0].value else {
            panic!("not a tensor map: {:?}", fields[0].value);
        };

        assert_eq!(
            (map.elemtype, map.swizzle),
            (TensorElemType::Bf16, TensorSwizzleMode::Swizzle128B)
        );

        assert_eq!(map.element_strides, [1, 1]);

        assert_eq!(map.fill, TensorFillMode::Zero);

        let error = LaunchFile::from_json(
            r#"{"block": 1, "params": [{"struct": [{"offset": 0, "tensor_map": {
                "array": "a", "dtype": "bf16", "dims": [8], "strides": [], "box": [8],
                "swizzle": "256B"}}]}]}"#,
        )
        .unwrap_err();

        assert!(
            error.contains("`swizzle` is one of none, 32B, 64B, 128B, 96B, not `256B`"),
            "{error}"
        );
    }

    #[test]
    fn reads_an_im2col_tensor_map_field() {
        let map = |shape: &str| {
            format!(
                r#"{{"block": 1, "arrays": [{{"name": "a", "kind": "in", "dtype": "f32", "len": 512}}],
                    "params": [{{"struct": [{{"offset": 0, "tensor_map": {{
                        "array": "a", "dtype": "f32", "dims": [32, 4, 4, 1],
                        "strides": [128, 512, 2048], {shape}}}}}]}}]}}"#
            )
        };
        let im2col = r#""im2col": {"lower_corner": [-1, 0], "upper_corner": [-1, -2],
                        "channels_per_pixel": 32, "pixels_per_column": 16}"#;

        let launch = LaunchFile::from_json(&map(im2col)).unwrap();

        let ParamValue::Struct(fields) = &launch.config.params[0] else {
            panic!("not a struct");
        };

        let FieldValue::TensorMap(tensor_map) = &fields[0].value else {
            panic!("not a tensor map: {:?}", fields[0].value);
        };

        assert_eq!(
            tensor_map.mode,
            TensorMapMode::Im2col(Im2colBox {
                lower_corner: vec![-1, 0],
                upper_corner: vec![-1, -2],
                channels_per_pixel: 32,
                pixels_per_column: 16,
            })
        );

        let error = |shape: &str| LaunchFile::from_json(&map(shape)).unwrap_err();

        let both = format!(r#""box": [32, 16], {im2col}"#);
        assert!(error(&both).contains("give exactly one of `box` and `im2col`"));

        assert!(error(r#""swizzle": "none""#).contains("give exactly one of `box` and `im2col`"));

        let far_corner = im2col.replace("[-1, -2]", "[-1, -200]");
        assert!(error(&far_corner).contains("corner offsets in -128..=127 for 4 dims, not -200"));
    }

    #[test]
    fn rejects_ambiguous_or_misspelled_entries() {
        let error = |text: &str| LaunchFile::from_json(text).unwrap_err();

        assert!(error(r#"{"block": 32, "grids": 2}"#).contains("unknown field `grids`"));

        assert!(
            error(r#"{"block": 32, "params": [{"int": 1, "float": 1.0}]}"#)
                .contains("parameter 0: give exactly one of")
        );

        assert!(error(
            r#"{"block": 32, "arrays": [{"name": "a", "kind": "in", "dtype": "f32", "elem_width": 4, "len": 1}]}"#
        )
        .contains("array 'a': give exactly one of `dtype` and `elem_width`"));

        assert!(error(r#"{"block": 32, "arrays": [{"name": "a", "kind": "in", "dtype": "f33", "len": 1}]}"#)
            .contains("unknown dtype 'f33'"));

        assert!(error(r#"{"block": [1, 2, 3, 4]}"#).contains("`block` takes one to three numbers"));
    }

    #[test]
    fn validates_the_resulting_config() {
        let overlapping = r#"{"block": 32, "arrays": [
            {"name": "a", "kind": "in", "dtype": "f32", "len": 64, "base": 65536},
            {"name": "b", "kind": "out", "dtype": "f32", "len": 64, "base": 65600}
        ]}"#;

        assert!(LaunchFile::from_json(overlapping).is_err());
    }
}
