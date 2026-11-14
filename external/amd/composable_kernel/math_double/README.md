# CK double math

Composable Kernel's device `double` specializations (CK pin `5a74dec`): legacy CK's
`ck::math::cos` (`ck/utility/math_v2.hpp:970`) and CK Tile's `exp`
(`ck_tile/core/numeric/math_v2.hpp:889`). Legacy CK's `exp`, `log`, `pow` and `expm1`
(lines 892-952) and CK Tile's `log`, `pow` and `expm1` (lines 951-987) have the same bug and
are not cases here. Each is written `return cos(x);` and so on. Inside the namespace,
unqualified lookup finds the specialization itself rather than HIP's `::cos(double)`, so it
calls itself forever. The recursion is undefined behaviour, and from `-O1` up the compiler
deletes it together with the store: every kernel here compiles to a bare `s_endpgm`. The fix is to qualify the call (`::cos(x)`).

Each kernel applies its specialization to 64 fp32 inputs widened to `double`, one per
work-item, and stores the result narrowed to fp32. Its spec states the function, so Volta
rejects each case for writing none of its 64 outputs. The spec language has no `cos`, so
`ck_math_cos_double` takes a scalar `x`, which its launch gives as 0, against `y = 1`.

| Case | Function | Verdict |
|------|----------|---------|
| `ck_math_cos_double` | `ck::math::cos<double>` | REJECT |
| `ck_tile_exp_double` | `ck_tile::exp<double>` | REJECT |

`uv run --package volta python external/amd/verify.py math_double` runs them.

## Compiling

The legacy header needs `ck/config.h`, generated from `config.h.in` as CK's CMake does for
gfx950 (all data types, `CK_USE_XDL`, `CK_USE_OCP_FP8`, `CK_USE_NATIVE_MX_SUPPORT`), in a
directory `CK_CONFIG` searched before CK's headers. With Clang 21.1.8, that CK checkout
(`CK_ROOT`) and the HIP 7.0.2 headers (`HIP_ROOT`), from this directory:

```sh
for hip in *.hip; do
  clang++ -x hip -std=c++20 -fbracket-depth=1024 \
    --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
    --hip-path="$HIP_ROOT" -DNDEBUG -Wno-unknown-warning-option \
    -O3 -g0 -fno-verbose-asm -fgpu-flush-denormals-to-zero \
    -fno-hip-fp32-correctly-rounded-divide-sqrt -I "$CK_CONFIG" -I "$CK_ROOT/include" \
    -S "$hip" -o "${hip%.hip}.s"
done
```
