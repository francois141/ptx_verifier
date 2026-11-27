// SM100 implicit-GEMM 2-D fprop convolution (example 76's kernel in two dimensions): f16 NHWC
// activations through im2col TMA, KRSC filters, 128 x 128 x 64 tile, f16 output, CUTLASS's default
// (cluster launch control) tile scheduler.
#include "sm100_gemm.h"

#include "cutlass/conv/collective/collective_builder.hpp"
#include "cutlass/conv/convnd_problem_shape.hpp"
#include "cutlass/conv/kernel/conv_universal.hpp"

using namespace cute;
using Element = cutlass::half_t;
using ConvLayout = cutlass::layout::TensorNHWC;
using ConvTile = Shape<_128, _128, Shape<_64>>;
using Cluster = Shape<_1, _1, _1>;
constexpr auto Op = cutlass::conv::Operator::kFprop;

using Epilogue = typename cutlass::epilogue::collective::CollectiveBuilder<
    cutlass::arch::Sm100, cutlass::arch::OpClassTensorOp, ConvTile, Cluster,
    cutlass::epilogue::collective::EpilogueTileAuto, float, float, void, ConvLayout, 8, Element, ConvLayout, 8,
    cutlass::epilogue::collective::EpilogueScheduleAuto>::CollectiveOp;
using Mainloop = typename cutlass::conv::collective::CollectiveBuilder<
    cutlass::arch::Sm100, cutlass::arch::OpClassTensorOp, Op, Element, ConvLayout, 8, Element, ConvLayout, 8, float, ConvTile,
    Cluster,
    cutlass::conv::collective::StageCountAutoCarveout<static_cast<int>(sizeof(typename Epilogue::SharedStorage))>,
    cutlass::conv::collective::KernelScheduleAuto>::CollectiveOp;
using ProblemShape = cutlass::conv::ConvProblemShape<Op, Mainloop::DispatchPolicy::NumSpatialDimensions>;
using Kernel = cutlass::conv::kernel::ConvUniversal<ProblemShape, Mainloop, Epilogue>;

int main(int, char** argv) {
  int n = 1, h = 8, w = 16, c = 64, k = 128, r = 3, s = 3;
  ProblemShape shape(cutlass::conv::Mode::kCrossCorrelation, {n, h, w, c}, {k, r, s, c}, {1, 1}, {1, 1}, {1, 1},
                     {1, 1}, 1);
  volta::Launch launch(
      "CUTLASS sm100 2-D fprop convolution, f16 NHWC 1 x 8 x 16 x 64, 128 KRSC 3 x 3 filters, pad 1, stride 1 "
      "(implicit GEMM M = N = 128, K = 576): one 128x128x64 tile, CLC scheduler");
  auto* act = launch.array<Element>("act", "in", "f16", {n, h, w, c});
  auto* flt = launch.array<Element>("flt", "in", "f16", {k, r, s, c});
  auto* out = launch.array<Element>("out", "out", "f16", {n, h, w, k});
  launch.spec("specs/conv2d_fprop_3x3_pad1.spec",
              {{"N", n}, {"H", h}, {"W", w}, {"C", c}, {"K", k}, {"R", r}, {"S", s}, {"P", h}, {"Q", w}});
  typename Kernel::StrideD stride_d;
  cute::for_each(cute::make_seq<cute::rank<0>(typename Kernel::StrideD{})>{},
                 [&](auto i) { cute::get<0, i>(stride_d) = shape.stride_C[ProblemShape::RankT - 2 - i]; });
  typename Kernel::Arguments args{shape, {act, flt}, {{1.0f, 0.0f}, nullptr, stride_d, out, stride_d}};
  args.hw_info = volta::sm_count(1);
  volta::write_launch<Kernel>(launch, volta::case_path(argv, "n1h8w16c64k128"), args);
}
