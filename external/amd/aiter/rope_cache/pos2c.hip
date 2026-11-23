// Probe: aiter::kn_entry_2c_sbhd_cached_indirect (rope_common.h:3385), out-of-place, as
// dispatch_2c_sbhd_cached_indirect (rope_common.h:5444) launches it for rope_cached_positions_2c_fwd_impl
// (general_2c_cached_positions_fwd_kernels.cu:72): bf16 input, bf16 cos/sin, int64 positions, all stride_d == 1,
// DoubleBuffer (min(h_x, h_y) <= 32). NEOX VP = 2 (preferred) and VP = 1 (small-problem fallback); GPT-J VP = 4.
#include "prelude.h"
#include "rope/rope_common.h"
#define INST(STYLE, VP)                                                                                          \
    template __global__ void aiter::kn_entry_2c_sbhd_cached_indirect<aiter::OpCachedFwd, STYLE, true, false, true,   \
        true, true, true, VP, true, hip_bfloat16, hip_bfloat16, int64_t>(                                           \
        hip_bfloat16*, hip_bfloat16*, const hip_bfloat16*, const hip_bfloat16*, const hip_bfloat16*,               \
        const hip_bfloat16*, const int64_t*, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, \
        int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t,  \
        int32_t, int32_t, int32_t, int32_t);
INST(0, 2)
INST(0, 1)
INST(1, 4)
