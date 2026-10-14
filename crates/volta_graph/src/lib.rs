//! The typed operation/event graph of one candidate execution: the boundary between Volta's
//! analysis (which records it) and the graph property checkers (which consume it). Neither side
//! depends on the other; this crate is their only shared contract besides `volta_expr`.
//!
//! # Contract
//!
//! * **Events** are numbered densely in the order the analysis executed them: an [`EventId`] is
//!   the event's position in the candidate trace. Every edge the graph encodes runs from a
//!   smaller to a larger position, which [`EventGraph::validate`] checks; consumers must not
//!   assume it of a graph that failed validation.
//! * **Execution contexts** ([`ExecContext`]): a `Thread` event is part of that thread's program
//!   order of issuance; an `Async` event (an asynchronous operation's memory effect or
//!   completion) is in no thread's program order; a `Generation` event is a synchronization
//!   generation's completion.
//! * **Typed edges**: program order (per-thread event sequence), contribution
//!   (`Contribute`/`Exit`/`AsyncComplete` event -> generation, typed by
//!   [`ContributionKind`]), release (generation -> `Resume`), spawn (`AsyncIssue` -> the op's
//!   effects) and completion (effects -> `AsyncComplete` -> tracking generations). The graph
//!   asserts no happens-before relation: which edge kinds order which effects, and under which
//!   validated prerequisites, is each checker's declared contract.
//! * **Tentative associations**: generation membership of arrivals and waits, the generation an
//!   async completion is tracked by, and read-from (the last write before a read in trace order)
//!   are what the candidate execution produced, not facts proved for all schedules.
//! * **Memory effects** ([`MemAccess`]) carry space, mode, ordering kind, proxy, a canonical
//!   footprint (byte ranges, or Tensor Memory lane x column rectangles) and, for writes, the
//!   stored value as expressions of the analysis's arena. Thread-private local memory is not
//!   recorded.
//! * **Terminal state** ([`Terminal`]) says whether the candidate execution completed, got
//!   stuck (with each blocked thread's wait condition) or was aborted by the analysis; a partial
//!   graph still validates.
//! * **Provenance** ([`Provenance`]) records the launch, target and the model assumptions the
//!   producer executed under.

mod builder;
mod dump;
mod graph;
mod ids;
mod model;
mod validate;

pub use builder::GraphBuilder;
pub use graph::EventGraph;
pub use ids::{
    AccessId, AsyncOpId, EventId, GenerationId, ProgramPoint, SyncObjectId, ThreadIx, ValueId,
};
pub use model::*;
pub use validate::GraphDefect;
