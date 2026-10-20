//! Symbolic evaluator for lowered PTX: the paper's round-robin interpreter.
//! Floats are symbolic reals; addresses and branch predicates must be
//! concrete (structured-CTA assumption). Race checking is not done here.

pub mod arithm;
pub mod async_bulk;
pub mod cluster_launch_control;
pub mod config;
pub mod error;
pub mod float_bits;
pub mod interp;
pub mod mbarrier;
pub mod memory;
pub mod record;
pub mod target;
pub mod tcgen05_mma;
pub mod tensor_map_table;
pub mod tensor_memory;
pub mod value;
pub mod warp;
pub mod warpgroup;
pub mod wgmma;

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

/// A warp within the CTA: its threads' `ThreadId / WARP_SIZE`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct WarpIndex(pub u32);

impl ThreadId {
    /// The warp this thread belongs to.
    pub fn warp(self) -> WarpIndex {
        WarpIndex(self.0 / WARP_SIZE)
    }
}

/// Number of threads in a warpgroup (PTX ISA 9.7.17.1: "four contiguous
/// warps such that the warp-rank of the first warp is a multiple of 4").
pub const WARPGROUP_SIZE: u32 = WARP_SIZE * 4;

pub use config::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};
pub use error::{AccessSite, ClcMisuse, EvalError, EvalResult};
pub use interp::{Interpreter, OutputsUnavailable, RunArtifacts, RunEnd, Stats};
pub use target::TargetFeatures;
pub use value::Value;
