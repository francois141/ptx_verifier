//! Volta's expression language: the arena-allocated expressions that fold constants as they are
//! built (`symbolic_simplified`, also reachable as `symbolic`, with its `text` format) and one
//! run's output footprint (`outputs`).

pub mod outputs;
pub mod symbolic_simplified;

pub use outputs::SymbolicOutputs;
pub use symbolic_simplified as symbolic;
pub use symbolic_simplified::*;
pub use symbolic_simplified::text;
