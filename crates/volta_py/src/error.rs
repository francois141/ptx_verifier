//! Conversion from Volta's Rust error types to Python exceptions.
//!
//! Parse errors carry a `Span` into the in-memory source the caller passed
//! in (there is no on-disk file to key a `FileCache` snippet off), so this
//! renders its own minimal plain-text "line N, col M" + source line +
//! caret snippet instead of reusing `volta_common::report`'s ANSI-styled,
//! `FileCache`-backed formatter.

use pyo3::PyErr;
use pyo3::create_exception;
use pyo3::exceptions::PyException;

use volta_analysis::driver::AnalysisError;
use volta_analysis::eval::EvalError;
use volta_common::Span;
use volta_frontend::parse::ParseError;

create_exception!(
    volta,
    VoltaError,
    PyException,
    "Base exception for Volta errors."
);
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

/// Render a title + message + optional span into `parse_error_to_py`'s
/// plain-text "line N, col M" + source line + caret format, against the
/// in-memory source the span indexes into.
fn format_located(source: &str, title: &str, message: Option<&str>, span: Option<Span>) -> String {
    let mut text = title.to_string();
    if let Some(message) = message {
        text.push_str(": ");
        text.push_str(message);
    }
    if let Some(Span(lo, _hi)) = span {
        let (line, col, line_text) = locate(source, lo);
        text.push_str(&format!("\n  --> line {}, column {}\n", line, col));
        text.push_str(&format!("  | {}\n", line_text));
        text.push_str(&format!("  | {}^", " ".repeat(col.saturating_sub(1))));
    }
    text
}

pub fn parse_error_to_py(source: &str, err: &ParseError) -> PyErr {
    let text = format_located(
        source,
        err.error.title(),
        err.error.message().as_deref(),
        err.span,
    );
    VoltaError::new_err(text)
}

/// Spec-language parse errors (`volta_spec::parse::ParseError`) only
/// implement `Display`, unlike the PTX parser's `title()`/`message()`
/// pair, so this uses a fixed title and the error's `Display` text as the
/// message - same rendering the CLI uses for `Report { title: "spec
/// parse error", message: Some(&e.error.to_string()), .. }`.
pub fn spec_parse_error_to_py(source: &str, err: &volta_spec::parse::ParseError) -> PyErr {
    let message = err.error.to_string();
    let text = format_located(source, "spec parse error", Some(&message), err.span);
    VoltaError::new_err(text)
}

pub fn analysis_error_to_py(err: AnalysisError) -> PyErr {
    match &err {
        AnalysisError::Eval(EvalError::DataRace { .. }) => DataRaceError::new_err(err.to_string()),
        AnalysisError::Eval(EvalError::Deadlock { .. }) => DeadlockError::new_err(err.to_string()),
        _ => VoltaError::new_err(err.to_string()),
    }
}

/// Catch-all for error types that only implement `Display` (spec
/// instantiation, unfolding, and equivalence-check errors) - none of
/// these are analysis *findings* like `DataRace`/`Deadlock`, just
/// ordinary failures.
pub fn other_error_to_py(err: impl std::fmt::Display) -> PyErr {
    VoltaError::new_err(err.to_string())
}
