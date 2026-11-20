# Composable Kernel fused GEMM activations

Composable Kernel's fp32 universal GEMM, `DeviceGemm_Xdl_CShuffleV3` (rocm-7.0.0), at
M = N = K = 256 with a C element-wise operation fused into its CShuffle epilogue, one kernel per
activation. `gemm.hip` instantiates a 256-thread block computing a 64 x 256 tile with the fp32
`v_mfma_f32_16x16x4_f32` instruction (the one Volta models; CK's shipped fp32 instances use the
32 x 32 MFMAs): 2 x 8 XDL tiles per wave over 2 x 2 waves, 32 of K per LDS stage, four-element
vectors, `GemmSpecialization::Default`, the Intrawave v3 pipeline. K = 256 is eight K blocks, a
main loop of seven and a full tail. The 64 x 256 tile spans whole rows of C, so workgroup 0 of the
four, the one Volta runs, writes rows 0..64 (`BlockToCTileMap_Grouped_M00_N0_M01Adapt` maps block
0 to tile 0, 0): the launch files' `c` array.

| Setting | Value |
|---|---|
| CK | rocm-7.0.0 (`571a8113913261fe0cc28ae05cc1977cd835a935`) |
| Compiler | LLVM clang 21.1.8, `--offload-arch=gfx950:xnack-`, `-O3 -ffast-math` (`sigmoid_precise` without `-ffast-math`), f32 denormals kept (no `-fgpu-flush-denormals-to-zero`), so every `exp` and `log` carries clang's denormal guard |
| Launch | 4 x 1 x 1 workgroups of 256 work-items |
| Arguments | CK's `Argument`: `Problem`'s dimensions and padding, the C operation by value, the three pointers |

The kernel argument carries the C operation by value, so its parameters (LeakyRelu's `alpha`,
ClippedRelu's bounds, CELU's `alpha` and `inv_alpha`) are launch-file floats after `Problem`'s
fields; `gemm.hip` exports the operation's size and alignment and `extract.py` checks its layout
against the kernel descriptor's argument size.

| Case | C operation | Compiles to | Spec |
|---|---|---|---|
| `relu` | `ck::tensor_operation::element_wise::Relu` | `v_max_f32` | `relu` |
| `leaky_relu` | `LeakyRelu`, alpha 0.01 | `v_cmp_gt_f32`, `v_cndmask_b32` choosing the multiplier `1.0` or `alpha`, `v_mul_f32` | `leaky_relu` |
| `hardtanh` | `ClippedRelu`, alpha -1 and beta 1 | `v_max_f32`, `v_min_f32` | `hardtanh` |
| `hardsigmoid` | `pytorch::Hardsigmoid` | `v_med3_f32`, `v_mul_f32` by `one_sixth` | `hardsigmoid` |
| `hardswish` | `pytorch::Hardswish` | the same, times `x` | `hardswish` |
| `softshrink` | `pytorch::Softshrink`, lambd 0.5 | `v_max_f32`, `v_min_f32` (clang branches on the nested ternary) | `softshrink` |
| `elu` | `Elu`, alpha 1 | OCML's `expm1`: `v_rndne_f32`, `v_ldexp_f32`, a polynomial, a select on `x < -17` | `elu` |
| `celu` | `pytorch::Celu`, alpha 2 and inv_alpha 0.5 | `v_exp_f32`, `v_pk_fma_f32` (`alpha * e - alpha`), `v_cndmask_b32` | `celu` |
| `selu` | `pytorch::Selu` | `v_exp_f32`, `v_pk_fma_f32`, `v_cndmask_b32` | `selu` |
| `fast_gelu` | `FastGelu` | `v_exp_f32` of `x * (c1 * x^2 + c2)`, `v_rcp_f32` | `gelu_tanh` |
| `gelu` | `Gelu` | OCML's `erf`: polynomials branching on `|x| < 1` | `gelu_erf` |
| `sigmoid` | `Sigmoid` | `v_exp_f32` of `-x * log2(e)`, `v_rcp_f32` | `sigmoid` |
| `sigmoid_precise` | `Sigmoid` without `-ffast-math` | `exp` with its range reduction (`v_rndne_f32`, `v_ldexp_f32`) and overflow bounds | `sigmoid` |
| `silu` | `Silu` | `Sigmoid`'s code times `x` | `silu` |
| `swish` | `Swish`, beta 1 | `v_exp_f32` of `-beta * x`, `v_rcp_f32` | `silu` |
| `tanh` | `TanH` | OCML's `tanh`: a polynomial below 0.625, `1 - 2 / (e^2x + 1)` above | `tanh` |
| `softrelu` | `SoftRelu`, alpha 1 | `v_exp_f32`, `v_log_f32` times `ln 2` | `softplus` |

`activations.hpp` holds the PyTorch activations CK has no operation for, written as PyTorch's
CUDA functors write them in the form of CK's `unary_element_wise_operation.hpp`, their `expm1` as
CK's `math::exp` minus 1, and Softshrink's nested ternary as `max` and `min`: clang compiles the
ternary to exec-masked branches (`s_and_saveexec_b64`, `s_cbranch_execz`), control flow on the
data that Volta cannot follow. `ocml.hpp` defines the ROCm device-library functions the operations call
(`-nogpulib` omits that library): `exp`, `log` and the native reciprocal as the compiler builtins
hipcc links under `-ffast-math`, which lower to `v_exp_f32`, `v_log_f32` and `v_rcp_f32`, and OCML's
`expm1`, `tanh` and `erf` algorithms (`expm1F.cl`, `tanhF.cl`, `erfF.cl`), which branch on their
argument's magnitude. CK's `FastGelu` is PyTorch's tanh GELU in sigmoid form,
`x / (1 + exp(-2 * 0.797885 * x * (1 + 0.0447149 * x^2)))`, its constants rounded to six digits.

## Building

With the activations' toolchain (`../../amd/composable_kernel/activations/README.md`): LLVM's
clang 21 (Apple's lacks the AMDGPU target), a CK rocm-7.0.0 checkout as `CK_ROOT` whose
`include/ck/config.h` is generated from `config.h.in` for gfx950 (all data types, `CK_USE_XDL`,
`CK_USE_OCP_FP8`, `CK_USE_NATIVE_MX_SUPPORT` on, the other `#cmakedefine`s out), and the HIP
7.0.2 headers as `HIP_ROOT` (`include/` and `share/hip/version`, from the `hip-dev` package):

```sh
cd "$CK_ROOT/include/ck" && sed \
  -e 's/#cmakedefine CK_ENABLE_ALL_DTYPES @CK_ENABLE_ALL_DTYPES@/#define CK_ENABLE_ALL_DTYPES ON/' \
  -e 's/#cmakedefine CK_USE_XDL @CK_USE_XDL@/#define CK_USE_XDL ON/' \
  -e 's/#cmakedefine CK_USE_OCP_FP8 @CK_USE_OCP_FP8@/#define CK_USE_OCP_FP8 ON/' \
  -e 's/#cmakedefine CK_USE_NATIVE_MX_SUPPORT @CK_USE_NATIVE_MX_SUPPORT@/#define CK_USE_NATIVE_MX_SUPPORT ON/' \
  -e 's/^#cmakedefine .*$/\/\/ &/' config.h.in > config.h
CK_ROOT=... HIP_ROOT=... python3 external/approximations/composable_kernel/extract.py [CASE...]
```

`extract.py` compiles each case to `<case>.s` and writes `<case>.launch.json`. One case runs with
`volta solve external/approximations/composable_kernel/relu.s --config external/approximations/composable_kernel/relu.launch.json`;
the folder's README has every verdict.
