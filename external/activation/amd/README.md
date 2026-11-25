# Polynomial approximations on AMD

AMD kernels whose activation is a polynomial or rational approximation, proved in Lean within a
tolerance of the function it approximates. The kernels live where they were compiled; this
folder holds the launches, a spec and [`prove.py`](prove.py).

| Case | Kernel | Approximation | Launch | Spec | Tolerance |
|---|---|---|---|---|---|
| `opencl_tanh` | [`opencl/tanh.s`](../../approximations/opencl/tanh.s) | OCML `tanh`: a polynomial below `\|x\| = 0.625`, `1 - 2 / (e^2x + 1)` above, behind clang's denormal guard | `c[0, n] = act(a[0] b[n])`: the GEMM at M = 1, N = 64, K = 1 | `tanh` | 1/1000 |
| `opencl_gelu` | [`opencl/gelu.s`](../../approximations/opencl/gelu.s) | OCML `erf`: two polynomials split at `\|z\| = 1`, `z = x / sqrt 2` | same | `gelu_erf` | 1/1000 |
| `opencl_elu` | [`opencl/elu.s`](../../approximations/opencl/elu.s) | OCML `expm1`: `2^n (1 + p(r)) - 1` with `n = rint(x log2 e)`, -1 below -17 | same | `elu` | 1/1000 |
| `ck_tanh` | [`composable_kernel/tanh.s`](../../approximations/composable_kernel/tanh.s) | CK's `TanH`, OCML `tanh` | workgroup 0's 64 x 256 tile, K = 256 | `tanh` | 1/1000 |
| `ck_gelu` | [`composable_kernel/gelu.s`](../../approximations/composable_kernel/gelu.s) | CK's `Gelu`, OCML `erf` | same | `gelu_erf` | 1/1000 |
| `ck_elu` | [`composable_kernel/elu.s`](../../approximations/composable_kernel/elu.s) | CK's `Elu`, OCML `expm1` | same | `elu` | 1/1000 |
| `aiter_gelu_fast` | [`aiter/activation.s`](../../amd/aiter/activation.s) | Aiter's `fast_tanh`: the Pade approximant `x (135135 + 17325x^2 + 378x^4 + x^6) / (135135 + 62370x^2 + 3150x^4 + 28x^6)`, clamped, 1 past `\|x\| = 3.8` | 128 bf16 elements, one workgroup | [`gelu_tanh.spec`](gelu_tanh.spec) | 1/500 |

The specs of the first six are [`../../approximations/specs/`](../../approximations/specs/)'s.

## What Volta needs for them

OCML picks its polynomial with an if/else on the argument, compiled to EXEC masks:
`v_cmp`, `s_and_saveexec_b64`, the arm, `s_andn2_saveexec_b64`, the other arm, `s_or_b64 exec`.
`volta_amd_analysis`'s `eval/divergence.rs` gives EXEC a predicate per lane while a mask holds a
symbolic comparison: the `saveexec` family computes lane by lane (with `p && !p` false and
`p || !p` true, so EXEC is concrete again after the else), a vector instruction writes each
guarded lane as `select(p, new, old)` and reads an earlier guarded write `select(p, x, _)` as
`x`, and `s_cbranch_execz` runs the arm it would skip, its writes guarded. A memory access, a
lane exchange or `v_readfirstlane` under such a predicate is rejected.

The arms also need:

- `v_bfi_b32 d, 0x7fffffff, m, s`, the sign transfer: `s < 0 ? -|m| : |m|`.
- `expm1`'s exponent `n == 128 ? 127 : cvt_i32(n)`: a select of an integer and a word, both
  integers, and `v_ldexp_f32 1.0, e` scaling each side by `2^e`.
- In Lean, `rint` (`v_rndne_f32`): rounding to nearest, ties to even, defined in a challenge
  that uses it, since Mathlib's `round` takes ties up.

## Aiter's `fast_tanh` misses its own target

Its comment targets an absolute error of 1e-3 on `tanh`, but it returns 1 from `|x| = 3.8`,
where `1 - tanh(3.8) = 1.0004e-3`. The GELU it feeds, `0.5 x (1 + fast_tanh(inner))`, is up to
1.62e-3 from PyTorch's tanh GELU (at `x = -3.24`), so it is claimed and proved within 1/500, and
"within 1/1000" is false.

## Running

```sh
cargo build --release -p volta_cli
uv run --reinstall-package volta --package volta python external/activation/amd/prove.py
```

`prove.py` proves every case (or those named) with Claude Code into
`target/lean/activation_amd/<case>/`, rechecks a proof whose challenge is unchanged, and copies
each proved case's `challenge.lean` and `proof.lean` to [`lean/<case>/`](lean/). It needs
`$VOLTA_LEAN_PROJECT` (or the repository's `.env`).
