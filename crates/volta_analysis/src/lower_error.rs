//! Lowering error types: errors that can occur during the lowering pass,
//! including type errors, undefined symbols, and unsupported instructions.

use std::fmt;

use volta_frontend::ast::ScalarType;

use crate::symbols::SymbolKind;

/// Errors that can occur during lowering
#[derive(Debug)]
pub enum LowerError {
    // =========================================================================
    // Type Errors
    // =========================================================================
    /// Register used with incompatible type
    TypeMismatch {
        register: String,
        declared_type: ScalarType,
        used_as: ScalarType,
        instruction: String,
        hint: String,
    },

    /// Instruction used with invalid type
    InvalidTypeForInstruction {
        instruction: String,
        ty: ScalarType,
        reason: &'static str,
    },

    /// Operands have incompatible types with each other
    OperandTypeMismatch {
        instruction: String,
        operand_a: String,
        type_a: ScalarType,
        operand_b: String,
        type_b: ScalarType,
    },

    // =========================================================================
    // Symbol Errors
    // =========================================================================
    /// Reference to undefined register
    UndefinedRegister {
        name: String,
        suggestions: Vec<String>,
    },

    /// Reference to undefined label
    UndefinedLabel { name: String },

    /// Reference to undefined symbol (shared mem, parameter, etc.)
    UndefinedSymbol { name: String },

    /// Duplicate name declaration (all identifiers share one namespace in PTX)
    DuplicateName {
        name: String,
        existing: SymbolKind,
        attempted: SymbolKind,
    },

    // =========================================================================
    // Instruction Errors
    // =========================================================================
    /// Unsupported instruction
    UnsupportedInstruction {
        instruction: String,
        reason: Option<String>,
    },

    /// The instruction is invalid PTX as written (e.g. a mandatory qualifier
    /// is missing) - unlike [`Self::UnsupportedInstruction`], no PTX
    /// assembler would accept it.
    InvalidInstruction { instruction: String, reason: String },

    /// Invalid operand for instruction
    InvalidOperand {
        instruction: String,
        operand: String,
        reason: &'static str,
    },

    /// A float immediate whose bit pattern is a NaN. The analysis model is
    /// the reals (extended with the infinities); NaN denotes no real
    /// number, so the literal is rejected at lowering.
    NanLiteral,

    /// Invalid branch target
    InvalidBranchTarget { target: String },

    /// Special register used as destination
    SpecialRegAsDestination {
        instruction: String,
        register: String,
    },

    // =========================================================================
    // Other Errors
    // =========================================================================
    /// A variable's declared size or placement overflows the u64 address space
    /// (e.g. `.shared .u32 A[0x4000000000000001]` would wrap to 4 bytes);
    /// a hostile or corrupt declaration, rejected loudly instead of wrapped.
    VariableSizeOverflow { what: String },

    /// No function body (declaration only)
    NoFunctionBody { name: String },

    /// Internal error (should not happen)
    Internal { message: String },
}

impl fmt::Display for LowerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::TypeMismatch {
                register,
                declared_type,
                used_as,
                instruction,
                hint,
            } => {
                write!(
                    f,
                    "Type error: register {} has type {:?}, but {} requires {:?}\n\
                     Hint: {}",
                    register, declared_type, instruction, used_as, hint
                )
            }

            Self::InvalidTypeForInstruction {
                instruction,
                ty,
                reason,
            } => {
                write!(
                    f,
                    "Type error: {} cannot operate on type {:?}\n\
                     Reason: {}",
                    instruction, ty, reason
                )
            }

            Self::OperandTypeMismatch {
                instruction,
                operand_a,
                type_a,
                operand_b,
                type_b,
            } => {
                write!(
                    f,
                    "Type error: {} operands have incompatible types\n\
                     {} has type {:?}\n\
                     {} has type {:?}",
                    instruction, operand_a, type_a, operand_b, type_b
                )
            }

            Self::UndefinedRegister { name, suggestions } => {
                write!(f, "Undefined register {}", name)?;
                if !suggestions.is_empty() {
                    write!(f, "\nDid you mean: {}?", suggestions.join(", "))?;
                }
                Ok(())
            }

            Self::UndefinedLabel { name } => {
                write!(f, "Undefined label {}", name)
            }

            Self::UndefinedSymbol { name } => {
                write!(f, "Undefined symbol {}", name)
            }

            Self::DuplicateName {
                name,
                existing,
                attempted,
            } => {
                write!(
                    f,
                    "Duplicate name '{}': already declared as {}, cannot redeclare as {}",
                    name, existing, attempted
                )
            }

            Self::UnsupportedInstruction {
                instruction,
                reason,
            } => {
                write!(f, "Unsupported instruction: {}", instruction)?;
                if let Some(r) = reason {
                    write!(f, "\nReason: {}", r)?;
                }
                Ok(())
            }

            Self::InvalidInstruction {
                instruction,
                reason,
            } => write!(
                f,
                "Invalid instruction: {}\nReason: {}",
                instruction, reason
            ),

            Self::InvalidOperand {
                instruction,
                operand,
                reason,
            } => {
                write!(
                    f,
                    "Invalid operand: {} in {}\n\
                     Reason: {}",
                    operand, instruction, reason
                )
            }

            Self::NanLiteral => {
                write!(f, "NaN literal is outside the analysis model (reals)")
            }

            Self::InvalidBranchTarget { target } => {
                write!(f, "Invalid branch target: {}", target)
            }

            Self::SpecialRegAsDestination {
                instruction,
                register,
            } => {
                write!(
                    f,
                    "Cannot use special register {} as destination in {}\n\
                     Special registers are read-only",
                    register, instruction
                )
            }

            Self::VariableSizeOverflow { what } => {
                write!(f, "Variable size overflows the address space: {}", what)
            }

            Self::NoFunctionBody { name } => {
                write!(f, "Function {} has no body (declaration only)", name)
            }

            Self::Internal { message } => {
                write!(f, "Internal error: {}", message)
            }
        }
    }
}

impl std::error::Error for LowerError {}

/// Result type for lowering operations
pub type LowerResult<T> = Result<T, LowerError>;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_display() {
        let err = LowerError::UndefinedRegister {
            name: "%r99".to_string(),
            suggestions: vec!["%r9".to_string(), "%r90".to_string()],
        };

        let msg = format!("{}", err);
        assert!(msg.contains("Undefined register %r99"));
        assert!(msg.contains("Did you mean"));
    }

    #[test]
    fn test_type_mismatch_display() {
        let err = LowerError::TypeMismatch {
            register: "%f1".to_string(),
            declared_type: ScalarType::F32,
            used_as: ScalarType::U32,
            instruction: "add.u32".to_string(),
            hint: "Use cvt.u32.f32 to convert".to_string(),
        };

        let msg = format!("{}", err);
        assert!(msg.contains("Type error"));
        assert!(msg.contains("%f1"));
        assert!(msg.contains("add.u32"));
    }
}
