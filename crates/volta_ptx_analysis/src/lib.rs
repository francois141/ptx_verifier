//! PTX analysis: parsing to a typed AST (`frontend`), lowering to a linear IR (`lower`, `ir`)
//! and one candidate symbolic execution (`eval`), producing `volta_expr` expressions (which
//! `volta_equivalence` checks) and a `volta_graph` event graph (which the graph checks consume).

mod logging;

pub mod frontend;

mod analysis;
mod config;
mod eval;
mod ir;
mod launch_file;
mod lower;

pub use analysis::{AnalysisError, AnalysisParts, AnalysisResult, analyze, write_op_counts};
pub use config::{
    AnalysisConfig, ArrayDef, ArrayKind, FieldValue, IntWidth, ParamValue, StructField,
    TensorMapValue,
};
pub use eval::{ClcMisuse, EvalError, OutputsUnavailable, Stats, ThreadId};
pub use ir::tensor_map::{
    TensorElemType, TensorFillMode, TensorInterleaveLayout, TensorSwizzleAtomicity,
    TensorSwizzleMode,
};
pub use launch_file::LaunchFile;
pub use lower::LowerError;
