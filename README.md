<p align="center">
  <img src="volta-logo.png" alt="Volta architecture: NVIDIA PTX, AMD Assembly, and AWS Trainium NKI frontends feed a shared Race Detector &amp; Extractor, which branches to independent Fast Canonical Solver and Powerful Lean Solver backends." width="60%">
</p>

<h1 align="center">Prove race freedom. Extract Lean expressions.</h1>

<p align="center">
  <strong>Multi-ISA · Multi-Solver · Assembly to Lean</strong><br>
  Analyze accelerator kernels automatically. Choose the Fast Canonical Solver or the Powerful Lean Solver.
</p>

<p align="center">
  <a href="Cargo.toml"><img src="https://img.shields.io/badge/Rust-2024-f97316?style=flat-square" alt="Rust edition 2024"></a>
  <a href="#sigmoid-to-lean"><img src="https://img.shields.io/badge/Lean-4-2563eb?style=flat-square" alt="Lean 4"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-65a30d?style=flat-square" alt="MIT license"></a>
</p>

<p align="center">
  <a href="#quick-start">Python quick start</a> ·
  <a href="#sigmoid-to-lean">Sigmoid to Lean</a> ·
  <a href="#frontends">Frontends</a>
</p>

---

> [!WARNING]
> **Under active development.** We are actively building Volta, and not everything is ready yet. Features, instruction support, and solver workflows may change.

## Quick start

With Rust and [uv](https://docs.astral.sh/uv/) installed, run from the repository root. No accelerator is needed.

Each example checks `out[i] = a[i] + b[i]` for one kernel and asserts its expected verdict and race-check status.

### NVIDIA PTX

This [PTX example](examples/quickstart/verify_add_ptx.py) checks 128 elements with 128 threads.

```bash
uv run --package volta python examples/quickstart/verify_add_ptx.py
```

```python
import volta

spec = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"
size = 128
config = volta.Config(block=(size, 1, 1))

for name, base, kind in (
    ("a", 0x10000, volta.ArrayKind.Input),
    ("b", 0x20000, volta.ArrayKind.Input),
    ("out", 0x30000, volta.ArrayKind.Output),
):
    config.add_array(volta.ArrayDef(name, base, 4, size, kind))
    config.add_param(volta.Param.array_ptr(name))

result = volta.solve("examples/quickstart/add.ptx", config, spec=spec, dims={"N": size})

assert result.verdict == "ACCEPT", result.evidence
assert result.race_verified is True

print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
```

Expected output:

```text
NVIDIA PTX: ACCEPT; race checks: True
```

### AMD gfx950

This [AMD example](examples/quickstart/verify_add_amd.py) checks 64 elements with one wave of 64 work-items.

```bash
uv run --package volta python examples/quickstart/verify_add_amd.py
```

```python
import volta

spec = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"
size = 64
config = volta.Config(block=(size, 1, 1))

for name, base, kind in (
    ("a", 0x10000, volta.ArrayKind.Input),
    ("b", 0x20000, volta.ArrayKind.Input),
    ("out", 0x30000, volta.ArrayKind.Output),
):
    config.add_array(volta.ArrayDef(name, base, 4, size, kind))
    config.add_param(volta.Param.array_ptr(name))

result = volta.solve(
    "crates/volta_amd_analysis/tests/fixtures/add.s",
    config,
    spec=spec,
    dims={"N": size},
)
assert result.verdict == "ACCEPT", result.evidence
assert result.race_verified is None

print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
```

Expected output:

```text
AMD gfx950: ACCEPT; race checks: None
```

### AWS Trainium NKI

This [Trainium example](examples/quickstart/verify_add_nki.py) checks a 16×16 tensor. The kernel declares its tensor shapes, so no launch configuration is needed.

```bash
uv run --package volta python examples/quickstart/verify_add_nki.py
```

```python
import volta

spec = "dim N; array a[N]; array b[N]; array out[N]; out[i] = a[i] + b[i];"

# Trainium reads the 16 x 16 tensor shapes from the kernel, so no config is needed.
result = volta.solve(
    "crates/volta_trainium_analysis/tests/fixtures/add.py",
    spec=spec,
    dims={"N": 256},
)

assert result.verdict == "ACCEPT", result.evidence
assert result.race_verified is None

print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
```

Expected output:

```text
AWS Trainium NKI: ACCEPT; race checks: None
```

`volta.solve` selects the frontend by file extension and uses the Fast Canonical Solver by default. `result.outputs` contains the extracted expressions, `result.verdict` is `ACCEPT`, `REJECT`, or `UNKNOWN`, and `result.evidence` explains the decision. Race checks currently run only for PTX; `None` means the AMD and Trainium frontends do not check race freedom.

## Sigmoid to Lean

Use `volta.extract_lean(...)` to turn a kernel and its expected formula into Lean propositions. This [script](examples/lean/extract_sigmoid.py) reads the eight-element [Trainium sigmoid kernel](crates/volta_trainium_analysis/tests/fixtures/sigmoid.py). Each proposition asks you to prove that the kernel's output is within **epsilon** of `1 / (1 + exp(-a[i]))`. The kernel declares its tensor shapes, so no launch configuration is needed.

```python
from pathlib import Path

import volta

epsilon = "1/1000"  # Maximum absolute error per output: 0.001.

result = volta.extract_lean(
    "crates/volta_trainium_analysis/tests/fixtures/sigmoid.py",
    spec="dim N; array a[N]; array out[N]; out[i] = 1 / (1 + exp(-a[i]));",
    dims={"N": 8},
    tolerance=epsilon,
)

output = Path("target/lean/sigmoid_nki.lean")

output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(result.lean, encoding="utf-8")

print(f"Wrote {output}")
```

Change `epsilon` to choose the allowed error: `"1/1000"` permits an absolute difference of at most `0.001` for each output; `"1/1000000"` tightens that bound to `0.000001`. Pass it as a nonnegative rational string through `tolerance=epsilon`. The generated claim is `|kernel_output - expected_output| ≤ epsilon`, under Volta's real-number model. Omit `tolerance` (or use `None`) to request exact equality.

```bash
uv run python examples/lean/extract_sigmoid.py
```

The equivalent CLI command is:

```bash
mkdir -p target/lean
cargo run --release -p volta_cli -- extract lean \
  crates/volta_trainium_analysis/tests/fixtures/sigmoid.py \
  --spec examples/lean/sigmoid.spec --dim N=8 \
  --tolerance 1/1000 \
  --output target/lean/sigmoid_nki.lean
```

Extraction raises `volta.DataRaceError` for detected races and `volta.DeadlockError` for deadlocks. Other failed or incomplete PTX graph checks raise `volta.VoltaError`. The CLI exits with an error and leaves the Lean output file untouched on these failures. AMD and Trainium extraction returns `race_verified=None` because those frontends do not check races.

This writes `target/lean/sigmoid_nki.lean`: a complete module containing eight propositions. Open it below.

<details>
<summary><strong>Open generated sigmoid_nki.lean</strong></summary>

```lean
import Mathlib

/-!
Generated by Volta: each definition states that one output element of the candidate
is within 0.001 of the same element of the baseline. Each input element `a[i]` is the real `a_i`.
Prove `theorem <name> : VoltaChallenge.<name>` in another module without editing this file.
-/

noncomputable section

namespace VoltaChallenge

/-- `out[0]` -/
def out_0 : Prop :=
  ∀ (a_0 : ℝ),
    |((1 : ℝ) + Real.exp (-a_0))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_0)))| ≤ (0.001 : ℝ)

/-- `out[1]` -/
def out_1 : Prop :=
  ∀ (a_1 : ℝ),
    |((1 : ℝ) + Real.exp (-a_1))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_1)))| ≤ (0.001 : ℝ)

/-- `out[2]` -/
def out_2 : Prop :=
  ∀ (a_2 : ℝ),
    |((1 : ℝ) + Real.exp (-a_2))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_2)))| ≤ (0.001 : ℝ)

/-- `out[3]` -/
def out_3 : Prop :=
  ∀ (a_3 : ℝ),
    |((1 : ℝ) + Real.exp (-a_3))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_3)))| ≤ (0.001 : ℝ)

/-- `out[4]` -/
def out_4 : Prop :=
  ∀ (a_4 : ℝ),
    |((1 : ℝ) + Real.exp (-a_4))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_4)))| ≤ (0.001 : ℝ)

/-- `out[5]` -/
def out_5 : Prop :=
  ∀ (a_5 : ℝ),
    |((1 : ℝ) + Real.exp (-a_5))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_5)))| ≤ (0.001 : ℝ)

/-- `out[6]` -/
def out_6 : Prop :=
  ∀ (a_6 : ℝ),
    |((1 : ℝ) + Real.exp (-a_6))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_6)))| ≤ (0.001 : ℝ)

/-- `out[7]` -/
def out_7 : Prop :=
  ∀ (a_7 : ℝ),
    |((1 : ℝ) + Real.exp (-a_7))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_7)))| ≤ (0.001 : ℝ)

end VoltaChallenge

end
```

</details>

## Frontends

Give Volta a kernel file. It automatically chooses how to read it from the file extension:

| Your file | Volta reads it as | What you provide |
| --- | --- | --- |
| `kernel.ptx` | [NVIDIA PTX](crates/volta_ptx_analysis) | Thread layout, arrays, and kernel arguments |
| `kernel.s` | [AMD gfx950 assembly](crates/volta_amd_analysis) | Workgroup size, arrays, and kernel arguments |
| `kernel.py` | [AWS Trainium NKI](crates/volta_trainium_analysis) | Tensor shapes in the kernel itself |

The calls stay the same for every target: use `volta.solve(...)` to check the expected formula, or `volta.extract_lean(...)` to generate Lean proof obligations. On the CLI, use `volta solve` or `volta extract lean` followed by the file path.

For PTX and AMD, the **launch configuration** tells Volta how the kernel runs: how many threads it has, where its arrays are, and which arguments it receives. The **specification** describes what it should compute. For example, `block=(128, 1, 1)` launches 128 threads in a block, while `dims={"N": 128}` gives the mathematical spec a value for `N`. Trainium gets its tensor shapes from the kernel, so it needs no launch configuration.

| What you want to set | Python | CLI |
| --- | --- | --- |
| Threads per block / workgroup | `config = volta.Config(block=(128, 1, 1))` | `--block 128` |
| An input array's address, element size, and length | `config.add_array(volta.ArrayDef("a", 0x10000, 4, 128, volta.ArrayKind.Input))` | `--array a:0x10000:4:128:in` |
| An array pointer argument | `config.add_param(volta.Param.array_ptr("a"))` | `--param ptr:a` |
| A specific kernel in the file | `kernel="name"` | `--kernel name` |
| The expected formula | `spec="dim N; ..."` | `--spec formula.spec` or inline spec text |
| A dimension used by the formula | `dims={"N": 128}` | `--dim N=128` |
| Maximum absolute error for Lean extraction | `tolerance="1/1000"` | `--tolerance 1/1000` |
| Where to save the Lean module | `Path("challenge.lean").write_text(result.lean)` | `--output challenge.lean` |

Pass `config` to `solve` or `extract_lean` after the kernel path, as in the quickstart. Add one array declaration per array, and add kernel arguments in their declaration order. On the CLI, repeat `--array`, `--param`, and `--dim` as needed. You can also put the launch settings, kernel name, spec path, and dimensions into a [JSON configuration](examples/lean/sigmoid_amd.json) and pass `--config FILE` instead of individual launch flags. Lean extraction requires a specification.

## Citation · BibTeX

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
