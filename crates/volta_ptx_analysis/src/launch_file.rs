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
//!     {"name": "n_elements", "int": 16}
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
//! `float`, `sym` (a symbolic float) or `ptr` (an array's base), bound in
//! declaration order; its optional `name` is a label for the reader, not
//! checked against the PTX (whose names are often mangled). Unknown keys are
//! errors, so a typo cannot silently fall back to a default.

use std::collections::BTreeMap;

use serde::Deserialize;

use crate::config::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};

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
}

impl RawParam {
    fn resolve(self, position: usize) -> Result<ParamValue, String> {
        match (self.int, self.float, self.sym, self.ptr) {
            (Some(v), None, None, None) => Ok(ParamValue::Int(v)),
            (None, Some(v), None, None) => Ok(ParamValue::Float(v)),
            (None, None, Some(name), None) => Ok(ParamValue::SymFloat(name)),
            (None, None, None, Some(array)) => Ok(ParamValue::ArrayPtr(array)),
            _ => Err(format!(
                "parameter {position}: give exactly one of `int`, `float`, `sym` and `ptr`"
            )),
        }
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
