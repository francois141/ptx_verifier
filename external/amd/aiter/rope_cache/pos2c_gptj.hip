// As pos2c.hip: GPT-J (RotateStyle 1) with VP = 2 and VP = 1 (the fallbacks get_grid_config takes for smaller problems).
#include "prelude.h"
#include "rope/rope_common.h"
#define INST(STYLE, VP)                                                                                          \
    template __global__ void aiter::kn_entry_2c_sbhd_cached_indirect<aiter::OpCachedFwd, STYLE, true, false, true,   \
        true, true, true, VP, true, hip_bfloat16, hip_bfloat16, int64_t>(                                           \
        hip_bfloat16*, hip_bfloat16*, const hip_bfloat16*, const hip_bfloat16*, const hip_bfloat16*,               \
        const hip_bfloat16*, const int64_t*, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, \
        int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t,  \
        int32_t, int32_t, int32_t, int32_t);
INST(1, 2)
INST(1, 1)
