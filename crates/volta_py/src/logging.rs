//! Volta's Rust logs (`volta_common::logging`) forwarded to Python's `logging`, at info level
//! and above: each record goes to the logger its target names (`volta_graph_check::suite`
//! becomes `volta_graph_check.suite`), so a configured root logger shows every stage.

use log::{Level, LevelFilter, Log, Metadata, Record};
use pyo3::prelude::*;

struct PythonLogger;

static LOGGER: PythonLogger = PythonLogger;

impl Log for PythonLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= Level::Info
    }

    fn log(&self, record: &Record) {
        if !self.enabled(record.metadata()) {
            return;
        }

        let level: u8 = match record.level() {
            Level::Error => 40,
            Level::Warn => 30,
            Level::Info => 20,
            Level::Debug => 10,
            Level::Trace => 5,
        };
        let name = record.target().replace("::", ".");
        let message = record.args().to_string();

        Python::attach(|py| {
            let logged = py
                .import("logging")
                .and_then(|logging| logging.call_method1("getLogger", (name,)))
                .and_then(|logger| logger.call_method1("log", (level, message)));

            // A failing handler must not fail the analysis that logged.
            drop(logged);
        });
    }

    fn flush(&self) {}
}

/// Forward Rust logs to Python; a no-op when another logger was installed first.
pub fn install() {
    if log::set_logger(&LOGGER).is_ok() {
        log::set_max_level(LevelFilter::Info);
    }
}
