# volta_py

Python bindings (PyO3, built with maturin) for the Volta engine, published as
the `volta` Python module. PTX source APIs are `parse`, `analyze` and `verify`;
`solve` and `extract_lean` accept kernel files for PTX, AMD and Trainium.
`compare` is not exposed yet; see `volta_cli` for the full command set.

```python
import volta

config = volta.Config(block=(4, 1, 1))  # mirrors volta_ptx_analysis::AnalysisConfig
config.add_array(volta.ArrayDef("in", 0x10000, 4, 4, volta.ArrayKind.Input))
config.add_array(volta.ArrayDef("out", 0x20000, 4, 4, volta.ArrayKind.Output))
config.add_param(volta.Param.array_ptr("in"))
config.add_param(volta.Param.array_ptr("out"))
volta.parse(ptx_source)                  # raises VoltaError on a syntax error
result = volta.analyze(ptx_source, config, kernel=None)  # DataRaceError / DeadlockError on findings
v = volta.verify(ptx_source, "dim N; array in[N]; array out[N]; out[i] = in[i];",
                 config, dims={"N": 4}, sample=0, verify_numeric=False)
assert v.equivalent and v.mismatches == []
```

## Modules

- `solve.rs`: `solve(path, config=None, spec=..., dims=...)` checks outputs
  with the canonical solver and returns a `SolveResult` with its verdict.
- `extract.rs`: `extract_lean(path, config=None, spec=..., dims=..., tolerance=None)`
  returns a `LeanExtraction` with `lean`, `statements`, `isa` and `race_verified`.
  Detected races raise `DataRaceError`, deadlocks raise `DeadlockError`, and other
  failed or incomplete graph checks raise `VoltaError` before any module is returned.
  A kernel whose run records no graph returns `race_verified=None`.
  The propositions still need proofs. This replaces `solve(..., solver="lean")`.
- `logging.rs`: the native module forwards the Rust crates' info-level logs
  (`[analysis]`, `[graph]` with each of the ten checks, `[equivalence]`) to Python's
  `logging`, under the logger its target names (`volta_graph_check.suite`), so
  `logging.basicConfig(level=logging.INFO)` shows each stage.
- `config.rs`: Python classes that wrap the Rust config types one to one
  (`Config`, `ArrayDef`, `ArrayKind`, `Param`), instead of the CLI's string
  mini-language (`"x:0x10000:4:128:in"`).
- `analyze.rs`: `parse` and `analyze`. They run the analysis and the graph
  checks, and return `AnalyzeResult` (outputs, `Stats`).
- `verify.rs`: `verify`. It instantiates a spec with caller-supplied `dims`,
  unfolds it into `SymbolicOutputs` standing in for a second kernel, and runs
  the equivalence check. It returns `VerifyResult` (`equivalent`, `mismatches`,
  `elements_checked`/`elements_total`, `stats`). `sample=` limits the checked
  elements.
- `error.rs`: maps Rust errors to Python exceptions: `VoltaError`, and its
  `DataRaceError` and `DeadlockError` for graph-check failures. Parse errors
  render their own "line N, col M" snippet, since in-memory source has no
  `FileCache`.

## Build and test

```sh
just test    # includes: uv run --reinstall-package volta pytest crates/volta_py
```

Tests are in `tests/` (`test_analyze.py`, `test_verify.py`, with shared kernels
in `kernels.py`).
