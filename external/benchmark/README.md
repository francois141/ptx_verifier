# Matmul benchmark

How long Volta takes on an `n x n` f32 matrix multiplication, `n` in 128, 256, 512, 1024,
2048, 4096 and 8192, on each accelerator. Each run computes the first 64 x 64 tile of
`C = A @ B`, each output a sum of `n` products, so the cost grows linearly in `n`. The whole
product grows as `n^3` and stops fitting in memory past `n = 256`.

| File | Accelerator | Kernel |
|---|---|---|
| `matmul.cu` -> `matmul.ptx` | NVIDIA PTX | one 16 x 16 block, 4 x 4 outputs per thread, shared-memory staging |
| `matmul.hip` -> `matmul.s` | AMD gfx950 | the same kernel, staging through LDS |
| `matmul.py` | Trainium NKI | `matmul_<n>`: `nc_matmul` over 128-row chunks accumulated in PSUM (`a_t` is A transposed) |

```sh
just benchmark                          # every accelerator and size, written to report.md
just benchmark --sizes 128 256 --isa ptx amd
```

`benchmark.py` writes each launch file to `target/benchmark/` and runs `volta solve` on it,
which does the symbolic execution, plus the graph checks on PTX and AMD. It then runs
`volta compare --exprs`, which checks the outputs against themselves. It writes the times
both commands print for those phases and each run's peak memory to `report.md` (git-ignored).

## Compiling the kernels

The sources need no CUDA or ROCm headers. They compile with LLVM's clang (Homebrew
`llvm@21`; Apple's clang lacks the NVPTX and AMDGPU targets). `matmul.ptx` is git-ignored,
like all PTX under `external/`. `benchmark.py` rebuilds it with the first command below
whenever it is missing or older than `matmul.cu` (`$CLANG` overrides the compiler).
`matmul.s` is committed:

```sh
CLANG=/opt/homebrew/opt/llvm@21/bin/clang
$CLANG -x cuda --cuda-device-only --cuda-gpu-arch=sm_80 -nocudainc -nocudalib -O2 \
  -S matmul.cu -o matmul.ptx
$CLANG -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
  -nogpuinc -O2 -g0 -fno-verbose-asm -S matmul.hip -o matmul.s
```

`matmul.hip` addresses memory through 32-bit byte offsets (`at`). With plain indexing,
clang emits the 64-bit-address (`off`) form of `global_load`, which Volta's AMD frontend
does not parse.
