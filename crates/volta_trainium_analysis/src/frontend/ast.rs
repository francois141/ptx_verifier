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
    pub params: Vec<Param>,
    /// Every tensor a statement names is a parameter or a tensor declared by an
    /// earlier statement, and no name is declared twice.
    pub body: Vec<Statement>,
    /// The tensor named by the `return` ending the body, if any.
    pub returned: Option<TensorName>,
}

/// An argument, with the shape of the call the kernel is specialized to.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Param {
    pub name: TensorName,
    /// The extents, outermost first.
    pub shape: Vec<NonZeroU64>,
}

/// The statements that remain once the parser has evaluated the kernel's integer
/// arithmetic and checked its `assert`s against the call's shapes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Statement {
    /// `name = nl.ndarray((partitions, free, ...), dtype, buffer=...)`.
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

/// A tile's `(partitions, free, ...)` shape: its partitions, then one or more free
/// dimensions, outermost first, which every partition holds.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TileShape {
    pub partitions: Partitions,
    pub free: Vec<NonZeroU64>,
}

impl TileShape {
    /// Its extents, the partitions first.
    pub fn extents(&self) -> Vec<u64> {
        std::iter::once(u64::from(self.partitions.get()))
            .chain(self.free.iter().map(|extent| extent.get()))
            .collect()
    }
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

/// One index of a subscript, as written: an integer, which selects one position and
/// drops the dimension, or a slice, which keeps it.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Subscript {
    Index(u64),
    Slice(Bounds),
}

/// A slice's bounds as written, an omitted bound meaning the tensor's own edge.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Bounds {
    pub start: Option<u64>,
    pub stop: Option<u64>,
}

/// One dimension of a region resolved against its tensor's extent.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Selected {
    /// One position, the dimension dropped from the region's shape.
    Index(u64),
    /// `extent` positions from `start`, at least one.
    Slice { start: u64, extent: u64 },
}

/// Why a subscript names no region of its tensor.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RegionProblem {
    /// More indices than the tensor has dimensions.
    TooManyIndices,
    /// An index outside dimension `dimension`, or a slice of it that is empty or
    /// reaches outside it.
    OutOfBounds { dimension: usize },
}

/// `dims` resolved against a tensor's `extents`, one per dimension: as in numpy, a
/// subscript may omit trailing dimensions, which it then selects whole.
pub fn resolve_region(dims: &[Subscript], extents: &[u64]) -> Result<Vec<Selected>, RegionProblem> {
    if dims.len() > extents.len() {
        return Err(RegionProblem::TooManyIndices);
    }
    let whole = Subscript::Slice(Bounds {
        start: None,
        stop: None,
    });
    let dims = dims.iter().copied().chain(std::iter::repeat(whole));
    extents
        .iter()
        .zip(dims)
        .enumerate()
        .map(|(dimension, (&extent, subscript))| match subscript {
            Subscript::Index(index) if index < extent => Ok(Selected::Index(index)),
            Subscript::Slice(bounds) => {
                let start = bounds.start.unwrap_or(0);
                let stop = bounds.stop.unwrap_or(extent);
                if start < stop && stop <= extent {
                    Ok(Selected::Slice {
                        start,
                        extent: stop - start,
                    })
                } else {
                    Err(RegionProblem::OutOfBounds { dimension })
                }
            }
            Subscript::Index(_) => Err(RegionProblem::OutOfBounds { dimension }),
        })
        .collect()
}

/// The shape of a resolved region: its slices' extents, the indexed dimensions dropped.
pub fn kept_extents(selected: &[Selected]) -> Vec<u64> {
    selected
        .iter()
        .filter_map(|selected| match *selected {
            Selected::Index(_) => None,
            Selected::Slice { extent, .. } => Some(extent),
        })
        .collect()
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Operand {
    Tensor(TensorName),
    /// A member of an imported module, its alias expanded, e.g. `nki.language.add`.
    Member(String),
    Scalar(Scalar),
    /// An integer, e.g. `axis=1`.
    Int(u64),
    /// A tuple of integers, e.g. `axis=(1,)`.
    Ints(Vec<u64>),
    /// A rectangular region of a tensor, from a subscript.
    Region {
        tensor: TensorName,
        dims: Vec<Subscript>,
    },
}

impl fmt::Display for Kernel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let params: Vec<String> = self
            .params
            .iter()
            .map(|param| format!("{}: [{}]", param.name, extents(&param.shape)))
            .collect();
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
            Self::Declare(tile) => {
                let buffer = tile.buffer.name();
                let extents: Vec<String> =
                    tile.shape.extents().iter().map(u64::to_string).collect();
                write!(
                    f,
                    "{}: {buffer}[{}] of {}",
                    tile.name,
                    extents.join(", "),
                    tile.dtype
                )
            }

            Self::DeclareHbm(tensor) => write!(
                f,
                "{}: shared_hbm[{}] of {}",
                tensor.name,
                extents(&tensor.shape),
                tensor.dtype
            ),

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

/// `2, 4` for the shape `(2, 4)`.
fn extents(shape: &[NonZeroU64]) -> String {
    let extents: Vec<String> = shape.iter().map(NonZeroU64::to_string).collect();
    extents.join(", ")
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
            Self::Int(value) => write!(f, "{value}"),
            Self::Ints(values) => match &values[..] {
                [value] => write!(f, "({value},)"),
                _ => {
                    let values: Vec<String> = values.iter().map(u64::to_string).collect();
                    write!(f, "({})", values.join(", "))
                }
            },
            Self::Region { tensor, dims } => {
                let dims: Vec<String> = dims.iter().map(Subscript::to_string).collect();
                write!(f, "{tensor}[{}]", dims.join(", "))
            }
        }
    }
}

impl fmt::Display for Subscript {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Index(index) => write!(f, "{index}"),
            Self::Slice(bounds) => write!(f, "{bounds}"),
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
