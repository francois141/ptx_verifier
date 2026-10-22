//! The verification pipeline.
//!
//! ```text
//! analysis (candidate execution) -> AnalysisResult { symbolic outputs, event graph, provenance }
//!   ├─ equivalence branch: symbolic outputs only              -> EquivalenceVerdict
//!   └─ graph branch: the event graph only, seven checks         -> GraphReport (per check)
//!                                       aggregation (decide)  -> ACCEPT / REJECT / UNKNOWN
//! ```
//!
//! The analysis stage runs neither branch and returns no verdict; the two branches share only
//! the stage's artifacts and never call each other. Aggregation alone combines them: ACCEPT
//! needs a complete equivalence proof, and a completed trace with every graph check passing
//! for every kernel.

pub mod aggregate;
pub mod equivalence;
pub mod kernel;
mod logging;

pub use aggregate::{Decision, KernelEvidence, Verdict, decide};
pub use equivalence::{Element, EquivalenceVerdict, check_equivalence, confirm_differences};
pub use kernel::{KernelVerification, verify_kernel};
