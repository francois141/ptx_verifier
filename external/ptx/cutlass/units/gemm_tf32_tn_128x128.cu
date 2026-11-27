// f32 (tf32 MMA) TN GEMM, f32 D.
#include "sm100_dense.h"

using G = volta::Dense<float, cutlass::layout::RowMajor, float, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, float, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_32>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k128", "CUTLASS sm100 f32 (tf32 MMA) TN GEMM, f32 D; M = 256, N = 128, K = 128, CTA 0 runs every tile", 256, 128, 128, 1, 1, "f32", "f32", "", "f32", 1.0, 0.0, "", true, "specs/gemm_tn.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
