# CK activations without fast math

The activation ops of `../activations/` (CK pin `5a74dec`), from the same sources, specs and
launch files, compiled without `-ffast-math`. `just amd_activations` runs both folders' cases
through `../../verify.py`.

Without `-ffast-math`, `max` and `min` first canonicalize NaNs (`v_max_f32 x, x`, and
`v_max_f32_e64` for ClippedRelu's bounds in SGPRs), and `exp` keeps its range reduction:
`v_rndne_f32` splits off the integer part of `x log2(e)` for `v_ldexp_f32`, and past the overflow
and underflow bounds the result is `+inf` and 0. FastGeluAsm computes its exponential in inline
asm, so its assembly is the same as with `-ffast-math`.

| Case | CK op | Verdict | Why |
|------|-------|---------|-----|
| `ck_relu` | `ck_tile::element_wise::Relu` | ACCEPT | |
| `ck_clipped_relu` | `ClippedRelu` (0, 1) | ACCEPT | |
| `ck_fast_gelu_asm` | `FastGeluAsm` | REJECT | ROCm/composable_kernel#3763, as in `../activations/` |
| `ck_fast_gelu_asm_fixed` | `FastGeluAsm`, scratch `"=&v"` | ACCEPT | |

The ops that call `exp` are not here: its overflow branch is `+inf`, a constant the canonical
solver rejects, and past its bounds the range-reduced `exp` is not `e^x` over the reals either.

## Compiling

With the toolchain of `../activations/`, from this directory:

```sh
for hip in *.hip; do
  clang++ -x hip -std=c++20 -fbracket-depth=1024 \
    --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
    --hip-path="$HIP_ROOT" -DNDEBUG -Wno-unknown-warning-option \
    -O3 -g0 -fno-verbose-asm -fgpu-flush-denormals-to-zero \
    -fno-hip-fp32-correctly-rounded-divide-sqrt -I "$CK_ROOT/include" \
    -S "$hip" -o "${hip%.hip}.s"
done
```

One case runs with `volta solve <kernel>.s --config <case>.launch.json`.
