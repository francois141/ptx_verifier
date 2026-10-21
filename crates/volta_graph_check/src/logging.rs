//! Logging support for volta_graph_check: with the `logging` feature, re-exports
//! the log crate macros; without it, a stub that compiles its arguments in a dead branch,
//! so values computed only for a log (a check's start time) still count as used.

#[cfg(feature = "logging")]
pub use log::info;

#[cfg(not(feature = "logging"))]
macro_rules! info {
    ($($arg:tt)*) => {
        if false {
            let _ = format_args!($($arg)*);
        }
    };
}

#[cfg(not(feature = "logging"))]
pub(crate) use info;
