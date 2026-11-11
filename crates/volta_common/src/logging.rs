//! The `log` macros Volta's crates log through: with the `logging` feature, `log`'s own;
//! without it, a stand-in that compiles its arguments in a dead branch, so values computed
//! only for a log (a check's start time) still count as used.

#[cfg(feature = "logging")]
pub use log::{debug, info, trace, warn};

#[cfg(not(feature = "logging"))]
#[doc(hidden)]
#[macro_export]
macro_rules! __disabled_log {
    ($($arg:tt)*) => {
        if false {
            let _ = format_args!($($arg)*);
        }
    };
}

#[cfg(not(feature = "logging"))]
pub use crate::__disabled_log as debug;
#[cfg(not(feature = "logging"))]
pub use crate::__disabled_log as info;
#[cfg(not(feature = "logging"))]
pub use crate::__disabled_log as trace;
#[cfg(not(feature = "logging"))]
pub use crate::__disabled_log as warn;
