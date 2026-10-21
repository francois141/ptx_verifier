//! Graph checks over a `volta_graph::EventGraph`: exactly the six checks of the Volta v2
//! design's data-race freedom check (§1.3), one module each, each callable on a graph in
//! isolation with explicitly passed certificates and with its contract in its module docs.
//! Checks never run symbolic analysis or equivalence checking.
//!
//! | # | Check                                  | Algorithm   | Module                |
//! |---|----------------------------------------|-------------|-----------------------|
//! | 1 | barrier epochs, named barriers         | 1           | [`barrier_epoch`]     |
//! | 2 | barrier epochs, mbarrier phases        | 1           | [`barrier_epoch`]     |
//! | 3 | memory-conflict obligations            | 2           | [`memory_conflict`]   |
//! | 4 | proxy ordering                         | 3           | [`proxy_order`]       |
//! | 5 | tensor-operation ordering              | 4, with 5   | [`tensor_order`], [`sync_search`] |
//! | 6 | resource lifetime                      | 6           | [`resource_lifetime`] |
//!
//! Shared by them: the typed edge projections `G0`, `G_HB` and `D` ([`relation`]), the
//! pipeline relation `E_pipeline` ([`pipeline`]) and the memory domains `M` and `A`
//! ([`domain`]). [`suite`] runs the six in order; [`scope`] is the separate
//! schedule-coverage argument a program-level verdict also needs.

pub mod barrier_epoch;
pub mod domain;
pub mod memory_conflict;
pub mod pipeline;
pub mod proxy_order;
pub mod relation;
pub mod resource_lifetime;
pub mod result;
pub mod scope;
pub mod suite;
pub mod sync_search;
pub mod tensor_order;

pub use result::{Property, PropertyResult, Unresolved, Verdict};
pub use scope::ProofScope;
pub use suite::{Deadlock, GraphConclusion, GraphReport, PropertySummary, check_graph};
