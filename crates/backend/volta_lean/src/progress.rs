use std::fmt;
use std::path::PathBuf;

use volta_common::logging::info;

/// A step of `prove`, in the order they happen. Each is logged at info level as `[lean] <step>`
/// and handed to the caller's `Observer`, so a caller can show progress without a logger.
#[derive(Clone, Debug)]
pub enum Progress {
    Compiling {
        challenge: PathBuf,
    },
    Compiled {
        statements: usize,
        proof: PathBuf,
    },
    AgentStarted {
        model: String,
        effort: String,
        max_turns: u32,
    },
    SessionStarted {
        model: String,
        tools: Vec<String>,
    },
    AgentSaid(String),
    ToolCalled {
        tool: String,
        detail: String,
    },
    ToolReturned {
        tool: String,
        content: String,
    },
    AgentStopped {
        turns: u64,
    },
    /// The first line of the final check's report.
    Verdict(String),
}

impl fmt::Display for Progress {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Progress::Compiling { challenge } => write!(
                f,
                "wrote {}; compiling it against Mathlib",
                challenge.display()
            ),
            Progress::Compiled { statements, proof } => write!(
                f,
                "challenge compiled: {statements} statements; the proof goes to {}",
                proof.display()
            ),
            Progress::AgentStarted {
                model,
                effort,
                max_turns,
            } => write!(
                f,
                "Claude Code is writing the proof: model {model}, effort {effort}, at most \
                 {max_turns} turns"
            ),
            Progress::SessionStarted { model, tools } => {
                write!(f, "Claude Code: {model}, tools {}", tools.join(", "))
            }
            Progress::AgentSaid(text) => write!(f, "agent: {text}"),
            Progress::ToolCalled { tool, detail } => write!(f, "agent -> {tool}{detail}"),
            Progress::ToolReturned { tool, content } => write!(f, "{tool} <- {content}"),
            Progress::AgentStopped { turns } => {
                write!(f, "the agent stopped after {turns} turns; final check")
            }
            Progress::Verdict(verdict) => f.write_str(verdict),
        }
    }
}

/// Receives each `Progress` of a `prove` as it happens.
pub type Observer<'a> = &'a dyn Fn(&Progress);

pub(crate) fn report(observer: Observer<'_>, progress: Progress) {
    info!("[lean] {progress}");
    observer(&progress);
}
