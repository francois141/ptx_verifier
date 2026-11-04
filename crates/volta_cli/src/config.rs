//! Shared launch arguments and conversion to analysis configuration.

use std::path::PathBuf;

use clap::Args;
use volta_ptx_analysis::{AnalysisConfig, ArrayDef, ArrayKind, LaunchFile, ParamValue};

/// Launch configuration shared by `analyze`, `compare` and `verify` (flattened into each, so
/// they cannot drift apart). For `compare` it describes the reference kernel; `--block2`/`--grid2`
/// override the optimized kernel's dims.
#[derive(Args)]
pub(crate) struct LaunchArgs {
    /// JSON launch file in place of the flags below: block, grid, arrays, params, globals and
    /// the kernel to run (see `volta_ptx_analysis`'s `launch_file` docs for the format)
    #[arg(
        long,
        value_name = "FILE",
        conflicts_with_all = ["block", "grid", "arrays", "params", "globals", "dyn_shared"]
    )]
    config: Option<PathBuf>,

    /// Block dimensions, e.g. "128" or "32,4,1"
    #[arg(short, long, default_value = "1")]
    block: String,

    /// Grid dimensions, e.g. "64,64"
    #[arg(short, long, default_value = "1")]
    grid: String,

    /// Global array: "name:base:elem_width:len:kind" where kind is
    /// in|out|inout|index (e.g. "in:0x10000:4:128:in"). Repeatable.
    #[arg(long = "array")]
    arrays: Vec<String>,

    /// Kernel parameter (in declaration order): "int:N", "float:X",
    /// "sym:name", or "ptr:array_name". Repeatable.
    #[arg(long = "param")]
    params: Vec<String>,

    /// Module-scope .global variable value: "NAME=value". Repeatable.
    #[arg(long = "global")]
    globals: Vec<String>,

    /// Dynamic (extern) shared memory size in bytes
    #[arg(long, default_value_t = 0)]
    dyn_shared: u64,
}

/// Parse "x[,y[,z]]" dimensions.
pub(crate) fn parse_dims(s: &str) -> Result<(u32, u32, u32), String> {
    let mut parts = s.split(',').map(|p| p.trim().parse::<u32>());
    let x = parts
        .next()
        .transpose()
        .map_err(|e| e.to_string())?
        .unwrap_or(1);
    let y = parts
        .next()
        .transpose()
        .map_err(|e| e.to_string())?
        .unwrap_or(1);
    let z = parts
        .next()
        .transpose()
        .map_err(|e| e.to_string())?
        .unwrap_or(1);
    Ok((x, y, z))
}

pub(crate) fn parse_u64_value(s: &str) -> Result<u64, String> {
    if let Some(hex) = s.strip_prefix("0x") {
        u64::from_str_radix(hex, 16).map_err(|e| e.to_string())
    } else {
        s.parse()
            .map_err(|e: std::num::ParseIntError| e.to_string())
    }
}

/// Parse "name:base:elem_width:len:kind".
fn parse_array(s: &str) -> Result<ArrayDef, String> {
    let parts: Vec<&str> = s.split(':').collect();
    let [name, base, elem_width, len, kind] = parts.as_slice() else {
        return Err(format!(
            "expected name:base:elem_width:len:kind, got '{}'",
            s
        ));
    };
    let kind = match *kind {
        "in" => ArrayKind::Input,
        "out" => ArrayKind::Output,
        "inout" => ArrayKind::InputOutput,
        "index" => ArrayKind::IndexInput,
        other => return Err(format!("unknown array kind '{}'", other)),
    };
    Ok(ArrayDef {
        name: name.to_string(),
        base: parse_u64_value(base)?,
        elem_width: parse_u64_value(elem_width)?,
        len: parse_u64_value(len)?,
        kind,
    })
}

/// Parse "int:N" | "float:X" | "sym:name" | "ptr:array".
fn parse_param(s: &str) -> Result<ParamValue, String> {
    let Some((kind, value)) = s.split_once(':') else {
        return Err(format!("expected kind:value, got '{}'", s));
    };
    match kind {
        "int" => Ok(ParamValue::Int(
            value.parse().map_err(|e| format!("{}", e))?,
        )),
        "float" => Ok(ParamValue::Float(
            value.parse().map_err(|e| format!("{}", e))?,
        )),
        "sym" => Ok(ParamValue::SymFloat(value.to_string())),
        "ptr" => Ok(ParamValue::ArrayPtr(value.to_string())),
        other => Err(format!("unknown param kind '{}'", other)),
    }
}

/// The launch `--config` or the flags describe; only a launch file names a kernel.
pub(crate) fn launch_config(launch: &LaunchArgs) -> Result<LaunchFile, String> {
    let Some(path) = &launch.config else {
        return build_config(launch).map(|config| LaunchFile {
            kernel: None,
            config,
        });
    };
    let text =
        std::fs::read_to_string(path).map_err(|e| format!("read {}: {}", path.display(), e))?;
    LaunchFile::from_json(&text).map_err(|e| format!("{}: {}", path.display(), e))
}

fn build_config(input: &LaunchArgs) -> Result<AnalysisConfig, String> {
    let block_dim = parse_dims(&input.block).map_err(|e| format!("invalid --block: {}", e))?;
    let mut config = AnalysisConfig::new(block_dim);
    config.grid_dim = parse_dims(&input.grid).map_err(|e| format!("invalid --grid: {}", e))?;
    config.dynamic_shared_bytes = input.dyn_shared;
    for a in &input.arrays {
        config
            .arrays
            .push(parse_array(a).map_err(|e| format!("invalid --array: {}", e))?);
    }
    for p in &input.params {
        config
            .params
            .push(parse_param(p).map_err(|e| format!("invalid --param: {}", e))?);
    }
    for g in &input.globals {
        let (name, value) = g
            .split_once('=')
            .ok_or_else(|| format!("invalid --global (expected NAME=value): {}", g))?;
        let v: i64 = value
            .parse()
            .map_err(|e: std::num::ParseIntError| format!("invalid --global value: {}", e))?;
        config.global_values.push((name.to_string(), v));
    }
    Ok(config)
}
