//! Command tree and global options.

use std::path::PathBuf;

use clap::{Parser, Subcommand};

use crate::commands::{AnalyzeArgs, CompareArgs, VerifyArgs, VizArgs};

/// Log level for controlling output verbosity
#[cfg(feature = "logging")]
#[derive(Debug, Clone, Copy, Default, clap::ValueEnum)]
pub(crate) enum LogLevel {
    /// Only show errors
    Error,
    /// Show warnings and errors
    #[default]
    Warn,
    /// Show info, warnings, and errors
    Info,
    /// Show debug output and above
    Debug,
    /// Show all log output including trace
    Trace,
}

#[cfg(feature = "logging")]
impl From<LogLevel> for log::LevelFilter {
    fn from(level: LogLevel) -> Self {
        match level {
            LogLevel::Error => log::LevelFilter::Error,
            LogLevel::Warn => log::LevelFilter::Warn,
            LogLevel::Info => log::LevelFilter::Info,
            LogLevel::Debug => log::LevelFilter::Debug,
            LogLevel::Trace => log::LevelFilter::Trace,
        }
    }
}

#[derive(Parser)]
#[command(name = "volta")]
#[command(about = "The Volta PTX analysis engine.")]
#[command(version)]
pub(crate) struct Cli {
    #[command(subcommand)]
    pub(crate) command: Commands,

    /// Log level for output verbosity
    #[cfg(feature = "logging")]
    #[arg(long, value_enum, default_value = "warn", global = true)]
    pub(crate) log_level: LogLevel,

    /// Directory for per-run log files
    #[arg(long, global = true, default_value = "volta-logs")]
    pub(crate) log_dir: PathBuf,

    /// Don't write a per-run log file
    #[arg(long, global = true)]
    pub(crate) no_log_file: bool,
}

#[derive(Subcommand)]
pub(crate) enum Commands {
    /// Parse a PTX file and check for syntax errors
    Parse {
        /// PTX file to parse
        file: PathBuf,
    },

    /// Symbolically execute a kernel: detect races/deadlocks and print the
    /// symbolic output tensors
    Analyze(AnalyzeArgs),

    /// Check two kernels for semantic equivalence (each is also checked for
    /// data races/deadlocks). Arrays/params/globals are shared by both
    /// kernels unless a `--block2`/`--grid2` override is given.
    Compare(CompareArgs),

    /// Check one kernel against a math spec (and for races/deadlocks). SPEC is a `.spec` path, or
    /// inline spec source if no such file exists; every array with a spec output equation must be a
    /// declared output array of the kernel.
    Verify(VerifyArgs),

    /// Build the event-graph viewer: one self-contained HTML page over a store of recorded runs
    /// (`just viz` records every volta_pipeline test into one, then builds the page)
    Viz(VizArgs),
}
