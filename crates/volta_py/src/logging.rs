//! Volta's Rust logs (`volta_common::logging`) forwarded to Python's `logging`, at info level
//! and above: each record goes to the logger its target names (`volta_graph_check::suite`
//! becomes `volta_graph_check.suite`), so a configured root logger shows every stage.

use std::sync::{Mutex, MutexGuard, PoisonError};
use std::time::{Duration, Instant};

use log::{Level, LevelFilter, Log, Metadata, Record};
use pyo3::prelude::*;

struct PythonLogger;

static LOGGER: PythonLogger = PythonLogger;

/// While set, every record also goes to `sys.stderr`, stamped with the clock time and the time
/// since this instant: `prove_lean(verbose=True)`'s output, which needs no Python handler.
static ECHO_SINCE: Mutex<Option<Instant>> = Mutex::new(None);

fn echo_since() -> MutexGuard<'static, Option<Instant>> {
    ECHO_SINCE.lock().unwrap_or_else(PoisonError::into_inner)
}

/// Echoes every record to `sys.stderr` until dropped, which restores the previous echo.
pub struct StderrEcho {
    previous: Option<Instant>,
}

impl StderrEcho {
    pub fn since(started: Instant) -> StderrEcho {
        StderrEcho {
            previous: echo_since().replace(started),
        }
    }
}

impl Drop for StderrEcho {
    fn drop(&mut self) {
        *echo_since() = self.previous;
    }
}

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
        let echo = *echo_since();

        Python::attach(|py| {
            let logged = py
                .import("logging")
                .and_then(|logging| logging.call_method1("getLogger", (name,)))
                .and_then(|logger| logger.call_method1("log", (level, &message)));
            let echoed = echo.map(|started| write_stderr(py, started, &message));

            // A failing handler or stderr must not fail the analysis that logged.
            drop((logged, echoed));
        });
    }

    fn flush(&self) {}
}

fn write_stderr(py: Python<'_>, started: Instant, message: &str) -> PyResult<()> {
    let now: String = py
        .import("time")?
        .call_method1("strftime", ("%H:%M:%S",))?
        .extract()?;
    let elapsed = clock(started.elapsed());
    let stderr = py.import("sys")?.getattr("stderr")?;
    stderr.call_method1("write", (format!("{now} +{elapsed}  {message}\n"),))?;
    stderr.call_method0("flush")?;
    Ok(())
}

/// `m:ss`, or `h:mm:ss` from an hour on.
fn clock(duration: Duration) -> String {
    let seconds = duration.as_secs();
    let (hours, minutes, seconds) = (seconds / 3600, seconds / 60 % 60, seconds % 60);
    if hours > 0 {
        format!("{hours}:{minutes:02}:{seconds:02}")
    } else {
        format!("{minutes}:{seconds:02}")
    }
}

/// Forward Rust logs to Python; a no-op when another logger was installed first.
pub fn install() {
    if log::set_logger(&LOGGER).is_ok() {
        log::set_max_level(LevelFilter::Info);
    }
}
