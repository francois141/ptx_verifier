// An SM100 dense GEMM unit: `Dense<...>` composes a CollectiveBuilder kernel (1-SM tcgen05
// MMA, one-CTA cluster, static persistent tile scheduler unless given) and `run` writes one
// problem's launch over arrays named A, B, C, D (and bias), stored as their layouts say.
#pragma once

#include "sm100_gemm.h"

#include <type_traits>

namespace volta {

using namespace cute;

template <class EA, class LA, class EB, class LB, class EC, class LC, class ED, class LD, class Tile,
          class Fusion = cutlass::epilogue::fusion::LinearCombination<ED, float, EC, float>,
          class EpilogueSchedule = cutlass::epilogue::TmaWarpSpecialized1Sm,
          class MainloopSchedule = cutlass::gemm::KernelTmaWarpSpecialized1SmSm100,
          class Scheduler = cutlass::gemm::StaticPersistentScheduler, class EAcc = float, int Stages = 0>
struct Dense {
  static constexpr int AlignC = 128 / cutlass::sizeof_bits<std::conditional_t<std::is_void_v<EC>, ED, EC>>::value;
  static constexpr int AlignD = 128 / cutlass::sizeof_bits<ED>::value;
  using Cluster = Shape<_1, _1, _1>;
  using Epilogue = typename cutlass::epilogue::collective::CollectiveBuilder<
      cutlass::arch::Sm100, cutlass::arch::OpClassTensorOp, Tile, Cluster,
      cutlass::epilogue::collective::EpilogueTileAuto, EAcc, float, EC, LC, AlignC, ED, LD, AlignD,
      EpilogueSchedule, Fusion>::CollectiveOp;
  using StageCount = std::conditional_t<
      Stages == 0,
      cutlass::gemm::collective::StageCountAutoCarveout<static_cast<int>(sizeof(typename Epilogue::SharedStorage))>,
      cutlass::gemm::collective::StageCount<Stages>>;
  using Mainloop = typename cutlass::gemm::collective::CollectiveBuilder<
      cutlass::arch::Sm100, cutlass::arch::OpClassTensorOp, EA, LA, 128 / cutlass::sizeof_bits<EA>::value, EB,
      LB, 128 / cutlass::sizeof_bits<EB>::value, EAcc, Tile, Cluster, StageCount, MainloopSchedule>::CollectiveOp;
  using Kernel = cutlass::gemm::kernel::GemmUniversal<Shape<int, int, int, int>, Mainloop, Epilogue, Scheduler>;
};

struct Problem {
  std::string name, description;
  int M, N, K, L = 1;
  int sms = 1;  // persistent CTAs: CTA 0 runs every tile when 1
  std::string a_dtype, b_dtype, c_dtype, d_dtype;
  float alpha = 1, beta = 0;
  std::string bias_dtype;  // a per-row (M) or per-column (N) bias when given
  bool bias_per_row = true;
  std::string spec;  // empty: races only
  std::map<std::string, long> extra_dims;
  int max_swizzle = 1;
  bool raster_along_m = false;
};

template <class Layout>
std::vector<long> storage(int rows, int cols, int batches) {
  bool row_major = std::is_same_v<Layout, cutlass::layout::RowMajor>;
  std::vector<long> shape = row_major ? std::vector<long>{rows, cols} : std::vector<long>{cols, rows};
  if (batches > 1) shape.insert(shape.begin(), batches);
  return shape;
}

template <class T, class = void>
struct HasBias : std::false_type {};
template <class T>
struct HasBias<T, std::void_t<decltype(std::declval<T&>().bias_ptr)>> : std::true_type {};

template <class T, class = void>
struct HasSwizzle : std::false_type {};
template <class T>
struct HasSwizzle<T, std::void_t<decltype(std::declval<T&>().max_swizzle_size)>> : std::true_type {};

template <class G, class LA, class LB, class LC, class LD>
void run(char** argv, Problem const& p) {
  using Kernel = typename G::Kernel;
  using EA = typename Kernel::ElementA;
  using EB = typename Kernel::ElementB;
  using EC = typename Kernel::CollectiveEpilogue::ElementC;
  using ED = typename Kernel::CollectiveEpilogue::ElementD;
  Launch launch(p.description);
  auto* a = launch.array<EA>("A", "in", p.a_dtype, storage<LA>(p.M, p.K, p.L));
  auto* b = launch.array<EB>("B", "in", p.b_dtype, storage<LB>(p.K, p.N, p.L));
  EC const* c = nullptr;
  if (!p.c_dtype.empty()) c = launch.array<EC>("C", "in", p.c_dtype, storage<LC>(p.M, p.N, p.L));
  auto* d = launch.array<ED>("D", "out", p.d_dtype, storage<LD>(p.M, p.N, p.L));
  std::map<std::string, long> dims{{"M", p.M}, {"N", p.N}, {"K", p.K}};
  if (p.L > 1) dims["L"] = p.L;
  for (auto const& [k, v] : p.extra_dims) dims[k] = v;
  launch.spec(p.spec, dims);

  typename Kernel::Arguments args{};
  args.mode = p.L > 1 ? cutlass::gemm::GemmUniversalMode::kBatched : cutlass::gemm::GemmUniversalMode::kGemm;
  args.problem_shape = {p.M, p.N, p.K, p.L};
  args.mainloop.ptr_A = a;
  args.mainloop.dA = cutlass::make_cute_packed_stride(typename Kernel::StrideA{}, {p.M, p.K, p.L});
  args.mainloop.ptr_B = b;
  args.mainloop.dB = cutlass::make_cute_packed_stride(typename Kernel::StrideB{}, {p.N, p.K, p.L});
  args.epilogue.ptr_C = c;
  args.epilogue.dC = cutlass::make_cute_packed_stride(typename Kernel::StrideC{}, {p.M, p.N, p.L});
  args.epilogue.ptr_D = d;
  args.epilogue.dD = cutlass::make_cute_packed_stride(typename Kernel::StrideD{}, {p.M, p.N, p.L});
  auto& thread = args.epilogue.thread;
  thread.alpha = p.alpha;
  thread.beta = p.beta;
  if constexpr (HasBias<std::remove_reference_t<decltype(thread)>>::value) {
    using EBias = std::remove_cv_t<std::remove_pointer_t<decltype(thread.bias_ptr)>>;
    thread.bias_ptr = launch.array<EBias>("bias", "in", p.bias_dtype, {p.bias_per_row ? p.M : p.N});
  }
  args.hw_info = sm_count(p.sms);
  if constexpr (HasSwizzle<decltype(args.scheduler)>::value) {
    args.scheduler.max_swizzle_size = p.max_swizzle;
    using Raster = decltype(args.scheduler.raster_order);
    args.scheduler.raster_order = p.raster_along_m ? Raster::AlongM : Raster::AlongN;
  }
  write_launch<Kernel>(launch, case_path(argv, p.name), args);
}

}  // namespace volta
