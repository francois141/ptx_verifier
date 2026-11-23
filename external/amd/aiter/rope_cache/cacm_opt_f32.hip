// Verbatim copy of concat_and_cache_mla_opt_kernel (csrc/kernels/cache_kernels.cu lines 1078-1189,
// Aiter 183a6ce); the host (concat_and_cache_mla, kv_lora_rank and pe_dim multiples of 8) launches it
// with grid(num_tokens), block(min(kv_lora_rank, 1024) / 8).
#define AITER_NO_TORCH_TYPES
#include "prelude.h"
#include "aiter_hip_common.h"
#include "attention_dtypes.h"
#include "opus/opus.hpp"
#include "aiter_opus_plus.h"
namespace aiter {
template <typename scalar_t, typename cache_t, vllm::Fp8KVCacheDataType kv_dt>
__global__ void concat_and_cache_mla_opt_kernel(
    const scalar_t* __restrict__ kv_c,        // [num_tokens, kv_lora_rank]
    const scalar_t* __restrict__ k_pe,        // [num_tokens, pe_dim]
    cache_t* __restrict__ kv_cache,           // [num_blocks, block_size, (kv_lora_rank
                                              // + pe_dim)]
    const int64_t* __restrict__ slot_mapping, // [num_tokens]
    const int block_stride,                   //
    const int entry_stride,                   //
    const int kv_c_stride,                    //
    const int k_pe_stride,                    //
    const int kv_lora_rank,                   //
    const int pe_dim,                         //
    const int block_size,                     //
    const float* scale                        //
)
{
    const int64_t token_idx = blockIdx.x;
    const int64_t slot_idx  = slot_mapping[token_idx];
    // NOTE: slot_idx can be -1 if the token is padded
    if(slot_idx < 0)
    {
        return;
    }
    const int64_t block_idx             = slot_idx / block_size;
    const int64_t block_offset          = slot_idx % block_size;
    const float inverted_kscale         = 1.0f / *scale;
    static constexpr int32_t vec_size_i = std::is_same_v<scalar_t, float> ? 4 : 8;
    static constexpr int32_t vec_size_o = vec_size_i;
    using vec_i                         = opus::vector_t<scalar_t, vec_size_i>;
    static constexpr int32_t ooba_i     = 4 / sizeof(scalar_t);
    static constexpr int32_t ooba_o     = 4 / sizeof(cache_t);
    auto out_offset                     = block_idx * block_stride + block_offset * entry_stride;

    const int32_t oob_i = (kv_lora_rank + ooba_i - 1) / ooba_i * ooba_i;
    auto const* ptr_i   = reinterpret_cast<scalar_t const*>(kv_c + token_idx * kv_c_stride);
    // auto buffer_i =
    //     ck_tile::make_buffer_view<ck_tile::address_space_enum::global>(ptr_i, oob_i);
    // buffer_i.init_raw();
    auto buffer_i = opus::make_gmem<scalar_t>(ptr_i, oob_i * sizeof(scalar_t));

    const int32_t pe_oob_i = (pe_dim + ooba_i - 1) / ooba_i * ooba_i;
    auto const* pe_ptr_i   = reinterpret_cast<scalar_t const*>(k_pe + token_idx * k_pe_stride);
    // auto pe_buffer_i =
    //     ck_tile::make_buffer_view<ck_tile::address_space_enum::global>(pe_ptr_i, pe_oob_i);
    // pe_buffer_i.init_raw();
    auto pe_buffer_i = opus::make_gmem<scalar_t>(pe_ptr_i, pe_oob_i * sizeof(scalar_t));
    const int32_t pe_num_vecs = (pe_dim + vec_size_i - 1) / vec_size_i;
    vec_i pe_vec_nxt;
    vec_i pe_vec_cur;
    size_t vec_idx    = threadIdx.x;
    size_t vec_stride = blockDim.x;
    // double load core loop start
    const int32_t num_vecs = (kv_lora_rank + vec_size_i - 1) / vec_size_i;
    vec_i vec_nxt;
    vec_i vec_cur;
    // vec_cur = buffer_i.template get<vec_i>(vec_idx * vec_size_i, 0, true);
    vec_cur = buffer_i.template load<vec_size_i>(vec_idx * vec_size_i);
    if(vec_idx < pe_num_vecs)
    {
        // pe_vec_cur = pe_buffer_i.template get<vec_i>(vec_idx * vec_size_i, 0, true);
        pe_vec_cur = pe_buffer_i.template load<vec_size_i>(vec_idx * vec_size_i);
    }
    const int32_t oob_o = (kv_lora_rank + ooba_o - 1) / ooba_o * ooba_o;
    auto* ptr_o         = reinterpret_cast<cache_t*>(kv_cache + out_offset);
    // auto buffer_o =
    //     ck_tile::make_buffer_view<ck_tile::address_space_enum::global>(ptr_o, oob_o);
    // buffer_o.init_raw();
    auto buffer_o = opus::make_gmem<cache_t>(ptr_o, oob_o * sizeof(cache_t));
    const int32_t pe_oob_o = (pe_dim + ooba_o - 1) / ooba_o * ooba_o;
    auto* pe_ptr_o         = reinterpret_cast<cache_t*>(kv_cache + out_offset + kv_lora_rank);
    // auto pe_buffer_o =
    //     ck_tile::make_buffer_view<ck_tile::address_space_enum::global>(pe_ptr_o, pe_oob_o);
    // pe_buffer_o.init_raw();
    auto pe_buffer_o = opus::make_gmem<cache_t>(pe_ptr_o, pe_oob_o * sizeof(cache_t));
    for(vec_idx += vec_stride; vec_idx < num_vecs; vec_idx += vec_stride)
    {
        // vec_nxt = buffer_i.template get<vec_i>(vec_idx * vec_size_i, 0, true);
        vec_nxt = buffer_i.template load<vec_size_i>(vec_idx * vec_size_i);
        if constexpr(kv_dt == vllm::Fp8KVCacheDataType::kAuto)
        {
            store_vector<cache_t, scalar_t, vec_size_i, RT, false, WARP_SIZE, 1, cache_t>(buffer_o, vec_cur, (vec_idx - vec_stride) * vec_size_o);
        }
        else
        {
            store_vector<cache_t, scalar_t, vec_size_i, RT, false, WARP_SIZE, 1, cache_t>(buffer_o, vec_cur, (vec_idx - vec_stride) * vec_size_o, inverted_kscale);
        }
        vec_cur = vec_nxt;
    }
    if(threadIdx.x < pe_num_vecs) {
      if constexpr(kv_dt == vllm::Fp8KVCacheDataType::kAuto)
      {
          store_vector<cache_t, scalar_t, vec_size_i, RT, false, WARP_SIZE, 1, cache_t>(pe_buffer_o, pe_vec_cur, threadIdx.x * vec_size_o);
      }
      else
      {
          store_vector<cache_t, scalar_t, vec_size_i, RT, false, WARP_SIZE, 1, cache_t>(pe_buffer_o, pe_vec_cur, threadIdx.x * vec_size_o, inverted_kscale);
      }
    }
    if(vec_idx - vec_stride < num_vecs)
    {
        if constexpr(kv_dt == vllm::Fp8KVCacheDataType::kAuto)
        {
            store_vector<cache_t, scalar_t, vec_size_i, RT, false, WARP_SIZE, 1, cache_t>(buffer_o, vec_cur, (vec_idx - vec_stride) * vec_size_o);
        }
        else
        {
            store_vector<cache_t, scalar_t, vec_size_i, RT, false, WARP_SIZE, 1, cache_t>(buffer_o, vec_cur, (vec_idx - vec_stride) * vec_size_o, inverted_kscale);
        }
    }

}

template __global__ void concat_and_cache_mla_opt_kernel<float, float, vllm::Fp8KVCacheDataType::kAuto>(
    const float*, const float*, float*, const int64_t*, const int, const int, const int, const int,
    const int, const int, const int, const float*);
}
