// Aiter's fused Q/K RMSNorm (`aiter.fused_qk_rmsnorm` without quantization; module
// fused_qk_norm_rope_cache_quant_shuffle), instantiated as the host dispatch
// (fused_qk_norm.cu, fused_qk_rmsnorm) picks it for bf16 heads of 513 to 1024 elements:
// 128 threads of 8 elements, 4 rows per workgroup when m >= 4096, else 1.
#include "prelude.h"
#include "aiter_hip_common.h"
#include "aiter_opus_plus.h"

namespace aiter {
// aiter: csrc/kernels/fused_qk_norm.cu 25-151

#define FUSED_QK(NUM_ROW)                                                                          \
    template __global__ void fused_qk_rmsnorm_kernel<opus::bf16_t, 128, 8, true, NUM_ROW>(         \
        opus::bf16_t*, opus::bf16_t*, opus::bf16_t const*, opus::bf16_t const*,                    \
        opus::bf16_t const*, opus::bf16_t const*, float, float, int, int, int, int, int, int, int);
FUSED_QK(4)
FUSED_QK(1)
} // namespace aiter
