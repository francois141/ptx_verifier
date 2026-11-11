//! Symbolic evaluator for lowered PTX: the paper's round-robin interpreter.
//! Floats are symbolic reals; addresses and branch predicates must be
//! concrete (structured-CTA assumption). Race checking is not done here.

mod arithm;
mod async_bulk;
mod cluster_launch_control;
mod cp_async;
mod error;
mod float_bits;
mod fragments;
mod im2col;
mod interp;
mod mbarrier;
mod memory;
mod param_space;
mod record;
mod schedule;
mod tcgen05;
mod tcgen05_block_scale;
mod tcgen05_mma;
mod tensor_map_table;
mod tensor_memory;
mod tensormap_replace;
mod value;
mod warp;

use id_collections::id_type;

/// A thread within the CTA, identified by its linearized index
/// (`tid.x + tid.y * ntid.x + tid.z * ntid.x * ntid.y`).
#[id_type]
pub struct ThreadId(pub u32);

impl std::fmt::Display for ThreadId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "t{}", self.0)
    }
}

/// Number of threads in a warp.
pub const WARP_SIZE: u32 = 32;

pub use error::{ClcMisuse, EvalError, TmaMisuse};
pub use interp::{Interpreter, OutputsUnavailable, RunArtifacts, Stats};
