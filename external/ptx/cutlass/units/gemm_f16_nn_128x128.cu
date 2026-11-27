// f16 GEMM with B row-major (N-major, transposed by the UMMA descriptor).
#include "sm100_dense.h"

using G = volta::Dense<cutlass::half_t, cutlass::layout::RowMajor, cutlass::half_t, cutlass::layout::RowMajor, void, cutlass::layout::RowMajor, cutlass::half_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 f16 GEMM with B row-major (N-major, transposed by the UMMA descriptor); M = 256, N = 128, K = 256, CTA 0 runs every tile", 256, 128, 256, 1, 1, "f16", "f16", "", "f16", 1.0, 0.0, "", true, "specs/gemm_nn.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor, cutlass::layout::RowMajor>(argv, p);
}
