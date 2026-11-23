// Aiter's opus RMSNorm (`aiter.rms_norm`, `aiter.fused_add_rms_norm`; module_rmsnorm), whose
// kernel is header-only, instantiated as launch_norm (csrc/include/rmsnorm.h) picks it for bf16
// rows: 8-wide vectors (hidden % 8 == 0); no gemma; no add, or the out-of-place add
// of rmsnorm2d_fwd_with_add_opus (OOP=true).
#include "prelude.h"
#include "opus/rmsnorm_opus_kernel.hpp"

namespace aiter {
#define RMSNORM(WIDTH, OOP)                                                                        \
    template __global__ void rmsnorm_opus_kernel<rmsnorm_opus_traits<opus::bf16_t, WIDTH, false>,  \
                                                 OOP>(void*, const void*, const void*, void*,      \
                                                      void*, float, int, int, int, int);
RMSNORM(8, false)
RMSNORM(8, true)
} // namespace aiter
