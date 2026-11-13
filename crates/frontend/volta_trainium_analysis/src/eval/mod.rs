//! Symbolic execution of NKI instructions.

mod alias;
mod error;
mod footprint;
mod interp;
mod record;
mod tensor;

pub use error::EvalError;
pub use footprint::{Access, Location, Mode, PARTITION_STRIDE, Reducer, footprints};
pub use interp::evaluate;
pub use record::{
    Execution, NoReorder, OrderingPolicy, PlacedTiles, Reductions, WriteAfterWrite, record_graph,
};
