//! PTX analysis: lowering from AST to a linear IR (`lowering`, `lowered`) and one candidate
//! symbolic execution (`eval`), producing `volta_expr` expressions (which `volta_equivalence`
//! checks) and a `volta_graph` event graph (which the graph checks consume).

mod logging;

pub mod analysis;
pub mod eval;
pub mod lower_error;
pub mod lowered;
pub mod lowering;
pub mod source_map;
pub mod symbols;
pub mod tensor_core;
pub mod tensor_map;
pub mod types;

pub use analysis::{AnalysisError, AnalysisResult, analyze, write_op_counts};
pub use eval::{AnalysisConfig, ArrayDef, ArrayKind, EvalError, ParamValue};
pub use lower_error::{LowerError, LowerResult};
pub use lowered::{InstrId, LoweredInstr, LoweredProgram, Operand, Predicate};
pub use lowering::{LoweringContext, lower_function};
pub use source_map::{SourceMap, SourceMapBuilder};
pub use symbols::{ParamId, RegId, RegIndex, SpecialRegKind, SymbolKind, SymbolTable};
pub use types::{RegClass, ScalarTypeExt};
