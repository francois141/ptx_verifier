//! PTX analysis: lowering from AST to a linear IR (`lowering`, `lowered`) and one candidate
//! symbolic execution (`eval`), producing `volta_expr` expressions (which `volta_equivalence`
//! checks) and a `volta_graph` event graph (which graph property checkers consume).

mod logging;

pub mod analysis;
pub mod driver;
pub mod eval;
mod legacy;
pub mod lower_error;
pub mod lowered;
pub mod lowering;
pub mod source_map;
pub mod symbols;
pub mod tensor_core;
pub mod tensor_map;
pub mod types;

pub use analysis::{AnalysisResult, analyze};
pub use driver::{AnalysisError, analyze_kernel};
pub use eval::{AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, EvalError, ParamValue};
pub use lower_error::{LowerError, LowerResult};
pub use lowered::{InstrId, LoweredInstr, LoweredProgram, Operand, Predicate};
pub use lowering::{LoweringContext, lower_function};
pub use source_map::{SourceMap, SourceMapBuilder};
pub use symbols::{ParamId, RegId, RegIndex, SpecialRegKind, SymbolKind, SymbolTable};
pub use types::{RegClass, ScalarTypeExt};
