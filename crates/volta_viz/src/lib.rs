//! The event-graph viewer: a test (or any producer) records each kernel run it performs as a
//! JSON document in a run store ([`write_run`]), and [`write_page`] turns the store into one
//! self-contained HTML page showing every event in its thread, async or
//! synchronization-object lane, the typed edges between them, the graph checks' findings
//! resolved to events, and the PTX source behind each program point.
//!
//! `just viz` records every `volta_bench` run (`VOLTA_VIZ_DIR=<dir> cargo test -p
//! volta_bench`) and builds the page (`volta viz <dir> -o <page>.html`).

mod export;
mod json;
mod page;
mod store;

pub use export::{Outcome, Run};
pub use page::write_page;
pub use store::{RunId, write_run};
