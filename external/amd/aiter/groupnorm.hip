// Aiter's GroupNorm (`aiter.groupnorm_run`; module_groupnorm), instantiated as
// launchGroupNormKernel (groupnorm.cu) launches it for fp32: an up kernel that sums each
// block's slice of a group, then a down kernel that normalizes with those partial sums;
// 1024 threads, `align4` taking 4-element vectors when inner_size % 4 == 0 and gridx >= 16.
#include "prelude.h"
#include "groupnorm.hpp"
#include "aiter_hip_common.h"
#include <hip/hip_bf16.h>
#include <hip/hip_fp16.h>
#include <type_traits>

// Aiter's kernels live in an anonymous namespace, which this file names to instantiate them.
namespace gn {
// aiter: csrc/kernels/groupnorm.cu 18-272

template __global__ void groupnorm_kernel_dispatch_up<float, 1024>(uint32_t, uint32_t, int64_t, bool,
                                                                   const float*, float*, float*);
template __global__ void groupnorm_kernel_dispatch_down<float, 1024>(
    uint32_t, uint32_t, int64_t, float, bool, const float*, const float*, const float*, const float*,
    const float*, float*);
} // namespace gn
