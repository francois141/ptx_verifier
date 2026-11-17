//! The full expression language the frontends build: every operation exactly as executed,
//! nothing folded or rewritten. [`crate::lower`] turns it into `symbolic_simplified`, the form
//! the backends decide; each node's value (see [`ExprArena::value`]) is what that lowering
//! makes of it, so execution sees the constants it computed.

mod build;
mod display;
mod node;
mod value;

pub use node::*;
