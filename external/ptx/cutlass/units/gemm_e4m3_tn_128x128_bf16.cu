// FP8 e4m3 TN GEMM (kind::f8f6f4), bf16 D.
#include "sm100_dense.h"

using G = volta::Dense<cutlass::float_e4m3_t, cutlass::layout::RowMajor, cutlass::float_e4m3_t, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, cutlass::bfloat16_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_128>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 FP8 e4m3 TN GEMM (kind::f8f6f4), bf16 D; M = 256, N = 128, K = 256, CTA 0 runs every tile", 256, 128, 256, 1, 1, "e4m3", "e4m3", "", "bf16", 1.0, 0.0, "", true, "specs/gemm_tn.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
