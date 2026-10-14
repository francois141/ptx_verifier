//! Graph property checkers over a `volta_graph::EventGraph`: one module per property, each
//! callable on a graph in isolation with explicitly passed inputs, each with its contract in its
//! module docs. Checkers never run symbolic analysis or equivalence checking; read-only
//! symbolic facts (the producer's arena, a value-equality oracle) are explicit inputs where a
//! property needs them.

pub mod async_completion;
pub mod barrier;
pub mod hb;
pub mod pipeline;
pub mod proxy;
pub mod race;
pub mod result;
pub mod well_formed;

pub use result::{Property, PropertyResult, Unresolved, Verdict};
