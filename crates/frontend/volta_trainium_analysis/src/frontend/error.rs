//! Errors from parsing an NKI kernel file.

use std::fmt;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ParseError {
    /// The file defines no function of that name.
    KernelNotFound(String),
    /// The call's shape for parameter `param` is missing or unusable.
    ParamShape {
        param: String,
        problem: ShapeProblem,
    },
    /// An error in helper `function` of `module`, which the kernel called; its line is
    /// that module's.
    InCall {
        function: String,
        module: String,
        error: Box<ParseError>,
    },
    /// Malformed or unsupported source at a 1-based line.
    Syntax { line: usize, message: String },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ShapeProblem {
    /// No shape is given for the parameter.
    Missing,
    /// A shape is given for a name that is not a parameter.
    NotAParam,
    /// Two shapes are given for the parameter.
    Repeated,
    /// A shape without extents, or with a zero one.
    Empty,
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
            Self::InCall {
                function,
                module,
                error,
            } => write!(f, "in `{function}` of module `{module}`: {error}"),
            Self::ParamShape { param, problem } => match problem {
                ShapeProblem::Missing => write!(f, "no shape is given for parameter `{param}`"),
                ShapeProblem::NotAParam => {
                    write!(
                        f,
                        "a shape is given for `{param}`, which is not a parameter"
                    )
                }
                ShapeProblem::Repeated => write!(f, "two shapes are given for parameter `{param}`"),
                ShapeProblem::Empty => write!(
                    f,
                    "parameter `{param}`'s shape needs one or more extents, all positive"
                ),
            },
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
