//! Per-run log file: each Volta binary invocation gets a timestamped file under
//! the log directory recording argv and an outcome summary, feature-independent;
//! `logging`-feature builds also mirror `log` output into it via [`RunLog::tee`].

use std::fs::{self, File};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

pub struct RunLog {
    file: Option<File>,
    path: Option<PathBuf>,
}

impl RunLog {
    /// Create `<dir>/<unix-seconds>-<pid>-<command>.log` (the pid keeps same-second
    /// runs apart) and write the argv line. Failures only disable logging with a
    /// warning: a bad log directory must never stop an analysis.
    pub fn open(dir: &Path, command: &str, disabled: bool) -> Self {
        if disabled {
            return Self {
                file: None,
                path: None,
            };
        }
        let stamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map(|d| d.as_secs())
            .unwrap_or(0);
        let path = dir.join(format!("{stamp}-{}-{command}.log", std::process::id()));
        match fs::create_dir_all(dir).and_then(|_| File::create(&path)) {
            Ok(mut file) => {
                let argv: Vec<String> = std::env::args().collect();
                let _ = writeln!(file, "argv: {}", argv.join(" "));
                let _ = file.flush();
                Self {
                    file: Some(file),
                    path: Some(path),
                }
            }
            Err(e) => {
                eprintln!(
                    "warning: could not create log file in {}: {}",
                    dir.display(),
                    e
                );
                Self {
                    file: None,
                    path: None,
                }
            }
        }
    }

    /// Append a summary line - typically the final outcome of a command.
    pub fn record(&mut self, line: &str) {
        if let Some(file) = &mut self.file {
            let _ = writeln!(file, "{line}");
            let _ = file.flush();
        }
    }

    pub fn path(&self) -> Option<&Path> {
        self.path.as_deref()
    }

    /// A writer that mirrors bytes to `w` and to this run's log file (if
    /// any). Used as the `env_logger` target so `log::` output lands in
    /// both the terminal and the run log.
    pub fn tee<W: Write + Send + 'static>(&self, w: W) -> Box<dyn Write + Send> {
        match self.file.as_ref().and_then(|f| f.try_clone().ok()) {
            Some(clone) => Box::new(Tee { a: w, b: clone }),
            None => Box::new(w),
        }
    }
}

/// Mirrors every write/flush to two writers.
struct Tee<A, B> {
    a: A,
    b: B,
}

impl<A: Write, B: Write> Write for Tee<A, B> {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        self.a.write_all(buf)?;
        self.b.write_all(buf)?;
        Ok(buf.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        self.a.flush()?;
        self.b.flush()
    }
}
