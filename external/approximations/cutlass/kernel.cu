// Instantiation of NVIDIA CUTLASS's SM80 TF32 tensor-core GEMM with ACTIVATION, an epilogue
// activation functor, fused through LinearCombinationGeneric. CUTLASS v3.9.2:
// ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e; see CUTLASS_LICENSE.txt. extract.py compiles one
// kernel per activation: nvcc ... -DACTIVATION=<functor template> kernel.cu
#include <cutlass/epilogue/thread/activation.h>
#include <cutlass/epilogue/thread/linear_combination_generic.h>
#include <cutlass/gemm/device/gemm.h>

#include "activations.h"

#ifndef ACTIVATION
#error "compile with -DACTIVATION=<epilogue activation functor template>"
#endif

// D = ACTIVATION(alpha * accumulator) with alpha = 1 and no source (beta = 0), four fp32 at a time.
using EpilogueOp = cutlass::epilogue::thread::LinearCombinationGeneric<ACTIVATION, float, 4, float, float>;

// The transpose of CUTLASS's SM80 TF32 GEMM test configuration 256x64x32_64x64x32 (test/unit/gemm/
// device/gemm_tf32t_tf32n_f32t_tensor_op_f32_sm80.cu): tf32 operands, fp32 accumulation, 4 warps,
// 3 stages. A 64 x 256 threadblock tile spans whole rows of C, so CTA 0 writes rows 0..64 of C.
using Gemm = cutlass::gemm::device::Gemm<
    cutlass::tfloat32_t, cutlass::layout::RowMajor,
    cutlass::tfloat32_t, cutlass::layout::ColumnMajor,
    float, cutlass::layout::RowMajor,
    float, cutlass::arch::OpClassTensorOp, cutlass::arch::Sm80,
    cutlass::gemm::GemmShape<64, 256, 32>,
    cutlass::gemm::GemmShape<64, 64, 32>,
    cutlass::gemm::GemmShape<16, 8, 8>,
    EpilogueOp,
    cutlass::gemm::threadblock::GemmIdentityThreadblockSwizzle<>,
    3>;
using Kernel = Gemm::GemmKernel;

// The parameters of the functors that take them: LeakyReLU's slope (PyTorch's default) and
// Clamp's bounds (Hardtanh's). The int overloads apply to the functors with that member.
template <typename Params>
CUTLASS_DEVICE auto set_arguments(Params &params, int) -> decltype(params.leaky_alpha, void()) {
  params.leaky_alpha = 0.01f;
}
template <typename Params>
CUTLASS_DEVICE auto set_arguments(Params &params, int) -> decltype(params.lower_bound, void()) {
  params.lower_bound = -1.0f;
  params.upper_bound = 1.0f;
}
template <typename Params>
CUTLASS_DEVICE void set_arguments(Params &, long) {}

// Construct the ordinary CUTLASS Params at compile-time-known dimensions. This replaces its host
// launch plumbing, not its mainloop or epilogue. The tf32 operands are the fp32 words as stored.
extern "C" __global__ __launch_bounds__(Kernel::kThreadCount)
void cutlass_gemm(float const *a, float const *b, float *c) {
  extern __shared__ __align__(16) unsigned char storage[];
  EpilogueOp::Params epilogue(1.0f, 0.0f);
  set_arguments(epilogue, 0);
  Kernel::Params params(
      {256, 256, 256}, {4, 1, 1},
      {reinterpret_cast<cutlass::tfloat32_t *>(const_cast<float *>(a)), 256},
      {reinterpret_cast<cutlass::tfloat32_t *>(const_cast<float *>(b)), 256},
      {c, 256}, {c, 256}, epilogue);
  Kernel{}(params, *reinterpret_cast<Kernel::SharedStorage *>(storage));
}

// Export constants for the offline extraction script without running CUDA.
extern "C" {
__device__ __constant__ int cutlass_shared_bytes = sizeof(Kernel::SharedStorage);
__device__ __constant__ int cutlass_threads = Kernel::kThreadCount;
}
