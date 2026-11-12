// A minimal model of CK Tile's PermuteWarpGemmCToA (5a74dec), whose loop runs over its 16 output
// halves instead of its 4 input words. CK's function is gfx11-only, so this copies its loop for
// gfx950: lane 0 writes each word twice, into buffers with room past both ends, as in the issue.
#include <hip/hip_runtime.h>
#include <cstdint>

extern "C" __global__ void ck_permute_c_to_a(const uint32_t* in, uint32_t* out)
{
    if(__builtin_amdgcn_workitem_id_x() != 0)
        return;
#pragma unroll
    for(int i = 0; i < 16; ++i)
    {
        const uint32_t x = in[i];
        out[2 * i]     = x;
        out[2 * i + 1] = x;
    }
}

// Upstream's fix (rocm-libraries#15011, merged 2026-11-10) bounds the loop by n_out / 4.
extern "C" __global__ void ck_permute_c_to_a_fixed(const uint32_t* in, uint32_t* out)
{
    if(__builtin_amdgcn_workitem_id_x() != 0)
        return;
#pragma unroll
    for(int i = 0; i < 4; ++i)
    {
        const uint32_t x = in[i];
        out[2 * i]     = x;
        out[2 * i + 1] = x;
    }
}
