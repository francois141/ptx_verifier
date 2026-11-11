//! A lowered kernel's tensors: each with the memory it lives in, its shape, and
//! what its elements hold before they are written.

use std::fmt;

use id_collections::id_type;

pub use crate::frontend::ast::Address;

/// A tensor's position in its kernel's tensor set.
#[id_type]
pub struct TensorId(pub u32);

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Tensor {
    /// Its Python name, unique within the kernel.
    pub name: String,
    pub memory: Memory,
    pub shape: Shape,
    pub initial: Initial,
    /// An on-chip tile's place in its buffer, if `address=` gave one: tiles placed
    /// where others are alias their bytes.
    pub address: Option<Address>,
}

/// What a tensor's elements hold before an instruction writes them.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Initial {
    /// A kernel argument's: each element is its input symbol.
    Argument,
    /// A kernel argument whose elements the call gives, row-major: an index tensor's.
    Integers(Vec<u64>),
    /// A tile's or a kernel-allocated HBM tensor's: nothing, so reading one is an error.
    Uninitialized,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Memory {
    /// Device memory, where the kernel's arguments and the tensor it returns live.
    Hbm,
    Sbuf,
    Psum,
}

impl Memory {
    pub fn name(self) -> &'static str {
        match self {
            Self::Hbm => "hbm",
            Self::Sbuf => "sbuf",
            Self::Psum => "psum",
        }
    }
}

/// A tensor's extents, outermost first; an on-chip tile's are its partitions, then
/// one or more free extents.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Shape(pub Vec<u64>);

/// An element's position in a tensor: one coordinate per dimension of its shape,
/// outermost first. Indices of one shape are ordered row-major.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct Index(pub Vec<u64>);

/// The elements of a tensor an operand names, viewed in `shape`: a rectangular
/// region, or an access pattern's strided view.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TensorRegion {
    pub tensor: TensorId,
    pub shape: Shape,
    pub layout: Layout,
}

/// Where each element of a region's `shape` lies in its tensor.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Layout {
    /// `shape` elements from `start`, per dimension of the tensor, an indexed
    /// dimension's extent being 1. A whole tensor is a zero `start` with the tensor's
    /// own shape, every dimension sliced.
    Rectangle {
        start: Index,
        /// How the region selects each dimension, which its rendering keeps.
        selections: Vec<Selection>,
    },
    /// `t.ap(pattern, offset)`, as `torch.as_strided`: element `local` is the one at
    /// position `offset + steps . local` of the tensor's row-major layout, `storage`.
    Pattern {
        offset: u64,
        steps: Vec<u64>,
        storage: Shape,
    },
}

/// How a region selects one dimension of its tensor.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Selection {
    /// One position: the dimension is dropped from the region's own shape.
    Index,
    /// A range of positions, which the region's shape keeps.
    Slice,
}

impl TensorRegion {
    /// A tile region's `[partitions, free]` view: its first dimension, the partitions,
    /// and every other dimension flattened row-major into one free axis. Lowering keeps
    /// a tile region's partition dimension and bounds every tile's element count.
    pub fn tile_extents(&self) -> [u64; 2] {
        let [partitions, ref free @ ..] = self.shape.0[..] else {
            unreachable!("a tile region has a partition dimension");
        };
        [partitions, free.iter().product()]
    }

    /// The tensor index of the element at `[partition, free]` of the region's
    /// `tile_extents` view.
    pub fn tile_index(&self, partition: u64, free: u64) -> Index {
        let mut local = vec![0; self.shape.0.len()];
        local[0] = partition;
        let mut rest = free;
        for (coordinate, &extent) in local.iter_mut().zip(&self.shape.0).skip(1).rev() {
            *coordinate = rest % extent;
            rest /= extent;
        }
        self.element(&Index(local))
    }

    /// The tensor index of the element at `local`, an index within the region's `shape`.
    pub fn element(&self, local: &Index) -> Index {
        match &self.layout {
            Layout::Rectangle { start, .. } => start.shifted(local),
            Layout::Pattern {
                offset,
                steps,
                storage,
            } => {
                let position = steps
                    .iter()
                    .zip(&local.0)
                    .fold(*offset, |position, (step, coordinate)| {
                        position + step * coordinate
                    });
                storage.index_at(position)
            }
        }
    }

    /// Whether the region drops its tensor's first dimension, a tile's partitions.
    pub fn indexes_first_dimension(&self) -> bool {
        match &self.layout {
            Layout::Rectangle { selections, .. } => selections[0] == Selection::Index,
            Layout::Pattern { .. } => false,
        }
    }
}

impl Shape {
    /// The number of elements, if it fits in a `u64`.
    pub fn element_count(&self) -> Option<u64> {
        self.0
            .iter()
            .try_fold(1u64, |count, &extent| count.checked_mul(extent))
    }

    /// Every index within the shape in row-major order, the last coordinate varying fastest.
    pub fn indices(&self) -> impl Iterator<Item = Index> + '_ {
        let first = (!self.0.contains(&0)).then(|| Index(vec![0; self.0.len()]));
        std::iter::successors(first, |index| self.successor(index))
    }

    /// The position of `index`'s element in a row-major layout of the shape. `index` must
    /// lie within the shape, and the element count fit in a `u64`.
    pub fn offset(&self, index: &Index) -> u64 {
        self.0
            .iter()
            .zip(&index.0)
            .fold(0, |offset, (&extent, &coordinate)| {
                offset * extent + coordinate
            })
    }

    /// The index at position `offset` of a row-major layout of the shape, which must
    /// lie within it.
    pub fn index_at(&self, mut offset: u64) -> Index {
        let mut coordinates = vec![0; self.0.len()];
        for (coordinate, &extent) in coordinates.iter_mut().zip(&self.0).rev() {
            *coordinate = offset % extent;
            offset /= extent;
        }
        Index(coordinates)
    }

    /// The index after `index` in row-major order, if any.
    fn successor(&self, index: &Index) -> Option<Index> {
        let mut next = index.0.clone();
        for (coordinate, &extent) in next.iter_mut().zip(&self.0).rev() {
            *coordinate += 1;
            if *coordinate < extent {
                return Some(Index(next));
            }
            *coordinate = 0;
        }
        None
    }
}

impl Index {
    /// The index with its coordinates reversed: a tile's `[partition, free]` becomes
    /// `[free, partition]`.
    pub fn transposed(&self) -> Index {
        Index(self.0.iter().rev().copied().collect())
    }

    /// This index advanced by `by`, component-wise: the tensor index of a
    /// region's `by`th element.
    pub fn shifted(&self, by: &Index) -> Index {
        Index(self.0.iter().zip(&by.0).map(|(a, b)| a + b).collect())
    }
}

impl fmt::Display for Shape {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write_list(f, &self.0)
    }
}

impl fmt::Display for Index {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write_list(f, &self.0)
    }
}

/// `[a, b, ...]`.
fn write_list(f: &mut fmt::Formatter<'_>, values: &[u64]) -> fmt::Result {
    let values: Vec<String> = values.iter().map(u64::to_string).collect();
    write!(f, "[{}]", values.join(", "))
}
