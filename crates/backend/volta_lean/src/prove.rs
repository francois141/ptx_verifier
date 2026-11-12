use std::fs;
use std::path::{Path, PathBuf};
use std::time::{Duration, Instant};

use crate::progress::report;
use crate::text::split_after_chars;
use crate::{
    AgentRun, CHALLENGE, ClaudeCode, Error, LeanCheck, Observer, PER_STATEMENT_LINE, Progress,
    ToolServer, Workspace,
};

pub const DEFAULT_MODEL: &str = "claude-opus-5-5";
pub const TRANSCRIPT: &str = "transcript.jsonl";
const QUOTED_LIMIT: usize = 30_000;

/// What `prove` produced; `check.proved` only when the final check accepted `proof`.
#[derive(Clone, Debug)]
pub struct LeanProof {
    pub check: LeanCheck,
    pub challenge: PathBuf,
    pub proof: PathBuf,
    pub transcript: PathBuf,
    pub agent: AgentRun,
    pub duration: Duration,
}

/// Writes `challenge` as `directory/challenge.lean`, then has `agent` write `proof.lean`, the
/// one file its tools can change, until Volta's check accepts it or the session ends. An
/// existing `proof.lean` is the starting point, else one `sorry` per statement. The verdict is
/// the final check's, never the agent's. `observer` receives each step as it happens.
pub fn prove(
    challenge: &str,
    directory: &Path,
    project: Option<&Path>,
    agent: &ClaudeCode,
    server: &ToolServer,
    observer: Observer<'_>,
) -> Result<LeanProof, Error> {
    fs::create_dir_all(directory).map_err(Error::io(directory))?;
    let directory = fs::canonicalize(directory).map_err(Error::io(directory))?;
    let challenge_path = directory.join(CHALLENGE);
    fs::write(&challenge_path, challenge).map_err(Error::io(&challenge_path))?;
    let transcript = directory.join(TRANSCRIPT);
    report(
        observer,
        Progress::Compiling {
            challenge: challenge_path.clone(),
        },
    );

    let workspace = Workspace::open(&directory, challenge, project)?;
    let proof = workspace.proof();
    report(
        observer,
        Progress::Compiled {
            statements: workspace.statements().len(),
            proof: proof.clone(),
        },
    );
    if !proof.exists() {
        fs::write(&proof, skeleton(workspace.statements())).map_err(Error::io(&proof))?;
    }

    let task = task(challenge, &workspace)?;
    report(
        observer,
        Progress::AgentStarted {
            model: agent.model.clone(),
            effort: agent.effort.clone(),
            max_turns: agent.max_turns,
        },
    );
    let started = Instant::now();
    let run = agent.run(
        &workspace,
        &system_prompt(),
        &task,
        &transcript,
        server,
        observer,
    )?;
    let duration = started.elapsed();

    report(observer, Progress::AgentStopped { turns: run.turns });
    let mut check = workspace.check()?;
    drop(workspace);
    let written = fs::read_to_string(&challenge_path).map_err(Error::io(&challenge_path))?;
    if written != challenge {
        check = LeanCheck::incomplete(check.statements, "INCOMPLETE: challenge.lean changed.");
    }

    let verdict = check.report.lines().next().unwrap_or_default();
    report(observer, Progress::Verdict(verdict.to_string()));
    Ok(LeanProof {
        check,
        challenge: challenge_path,
        proof,
        transcript,
        agent: run,
        duration,
    })
}

/// Checks `directory`'s `proof.lean` against its `challenge.lean`, as `prove` does.
pub fn check_lean_proof(directory: &Path, project: Option<&Path>) -> Result<LeanCheck, Error> {
    let path = directory.join(CHALLENGE);
    let challenge = fs::read_to_string(&path).map_err(Error::io(&path))?;
    Workspace::open(directory, &challenge, project)?.check()
}

/// A `proof.lean` with one `sorry` per statement.
pub fn skeleton(statements: &[String]) -> String {
    let theorems: String = statements
        .iter()
        .map(|s| format!("theorem {s} : VoltaChallenge.{s} := by\n  sorry\n\n"))
        .collect();
    format!("import challenge\n\nnamespace VoltaProofs\n\n{theorems}end VoltaProofs\n")
}

fn task(challenge: &str, workspace: &Workspace) -> Result<String, Error> {
    let names = workspace.statements();
    let span = match (names.first(), names.last()) {
        (Some(first), Some(last)) => format!(", {first} to {last}"),
        _ => String::new(),
    };
    let proof = workspace.proof();
    let current = fs::read_to_string(&proof).map_err(Error::io(&proof))?;

    Ok([
        format!("challenge.lean states {} propositions{span}.", names.len()),
        quoted("challenge.lean", challenge, "read_challenge"),
        quoted("proof.lean now", &current, "read_proof"),
    ]
    .join("\n\n"))
}

/// `text` in a Lean block, or its head when longer than the task should carry.
fn quoted(title: &str, text: &str, tool: &str) -> String {
    let Some((head, _)) = split_after_chars(text, QUOTED_LIMIT) else {
        return format!("{title}:\n```lean\n{text}```");
    };

    let head = head.rsplit_once('\n').map_or(head, |(lines, _)| lines);
    let shown = head.matches('\n').count() + 1;
    let total = text.matches('\n').count();
    format!(
        "{title}, lines 1 to {shown} of {total} (read the rest with {tool}):\n```lean\n{head}\n```"
    )
}

fn system_prompt() -> String {
    format!(
        "You prove Lean 4 propositions that Volta, a GPU kernel verifier, extracted from a kernel: \
each `VoltaChallenge.<name>` in challenge.lean states that one output element of the kernel \
equals, or is within a tolerance of, its specification over the reals.

challenge.lean is fixed and no tool can change it; read_challenge reads it. proof.lean is yours: \
write_proof replaces it and read_proof shows it. It must `import challenge` (any other import \
must be a Mathlib module) and, inside `namespace VoltaProofs`, prove `theorem <name> : \
VoltaChallenge.<name>` for every statement, without `sorry` and with no axioms beyond propext, \
Classical.choice and Quot.sound.

check_proof runs the check Volta itself uses to accept the proof: it compiles proof.lean, gives \
each statement's status and replays the proof in Lean's kernel. A run takes a minute or more, so \
fix what you can between runs. search_library searches the Lean sources of Mathlib and Lean's \
core library, for lemma names and statements.

The proof must be plain mathematics. check_proof refuses to compile a proof.lean that runs code \
or extends Lean, and so contains, even in a comment: #eval, #guard, run_cmd, run_tac, run_elab, \
run_meta, elab, elab_rules, initialize, command_elab, term_elab, a [tactic] attribute, \
implemented_by, extern, native_decide, unsafe, or a debug option.

Statements usually share one shape and differ in their input names: prove a general lemma once \
and instantiate it per statement. With many statements, give write_proof a `per_statement` \
template rather than writing each instance: it expands at the line `{PER_STATEMENT_LINE}`. You \
are done when check_proof reports COMPLETE. If a statement is false, stop and explain why, with \
a counterexample: that is a finding about the kernel or its tolerance, not a failure to prove it."
    )
}
