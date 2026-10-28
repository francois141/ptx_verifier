//! PTX analysis: parsing to a typed AST (`frontend`), lowering to a linear IR (`lower`, `ir`)
//! and one candidate symbolic execution (`eval`), producing `volta_expr` expressions (which
//! `volta_equivalence` checks) and a `volta_graph` event graph (which the graph checks consume).

mod logging;

pub mod frontend;

mod analysis;
mod config;
mod eval;
mod ir;
mod lower;

pub use analysis::{
    AnalysisError, AnalysisParts, AnalysisResult, analyze, analyze_lowered, write_op_counts,
};
pub use config::{AnalysisConfig, ArrayDef, ArrayKind, ParamValue};
pub use eval::{ClcMisuse, EvalError, OutputsUnavailable, Stats, ThreadId};
pub use frontend::ast::ScalarType;
pub use ir::source_map::SourceMap;
pub use ir::symbols::{ParamId, RegId, SpecialRegKind, SymbolTable};
pub use ir::types::RegClass;
pub use ir::{BinOp, InstrId, LoweredInstr, LoweredProgram, MemSpace, Operand, Predicate};
pub use lower::LowerError;
