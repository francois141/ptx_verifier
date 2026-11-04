//! Command-specific arguments and handlers.

mod analyze;
mod compare;
mod parse;
mod verify;
mod viz;

pub(crate) use analyze::{AnalyzeArgs, cmd_analyze};
pub(crate) use compare::{CompareArgs, cmd_compare};
pub(crate) use parse::cmd_parse;
pub(crate) use verify::{VerifyArgs, cmd_verify};
pub(crate) use viz::{VizArgs, cmd_viz};
