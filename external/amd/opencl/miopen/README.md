# MIOpen's OpenCL kernels (gfx950)

Fifteen OpenCL kernels of [MIOpen](https://github.com/ROCm/rocm-libraries/tree/develop/projects/miopen),
AMD's DNN library, at tag `rocm-7.2.4`: the ones its solvers still dispatch on gfx950, compiled and
launched as MIOpen compiles and launches them there, and checked by Volta. The registry is
`cases.py`; `extract.py` compiles it and `external/amd/verify.py` runs it (`just opencl`). The
toolchain, device libraries and what the AMD frontend learned for these kernels are in
[`../README.md`](../README.md).

    python3 external/amd/opencl/miopen/extract.py [--clang PATH] [CASE...]

## How the kernels are built

- **Sources.** `projects/miopen/src/kernels` of ROCm/rocm-libraries at `rocm-7.2.4`, a sparse
  checkout in `target/opencl/rocm-libraries`.
- **Build parameters.** Each case follows one solver's `GetSolution` (named in its launch file's
  description): its `-D` build parameters for the case's problem, its work sizes, and the kernel
  arguments its invoker passes.
- **Options.** Those of comgr (`src/comgr.cpp`): `-cl-std=CL2.0 -O3 -mllvm -amdgpu-early-inline-all
  -mllvm -amdgpu-prelink -mllvm -amdgpu-internalize-symbols`, no fast math and f32 denormals kept,
  so division and `exp` are LLVM's accurate expansions.

## Cases

| Kernel | Cases | Configuration | Verdict |
|---|---|---|---|
| `SoftmaxForward` | `softmax_c1000`, `softmax_c64` | channel mode fp32: [1, 1000, 1, 1] (CSR-Vector, one vector per workgroup) and [1, 64, 2, 2] (CSR-Stream, 4 per workgroup) | ACCEPT |
| `SoftmaxBackward` | `softmax_bwd_c1000`, `softmax_bwd_c64` | the same shapes, `dx = y (dy - sum y dy)` | ACCEPT |
| `MIOpenBatchNormFwdInferSpatialEst` | `bn_infer_spatial` | [2, 1, 16, 16], float4 loads, OCML `rsqrt` | ACCEPT |
| `MIOpenBatchNormFwdInferPerActivationEst` | `bn_infer_peract` | [2, 1, 16, 16] | ACCEPT |
| `MIOpenBatchNormFwdTrainSpatial` | `bn_train_spatial` | variant 0, [8, 1, 8, 8], DPP and LDS reduction of the mean and variance, saved mean and inverse deviation | ACCEPT |
| `MIOpenBatchNormBwdSpatial` | `bn_bwd_spatial` | variant 0, [8, 1, 8, 8], 1024 work-items, from saved statistics | ACCEPT |
| `MIOpenBatchNormBwdPerActivationSaved` | `bn_bwd_peract` | [4, 1, 8, 8] | ACCEPT |
| `MIOpenActiveFwdLite` | `sigmoid_fwd`, `relu6_fwd` | 1024 elements as float4: logistic, clipped ReLU (alpha 6) | ACCEPT |
| `MIOpenActiveBwdLite` | `sigmoid_bwd` | logistic gradient | ACCEPT |
| `OpTensorFwdBias` | `bias_add` | A [2, 4, 16, 16] + B [1, 4, 1, 1], workgroup 0's plane | ACCEPT |
| `OpTensorLeadingOnes` | `leading_ones_mul` | A [2, 3, 8, 8] * B [2, 1, 1, 1], image 0 | ACCEPT |
| `MIOpenConvBwdB` | `conv_bwd_bias`, `conv_bwd_bias_k257` | dy [2, 4, 7, 7] (a 1-element tail per map); [2, 257, 3, 3], two channels per workgroup, graph checks only | ACCEPT, VERIFIED |
| `UniversalTranspose` | `transpose_nhwc_nchw` | NHWC [1, 4, 2, 2] to NCHW, 256 work-items | ACCEPT |
| `SubTensorOpWithSubTensor2d` | `copy_tensor` | `miopenCopyTensor`, a [6, 10] view of a [6, 16] buffer | ACCEPT |
| `SubTensorOpWithTransform2d` | `transform_tensor` | `miopenTransformTensor`, y = 0.5 x from the same view | ACCEPT |

## Bugs

| Case (fixed twin) | Bug | What Volta reports |
|---|---|---|
| `softmax_pixels_race`, `softmax_bwd_rows_race` (`_fixed`) | The CSR-Vector loop of `SoftmaxForward` and `SoftmaxBackward` (`MIOpenSoftmax.cl`, the `NUM_BATCH == 1` path) reads the reduced value from `l_helper[0]` and starts the next vector with `l_helper[lid] = ...` with no barrier between. When a workgroup handles two vectors (more than 20480 vectors of 256 or more elements: channel-mode forward over a 256-class 144 x 144 map, or any backward), wave 0 can overwrite `l_helper[0]` with its next-vector partial before the other waves read the sum, which they then normalize by. Fix: a barrier closing each iteration (`MIOpenConvBwdBias.cl`'s loop already has one). | REJECTED: 192 LDS write/read conflicts on `l_helper[0]`; with the fix VERIFIED |
| `transpose_nhwc_nchw_256` (`_fixed`) | `UniversalTransposeSolver` (`transposing_solver.hpp`) launches one workgroup of 16 x min(elements, compute units) work-items: 4096 on an MI355X (256 CUs) from 256 elements, past the hardware's 1024 and the 256 of the kernel's code object (`.max_flat_workgroup_size`). It is the transpose of the transposing pooling solvers, which serve every NHWC pooling forward. Fix: launch at most 256; the kernel's loop strides by the local size. | launch rejected; with 256 work-items ACCEPT |

## Not here

The kernels using OpenCL `tanh`, `pow` or `log`, whose OCML versions branch on the argument (the
LSTM hidden-state update, the power and soft-ReLU activations, LRN, CTC loss); the f64 `rsqrt`
with a Newton step that kernels adding a `double` epsilon to a float run (per-activation training,
fused batch norm plus activation); ReLU written `x * (x > 0)`, a select the canonical solver cannot
match with `max`; in-place calls (`ScaleTensor`, `beta != 0`), as Volta's arrays are inputs or
outputs. MIOpen's OpenCL direct convolutions are not applicable on gfx950 (their solvers stop at
gfx8, gfx90* and gfx103).
