// bf16 TN GEMM with a C source: D = 1.5 A B + 0.5 C.
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 bf16 TN GEMM with a C source: D = 1.5 A B + 0.5 C; M = 256, N = 128, K = 256, CTA 0 runs every tile", 256, 128, 256, 1, 1, "bf16", "bf16", "bf16", "bf16", 1.5, 0.5, "", true, "specs/gemm_tn_alpha_beta.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
