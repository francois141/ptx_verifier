// SM100 blockwise-scaled FP8 GEMM (example 81, DeepSeek-style): e4m3 operands with f32 scales
// per 128 x 128 block of A and of B, applied to each k-block's partial accumulator in the
// epilogue warps (KernelScheduleSm100Blockwise), 128 x 128 x 128 tile, bf16 D. Races only.
#include "sm100_gemm.h"

#include "cutlass/detail/blockwise_scale_layout.hpp"

using namespace cute;
using ElementA = cutlass::float_e4m3_t;
using ElementB = cutlass::float_e4m3_t;
using ElementD = cutlass::bfloat16_t;
using BTile = Shape<_128, _128, _128>;
using Cluster = Shape<_1, _1, _1>;
using ScaleConfig = decltype(cutlass::detail::sm100_trivial_blockwise_scale_config(BTile{}));
using LayoutSFA = decltype(ScaleConfig::deduce_layoutSFA());
using LayoutSFB = decltype(ScaleConfig::deduce_layoutSFB());

using Epilogue = typename cutlass::epilogue::collective::CollectiveBuilder<
    cutlass::arch::Sm100, cutlass::arch::OpClassTensorOp, BTile, Cluster,
    cutlass::epilogue::collective::EpilogueTileAuto, float, float, void, cutlass::layout::RowMajor, 8, ElementD,
    cutlass::layout::RowMajor, 8, cutlass::epilogue::collective::EpilogueScheduleAuto>::CollectiveOp;
using Mainloop = typename cutlass::gemm::collective::CollectiveBuilder<
    cutlass::arch::Sm100, cutlass::arch::OpClassTensorOp, ElementA, cute::tuple<cutlass::layout::RowMajor, LayoutSFA>,
    16, ElementB, cute::tuple<cutlass::layout::ColumnMajor, LayoutSFB>, 16, float, BTile, Cluster,
    cutlass::gemm::collective::StageCountAutoCarveout<static_cast<int>(sizeof(typename Epilogue::SharedStorage))>,
    cutlass::gemm::KernelScheduleSm100Blockwise>::CollectiveOp;
using Kernel = cutlass::gemm::kernel::GemmUniversal<Shape<int, int, int, int>, Mainloop, Epilogue,
                                                    cutlass::gemm::StaticPersistentScheduler>;

int main(int, char** argv) {
  int M = 256, N = 128, K = 256;
  auto layout_sfa = ScaleConfig::tile_atom_to_shape_SFA(make_shape(M, N, K, 1));
  auto layout_sfb = ScaleConfig::tile_atom_to_shape_SFB(make_shape(M, N, K, 1));
  volta::Launch launch("CUTLASS sm100 blockwise-scaled FP8 GEMM (e4m3, f32 scale per 128x128 block), 128x128x128 "
                       "1-SM tile, M = 256, N = 128, K = 256 on one SM: CTA 0 runs both tiles; races only");
  auto* a = launch.array<ElementA>("A", "in", "e4m3", {M, K});
  auto* b = launch.array<ElementB>("B", "in", "e4m3", {N, K});
  auto* sfa = launch.array<float>("SFA", "in", "f32", {long(size(filter_zeros(layout_sfa)))});
  auto* sfb = launch.array<float>("SFB", "in", "f32", {long(size(filter_zeros(layout_sfb)))});
  auto* d = launch.array<ElementD>("D", "out", "bf16", {M, N});
  typename Kernel::Arguments args{
      cutlass::gemm::GemmUniversalMode::kGemm,
      {M, N, K, 1},
      {a, cutlass::make_cute_packed_stride(typename Kernel::StrideA{}, {M, K, 1}), b,
       cutlass::make_cute_packed_stride(typename Kernel::StrideB{}, {N, K, 1}), sfa, layout_sfa, sfb, layout_sfb},
      {{}, nullptr, cutlass::make_cute_packed_stride(typename Kernel::StrideD{}, {M, N, 1}), d,
       cutlass::make_cute_packed_stride(typename Kernel::StrideD{}, {M, N, 1})}};
  args.epilogue.thread.alpha = 1.0f;
  args.epilogue.thread.beta = 0.0f;
  args.hw_info = volta::sm_count(1);
  volta::write_launch<Kernel>(launch, volta::case_path(argv, "m256n128k256"), args);
}
