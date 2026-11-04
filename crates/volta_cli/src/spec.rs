//! Specification sources and dimension values.

use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

use volta_common::file_cache::FileCache;
use volta_common::report::{Report, report_error};
use volta_pipeline::Spec;

use crate::config::parse_u64_value;

/// Resolve `verify`'s `spec` argument: a file path first (via `files`, for parse-error
/// snippets), else inline spec text - but only when the file is missing; other I/O errors
/// (permission denied, is a directory, ...) are reported directly.
fn load_spec_source(files: &mut FileCache, arg: &str) -> Result<(String, Option<PathBuf>), String> {
    match files.read(arg) {
        Ok(contents) => Ok((contents.to_string(), Some(PathBuf::from(arg)))),
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => Ok((arg.to_string(), None)),
        Err(e) => Err(format!("failed to read spec file '{}': {}", arg, e)),
    }
}

/// Parse "NAME=VALUE" (hex with a 0x prefix, via `parse_u64_value`).
fn parse_dim(s: &str) -> Result<(String, u64), String> {
    let (name, value) = s
        .split_once('=')
        .ok_or_else(|| format!("invalid --dim (expected NAME=VALUE): {}", s))?;
    Ok((name.to_string(), parse_u64_value(value)?))
}

/// The `--dim` values, by dim name.
pub(crate) fn dim_values(dims: &[String]) -> Result<HashMap<String, u64>, ExitCode> {
    dims.iter()
        .map(|d| {
            parse_dim(d).map_err(|e| {
                eprintln!("error: {}", e);
                ExitCode::FAILURE
            })
        })
        .collect()
}

/// Where a spec's source comes from.
#[derive(Clone, Copy)]
pub(crate) enum SpecSource<'a> {
    /// A command-line argument: a `.spec` path, or inline spec source if no such file exists.
    Argument(&'a str),
    /// A launch file's `spec`: a path only.
    File(&'a Path),
}

/// The spec `source` at the values `dims`; a failure is reported here, located in the spec
/// source when it is a parse error.
pub(crate) fn load_spec(source: SpecSource, dims: &HashMap<String, u64>) -> Result<Spec, ExitCode> {
    let mut spec_files = FileCache::new();
    let loaded = match source {
        SpecSource::Argument(arg) => load_spec_source(&mut spec_files, arg),
        SpecSource::File(path) => spec_files
            .read(path)
            .map(|contents| (contents.to_string(), Some(path.to_path_buf())))
            .map_err(|e| format!("failed to read spec file '{}': {}", path.display(), e)),
    };
    let (spec_src, spec_path) = loaded.map_err(|e| {
        eprintln!("error: {}", e);
        ExitCode::FAILURE
    })?;
    let parsed_spec = volta_spec::parse_spec(&spec_src).map_err(|e| {
        if let SpecSource::Argument(arg) = source
            && spec_path.is_none()
        {
            eprintln!(
                "note: '{}' is not an existing file, so it was parsed as inline spec text",
                arg
            );
        }
        let _ = report_error(
            &mut std::io::stderr(),
            &spec_files,
            Report {
                path: spec_path.as_deref(),
                span: e.span,
                title: "spec parse error",
                message: Some(&e.error.to_string()),
            },
        );
        ExitCode::FAILURE
    })?;
    Spec::new(&parsed_spec, dims).map_err(|e| {
        eprintln!("error: {}", e);
        ExitCode::FAILURE
    })
}
