# GEMMs fused with activations

Written by `table.py`. Each kernel is its launch file's tile of C = act(A @ B^T) (OpenCL's at M = 64, N = K = 256); Lean claims every output within 1/1000 of the spec.

| System / method | CUTLASS | AMD | OpenCL | Triton |
|---|---:|---:|---:|---:|
| Kernels tested | 18 | 17 | 15 | 18 |
| **Kernels verified** | | | | |
| Volta | 11 | n/a | n/a | 9 |
| Ours | 18 | 13 | 11 | 18 |

Volta: the canonical solver without the activation rewrites, on PTX inputs only (`n/a`: AMD assembly). Ours: verified by the rewrites or, failing them, by Lean, counted once.

## Each kernel

| Kernel | Volta | Rewrites | Rewrites (s) | Lean | Lean (s) | Cost (USD) | Verified by | Why not by the rewrites |
|---|---|---|---:|---|---:|---:|---|---|
| [`cutlass/celu`](../cutlass/celu.ptx) | UNKNOWN | ACCEPT | 9.3 | - | - | - | rewrites |  |
| [`cutlass/elu`](../cutlass/elu.ptx) | UNKNOWN | ACCEPT | 9.9 | - | - | - | rewrites |  |
| [`cutlass/gelu_erf`](../cutlass/gelu_erf.ptx) | REJECT | REJECT | 12.6 | proved | 4208 | 14.07 | Lean | equivalence: 16323 element(s) refuted by a numeric counterexample, first c[0] |
| [`cutlass/gelu_tanh`](../cutlass/gelu_tanh.ptx) | REJECT | ACCEPT | 10.7 | - | - | - | rewrites |  |
| [`cutlass/hardsigmoid`](../cutlass/hardsigmoid.ptx) | ACCEPT | ACCEPT | 9.1 | - | - | - | rewrites |  |
| [`cutlass/hardswish`](../cutlass/hardswish.ptx) | ACCEPT | ACCEPT | 10.1 | - | - | - | rewrites |  |
| [`cutlass/hardtanh`](../cutlass/hardtanh.ptx) | ACCEPT | ACCEPT | 10.1 | - | - | - | rewrites |  |
| [`cutlass/leaky_relu`](../cutlass/leaky_relu.ptx) | UNKNOWN | ACCEPT | 10.0 | - | - | - | rewrites |  |
| [`cutlass/relu`](../cutlass/relu.ptx) | ACCEPT | ACCEPT | 10.1 | - | - | - | rewrites |  |
| [`cutlass/selu`](../cutlass/selu.ptx) | UNKNOWN | ACCEPT | 10.7 | - | - | - | rewrites |  |
| [`cutlass/sigmoid`](../cutlass/sigmoid.ptx) | ACCEPT | ACCEPT | 10.3 | - | - | - | rewrites |  |
| [`cutlass/sigmoid_precise`](../cutlass/sigmoid_precise.ptx) | UNKNOWN | UNKNOWN | 16.2 | proved | 618 | 1.28 | Lean | equivalence: 16384 element(s) not proved equivalent and not refuted, first c[0] |
| [`cutlass/sigmoid_tanh`](../cutlass/sigmoid_tanh.ptx) | ACCEPT | ACCEPT | 9.8 | - | - | - | rewrites |  |
| [`cutlass/silu`](../cutlass/silu.ptx) | ACCEPT | ACCEPT | 9.8 | - | - | - | rewrites |  |
| [`cutlass/softplus`](../cutlass/softplus.ptx) | ACCEPT | ACCEPT | 10.4 | - | - | - | rewrites |  |
| [`cutlass/softplus_threshold`](../cutlass/softplus_threshold.ptx) | ACCEPT | ACCEPT | 9.4 | - | - | - | rewrites |  |
| [`cutlass/softshrink`](../cutlass/softshrink.ptx) | ACCEPT | ACCEPT | 9.7 | - | - | - | rewrites |  |
| [`cutlass/tanh`](../cutlass/tanh.ptx) | ACCEPT | ACCEPT | 9.2 | - | - | - | rewrites |  |
| [`composable_kernel/celu`](../composable_kernel/celu.s) | - | ACCEPT | 9.2 | - | - | - | rewrites |  |
| [`composable_kernel/elu`](../composable_kernel/elu.s) | - | UNKNOWN | 0.7 | not proved | 3 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 871: VCC bit in lane 0 must be concrete to form a lane mask Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: VCC bit in lane 0 must be concrete to form a lane mask |
| [`composable_kernel/fast_gelu`](../composable_kernel/fast_gelu.s) | - | ACCEPT | 9.9 | - | - | - | rewrites |  |
| [`composable_kernel/gelu`](../composable_kernel/gelu.s) | - | UNKNOWN | 0.7 | not proved | 3 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 869: scalar register s0 must contain a concrete 32-bit word Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: scalar register s0 must contain a concrete 32-bit word |
| [`composable_kernel/hardsigmoid`](../composable_kernel/hardsigmoid.s) | - | ACCEPT | 8.9 | - | - | - | rewrites |  |
| [`composable_kernel/hardswish`](../composable_kernel/hardswish.s) | - | ACCEPT | 8.9 | - | - | - | rewrites |  |
| [`composable_kernel/hardtanh`](../composable_kernel/hardtanh.s) | - | ACCEPT | 8.7 | - | - | - | rewrites |  |
| [`composable_kernel/leaky_relu`](../composable_kernel/leaky_relu.s) | - | UNKNOWN | 15.7 | proved | 259 | 0.34 | Lean | equivalence: 16384 element(s) not proved equivalent and not refuted, first c[0] |
| [`composable_kernel/relu`](../composable_kernel/relu.s) | - | ACCEPT | 9.1 | - | - | - | rewrites |  |
| [`composable_kernel/selu`](../composable_kernel/selu.s) | - | UNKNOWN | 0.6 | not proved | 1 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 852: scalar register s1 must contain a concrete 32-bit word Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: scalar register s1 must contain a concrete 32-bit word |
| [`composable_kernel/sigmoid`](../composable_kernel/sigmoid.s) | - | ACCEPT | 9.1 | - | - | - | rewrites |  |
| [`composable_kernel/sigmoid_precise`](../composable_kernel/sigmoid_precise.s) | - | ACCEPT | 9.2 | - | - | - | rewrites |  |
| [`composable_kernel/silu`](../composable_kernel/silu.s) | - | ACCEPT | 8.9 | - | - | - | rewrites |  |
| [`composable_kernel/softrelu`](../composable_kernel/softrelu.s) | - | REJECT | 11.3 | proved, inputs within 1/2 | 402 | 0.88 | Lean | equivalence: 16384 element(s) refuted by a numeric counterexample, first c[0] |
| [`composable_kernel/softshrink`](../composable_kernel/softshrink.s) | - | ACCEPT | 8.5 | - | - | - | rewrites |  |
| [`composable_kernel/swish`](../composable_kernel/swish.s) | - | ACCEPT | 9.0 | - | - | - | rewrites |  |
| [`composable_kernel/tanh`](../composable_kernel/tanh.s) | - | UNKNOWN | 0.7 | not proved | 1 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 869: scalar register s0 must contain a concrete 32-bit word Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: scalar register s0 must contain a concrete 32-bit word |
| [`opencl/celu`](../opencl/celu.s) | - | ACCEPT | 10.9 | - | - | - | rewrites |  |
| [`opencl/elu`](../opencl/elu.s) | - | UNKNOWN | 0.0 | not proved | 0 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 66: VCC bit in lane 0 must be concrete to form a lane mask Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: VCC bit in lane 0 must be concrete to form a lane mask |
| [`opencl/fast_gelu`](../opencl/fast_gelu.s) | - | ACCEPT | 11.3 | - | - | - | rewrites |  |
| [`opencl/gelu`](../opencl/gelu.s) | - | UNKNOWN | 0.0 | not proved | 0 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 77: scalar register s16 must contain a concrete 32-bit word Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: scalar register s16 must contain a concrete 32-bit word |
| [`opencl/hardsigmoid`](../opencl/hardsigmoid.s) | - | ACCEPT | 12.2 | - | - | - | rewrites |  |
| [`opencl/hardswish`](../opencl/hardswish.s) | - | ACCEPT | 10.5 | - | - | - | rewrites |  |
| [`opencl/hardtanh`](../opencl/hardtanh.s) | - | ACCEPT | 10.2 | - | - | - | rewrites |  |
| [`opencl/leaky_relu`](../opencl/leaky_relu.s) | - | ACCEPT | 10.2 | - | - | - | rewrites |  |
| [`opencl/relu`](../opencl/relu.s) | - | ACCEPT | 10.2 | - | - | - | rewrites |  |
| [`opencl/selu`](../opencl/selu.s) | - | UNKNOWN | 0.0 | not proved | 0 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 63: VCC bit in lane 0 must be concrete to form a lane mask Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: VCC bit in lane 0 must be concrete to form a lane mask |
| [`opencl/sigmoid`](../opencl/sigmoid.s) | - | ACCEPT | 10.7 | - | - | - | rewrites |  |
| [`opencl/silu`](../opencl/silu.s) | - | ACCEPT | 11.2 | - | - | - | rewrites |  |
| [`opencl/softrelu`](../opencl/softrelu.s) | - | REJECT | 13.4 | proved, inputs within 1/2 | 343 | 0.55 | Lean | equivalence: 16384 element(s) refuted by a numeric counterexample, first c[0] |
| [`opencl/softshrink`](../opencl/softshrink.s) | - | ACCEPT | 10.7 | - | - | - | rewrites |  |
| [`opencl/tanh`](../opencl/tanh.s) | - | UNKNOWN | 0.0 | not proved | 0 | - | - | equivalence: not decided: kernel: wave 0 aborted at instruction 67: scalar register s16 must contain a concrete 32-bit word Lean: Lean extraction failed: graph verification is UNKNOWN: the trace generator aborted, so the graph is only a prefix: scalar register s16 must contain a concrete 32-bit word |
| [`triton/celu`](../triton/celu.ptx) | UNKNOWN | ACCEPT | 11.0 | - | - | - | rewrites |  |
| [`triton/elu`](../triton/elu.ptx) | UNKNOWN | ACCEPT | 10.0 | - | - | - | rewrites |  |
| [`triton/gelu_erf`](../triton/gelu_erf.ptx) | REJECT | REJECT | 15.6 | proved | 3275 | 10.62 | Lean | equivalence: 15813 element(s) refuted by a numeric counterexample, first c[0] |
| [`triton/gelu_tanh`](../triton/gelu_tanh.ptx) | REJECT | ACCEPT | 11.9 | - | - | - | rewrites |  |
| [`triton/gelu_tanh_libdevice`](../triton/gelu_tanh_libdevice.ptx) | UNKNOWN | UNKNOWN | 22.1 | proved | 1598 | 5.21 | Lean | equivalence: not decided: equivalence check failed: VC too large: exceeded 4000000000 term operations |
| [`triton/hardsigmoid`](../triton/hardsigmoid.ptx) | ACCEPT | ACCEPT | 10.9 | - | - | - | rewrites |  |
| [`triton/hardswish`](../triton/hardswish.ptx) | ACCEPT | ACCEPT | 10.1 | - | - | - | rewrites |  |
| [`triton/hardtanh`](../triton/hardtanh.ptx) | ACCEPT | ACCEPT | 10.3 | - | - | - | rewrites |  |
| [`triton/leaky_relu`](../triton/leaky_relu.ptx) | UNKNOWN | ACCEPT | 9.9 | - | - | - | rewrites |  |
| [`triton/relu`](../triton/relu.ptx) | ACCEPT | ACCEPT | 9.9 | - | - | - | rewrites |  |
| [`triton/selu`](../triton/selu.ptx) | UNKNOWN | ACCEPT | 10.2 | - | - | - | rewrites |  |
| [`triton/sigmoid`](../triton/sigmoid.ptx) | ACCEPT | ACCEPT | 9.8 | - | - | - | rewrites |  |
| [`triton/silu`](../triton/silu.ptx) | ACCEPT | ACCEPT | 9.9 | - | - | - | rewrites |  |
| [`triton/softplus`](../triton/softplus.ptx) | UNKNOWN | UNKNOWN | 10.9 | proved, inputs within 1/2 | 587 | 2.00 | Lean | equivalence: not decided: equivalence check failed: non-finite constant -inf in expression |
| [`triton/softplus_fast`](../triton/softplus_fast.ptx) | ACCEPT | ACCEPT | 10.5 | - | - | - | rewrites |  |
| [`triton/softplus_threshold`](../triton/softplus_threshold.ptx) | ACCEPT | ACCEPT | 10.1 | - | - | - | rewrites |  |
| [`triton/softshrink`](../triton/softshrink.ptx) | UNKNOWN | ACCEPT | 11.1 | - | - | - | rewrites |  |
| [`triton/tanh`](../triton/tanh.ptx) | ACCEPT | ACCEPT | 10.7 | - | - | - | rewrites |  |
