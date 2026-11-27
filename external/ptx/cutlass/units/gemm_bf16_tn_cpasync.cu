// bf16 TN GEMM whose mainloop loads A and B with cp.async instead of TMA
// (KernelWarpSpecialized1SmSm100, the builder's non-TMA path), tcgen05 MMA, TMA epilogue.
#include "sm100_dense.h"

using G = volta::Dense<cutlass::bfloat16_t, cutlass::layout::RowMajor, cutlass::bfloat16_t,
                       cutlass::layout::ColumnMajor, void, cutlass::layout::RowMajor, cutlass::bfloat16_t,
                       cutlass::layout::RowMajor, cute::Shape<cute::_128, cute::_128, cute::_64>,
                       cutlass::epilogue::fusion::LinearCombination<cutlass::bfloat16_t, float, void, float>,
                       cutlass::epilogue::TmaWarpSpecialized1Sm, cutlass::gemm::KernelWarpSpecialized1SmSm100>;

int main(int, char** argv) {
  volta::Problem p{"m256n128k256", "CUTLASS sm100 bf16 TN GEMM with a cp.async mainloop; M = 256, N = 128, K = 256, CTA 0 runs every tile",
                   256, 128, 256, 1, 1, "bf16", "bf16", "", "bf16", 1.0, 0.0, "", true, "specs/gemm_tn.spec"};
  volta::run<G, cutlass::layout::RowMajor, cutlass::layout::ColumnMajor, cutlass::layout::RowMajor,
             cutlass::layout::RowMajor>(argv, p);
}
