use std::io::Read;
use std::path::{Path, PathBuf};
use std::process::{Child, Command, ExitStatus, Stdio};
use std::thread;
use std::time::{Duration, Instant};

use crate::Error;
use crate::text::capped;

/// How long one Lean or Lake run, or one agent tool call, may take.
pub(crate) const TIMEOUT: Duration = Duration::from_secs(3600);
const POLL: Duration = Duration::from_millis(50);

pub(crate) struct Finished {
    status: ExitStatus,
    stdout: String,
    stderr: String,
}

impl Finished {
    pub(crate) fn succeeded(&self) -> bool {
        self.status.success()
    }

    pub(crate) fn stdout(&self) -> &str {
        &self.stdout
    }

    pub(crate) fn stderr(&self) -> &str {
        &self.stderr
    }

    /// Both streams, trimmed and capped, as a report quotes them.
    pub(crate) fn messages(&self) -> String {
        capped(format!("{}{}", self.stdout, self.stderr).trim())
    }
}

/// Runs `command` to completion with no input, its output captured; killed after `TIMEOUT`.
pub(crate) fn run(command: &mut Command) -> Result<Finished, Error> {
    let program = PathBuf::from(command.get_program());

    let mut child = command
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(Error::process(&program))?;

    let stdout = child.stdout.take().expect("stdout is piped");
    let stderr = child.stderr.take().expect("stderr is piped");

    thread::scope(|scope| {
        let stdout = scope.spawn(|| read_all(stdout));
        let stderr = scope.spawn(|| read_all(stderr));
        let status = wait(&mut child, &program);
        let stdout = stdout.join().expect("reading a pipe does not panic");
        let stderr = stderr.join().expect("reading a pipe does not panic");

        Ok(Finished {
            status: status?,
            stdout,
            stderr,
        })
    })
}

fn wait(child: &mut Child, program: &Path) -> Result<ExitStatus, Error> {
    let deadline = Instant::now() + TIMEOUT;
    
    loop {
        let exited = child.try_wait().map_err(Error::process(program))?;
        if let Some(status) = exited {
            return Ok(status);
        }

        if Instant::now() >= deadline {
            let _ = child.kill();
            let _ = child.wait();
            return Err(Error::TimedOut {
                program: program.to_path_buf(),
                after: TIMEOUT,
            });
        }

        thread::sleep(POLL);
    }
}

fn read_all(mut pipe: impl Read) -> String {
    let mut bytes = Vec::new();
    let _ = pipe.read_to_end(&mut bytes);
    String::from_utf8_lossy(&bytes).into_owned()
}
