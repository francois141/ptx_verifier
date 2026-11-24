# CUTLASS fused GEMM activations

NVIDIA CUTLASS's SM80 TF32 tensor-core GEMM at M = N = K = 256 with an activation fused through
its `LinearCombinationGeneric<Activation>` epilogue, one kernel per activation. `kernel.cu`
instantiates the transpose of the configuration of CUTLASS's test `256x64x32_64x64x32`
(`test/unit/gemm/device/gemm_tf32t_tf32n_f32t_tensor_op_f32_sm80.cu`): `tfloat32_t` operands,
fp32 accumulation, a 64 x 256 x 32 threadblock tile over 4 warps of 64 x 64 x 32, the
`mma.sync.aligned.m16n8k8.row.col.f32.tf32.tf32.f32` instruction, 3 `cp.async` stages. The small
wrapper constructs CUTLASS's `Params` from constant dimensions; the mainloop and epilogue are the
library's. The 64 x 256 tile, Triton's and Composable Kernel's, spans whole rows of C, so CTA 0 of
the 4 x 1 grid, the one Volta runs, writes rows 0..64: the launch files' `c` array.

| Setting | Value |
|---|---|
| CUTLASS | v3.9.2, commit `ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e` |
| CUDA compiler | 12.9, V12.9.86, `-O3 -arch=sm_80 -use_fast_math` (`sigmoid_precise` without it) |
| Launch | 4 x 1 x 1 blocks of 128 threads, 122,880 bytes of dynamic shared memory |
| Epilogue | `LinearCombinationGeneric<Activation, float, 4, float, float>`, alpha 1, beta 0 |

The operands are the fp32 words as stored: CUTLASS's `tfloat32_t` path rounds nothing in the
kernel (the hardware ignores the low 13 mantissa bits), which Volta's reals keep. The `float`
operand path would round them with integer arithmetic on their bits, which Volta does not see
through.

| Case | Functor | Compiles to | Spec |
|---|---|---|---|
| `relu` | `cutlass::epilogue::thread::ReLu` | `max.NaN.f32` | `relu` |
| `leaky_relu` | `LeakyReLU`, `leaky_alpha` 0.01 | `setp.gt` + `selp` | `leaky_relu` |
| `hardtanh` | `Clamp`, bounds -1 and 1 | `max.NaN.f32`, `min.NaN.f32` | `hardtanh` |
| `hardsigmoid` | `pytorch::Hardsigmoid` | `max.ftz`, `min.ftz`, `mul` by `one_sixth` | `hardsigmoid` |
| `hardswish` | `HardSwish<float>` | `max`, `min`, `mul` by `0.16666667f` | `hardswish` |
| `softshrink` | `pytorch::Softshrink`, lambd 0.5 | `max.ftz.f32`, `min.ftz.f32` (nvcc branches on the nested ternary) | `softshrink` |
| `elu` | `pytorch::ELU` | `ex2.approx.ftz.f32`, `selp` | `elu` |
| `celu` | `pytorch::CELU`, alpha 2 | `ex2.approx.ftz.f32`, `selp` | `celu` |
| `selu` | `pytorch::SELU` | `ex2.approx.ftz.f32`, `selp` | `selu` |
| `gelu_tanh` | `GELU_taylor<float>` | `fma`, `tanh.approx.f32` | `gelu_tanh` |
| `gelu_erf` | `GELU<float>` | `erff`: libdevice's polynomial, branching on `|x| < 1` | `gelu_erf` |
| `sigmoid` | `Sigmoid` | `ex2.approx.ftz.f32` of `-x * log2(e)`, `div.approx` | `sigmoid` |
| `sigmoid_tanh` | `Sigmoid`, `-DCUTLASS_USE_TANH_FOR_SIGMOID` | `tanh.approx.f32` of `x / 2`, `fma` | `sigmoid` |
| `sigmoid_precise` | `Sigmoid` without `-use_fast_math` | libdevice's `expf` (an `fma` range reduction, `ex2.approx` of the fraction) and an `rcp.rn` division | `sigmoid` |
| `silu` | `SiLu` | `Sigmoid`'s code times `x` | `silu` |
| `tanh` | `Tanh` | `tanh.approx.f32` | `tanh` |
| `softplus` | `pytorch::Softplus` | `ex2.approx.ftz.f32`, `lg2.approx.ftz.f32` times `ln 2` | `softplus` |
| `softplus_threshold` | `pytorch::SoftplusThreshold`, threshold 20 | the same, as volatile asm, under a `selp` on `x > 20` | `softplus_threshold` |

`activations.h` holds the PyTorch activations CUTLASS has no functor for, written as PyTorch's
CUDA functors write them (`aten/src/ATen/native/cuda/Activation*.cu`) in `activation.h`'s form.
Their exponential is the `ex2.approx.ftz.f32` of `x * log2(e)` that `-use_fast_math`'s `expf`
lowers to, issued as a volatile asm before the select: with `cutlass::fast_exp` in the ternary,
nvcc branches around the exponential per element, a data-dependent branch Volta cannot execute,
as it does on Softshrink's nested ternary, which is therefore written with `max` and `min`, and
on the thresholded softplus, whose log is a volatile asm too.
`-use_fast_math` is what makes `expf` and `logf` the `ex2.approx` and `lg2.approx` instructions
and the sigmoid's division approximate; CUTLASS's `fast_tanh` is `tanh.approx.f32` regardless,
and its `GELU` calls `erff` regardless.

## Building

`extract.py` compiles every case (or the cases named on its command line) and writes
`<case>.ptx`, `<case>.json` (compiler, configuration, hashes) and `<case>.launch.json`. It
downloads CUTLASS v3.9.2, or takes a clean checkout with `--cutlass DIR`, and runs `nvcc`
locally when installed, else in the `nvidia/cuda:12.9.1-devel-ubuntu24.04` image
(`--backend local|docker`). No GPU is needed.

```sh
python3 external/approximations/cutlass/extract.py
python3 external/approximations/cutlass/extract.py --cutlass ~/cutlass sigmoid sigmoid_precise
```

One case runs with
`volta solve external/approximations/cutlass/relu.ptx --config external/approximations/cutlass/relu.launch.json`;
the folder's README has every verdict.
