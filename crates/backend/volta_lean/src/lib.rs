//! Lean proofs of the obligations Volta states as a `challenge.lean` module: the acceptance
//! check of a `proof.lean` against it (`Workspace::check`), the tools a proving agent works
//! through (`Tool`), served over MCP (`serve_stdio`), and a Claude Code agent that writes the
//! proof (`prove`). Every module is private; this root re-exports the whole API.

mod claude_code;
mod error;
mod library;
mod mcp;
mod process;
mod progress;
mod prove;
mod text;
mod toolchain;
mod tools;
mod workspace;

pub use claude_code::{AgentRun, ClaudeCode, ToolServer, Usage, find_claude};
pub use error::Error;
pub use mcp::{SERVER_NAME, serve, serve_stdio};
pub use progress::{Observer, Progress};
pub use prove::{DEFAULT_MODEL, LeanProof, TRANSCRIPT, check_lean_proof, prove, skeleton};
pub use toolchain::{Toolchain, lean_project};
pub use tools::{PER_STATEMENT_LINE, Tool};
pub use workspace::{CHALLENGE, LeanCheck, PROOF, Workspace, WorkspaceConfig};
