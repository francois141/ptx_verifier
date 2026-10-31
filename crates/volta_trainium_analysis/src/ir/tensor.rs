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

impl fmt::Display for Shape {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let extents: Vec<String> = self.0.iter().map(u64::to_string).collect();
        write!(f, "[{}]", extents.join(", "))
    }
}
