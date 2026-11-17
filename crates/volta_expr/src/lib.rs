//! Volta's expression language, in two forms: `symbolic_full`, every operation exactly as a
//! frontend built it, and `symbolic_simplified` (also reachable as `symbolic`, with its `text`
//! format), the constant-folded form the backends decide; `lower` takes one to the other.
//! `outputs` holds one run's output footprint in either form.

pub mod lower;
pub mod outputs;
pub mod symbolic_full;
pub mod symbolic_simplified;

pub use outputs::{FullOutputs, SymbolicOutputs};
pub use symbolic_simplified as symbolic;
pub use symbolic_simplified::text;
pub use symbolic_simplified::*;
