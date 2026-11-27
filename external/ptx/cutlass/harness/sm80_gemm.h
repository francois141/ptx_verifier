// A CUTLASS 2.x `device::Gemm` (or `GemmBatched`) unit: `run` builds the kernel's `Params` as
// the adapter's `initialize` does and writes the launch its `run` makes, one CTA per tile.
#pragma once

#include "volta_launch.h"

#include "cutlass/cutlass.h"
#include "cutlass/epilogue/thread/linear_combination_relu.h"
#include "cutlass/gemm/device/gemm.h"
#include "cutlass/gemm/device/gemm_batched.h"

#include <type_traits>

namespace volta {

struct Problem2x {
  std::string name, description;
  int M, N, K, L = 1;
  std::string a_dtype, b_dtype, d_dtype;
  std::string spec;
  int cta_m = 0, cta_n = 0;  // the analyzed tile
  std::map<std::string, long> extra_dims;
};

template <class Layout>
std::vector<long> storage2x(int rows, int cols, int batches) {
  bool row_major = std::is_same_v<Layout, cutlass::layout::RowMajor>;
  std::vector<long> shape = row_major ? std::vector<long>{rows, cols} : std::vector<long>{cols, rows};
  if (batches > 1) shape.insert(shape.begin(), batches);
  return shape;
}

template <class Layout>
int leading(int rows, int cols) {
  return std::is_same_v<Layout, cutlass::layout::RowMajor> ? cols : rows;
}

template <class DeviceGemm>
Launch arrays2x(Problem2x const& p, typename DeviceGemm::ElementA*& a, typename DeviceGemm::ElementB*& b,
                typename DeviceGemm::ElementC*& d) {
  using LA = typename DeviceGemm::LayoutA;
  using LB = typename DeviceGemm::LayoutB;
  using LC = typename DeviceGemm::LayoutC;
  Launch launch(p.description);
  a = launch.array<typename DeviceGemm::ElementA>("A", "in", p.a_dtype, storage2x<LA>(p.M, p.K, p.L));
  b = launch.array<typename DeviceGemm::ElementB>("B", "in", p.b_dtype, storage2x<LB>(p.K, p.N, p.L));
  d = launch.array<typename DeviceGemm::ElementC>("D", "out", p.d_dtype, storage2x<LC>(p.M, p.N, p.L));
  std::map<std::string, long> dims{{"M", p.M}, {"N", p.N}, {"K", p.K}};
  if (p.L > 1) dims["L"] = p.L;
  for (auto const& [k, v] : p.extra_dims) dims[k] = v;
  launch.spec(p.spec, dims);
  launch.cta(p.cta_m, p.cta_n);
  return launch;
}

// `device::Gemm`: D = alpha A B (beta 0, so C is never read).
template <class DeviceGemm>
void run2x(char** argv, Problem2x const& p, float alpha = 1) {
  using GemmKernel = typename DeviceGemm::GemmKernel;
  using LA = typename DeviceGemm::LayoutA;
  using LB = typename DeviceGemm::LayoutB;
  using LC = typename DeviceGemm::LayoutC;
  typename DeviceGemm::ElementA* a;
  typename DeviceGemm::ElementB* b;
  typename DeviceGemm::ElementC* d;
  Launch launch = arrays2x<DeviceGemm>(p, a, b, d);
  typename DeviceGemm::Arguments args({p.M, p.N, p.K}, {a, leading<LA>(p.M, p.K)}, {b, leading<LB>(p.K, p.N)},
                                      {nullptr, leading<LC>(p.M, p.N)}, {d, leading<LC>(p.M, p.N)},
                                      {typename DeviceGemm::EpilogueOutputOp::ElementCompute(alpha), 0});
  if (DeviceGemm::can_implement(args) != cutlass::Status::kSuccess) fail("can_implement rejects the arguments");
  typename DeviceGemm::ThreadblockSwizzle swizzle;
  using TB = typename DeviceGemm::ThreadblockShape;
  cutlass::gemm::GemmCoord tiles = swizzle.get_tiled_shape(args.problem_size, {TB::kM, TB::kN, TB::kK}, 1);
  typename GemmKernel::Params params{args.problem_size, tiles,           args.ref_A.non_const_ref(),
                                     args.ref_B.non_const_ref(), args.ref_C.non_const_ref(), args.ref_D,
                                     args.epilogue,             nullptr};
  launch.write<GemmKernel>(case_path(argv, p.name), params, swizzle.get_grid_shape(tiles),
                           dim3(GemmKernel::kThreadCount, 1, 1), int(sizeof(typename GemmKernel::SharedStorage)));
  void const* volatile entry = reinterpret_cast<void const*>(&cutlass::Kernel<GemmKernel>);
  (void)entry;
}

// `device::GemmBatched`: L packed batches, D[l] = A[l] B[l].
template <class DeviceGemm>
void run2x_batched(char** argv, Problem2x const& p) {
  using GemmKernel = typename DeviceGemm::GemmKernel;
  using LA = typename DeviceGemm::LayoutA;
  using LB = typename DeviceGemm::LayoutB;
  using LC = typename DeviceGemm::LayoutC;
  typename DeviceGemm::ElementA* a;
  typename DeviceGemm::ElementB* b;
  typename DeviceGemm::ElementC* d;
  Launch launch = arrays2x<DeviceGemm>(p, a, b, d);
  typename DeviceGemm::Arguments args({p.M, p.N, p.K}, {a, leading<LA>(p.M, p.K)}, long(p.M) * p.K,
                                      {b, leading<LB>(p.K, p.N)}, long(p.K) * p.N, {nullptr, leading<LC>(p.M, p.N)},
                                      long(p.M) * p.N, {d, leading<LC>(p.M, p.N)}, long(p.M) * p.N, {1, 0}, p.L);
  typename DeviceGemm::ThreadblockSwizzle swizzle;
  using TB = typename DeviceGemm::ThreadblockShape;
  cutlass::gemm::GemmCoord tiles =
      swizzle.get_tiled_shape(args.problem_size, {TB::kM, TB::kN, TB::kK}, args.batch_count);
  typename GemmKernel::Params params{args.problem_size, tiles,          args.ref_A.non_const_ref(), args.stride_A,
                                     args.ref_B.non_const_ref(), args.stride_B, args.ref_C.non_const_ref(),
                                     args.stride_C,             args.ref_D,    args.stride_D,
                                     args.epilogue,             args.batch_count};
  launch.write<GemmKernel>(case_path(argv, p.name), params, swizzle.get_grid_shape(tiles),
                           dim3(GemmKernel::kThreadCount, 1, 1), int(sizeof(typename GemmKernel::SharedStorage)));
  void const* volatile entry = reinterpret_cast<void const*>(&cutlass::Kernel<GemmKernel>);
  (void)entry;
}

}  // namespace volta
