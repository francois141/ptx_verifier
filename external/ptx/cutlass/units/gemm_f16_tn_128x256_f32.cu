// f16 TN GEMM with a 128 x 256 tile and an f32 D.
#include "sm100_dense.h"

using G = volta::Dense<cutlass::half_t, cutlass::layout::RowMajor, cutlass::half_t, cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, float, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_256, cute::_64>>;

int main(int, char** argv) {
  volta::Problem p{"m256n256k128", "CUTLASS sm100 f16 TN GEMM with a 128 x 256 tile and an f32 D; M = 256, N = 256, K = 128, CTA 0 runs every tile", 256, 256, 128, 1, 1, "f16", "f16", "", "f32", 1.0, 0.0, "", true, "specs/gemm_tn.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
