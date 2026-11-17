//! Kernels traced under CPython: `tracer/trace.py` runs a kernel call with a stand-in
//! `nki` package that records each declaration and `nki.isa` call, and prints the
//! kernel in the JSON wire form this module reads into an `ast::Kernel`. Kernel code may
//! use all of Python, more than NKI's own frontends accept.

use std::collections::{BTreeMap, BTreeSet};
use std::fmt;
use std::io::Write;
use std::num::NonZeroU64;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use serde::Deserialize;
use serde_json::{Value as Json, json};

use super::ast::{
    Address, Bounds, Buffer, Dtype, HbmDecl, Instruction, Kernel, LoopId, LoopIteration, LoopKind,
    NoReorderId, Operand, Origin, Param, Partitions, Reordering, Scalar, Statement, Subscript,
    TensorName, TileDecl, TileShape,
};
use super::parse::{Constant, KernelCall};

/// The tracer script, in this crate's source tree; its stand-in `nki` package is beside it.
const SCRIPT: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/tracer/trace.py");

/// The Python interpreter kernels are traced with. Kernel modules import what they
/// import (numpy, for most), so it must have those packages installed.
#[derive(Debug, Clone)]
pub struct Tracer {
    python: PathBuf,
}

impl Tracer {
    pub fn new(python: impl Into<PathBuf>) -> Self {
        Self {
            python: python.into(),
        }
    }

    /// `$VOLTA_PYTHON`, else `python3` on the `PATH`.
    pub fn from_env() -> Self {
        Self::new(std::env::var_os("VOLTA_PYTHON").unwrap_or_else(|| "python3".into()))
    }

    /// Kernel `kernel` of `file` for `call`, imported by its dotted name under the
    /// `search_path` root holding it (so relative imports resolve), else as a top-level
    /// module, its directory searched for the modules it imports.
    pub fn trace(
        &self,
        file: &Path,
        search_path: &[PathBuf],
        kernel: &str,
        call: &KernelCall,
    ) -> Result<Kernel, TraceError> {
        let request = request(file, search_path, kernel, call);
        let output = self.run(&request)?;
        let response: Response = serde_json::from_slice(&output)
            .map_err(|error| TraceError::Malformed(error.to_string()))?;
        match response {
            Response::Kernel(kernel) => kernel.read().map_err(TraceError::Invalid),
            Response::Error(failure) => Err(TraceError::Kernel(failure.read())),
        }
    }

    fn run(&self, request: &Json) -> Result<Vec<u8>, TraceError> {
        let start = |error| TraceError::Start {
            python: self.python.clone(),
            error,
        };
        let mut child = Command::new(&self.python)
            .arg("-I")
            .arg(SCRIPT)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(start)?;
        let mut stdin = child.stdin.take().expect("stdin is piped");
        stdin
            .write_all(request.to_string().as_bytes())
            .map_err(start)?;
        drop(stdin);
        let output = child.wait_with_output().map_err(start)?;
        if !output.status.success() {
            return Err(TraceError::Crashed {
                status: output.status.to_string(),
                stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
            });
        }
        Ok(output.stdout)
    }
}

fn request(file: &Path, search_path: &[PathBuf], kernel: &str, call: &KernelCall) -> Json {
    let constant = |constant: &Constant| match *constant {
        Constant::Int(value) => json!(value),
        Constant::Ints(values) => json!(values),
        Constant::Bool(value) => json!(value),
    };
    let by_name = |pairs: Vec<(&str, Json)>| -> serde_json::Map<String, Json> {
        pairs
            .into_iter()
            .map(|(name, value)| (name.to_string(), value))
            .collect()
    };
    let sizes = call.tile_sizes;
    json!({
        "file": file,
        "search_path": search_path,
        "kernel": kernel,
        "shapes": by_name(call.shapes.iter().map(|&(name, shape)| (name, json!(shape))).collect()),
        "dtypes": by_name(call.dtypes.iter().map(|&(name, dtype)| (name, json!(dtype))).collect()),
        "constants": by_name(call.constants.iter().map(|(name, c)| (*name, constant(c))).collect()),
        "contents": by_name(call.contents.iter().map(|&(name, items)| (name, json!(items))).collect()),
        "tile_sizes": {
            "pmax": sizes.pmax,
            "gemm_stationary_fmax": sizes.gemm_stationary_fmax,
            "gemm_moving_fmax": sizes.gemm_moving_fmax,
            "sbuf_fmax_bytes": sizes.sbuf_fmax_bytes,
        },
    })
}

#[derive(Debug)]
pub enum TraceError {
    /// The interpreter could not be started or spoken to.
    Start {
        python: PathBuf,
        error: std::io::Error,
    },
    /// The tracer itself failed, outside kernel code.
    Crashed { status: String, stderr: String },
    /// The tracer's output is not the wire form.
    Malformed(String),
    /// The wire form names a kernel no `ast::Kernel` can be: a broken tracer invariant.
    Invalid(String),
    /// Running the kernel's Python stopped it.
    Kernel(KernelFailure),
}

/// Why running a kernel call stopped, and the innermost line of kernel code it stopped at.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct KernelFailure {
    pub kind: FailureKind,
    pub message: String,
    pub location: Option<SourceLine>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FailureKind {
    /// The kernel used a part of NKI the stand-in does not model.
    Unsupported,
    /// The kernel used NKI as NKI does not allow, e.g. a slice outside its tensor.
    Kernel,
    /// An `assert` of the kernel failed for this call.
    Assertion,
    /// Any other Python exception.
    Python,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SourceLine {
    pub file: PathBuf,
    pub line: usize,
}

impl fmt::Display for TraceError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Start { python, error } => {
                write!(
                    f,
                    "cannot run the tracer with `{}`: {error}",
                    python.display()
                )
            }
            Self::Crashed { status, stderr } => {
                write!(f, "the tracer failed ({status}):\n{stderr}")
            }
            Self::Malformed(message) => write!(f, "the tracer's output is malformed: {message}"),
            Self::Invalid(message) => write!(f, "the traced kernel is invalid: {message}"),
            Self::Kernel(failure) => write!(f, "{failure}"),
        }
    }
}

impl fmt::Display for KernelFailure {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let kind = match self.kind {
            FailureKind::Unsupported => "unsupported",
            FailureKind::Kernel => "invalid kernel",
            FailureKind::Assertion => "assertion failed",
            FailureKind::Python => "Python error",
        };
        if let Some(SourceLine { file, line }) = &self.location {
            write!(f, "{}:{line}: ", file.display())?;
        }
        write!(f, "{kind}: {}", self.message)
    }
}

impl std::error::Error for TraceError {}

// =============================================================================
// The wire form
// =============================================================================

#[derive(Deserialize)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
enum Response {
    Kernel(WireKernel),
    Error(WireFailure),
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireFailure {
    kind: WireFailureKind,
    message: String,
    location: Option<WireLocation>,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
enum WireFailureKind {
    Unsupported,
    Kernel,
    Assertion,
    Python,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireLocation {
    file: PathBuf,
    line: usize,
}

impl WireFailure {
    fn read(self) -> KernelFailure {
        KernelFailure {
            kind: match self.kind {
                WireFailureKind::Unsupported => FailureKind::Unsupported,
                WireFailureKind::Kernel => FailureKind::Kernel,
                WireFailureKind::Assertion => FailureKind::Assertion,
                WireFailureKind::Python => FailureKind::Python,
            },
            message: self.message,
            location: self.location.map(|location| SourceLine {
                file: location.file,
                line: location.line,
            }),
        }
    }
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireKernel {
    name: String,
    params: Vec<WireParam>,
    body: Vec<WireStatement>,
    returned: Option<String>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireParam {
    name: String,
    shape: Vec<u64>,
    contents: Option<Vec<u64>>,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
enum WireStatement {
    Declare(WireTile),
    DeclareHbm(WireHbm),
    Instruction(WireInstruction),
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireTile {
    name: String,
    shape: Vec<u64>,
    dtype: WireDtype,
    buffer: WireBuffer,
    address: Option<WireAddress>,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
enum WireBuffer {
    Sbuf,
    Psum,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireAddress {
    partition: u64,
    offset: u64,
    element_bytes: u64,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireHbm {
    name: String,
    shape: Vec<u64>,
    dtype: WireDtype,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
enum WireDtype {
    Of(String),
    Named(String),
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireInstruction {
    opcode: String,
    operands: BTreeMap<String, WireOperand>,
    origin: WireOrigin,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireOrigin {
    loops: Vec<WireLoop>,
    no_reorder: Option<u32>,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct WireLoop {
    loop_id: u32,
    kind: WireLoopKind,
    index: u64,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case")]
enum WireLoopKind {
    Affine,
    Sequential,
    Static,
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
enum WireOperand {
    Tensor(String),
    Member(String),
    Scalar(f64),
    Int(u64),
    Ints(Vec<u64>),
    Bool(bool),
    None(()),
    Region {
        tensor: String,
        dims: Vec<WireSubscript>,
    },
    Pattern {
        tensor: String,
        pattern: Vec<[u64; 2]>,
        offset: u64,
    },
    Broadcast {
        tensor: String,
        shape: Vec<u64>,
    },
    Indirect {
        tensor: String,
        index: String,
        count: Option<u64>,
    },
}

#[derive(Deserialize)]
#[serde(rename_all = "snake_case", deny_unknown_fields)]
enum WireSubscript {
    Index(u64),
    Slice([Option<u64>; 2]),
}

/// The tensors declared so far; a statement may name only these.
struct Names(BTreeSet<String>);

impl Names {
    fn declare(&mut self, name: String) -> Result<TensorName, String> {
        if !self.0.insert(name.clone()) {
            return Err(format!("tensor `{name}` is declared twice"));
        }
        Ok(TensorName(name))
    }

    fn get(&self, name: String) -> Result<TensorName, String> {
        match self.0.contains(&name) {
            true => Ok(TensorName(name)),
            false => Err(format!("tensor `{name}` is named before it is declared")),
        }
    }
}

impl WireKernel {
    fn read(self) -> Result<Kernel, String> {
        let mut names = Names(BTreeSet::new());
        let params = self
            .params
            .into_iter()
            .map(|param| {
                Ok(Param {
                    shape: extents(&param.shape, &param.name)?,
                    name: names.declare(param.name)?,
                    contents: param.contents,
                })
            })
            .collect::<Result<_, String>>()?;
        let body = self
            .body
            .into_iter()
            .map(|statement| statement.read(&mut names))
            .collect::<Result<_, String>>()?;
        let returned = self.returned.map(|name| names.get(name)).transpose()?;
        Ok(Kernel {
            name: self.name,
            params,
            body,
            returned,
        })
    }
}

fn extents(shape: &[u64], tensor: &str) -> Result<Vec<NonZeroU64>, String> {
    let extents: Option<Vec<_>> = shape.iter().copied().map(NonZeroU64::new).collect();
    match extents {
        Some(extents) if !extents.is_empty() => Ok(extents),
        _ => Err(format!(
            "`{tensor}`'s shape {shape:?} is not one or more positive extents"
        )),
    }
}

impl WireStatement {
    fn read(self, names: &mut Names) -> Result<Statement, String> {
        Ok(match self {
            Self::Declare(tile) => {
                let [partitions, ref free @ ..] = extents(&tile.shape, &tile.name)?[..] else {
                    unreachable!("extents are non-empty")
                };
                let partitions = Partitions::new(partitions.get())
                    .ok_or_else(|| format!("tile `{}` spans {partitions} partitions", tile.name))?;
                if free.is_empty() {
                    return Err(format!("tile `{}` has no free dimension", tile.name));
                }
                Statement::Declare(TileDecl {
                    shape: TileShape {
                        partitions,
                        free: free.to_vec(),
                    },
                    dtype: tile.dtype.read(names)?,
                    buffer: match tile.buffer {
                        WireBuffer::Sbuf => Buffer::Sbuf,
                        WireBuffer::Psum => Buffer::Psum,
                    },
                    address: tile.address.map(|address| Address {
                        partition: address.partition,
                        offset: address.offset,
                        element_bytes: address.element_bytes,
                    }),
                    name: names.declare(tile.name)?,
                })
            }
            Self::DeclareHbm(tensor) => Statement::DeclareHbm(HbmDecl {
                shape: extents(&tensor.shape, &tensor.name)?,
                dtype: tensor.dtype.read(names)?,
                name: names.declare(tensor.name)?,
            }),
            Self::Instruction(instruction) => Statement::Instruction(Instruction {
                opcode: instruction.opcode,
                operands: instruction
                    .operands
                    .into_iter()
                    .map(|(keyword, operand)| Ok((keyword, operand.read(names)?)))
                    .collect::<Result<_, String>>()?,
                origin: instruction.origin.read(),
            }),
        })
    }
}

impl WireDtype {
    fn read(self, names: &Names) -> Result<Dtype, String> {
        match self {
            Self::Of(tensor) => Ok(Dtype::Of(names.get(tensor)?)),
            Self::Named(dtype) => Ok(Dtype::Named(dtype)),
        }
    }
}

impl WireOrigin {
    fn read(self) -> Origin {
        Origin {
            loops: self
                .loops
                .into_iter()
                .map(|wire| LoopIteration {
                    loop_id: LoopId(wire.loop_id),
                    kind: match wire.kind {
                        WireLoopKind::Affine => LoopKind::Affine,
                        WireLoopKind::Sequential => LoopKind::Sequential,
                        WireLoopKind::Static => LoopKind::Static,
                    },
                    index: wire.index,
                })
                .collect(),
            reordering: match self.no_reorder {
                None => Reordering::Allowed,
                Some(block) => Reordering::Forbidden {
                    block: NoReorderId(block),
                },
            },
        }
    }
}

impl WireOperand {
    fn read(self, names: &Names) -> Result<Operand, String> {
        Ok(match self {
            Self::Tensor(tensor) => Operand::Tensor(names.get(tensor)?),
            Self::Member(member) => Operand::Member(member),
            Self::Scalar(value) => Operand::Scalar(
                Scalar::new(value).ok_or_else(|| format!("scalar {value} is not finite"))?,
            ),
            Self::Int(value) => Operand::Int(value),
            Self::Ints(values) => Operand::Ints(values),
            Self::Bool(value) => Operand::Bool(value),
            Self::None(()) => Operand::None,
            Self::Region { tensor, dims } => Operand::Region {
                tensor: names.get(tensor)?,
                dims: dims
                    .into_iter()
                    .map(|dim| match dim {
                        WireSubscript::Index(index) => Subscript::Index(index),
                        WireSubscript::Slice([start, stop]) => {
                            Subscript::Slice(Bounds { start, stop })
                        }
                    })
                    .collect(),
            },
            Self::Pattern {
                tensor,
                pattern,
                offset,
            } => Operand::Pattern {
                tensor: names.get(tensor)?,
                pattern,
                offset,
            },
            Self::Broadcast { tensor, shape } => Operand::Broadcast {
                tensor: names.get(tensor)?,
                shape,
            },
            Self::Indirect {
                tensor,
                index,
                count,
            } => Operand::Indirect {
                tensor: names.get(tensor)?,
                index: names.get(index)?,
                count,
            },
        })
    }
}
