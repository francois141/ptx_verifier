// CUTLASS 2.x f32 GEMM on SM80 tensor cores through tf32 mma.sync 16x8x8, 128 x 128 x 16
// tiles, three stages, f32 D.
#include "sm80_gemm.h"

using Gemm = cutlass::gemm::device::Gemm<
    float, cutlass::layout::RowMajor, float, cutlass::layout::ColumnMajor, float, cutlass::layout::RowMajor, float,
    cutlass::arch::OpClassTensorOp, cutlass::arch::Sm80, cutlass::gemm::GemmShape<128, 128, 16>,
    cutlass::gemm::GemmShape<64, 64, 16>, cutlass::gemm::GemmShape<16, 8, 8>,
    cutlass::epilogue::thread::LinearCombination<float, 4, float, float>,
    cutlass::gemm::threadblock::GemmIdentityThreadblockSwizzle<>, 3>;

int main(int, char** argv) {
  volta::Problem2x p{"m128n128k128", "CUTLASS 2.x SM80 tf32 tensor-op GEMM, 128x128x16 tile, 3 stages, M = N = K = 128: one tile",
                     128, 128, 128, 1, "f32", "f32", "f32", "specs/gemm_tn_tile.spec", 0, 0,
                     {{"M0", 0}, {"M1", 128}, {"N0", 0}, {"N1", 128}}};
  volta::run2x<Gemm>(argv, p);
}
