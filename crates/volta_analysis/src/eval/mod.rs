//! Symbolic evaluator for lowered PTX programs.
//!
//! Implements the interpreter from the paper: per-thread round-robin symbolic
//! execution with χ-context race detection and barrier/warp-group
//! synchronization. All floating-point values are symbolic expressions over
//! the reals; addresses, branch predicates, and other control-relevant values
//! must be concrete (the structured-CTA assumption).

pub mod config;
pub mod error;
pub mod fp8;
pub mod interp;
pub mod mbarrier;
pub mod memory;
pub mod race;
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

/// Number of threads in a warpgroup (PTX ISA 9.7.17.1: "four contiguous
/// warps such that the warp-rank of the first warp is a multiple of 4").
pub const WARPGROUP_SIZE: u32 = WARP_SIZE * 4;

pub use config::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};
pub use error::{AccessSite, EvalError, EvalResult};
pub use interp::{AnalysisOutput, Interpreter, Stats};
pub use target::TargetFeatures;
pub use value::Value;
