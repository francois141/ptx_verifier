# GEMMs fused with activations: verification table

`table.py` fills the paper's table of GEMMs fused with activations: for each framework of
[`../`](../README.md), the kernels tested and how many each system verifies. Every kernel is the tile
of `c = act(a @ b^T)` its launch file names (CUTLASS's and Triton's CTA 0 and CK's workgroup 0, a
64 x 256 tile with K = 256; OpenCL's one workgroup, launched at M = 64, N = K = 256), checked
against its spec in [`../specs/`](../specs/):

| Column | Kernels |
|---|---|
| CUTLASS | [`cutlass/*.ptx`](../cutlass/) |
| AMD | [`composable_kernel/*.s`](../composable_kernel/) |
| OpenCL | [`opencl/*.s`](../opencl/) (gfx950 assembly) |
| Triton | [`triton/*.ptx`](../triton/) |

Each kernel is checked up to three ways:

- **Volta**: `volta.solve(..., rewrites=False)` (`volta solve --no-rewrites`), the canonical solver
  without the activation rewrites; ACCEPT verifies. Counted only for PTX kernels, the inputs the
  original Volta reads; `n/a` marks the frameworks compiled to AMD assembly.
- **Rewrites**: `volta.solve`, the canonical solver with its activation rewrites; ACCEPT verifies.
- **Lean**, only for a kernel the rewrites do not verify: `volta.prove_lean` claims every output
  within `1/1000` of the spec and a Claude Code agent proves the claim. `triton/softplus` and
  both softrelu kernels are claimed on inputs within `1/2` (`INPUT_BOUNDS`), which keeps their
  pre-activation, a sum of 256 products, within 64: below the 88.7 past which an f32 `exp`
  overflows, and where the f32 `ln 2` and `1/ln 2` their `log` uses (a relative error of 1e-8)
  stay far within the tolerance. Over all reals the claim is false: the agent's counterexample is
  a pre-activation of 1e6, where that relative error reaches 0.01.

**Ours** counts a kernel verified by the rewrites or by Lean once.

## Running it

```sh
cargo build --release -p volta_cli
export VOLTA_LEAN_PROJECT=~/path/to/lake-project-with-mathlib   # or a line in the repo's .env
just approximations-table                          # every kernel, Lean for those the rewrites miss
just approximations-table --no-lean                # the solvers only, no agent
just approximations-table triton/softplus          # one kernel
just approximations-table --force triton/softplus  # measure it again, proof from scratch
```

The recipe runs `uv run --reinstall-package volta --package volta python
external/approximations/table/table.py`. Results go to `target/approximations-table/kernels.json`.
A later run reuses them and runs only the missing measurements, so an agent proof is paid for once;
`--jobs N` (default 4) runs N proofs at once. `--force` measures again and deletes the kernel's
earlier proof, so the agent starts from scratch. Proofs are written to
`target/lean/approximations-table/<framework>/<kernel>/` (`challenge.lean`, `proof.lean`,
`transcript.jsonl`), and each proved kernel's `challenge.lean` and `proof.lean` are copied to
[`lean/<framework>/<kernel>/`](lean/) here, so the proofs stay in the repository.

Every run writes [`table.md`](table.md) (the table, then each kernel's verdicts, times, cost and
why the rewrites did not verify it) and [`table.tex`](table.tex) (the table as a `tabular`).

## The denormal guard and the GELU constants

The CK and OpenCL kernels keep f32 denormals, so clang guards every `exp`: past a bound,
`exp(u)` becomes `K * exp(u + 64)` with `K = f32(e^-64)`. The rewrites read that select as
`exp(u)` (`volta_expr`'s `denormal_exp` rewrite, which equates `K * e^64` with 1 within 1e-6);
Lean instead proves the raw guarded expression within `1/1000`. The two PTX kernels use
`tanh.approx` and GELU constants that agree with PyTorch's to within 2e-5: the rewrites equate
them (the `Gelu` node), and Lean proves the raw expressions within `1/1000`. Lean never sees a
rewrite, so its column is an independent check of each kernel.
