//! Symbolic evaluator for lowered PTX programs.
//!
//! Implements the interpreter from the paper: per-thread round-robin symbolic
//! execution with χ-context race detection and barrier/warp-group
//! synchronization. All floating-point values are symbolic expressions over
//! the reals; addresses, branch predicates, and other control-relevant values
//! must be concrete (the structured-CTA assumption).

pub mod config;
pub mod error;
pub mod interp;
pub mod memory;
pub mod race;
pub mod tensor_memory;
pub mod value;
pub mod warp;

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

pub use config::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};
pub use error::{AccessSite, EvalError, EvalResult};
pub use interp::{AnalysisOutput, Interpreter, Stats};
pub use value::Value;
