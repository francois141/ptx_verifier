# Polynomial approximations in Triton

Four 1D activations over 64 fp32 elements, one per thread, compiled by Triton 3.5.1 for `sm_80`
from [`kernel.py`](kernel.py). Each computes its function through a polynomial approximation
that the compiler or the kernel's author substitutes for it, so none is its spec over the reals.
Volta runs each kernel and states every output within `1/1000` of the spec, and a Lean proof
shows that claim.

| Case | Approximation | Spec |
|---|---|---|
| `gelu_erf` | libdevice's `erff`: two degree-6 polynomials split at `\|z\| = 1.003`, the upper one under `1 - 2^p` | [`gelu_erf.spec`](gelu_erf.spec), `0.5 x (1 + erf(x / sqrt 2))` |
| `tanh` | libdevice's `tanhf`: an odd polynomial below `\|x\| = 0.6`, `1 - 2 / (e^2x + 1)` above, 1 past 9.01 | [`tanh.spec`](tanh.spec) |
| `softplus` | `tl.log`, libdevice's `logf`: the exponent and mantissa split on the float's bits, a degree-10 polynomial of the mantissa | [`softplus.spec`](softplus.spec), `log(1 + e^x)` |
| `gelu_erf_as` | the AI compiler's GELU: Abramowitz and Stegun's 7.1.26 erf, `1 - (a1 t + ... + a5 t^5) e^(-z^2)` for `t = 1 / (1 + p\|z\|)` | [`gelu_erf.spec`](gelu_erf.spec) |

What Volta needs for them:

- **Branches on the argument.** libdevice picks its polynomial with a branch on `|x|`. A branch
  on a symbolic predicate whose arms only compute into registers is if-converted: both arms run
  to the branch's immediate post-dominator and every register they leave different becomes a
  select (`volta_ptx_analysis`'s `eval/branch.rs`). An arm that stores, synchronizes or exits
  is still rejected.
- **The sign transfer** `(x & 0x80000000) | y` of two floats is `x < 0 ? -|y| : y`.
- **`logf`'s bit fields** (`eval/float_fields.rs`): for a positive float `v`,
  `(bits(v) - bits(c)) & 0xff800000` is `k * 2^23` with `k = floor(log2(v / c))`, `bits(v)`
  minus it is the mantissa `v * 2^-k`, and `bits(v) < bits(f)` unsigned is `0 <= v < f`.
- **Lean**: the challenge defines `erf x = 2 / sqrt pi * integral_0^x e^(-t^2)` where a statement
  uses it, writes `floor` as `⌊·⌋`, and states each infinity as a universally quantified real, so
  a proof must show its branch does not matter (`softplus`'s `log 0 = -inf`, never reached).

The canonical solver refutes `gelu_erf`, `tanh` and `gelu_erf_as` (a polynomial is not the
function) and stops at `softplus`'s infinity; only Lean decides them.

`softplus` is claimed only for inputs within 88 in absolute value (`--input-bound 88`, Lean's
`|v0| ≤ 88 →`). `logf` multiplies the exponent `k ≈ x / ln 2` by ln 2 rounded to f32, which is
1.9e-9 off, so over all reals its error grows without bound and passes `1/1000` near
`x = 364,000`. On the hardware `e^x` overflows to infinity past 88.72, so no f32 input reaches
that drift.

## Running

```sh
docker run --rm -v "$PWD/external/triton_polynomial_approximation":/work -w /work \
  volta-tritonbench:triton-3.5.1-torch-2.9.0 python extract.py      # recompile the kernels
cargo build --release -p volta_cli
target/release/volta solve external/triton_polynomial_approximation/tanh.ptx \
  --config external/triton_polynomial_approximation/tanh.launch.json             # run one kernel
uv run --reinstall-package volta --package volta python external/triton_polynomial_approximation/prove.py
```

`prove.py` proves every case (or those named) with Claude Code into
`target/lean/activation_triton/<case>/`, rechecks a proof whose challenge is unchanged, and
copies each proved case's `challenge.lean` and `proof.lean` to [`lean/<case>/`](lean/).
Each agent attempt is recorded in `lean/<case>/attempts.json`, and [`REPORT.md`](REPORT.md)
lists each proof's length, time, turns and price (`prove.py --report` rewrites it alone). It needs
`$VOLTA_LEAN_PROJECT` (or the repository's `.env`).
