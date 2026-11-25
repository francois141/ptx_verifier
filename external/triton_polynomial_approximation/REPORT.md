# Triton polynomial approximations: Lean proofs

Written by `prove.py`. Each kernel's 64 outputs are claimed within 1/1000 of the exact function it approximates; `softplus` for inputs within 88 in absolute value. Every proof was written by a Claude Code agent and checked by Lean and `leanchecker`.

| Kernel | Function | Approximation | Statements | Proof (lines) | Proof (bytes) | Time (s) | Turns | Cost (USD) | All attempts (USD) |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| [`tanh`](tanh.ptx) | tanh(x) | libdevice `tanhf`: odd polynomial below 0.6, `1 - 2/(e^2x + 1)` above | 1 | [157](lean/tanh/proof.lean) | 6584 | 516 | 13 | 1.14 | 1.14 |
| [`softplus`](softplus.ptx) | log(1 + e^x) | libdevice `logf`: exponent/mantissa split, degree-10 polynomial | 1 | [139](lean/softplus/proof.lean) | 8017 | 582 | 14 | 1.16 | 1.24 |
| [`gelu_erf_as`](gelu_erf_as.ptx) | GELU with erf | Abramowitz-Stegun 7.1.26 `erf` (the AI compiler's) | 1 | [484](lean/gelu_erf_as/proof.lean) | 26384 | 1609 | 24 | 5.87 | 7.94 |
| [`gelu_erf`](gelu_erf.ptx) | GELU with erf | libdevice `erff`: two degree-6 polynomials split at 1.003 | 1 | [979](lean/gelu_erf/proof.lean) | 51485 | 3547 | 46 | 12.90 | 14.03 |
| **Total** | | | | | | | | **21.07** | **24.35** |

Time, turns and cost are the proving attempt's; the last column adds the earlier attempts that did not prove the case (`lean/<case>/attempts.json` lists each).
