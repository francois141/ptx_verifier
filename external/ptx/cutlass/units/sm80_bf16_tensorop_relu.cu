// CUTLASS 2.x bf16 tensor-core GEMM for SM80 with a fused ReLU epilogue (LinearCombinationRelu),
// 128 x 128 x 64 tiles, four stages.
#include "sm80_gemm.h"

using Gemm = cutlass::gemm::device::Gemm<
    cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor,
    cutlass::bfloat16_t, cutlass::layout::RowMajor, float, cutlass::arch::OpClassTensorOp, cutlass::arch::Sm80,
    cutlass::gemm::GemmShape<128, 128, 64>, cutlass::gemm::GemmShape<64, 64, 64>, cutlass::gemm::GemmShape<16, 8, 16>,
    cutlass::epilogue::thread::LinearCombinationRelu<cutlass::bfloat16_t, 8, float, float>,
    cutlass::gemm::threadblock::GemmIdentityThreadblockSwizzle<>, 4>;

int main(int, char** argv) {
  volta::Problem2x p{"m128n128k512", "CUTLASS 2.x SM80 bf16 tensor-op GEMM + ReLU, 128x128x64 tile, 4 stages, M = N = 128, K = 512: one tile",
                     128, 128, 512, 1, "bf16", "bf16", "bf16", "specs/gemm_tn_relu_tile.spec", 0, 0,
                     {{"M0", 0}, {"M1", 128}, {"N0", 0}, {"N1", 128}}};
  volta::run2x<Gemm>(argv, p);
}
