use std::env;
use std::ffi::OsString;
use std::fs::{self, DirBuilder};
use std::io;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::LazyLock;
use std::thread;

use regex::Regex;
use serde::{Deserialize, Serialize};

use crate::library::Library;
use crate::process::{self, Finished};
use crate::text::line_of;
use crate::{Error, Toolchain};

pub const CHALLENGE: &str = "challenge.lean";
pub const PROOF: &str = "proof.lean";

/// Run as `lean --run`; it imports `proof` only at run time, so nothing `proof` declares can
/// change the check.
const CHECK_SCRIPT: &str = include_str!("check_proof.lean");
const CHECK_SCRIPT_FILE: &str = "check_proof.lean";
const PROOF_MODULE: &str = "proof";

const LISTED_FAILURES: usize = 40;
const LISTED_NAMES: usize = 8;

static STATEMENT: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?m)^def (\S+) : Prop :=$").expect("a valid regex"));

static IMPORT: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"(?m)^\s*import\s+(\S+)").expect("a valid regex"));

static ALLOWED_IMPORT: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"^(?:challenge|Mathlib(?:\.\w+)*)$").expect("a valid regex"));

// What runs code or extends Lean while proof.lean compiles: it could write files or fool the check.
static FORBIDDEN: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(
        r"#eval|#guard\b|\[\s*tactic\b|\bdebug\.|\bunsafe\w*|\b(?:run_cmd|run_elab|run_meta|run_tac|elab|elab_rules|initialize|builtin_initialize|command_elab|term_elab|implemented_by|extern|native_decide)\b",
    )
    .expect("a valid regex")
});

/// Volta's verdict on a `proof.lean`; `report` is the text the proving agent reads.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct LeanCheck {
    pub proved: bool,
    pub statements: usize,
    pub proved_statements: usize,
    pub report: String,
}

impl LeanCheck {
    pub(crate) fn incomplete(statements: usize, report: impl Into<String>) -> LeanCheck {
        LeanCheck {
            proved: false,
            statements,
            proved_statements: 0,
            report: report.into(),
        }
    }
}

/// What another process needs to reopen a workspace over the same build directory.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct WorkspaceConfig {
    pub directory: PathBuf,
    pub statements: Vec<String>,
    pub build: PathBuf,
    pub toolchain: Toolchain,
}

/// An output directory's `proof.lean`, checked against a challenge compiled from Volta's own
/// text into a private `build` directory, which holds `challenge.olean` and the proof's build.
pub struct Workspace {
    directory: PathBuf,
    statements: Vec<String>,
    build: PathBuf,
    toolchain: Toolchain,
    library: Library,
    lean_path: OsString,
    owned_build: Option<TempDir>,
}

impl Workspace {
    /// `directory`'s workspace, with `challenge` compiled into a new build directory, removed
    /// when the workspace is dropped.
    pub fn open(
        directory: &Path,
        challenge: &str,
        project: Option<&Path>,
    ) -> Result<Workspace, Error> {
        let toolchain = Toolchain::of(project)?;
        let build = TempDir::new()?;

        let config = WorkspaceConfig {
            directory: fs::canonicalize(directory).map_err(Error::io(directory))?,
            statements: STATEMENT
                .captures_iter(challenge)
                .map(|c| c[1].to_string())
                .collect(),
            build: build.0.clone(),
            toolchain,
        };

        let mut workspace = Workspace::from_config(config)?;
        workspace.owned_build = Some(build);
        workspace.compile_challenge(challenge)?;
        Ok(workspace)
    }

    /// The workspace `config` describes, its challenge already compiled; it leaves `build` in
    /// place when dropped.
    pub fn from_config(config: WorkspaceConfig) -> Result<Workspace, Error> {
        let lean_path =
            env::join_paths(std::iter::once(&config.build).chain(&config.toolchain.lean_path))
                .map_err(|error| Error::Io {
                    path: config.build.clone(),
                    error: io::Error::new(io::ErrorKind::InvalidInput, error),
                })?;

        Ok(Workspace {
            directory: config.directory,
            statements: config.statements,
            build: config.build,
            library: Library::new(config.toolchain.sources.clone()),
            toolchain: config.toolchain,
            lean_path,
            owned_build: None,
        })
    }

    pub fn config(&self) -> WorkspaceConfig {
        WorkspaceConfig {
            directory: self.directory.clone(),
            statements: self.statements.clone(),
            build: self.build.clone(),
            toolchain: self.toolchain.clone(),
        }
    }

    /// The names of the challenge's statements (`out_0`, ...), in order.
    pub fn statements(&self) -> &[String] {
        &self.statements
    }

    pub fn proof(&self) -> PathBuf {
        self.directory.join(PROOF)
    }

    pub fn build(&self) -> &Path {
        &self.build
    }

    pub(crate) fn library(&self) -> &Library {
        &self.library
    }

    /// The challenge as compiled, which no tool of the agent can change.
    pub(crate) fn challenge(&self) -> Result<String, Error> {
        let path = self.build.join(CHALLENGE);
        fs::read_to_string(&path).map_err(Error::io(path))
    }

    fn compile_challenge(&self, challenge: &str) -> Result<(), Error> {
        let source = self.build.join(CHALLENGE);
        fs::write(&source, challenge).map_err(Error::io(&source))?;

        let compiled = process::run(
            self.command(&self.toolchain.lean)
                .arg("-R")
                .arg(&self.build)
                .arg("-o")
                .arg(self.build.join("challenge.olean"))
                .arg(&source),
        )?;

        if compiled.succeeded() {
            Ok(())
        } else {
            Err(Error::ChallengeDoesNotCompile(compiled.messages()))
        }
    }

    fn command(&self, program: &Path) -> Command {
        let mut command = Command::new(program);
        command
            .current_dir(&self.build)
            .env("LEAN_PATH", &self.lean_path);
        command
    }

    /// Compiles `proof.lean` and accepts it only when every statement has a `VoltaProofs.<name>`
    /// of type exactly `VoltaChallenge.<name>`, using no axioms beyond `propext`,
    /// `Classical.choice` and `Quot.sound`, and `leanchecker` replays it in the kernel.
    pub fn check(&self) -> Result<LeanCheck, Error> {
        let total = self.statements.len();
        let proof = self.proof();
        if !proof.is_file() {
            return Ok(LeanCheck::incomplete(
                total,
                "INCOMPLETE: proof.lean does not exist.",
            ));
        }

        let text = fs::read_to_string(&proof).map_err(Error::io(&proof))?;
        let problems = policy_problems(&text);
        if !problems.is_empty() {
            let report = format!(
                "INCOMPLETE: proof.lean was not compiled.\n{}",
                problems.join("\n")
            );
            return Ok(LeanCheck::incomplete(total, report));
        }

        let olean = self.build.join(format!("{PROOF_MODULE}.olean"));
        match fs::remove_file(&olean) {
            Err(error) if error.kind() != io::ErrorKind::NotFound => {
                return Err(Error::Io { path: olean, error });
            }
            _ => {}
        }

        let compiled = process::run(
            self.command(&self.toolchain.lean)
                .arg("-R")
                .arg(&self.directory)
                .arg("-o")
                .arg(&olean)
                .arg(&proof),
        )?;

        let messages = compiled.messages();
        if !compiled.succeeded() || !olean.exists() {
            let report = format!("INCOMPLETE: proof.lean does not compile.\n{messages}");
            return Ok(LeanCheck::incomplete(total, report));
        }

        let script = self.build.join(CHECK_SCRIPT_FILE);
        fs::write(&script, CHECK_SCRIPT).map_err(Error::io(&script))?;
        let (statements, replay) = thread::scope(|scope| {
            let replay = scope.spawn(|| {
                process::run(self.command(&self.toolchain.leanchecker).arg(PROOF_MODULE))
            });
            let statements =
                process::run(self.command(&self.toolchain.lean).arg("--run").arg(&script));
            (
                statements,
                replay.join().expect("running leanchecker does not panic"),
            )
        });
        
        let (statements, replay) = (statements?, replay?);

        if !statements.succeeded() {
            let report = format!(
                "INCOMPLETE: the statement check failed.\n{}",
                statements.messages()
            );
            return Ok(LeanCheck::incomplete(total, report));
        }

        let verdicts = statements
            .stdout()
            .lines()
            .filter(|line| !line.trim().is_empty())
            .map(parse_verdict)
            .collect::<Result<Vec<_>, _>>()?;
        Ok(report(&verdicts, &replay, &messages))
    }
}

/// Why the statement check left a statement unproved, or that it proved it.
enum Verdict {
    Proved,
    Missing,
    Mistyped,
    Unproved,
    Axioms(Vec<String>),
}

impl Verdict {
    /// The same words for every statement with this reason.
    fn failure(&self) -> Option<String> {
        match self {
            Verdict::Proved => None,
            Verdict::Missing => Some("there is no theorem VoltaProofs.<name>.".to_string()),
            Verdict::Mistyped => {
                Some("VoltaProofs.<name> does not have type VoltaChallenge.<name>.".to_string())
            }
            Verdict::Unproved => Some("VoltaProofs.<name> has no proof.".to_string()),
            Verdict::Axioms(axioms) => Some(format!("the proof uses {}.", axioms.join(", "))),
        }
    }
}

/// One line of `check_proof.lean`'s output: `proved NAME`, `missing NAME`, `mistyped NAME`,
/// `unproved NAME` or `axioms NAME AXIOM...`.
fn parse_verdict(line: &str) -> Result<(String, Verdict), Error> {
    let unexpected = || Error::UnexpectedCheckOutput(line.to_string());
    let mut words = line.split_whitespace();
    let (Some(kind), Some(name)) = (words.next(), words.next()) else {
        return Err(unexpected());
    };

    let verdict = match kind {
        "proved" => Verdict::Proved,
        "missing" => Verdict::Missing,
        "mistyped" => Verdict::Mistyped,
        "unproved" => Verdict::Unproved,
        "axioms" => Verdict::Axioms(words.map(str::to_string).collect()),
        _ => return Err(unexpected()),
    };
    Ok((name.to_string(), verdict))
}

fn report(verdicts: &[(String, Verdict)], replay: &Finished, messages: &str) -> LeanCheck {
    let total = verdicts.len();
    let proved = verdicts
        .iter()
        .filter(|(_, verdict)| matches!(verdict, Verdict::Proved))
        .count();

    let mut unproved: Vec<(String, Vec<&str>)> = Vec::new();
    for (name, verdict) in verdicts {
        let Some(reason) = verdict.failure() else {
            continue;
        };
        match unproved.iter_mut().find(|(known, _)| *known == reason) {
            Some((_, names)) => names.push(name),
            None => unproved.push((reason, vec![name])),
        }
    }

    let complete = total > 0 && proved == total && replay.succeeded();
    let mut lines = vec![
        if complete {
            format!("COMPLETE: all {total} statements proved.")
        } else {
            format!("INCOMPLETE: {proved} of {total} statements proved.")
        },
        if replay.succeeded() {
            "Kernel replay (leanchecker): passed.".to_string()
        } else {
            format!(
                "Kernel replay (leanchecker): failed.\n{}",
                replay.messages()
            )
        },
    ];
    lines.extend(
        unproved
            .iter()
            .take(LISTED_FAILURES)
            .map(|(reason, names)| format!("{}: {reason}", listed(names))),
    );
    if unproved.len() > LISTED_FAILURES {
        lines.push(format!(
            "... and {} more reasons.",
            unproved.len() - LISTED_FAILURES
        ));
    }
    if !messages.is_empty() {
        lines.push(format!("Lean messages:\n{messages}"));
    }

    LeanCheck {
        proved: complete,
        statements: total,
        proved_statements: proved,
        report: lines.join("\n"),
    }
}

fn listed(names: &[&str]) -> String {
    if names.len() <= LISTED_NAMES {
        return names.join(", ");
    }
    format!(
        "{} and {} more ({} statements)",
        names[..LISTED_NAMES].join(", "),
        names.len() - LISTED_NAMES,
        names.len()
    )
}

fn policy_problems(text: &str) -> Vec<String> {
    let imports: Vec<&str> = IMPORT
        .captures_iter(text)
        .map(|c| c.get(1).expect("the module group").as_str())
        .collect();

    let mut problems = Vec::new();
    if !imports.contains(&"challenge") {
        problems.push("proof.lean must `import challenge`.".to_string());
    }
    problems.extend(
        imports
            .iter()
            .filter(|module| !ALLOWED_IMPORT.is_match(module))
            .map(|module| {
                format!("`import {module}`: only challenge and Mathlib modules may be imported.")
            }),
    );
    problems.extend(FORBIDDEN.find_iter(text).map(|found| {
        format!(
            "line {}: `{}` runs code or extends Lean.",
            line_of(text, found.start()),
            found.as_str()
        )
    }));
    problems
}

/// A new private directory, removed with everything in it when dropped.
struct TempDir(PathBuf);

impl TempDir {
    fn new() -> Result<TempDir, Error> {
        let parent = env::temp_dir();
        let mut builder = DirBuilder::new();
        #[cfg(unix)]
        std::os::unix::fs::DirBuilderExt::mode(&mut builder, 0o700);

        let mut attempt = 0u32;
        loop {
            let path = parent.join(format!("volta-lean-{}-{attempt}", std::process::id()));
            match builder.create(&path) {
                Ok(()) => return Ok(TempDir(fs::canonicalize(&path).unwrap_or(path))),
                Err(error) if error.kind() == io::ErrorKind::AlreadyExists => attempt += 1,
                Err(error) => return Err(Error::Io { path, error }),
            }
        }
    }
}

impl Drop for TempDir {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.0);
    }
}
