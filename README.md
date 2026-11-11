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
  <a href="#prove-sigmoid-in-lean"><img src="https://img.shields.io/badge/Lean-4-2563eb?style=flat-square" alt="Lean 4"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-65a30d?style=flat-square" alt="MIT license"></a>
</p>

<p align="center">
  <a href="#quick-start">Python quick start</a> ·
  <a href="#prove-sigmoid-in-lean">Prove sigmoid in Lean</a> ·
  <a href="#frontends">Frontends</a>
</p>

---

> [!WARNING]
> **Under active development.** We are actively building Volta, and not everything is ready yet. Features, instruction support, and solver workflows may change.

## Quick start

### Install

Rust and [uv](https://docs.astral.sh/uv/) are all the examples below need. The rest is only for [proving in Lean](#prove-sigmoid-in-lean): Lean, a Mathlib project in `~/mathlib-project` (`lake exe cache get` downloads Mathlib's prebuilt files, a few GB, instead of building it for hours) and Claude Code.

```bash
# Rust and uv
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && . "$HOME/.cargo/env"
curl -LsSf https://astral.sh/uv/install.sh | sh && . "$HOME/.local/bin/env"

# Lean solver only: Lean (elan), a Mathlib project, and Claude Code
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh && . "$HOME/.elan/env"
(cd ~ && lake +leanprover-community/mathlib4:lean-toolchain new mathlib-project math)
(cd ~/mathlib-project && lake exe cache get)
curl -fsSL https://claude.ai/install.sh | bash
claude  # Log in once, then exit.
```

Run each example from the repository root. No accelerator is needed.

Each example checks `out[i] = a[i] + b[i]` for one kernel and prints its verdict and race-check status.

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
    "crates/volta_pipeline/tests/amd/success/add.s",
    config,
    spec=spec,
    dims={"N": size},
)

print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
```

Expected output:

```text
AMD gfx950: ACCEPT; race checks: True
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
    "crates/volta_pipeline/tests/trainium/success/add.py",
    spec=spec,
    dims={"N": 256},
)

print(f"{result.isa}: {result.verdict}; race checks: {result.race_verified}")
```

Expected output:

```text
AWS Trainium NKI: ACCEPT; race checks: None
```

`volta.solve` selects the frontend by file extension and uses the Fast Canonical Solver by default. `result.outputs` contains the extracted expressions, `result.verdict` is `ACCEPT`, `REJECT`, or `UNKNOWN`, and `result.evidence` explains the decision. Race checks run for PTX and AMD (for AMD, over one workgroup's LDS accesses and barriers); `None` means the Trainium frontend does not check race freedom.

## Prove sigmoid in Lean

`volta.prove_lean(...)` turns a kernel and its expected formula into Lean propositions, one per output, and has [Claude Code](https://claude.com/claude-code) prove them. This [script](examples/lean/prove_sigmoid_amd.py) proves the [AMD sigmoid kernel](examples/lean/sigmoid_4096.cl) over **4096 elements**: one workgroup of 1024 work-items, each computing four outputs. Volta runs the kernel's [gfx950 assembly](examples/lean/sigmoid_4096.s), checks its event graph, and writes 4096 propositions to `challenge.lean`. Claude Code then writes `proof.lean` until Volta's own check accepts it.

It needs the Lean part of [Install](#install): the Mathlib project, passed as `VOLTA_LEAN_PROJECT` (or `lean_project=`), and Claude Code, logged in. Claude Code runs on your login, so no API key is needed.

```python
import volta

spec = "dim N; array a[N]; array out[N]; out[i] = 1 / (1 + exp(-a[i]));"
size = 4096
config = volta.Config(block=(1024, 1, 1))  # One workgroup; each work-item computes four outputs.
for name, base, kind in (
    ("a", 0x10000, volta.ArrayKind.Input),
    ("out", 0x20000, volta.ArrayKind.Output),
):
    config.add_array(volta.ArrayDef(name, base, 4, size, kind))
    config.add_param(volta.Param.array_ptr(name))

result = volta.prove_lean(
    "examples/lean/sigmoid_4096.s",
    config,
    spec=spec,
    dims={"N": size},
    tolerance="1/1000",
    output_dir="target/lean/sigmoid_amd_4096",
    verbose=True,  # Print each step, then the time and cost.
)

print(f"{result.isa}: {result.proved_statements} of {result.statements} statements proved")
print(f"Proof: {result.proof}")
```

Run it from the repository root:

```bash
VOLTA_LEAN_PROJECT=~/mathlib-project uv run --package volta python examples/lean/prove_sigmoid_amd.py
```

The tolerance is required. For inputs above 87.34, the compiled kernel computes `exp(64 - a)` and scales it by the f32 rounding of `e^-64`, so over the reals its output is close to `1 / (1 + exp(-a))` but not equal to it. Each proposition states exactly that:

```lean
def out_0 : Prop :=
  ∀ (a_0 : ℝ),
    let x0 := Real.exp (if (87.3365478515625 : ℝ) < a_0 then (64 : ℝ) - a_0 else -a_0)
    |((1 : ℝ) + (if (87.3365478515625 : ℝ) < a_0 then (3330985 / 2 ^ 114 : ℝ) * x0 else x0))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_0)))| ≤ (0.001 : ℝ)
```

`result.proved` comes from Volta's final check, never from Claude. The check requires the proof to compile, to give each `VoltaChallenge.out_i` a theorem of exactly that type, to use no axioms beyond `propext`, `Classical.choice` and `Quot.sound`, and to pass `leanchecker`'s replay in Lean's kernel. See [volta_lean](crates/backend/volta_lean) for details. A race in the kernel raises `volta.DataRaceError` and a deadlock `volta.DeadlockError` before any proof starts.

With `verbose=True`, each step is printed as it happens, with the clock time and the time elapsed: the analysis and each of the ten graph checks, the equivalence verdict, the challenge generated and compiled, Claude Code starting the proof, every proof it writes and checks, and the final verdict. A last summary gives the total time, the agent's turns and time, the cost (Claude Code's estimate at API prices) and the tokens used. The same figures are on the result: `duration_seconds`, `turns`, `cost_usd` and `usage`.

The script writes `challenge.lean`, `proof.lean` and Claude's `transcript.jsonl` to `target/lean/sigmoid_amd_4096`. A previous run took about six minutes, most of it spent importing Mathlib and checking the proof. To write the propositions without proving them, call `volta.extract_lean(...)` with the same arguments (no `output_dir`); it returns the module as `result.lean`.

<details>
<summary><strong>Open the challenge.lean Volta writes</strong></summary>

One definition per output, `out_0` to `out_4095`, each over its own input `a_i`. Claude must prove every one of them, and may not edit this file.

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
    let x0 := Real.exp (if (87.3365478515625 : ℝ) < a_0 then (64 : ℝ) - a_0 else -a_0)
    |((1 : ℝ) + (if (87.3365478515625 : ℝ) < a_0 then (3330985 / 2 ^ 114 : ℝ) * x0 else x0))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_0)))| ≤ (0.001 : ℝ)

/-- `out[1]` -/
def out_1 : Prop :=
  ∀ (a_1 : ℝ),
    let x0 := Real.exp (if (87.3365478515625 : ℝ) < a_1 then (64 : ℝ) - a_1 else -a_1)
    |((1 : ℝ) + (if (87.3365478515625 : ℝ) < a_1 then (3330985 / 2 ^ 114 : ℝ) * x0 else x0))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_1)))| ≤ (0.001 : ℝ)

/-- `out[2]` -/
def out_2 : Prop :=
  ∀ (a_2 : ℝ),
    let x0 := Real.exp (if (87.3365478515625 : ℝ) < a_2 then (64 : ℝ) - a_2 else -a_2)
    |((1 : ℝ) + (if (87.3365478515625 : ℝ) < a_2 then (3330985 / 2 ^ 114 : ℝ) * x0 else x0))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_2)))| ≤ (0.001 : ℝ)

-- ... out_3 to out_4094, the same statement over a_3 to a_4094 ...

/-- `out[4095]` -/
def out_4095 : Prop :=
  ∀ (a_4095 : ℝ),
    let x0 := Real.exp (if (87.3365478515625 : ℝ) < a_4095 then (64 : ℝ) - a_4095 else -a_4095)
    |((1 : ℝ) + (if (87.3365478515625 : ℝ) < a_4095 then (3330985 / 2 ^ 114 : ℝ) * x0 else x0))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a_4095)))| ≤ (0.001 : ℝ)

end VoltaChallenge

end
```

</details>

<details>
<summary><strong>Open a proof.lean written by Claude Code</strong></summary>

Claude proves one general lemma, `key`, and states every output as an instance of it.

```lean
import challenge

namespace VoltaProofs

theorem aux (x y : ℝ) (hx0 : 0 ≤ x) (hx : x ≤ 0.001) (hy0 : 0 ≤ y) (hy : y ≤ 0.001) :
    |(1 + x)⁻¹ - (1 : ℝ) / (1 + y)| ≤ 0.001 := by
  have h1 : (1 + x) ≠ 0 := by positivity
  have h2 : (1 + y) ≠ 0 := by positivity
  rw [one_div, inv_sub_inv h1 h2, abs_le]
  have hp : 0 < (1 + x) * (1 + y) := by positivity
  constructor
  · rw [le_div_iff₀ hp]; nlinarith [mul_nonneg hx0 hy0]
  · rw [div_le_iff₀ hp]; nlinarith [mul_nonneg hx0 hy0]

theorem key : ∀ (a : ℝ),
    let x0 := Real.exp (if (87.3365478515625 : ℝ) < a then (64 : ℝ) - a else -a)
    |((1 : ℝ) + (if (87.3365478515625 : ℝ) < a then (3330985 / 2 ^ 114 : ℝ) * x0 else x0))⁻¹ - ((1 : ℝ) / ((1 : ℝ) + Real.exp (-a)))| ≤ (0.001 : ℝ) := by
  intro a
  dsimp only
  by_cases h : (87.3365478515625 : ℝ) < a
  · rw [if_pos h, if_pos h]
    have he1 : Real.exp (64 - a) ≤ 1 := Real.exp_le_one_iff.mpr (by linarith)
    have hep : 0 < Real.exp (64 - a) := Real.exp_pos _
    have hc : (3330985 / 2 ^ 114 : ℝ) ≤ 0.001 := by norm_num
    have hc0 : (0 : ℝ) ≤ (3330985 / 2 ^ 114 : ℝ) := by norm_num
    have hx : (3330985 / 2 ^ 114 : ℝ) * Real.exp (64 - a) ≤ 0.001 :=
      (mul_le_of_le_one_right hc0 he1).trans hc
    have hx0 : 0 ≤ (3330985 / 2 ^ 114 : ℝ) * Real.exp (64 - a) := by positivity
    have hea : Real.exp a = Real.exp (a / 4) ^ 4 := by
      rw [← Real.exp_nat_mul]; congr 1; push_cast; ring
    have he4 : 1 + a / 4 ≤ Real.exp (a / 4) := by linarith [Real.add_one_le_exp (a / 4)]
    have he22 : 22 ≤ Real.exp (a / 4) := by linarith
    have he2 : 484 ≤ Real.exp (a / 4) ^ 2 := by nlinarith
    have he1000 : 1000 ≤ Real.exp a := by rw [hea]; nlinarith
    have hy : Real.exp (-a) ≤ 0.001 := by
      rw [Real.exp_neg, inv_le_comm₀ (Real.exp_pos a) (by norm_num)]
      norm_num; linarith
    exact aux _ _ hx0 hx (Real.exp_pos _).le hy
  · rw [if_neg h, if_neg h, one_div, sub_self, abs_zero]
    norm_num

theorem out_0 : VoltaChallenge.out_0 := key
theorem out_1 : VoltaChallenge.out_1 := key
-- ... one line per output ...
theorem out_4095 : VoltaChallenge.out_4095 := key

end VoltaProofs
```

</details>

## Frontends

Give Volta a kernel file. It automatically chooses how to read it from the file extension:

| Your file | Volta reads it as | What you provide |
| --- | --- | --- |
| `kernel.ptx` | [NVIDIA PTX](crates/frontend/volta_ptx_analysis) | Thread layout, arrays, and kernel arguments |
| `kernel.s` | [AMD gfx950 assembly](crates/frontend/volta_amd_analysis) | Workgroup size, arrays, and kernel arguments |
| `kernel.py` | [AWS Trainium NKI](crates/frontend/volta_trainium_analysis) | Tensor shapes in the kernel itself |

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
