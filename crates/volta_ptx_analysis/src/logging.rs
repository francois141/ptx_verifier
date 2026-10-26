//! Logging support for volta_ptx_analysis: with the `logging` feature, re-exports
//! the log crate macros; without it, provides zero-overhead no-op stubs.

// When logging is enabled, re-export log crate macros
#[cfg(feature = "logging")]
pub use log::{info, trace, warn};

// When logging is disabled, provide no-op stub macros
#[cfg(not(feature = "logging"))]
macro_rules! trace {
    ($($arg:tt)*) => {};
}

#[cfg(not(feature = "logging"))]
macro_rules! info {
    ($($arg:tt)*) => {};
}

#[cfg(not(feature = "logging"))]
macro_rules! warn_ {
    ($($arg:tt)*) => {};
}

#[cfg(not(feature = "logging"))]
pub(crate) use {info, trace, warn_ as warn};
