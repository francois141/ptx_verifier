# OpenCL GEMM + activation: verification report

Written by `prove.py` (`just opencl_lean`). Each kernel is a 128x128x128 GEMM with the activation fused; the canonical solver checks it at that size, and Lean, when the solver does not accept it, checks the same binary at 8x8x8.

| Case | Spec | Canonical solver | Lean | Verified by |
|---|---|---|---|---|
| `celu` | `celu` | UNKNOWN (14 s) | challenge written, not proved (`--extract-only`) | not verified |
| `elu` | `elu` | UNKNOWN (0 s) | no challenge: VCC bit in lane 0 must be concrete to form a lane mask | not verified |
| `fast_gelu` | `gelu_tanh` | skipped (too long) | - | skipped |
| `gelu` | `gelu_erf` | UNKNOWN (0 s) | no challenge: scalar register s16 must contain a concrete 32-bit word | not verified |
| `hardsigmoid` | `hardsigmoid` | ACCEPT (9 s) | - | canonical solver (128x128x128) |
| `hardswish` | `hardswish` | ACCEPT (11 s) | - | canonical solver (128x128x128) |
| `hardtanh` | `hardtanh` | ACCEPT (8 s) | - | canonical solver (128x128x128) |
| `leaky_relu` | `leaky_relu` | ACCEPT (8 s) | - | canonical solver (128x128x128) |
| `relu` | `relu` | ACCEPT (8 s) | - | canonical solver (128x128x128) |
| `selu` | `selu` | UNKNOWN (0 s) | no challenge: VCC bit in lane 0 must be concrete to form a lane mask | not verified |
| `sigmoid` | `sigmoid` | UNKNOWN (12 s) | challenge written, not proved (`--extract-only`) | not verified |
| `silu` | `silu` | UNKNOWN (16 s) | challenge written, not proved (`--extract-only`) | not verified |
| `softrelu` | `softplus` | UNKNOWN (0 s) | no challenge: lane 0 selects between two constant words under a symbolic condition, which may encode floats or integers | not verified |
| `softshrink` | `softshrink` | ACCEPT (9 s) | - | canonical solver (128x128x128) |
| `tanh` | `tanh` | UNKNOWN (0 s) | no challenge: scalar register s16 must contain a concrete 32-bit word | not verified |
