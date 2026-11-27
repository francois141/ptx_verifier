// bf16 TN GEMM with a per-row bias and ReLU (LinCombPerRowBiasEltAct).
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>, cutlass::epilogue::fusion::LinCombPerRowBiasEltAct<cutlass::epilogue::thread::ReLu, cutlass::bfloat16_t, float, cutlass::bfloat16_t, void, float>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 bf16 TN GEMM with a per-row bias and ReLU (LinCombPerRowBiasEltAct); M = 256, N = 128, K = 256, CTA 0 runs every tile", 256, 128, 256, 1, 1, "bf16", "bf16", "", "bf16", 1.0, 0.0, "bf16", true, "specs/gemm_tn_row_bias_relu.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
