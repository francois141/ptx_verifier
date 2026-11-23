// Aiter's activation kernels (module_activation), instantiated as the host dispatch
// (activation_kernels.cu) picks them for bf16 rows: the gated `aiter.silu_and_mul`
// (LAUNCH_ACTIVATION_GATE_KERNEL: no limit, non-temporal loads, VEC_SIZE = clamp(nextPow2(d /
// 64), 2, 8)), its bias variant `aiter.silu_and_mul_bias`, and `aiter.gelu_fast`.
#include "prelude.h"
#include "aiter_hip_common.h"
#include "aiter_opus_plus.h"
#include <hip/hip_bf16.h>

namespace aiter {
// aiter: csrc/kernels/activation_kernels.cu 31-121
// aiter: csrc/kernels/activation_kernels.cu 181-298
// aiter: csrc/kernels/activation_kernels.cu 1105-1113
// aiter: csrc/kernels/activation_kernels.cu 2070-2130
// aiter: csrc/kernels/activation_kernels.cu 2238-2246

#define SILU_AND_MUL(VEC)                                                                    \
    template __global__ void                                                                 \
    act_and_mul_kernel<opus::bf16_t, opus::bf16_t, silu_kernel<opus::bf16_t>, VEC, false,    \
                       GROUP_NT>(opus::bf16_t*, const opus::bf16_t*, const int, const float);
SILU_AND_MUL(2)
SILU_AND_MUL(4)
SILU_AND_MUL(8)

// silu_and_mul_bias (MoE experts' gate/up bias, fp32), int32 expert ids.
template __global__ void act_and_mul_bias_kernel<opus::bf16_t, opus::bf16_t, int32_t, opus::fp32_t,
                                                 silu_kernel<opus::fp32_t>, 2>(
    opus::bf16_t*, const opus::bf16_t*, const int32_t*, const opus::fp32_t*, const int,
    const int64_t);

// gelu_fast (LAUNCH_ACTIVATION_KERNEL_VEC): VEC_SIZE = clamp(nextPow2(numel / 64), 1, 8).
template __global__ void activation_kernel_vec<opus::bf16_t, gelu_fast_kernel<opus::bf16_t>, 2>(
    opus::bf16_t*, const opus::bf16_t*, const int64_t);
template __global__ void activation_kernel_vec<opus::bf16_t, gelu_fast_kernel<opus::bf16_t>, 8>(
    opus::bf16_t*, const opus::bf16_t*, const int64_t);
} // namespace aiter
