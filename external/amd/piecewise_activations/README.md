# PyTorch's piecewise activations

PyTorch's continuous piecewise activations (`torch.nn`), each applied to 64 fp32 elements, one
per work-item of one 64-work-item workgroup. Every kernel is written as PyTorch's CUDA functor
writes it, in a header-free `<kernel>.hip` compiled to `<kernel>.s`; every case is a launch file
`<case>.launch.json` and a spec. `just piecewise` runs them through `../verify.py`.

A kernel compiles these activations to selects, which the canonical solver cannot match with a
spec's `max` and `min`. One rewrite per activation in
`crates/volta_expr/src/symbolic_simplified/rewrite/` turns the kernel's selects into its spec's
form first. Constants that are not exact in float32 (LeakyReLU's 0.01, PyTorch's `one_sixth`,
SELU's `scale` and PyTorch's f32 product `alpha * scale`) appear in the launch files and specs
as their exact f32 values.

| Case | Kernel | PyTorch op | Rewrite | Verdict |
|------|--------|------------|---------|---------|
| `hardtanh` | `hardtanh` | `Hardtanh` (-1, 1) | `hardtanh.rs` | ACCEPT |
| `leaky_relu` | `leaky_relu` | `LeakyReLU` (0.01) | `leaky_relu.rs` | ACCEPT |
| `hardsigmoid` | `hardsigmoid` | `Hardsigmoid` | `hardtanh.rs` | ACCEPT |
| `hardswish` | `hardswish` | `Hardswish` | `hardtanh.rs` | ACCEPT |
| `hardswish_fast` | `hardswish_fast` | `Hardswish`, `-ffast-math` (native `v_max`, `v_min`) | none | ACCEPT |
| `hardswish_nans` | `hardswish_nans` | `Hardswish`, `-funsafe-math-optimizations` | `hardtanh.rs` | ACCEPT |
| `softshrink` | `softshrink` | `Softshrink` (0.5) | `softshrink.rs` | ACCEPT |
| `elu` | `elu` | `ELU` (alpha 1) | `elu.rs` | ACCEPT |
| `celu` | `celu` | `CELU` (alpha 2), as `elu(x, alpha, 1, 1 / alpha)` | `elu.rs` | ACCEPT |
| `selu` | `selu` | `SELU`, as `elu(x, alpha, scale, 1)` | `elu.rs` | ACCEPT |

The spec language has no conditional, so ELU, CELU and SELU are stated as
`max(x, 0) + alpha * (exp(min(x, 0)) - 1)` forms, the same functions. Hardshrink and Threshold
are discontinuous, which `max` and `min` cannot state, so they have no case.

## Compiling

`elu.hip`, `celu.hip` and `selu.hip` compute both pieces before their select, so clang emits a
`v_cndmask` rather than a branch on `x`, and take `expm1` as the hardware `exp2` of
`x * log2(e)`, minus 1. `celu.hip` and `hardtanh.hip` take `n` first so their arguments end on a
16-byte boundary: clang reads their trailing arguments with one 16-byte load, which would run
past a 28-byte argument segment. `hardswish_fast.hip` and `hardswish_nans.hip` are
`hardswish.hip` under their own names, compiled with `-ffast-math` and
`-funsafe-math-optimizations`. With LLVM's clang, from this directory:

```sh
for hip in *.hip; do
  case "$hip" in
    hardswish_fast.hip) flags=-ffast-math ;;
    hardswish_nans.hip) flags=-funsafe-math-optimizations ;;
    *) flags= ;;
  esac
  clang -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
    -nogpuinc -O2 -g0 -fno-verbose-asm $flags -S "$hip" -o "${hip%.hip}.s"
done
```
