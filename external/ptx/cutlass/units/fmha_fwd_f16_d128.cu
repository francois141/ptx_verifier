// SM100 fused multi-head attention forward (example 77's kernel): f16 Q, K, V with head
// dimension 128, a 256 x 128 tile (two softmax warpgroups over 128 query rows each), online
// softmax with TMEM-resident S and O, no mask, the individual (one CTA per tile) scheduler,
// f16 O and f32 LSE. Races only.
#include "volta_launch.h"

#include "cute/tensor.hpp"
#include "cutlass/cutlass.h"
#include "cutlass/kernel_hardware_info.h"

#include "collective/fmha_fusion.hpp"
#include "collective/sm100_fmha_fwd_epilogue_tma_warpspecialized.hpp"
#include "collective/sm100_fmha_fwd_mainloop_tma_warpspecialized.hpp"
#include "device/fmha.hpp"
#include "kernel/fmha_options.hpp"
#include "kernel/fmha_tile_scheduler.hpp"
#include "kernel/sm100_fmha_fwd_kernel_tma_warpspecialized.hpp"

using namespace cute;
using Element = cutlass::half_t;
using ElementOut = cutlass::half_t;
using TileShape = Shape<_256, _128, _128>;
using ProblemShape = cute::tuple<int, int, int, cute::tuple<cute::tuple<int, int>, int>>;
using StrideQ = cute::tuple<int, _1, cute::tuple<cute::tuple<int, int>, int>>;
using StrideK = cute::tuple<int, _1, cute::tuple<cute::tuple<_0, int>, int>>;
using StrideLSE = cute::tuple<_1, cute::tuple<cute::tuple<int, int>, int>>;
using Mainloop = cutlass::fmha::collective::Sm100FmhaFwdMainloopTmaWarpspecialized<
    Element, float, float, TileShape, StrideQ, StrideK, StrideK, cutlass::fmha::collective::NoMask>;
using Kernel = cutlass::fmha::kernel::Sm100FmhaFwdKernelTmaWarpspecialized<
    ProblemShape, Mainloop,
    cutlass::fmha::collective::Sm100FmhaFwdEpilogueTmaWarpspecialized<ElementOut, float,
                                                                      typename Mainloop::TileShapePV, StrideQ,
                                                                      StrideLSE>,
    cutlass::fmha::kernel::IndividualTileScheduler>;

int main(int, char** argv) {
  int sq = 256, sk = 256, d = 128, h = 1, b = 1;
  ProblemShape shape = make_tuple(sq, sk, d, make_tuple(make_tuple(1, h), b));
  StrideQ stride_q = make_stride(h * d, _1{}, make_stride(make_stride(d, h * d), h * d * sq));
  StrideK stride_k = make_stride(h * d, _1{}, make_stride(make_stride(_0{}, d), h * d * sk));
  StrideLSE stride_lse = make_stride(_1{}, make_stride(make_stride(sq, sq * h), sq * h));
  volta::Launch launch("CUTLASS sm100 FMHA forward (example 77), f16, head dim 128, 256 x 128 tile, no mask, "
                       "seq_q = seq_k = 256, one head: CTA 0 computes query rows 0..255; races only");
  auto* q = launch.array<Element>("Q", "in", "f16", {sq, d});
  auto* k = launch.array<Element>("K", "in", "f16", {sk, d});
  auto* v = launch.array<Element>("V", "in", "f16", {sk, d});
  auto* o = launch.array<ElementOut>("O", "out", "f16", {sq, d});
  auto* lse = launch.array<float>("LSE", "out", "f32", {sq});
  typename Kernel::Arguments args{shape, {{q, stride_q, k, stride_k, v, stride_k}}, {o, stride_q, lse, stride_lse},
                                  cutlass::KernelHardwareInfo{0, 148}};
  if (!Kernel::can_implement(args)) volta::fail("can_implement rejects the arguments");
  auto params = Kernel::to_underlying_arguments(args, nullptr);
  launch.write<Kernel>(volta::case_path(argv, "sq256sk256d128"), params, Kernel::get_grid_shape(params),
                       Kernel::get_block_shape(), Kernel::SharedStorageSize);
  void const* volatile entry = reinterpret_cast<void const*>(&cutlass::device_kernel<Kernel>);
  (void)entry;
}
