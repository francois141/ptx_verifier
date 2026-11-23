// Probe: aiter::kn_entry_1c_2d_cached (csrc/kernels/rope/rope_common.h:4096) as dispatch_1c_2d_cached
// (rope_common.h:6229) launches it for rope_2d_fwd_impl (general_1c_2d_fwd_kernels.cu:38) with fp32
// input and fp32 cos/sin, NEOX, NopeFirst=false, all stride_d == 1, VecPairs = 1 (small problem).
#include "prelude.h"
#include "rope/rope_common.h"
template __global__ void aiter::kn_entry_1c_2d_cached<aiter::OpCachedFwd, 0, false, false, true, true, 1, float, float>(
    float*, const float*, const float*, const float*, const float*, const float*, int32_t, int32_t, int32_t,
    int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t);
template __global__ void aiter::kn_entry_1c_2d_cached<aiter::OpCachedFwd, 0, true, false, true, true, 1, float, float>(
    float*, const float*, const float*, const float*, const float*, const float*, int32_t, int32_t, int32_t,
    int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t);
