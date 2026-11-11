use std::fmt;
use std::fs;

use serde_json::{Map, Value, json};

use crate::text::capped;
use crate::{CHALLENGE, Error, Workspace};

/// The line of `write_proof`'s `content` that its `per_statement` template replaces.
pub const PER_STATEMENT_LINE: &str = "-- volta: per statement";

/// Everything a proving agent can do; only `WriteProof` writes, and only `proof.lean`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Tool {
    ReadChallenge,
    ReadProof,
    WriteProof,
    CheckProof,
    SearchLibrary,
}

impl Tool {
    pub const ALL: [Tool; 5] = [
        Tool::ReadChallenge,
        Tool::ReadProof,
        Tool::WriteProof,
        Tool::CheckProof,
        Tool::SearchLibrary,
    ];

    pub fn name(self) -> &'static str {
        match self {
            Tool::ReadChallenge => "read_challenge",
            Tool::ReadProof => "read_proof",
            Tool::WriteProof => "write_proof",
            Tool::CheckProof => "check_proof",
            Tool::SearchLibrary => "search_library",
        }
    }

    pub fn named(name: &str) -> Option<Tool> {
        Tool::ALL.into_iter().find(|tool| tool.name() == name)
    }

    pub fn description(self) -> String {
        match self {
            Tool::ReadChallenge => {
                "Return lines of challenge.lean, the statements to prove (read-only).".to_string()
            }
            Tool::ReadProof => "Return the current text of proof.lean.".to_string(),
            Tool::WriteProof => format!(
                "Replace all of proof.lean, the only file you can change, with new text. With \
                 `per_statement`, the line `{PER_STATEMENT_LINE}` in `content` becomes that \
                 template once per statement of challenge.lean, in order, with `{{name}}` \
                 replaced by the statement's name (out_0, out_1, ...)."
            ),
            Tool::CheckProof => {
                "Compile proof.lean and run Volta's acceptance check on it (about a minute)."
                    .to_string()
            }
            Tool::SearchLibrary => {
                "Search the Lean sources of Mathlib, its dependencies and Lean's core library."
                    .to_string()
            }
        }
    }

    pub fn input_schema(self) -> Value {
        match self {
            Tool::ReadChallenge => json!({
                "type": "object",
                "properties": {
                    "start_line": {
                        "type": "integer",
                        "description": "The first line to return, from 1 (default 1).",
                    },
                    "line_count": {
                        "type": "integer",
                        "description": "How many lines to return (default 200).",
                    },
                },
                "additionalProperties": false,
            }),
            Tool::ReadProof | Tool::CheckProof => json!({
                "type": "object",
                "properties": {},
                "additionalProperties": false,
            }),
            Tool::WriteProof => json!({
                "type": "object",
                "properties": {
                    "content": {
                        "type": "string",
                        "description": "The complete new text of proof.lean.",
                    },
                    "per_statement": {
                        "type": "string",
                        "description": "Lean text to repeat once per statement, `{name}` \
                            standing for its name, e.g. `theorem {name} : \
                            VoltaChallenge.{name} := fun x => key x`.",
                    },
                },
                "required": ["content"],
                "additionalProperties": false,
            }),
            Tool::SearchLibrary => json!({
                "type": "object",
                "properties": {
                    "pattern": {
                        "type": "string",
                        "description": "A regular expression (Rust regex syntax: no lookaround \
                            or backreferences), matched in multiline mode against each file.",
                    },
                    "max_results": {
                        "type": "integer",
                        "description": "The most matching lines to return (default 40).",
                    },
                },
                "required": ["pattern"],
                "additionalProperties": false,
            }),
        }
    }

    pub(crate) fn run(
        self,
        workspace: &Workspace,
        arguments: &Map<String, Value>,
    ) -> Result<String, ToolError> {
        match self {
            Tool::ReadChallenge => read_challenge(workspace, arguments),
            Tool::ReadProof => {
                let proof = workspace.proof();
                let text = fs::read_to_string(&proof).map_err(Error::io(proof))?;
                Ok(capped(&text))
            }
            Tool::WriteProof => write_proof(workspace, arguments),
            Tool::CheckProof => Ok(workspace.check()?.report),
            Tool::SearchLibrary => {
                let limit = count(arguments, "max_results", 40)?;
                let pattern = text(arguments, "pattern")?;
                workspace.library().search(pattern, limit).map_err(|error| {
                    ToolError::Argument(format!("`pattern` is not a regular expression: {error}"))
                })
            }
        }
    }
}

/// Why a tool call failed; either way the agent reads the message and may call again.
pub(crate) enum ToolError {
    /// The agent's arguments are invalid.
    Argument(String),
    /// The arguments are valid, but running the tool failed.
    Failed(Error),
}

impl fmt::Display for ToolError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ToolError::Argument(message) => f.write_str(message),
            ToolError::Failed(error) => write!(f, "{error}"),
        }
    }
}

impl From<Error> for ToolError {
    fn from(error: Error) -> ToolError {
        ToolError::Failed(error)
    }
}

fn read_challenge(
    workspace: &Workspace,
    arguments: &Map<String, Value>,
) -> Result<String, ToolError> {
    let start = count(arguments, "start_line", 1)?;
    let wanted = count(arguments, "line_count", 200)?;

    let challenge = workspace.challenge()?;
    let lines: Vec<&str> = challenge.lines().collect();
    let shown: Vec<&str> = lines.iter().skip(start - 1).take(wanted).copied().collect();

    let mut text = format!(
        "{CHALLENGE}, lines {start} to {} of {}:",
        start + shown.len() - 1,
        lines.len()
    );

    for line in shown {
        text.push('\n');
        text.push_str(line);
    }
    
    Ok(capped(&text))
}

fn write_proof(workspace: &Workspace, arguments: &Map<String, Value>) -> Result<String, ToolError> {
    let mut content = text(arguments, "content")?.to_string();
    if arguments.contains_key("per_statement") {
        let template = text(arguments, "per_statement")?.trim_end_matches('\n');
        if content.matches(PER_STATEMENT_LINE).count() != 1 {
            return Err(ToolError::Argument(format!(
                "with `per_statement`, `content` must hold the line `{PER_STATEMENT_LINE}` once"
            )));
        }

        let instances = workspace
            .statements()
            .iter()
            .map(|statement| template.replace("{name}", statement))
            .collect::<Vec<_>>()
            .join("\n");
        content = content.replace(PER_STATEMENT_LINE, &instances);
    }

    let proof = workspace.proof();
    fs::write(&proof, &content).map_err(Error::io(proof))?;
    Ok(format!(
        "Wrote proof.lean ({} lines).",
        content.lines().count()
    ))
}

fn text<'a>(arguments: &'a Map<String, Value>, key: &str) -> Result<&'a str, ToolError> {
    arguments
        .get(key)
        .and_then(Value::as_str)
        .ok_or_else(|| ToolError::Argument(format!("`{key}` must be a string")))
}

fn count(arguments: &Map<String, Value>, key: &str, default: usize) -> Result<usize, ToolError> {
    let Some(value) = arguments.get(key) else {
        return Ok(default);
    };
    value
        .as_u64()
        .filter(|&n| n >= 1)
        .map(|n| usize::try_from(n).unwrap_or(usize::MAX))
        .ok_or_else(|| ToolError::Argument(format!("`{key}` must be a positive integer")))
}
