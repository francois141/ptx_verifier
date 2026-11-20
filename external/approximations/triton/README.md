# Triton fused GEMM activations

The Triton matrix multiplication tutorial's kernel with a fused activation, `kernel.py`, at
M = N = K = 256: each program computes a 64 x 256 tile of `c = act(a @ b^T)` over the whole K with
`tl.dot` (TF32 tensor cores for fp32 operands, `mma.sync.aligned.m16n8k8.row.col.f32.tf32.tf32.f32`)
and applies `ACTIVATION`, a `constexpr` naming one of the activations below, before the store.
`extract.py` compiles it once per activation for Ampere (`sm_80`) with `M`, `N`, `K` and the
strides as constants. The 64 x 256 tile spans whole rows of C, so CTA 0 of the 4 x 1 grid, the one
Volta runs, writes rows 0..64: the launch files' `c` array.

| Setting | Value |
|---|---|
| Triton | 3.5.1 |
| Target | `sm_80`, PTX ISA 8.7 |
| Tile | 64 x 256 x 32, `num_warps=4`, `num_stages=3` (a `cp.async` pipeline) |
| Launch | 4 x 1 x 1 blocks of 128 threads, 81,920 bytes of shared memory |

Triton rounds nothing to TF32 in the kernel (the hardware ignores the operands' low 13 mantissa
bits), so to Volta the GEMM is the exact fp32 product.

| Case | Written as | Compiles to | Spec |
|---|---|---|---|
| `relu` | `tl.maximum(x, 0.0)` | `max.f32` | `relu` |
| `leaky_relu` | `tl.where(x > 0, x, 0.01 * x)` | `setp`, `selp` | `leaky_relu` |
| `hardtanh` | `tl.minimum(tl.maximum(x, -1.0), 1.0)` | `max.f32`, `min.f32` | `hardtanh` |
| `hardsigmoid` | `tl.minimum(tl.maximum(x + 3.0, 0.0), 6.0) * (1.0 / 6.0)` | `max`, `min`, `mul` by f32 `1/6` | `hardsigmoid` |
| `hardswish` | `x * tl.minimum(tl.maximum(x + 3.0, 0.0), 6.0) * (1.0 / 6.0)` | the same | `hardswish` |
| `softshrink` | nested `tl.where` on `x > 0.5` and `x < -0.5` | two `selp` | `softshrink` |
| `elu` | `tl.where(x > 0, x, tl.exp(x) - 1.0)` | `ex2.approx.f32` of `x * log2(e)`, `selp` | `elu` |
| `celu` | `tl.where(x > 0, x, 2.0 * (tl.exp(x * 0.5) - 1.0))` | the same, `2 * y` as `y + y` | `celu` |
| `selu` | `tl.where(x > 0, scale * x, negcoef * (tl.exp(x) - 1.0))`, PyTorch's f32 coefficients | `ex2.approx.f32`, `mul`, `selp` | `selu` |
| `gelu_tanh` | `0.5 * x * (1.0 + tanh_approx(0.7978845608028654 * (x + 0.044715 * x * x * x)))` | `tanh.approx.f32` (inline asm, as Liger-Kernel's GELU) | `gelu_tanh` |
| `gelu_tanh_libdevice` | the same with `libdevice.tanh` | `__nv_tanhf`: a polynomial below 0.55, `ex2` and `rcp.approx` above | `gelu_tanh` |
| `gelu_erf` | `0.5 * x * (1.0 + libdevice.erf(x * 0.7071067811865476))` | `__nv_erff`: polynomials, branching on `|x| < 1` | `gelu_erf` |
| `sigmoid` | `tl.sigmoid(x)` | `ex2.approx.f32`, `div.full.f32` | `sigmoid` |
| `silu` | `x * tl.sigmoid(x)` | the same times `x` | `silu` |
| `tanh` | `tanh_approx(x)` | `tanh.approx.f32` | `tanh` |
| `softplus` | `tl.log(1.0 + tl.exp(x))` | `__nv_logf`: libdevice's range-reduced polynomial | `softplus` |
| `softplus_fast` | `libdevice.fast_logf(1.0 + tl.exp(x))` | `lg2.approx.ftz.f32` times f32 `ln 2` | `softplus` |
| `softplus_threshold` | `tl.where(x > 20.0, x, libdevice.fast_logf(1.0 + tl.exp(x)))` | the same under a `selp` | `softplus` |

Python's float constants become f32 constants next to the fp32 tiles, so `0.01` and `1.0 / 6.0`
are PyTorch's `0.01f` and `one_sixth`; the specs state those f32 values. `tl.log` is libdevice's
`__nv_logf` in this Triton, where `tl.exp` is the `ex2.approx` instruction.

## Building

`extract.py` runs under `triton==3.5.1` on Linux (no GPU) and writes, per case, `<case>.ptx`,
`<case>.json` (compiler, constants, hashes) and `<case>.launch.json`. On this Mac it runs in the
`volta-tritonbench:triton-3.5.1` image, from this directory:

```sh
docker create --name volta-triton-approximations --workdir /work \
  volta-tritonbench:triton-3.5.1 python extract.py --out /work/out
docker cp kernel.py volta-triton-approximations:/work/
docker cp extract.py volta-triton-approximations:/work/
docker start --attach volta-triton-approximations
docker cp volta-triton-approximations:/work/out/. .
docker rm volta-triton-approximations
```

Case names after `extract.py` build only those. One case runs with
`volta solve external/approximations/triton/relu.ptx --config external/approximations/triton/relu.launch.json`;
the folder's README has every verdict.
