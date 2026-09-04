//! Conversion from Volta's Rust error types to Python exceptions.
//!
//! Parse errors carry a `Span` into the in-memory source the caller passed
//! in (there is no on-disk file to key a `FileCache` snippet off), so this
//! renders its own minimal plain-text "line N, col M" + source line +
//! caret snippet instead of reusing `volta_common::report`'s ANSI-styled,
//! `FileCache`-backed formatter.

use pyo3::create_exception;
use pyo3::exceptions::PyException;
use pyo3::PyErr;

use volta_analysis::driver::AnalysisError;
use volta_analysis::eval::EvalError;
use volta_common::Span;
use volta_frontend::parse::ParseError;

create_exception!(volta, VoltaError, PyException, "Base exception for Volta errors.");
create_exception!(
    volta,
    DataRaceError,
    VoltaError,
    "An unsynchronized conflicting memory access was detected."
);
create_exception!(
    volta,
    DeadlockError,
    VoltaError,
    "Every thread is blocked and no barrier or warp group can fire."
);

/// Resolve a byte offset to a 1-based (line, column) and that line's text.
fn locate(source: &str, offset: usize) -> (usize, usize, &str) {
    let mut line = 1;
    let mut col = 1;
    let mut line_start = 0;
    for (i, ch) in source.char_indices() {
        if i >= offset {
            break;
        }
        if ch == '\n' {
            line += 1;
            col = 1;
            line_start = i + 1;
        } else {
            col += 1;
        }
    }
    let line_text = source[line_start..].lines().next().unwrap_or("");
    (line, col, line_text)
}

pub fn parse_error_to_py(source: &str, err: &ParseError) -> PyErr {
    let title = err.error.title();
    let message = err.error.message();
    let mut text = title.to_string();
    if let Some(message) = &message {
        text.push_str(": ");
        text.push_str(message);
    }
    if let Some(Span(lo, _hi)) = err.span {
        let (line, col, line_text) = locate(source, lo);
        text.push_str(&format!("\n  --> line {}, column {}\n", line, col));
        text.push_str(&format!("  | {}\n", line_text));
        text.push_str(&format!("  | {}^", " ".repeat(col.saturating_sub(1))));
    }
    VoltaError::new_err(text)
}

pub fn analysis_error_to_py(err: AnalysisError) -> PyErr {
    match &err {
        AnalysisError::Eval(EvalError::DataRace { .. }) => DataRaceError::new_err(err.to_string()),
        AnalysisError::Eval(EvalError::Deadlock { .. }) => DeadlockError::new_err(err.to_string()),
        _ => VoltaError::new_err(err.to_string()),
    }
}
