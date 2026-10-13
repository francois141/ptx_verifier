//! Logging support for volta_equivalence: with the `logging` feature, re-exports
//! the log crate macros; without it, provides zero-overhead no-op stubs.

#[cfg(feature = "logging")]
pub use log::{debug, info};

#[cfg(not(feature = "logging"))]
macro_rules! debug {
    ($($arg:tt)*) => {};
}

#[cfg(not(feature = "logging"))]
macro_rules! info {
    ($($arg:tt)*) => {};
}

#[cfg(not(feature = "logging"))]
pub(crate) use {debug, info};
