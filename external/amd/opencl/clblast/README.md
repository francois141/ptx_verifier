# CLBlast's OpenCL kernels (gfx950)

Five kernels of [CLBlast](https://github.com/CNugteren/CLBlast) 1.6.3, the most widely used
OpenCL BLAS, which runs on an MI355X through ROCm's OpenCL runtime: compiled as that runtime
compiles CLBlast's programs and checked by Volta. The registry is `cases.py`; `extract.py`
compiles it and `external/amd/verify.py` runs it (`just opencl`). The toolchain, device libraries
and what the AMD frontend learned for these kernels are in [`../README.md`](../README.md).

    python3 external/amd/opencl/clblast/extract.py [--clang PATH] [CASE...]

## How the kernels are built

- **Program.** The text CLBlast's routine builds (`src/routine.cpp`): the header of
  `CompileFromSource` for an AMD GPU (`USE_CL_MAD`, `USE_STAGGERED_INDICES`) and `common.opencl`,
  the routine's tuning parameters, then its kernel strings. The GEMM program holds only the direct
  kernels' strings.
- **Tuning parameters.** The database's AMD GPU defaults (vendor "AMD", architecture "default"),
  which an MI355X, absent from the database, gets: `WGD 16`, `MDIMCD`/`NDIMCD 8`, `VWMD`/`VWND 2`
  for the direct GEMM, `WGS1 256`, `WGS2 64` for the reductions.
- **Options.** Those of ROCm's OpenCL runtime (CLR `rocclr/device/devprogram.cpp`): OpenCL C 1.2,
  `-O3`, `-amdgpu-prelink`, `-amdgpu-internalize-symbols`, plus one change,
  `-mllvm -inline-threshold=100000`: CLR leaves `XgemmDirect` a function its four entry points
  call, which Volta does not follow, and inlining it changes no value. Inlining is also what
  exposes the bug below.

## Cases

| Kernel | Cases | Configuration | Verdict |
|---|---|---|---|
| `XgemmDirectNT` | `gemm_direct_fixed` | column-major C[16, 16] = A[16, 40] B[40, 16] (the kernel a column-major GEMM without transposes runs), packed f32 FMAs split | ACCEPT |
| `Xdot` | `dot` | n = 40000, 128 workgroups, workgroup 0's two blocks | ACCEPT |
| `XdotEpilogue` | `dot_epilogue` | 128 partials, one workgroup of 64 | ACCEPT |
| `Xnrm2` | `nrm2` | n = 40000, sum of squares | ACCEPT |
| `Xasum` | `asum` | n = 40000, absolute sum | ACCEPT |

## Bugs

| Case (fixed twin) | Bug | What Volta reports |
|---|---|---|
| `gemm_direct` (`_fixed`) | A compiler bug, not CLBlast's. With `XgemmDirect` inlined, LLVM vectorizes its float2 multiply-adds into `v_pk_fma_f32 ... op_sel:[0,1,0]`, an encoding gfx950 does not execute (LLVM commit cac3cc28, October 2026, splits such FMAs into two `v_fma_f32` and makes the assembler reject them). Upstream clang 21.1.8 emits 68 of them here and ROCm 7.2.1's clang (AMD LLVM 22.0.0git, the compiler of its OpenCL runtime) 128 in the same inlined build; with CLR's default options `XgemmDirect` stays a call and both happen to choose valid selectors. Fix: an LLVM with that commit; with an older one, compile without packed f32 ops (`-Xclang -target-feature -Xclang -packed-fp32-ops`), which `gemm_direct_fixed` does. | ABORT at lowering: "unsupported packed f32 low-word selectors on gfx950"; without packed f32 ops ACCEPT, all 256 outputs |

## Not here

`Xnrm2Epilogue`, whose square root's denormal scaling is a scalar select on a lane's comparison
(`s_cselect` on SCC), which Volta keeps concrete; the in-place routines (`axpy`, `scal`, GEMV, GEMM
with `beta != 0`), as Volta's arrays are inputs or outputs; the indirect GEMM kernels, which need
the copy and pad kernels before them.
