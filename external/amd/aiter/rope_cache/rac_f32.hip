// Verbatim copy of SlotIndexWidth/load_slot_index (lines 41-55) and reshape_and_cache_kernel (lines 207-287)
// from csrc/kernels/cache_kernels.cu (Aiter 183a6ce); host: grid(num_tokens), block(min(H*D, 512)).
#define AITER_NO_TORCH_TYPES
#include "prelude.h"
#include "aiter_hip_common.h"
#include "attention_dtypes.h"
#include "opus/opus.hpp"
#include "aiter_opus_plus.h"
namespace aiter {
enum class SlotIndexWidth : int
{
    kInt32 = 0,
    kInt64 = 1,
};

__device__ __forceinline__ int64_t load_slot_index(const void* __restrict__ slot_mapping,
                                                   int64_t token_idx,
                                                   SlotIndexWidth width)
{
    return width == SlotIndexWidth::kInt64
               ? static_cast<const int64_t*>(slot_mapping)[token_idx]
               : static_cast<int64_t>(
                     static_cast<const int32_t*>(slot_mapping)[token_idx]);
}
template <typename scalar_t,
          typename cache_t,
          vllm::Fp8KVCacheDataType kv_dt,
          bool asmLayout = false>
__global__ void
reshape_and_cache_kernel(const scalar_t* __restrict__ key,   // [num_tokens, num_heads, head_size]
                         const scalar_t* __restrict__ value, // [num_tokens, num_heads, head_size]
                         cache_t* __restrict__ key_cache,    // [num_blocks, num_heads, head_size/x,
                                                             // block_size, x]
                         cache_t* __restrict__ value_cache,  // [num_blocks, num_heads, head_size,
                                                             // block_size]
                         const void* __restrict__ slot_mapping, // [num_tokens], int32 or int64
                         const SlotIndexWidth slot_width,
                         const int key_stride,
                         const int value_stride,
                         const int num_heads,
                         const int head_size,
                         const int block_size,
                         const int x,
                         const float* k_scale,
                         const float* v_scale)
{
    const int64_t token_idx = blockIdx.x;
    const int64_t slot_idx  = load_slot_index(slot_mapping, token_idx, slot_width);
    if(slot_idx < 0)
    {
        // Padding token that should be ignored.
        return;
    }

    const int64_t block_idx    = slot_idx / block_size;
    const int64_t block_offset = slot_idx % block_size;

    const int n                 = num_heads * head_size;
    const float inverted_kscale = k_scale == nullptr ? 1.0f : 1 / (*k_scale);
    const float inverted_vscale = v_scale == nullptr ? 1.0f : 1 / (*v_scale);
    for(int i = threadIdx.x; i < n; i += blockDim.x)
    {
        const int64_t src_key_idx   = token_idx * key_stride + i;
        const int64_t src_value_idx = token_idx * value_stride + i;

        const int head_idx    = i / head_size;
        const int head_offset = i % head_size;
        const int x_idx       = head_offset / x;
        const int x_offset    = head_offset % x;

        const int64_t tgt_key_idx = block_idx * num_heads * (head_size / x) * block_size * x +
                                    head_idx * (head_size / x) * block_size * x +
                                    x_idx * block_size * x + block_offset * x + x_offset;
        int64_t tgt_value_idx;
        if constexpr(asmLayout)
        { //[num_blocks, num_heads, block_size/X, head_size, X]
            const int x_idx_v    = block_offset / x;
            const int x_offset_v = block_offset % x;
            tgt_value_idx        = block_idx * num_heads * head_size * block_size +
                            head_idx * head_size * block_size + x_idx_v * head_size * x +
                            head_offset * x + x_offset_v;
        }
        else
        { //[num_blocks, num_heads, head_size, block_size]
            tgt_value_idx = block_idx * num_heads * head_size * block_size +
                            head_idx * head_size * block_size + head_offset * block_size +
                            block_offset;
        }
        scalar_t tgt_key   = key[src_key_idx];
        scalar_t tgt_value = value[src_value_idx];
        if constexpr(kv_dt == vllm::Fp8KVCacheDataType::kAuto)
        {
            key_cache[tgt_key_idx]     = tgt_key;
            value_cache[tgt_value_idx] = tgt_value;
        }
        else
        {
            key_cache[tgt_key_idx] = opus::cast<cache_t>(
                static_cast<float>(tgt_key) * inverted_kscale);
            value_cache[tgt_value_idx] = opus::cast<cache_t>(
                static_cast<float>(tgt_value) * inverted_vscale);
        }
    }
}


template __global__ void reshape_and_cache_kernel<float, float, vllm::Fp8KVCacheDataType::kAuto, false>(
    const float*, const float*, float*, float*, const void*, const SlotIndexWidth, const int, const int,
    const int, const int, const int, const int, const float*, const float*);
}
