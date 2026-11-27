// SM100 block-scaled MXFP8 GEMM (example 72's kernel family, both operands e4m3 with a UE8M0
// scale per 32 elements, kind::mxf8f6f4.block_scale with scales copied to TMEM by tcgen05.cp),
// 128 x 128 x 128 1-SM tile, bf16 D. Races only: the scales are symbolic bytes.
#include "sm100_gemm.h"

using namespace cute;
using ElementA = cutlass::mx_float8_t<cutlass::float_e4m3_t>;
using ElementB = cutlass::mx_float8_t<cutlass::float_e4m3_t>;
using ElementD = cutlass::bfloat16_t;
using BTile = Shape<_128, _128, _128>;
using Cluster = Shape<_1, _1, _1>;

using Epilogue = typename cutlass::epilogue::collective::CollectiveBuilder<
    cutlass::arch::Sm100, cutlass::arch::OpClassBlockScaledTensorOp, BTile, Cluster,
    cutlass::epilogue::collective::EpilogueTileAuto, float, float, void, cutlass::layout::RowMajor, 8, ElementD,
    cutlass::layout::RowMajor, 8, cutlass::epilogue::TmaWarpSpecialized1Sm>::CollectiveOp;
using Mainloop = typename cutlass::gemm::collective::CollectiveBuilder<
    cutlass::arch::Sm100, cutlass::arch::OpClassBlockScaledTensorOp, ElementA, cutlass::layout::RowMajor, 16,
    ElementB, cutlass::layout::ColumnMajor, 16, float, BTile, Cluster,
    cutlass::gemm::collective::StageCountAutoCarveout<static_cast<int>(sizeof(typename Epilogue::SharedStorage))>,
    cutlass::gemm::KernelTmaWarpSpecialized1SmMxf8f6f4Sm100>::CollectiveOp;
using Kernel = cutlass::gemm::kernel::GemmUniversal<Shape<int, int, int, int>, Mainloop, Epilogue,
                                                    cutlass::gemm::StaticPersistentScheduler>;

int main(int, char** argv) {
  int M = 256, N = 128, K = 256;
  using Config = typename Mainloop::Sm1xxBlkScaledConfig;
  auto layout_sfa = Config::tile_atom_to_shape_SFA(make_shape(M, N, K, 1));
  auto layout_sfb = Config::tile_atom_to_shape_SFB(make_shape(M, N, K, 1));
  volta::Launch launch("CUTLASS sm100 block-scaled MXFP8 GEMM (e4m3 x e4m3, UE8M0 scales per 32), 128x128x128 "
                       "1-SM tile, M = 256, N = 128, K = 256 on one SM: CTA 0 runs both tiles; races only");
  auto* a = launch.array<typename Mainloop::ElementA>("A", "in", "e4m3", {M, K});
  auto* b = launch.array<typename Mainloop::ElementB>("B", "in", "e4m3", {N, K});
  auto* sfa = launch.array<typename Mainloop::ElementSF>("SFA", "in", "u8", {long(size(filter_zeros(layout_sfa)))});
  auto* sfb = launch.array<typename Mainloop::ElementSF>("SFB", "in", "u8", {long(size(filter_zeros(layout_sfb)))});
  auto* d = launch.array<ElementD>("D", "out", "bf16", {M, N});
  typename Kernel::Arguments args{
      cutlass::gemm::GemmUniversalMode::kGemm,
      {M, N, K, 1},
      {a, cutlass::make_cute_packed_stride(typename Kernel::StrideA{}, {M, K, 1}), b,
       cutlass::make_cute_packed_stride(typename Kernel::StrideB{}, {N, K, 1}), sfa, layout_sfa, sfb, layout_sfb},
      {{1.0f, 0.0f}, nullptr, cutlass::make_cute_packed_stride(typename Kernel::StrideD{}, {M, N, 1}), d,
       cutlass::make_cute_packed_stride(typename Kernel::StrideD{}, {M, N, 1})}};
  args.hw_info = volta::sm_count(1);
  volta::write_launch<Kernel>(launch, volta::case_path(argv, "m256n128k256"), args);
}
