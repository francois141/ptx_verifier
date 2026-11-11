# volta_py

The `volta` Python module: Python bindings for the Volta engine, written with PyO3 and
built with maturin.

## What you can call

| Function           | Input                          | What it does                                                              |
|--------------------|--------------------------------|---------------------------------------------------------------------------|
| `parse`            | PTX source                     | Checks the syntax.                                                        |
| `analyze`          | PTX source                     | Runs the kernel and its graph checks; returns its outputs and stats.      |
| `verify`           | PTX source + spec              | Checks the kernel's outputs against the spec.                             |
| `solve`            | Kernel file (PTX, AMD, NKI)    | Checks the kernel against a spec with the canonical solver.               |
| `extract_lean`     | Kernel file (PTX, AMD, NKI)    | Writes the kernel's claims as Lean propositions to prove.                 |
| `prove_lean`       | Kernel file (PTX, AMD, NKI)    | Extracts the propositions, then has Claude Code prove them in Lean.       |
| `check_lean_proof` | A directory with a proof       | Runs Volta's acceptance check on an existing `proof.lean`.                |

`compare` is not exposed yet; [volta_cli](../volta_cli) has every command.

## Quick example

```python
import volta

config = volta.Config(block=(4, 1, 1))
config.add_array(volta.ArrayDef("in", 0x10000, 4, 4, volta.ArrayKind.Input))
config.add_array(volta.ArrayDef("out", 0x20000, 4, 4, volta.ArrayKind.Output))
config.add_param(volta.Param.array_ptr("in"))
config.add_param(volta.Param.array_ptr("out"))

volta.parse(ptx_source)
result = volta.analyze(ptx_source, config)

spec = "dim N; array in[N]; array out[N]; out[i] = in[i];"
v = volta.verify(ptx_source, spec, config, dims={"N": 4})
assert v.equivalent and v.mismatches == []
```

`Config`, `ArrayDef`, `ArrayKind` and `Param` match the Rust launch config one to one.

## Proving a kernel in Lean

```python
result = volta.prove_lean(
    "examples/lean/sigmoid_4096.s",
    config,
    spec="dim N; array a[N]; array out[N]; out[i] = 1 / (1 + exp(-a[i]));",
    dims={"N": 4096},
    tolerance="1/1000",
    output_dir="target/lean/sigmoid_amd_4096",
    verbose=True,
)
print(result.proved, result.duration_seconds, result.cost_usd)
```

`prove_lean` does four things:

1. Runs the kernel and its graph checks. A race raises `DataRaceError`, a deadlock
   `DeadlockError`.
2. Checks the outputs against the spec with the canonical solver (skip it with
   `equivalence=False`).
3. Writes `challenge.lean`: one proposition per output.
4. Starts Claude Code, which writes `proof.lean` until Volta's check accepts it.

`result.proved` is the verdict of Volta's final check, never Claude's.

### What you need

- **A Lean project**: a Lake project with Mathlib built, as `lean_project=` or
  `$VOLTA_LEAN_PROJECT`.
- **Claude Code**, installed and logged in. It runs on your login, so no API key is
  needed. Volta looks for it at `claude=`, then `$VOLTA_CLAUDE`, `PATH`, then VS Code's
  copy.

### Verbose mode

With `verbose=True`, `prove_lean` prints each step to stderr as it happens, with the clock
time and the time since the call began:

- the kernel analyzed, each graph check with its verdict and time, and the equivalence
  verdict;
- the challenge generated, written and compiled;
- Claude Code starting the proof, then each thing it says and every tool it calls
  (`write_proof`, `check_proof`, ...) with the result;
- the final check's verdict;
- a summary: how many statements were proved, the total time, the agent's turns and
  time, the cost, and the tokens used.

The same lines go to Python's `logging` (as `INFO`) whether or not `verbose` is set.

### Options

| Option         | Default                     | Meaning                                                  |
|----------------|-----------------------------|----------------------------------------------------------|
| `tolerance`    | `None` (exact equality)     | Allowed error per output, a rational such as `"1/1000"`. |
| `equivalence`  | `True`                      | Run the canonical solver first.                          |
| `model`        | `volta.DEFAULT_PROVE_MODEL` | The Claude model.                                        |
| `effort`       | `"high"`                    | Claude Code's effort level.                              |
| `max_turns`    | `60`                        | How many turns the agent may take.                       |
| `verbose`      | `False`                     | Print each step and a final summary.                     |

### The result (`LeanProof`)

| Field                                    | Meaning                                                        |
|------------------------------------------|----------------------------------------------------------------|
| `proved`                                 | Volta's final check accepted the proof.                        |
| `statements`, `proved_statements`        | How many propositions, and how many are proved.                |
| `challenge`, `proof`, `transcript`       | Paths in `output_dir`; the transcript has every session event. |
| `report`                                 | The final check's full report.                                 |
| `summary`, `turns`                       | The agent's last message and its number of turns.              |
| `duration_seconds`                       | How long the agent's session took.                             |
| `cost_usd`                               | Claude Code's estimate at API prices (a subscription is not billed per token). |
| `usage`                                  | Token counts, as a dict.                                       |
| `isa`, `race_verified`                   | The kernel's ISA, and `True` when its graph checks passed (`None` when the run records no graph). |
| `equivalence`, `equivalence_evidence`    | The canonical solver's verdict and its evidence.               |

An existing `proof.lean` in `output_dir` is the agent's starting point. To recheck a proof
without the agent, call `volta.check_lean_proof(output_dir)`. See
[volta_lean](../backend/volta_lean) for the agent's tools and what the check accepts.

[examples/lean/prove_sigmoid_amd.py](../../examples/lean/prove_sigmoid_amd.py) proves the
AMD sigmoid over 4096 elements.

## Errors

| Exception       | Raised for                                  |
|-----------------|---------------------------------------------|
| `VoltaError`    | Every failure, and the base class below.    |
| `DataRaceError` | A data race found by the graph checks.      |
| `DeadlockError` | A deadlock.                                 |

Parse errors include a "line N, col M" snippet of the source.

## Logging

The Rust crates' logs go to Python's `logging`, under their crate names
(`volta_graph_check.suite`, ...). To see every stage:

```python
import logging
logging.basicConfig(level=logging.INFO)
```

## Source files

| File         | Contents                                                      |
|--------------|---------------------------------------------------------------|
| `config.rs`  | `Config`, `ArrayDef`, `ArrayKind`, `Param`.                   |
| `analyze.rs` | `parse` and `analyze`.                                        |
| `verify.rs`  | `verify`.                                                     |
| `solve.rs`   | `solve`.                                                      |
| `extract.rs` | `extract_lean`.                                               |
| `prove.rs`   | `prove_lean`, its verbose mode, and `check_lean_proof`.       |
| `error.rs`   | Rust errors to Python exceptions.                             |
| `logging.rs` | Rust logs to Python's `logging`.                              |

## Build

```sh
uv run --reinstall-package volta python script.py   # rebuild the extension, then run the script
```
