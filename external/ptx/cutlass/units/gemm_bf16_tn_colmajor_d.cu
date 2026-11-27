// bf16 TN GEMM storing D column-major.
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor, void, cutlass::layout::ColumnMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 bf16 TN GEMM storing D column-major; M = 256, N = 128, K = 256, CTA 0 runs every tile", 256, 128, 256, 1, 1, "bf16", "bf16", "", "bf16", 1.0, 0.0, "", true, "specs/gemm_tn_colmajor_d.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::ColumnMajor, cutlass::layout::ColumnMajor>(argv, p);
}
