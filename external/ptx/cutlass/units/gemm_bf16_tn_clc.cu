// bf16 TN GEMM under CUTLASS's default sm100 scheduler (cluster launch control).
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>, cutlass::epilogue::fusion::LinearCombination<cutlass::bfloat16_t, float, void, float>, cutlass::epilogue::TmaWarpSpecialized1Sm, cutlass::gemm::KernelTmaWarpSpecialized1SmSm100, void>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 bf16 TN GEMM under CUTLASS's default sm100 scheduler (cluster launch control); M = 256, N = 128, K = 256, 2 CTAs, CTA 0's tile (no cancel succeeds)", 256, 128, 256, 1, 2, "bf16", "bf16", "", "bf16", 1.0, 0.0, "", true, "specs/gemm_tn_tile.spec", {{"M0", 0}, {"M1", 128}, {"N0", 0}, {"N1", 128}}};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
