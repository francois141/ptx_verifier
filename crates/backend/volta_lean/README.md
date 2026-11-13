# volta_lean

Proves Volta's obligations in Lean. Volta states them as a `challenge.lean` module
(`volta_pipeline`'s `extract_lean`: one `def <array>_<index> : Prop` per output element,
in `namespace VoltaChallenge`). This crate has a Claude Code agent write a matching
`proof.lean`, then decides on its own whether to accept it.

It generates challenges from `volta_expr::SymbolicOutputs` with `to_lean`. The prover
also accepts challenges as plain text; `volta_py`'s `prove_lean` connects it to
`volta_pipeline`. Every module is private; `lib.rs`
re-exports the API.

## Lean challenges (`extract.rs`)

`to_lean(candidate, baseline, arrays, claim, namespace)` writes a Lean 4 / Mathlib
module with one `def <array>_<index> : Prop` per element both sides write of the
named arrays. Each one states the candidate's value against the baseline's, either
`Claim::Equal` (`c = b`) or `Claim::Within(tol)` (`|c - b| ≤ tol`, with `tol` an exact
rational). A prover, such as an LLM, proves `theorem out_0 : NS.out_0` in a module of its
own. Because the statement is a definition the prover does not write, it cannot weaken
the claim; checking a solution means building it and confirming `#print axioms` shows
no `sorryAx`.

- Values are `ℝ`. An input element `a[i]` is the real variable `a_i`, a parameter
  or machine symbol is an `ℝ` variable, and every variable is universally quantified
  (two inputs that would share a Lean name are a `DuplicateName` error).
  Comparisons and boolean ops become `Prop`s and `select` becomes `if … then … else`.
- Every literal is ascribed `ℝ` and exact: an integer, a short decimal, `p / 2 ^ k` or `p / q`.
- A non-leaf real node used twice within an element becomes a `let`, so the statement's size
  stays linear in the DAG.
- Bitwise ops, `rem`, infinities, symbolic reads and undefined values have no real-number
  form and are errors, as is mixing truth values with numbers.
- Lean's total conventions (`x / 0 = 0`, `log`, `sqrt` of negatives) apply where Volta's
  arithmetic is undefined.

`just extract-lean` writes the AMD sigmoid one to `target/lean/sigmoid.lean`.

## How it works

1. `prove` writes `challenge.lean` and a starting `proof.lean` (the existing one, or one
   `sorry` per statement).
2. A `claude -p` session edits the proof, using only Volta's tools, served over MCP.
3. A final check decides: `LeanProof.check.proved` is its verdict, never the agent's.

## What the check accepts

A proof is accepted only if:

- it imports nothing but `challenge` and Mathlib, and cannot run code while compiling
  (`#eval`, `run_tac`, `elab`, `native_decide`, ...);
- every statement has a `VoltaProofs.<name>` whose type is exactly `VoltaChallenge.<name>`;
- it uses no axioms beyond `propext`, `Classical.choice` and `Quot.sound`;
- `leanchecker` replays it in the kernel;
- `challenge.lean` did not change during the session.

The challenge is compiled from Volta's own text into a private build directory, and the
statement check imports the modules at run time, so nothing the proof declares can affect
it. Lean's and Mathlib's axioms are trusted. A check takes about a minute, mostly
importing Mathlib.

## Modules

| Module             | Role                                                                                                        |
|--------------------|-------------------------------------------------------------------------------------------------------------|
| `prove.rs`         | `prove` runs the whole loop (files, agent session, final check); `check_lean_proof` runs the check alone.   |
| `workspace.rs`     | `Workspace` compiles the challenge into a private build directory and checks `proof.lean` against it.       |
| `check_proof.lean` | The embedded Lean program, run as `lean --run`, that checks each statement's type and axioms.               |
| `claude_code.rs`   | `ClaudeCode` runs a `claude -p` session with only Volta's tools and logs every event to `transcript.jsonl`. |
| `progress.rs`      | `Progress`, each step of `prove`: logged as `[lean] ...` and passed to the caller's `observer`.              |
| `tools.rs`         | `Tool::ALL`, the agent's only actions: read the challenge, read or write the proof, check it, search Mathlib. |
| `mcp.rs`           | Serves those tools as a stdio JSON-RPC MCP server (`serve`, `serve_stdio`).                                 |
| `toolchain.rs`     | `Toolchain` finds `lean`, `leanchecker`, `LEAN_PATH` and the library sources of a Lake project.             |
| `library.rs`       | Regex search over the library's Lean sources, read on the first search.                                     |
| `process.rs`       | Runs Lean and Lake, killing any run (and so any tool call) after an hour.                                   |
| `text.rs`          | Caps long text at 30,000 characters for tool results and the agent's task.                                  |
| `error.rs`         | `Error`, the crate's one error type, grouped by toolchain, files and processes, the check, and the session. |

## Setup

- **Lean project**: a Lake project with Mathlib built, passed explicitly or as
  `$VOLTA_LEAN_PROJECT`.
- **Claude binary**: `find_claude` tries an explicit path, then `$VOLTA_CLAUDE`, `PATH` and
  `$CLAUDE_CODE_EXECPATH`.
- **Tool server**: the caller gives the command that starts the MCP server (`ToolServer`),
  since a Python extension cannot exec itself; `WorkspaceConfig` lets that process reopen
  the same workspace.
- **Many statements**: `write_proof` takes an optional `per_statement` template, `{name}`
  expanding for each statement at the line `-- volta: per statement`, so thousands of
  instances cost the agent no output.
