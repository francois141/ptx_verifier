use std::collections::HashMap;
use std::env;
use std::fs::{self, File};
use std::io::{BufRead, BufReader, Write};
use std::path::{Path, PathBuf};
use std::process::{ChildStdout, Command, Stdio};

use serde_json::{Value, json};
use volta_common::logging::warn;

use crate::process::TIMEOUT;
use crate::progress::report;
use crate::{Error, Observer, Progress, SERVER_NAME, Tool, Workspace};

// A Claude Code session's own variables, which a `claude` started from inside one must not inherit.
const SESSION_VARIABLES: [&str; 12] = [
    "CLAUDECODE",
    "CLAUDE_AGENT_SDK_VERSION",
    "CLAUDE_CODE_CHILD_SESSION",
    "CLAUDE_CODE_ENTRYPOINT",
    "CLAUDE_CODE_EXECPATH",
    "CLAUDE_CODE_MESSAGING_SOCKET",
    "CLAUDE_CODE_MESSAGING_TOKEN",
    "CLAUDE_CODE_SESSION_ATTENDED",
    "CLAUDE_CODE_SESSION_ID",
    "CLAUDE_CODE_SSE_PORT",
    "CLAUDE_EFFORT",
    "CLAUDE_PID",
];

const LOGGED_LIMIT: usize = 400;
const STDERR_TAIL: usize = 4000;

/// A `claude -p` session: which binary, model and effort, and how many turns it may take.
#[derive(Clone, Debug)]
pub struct ClaudeCode {
    pub executable: PathBuf,
    pub model: String,
    pub effort: String,
    pub max_turns: u32,
}

/// The command that serves `Tool::ALL` over stdio (`serve_stdio`): `program` with `args`, then
/// the path of a `WorkspaceConfig` JSON file.
#[derive(Clone, Debug)]
pub struct ToolServer {
    pub program: PathBuf,
    pub args: Vec<String>,
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct Usage {
    pub input_tokens: u64,
    pub output_tokens: u64,
    pub cache_creation_input_tokens: u64,
    pub cache_read_input_tokens: u64,
}

/// What the session reported when it ended. `cost_usd` is Claude Code's own estimate at API
/// prices; a subscription is not billed per token.
#[derive(Clone, Debug)]
pub struct AgentRun {
    pub summary: String,
    pub turns: u64,
    pub cost_usd: Option<f64>,
    pub usage: Usage,
}

/// `explicit`, else `$VOLTA_CLAUDE`, `claude` on `PATH`, then `$CLAUDE_CODE_EXECPATH` (the
/// binary of the Claude Code session running the caller).
pub fn find_claude(explicit: Option<&Path>) -> Result<PathBuf, Error> {
    if let Some(explicit) = explicit {
        return if is_executable(explicit) {
            Ok(explicit.to_path_buf())
        } else {
            Err(Error::ClaudeNotExecutable(explicit.to_path_buf()))
        };
    }

    let on_path = env::var_os("PATH")
        .map(|path| env::split_paths(&path).collect::<Vec<_>>())
        .unwrap_or_default()
        .into_iter()
        .map(|directory| directory.join("claude"))
        .find(|candidate| is_executable(candidate));
    let from_env = |name: &str| env::var_os(name).map(PathBuf::from);
    [
        from_env("VOLTA_CLAUDE"),
        on_path,
        from_env("CLAUDE_CODE_EXECPATH"),
    ]
    .into_iter()
    .flatten()
    .find(|candidate| is_executable(candidate))
    .ok_or(Error::ClaudeNotFound)
}

fn is_executable(path: &Path) -> bool {
    let Ok(metadata) = fs::metadata(path) else {
        return false;
    };
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        metadata.is_file() && metadata.permissions().mode() & 0o111 != 0
    }
    #[cfg(not(unix))]
    {
        metadata.is_file()
    }
}

impl ClaudeCode {
    /// Runs `claude -p` on `task` with no built-in tools, only `Tool::ALL` through `server`,
    /// writing every event of the session to `transcript`.
    pub(crate) fn run(
        &self,
        workspace: &Workspace,
        system: &str,
        task: &str,
        transcript: &Path,
        server: &ToolServer,
        observer: Observer<'_>,
    ) -> Result<AgentRun, Error> {
        let build = workspace.build();
        let config = build.join("workspace.json");
        let text = serde_json::to_string(&workspace.config()).map_err(Error::Config)?;
        fs::write(&config, text).map_err(Error::io(&config))?;

        let mut args = server.args.clone();
        args.push(config.to_string_lossy().into_owned());
        let servers = build.join("mcp.json");
        let servers_text = json!({"mcpServers": {SERVER_NAME: {
            "command": server.program,
            "args": args,
        }}});
        fs::write(&servers, servers_text.to_string()).map_err(Error::io(&servers))?;

        let allowed: Vec<String> = Tool::ALL
            .iter()
            .map(|tool| format!("mcp__{SERVER_NAME}__{}", tool.name()))
            .collect();

        let errors_path = build.join("claude.stderr");
        let errors = File::create(&errors_path).map_err(Error::io(&errors_path))?;
        let mut command = Command::new(&self.executable);
        command
            .args(["--print", "--model", &self.model, "--effort", &self.effort])
            .args(["--max-turns", &self.max_turns.to_string()])
            .args(["--system-prompt", system, "--tools", ""])
            .arg("--mcp-config")
            .arg(&servers)
            .args(["--strict-mcp-config", "--allowedTools", &allowed.join(",")])
            .args([
                "--permission-mode",
                "dontAsk",
                "--permission-prompts",
                "none",
            ])
            .args(["--setting-sources", "", "--disable-slash-commands"])
            .args(["--no-session-persistence", "--output-format", "stream-json"])
            .arg("--verbose")
            .current_dir(build)
            .env("MCP_TOOL_TIMEOUT", TIMEOUT.as_millis().to_string())
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(errors);
        for variable in SESSION_VARIABLES {
            command.env_remove(variable);
        }

        let mut child = command.spawn().map_err(Error::process(&self.executable))?;
        // A session that exits before reading its task ends without a result, reported with
        // its standard error below.
        let _ = child
            .stdin
            .take()
            .expect("stdin is piped")
            .write_all(task.as_bytes());
        let stdout = child.stdout.take().expect("stdout is piped");
        let followed = follow(stdout, transcript, &allowed, observer);
        if !matches!(child.try_wait(), Ok(Some(_))) {
            let _ = child.kill();
        }
        let status = child.wait().map_err(Error::process(&self.executable))?;

        let Some(result) = followed? else {
            return Err(Error::NoSessionResult {
                status,
                stderr: tail(&errors_path),
            });
        };
        if result["is_error"].as_bool() == Some(true) {
            let subtype = result["subtype"].as_str().unwrap_or("an error");
            warn!("Claude Code ended with {subtype}");
        }

        let usage = &result["usage"];
        let tokens = |key: &str| usage[key].as_u64().unwrap_or(0);
        Ok(AgentRun {
            summary: result["result"].as_str().unwrap_or_default().to_string(),
            turns: result["num_turns"].as_u64().unwrap_or(0),
            cost_usd: result["total_cost_usd"].as_f64(),
            usage: Usage {
                input_tokens: tokens("input_tokens"),
                output_tokens: tokens("output_tokens"),
                cache_creation_input_tokens: tokens("cache_creation_input_tokens"),
                cache_read_input_tokens: tokens("cache_read_input_tokens"),
            },
        })
    }
}

/// Copies the session's events to `transcript` as they arrive, reporting the agent's words and
/// tool calls, and returns its final `result` event.
fn follow(
    stdout: ChildStdout,
    transcript: &Path,
    allowed: &[String],
    observer: Observer<'_>,
) -> Result<Option<Value>, Error> {
    let mut events = File::create(transcript).map_err(Error::io(transcript))?;
    let mut result = None;
    let mut tool_names = HashMap::new();

    for line in BufReader::new(stdout).lines() {
        let line = line.map_err(Error::io(transcript))?;
        writeln!(events, "{line}")
            .and_then(|()| events.flush())
            .map_err(Error::io(transcript))?;

        let Ok(event) = serde_json::from_str::<Value>(&line) else {
            continue;
        };
        match event["type"].as_str() {
            Some("system") if event["subtype"] == "init" => {
                let tools = require_only(&event, allowed)?;
                let model = event["model"].as_str().unwrap_or("(unknown model)");
                report(
                    observer,
                    Progress::SessionStarted {
                        model: model.to_string(),
                        tools,
                    },
                );
            }
            Some("assistant" | "user") => {
                for block in event["message"]["content"].as_array().into_iter().flatten() {
                    if let Some(progress) = block_progress(block, &mut tool_names) {
                        report(observer, progress);
                    }
                }
            }
            Some("result") => result = Some(event),
            _ => {}
        }
    }
    Ok(result)
}

/// Refuses a session whose tools are not exactly Volta's: another could write a file.
fn require_only(init: &Value, allowed: &[String]) -> Result<Vec<String>, Error> {
    let mut tools: Vec<String> = init["tools"]
        .as_array()
        .into_iter()
        .flatten()
        .filter_map(|tool| tool.as_str().map(str::to_string))
        .collect();
    tools.sort();
    let mut expected = allowed.to_vec();
    expected.sort();

    let connected = init["mcp_servers"]
        .as_array()
        .into_iter()
        .flatten()
        .any(|server| server["name"] == SERVER_NAME && server["status"] == "connected");

    if tools == expected && connected {
        return Ok(tools);
    }
    Err(Error::UnexpectedSession {
        tools,
        servers: init["mcp_servers"].to_string(),
        allowed: allowed.to_vec(),
    })
}

/// The step one content block of the agent's conversation shows: its words, a tool call or a
/// tool's result.
fn block_progress(block: &Value, tool_names: &mut HashMap<String, String>) -> Option<Progress> {
    match block["type"].as_str() {
        Some("text") => {
            let text = block["text"].as_str().unwrap_or_default();
            (!text.trim().is_empty()).then(|| Progress::AgentSaid(short(text)))
        }
        Some("tool_use") => {
            let full = block["name"].as_str().unwrap_or_default();
            let name = full.rsplit("__").next().unwrap_or(full).to_string();
            let detail = described(&name, &block["input"]);
            if let Some(id) = block["id"].as_str() {
                tool_names.insert(id.to_string(), name.clone());
            }
            Some(Progress::ToolCalled { tool: name, detail })
        }
        Some("tool_result") => {
            let content = match &block["content"] {
                Value::String(text) => text.clone(),
                Value::Array(parts) => parts
                    .iter()
                    .filter_map(|part| part["text"].as_str())
                    .collect::<Vec<_>>()
                    .join("\n"),
                _ => String::new(),
            };

            let name = block["tool_use_id"]
                .as_str()
                .and_then(|id| tool_names.get(id))
                .map_or("tool", String::as_str);
            Some(Progress::ToolReturned {
                tool: name.to_string(),
                content: short(&content),
            })
        }
        _ => None,
    }
}

fn described(name: &str, input: &Value) -> String {
    match Tool::named(name) {
        Some(Tool::WriteProof) => {
            let lines = input["content"]
                .as_str()
                .unwrap_or_default()
                .lines()
                .count();
            let template = if input.get("per_statement").is_some() {
                " and a per-statement template"
            } else {
                ""
            };
            format!(" ({lines} lines{template})")
        }
        Some(Tool::SearchLibrary) => format!(" {}", input["pattern"]),
        Some(Tool::ReadChallenge) => {
            let start = input.get("start_line").cloned().unwrap_or(json!(1));
            format!(" (from line {start})")
        }
        _ => String::new(),
    }
}

fn short(text: &str) -> String {
    let text = text.split_whitespace().collect::<Vec<_>>().join(" ");
    match crate::text::split_after_chars(&text, LOGGED_LIMIT) {
        None => text,
        Some((head, _)) => format!("{head} ..."),
    }
}

/// The last `STDERR_TAIL` characters of the session's standard error.
fn tail(path: &Path) -> String {
    let text = fs::read_to_string(path).unwrap_or_default();
    let skipped = text.chars().count().saturating_sub(STDERR_TAIL);
    text.chars().skip(skipped).collect()
}
