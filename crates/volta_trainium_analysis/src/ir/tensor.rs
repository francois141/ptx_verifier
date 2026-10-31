//! A lowered kernel's tensors: each with the memory it lives in and its shape.

use std::fmt;

use id_collections::id_type;

/// A tensor's position in its kernel's tensor set.
#[id_type]
pub struct TensorId(pub u32);

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Tensor {
    /// Its Python name, unique within the kernel.
    pub name: String,
    pub memory: Memory,
    pub shape: Shape,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Memory {
    /// Device memory, where the kernel's arguments live.
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

/// A tensor's extents, outermost first; an on-chip tile's are `[partitions, free]`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Shape(pub Vec<u64>);

/// An element's position in a tensor: one coordinate per dimension of its shape,
/// outermost first. Indices of one shape are ordered row-major.
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct Index(pub Vec<u64>);

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
