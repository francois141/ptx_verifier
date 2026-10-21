//! PTX analysis: lowering from AST to a linear IR (`lowering`, `lowered`) and one candidate
//! symbolic execution (`eval`), producing `volta_expr` expressions (which `volta_equivalence`
//! checks) and a `volta_graph` event graph (which the graph checks consume).

mod logging;

mod analysis;
mod config;
mod eval;
mod lower_error;
mod lowered;
mod lowering;
mod source_map;
mod symbols;
mod target;
mod tensor_core;
mod tensor_map;
mod types;

pub use analysis::{AnalysisError, AnalysisParts, AnalysisResult, analyze, write_op_counts};
pub use config::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};
pub use eval::{ClcMisuse, EvalError, OutputsUnavailable, Stats, ThreadId};
pub use lower_error::LowerError;
