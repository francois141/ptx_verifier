// CUTLASS 2.x SGEMM (the default f32 SIMT device::Gemm of example 00, with row-major A and D and
// column-major B): 128 x 128 x 8 threadblock tile, two-stage pipelined mainloop.
#include "sm80_gemm.h"

using Gemm = cutlass::gemm::device::Gemm<float, cutlass::layout::RowMajor, float, cutlass::layout::ColumnMajor,
                                         float, cutlass::layout::RowMajor>;

int main(int, char** argv) {
  volta::Problem2x p{"m128n128k64", "CUTLASS 2.x SGEMM (example 00's default SIMT config), f32, M = N = 128, K = 64: one tile",
                     128, 128, 64, 1, "f32", "f32", "f32", "specs/gemm_tn_tile.spec", 0, 0,
                     {{"M0", 0}, {"M1", 128}, {"N0", 0}, {"N1", 128}}};
  volta::run2x<Gemm>(argv, p);
}
