// Instantiation of NVIDIA CUTLASS's SM80 binary XOR-popcount GEMM.
// CUTLASS v3.9.2: ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e.
// See CUTLASS_LICENSE.txt for the library's license.
#include <cutlass/gemm/device/gemm.h>

using Gemm = cutlass::gemm::device::Gemm<
    cutlass::uint1b_t, cutlass::layout::RowMajor,
    cutlass::uint1b_t, cutlass::layout::ColumnMajor,
    int32_t, cutlass::layout::RowMajor,
    int32_t, cutlass::arch::OpClassTensorOp, cutlass::arch::Sm80,
    cutlass::gemm::GemmShape<64, 256, 512>,
    cutlass::gemm::GemmShape<64, 64, 512>,
    cutlass::gemm::GemmShape<16, 8, 256>,
    cutlass::epilogue::thread::LinearCombination<int32_t, 4, int32_t, int32_t>,
    cutlass::gemm::threadblock::GemmIdentityThreadblockSwizzle<>,
    3, 128, 128, false, cutlass::arch::OpXorPopc>;
using Kernel = Gemm::GemmKernel;

// Construct the ordinary CUTLASS Params at compile-time-known dimensions.
// This replaces its host launch plumbing, not its mainloop or epilogue.
extern "C" __global__ __launch_bounds__(Kernel::kThreadCount)
void cutlass_binary_gemm(uint32_t const *a, uint32_t const *b, int32_t *c) {
  extern __shared__ __align__(16) unsigned char storage[];
  Kernel::Params params(
      {256, 256, 256}, {4, 1, 1},
      {reinterpret_cast<cutlass::uint1b_t *>(const_cast<uint32_t *>(a)), 256},
      {reinterpret_cast<cutlass::uint1b_t *>(const_cast<uint32_t *>(b)), 256},
      {c, 256}, {c, 256}, {1, 0});
  Kernel{}(params, *reinterpret_cast<Kernel::SharedStorage *>(storage));
}

// Export constants for the offline extraction script without running CUDA.
extern "C" {
__device__ __constant__ int cutlass_shared_bytes = sizeof(Kernel::SharedStorage);
__device__ __constant__ int cutlass_threads = Kernel::kThreadCount;
}
