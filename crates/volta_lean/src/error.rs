use std::fmt;
use std::io;
use std::path::PathBuf;
use std::process::ExitStatus;
use std::time::Duration;

use crate::SERVER_NAME;

/// What stops a proof attempt or a check before it reaches a verdict. A proof the check
/// rejects is not an `Error` but a `LeanCheck` that did not prove.
#[derive(Debug)]
pub enum Error {
    // Finding the Lean toolchain of a Lake project with Mathlib built.
    /// No project was given and `$VOLTA_LEAN_PROJECT` is unset.
    NoProject,
    /// The project's directory does not exist.
    ProjectNotFound(PathBuf),
    /// `lake` is not on `PATH`.
    LakeNotFound,
    /// `lake env printenv` failed in `project`.
    LakeEnv { project: PathBuf, stderr: String },
    /// `lake env` does not set a variable the toolchain needs.
    LakeVariable(&'static str),

    // Files and child processes.
    /// Reading, writing or creating `path` failed.
    Io { path: PathBuf, error: io::Error },
    /// `program` could not be started or waited for.
    Process { program: PathBuf, error: io::Error },
    /// `program` ran longer than `after` and was killed.
    TimedOut { program: PathBuf, after: Duration },

    // The workspace and Volta's acceptance check.
    /// Volta's own challenge text does not compile against Mathlib.
    ChallengeDoesNotCompile(String),
    /// `check_proof.lean` printed a line that is not a verdict.
    UnexpectedCheckOutput(String),
    /// A `WorkspaceConfig` could not be written or read as JSON.
    Config(serde_json::Error),

    // The Claude Code session.
    /// No `claude` binary is where `find_claude` looks.
    ClaudeNotFound,
    /// The `claude` path given explicitly is not an executable file.
    ClaudeNotExecutable(PathBuf),
    /// The session's tools are not exactly `allowed`, served by a connected Volta server.
    UnexpectedSession {
        tools: Vec<String>,
        servers: String,
        allowed: Vec<String>,
    },
    /// The session exited without its final `result` event.
    NoSessionResult { status: ExitStatus, stderr: String },
}

impl Error {
    pub(crate) fn io(path: impl Into<PathBuf>) -> impl FnOnce(io::Error) -> Error {
        let path = path.into();
        move |error| Error::Io { path, error }
    }

    pub(crate) fn process(program: impl Into<PathBuf>) -> impl FnOnce(io::Error) -> Error {
        let program = program.into();
        move |error| Error::Process { program, error }
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::NoProject => write!(
                f,
                "a Lean project with Mathlib built is required: pass lean_project= or set \
                 VOLTA_LEAN_PROJECT"
            ),
            Error::ProjectNotFound(project) => write!(
                f,
                "the Lean project {} does not exist: create a Lake project with Mathlib built \
                 (`lake new <name> math`, then `lake exe cache get` in it) and pass its \
                 directory as lean_project= or VOLTA_LEAN_PROJECT",
                project.display()
            ),
            Error::LakeNotFound => write!(f, "`lake` is not on PATH (install Lean with elan)"),
            Error::LakeEnv { project, stderr } => {
                write!(f, "`lake env` failed in {}:\n{stderr}", project.display())
            }
            Error::LakeVariable(name) => write!(f, "`lake env` does not set {name}"),

            Error::Io { path, error } => write!(f, "{}: {error}", path.display()),
            Error::Process { program, error } => {
                write!(f, "running `{}` failed: {error}", program.display())
            }
            Error::TimedOut { program, after } => write!(
                f,
                "`{}` did not finish within {} seconds",
                program.display(),
                after.as_secs()
            ),

            Error::ChallengeDoesNotCompile(messages) => {
                write!(f, "challenge.lean does not compile:\n{messages}")
            }
            Error::UnexpectedCheckOutput(line) => {
                write!(f, "the statement check printed an unexpected line: {line}")
            }
            Error::Config(error) => write!(f, "invalid workspace configuration: {error}"),

            Error::ClaudeNotFound => write!(
                f,
                "Claude Code's `claude` was not found: put it on PATH, set VOLTA_CLAUDE or pass \
                 claude="
            ),
            Error::ClaudeNotExecutable(path) => {
                write!(f, "{} is not an executable `claude`", path.display())
            }
            Error::UnexpectedSession {
                tools,
                servers,
                allowed,
            } => write!(
                f,
                "Claude Code started with tools {tools:?} and MCP servers {servers}, not exactly \
                 {allowed:?} from a connected `{SERVER_NAME}` server"
            ),
            Error::NoSessionResult { status, stderr } => {
                write!(
                    f,
                    "Claude Code exited ({status}) without a result:\n{stderr}"
                )
            }
        }
    }
}

impl std::error::Error for Error {}
