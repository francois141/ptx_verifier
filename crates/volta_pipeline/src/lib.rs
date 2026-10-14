//! The verification pipeline.
//!
//! ```text
//! analysis (candidate execution) -> AnalysisResult { symbolic outputs, event graph, provenance }
//!   ├─ equivalence branch: symbolic outputs only              -> EquivalenceVerdict
//!   └─ graph branch: graph + read-only symbolic facts         -> GraphReport (per property)
//!                                       aggregation (decide)  -> ACCEPT / REJECT / UNKNOWN
//! ```
//!
//! The analysis stage runs neither branch and returns no verdict; the two branches share only
//! the stage's artifacts and never call each other (the graph branch's benign-store rule takes
//! the `ValueEquality` query interface, declared in `volta_expr`, as an explicit input).
//! Aggregation alone combines them: ACCEPT needs a complete equivalence proof, every graph
//! property passing, and a schedule-independent proof scope for every kernel.

pub mod aggregate;
pub mod equivalence;
pub mod kernel;

pub use aggregate::{Decision, KernelEvidence, Verdict, decide};
pub use equivalence::{Element, EquivalenceVerdict, check_equivalence, confirm_differences};
pub use kernel::{KernelVerification, verify_kernel};
