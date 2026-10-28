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
//! (innermost first), `strides` (bytes, all dims but the innermost), `box`, and
//! optionally `element_strides` (1s), `swizzle` (`none`, `32B`, `64B`, `128B`),
//! `swizzle_atomicity` (`16B`), `interleave` (`none`) and `fill` (`zero`). Bytes
//! no field gives read as undefined. Unknown keys are errors, so a typo cannot
//! silently fall back to a default.

use std::collections::BTreeMap;

use serde::Deserialize;

use crate::config::{
    AnalysisConfig, ArrayDef, ArrayKind, FieldValue, IntWidth, ParamValue, StructField,
    TensorMapValue,
};
use crate::ir::tensor_map::{
    TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorSwizzleAtomicity,
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
        let mut next_base = ARRAY_ALIGN;
        for array in raw.arrays {
            let array = array.resolve(next_base)?;
            next_base = next_base.max(align_up(array.base.saturating_add(array.size_bytes())));
            config.arrays.push(array);
        }
        for (position, param) in raw.params.into_iter().enumerate() {
            config.params.push(param.resolve(position)?);
        }
        config.global_values = raw.globals.into_iter().collect();
        config.validate()?;
        Ok(LaunchFile {
            kernel: raw.kernel,
            config,
        })
    }
}

fn align_up(address: u64) -> u64 {
    address.div_ceil(ARRAY_ALIGN).saturating_mul(ARRAY_ALIGN)
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RawLaunch {
    #[serde(default, rename = "description")]
    _description: Option<String>,
    #[serde(default)]
    kernel: Option<String>,
    block: RawDims,
    #[serde(default)]
    grid: Option<RawDims>,
    #[serde(default)]
    dynamic_shared_bytes: u64,
    #[serde(default)]
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
        match self {
            RawDims::One(x) => Ok((x, 1, 1)),
            RawDims::Many(dims) => match dims[..] {
                [x] => Ok((x, 1, 1)),
                [x, y] => Ok((x, y, 1)),
                [x, y, z] => Ok((x, y, z)),
                _ => Err(format!(
                    "`{field}` takes one to three numbers, got {}",
                    dims.len()
                )),
            },
        }
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct RawArray {
    name: String,
    kind: RawKind,
    #[serde(default)]
    dtype: Option<String>,
    #[serde(default)]
    elem_width: Option<u64>,
    #[serde(default)]
    shape: Option<Vec<u64>>,
    #[serde(default)]
    len: Option<u64>,
    #[serde(default)]
    base: Option<RawAddress>,
}

#[derive(Deserialize)]
#[serde(rename_all = "lowercase")]
enum RawKind {
    In,
    Out,
    Inout,
    Index,
}

#[derive(Deserialize)]
#[serde(untagged)]
enum RawAddress {
    Number(u64),
    Text(String),
}

impl RawArray {
    fn resolve(self, next_base: u64) -> Result<ArrayDef, String> {
        let context = |message: String| format!("array '{}': {}", self.name, message);
        let elem_width = match (&self.dtype, self.elem_width) {
            (Some(dtype), None) => {
                dtype_width(dtype).ok_or_else(|| context(format!("unknown dtype '{dtype}'")))?
            }
            (None, Some(width)) => width,
            _ => {
                return Err(context(
                    "give exactly one of `dtype` and `elem_width`".into(),
                ));
            }
        };
        let len = match (&self.shape, self.len) {
            (Some(shape), None) => shape
                .iter()
                .try_fold(1u64, |len, &dim| len.checked_mul(dim))
                .ok_or_else(|| context("`shape` has more elements than fit in u64".into()))?,
            (None, Some(len)) => len,
            _ => return Err(context("give exactly one of `shape` and `len`".into())),
        };
        let base = match &self.base {
            None => next_base,
            Some(RawAddress::Number(base)) => *base,
            Some(RawAddress::Text(text)) => text
                .strip_prefix("0x")
                .and_then(|hex| u64::from_str_radix(hex, 16).ok())
                .ok_or_else(|| {
                    context(format!("`base` '{text}' is not a 0x-prefixed hex number"))
                })?,
        };
        let kind = match self.kind {
            RawKind::In => ArrayKind::Input,
            RawKind::Out => ArrayKind::Output,
            RawKind::Inout => ArrayKind::InputOutput,
            RawKind::Index => ArrayKind::IndexInput,
        };
        Ok(ArrayDef {
            name: self.name,
            base,
            elem_width,
            len,
            kind,
        })
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
    #[serde(default, rename = "name")]
    _name: Option<String>,
    #[serde(default)]
    int: Option<i64>,
    #[serde(default)]
    float: Option<f64>,
    #[serde(default)]
    sym: Option<String>,
    #[serde(default)]
    ptr: Option<String>,
    #[serde(default, rename = "struct")]
    fields: Option<Vec<RawField>>,
}

impl RawParam {
    fn resolve(self, position: usize) -> Result<ParamValue, String> {
        match (self.int, self.float, self.sym, self.ptr, self.fields) {
            (Some(v), None, None, None, None) => Ok(ParamValue::Int(v)),
            (None, Some(v), None, None, None) => Ok(ParamValue::Float(v)),
            (None, None, Some(name), None, None) => Ok(ParamValue::SymFloat(name)),
            (None, None, None, Some(array), None) => Ok(ParamValue::ArrayPtr(array)),
            (None, None, None, None, Some(fields)) => fields
                .into_iter()
                .map(|field| field.resolve(position))
                .collect::<Result<_, _>>()
                .map(ParamValue::Struct),
            _ => Err(format!(
                "parameter {position}: give exactly one of `int`, `float`, `sym`, `ptr` and `struct`"
            )),
        }
    }
}

/// A struct field, `{"offset": N, "<type>": value}`: read by hand, since its value's key is its type.
#[derive(Deserialize)]
#[serde(transparent)]
struct RawField(serde_json::Map<String, serde_json::Value>);

impl RawField {
    fn resolve(self, param: usize) -> Result<StructField, String> {
        let context = |message: String| format!("parameter {param}: {message}");
        let mut entries = self.0;
        entries.remove("name");
        let offset = entries
            .remove("offset")
            .and_then(|offset| offset.as_u64())
            .ok_or_else(|| context("a struct field needs an `offset` in bytes".into()))?;
        let mut entries = entries.into_iter();
        let (Some((key, value)), None) = (entries.next(), entries.next()) else {
            return Err(context(format!(
                "the struct field at byte {offset} needs exactly one of `ptr` or an integer type \
                 (`u32`, `i64`, ...) beside its `offset` and `name`"
            )));
        };
        let value = if key == "ptr" {
            let array = value.as_str().ok_or_else(|| {
                context(format!("the `ptr` field at byte {offset} names no array"))
            })?;
            FieldValue::ArrayPtr(array.to_string())
        } else if key == "tensor_map" {
            let map: RawTensorMap = serde_json::from_value(value)
                .map_err(|e| context(format!("the tensor map at byte {offset}: {e}")))?;
            let map = map
                .resolve()
                .map_err(|e| context(format!("the tensor map at byte {offset}: {e}")))?;
            FieldValue::TensorMap(Box::new(map))
        } else {
            let width = int_width(&key).ok_or_else(|| {
                context(format!("unknown struct field key `{key}` at byte {offset}"))
            })?;
            // A u64 above i64::MAX is kept as its bits.
            let bits = value
                .as_i64()
                .or_else(|| value.as_u64().map(|v| v as i64))
                .ok_or_else(|| {
                    context(format!("the `{key}` field at byte {offset} is no integer"))
                })?;
            FieldValue::Int { value: bits, width }
        };
        Ok(StructField { offset, value })
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
    box_dims: Vec<u32>,
    #[serde(default)]
    element_strides: Option<Vec<u32>>,
    #[serde(default)]
    swizzle: Option<String>,
    #[serde(default)]
    swizzle_atomicity: Option<String>,
    #[serde(default)]
    interleave: Option<String>,
    #[serde(default)]
    fill: Option<String>,
}

impl RawTensorMap {
    fn resolve(self) -> Result<TensorMapValue, String> {
        let pick = |field: &str, given: Option<String>, default: &str, names: &[&str]| {
            let given = given.unwrap_or_else(|| default.to_string());
            names
                .iter()
                .position(|name| *name == given)
                .ok_or_else(|| format!("`{field}` is one of {}, not `{given}`", names.join(", ")))
        };
        use TensorElemType as E;
        let elemtype = match self.dtype.as_str() {
            "u8" => E::U8,
            "u16" => E::U16,
            "u32" => E::U32,
            "s32" | "i32" => E::S32,
            "u64" => E::U64,
            "s64" | "i64" => E::S64,
            "f16" => E::F16,
            "f32" => E::F32,
            "f32_ftz" => E::F32Ftz,
            "f64" => E::F64,
            "bf16" => E::Bf16,
            "tf32" => E::Tf32,
            other => return Err(format!("unknown tensor-map dtype `{other}`")),
        };
        let swizzle = [
            TensorSwizzleMode::None,
            TensorSwizzleMode::Swizzle32B,
            TensorSwizzleMode::Swizzle64B,
            TensorSwizzleMode::Swizzle128B,
            TensorSwizzleMode::Swizzle96B,
        ][pick(
            "swizzle",
            self.swizzle,
            "none",
            &["none", "32B", "64B", "128B", "96B"],
        )?];
        let swizzle_atomicity = [
            TensorSwizzleAtomicity::Atomicity16B,
            TensorSwizzleAtomicity::Atomicity32B,
            TensorSwizzleAtomicity::Atomicity32BWith8BFlip,
            TensorSwizzleAtomicity::Atomicity64B,
        ][pick(
            "swizzle_atomicity",
            self.swizzle_atomicity,
            "16B",
            &["16B", "32B", "32B_flip_8B", "64B"],
        )?];
        let interleave = [
            TensorInterleaveLayout::None,
            TensorInterleaveLayout::Interleave16B,
            TensorInterleaveLayout::Interleave32B,
        ][pick(
            "interleave",
            self.interleave,
            "none",
            &["none", "16B", "32B"],
        )?];
        let fill = [TensorFillMode::Zero, TensorFillMode::OobNan]
            [pick("fill", self.fill, "zero", &["zero", "nan"])?];
        let rank = self.dims.len();
        Ok(TensorMapValue {
            array: self.array,
            elemtype,
            dims: self.dims,
            strides: self.strides,
            box_dims: self.box_dims,
            element_strides: self.element_strides.unwrap_or_else(|| vec![1; rank]),
            interleave,
            swizzle,
            swizzle_atomicity,
            fill,
        })
    }
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
