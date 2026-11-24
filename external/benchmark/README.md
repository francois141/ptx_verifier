# Matmul benchmark

How long Volta takes to check `C = A @ B` (f32, A `256 x K`, B `K x 64`) against its spec on
each accelerator, for K from 128 to 8192. Each of the 16,384 outputs sums K products, so the
work grows linearly in K.

| File | Accelerator | Kernel |
|---|---|---|
| `matmul.cu` -> `matmul.ptx` | NVIDIA PTX | one 16 x 16 block, 16 x 4 outputs per thread, shared-memory staging |
| `matmul.hip` -> `matmul.s` | AMD gfx950 | the same kernel, staging through LDS |
| `matmul.py` | Trainium NKI | `matmul_<K>`: `nc_matmul` over 128-row chunks into two 128 x 64 PSUM tiles (`a_t` is A transposed) |

All outputs are checked against `matmul.spec` (`matmul_nki.spec` for NKI) in two ways:

- **Canonical solver**: `volta solve --spec`.
- **Lean**: `volta extract lean` states them, and `volta.check_lean_proof` checks a fixed
  `unfold`, `intros`, `ring` proof, so only Lean is timed. Its time grows faster than K, so past
  `--lean-max-k` (128) the report shows ∞.

```sh
export VOLTA_LEAN_PROJECT=~/path/to/lake-project-with-mathlib
just benchmark                                # everything, 5 runs each, to report.md and the figure
just benchmark --sizes 128 256 --isa ptx amd
just benchmark --runs 1                       # one run each, no variance
just benchmark --no-lean                      # the canonical solver only
```

Each configuration runs `--runs` times (default 5). `report.md` gives each phase's mean ± sample
standard deviation and the largest peak resident set of `volta solve` over the runs. `plot.py`
then draws `solving-speed.pdf` and `.png`: execution + canonical seconds per K (mean, ±1 SD error
bars) above a row of peak memory per ISA. It runs under `uv run --no-project --with matplotlib`, and
it can redraw from saved results alone. The report and the figure are git-ignored.

Launch files and results go to `target/benchmark/`: `--resume` reuses the runs `results.json`
holds and adds only the missing ones, `--keep` keeps the Lean files, and `--lean-timeout` bounds
each Lean check (default 4 hours).

## Compiling the kernels

The sources are header-free and compile with LLVM's clang (Homebrew `llvm@21`; Apple's clang
lacks the NVPTX and AMDGPU targets; `$CLANG` overrides it). `benchmark.py` rebuilds the
git-ignored `matmul.ptx` when it is stale; `matmul.s` is committed:

```sh
CLANG=/opt/homebrew/opt/llvm@21/bin/clang
$CLANG -x cuda --cuda-device-only --cuda-gpu-arch=sm_80 -nocudainc -nocudalib -O2 \
  -S matmul.cu -o matmul.ptx
$CLANG -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
  -nogpuinc -O2 -g0 -fno-verbose-asm -S matmul.hip -o matmul.s
```

`matmul.hip` uses 32-bit byte offsets (`at`): Volta's AMD frontend does not parse the 64-bit
`off` form of `global_load`. Both sources `#pragma unroll` their loops; otherwise clang keeps the
accumulators in local memory, zeroed byte by byte, which Volta rejects.
