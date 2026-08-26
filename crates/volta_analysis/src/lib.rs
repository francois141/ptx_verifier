//! PTX analysis
//!
//! This crate provides:
//! - Symbolic expression representation (`symbolic`)
//! - Lowering from AST to linear IR (`lowering`, `lowered`)
//! - Symbolic equivalence checking (`equiv`)

mod logging;

pub mod canon;
pub mod driver;
pub mod equiv;
pub mod eval;
pub mod lower_error;
pub mod lowered;
pub mod lowering;
pub mod numeric;
pub mod source_map;
pub mod spec;
pub mod symbolic;
pub mod symbols;
pub mod tensor_core;
pub mod types;

pub use driver::{AnalysisError, EquivOutcome, analyze_kernel, check_output_equivalence};
pub use eval::{AnalysisConfig, AnalysisOutput, ArrayDef, ArrayKind, EvalError, ParamValue};
pub use lower_error::{LowerError, LowerResult};
pub use lowered::{InstrId, LoweredInstr, LoweredProgram, Operand, Predicate};
pub use lowering::{LoweringContext, lower_function};
pub use source_map::{SourceMap, SourceMapBuilder};
pub use symbolic::{ExprArena, ExprId, ExprNode, StringId, SymbolId};
pub use symbols::{ParamId, RegId, RegIndex, SpecialRegKind, SymbolKind, SymbolTable};
pub use types::{RegClass, ScalarTypeExt};
