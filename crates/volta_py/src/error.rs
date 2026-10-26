//! Conversion from Volta's Rust error types to Python exceptions. Parse errors span in-memory
//! source (no file for a `FileCache`), so this renders its own plain-text "line N, col M" +
//! source line + caret snippet instead of `volta_common::report`'s ANSI formatter.

use pyo3::PyErr;
use pyo3::create_exception;
use pyo3::exceptions::PyException;

use volta_common::Span;
use volta_graph_check::{Deadlock, Property, PropertySummary};
use volta_ptx_analysis::AnalysisError;
use volta_ptx_analysis::frontend::parse::ParseError;

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
    "A thread can be blocked forever: no barrier or warp group releases it."
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

/// Spec-language parse errors only implement `Display` (no `title()`/`message()`),
/// so this uses a fixed title and the `Display` text as the message, as the CLI does.
pub fn spec_parse_error_to_py(source: &str, err: &volta_spec::parse::ParseError) -> PyErr {
    let message = err.error.to_string();
    let text = format_located(source, "spec parse error", Some(&message), err.span);
    VoltaError::new_err(text)
}

pub fn analysis_error_to_py(err: AnalysisError) -> PyErr {
    VoltaError::new_err(err.to_string())
}

/// The exception for a kernel whose event graph failed `failed`, or whose trace `deadlock`ed:
/// `DataRaceError` if memory-conflict freedom failed, else `DeadlockError` for a deadlock,
/// else `VoltaError`. The message names the deadlock and every failed check with its first
/// witness.
pub fn graph_failure_to_py(failed: &[PropertySummary], deadlock: Option<&Deadlock>) -> PyErr {
    let message = deadlock
        .map(|d| {
            format!(
                "the trace deadlocked with {} blocked thread(s)",
                d.blocked.len()
            )
        })
        .into_iter()
        .chain(failed.iter().map(|s| match s.findings.first() {
            Some(witness) => format!("{} failed: {}", s.property.name(), witness),
            None => format!("{} failed", s.property.name()),
        }))
        .collect::<Vec<_>>()
        .join("; ");
    if failed
        .iter()
        .any(|s| s.property == Property::MemoryConflict)
    {
        DataRaceError::new_err(message)
    } else if deadlock.is_some() {
        DeadlockError::new_err(message)
    } else {
        VoltaError::new_err(message)
    }
}

/// Catch-all for `Display`-only errors (spec instantiation, unfolding, equivalence
/// checks): ordinary failures, not graph check failures.
pub fn other_error_to_py(err: impl std::fmt::Display) -> PyErr {
    VoltaError::new_err(err.to_string())
}
