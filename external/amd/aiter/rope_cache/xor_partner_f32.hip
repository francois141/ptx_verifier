// Probe: fusedQKNormRopeQuantCacheShuffleKernel (csrc/kernels/fused_qk_norm_rope_cache_quant.cu:157-456),
// copied verbatim except one harness change: the Q/K write-back goes to the extra q_out/k_out
// parameters instead of q_act/k_act (Volta's AMD model has no in-place arrays). The rotation is untouched.
#include "prelude.h"
#define AITER_NO_TORCH_TYPES
#include <cmath>
#include <cstdlib>
#include <limits>
#include <type_traits>
#include "aiter_hip_common.h"
#include "opus/opus.hpp"
#include "aiter_opus_plus.h"
#include "dtype_fp8.cuh"
#include "quant_amax_floor.h"
#include "rope/rope_common.h"
extern "C" __device__ float __ocml_rsqrt_f32(float x) { return __builtin_amdgcn_rsqf(x); }
using mrope_utils::vec_t;
namespace probe {
template <typename Func, typename T>
__inline__ __device__ T warpReduceSum(Func func, T val)
{
#pragma unroll
    for(int mask = 16; mask > 0; mask >>= 1)
        val = func(val, __shfl_xor(val, mask, 32));
    return val;
}

template <typename T>
inline __device__ __host__ T divUp(T m, T n)
{
    return (m + n - 1) / n;
}

__device__ float abs(float x)
{
    union
    {
        float f32;
        uint32_t u32;
    } y;
    y.f32 = x;
    y.u32 = y.u32 & 0x7fffffff;
    return y.f32;
};
template <typename scalar_t,
          typename kv_cache_scalar_t,
          int head_dim,
          bool interleave,
          int num_kv_heads,
          vllm::Fp8KVCacheDataType kv_dt>
__global__ void fusedQKNormRopeQuantCacheShuffleKernel(
    scalar_t* q_act, // [num_tokens, num_heads_q * head_dim]
    scalar_t* k_act, // [num_tokens, num_heads_k * head_dim]
    scalar_t* v_act, // [num_tokens, num_heads_v * head_dim]
    int64_t const q_st,
    int64_t const q_sh,
    int64_t const q_sd,
    int64_t const k_st,
    int64_t const k_sh,
    int64_t const k_sd,
    int64_t const v_st,
    int64_t const v_sh,
    int64_t const v_sd,
    int const num_heads_q,         // Number of query heads
    int const num_heads_k,         // Number of key heads
    int const num_heads_v,         // Number of value heads
    float const eps,               // Epsilon for RMS normalization
    scalar_t const* q_weight,      // RMSNorm weights for query
    scalar_t const* k_weight,      // RMSNorm weights for key
    scalar_t const* cos_sin_cache, // Pre-computed cos/sin cache
    int64_t const* position_ids,   // Position IDs for RoPE
    kv_cache_scalar_t*
        k_cache, // Key cache [num_blocks, num_kv_heads, head_size // x, block_size, x]
    kv_cache_scalar_t*
        v_cache,           // Value cache [num_blocks, num_kv_heads, block_size/X, head_size, X]
    int64_t* slot_mapping, // Slot mapping
    float* k_scale,        // Key scale for quantized key cache [num_blocks, block_size]
    float* v_scale,        // Value scale for quantized value cache [num_blocks, block_size]
    int const num_tokens,  // Number of tokens
    int const page_size,   // Page size for kv cache
    int x,                 // kv cache tiling size
    int const rotary_dim,  // Rotary dimension (concatenated cos+sin width); <= head_dim
    scalar_t* q_out,       // harness: write-back target replacing q_act
    scalar_t* k_out)       // harness: write-back target replacing k_act
{

    int const warpsPerBlock = blockDim.x / 32;
    int const warpId        = threadIdx.x / 32;
    int const laneId        = threadIdx.x % 32;

    int const globalWarpIdx = blockIdx.x * warpsPerBlock + warpId;

    int const num_heads    = num_heads_q + num_heads_k + num_heads_v;
    int const tokenIdx     = globalWarpIdx / num_heads;
    int const localHeadIdx = globalWarpIdx % num_heads;
    if(tokenIdx >= num_tokens)
        return;
    bool const isQ                  = localHeadIdx < num_heads_q;
    bool const isK                  = (localHeadIdx < num_heads_q + num_heads_k) & !isQ;
    bool const isV                  = !isQ & !isK;
    int const headIdx               = isV   ? localHeadIdx - num_heads_q - num_heads_k
                                      : isK ? localHeadIdx - num_heads_q
                                            : localHeadIdx;
    constexpr int numElemsPerThread = head_dim / 32;
    scalar_t elements[numElemsPerThread];
    constexpr int best_vec_size = sizeof(float4) / sizeof(scalar_t);
    constexpr int vec_size      = std::min(best_vec_size, numElemsPerThread);
    constexpr int load_loop_cnt = numElemsPerThread / vec_size;
    using ltype                 = ::vec_t<scalar_t, vec_size>;
    const float inverted_kscale = k_scale == nullptr ? 1.0f : 1 / (*k_scale);
    const float inverted_vscale = v_scale == nullptr ? 1.0f : 1 / (*v_scale);

    int64_t const act_st     = isQ ? q_st : (isK ? k_st : v_st);
    int64_t const act_sh     = isQ ? q_sh : (isK ? k_sh : v_sh);
    int64_t const act_sd     = isQ ? q_sd : (isK ? k_sd : v_sd);
    scalar_t* const act_base = isQ ? q_act : (isK ? k_act : v_act);

    // Load data first, suppose have no tail since we check the head_dim is multiple of 32 before
    // kernel launch
    if(act_sd == 1)
    {
        int64_t const base_elems = (int64_t)tokenIdx * act_st + (int64_t)headIdx * act_sh +
                                   (int64_t)(laneId * numElemsPerThread);
#pragma unroll
        for(int i = 0; i < load_loop_cnt; i += 1)
        {
            reinterpret_cast<ltype*>(elements)[i] =
                *reinterpret_cast<ltype const*>(act_base + base_elems + i * vec_size);
        }
    }
    else
    {
#pragma unroll
        for(int j = 0; j < numElemsPerThread; j++)
        {
            int64_t const off = (int64_t)tokenIdx * act_st + (int64_t)headIdx * act_sh +
                                (int64_t)(laneId * numElemsPerThread + j) * act_sd;
            elements[j] = act_base[off];
        }
    }

    // If qk, we adopt RMSNorm + RoPE, so we need to compute sum of squares.
    if(!isV)
    {

        // Compute norm squares
        float sumOfSquares = 0.0f;
#pragma unroll
        for(int i = 0; i < numElemsPerThread; i++)
        {
            sumOfSquares += static_cast<float>(elements[i]) * static_cast<float>(elements[i]);
        }
        auto sum_func = [](float a, float b) { return a + b; };
        sumOfSquares  = warpReduceSum(sum_func, sumOfSquares);
        float rms_rcp = rsqrtf(sumOfSquares / static_cast<float>(head_dim) + eps);

        // Normalize elements
#pragma unroll
        for(int i = 0; i < numElemsPerThread; i++)
        {
            int dim      = laneId * numElemsPerThread + i;
            float weight = isQ ? float(q_weight[dim]) : float(k_weight[dim]);
            elements[i]  = static_cast<scalar_t>(elements[i] * rms_rcp * weight);
        }

        // Apply RoPE to normalized elements

        int64_t pos_id            = position_ids[tokenIdx];
        int const embed_dim       = rotary_dim / 2;
        scalar_t const* cache_ptr = cos_sin_cache + pos_id * rotary_dim;
        scalar_t const* cos_ptr   = cache_ptr;
        scalar_t const* sin_ptr   = cache_ptr + embed_dim;

        if constexpr(interleave)
        {
            // Perform interleaving. Use pre-computed cos/sin values.
#pragma unroll
            for(int i = 0; i < numElemsPerThread / 2; ++i)
            {
                int const idx0 = 2 * i;
                int const idx1 = 2 * i + 1;
                int const dim0 = laneId * numElemsPerThread + idx0;

                if(dim0 + 1 < rotary_dim)
                {
                    float const val0  = elements[idx0];
                    float const val1  = elements[idx1];
                    int const half_dim = dim0 / 2;
                    float cos_val     = static_cast<float>(cos_ptr[half_dim]);
                    float sin_val     = static_cast<float>(sin_ptr[half_dim]);

                    elements[idx0] = static_cast<scalar_t>(val0 * cos_val - val1 * sin_val);
                    elements[idx1] = static_cast<scalar_t>(val0 * sin_val + val1 * cos_val);
                }
            }
        }
        else
        {
            scalar_t elements2[numElemsPerThread]; // Additional buffer required for RoPE.
            // Before data exchange within warp, we need to sync.
            __syncwarp();
            int const partner_lane_delta = embed_dim / numElemsPerThread;
            // Get the data from the other half of the warp. Use pre-computed cos/sin values.
#pragma unroll
            for(int i = 0; i < numElemsPerThread; i++)
            {
                int const dim_idx = laneId * numElemsPerThread + i;
                if(dim_idx < rotary_dim)
                {
                    elements2[i] = static_cast<scalar_t>(
                        __shfl_xor(float(elements[i]), partner_lane_delta, 32));
                    if(dim_idx < embed_dim)
                    {
                        elements2[i] = -elements2[i];
                    }

                    int const half_dim = dim_idx % embed_dim;
                    float cos_val      = static_cast<float>(cos_ptr[half_dim]);
                    float sin_val      = static_cast<float>(sin_ptr[half_dim]);

                    elements[i] = static_cast<scalar_t>(
                        elements[i] * cos_val + elements2[i] * sin_val);
                }
            }
            __syncwarp();
        }
        int64_t const qk_st    = isQ ? q_st : k_st;
        int64_t const qk_sh    = isQ ? q_sh : k_sh;
        int64_t const qk_sd    = isQ ? q_sd : k_sd;
        scalar_t* const qk_dst = isQ ? q_out : k_out;
        if(qk_sd == 1)
        {
            int64_t const base_elems = (int64_t)tokenIdx * qk_st + (int64_t)headIdx * qk_sh +
                                       (int64_t)(laneId * numElemsPerThread);
#pragma unroll
            for(int i = 0; i < load_loop_cnt; i += 1)
            {
                *reinterpret_cast<ltype*>(qk_dst + base_elems + i * vec_size) =
                    reinterpret_cast<ltype*>(elements)[i];
            }
        }
        else
        {
#pragma unroll
            for(int j = 0; j < numElemsPerThread; j++)
            {
                int64_t const off = (int64_t)tokenIdx * qk_st + (int64_t)headIdx * qk_sh +
                                    (int64_t)(laneId * numElemsPerThread + j) * qk_sd;
                qk_dst[off] = elements[j];
            }
        }
    }

    if(isQ)
    {
        // For Q, we are done.
        return;
    }

    // cache the kv into kv cache and quant if required
    int64_t slot_id = slot_mapping[tokenIdx];
    if(slot_id < 0)
    {
        // invalid slot, skip
        return;
    }
    int64_t block_idx    = slot_id / page_size;
    int64_t block_offset = slot_id % page_size;
    __shared__ float shared_max[num_kv_heads];
    float dtype_max = static_cast<float>(opus::finfo<kv_cache_scalar_t>::max());
    float warp_max  = elements[0];

    // If quantization is required, compute the max abs value across the head_dim * num_heads
    if constexpr(kv_dt != vllm::Fp8KVCacheDataType::kAuto)
    {
        auto f_absmax_f32 = [](float v_0_, float v_1_) {
            return __builtin_fmaxf(abs(v_0_), abs(v_1_));
        };
#pragma unroll
        for(int i = 1; i < numElemsPerThread; i++)
        {
            warp_max = f_absmax_f32(warp_max, elements[i]);
        }
        warp_max = warpReduceSum(f_absmax_f32, warp_max);
    }
    if(isK)
    {
        float k_scale_val = 1.0f;
        if constexpr(kv_dt != vllm::Fp8KVCacheDataType::kAuto)
        {
            float const warp_max_safe = fmaxf(warp_max, aiter::kAmaxFloor);
            k_scale_val               = warp_max_safe / dtype_max;
            int64_t scale_offset =
                block_idx * page_size * num_kv_heads + headIdx * page_size + block_offset;
            k_scale[scale_offset] = k_scale_val;
        }
        int64_t cache_offset = block_idx * page_size * num_heads_k * head_dim +
                               headIdx * head_dim * page_size + block_offset * x;
#pragma unroll
        for(int i = 0; i < numElemsPerThread; i++)
        {
            int64_t offset = cache_offset + (laneId * numElemsPerThread + i) / x * page_size * x +
                             (laneId * numElemsPerThread + i) % x;
            if constexpr(kv_dt == vllm::Fp8KVCacheDataType::kAuto)
            {
                k_cache[offset] = elements[i];
            }
            else
            {
                k_cache[offset] =
                    opus::cast<kv_cache_scalar_t>(float(elements[i]) / k_scale_val);
            }
        }
    }
    else
    {
        float v_scale_val = 1.0f;
        if constexpr(kv_dt != vllm::Fp8KVCacheDataType::kAuto)
        {
            float const warp_max_safe = fmaxf(warp_max, aiter::kAmaxFloor);
            v_scale_val               = warp_max_safe / dtype_max;
            int64_t scale_offset =
                block_idx * page_size * num_kv_heads + headIdx * page_size + block_offset;
            v_scale[scale_offset] = v_scale_val;
        }
        int64_t cache_offset = block_idx * page_size * num_heads_v * head_dim +
                               headIdx * head_dim * page_size + block_offset / x * head_dim * x +
                               block_offset % x;
        // no vectorized store for v cache since its not contiguous on head_dim
#pragma unroll
        for(int i = 0; i < numElemsPerThread; i++)
        {
            int64_t offset = cache_offset + (laneId * numElemsPerThread + i) * x;
            if constexpr(kv_dt == vllm::Fp8KVCacheDataType::kAuto)
            {
                v_cache[offset] = elements[i];
            }
            else
            {
                v_cache[offset] =
                    opus::cast<kv_cache_scalar_t>(float(elements[i]) / v_scale_val);
            }
        }
    }
}
} // namespace probe

template __global__ void probe::fusedQKNormRopeQuantCacheShuffleKernel<float, float, 128, false, 1, vllm::Fp8KVCacheDataType::kAuto>(
    float*, float*, float*, int64_t, int64_t, int64_t, int64_t, int64_t, int64_t, int64_t, int64_t, int64_t,
    int, int, int, float, float const*, float const*, float const*, int64_t const*, float*, float*,
    int64_t*, float*, float*, int, int, int, int, float*, float*);
