# CK activations

Composable Kernel's activation element-wise ops (CK pin `5a74dec`), each applied to 64 fp32
elements, one per work-item of one 64-work-item workgroup. Every case is a kernel
`<kernel>.hip`/`.s`, a launch file `<case>.launch.json` and, where the spec language can state
it, a spec. Parameterized ops are constructed on the host and passed by value, as CK does; the
launch files give CK's default parameters as exact f32 values. `just amd_activations` runs
them through `../../verify.py`.

| Case | CK op | Verdict | Why |
|------|-------|---------|-----|
| `ck_relu` | `ck_tile::element_wise::Relu` | ACCEPT | |
| `ck_clipped_relu` | `ClippedRelu` (0, 1) | ACCEPT | |
| `ck_sigmoid` | `Sigmoid` | ACCEPT | |
| `ck_logistic` | `Logistic` (alpha 1) | ACCEPT | |
| `ck_silu` | `Silu` | ACCEPT | |
| `ck_swish` | `Swish` (beta 1) | ACCEPT | |
| `ck_fast_gelu` | `FastGelu` | ACCEPT | |
| `ck_fast_gelu_asm` | `FastGeluAsm` | REJECT | ROCm/composable_kernel#3763: the asm's scratch register is `c2`'s, so the kernel computes `x / (1 + exp((x^2 c1 + x^2) x))` |
| `ck_fast_gelu_asm_fixed` | `FastGeluAsm`, scratch `"=&v"` | ACCEPT | |
| `ck_unary_abs` | `UnaryAbs` | ACCEPT | |
| `ck_neg` | `Neg` | ACCEPT | |

## Compiling

`-nogpulib` omits ROCm's device library, so `ocml.hpp` defines the OCML functions the ops call as
ROCm 7.0.0's device-libs (`amd/device-libs/ocml/src`) define them, with the finite-only and
unsafe-math controls hipcc links under `-ffast-math`. `-ffast-math` is what lowers `exp` to
`v_exp_f32` and divisions to `v_rcp_f32`; without it `exp` keeps its range reduction. It does
not change `FastGeluAsm`'s register allocation. With Clang 21.1.8, that CK checkout (`CK_ROOT`)
and the HIP 7.0.2 headers (`HIP_ROOT`), from this directory:

```sh
for hip in *.hip; do
  clang++ -x hip -std=c++20 -fbracket-depth=1024 \
    --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
    --hip-path="$HIP_ROOT" -DNDEBUG -Wno-unknown-warning-option -Wno-nan-infinity-disabled \
    -O3 -g0 -fno-verbose-asm -fgpu-flush-denormals-to-zero -ffast-math \
    -fno-hip-fp32-correctly-rounded-divide-sqrt -I "$CK_ROOT/include" \
    -S "$hip" -o "${hip%.hip}.s"
done
```

One case runs with `volta solve <kernel>.s --config <case>.launch.json`.
