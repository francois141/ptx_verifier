// CUTLASS 2.x batched f16 tensor-core GEMM for SM80 (device::GemmBatched, example 05's API),
// 128 x 128 x 32 tiles, three stages; batch 0's tile is analyzed.
#include "sm80_gemm.h"

using Gemm = cutlass::gemm::device::GemmBatched<
    cutlass::half_t, cutlass::layout::RowMajor, cutlass::half_t, cutlass::layout::ColumnMajor, cutlass::half_t,
    cutlass::layout::RowMajor, float, cutlass::arch::OpClassTensorOp, cutlass::arch::Sm80,
    cutlass::gemm::GemmShape<128, 128, 32>, cutlass::gemm::GemmShape<64, 64, 32>, cutlass::gemm::GemmShape<16, 8, 16>,
    cutlass::epilogue::thread::LinearCombination<cutlass::half_t, 8, float, float>,
    cutlass::gemm::threadblock::GemmBatchedIdentityThreadblockSwizzle, 3>;

int main(int, char** argv) {
  volta::Problem2x p{"l2m128n128k128", "CUTLASS 2.x SM80 batched f16 tensor-op GEMM, 2 batches of M = N = K = 128, batch 0's CTA",
                     128, 128, 128, 2, "f16", "f16", "f16", "specs/gemm_tn_batched_tile.spec", 0, 0,
                     {{"M0", 0}, {"M1", 128}, {"N0", 0}, {"N1", 128}}};
  volta::run2x_batched<Gemm>(argv, p);
}
