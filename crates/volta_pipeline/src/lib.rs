//! The verification pipeline.
//!
//! ```text
//! frontend (by ISA: PTX, AMD, NKI) -> KernelRun { symbolic outputs, graph evidence }
//!   ├─ equivalence branch: symbolic outputs only              -> EquivalenceVerdict
//!   │    (a spec's canonical check, or Lean statements left to a prover)
//!   └─ graph branch: the event graph only, ten checks           -> GraphReport (per check)
//!                                       aggregation (decide)  -> ACCEPT / REJECT / UNKNOWN
//! ```
//!
//! The analysis stage runs neither branch and returns no verdict; the two branches share only
//! the stage's artifacts and never call each other. Aggregation alone combines them: ACCEPT
//! needs a complete equivalence proof, and a completed trace with every graph check passing
//! for every kernel whose ISA records one.

pub mod aggregate;
pub mod equivalence;
pub mod extract;
pub mod frontend;
pub mod kernel;
mod logging;
pub mod solve;

pub use aggregate::{Decision, KernelEvidence, Verdict, decide};
pub use equivalence::{Element, EquivalenceVerdict, check_equivalence, confirm_differences};
pub use extract::LeanExtractionError;
pub use frontend::{Frontend, FrontendError, GraphEvidence, Isa, KernelRun, SolveError};
pub use kernel::{KernelVerification, verify_kernel};
pub use solve::{
    DEFAULT_LEAN_NAMESPACE, InvalidSpec, LeanChallenge, LeanSolution, Solution, Solver, Spec,
    check_against_spec, claim, state_against_spec,
};
