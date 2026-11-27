// The SM100 GEMM units' shared shape: a CollectiveBuilder kernel over 1-SM tcgen05 MMA in a
// cluster of one CTA, its launch written as `GemmUniversalAdapter` would make it.
#pragma once

#include "volta_launch.h"

#include "cute/tensor.hpp"
#include "cutlass/cutlass.h"
#include "cutlass/epilogue/collective/collective_builder.hpp"
#include "cutlass/epilogue/thread/activation.h"
#include "cutlass/gemm/collective/collective_builder.hpp"
#include "cutlass/gemm/device/gemm_universal_adapter.h"
#include "cutlass/gemm/kernel/gemm_universal.hpp"
#include "cutlass/util/packed_stride.hpp"

namespace volta {

// The kernel's `Params` for `args`, and its launch as the adapter's `run` makes it.
template <class GemmKernel>
void write_launch(Launch const& launch, std::string const& path, typename GemmKernel::Arguments const& args,
                  void* workspace = nullptr) {
  if (GemmKernel::can_implement(args) == false) fail("can_implement rejects the arguments");
  auto params = GemmKernel::to_underlying_arguments(args, workspace);
  // Kernels that query the device's SM count get 0 without a GPU: stand in the requested one.
  if (params.hw_info.sm_count == 0) params.hw_info.sm_count = args.hw_info.sm_count;
  dim3 grid = GemmKernel::get_grid_shape(params);
  dim3 block = GemmKernel::get_block_shape();
  auto cluster = typename GemmKernel::DispatchPolicy::ClusterShape{};
  dim3 cluster_dims(cute::size<0>(cluster), cute::size<1>(cluster), cute::size<2>(cluster));
  launch.write<GemmKernel>(path, params, grid, block, GemmKernel::SharedStorageSize, cluster_dims);
  // The PTX keeps the entry only if something refers to it.
  void const* volatile entry = reinterpret_cast<void const*>(&cutlass::device_kernel<GemmKernel>);
  (void)entry;
}

// A persistent grid of `sms` CTAs (148 on a B200): fewer SMs give the analyzed CTA more tiles.
inline cutlass::KernelHardwareInfo sm_count(int sms) {
  cutlass::KernelHardwareInfo hw;
  hw.device_id = 0;
  hw.sm_count = sms;
  return hw;
}

}  // namespace volta
