// bf16 TN GEMM with a per-column bias (LinCombPerColBias).
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>, cutlass::epilogue::fusion::LinCombPerColBias<cutlass::bfloat16_t, float, cutlass::bfloat16_t, void, float>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 bf16 TN GEMM with a per-column bias (LinCombPerColBias); M = 256, N = 128, K = 256, CTA 0 runs every tile", 256, 128, 256, 1, 1, "bf16", "bf16", "", "bf16", 1.0, 0.0, "bf16", false, "specs/gemm_tn_col_bias.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
