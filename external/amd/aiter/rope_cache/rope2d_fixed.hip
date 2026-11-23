// kn_entry_1c_2d_cached (rope_common.h:4096) with the fix: each half's freq count, and the cos/sin row
// stride, is size_half_d / 2 under ReuseFreqsFrontPart (tables d/4 wide, aiter/ops/rope.py:328), not size_half_d.
#include "prelude.h"
#include "rope/rope_common.h"
namespace probe {
using namespace aiter;
template <typename Op, int32_t RotateStyle, bool ReuseFreqsFrontPart, bool NopeFirst, bool StrideDOutEq1,
          bool StrideDInEq1, int32_t VecPairs = 1, typename scalar_t, typename scalar_f_t>
__launch_bounds__(256, 8) __global__
    void kn_entry_1c_2d_cached_fixed(scalar_t* __restrict__ p_output, const scalar_t* __restrict__ p_input,
                                     const scalar_f_t* __restrict__ p_cos_h, const scalar_f_t* __restrict__ p_sin_h,
                                     const scalar_f_t* __restrict__ p_cos_w, const scalar_f_t* __restrict__ p_sin_w,
                                     const int32_t img_width, const int32_t size_h, const int32_t size_d,
                                     const int32_t stride_i_b, const int32_t stride_i_s, const int32_t stride_i_h,
                                     const int32_t stride_i_d, const int32_t stride_o_b, const int32_t stride_o_s,
                                     const int32_t stride_o_h, const int32_t stride_o_d, const int32_t size_s_h,
                                     const int32_t threads_per_sb, const int32_t total_sb)
{
    const int32_t global_tid  = blockIdx.x * 256 + threadIdx.x;
    const int32_t sb_idx      = global_tid / threads_per_sb;
    const int32_t d_chunk_idx = global_tid % threads_per_sb;
    if(sb_idx >= total_sb)
        return;
    const int32_t bid    = sb_idx / (size_s_h * img_width);
    const int32_t hw_idx = sb_idx % (size_s_h * img_width);
    const int32_t Hid    = hw_idx / img_width;
    const int32_t Wid    = hw_idx % img_width;
    const uint64_t sid   = Hid * img_width + Wid;

    const uint64_t size_half_d = size_d >> 1;
    const int32_t size_f       = ReuseFreqsFrontPart ? (size_half_d >> 1) : size_half_d; // FIX

    const int offset_h_i = bid * stride_i_b + sid * stride_i_s;
    const int offset_h_o = bid * stride_o_b + sid * stride_o_s;
    const int offset_h_f = Hid * size_f; // FIX
    Op::template apply_1c<RotateStyle, ReuseFreqsFrontPart, NopeFirst, false, StrideDOutEq1, StrideDInEq1, VecPairs>(
        p_output, p_input, (int32_t)offset_h_o, (int32_t)offset_h_i, p_cos_h + offset_h_f, p_sin_h + offset_h_f, 0,
        size_h, size_half_d, size_f, stride_i_h, stride_i_d, stride_o_h, stride_o_d, d_chunk_idx, threads_per_sb);

    const int offset_w_i = offset_h_i + size_half_d * stride_i_d;
    const int offset_w_o = offset_h_o + size_half_d * stride_o_d;
    const int offset_w_f = Wid * size_f; // FIX
    Op::template apply_1c<RotateStyle, ReuseFreqsFrontPart, NopeFirst, false, StrideDOutEq1, StrideDInEq1, VecPairs>(
        p_output, p_input, (int32_t)offset_w_o, (int32_t)offset_w_i, p_cos_w + offset_w_f, p_sin_w + offset_w_f, 0,
        size_h, size_half_d, size_f, stride_i_h, stride_i_d, stride_o_h, stride_o_d, d_chunk_idx, threads_per_sb);
}
template __global__ void kn_entry_1c_2d_cached_fixed<OpCachedFwd, 0, true, false, true, true, 1, float, float>(
    float*, const float*, const float*, const float*, const float*, const float*, int32_t, int32_t, int32_t,
    int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t, int32_t);
}
