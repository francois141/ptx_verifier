// f16 TN GEMM over a 2 x 2 tile grid rasterized along M with swizzle 2 (the static persistent
// scheduler's L2-locality options): CTA 0 walks all four tiles in the swizzled order.
#include "sm100_dense.h"

using G = volta::Dense<cutlass::half_t, cutlass::layout::RowMajor, cutlass::half_t, cutlass::layout::ColumnMajor,
                       void, cutlass::layout::RowMajor, cutlass::half_t, cutlass::layout::RowMajor,
                       cute::Shape<cute::_128, cute::_128, cute::_64>>;

int main(int, char** argv) {
  volta::Problem p{"m256n256k128", "CUTLASS sm100 f16 TN GEMM, raster along M, swizzle 2; M = N = 256, K = 128, CTA 0 runs every tile",
                   256, 256, 128, 1, 1, "f16", "f16", "", "f16", 1.0, 0.0, "", true, "specs/gemm_tn.spec", {}, 2, true};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor,
             cutlass::layout::RowMajor>(argv, p);
}
