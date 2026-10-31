//! Errors from parsing an NKI kernel file.

use std::fmt;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ParseError {
    /// The file defines no function of that name.
    KernelNotFound(String),
    /// Malformed or unsupported source at a 1-based line.
    Syntax { line: usize, message: String },
}

impl ParseError {
    pub(super) fn at(line: usize, message: impl fmt::Display) -> Self {
        Self::Syntax {
            line,
            message: message.to_string(),
        }
    }
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::KernelNotFound(name) => write!(f, "kernel `{name}` not found"),
            Self::Syntax { line, message } => write!(f, "line {line}: {message}"),
        }
    }
}

impl std::error::Error for ParseError {}

/// `bail!(line, "format", args...)` returns a `ParseError::Syntax` at `line`.
macro_rules! bail {
    ($line:expr, $($message:tt)+) => {
        return Err($crate::frontend::error::ParseError::at($line, format_args!($($message)+)))
    };
}

pub(super) use bail;
