// batched bf16 TN GEMM, two batches.
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>>;

int main(int, char** argv) {
  volta::Problem p{"m128n128k256", "CUTLASS sm100 batched bf16 TN GEMM, two batches; M = 128, N = 128, K = 256, 2 batches, CTA 0 runs every tile", 128, 128, 256, 2, 1, "bf16", "bf16", "", "bf16", 1.0, 0.0, "", true, "specs/gemm_tn_batched.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
