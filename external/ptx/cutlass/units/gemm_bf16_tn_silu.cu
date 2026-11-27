// bf16 TN GEMM with a fused SiLU epilogue (LinCombEltAct).
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>, cutlass::epilogue::fusion::LinCombEltAct<cutlass::epilogue::thread::SiLu, cutlass::bfloat16_t, float, void, float>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 bf16 TN GEMM with a fused SiLU epilogue (LinCombEltAct); M = 256, N = 128, K = 256, CTA 0 runs every tile", 256, 128, 256, 1, 1, "bf16", "bf16", "", "bf16", 1.0, 0.0, "", true, "specs/gemm_tn_silu.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
