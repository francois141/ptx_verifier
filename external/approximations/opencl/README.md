# OpenCL activations

The activations of [`../composable_kernel`](../composable_kernel/README.md) written in OpenCL C
([`activations.cl`](activations.cl)), each as CK's element-wise operation or its PyTorch functor
computes it, its parameters literals, fused after a GEMM: `c[m, n] = act(sum_k a[m, k] * b[n, k])`,
A M x K and B N x K row-major, computed by one workgroup of one wave, each work-item a column of
every row. Each case runs at M = N = K = 128 (16,384 outputs) against its
[`../specs`](../specs/) GEMM spec, the one CUTLASS, Triton and CK are checked against.

| Setting | Value |
|---|---|
| Compiler | LLVM clang 21.1.8, `-x cl -cl-std=CL1.2 -mcpu=gfx950 -nogpulib -O2 -cl-fast-relaxed-math`, xnack off |
| Denormals | kept (no `-cl-denorms-are-zero`), as the AMD `sigmoid.cl` fixture |
| Launch | 1 workgroup of 64 work-items; M, N and K are kernel arguments |

`exp`, `log`, `fmin`, `fmax`, `fabs`, `copysign`, `rint`, `fma` and `ldexp` compile to instructions;
`expm1`, `tanh` and `erf` are ROCm's device library (OCML) algorithms, which `-nogpulib` omits, so
[`ocml.h`](ocml.h) defines them as `../composable_kernel/ocml.hpp` does. The kernel stays within
the AMD frontend's subset: byte offsets are 32-bit (no 64-bit `off` addresses), the K loop is not
vectorized (no `global_load_dwordx2`), and one wave keeps the column stride an inline constant (no
`s_addk_i32`). `python3 compile.py` regenerates every `.s` and launch file. `just opencl_lean`
([`prove.py`](prove.py)) checks each case with the canonical solver and proves in Lean, within
1/1000, those it does not accept, on the same binary at 8 x 8 x 8: at 128, a challenge of 16,384
statements over 128-term sums is out of Lean's reach.

## The denormal guard

`v_exp_f32` flushes denormal results and `v_log_f32` denormal inputs. With approximate functions
allowed (`-cl-fast-relaxed-math`) and f32 denormals kept, clang guards them: `exp(u)` for
`u < -87.3365` (a result below 2^-126) is `f32(e^-64) * exp(u + 64)`, and `log` scales an input
below 2^-126 by 2^32 and subtracts `32 ln 2`. Flushing denormals (`-cl-denorms-are-zero`, or HIP's
`-fgpu-flush-denormals-to-zero` as CK builds) removes both. Every activation calling `exp` has the
guard: sigmoid, silu, celu, selu, fast_gelu, gelu, tanh and softrelu (also the `log` guard).

## Verdicts

`prove.py` writes [`REPORT.md`](REPORT.md): per case, the canonical solver's verdict at 128 x 128 x
128 (at most 120 s), Lean's result at 8 x 8 x 8, and which of them verified it.

| Case | Spec | Canonical solver | Lean, within 1/1000 |
|---|---|---|---|
| `relu`, `leaky_relu`, `hardtanh`, `hardsigmoid`, `hardswish`, `softshrink` | same name | ACCEPT | - |
| `sigmoid`, `silu`, `celu` | same name | UNKNOWN | challenge |
| `fast_gelu` | `gelu_tanh` | skipped by default | challenge |
| `selu`, `elu`, `tanh`, `gelu` | same name, `gelu_erf` | UNKNOWN (aborted) | none |
| `softrelu` | `softplus` | UNKNOWN (aborted) | none |

Over the reals `f32(e^-64) != e^-64`, so a guarded `exp` is not the spec's: the solver neither
proves nor refutes sigmoid, silu and celu. The kernel is within about 3e-8 relative of the spec past
the bound, so `prove.py` claims each output within 1/1000 and has Claude Code prove it in Lean.
`fast_gelu`'s guard hides the sigmoid form of GELU from the rewrite that equates CK's rounded
constants (0.797885, 0.035677) with PyTorch's, so the solver expands the cube of every 128-term dot
product, far past its time limit: `prove.py` skips it unless named. It is within about 2.1e-7 of the
spec, so Lean can prove it within 1/1000.

clang compiles `selu`'s and `elu`'s ternaries to exec-masked branches (`s_and_saveexec_b64`),
control flow on the data Volta cannot follow, where it gives CK's HIP `selu` a `v_cndmask_b32`;
OCML's `tanh` and `erf` branch on the argument's magnitude, as in CK; `softrelu`'s `log` guard
selects between the integers 0 and 32, which the AMD frontend cannot type. None of them reaches
extraction. `leaky_relu`, with a literal alpha, is a select between `x` and `0.01 * x`, which Volta
proves, where CK's argument alpha selects between the constant multipliers 1 and alpha.
