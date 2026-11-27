// CUTLASS 2.x f16 tensor-core GEMM for SM80 (mma.sync 16x8x16, cp.async multistage, three
// stages of 128 x 128 x 32), f32 accumulation, f16 D: the library's most common 2.x kernel.
#include "sm80_gemm.h"

using Gemm = cutlass::gemm::device::Gemm<
    cutlass::half_t, cutlass::layout::RowMajor, cutlass::half_t, cutlass::layout::ColumnMajor, cutlass::half_t,
    cutlass::layout::RowMajor, float, cutlass::arch::OpClassTensorOp, cutlass::arch::Sm80,
    cutlass::gemm::GemmShape<128, 128, 32>, cutlass::gemm::GemmShape<64, 64, 32>, cutlass::gemm::GemmShape<16, 8, 16>,
    cutlass::epilogue::thread::LinearCombination<cutlass::half_t, 8, float, float>,
    cutlass::gemm::threadblock::GemmIdentityThreadblockSwizzle<>, 3>;

int main(int, char** argv) {
  volta::Problem2x p{"m256n128k256", "CUTLASS 2.x SM80 f16 tensor-op GEMM, 128x128x32 tile, 3 stages, M = 256, N = 128, K = 256, CTA (1, 0)'s tile",
                     256, 128, 256, 1, "f16", "f16", "f16", "specs/gemm_tn_tile.spec", 1, 0,
                     {{"M0", 128}, {"M1", 256}, {"N0", 0}, {"N1", 128}}};
  volta::run2x<Gemm>(argv, p);
}
