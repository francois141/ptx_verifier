<p align="center">
  <img src="volta-logo.png" alt="Volta architecture: NVIDIA PTX, AMD Assembly, and AWS Trainium NKI frontends feed a shared Race Detector &amp; Extractor, which branches to independent Fast Canonical Solver and Powerful Lean Solver backends." width="1200">
</p>

<h1 align="center">Prove race freedom. Extract Lean expressions.</h1>

<p align="center">
  <strong>Multi-ISA · Multi-Solver · Assembly to Lean</strong><br>
  Analyze accelerator kernels automatically. Choose the Fast Canonical Solver or the Powerful Lean Solver.
</p>

<p align="center">
  <a href="Cargo.toml"><img src="https://img.shields.io/badge/Rust-2024-f97316?style=flat-square" alt="Rust edition 2024"></a>
  <a href="#powerful-lean-solver"><img src="https://img.shields.io/badge/Lean-4-2563eb?style=flat-square" alt="Lean 4"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-65a30d?style=flat-square" alt="MIT license"></a>
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> ·
  <a href="#fast-canonical-solver">Fast Canonical Solver</a> ·
  <a href="#powerful-lean-solver">Powerful Lean Solver</a> ·
  <a href="#frontends">Frontends</a> ·
  <a href="#python">Python</a> ·
  <a href="#cli-reference">CLI reference</a>
</p>

---

> [!WARNING]
> **Under active development.** We are actively building Volta, and not everything is ready yet. Some features, instruction support, and solver workflows are still being implemented and may change.

**Volta is a multi-ISA, multi-solver framework for automatically proving race freedom and extracting Lean expressions from assembly kernels.** It supports NVIDIA PTX, AMD assembly, and AWS Trainium NKI kernels. The PTX backend analyzes memory accesses and synchronization to check for data races and deadlocks; the frontends recover symbolic output expressions for equivalence checking and Lean export.

The architecture brings three frontends into a shared race-detection and extraction stage, then branches into two independent solver backends. The **Fast Canonical Solver** automatically checks symbolic equivalence against a reference kernel or a mathematical specification. The **Powerful Lean Solver** exports expressions as Lean 4 proof goals for proving equality or a chosen error bound with Mathlib. Both paths use the extracted expressions directly.

Writing a fused kernel, reviewing an AI-generated implementation, or porting an operation to another accelerator? Volta connects the implementation to the formula it is meant to compute.

| Capability | What you get |
| --- | --- |
| **Multi-ISA extraction** | Symbolic output expressions from NVIDIA PTX, AMD assembly, and AWS Trainium NKI kernels. |
| **Automatic race checks** | Event-graph checks for data races, deadlocks, and synchronization in PTX kernels. |
| **Fast Canonical Solver** | Automated equivalence checks against a reference kernel or spec using algebraic canonicalization. |
| **Powerful Lean Solver** | Extracted Lean expressions and equality or error-bound statements to prove in Lean 4 / Mathlib. |

## Quick start

From the repository root, with Rust and `just` installed:

```bash
cargo build --release -p volta_cli
just extract-lean
```

```text
Wrote target/lean/sigmoid.lean
```

Your first extraction: **64 Lean propositions** comparing an AMD sigmoid kernel with `1 / (1 + exp(-x))`, each with an absolute error tolerance of `0.001`.

The example uses the checked-in [kernel](crates/volta_amd_analysis/tests/fixtures/sigmoid.s) and [specification](crates/volta_amd_analysis/tests/fixtures/sigmoid.spec). Follow the [extraction code](crates/volta_amd_analysis/tests/lean_tests.rs) to adapt it to your own kernels. No accelerator is needed to run this example.

## Fast Canonical Solver

The automatic equivalence path in Volta's multi-solver framework. The Fast Canonical Solver rewrites symbolic expressions into canonical forms and compares each output element against a reference kernel or specification, sharing work across expressions.

Try the included PTX kernel, which fuses a ReLU clamp with an `f32`-to-`f16` conversion:

```bash
relu=crates/volta_pipeline/tests/ptx/success/relu_epilogue_vs_explicit_max_fused.ptx

./target/release/volta verify "$relu" \
  'dim N; array x[N]; array out[N]; out[i] = max(x[i], 0);' \
  -k k -b 128 --dim N=128 \
  --array x:0x10000:4:128:in --array out:0x20000:2:128:out \
  --param ptr:x --param ptr:out
```

```text
EQUIVALENT (matches spec)
VERDICT: ACCEPT
```

Floating-point values are modeled as real numbers. PTX runs also check for data races and deadlocks. Use `compare` to check two kernels, or save `.vexpr` outputs to repeat comparisons without rerunning extraction. The [CLI reference](#cli-reference) covers these workflows.

## Powerful Lean Solver

The Lean proof path in Volta's multi-solver framework. Extract expressions from the kernel and turn them into explicit proof goals: the Lean exporter writes one proposition per output element, with universally quantified real inputs and exact constants.

| Claim | Generated statement |
| --- | --- |
| `Claim::Equal` | Candidate output equals the reference output. |
| `Claim::Within(tolerance)` | The absolute difference is at most the chosen tolerance. |

Use [`volta_expr::lean::to_lean`](crates/volta_expr/src/lean.rs) with your candidate and reference symbolic outputs:

```rust
use volta_expr::lean::{Claim, to_lean};

let statements = to_lean(
    &candidate,
    &reference,
    &["out".to_string()],
    &Claim::Equal,
    "VoltaChallenge",
)?;
```

Import the generated file into a separate Lean module and prove its propositions with Lean tactics or a prover of your choice. Volta supplies the statements; your proof module supplies the proofs. See the [Lean export API](crates/volta_expr/README.md#lean-challenges-leanrs) and the [complete example](crates/volta_amd_analysis/tests/lean_tests.rs).

## Frontends

Different instruction sets, a shared symbolic expression format.

| Target | Kernel input | Entry point |
| --- | --- | --- |
| **NVIDIA** | PTX | CLI, Python, and [Rust API](crates/volta_ptx_analysis) |
| **AMD** | gfx950 assembly | [Rust API](crates/volta_amd_analysis) |
| **AWS Trainium** | NKI Python kernels using `nki.isa` | [Rust API](crates/volta_trainium_analysis) |

Frontends produce the shared expressions used by the Fast Canonical Solver and Powerful Lean Solver backends. Each frontend documents its supported instructions and launch configurations.

## CLI reference

The commands below use `volta` as shorthand for `./target/release/volta`. You can also run `cargo run --release -p volta_cli -- <command> ...` to build and run in one step. Examples here assume your own `relu.ptx`, reference kernels, and launch files; the [Fast Canonical Solver example](#fast-canonical-solver) above runs directly from this checkout.

<details>
<summary><strong>Extract outputs, check a specification, or compare two kernels</strong></summary>

The PTX CLI extracts symbolic outputs and provides race, deadlock, and equivalence checks. Kernels must have statically known sizes, and their addresses and branches must resolve from thread indices and concrete parameters, not from input values. Only CTA 0 is executed; it stands for every CTA of the grid.

### Extract a kernel's symbolic outputs

```bash
volta analyze relu.ptx -k relu -b 128 \
  --array x:0x10000:4:128:in --array out:0x20000:4:128:out \
  --param ptr:x --param ptr:out --emit-exprs relu.vexpr
```

Prints the symbolic outputs (`--print-outputs N`, default 8 per array), the verdict of each graph check, and `GRAPH VERIFICATION: VERIFIED | REJECTED | UNKNOWN` (exit 0/1/2). `--emit-exprs FILE` writes the outputs as `.vexpr` text, `--dump-graph FILE` the event graph.

### Check a kernel against a spec

```
# relu.spec
dim N;
array x[N];
array out[N];
out[i] = max(x[i], 0);
```

```bash
volta verify relu.ptx relu.spec -k relu -b 128 --dim N=128 \
  --array x:0x10000:4:128:in --array out:0x20000:4:128:out \
  --param ptr:x --param ptr:out
```

The spec can also be passed inline as a string. Each spec output must be declared `out` or `inout`, and each `dim` needs a `--dim NAME=VALUE`.

### Compare two kernels

```bash
volta compare ref.ptx opt.ptx --kernel1 ref --kernel2 opt -b 128 \
  --array x:0x10000:4:128:in --array out:0x20000:4:128:out \
  --param ptr:x --param ptr:out --check-array out
```

`--check-array NAME` (required, repeatable) names the outputs to compare. Arrays, params and globals are shared by both kernels; `--block2`/`--grid2` override the optimized kernel's dims.

`verify` and `compare` print `VERDICT: ACCEPT | REJECT | UNKNOWN` (exit 0/1/2) and take:

- `--sample N`: check at most N elements per array (a sampled check is never ACCEPT)
- `--verify-numeric`: confirm each verdict with an f64 oracle at random inputs
- `--recycle-terms N`: bound memory by recycling intern tables past N terms
- `--iterations N`: re-run the solve N times (timing and determinism check)

`compare` can skip symbolic execution: `--exprs a.vexpr b.vexpr` (from `analyze --emit-exprs`), or `--dump-vcs pair.vcdump` once and then `--from-dump pair.vcdump`.

</details>

<details>
<summary><strong>Launch flags and JSON configuration</strong></summary>

### Launch flags

`analyze`, `verify` and `compare` share these flags. They must match the kernel's parameters.

- `-b, --block X[,Y[,Z]]` / `-g, --grid X[,Y[,Z]]`: launch dims (default `1`)
- `--array name:base:elem_width:len:kind`: a global array of `len` elements of `elem_width` bytes at address `base`; `kind` is `in`, `out`, `inout` or `index` (concrete `a[i] = i`). Repeatable.
- `--param int:N | float:X | sym:name | ptr:array`: the kernel's parameters, in declaration order. Repeatable.
- `--global NAME=value`: value of a module-scope `.global` variable. Repeatable.
- `--dyn-shared N`: dynamic shared memory, in bytes
- `--no-profile`: skip the per-instruction-kind profile

### Launch files

`--config FILE` replaces every launch flag above with one JSON file. The ReLU launch of the first example reads:

```json
{
  "description": "relu over 128 fp32 elements",
  "kernel": "relu",
  "block": 128,
  "arrays": [
    {"name": "x",   "kind": "in",  "dtype": "f32", "shape": [128]},
    {"name": "out", "kind": "out", "dtype": "f32", "shape": [128]}
  ],
  "params": [
    {"ptr": "x"},
    {"ptr": "out"}
  ]
}
```

```bash
volta analyze relu.ptx --config relu.json
```

- `block` (required) and `grid`: a number or one to three numbers
- `arrays`: `kind` is `in`, `out`, `inout` or `index`; the element size is a `dtype` (`f32`, `bf16`, `u8`, `e4m3`, ...) or an `elem_width` in bytes, the length a `shape` or a `len`. Arrays without a `base` (a number or `"0x..."`) are laid out in order from `0x10000`, each on a 64 KiB boundary.
- `params`: exactly one of `{"int": N}`, `{"float": X}`, `{"sym": name}` or `{"ptr": array}` each, in declaration order. An optional `"name"` labels it for the reader and is not checked against the PTX.
- `globals` (`{"NAME": value}`), `dynamic_shared_bytes`, `max_instructions`, and a free-text `description`
- `kernel`: the default for `--kernel` (`analyze`, `verify`); `compare` names its two kernels with `--kernel1`/`--kernel2` instead

Unknown keys are errors, so a typo never falls back to a default. `--config` cannot be combined with the launch flags.

</details>

<details>
<summary><strong>Syntax checks and logging</strong></summary>

`volta parse file.ptx` checks PTX syntax.

Every run writes a log under `volta-logs/` (`--log-dir DIR`, `--no-log-file`). Build with `--features logging` and pass `--log-level info` for a trace of the run.

</details>

## Python

Work with PTX kernels from your own scripts: extract outputs, inspect execution statistics, and compare a kernel with a mathematical specification.

<details>
<summary><strong>Install the bindings and analyze a kernel</strong></summary>

Add the bindings to your project's `pyproject.toml`, then run `uv sync`:

```toml
[project]
dependencies = ["volta"]

[tool.uv.sources]
volta = { path = "<path/to/volta>/crates/volta_py", editable = true }
```

```python
import volta

src = open("relu.ptx").read()

config = volta.Config(block=(128, 1, 1), grid=(1, 1, 1), dynamic_shared_bytes=0)
config.add_array(volta.ArrayDef("x", base=0x10000, elem_width=4, len=128, kind=volta.ArrayKind.Input))
config.add_array(volta.ArrayDef("out", base=0x20000, elem_width=4, len=128, kind=volta.ArrayKind.Output))
config.add_param(volta.Param.array_ptr("x"))  # also Param.int, Param.float, Param.sym_float
config.add_param(volta.Param.array_ptr("out"))
# config.set_global("NAME", 42)

volta.parse(src)  # raises VoltaError on a syntax error

result = volta.analyze(src, config, kernel="relu")
result.outputs        # [("out", [(0, "max(x[0], 0)"), ...])]
result.race_verified  # True when every graph check passed
result.stats, result.op_counts

spec = "dim N; array x[N]; array out[N]; out[i] = max(x[i], 0);"
check = volta.verify(src, spec, config, kernel="relu", dims={"N": 128}, sample=0, verify_numeric=False)
check.equivalent, check.mismatches, check.elements_checked
```

`ArrayKind` is `Input`, `Output`, `InputOutput` or `IndexInput`. A race raises `volta.DataRaceError`, a deadlock `volta.DeadlockError`, and any other failure `volta.VoltaError` (the base class of both). An inconclusive graph check emits a `RuntimeWarning` and sets `race_verified` to `False`. `compare` is CLI-only for now.

</details>

## Build with us

New instruction support, kernel fixtures, solver improvements, and Lean proofs are all useful contributions. Start with a kernel you care about and its expected mathematical behavior.

```bash
just test           # Rust and Python tests
just amd           # AMD kernel and equivalence tests
just trainium      # Trainium frontend and symbolic execution tests
just check         # Rust checks, Clippy, and Python lint
```

Found an interesting kernel or a missing instruction? [Open an issue](https://github.com/francois141/ptx_verifier/issues). If Volta is useful for your work, [give it a star](https://github.com/francois141/ptx_verifier) to help others find it.

## Research & credits

Built on [Volta](https://github.com/willtunnels/volta), with multi-ISA extraction and the Fast Canonical Solver and Powerful Lean Solver workflows. If you use this project in your research, please cite the relevant work below.

### Citation · BibTeX

```bibtex
@misc{costa2026aicompilercompilingtriton,
      title={AI as a Compiler: Compiling Triton kernels without the Triton compiler},
      author={François Costa and Charly Castes and Thomas Bourgeat and Azalia Mirhoseini},
      year={2026},
      eprint={2609.36800},
      archivePrefix={arXiv},
      primaryClass={cs.AI},
      url={https://arxiv.org/abs/2609.36800},
}
```

```bibtex
@article{volta,
  author    = {Driscoll, Benjamin and Dubey, Kshitij and Wei, Anjiang and Kayal, Neeraj and Sharma, Rahul and Aiken, Alex},
  title     = {Equivalence Checking of {ML} {GPU} Kernels},
  journal   = {Proc. ACM Program. Lang.},
  volume    = {10},
  number    = {OOPSLA2},
  articleno = {338},
  numpages  = {28},
  year      = {2026},
  doi       = {10.1145/3839470}
}
```

---

<p align="center">
  <strong>Volta</strong> · Multi-ISA · Multi-Solver · Assembly to Lean<br>
  <a href="LICENSE">MIT licensed</a>
</p>
