// Aiter's HIP RMSNorm (`aiter.rms_norm`, `aiter.rmsnorm2d_fwd(_with_add)`, which
// rmsnorm.py's _use_hip_common routes here for 2-D bf16/fp16 rows of at most 8192 on gfx950;
// module_rmsnorm_quant), instantiated as RMSNORM_KERNEL_DISPATCH / ADD_RMSNORM_KERNEL_DISPATCH
// pick it without quantization: (block, elements per thread) = (128, 8) up to n = 1024,
// (256, 16) up to 4096; interleaved loads; one row per workgroup.
#define AITER_NO_TORCH_TYPES
#include "prelude.h"
#include "aiter_hip_common.h"
#include "aiter_opus_plus.h"
#include "aiter_dispatch.h"
#include "mx_quant_utils.h"
#include "quant_amax_floor.h"
#include "rocprim/rocprim.hpp"

namespace aiter {
// aiter: csrc/kernels/rmsnorm_quant_kernels.cu 23-343

#define RMSNORM_HIP(BS, TDS, ADD)                                                                  \
    template __global__ void add_rmsnorm_quant_kernel<opus::bf16_t, opus::bf16_t, BS, TDS, ADD,    \
                                                      false, true, 1, false>(                     \
        opus::bf16_t*, opus::bf16_t*, float*, opus::bf16_t*, opus::bf16_t*, opus::bf16_t*, double, \
        bool, int, int, int, int, int, int, int, bool, bool);
RMSNORM_HIP(128, 8, false)
RMSNORM_HIP(256, 16, false)
RMSNORM_HIP(256, 16, true)
} // namespace aiter
