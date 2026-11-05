//! The parsed form of one NKI kernel: HBM tensors, on-chip tiles, the
//! `nki.isa` instructions over them, and the tensor it returns. `Display` renders a kernel one statement
//! per line, the form of the fixtures' expected `.ast` files.

use std::collections::BTreeMap;
use std::fmt;
use std::num::NonZeroU64;

/// A tensor's Python name; within a kernel it names exactly one tensor.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub struct TensorName(pub String);

/// One `@nki.jit` function.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Kernel {
    pub name: String,
    /// The arguments in order: tensors in device memory (HBM).
    pub params: Vec<TensorName>,
    /// Every tensor a statement names is a parameter or a tensor declared by an
    /// earlier statement, and no name is declared twice.
    pub body: Vec<Statement>,
    /// The tensor named by the `return` ending the body, if any.
    pub returned: Option<TensorName>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Statement {
    /// `assert tensor.shape == (extent, ...)`.
    AssertShape { tensor: TensorName, shape: Vec<u64> },
    /// `name = nl.ndarray((partitions, free), dtype, buffer=...)`.
    Declare(TileDecl),
    /// `name = nl.ndarray(shape, dtype, buffer=nl.shared_hbm)`.
    DeclareHbm(HbmDecl),
    /// `nisa.<opcode>(operand=..., ...)`.
    Instruction(Instruction),
}

/// An on-chip tile.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TileDecl {
    pub name: TensorName,
    pub shape: TileShape,
    pub dtype: Dtype,
    pub buffer: Buffer,
}

/// A tensor the kernel allocates in device memory (HBM), such as the output it returns.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct HbmDecl {
    pub name: TensorName,
    /// The extents, outermost first.
    pub shape: Vec<NonZeroU64>,
    pub dtype: Dtype,
}

/// A tile's `(partitions, free)` shape: `free` elements in each of `partitions` partitions.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TileShape {
    pub partitions: Partitions,
    pub free: NonZeroU64,
}

/// A tile's partition count, from 1 to `Partitions::MAX` (NKI's `nl.tile_size.pmax`).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct Partitions(u32);

impl Partitions {
    pub const MAX: u32 = 128;

    pub fn new(count: u64) -> Option<Self> {
        let count = u32::try_from(count).ok()?;
        (1..=Self::MAX).contains(&count).then_some(Self(count))
    }

    pub fn get(self) -> u32 {
        self.0
    }
}

/// A finite decimal literal, e.g. `tensor_scalar`'s `operand0=0.125`. `new`
/// rejects non-finite values, so equality is reflexive and `Eq` holds.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Scalar(f64);

impl Eq for Scalar {}

impl Scalar {
    pub fn new(value: f64) -> Option<Self> {
        value.is_finite().then_some(Self(value))
    }

    pub fn get(self) -> f64 {
        self.0
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Dtype {
    /// `t.dtype`: the element type of tensor `t`.
    Of(TensorName),
    /// A `nki.language` type, e.g. `float32`.
    Named(String),
}

/// The on-chip memory a tile lives in.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Buffer {
    Sbuf,
    Psum,
}

impl Buffer {
    pub const ALL: [Self; 2] = [Self::Sbuf, Self::Psum];

    /// Its `nki.language` member: `nl.sbuf` is `sbuf`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Sbuf => "sbuf",
            Self::Psum => "psum",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Instruction {
    /// The `nki.isa` function, e.g. `dma_copy`.
    pub opcode: String,
    /// Operands by keyword: the parser rejects positional ones, so each role is explicit.
    pub operands: BTreeMap<String, Operand>,
}

/// One dimension of a tensor region: the slice bounds as written, an omitted
/// bound meaning the tensor's own edge. Lowering resolves those against its shape.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Bounds {
    pub start: Option<u64>,
    pub stop: Option<u64>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Operand {
    Tensor(TensorName),
    /// A member of an imported module, its alias expanded, e.g. `nki.language.add`.
    Member(String),
    Scalar(Scalar),
    /// A rectangular region of a tensor, one slice per subscript index.
    Region {
        tensor: TensorName,
        dims: Vec<Bounds>,
    },
}

impl fmt::Display for Kernel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let params: Vec<&str> = self.params.iter().map(|param| param.0.as_str()).collect();
        writeln!(f, "kernel {}({})", self.name, params.join(", "))?;

        for statement in &self.body {
            writeln!(f, "  {statement}")?;
        }
        if let Some(returned) = &self.returned {
            writeln!(f, "  return {returned}")?;
        }
        Ok(())
    }
}

impl fmt::Display for Statement {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::AssertShape { tensor, shape } => {
                let extents: Vec<String> = shape.iter().map(u64::to_string).collect();
                write!(f, "assert {tensor}.shape == [{}]", extents.join(", "))
            }

            Self::Declare(tile) => {
                let TileShape { partitions, free } = tile.shape;
                let buffer = tile.buffer.name();
                write!(
                    f,
                    "{}: {buffer}[{}, {free}] of {}",
                    tile.name,
                    partitions.get(),
                    tile.dtype
                )
            }

            Self::DeclareHbm(tensor) => {
                let extents: Vec<String> = tensor.shape.iter().map(|e| e.to_string()).collect();
                write!(
                    f,
                    "{}: shared_hbm[{}] of {}",
                    tensor.name,
                    extents.join(", "),
                    tensor.dtype
                )
            }

            Self::Instruction(instruction) => {
                let operands: Vec<String> = instruction
                    .operands
                    .iter()
                    .map(|(keyword, operand)| format!("{keyword}={operand}"))
                    .collect();
                write!(f, "{}({})", instruction.opcode, operands.join(", "))
            }
        }
    }
}

impl fmt::Display for TensorName {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.0)
    }
}

impl fmt::Display for Dtype {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Of(tensor) => write!(f, "{tensor}.dtype"),
            Self::Named(dtype) => f.write_str(dtype),
        }
    }
}

impl fmt::Display for Operand {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Tensor(tensor) => write!(f, "{tensor}"),
            Self::Member(member) => f.write_str(member),
            Self::Scalar(value) => write!(f, "{value}"),
            Self::Region { tensor, dims } => {
                let dims: Vec<String> = dims.iter().map(Bounds::to_string).collect();
                write!(f, "{tensor}[{}]", dims.join(", "))
            }
        }
    }
}

impl fmt::Display for Bounds {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(start) = self.start {
            write!(f, "{start}")?;
        }
        f.write_str(":")?;
        if let Some(stop) = self.stop {
            write!(f, "{stop}")?;
        }
        Ok(())
    }
}

impl fmt::Display for Scalar {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}
