//! The proving tools as a stdio MCP server, for a Claude Code agent to work through:
//! newline-delimited JSON-RPC 2.0 serving `tools/list` and `tools/call` of `Tool::ALL`.

use std::fmt;
use std::fs;
use std::io::{self, BufRead, Write};
use std::path::Path;

use serde_json::{Map, Value, json};

use crate::{Error, Tool, Workspace, WorkspaceConfig};

/// The server's name, so Claude Code calls its tools `mcp__volta__<tool>`.
pub const SERVER_NAME: &str = "volta";
const PROTOCOL_VERSION: &str = "2025-06-18";

/// Serves the workspace a `WorkspaceConfig` JSON file describes on standard input and output,
/// until standard input closes.
pub fn serve_stdio(config: &Path) -> Result<(), Error> {
    let text = fs::read_to_string(config).map_err(Error::io(config))?;
    let config: WorkspaceConfig = serde_json::from_str(&text).map_err(Error::Config)?;
    let workspace = Workspace::from_config(config)?;
    serve(&workspace, io::stdin().lock(), io::stdout().lock()).map_err(Error::io("<stdio>"))
}

/// Answers every request read from `input` on `output`, one JSON object per line.
pub fn serve(workspace: &Workspace, input: impl BufRead, mut output: impl Write) -> io::Result<()> {
    for line in input.lines() {
        let line = line?;
        if line.trim().is_empty() {
            continue;
        }

        let reply = match serde_json::from_str::<Value>(&line) {
            Err(error) => Some(reply(Value::Null, Err(RpcError::Parse(error)))),
            Ok(request) => request
                .get("id")
                .cloned()
                .map(|id| reply(id, respond(&request, workspace))),
        };
        if let Some(reply) = reply {
            writeln!(output, "{reply}")?;
            output.flush()?;
        }
    }
    Ok(())
}

/// A request the server cannot answer. A tool that fails is not one: its call succeeds
/// with a result marked `isError`, which the agent reads.
enum RpcError {
    /// The line is not JSON.
    Parse(serde_json::Error),
    /// The method is not one the server serves (`None` when the request names none).
    UnknownMethod(Option<String>),
    /// `tools/call` names no tool of `Tool::ALL`.
    UnknownTool(Value),
}

impl RpcError {
    /// The JSON-RPC 2.0 error code.
    fn code(&self) -> i64 {
        match self {
            RpcError::Parse(_) => -32700,
            RpcError::UnknownMethod(_) => -32601,
            RpcError::UnknownTool(_) => -32602,
        }
    }
}

impl fmt::Display for RpcError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            RpcError::Parse(error) => write!(f, "{error}"),
            RpcError::UnknownMethod(method) => {
                write!(
                    f,
                    "method {} not found",
                    method.as_deref().unwrap_or("(none)")
                )
            }
            RpcError::UnknownTool(name) => write!(f, "no tool {name}"),
        }
    }
}

fn reply(id: Value, outcome: Result<Value, RpcError>) -> Value {
    match outcome {
        Ok(result) => json!({"jsonrpc": "2.0", "id": id, "result": result}),
        Err(error) => json!({
            "jsonrpc": "2.0",
            "id": id,
            "error": {"code": error.code(), "message": error.to_string()},
        }),
    }
}

fn respond(request: &Value, workspace: &Workspace) -> Result<Value, RpcError> {
    let params = &request["params"];
    match request["method"].as_str() {
        Some("initialize") => Ok(json!({
            "protocolVersion": params["protocolVersion"].as_str().unwrap_or(PROTOCOL_VERSION),
            "capabilities": {"tools": {}},
            "serverInfo": {"name": SERVER_NAME, "version": "1"},
        })),

        Some("ping") => Ok(json!({})),

        Some("tools/list") => {
            let tools: Vec<Value> = Tool::ALL
                .iter()
                .map(|tool| {
                    json!({
                        "name": tool.name(),
                        "description": tool.description(),
                        "inputSchema": tool.input_schema(),
                    })
                })
                .collect();
            Ok(json!({"tools": tools}))
        }

        Some("tools/call") => {
            let tool = params["name"]
                .as_str()
                .and_then(Tool::named)
                .ok_or_else(|| RpcError::UnknownTool(params["name"].clone()))?;
            let arguments: Map<String, Value> =
                params["arguments"].as_object().cloned().unwrap_or_default();

            let (text, failed) = match tool.run(workspace, &arguments) {
                Ok(text) => (text, false),
                Err(error) => (error.to_string(), true),
            };
            Ok(json!({"content": [{"type": "text", "text": text}], "isError": failed}))
        }

        method => Err(RpcError::UnknownMethod(method.map(str::to_string))),
    }
}
