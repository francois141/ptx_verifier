# OpenCL kernels for gfx950 (MI355X)

OpenCL kernels that run on an MI355X, compiled for gfx950 exactly as their library compiles them
there and checked by Volta: every output against a spec over the reals, and the event graph for
LDS races. Each library has its folder, with its registry (`cases.py`), the script compiling it
(`extract.py`), its specs, compiled kernels and launch files:

| Folder | Library | Kernels | Bugs Volta found |
|---|---|---|---|
| [`miopen/`](miopen/README.md) | MIOpen, AMD's DNN library (ROCm/rocm-libraries `rocm-7.2.4`) | 15: softmax, batch norm, activations, tensor ops, convolution bias gradient, transpose, copy and transform | 2 |
| [`clblast/`](clblast/README.md) | CLBlast, the most widely used OpenCL BLAS (`1.6.3`) | 5: direct GEMM, dot product and its epilogue, nrm2, asum | 1 (a compiler bug) |

    just opencl                                          # check every case (verify.py opencl/)
    python3 external/amd/opencl/miopen/extract.py [CASE...]   # recompile MIOpen's cases
    python3 external/amd/opencl/clblast/extract.py [CASE...]  # recompile CLBlast's cases

One case can be run alone with `volta solve <case>.s --config <case>.launch.json` from its folder
(a shared kernel's `.s` is named in `cases.py`'s `assembly`).

## How the kernels are built

`opencl_common.py` holds what the two folders share: the case dataclasses, the compilation and the
launch files. Each `extract.py` adds its library's sources and compiler options.

- **Device libraries.** ROCm's own bitcode (`opencl.bc`, `ocml.bc`, `ockl.bc`, the `oclc_*`
  controls) from the `rocm-device-libs` 7.2.1 Ubuntu package, fetched into `target/opencl/devlibs`
  and linked as ROCm's comgr links it. `get_global_id`, `barrier`, `exp`, `rsqrt` and division are
  therefore the code an MI355X runs, not stand-ins.
- **Compiler.** LLVM's clang 21 (Homebrew `llvm@21`), `-target amdgcn-amd-amdhsa -mcpu=gfx950:xnack-`.
- **Inline asm.** Each inline-asm instruction (MIOpen's DPP reductions, written without commas and
  with `bound_ctrl:0`) is replaced by what LLVM's assembler prints back for it, so Volta reads
  LLVM's own encoding.
- **Launch files.** The kernel-argument bytes are laid out from the compiled metadata: each
  argument the case gives, then the hidden arguments (block counts, group sizes, grid dimensions;
  global offsets and remainders zero).

Volta runs workgroup 0. Each case's output arrays hold exactly what that workgroup writes, a prefix
of the tensor where the grid has more workgroups (the specs say which outputs).

## What the AMD frontend learned for these kernels

Without fast math, LLVM expands f32 division and `exp`, and OCML scales roots, in ways that are
exact over the reals. `crates/frontend/volta_amd_analysis` follows them:

- **Division** (`v_frexp_mant_f32`, `v_frexp_exp_i32_f32`, `v_rcp_f32`, `v_ldexp_f32`):
  `ldexp(mant(n) * rcp(mant(d)), exp(n) - exp(d))` is `n / d` for any exponent. A symbolic `x`'s
  exponent is `floor(log2 |x|) + 1`, an i32 the solver treats as uninterpreted; integer adds and
  subtracts of exponents stay exact, and their integer parts scale by exact powers of two.
- **`expf`**: `exp2((h - rndne(h)) + l) * 2^rndne(h)` with `h = x c_hi`, `l = fma(x, c_lo,
  fma(x, c_hi, -h))` is `exp2(x (c_hi + c_lo))`, which the existing `log2(e)` fold makes `e^x`.
  Its range guards, 0 below an argument whose `e^u` is under the least f32 and +inf above one
  whose `e^u` overflows, are taken as `e^u`: they are f32 rounding, which Volta ignores
  everywhere. They are folded only when their bounds are past `ln(2^-149)` and `ln(f32::MAX)`.
- **OCML `rsqrt`/`sqrt`**: `c ? k r(c ? v s : v) : r(c ? v s : v)` with `k^2 = s` (rsqrt) or
  `k^2 s = 1` (sqrt) is `r(v)`.
- **Kernel arguments read by vector loads**: OpenCL 2.0's `get_local_size` reads the group size or
  the remainder it selects with a `global_load_ushort` from the argument buffer.

## What is checked, and what is not

- **Exact reals.** Floats are exact reals: roundings, f32 underflow and overflow (the `expf` guards
  above), and conversions (MIOpen's `double` epsilon converted to f32: the specs use the double
  1e-5).
- **One workgroup.** Workgroup 0 of the grid runs; cross-workgroup and global-memory races are not
  checked. Launch sizes are the libraries' own, so an oversized workgroup shows.
- **Not here.** OpenCL `tanh`, `pow` and `log` (OCML branches on the argument), f64 `rsqrt` with a
  Newton step, and selects the canonical solver cannot match with `max`; each folder's README lists
  the kernels this leaves out.
