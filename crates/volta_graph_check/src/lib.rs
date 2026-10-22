//! Graph checks over a `volta_graph::EventGraph`: the seven checks of the Volta v2 design's
//! data-race freedom check (§1.3), then two beyond the design, one module each, each callable
//! on a graph in isolation with explicitly passed certificates and with its contract in its
//! module docs. Checks never run symbolic analysis or equivalence checking.
//!
//! | # | Check                                  | Algorithm   | Module                |
//! |---|----------------------------------------|-------------|-----------------------|
//! | 1 | barrier epochs, named barriers         | 1           | [`barrier_epoch`]     |
//! | 2 | barrier epochs, mbarrier phases        | 1           | [`barrier_epoch`]     |
//! | 3 | mbarrier ordering                      | 2           | [`mbarrier_ordering`] |
//! | 4 | memory-conflict obligations            | 3           | [`memory_conflict`]   |
//! | 5 | proxy ordering                         | 4           | [`proxy_order`]       |
//! | 6 | tensor-operation ordering              | 5, with 6   | [`tensor_order`], [`sync_search`] |
//! | 7 | resource lifetime                      | 7           | [`resource_lifetime`] |
//! | 8 | allocation order                       | (ISA rule)  | [`allocation_order`]  |
//! | 9 | allocation permit                      | (ISA rule)  | [`allocation_permit`] |
//!
//! Shared by them: the typed edge projections `G0`, `G_HB` and `D` ([`relation`]), the
//! pipeline relation `E_pipeline` ([`pipeline`]) and the memory domains `M` and `A`
//! ([`domain`]). [`suite`] runs the nine in order; a kernel's conclusion is theirs alone.

pub mod allocation_order;
pub mod allocation_permit;
pub mod barrier_epoch;
pub mod domain;
mod logging;
pub mod mbarrier_ordering;
pub mod memory_conflict;
pub mod pipeline;
pub mod proxy_order;
pub mod relation;
pub mod resource_lifetime;
pub mod result;
pub mod suite;
pub mod sync_search;
pub mod tensor_order;

pub use result::{Property, PropertyResult, Unresolved, Verdict};
pub use suite::{Deadlock, GraphConclusion, GraphReport, PropertySummary, check_graph};
