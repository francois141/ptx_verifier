// Verbatim copy of fuse_qk_rope_concat_and_cache_mla_per_head_kernel(_impl) from
// csrc/kernels/cache_kernels.cu (Aiter 183a6ce), lines 2296-2520, instantiated as the host
// dispatch picks it for fp32, kv_cache "auto", q_out "auto", kv_lora_rank <= 128 (vec_size 4).
#define AITER_NO_TORCH_TYPES
#include "prelude.h"
#include "aiter_hip_common.h"
#include "attention_dtypes.h"
#include "opus/opus.hpp"
#include "aiter_opus_plus.h"
namespace aiter {
 template <typename scalar_t, typename cache_t, typename query_t, vllm::Fp8KVCacheDataType kv_dt, 
         vllm::Fp8KVCacheDataType q_dt, bool is_neox, bool is_nope_first=true, int32_t vec_size=4>
inline __device__ void fuse_qk_rope_concat_and_cache_mla_per_head_kernel_impl(
    const scalar_t* __restrict__ q_nope,  // [num_tokens, num_heads, kv_lora_rank]
    const scalar_t* __restrict__ q_pe,  // [num_tokens, num_heads, pe_dim]
    const scalar_t* __restrict__ kv_c,  // [num_tokens, kv_lora_rank]
    const scalar_t* __restrict__ k_pe,  // [num_tokens, pe_dim]
    cache_t* __restrict__ kv_cache,  // [num_blocks, block_size, (qk_lora_rank
                                     // + pe_dim)]
    query_t* __restrict__ q_out,  // [num_tokens, num_heads, kv_lora_rank + pe_dim]
    const int64_t* __restrict__ slot_mapping,  // [num_tokens]
    const int64_t* __restrict__ positions,     // [num_tokens]
    const scalar_t *__restrict__ cos_cache,        // [max_position, rot_dim //2]
    const scalar_t *__restrict__ sin_cache,        // [max_position, rot_dim //2]
    const int block_stride,                    //
    const int entry_stride,                    //
    const int q_nope_stride_0, const int q_nope_stride_1,                   //
    const int q_pe_stride_0, const int q_pe_stride_1,                     //
    const int q_out_stride_0, const int q_out_stride_1,                    //
    const int num_heads,                       //
    const int kv_c_stride,                     //
    const int k_pe_stride,                     //
    const int kv_lora_rank,                    //
    const int pe_dim,                          // 64
    const int block_size,                      //
    const float* k_scale,                         //
    const float* q_scale,
    const int max_position,
    const bool compute_all_q_rope
) {
  const int64_t token_idx = blockIdx.x / num_heads; //num_heads
  const int64_t head_idx = blockIdx.x % num_heads;

  const int64_t slot_idx = slot_mapping[token_idx];
  int64_t pos = positions[token_idx];

  // compute_all_q_rope == false (non-DCP default): restore the original early-return
  // so padded / cudagraph tokens (slot_idx < 0) skip Q RoPE + q_out entirely.
  // compute_all_q_rope == true (DCP): every rank needs all queries after the head
  // all-gather, so compute Q RoPE unconditionally; only the KV-cache writes
  // below are guarded by (slot_idx >= 0). Clamp pos defensively: padded tokens
  // may carry a stale position that would index cos/sin out of bounds.
  if (!compute_all_q_rope && slot_idx < 0) {
    return;
  }
  pos = pos < 0 ? 0 : (pos >= max_position ? max_position - 1 : pos);
  int64_t cos_sin_cache_offset = pos * 32;
  const scalar_t *cos_ptr = cos_cache + cos_sin_cache_offset;
  const scalar_t *sin_ptr = sin_cache + cos_sin_cache_offset;
  const int64_t block_idx = slot_idx;// / block_size;
  const int64_t block_offset = 0;//slot_idx % block_size;

  const int64_t head_size = kv_lora_rank + 64;
  // rotary emmbedding
  //concat
  static constexpr int32_t ooba_i = 4 / sizeof(scalar_t);
  static constexpr int32_t ooba_o = 4 / sizeof(cache_t);
  const int32_t oob_i             = (kv_lora_rank + ooba_i - 1) / ooba_i * ooba_i;
  const int32_t oob_o             = (kv_lora_rank + ooba_o - 1) / ooba_o * ooba_o;
  // Auto-adjust vec_size based on scalar_t size to avoid exceeding 16-byte limit
  // float (4 bytes): max vec_size=4 (16 bytes), half/bf16 (2 bytes): max vec_size=8 (16 bytes)
  static constexpr int32_t max_vec_size = (sizeof(scalar_t) == 4) ? 4 : vec_size;
  static constexpr int32_t vec_size_i = max_vec_size;
  static constexpr int32_t vec_size_o = vec_size_i;
  using opus_vec_i = opus::vector_t<scalar_t, vec_size_i>;
  using opus_vec_o = opus::vector_t<cache_t, vec_size_o>;
  using opus_vec_q = opus::vector_t<query_t, vec_size_o>;

  float inv_qscale = 1.0f;
  if constexpr (kv_dt != vllm::Fp8KVCacheDataType::kAuto) {
      inv_qscale = 1.0f / *q_scale;
  }
  static constexpr int32_t q_ooba_o = 4 / sizeof(query_t);
  auto const* q_ptr_i               = reinterpret_cast<scalar_t const*>(q_nope + token_idx * q_nope_stride_0 + head_idx * q_nope_stride_1);
  auto* q_ptr_o                     = reinterpret_cast<query_t*>(q_out + token_idx * q_out_stride_0 + head_idx * q_out_stride_1);
  // Use opus::make_gmem instead of ck_tile::make_buffer_view
  auto buffer_i = opus::make_gmem<scalar_t>(q_ptr_i, oob_i * sizeof(scalar_t));
  auto buffer_o = opus::make_gmem<query_t>(q_ptr_o, oob_o * sizeof(query_t));
  opus_vec_i vec_cur;  // Use opus_vec_i directly, no need to cast on load
  size_t vec_idx    = threadIdx.x;
  vec_cur = buffer_i.template load<vec_size_i>(vec_idx * vec_size_i);
  const int embed_dim = 32;
  const int nq =  embed_dim;
  q_out += head_size - pe_dim;

  scalar_t cos, sin;
  scalar_t x, y;
  int x_index, y_index;
  if(threadIdx.x < nq)
  {
    // GPT-NeoX style rotary embedding. 
    if constexpr (is_neox)
    {
      // GPT-NeoX style rotary embedding.
      x_index = threadIdx.x;
      y_index = embed_dim + threadIdx.x;
      cos = cos_ptr[x_index];//*(cos_ptr + x_index);
      sin = sin_ptr[x_index];//*(sin_ptr + x_index);
    }
    else
    {
      // GPT-J style rotary embedding.
      x_index = 2 * threadIdx.x;
      y_index = 2 * threadIdx.x + 1;
      cos = cos_ptr[x_index/2];//*(cos_ptr + x_index / 2);
      sin = sin_ptr[x_index/2];//*(sin_ptr + x_index / 2);
    }
    const int64_t token_head_in = token_idx * q_pe_stride_0 + head_idx * q_pe_stride_1;
    const int rot_offset = threadIdx.x;
    const scalar_t * q_pe_rot = q_pe + token_head_in;
    x = q_pe_rot[x_index];
    y = q_pe_rot[y_index];
  }
  if constexpr (q_dt == vllm::Fp8KVCacheDataType::kAuto) {
    buffer_o.template store<vec_size_o, opus_vec_i>(vec_cur, vec_idx * vec_size_o);
  } else {
    opus_vec_q vec_converted = aiter::scaled_cast<query_t>(vec_cur, inv_qscale);
    buffer_o.template store<vec_size_o, opus_vec_q>(vec_converted, vec_idx * vec_size_o);
  }
  float fp32_cos = static_cast<float>(cos);
  float fp32_sin = static_cast<float>(sin);
  if (head_idx == 0 && slot_idx >= 0) {
    auto const* ptr_i               = reinterpret_cast<scalar_t const*>(kv_c + token_idx * kv_c_stride);

    // Use opus::make_gmem for kv_c input
    auto kv_buffer_i = opus::make_gmem<scalar_t>(ptr_i, oob_i * sizeof(scalar_t));
    vec_cur = kv_buffer_i.template load<vec_size_i>(vec_idx * vec_size_i);

    float inv_kscale = 1.0f;
    if constexpr (kv_dt != vllm::Fp8KVCacheDataType::kAuto) {
      inv_kscale = 1.0f / *k_scale;
    }
    const int64_t token_head_in = token_idx * k_pe_stride;

     scalar_t k_x, k_y;
    if (threadIdx.x < 32)
    {
      const int rot_offset = threadIdx.x;
      const scalar_t* k_pe_rot =  k_pe + token_head_in;

      k_x = k_pe_rot[x_index];
      k_y = k_pe_rot[y_index];
    }
    const int64_t kv_cache_offset = block_idx * block_stride + block_offset * entry_stride;
    auto* ptr_o                     = reinterpret_cast<cache_t*>(kv_cache + kv_cache_offset);
    // Use opus::make_gmem for kv_cache output
    auto kv_buffer_o = opus::make_gmem<cache_t>(ptr_o, oob_o * sizeof(cache_t));
    if constexpr (kv_dt == vllm::Fp8KVCacheDataType::kAuto) {
        kv_buffer_o.template store<vec_size_o, opus_vec_i>(vec_cur, vec_idx * vec_size_o);
    } else {
        opus_vec_o vec_converted = aiter::scaled_cast<cache_t>(vec_cur, inv_kscale);
        kv_buffer_o.template store<vec_size_o, opus_vec_o>(vec_converted, vec_idx * vec_size_o);
    }

    float fp32_k_x = static_cast<float>(k_x);
    float fp32_k_y = static_cast<float>(k_y);

    if (threadIdx.x < 32)
    {
        kv_cache += kv_lora_rank;
        const int64_t token_head = kv_cache_offset;
        cache_t* kv_cache_rot = kv_cache + token_head;
        if constexpr (std::is_same_v<cache_t, opus::fp8_t>) {
          kv_cache_rot[x_index] = opus::cast<opus::fp8_t>(
               (fp32_k_x * fp32_cos - fp32_k_y * fp32_sin) * inv_kscale);
          kv_cache_rot[y_index] = opus::cast<opus::fp8_t>(
               (fp32_k_y * fp32_cos + fp32_k_x * fp32_sin) * inv_kscale);
        } else {
          kv_cache_rot[x_index] = static_cast<cache_t>((fp32_k_x * fp32_cos - fp32_k_y * fp32_sin));
          kv_cache_rot[y_index] = static_cast<cache_t>((fp32_k_y * fp32_cos + fp32_k_x * fp32_sin));
        }
    }
  }
  if (threadIdx.x < 32)
  {
    const int64_t token_head = token_idx * q_out_stride_0 + head_idx * q_out_stride_1;
    query_t * q_out_rot = q_out + token_head;
    float f32_x = static_cast<float>(x);
    float f32_y = static_cast<float>(y);
    if constexpr (std::is_same_v<query_t, opus::fp8_t>) {
        q_out_rot[x_index] = opus::cast<opus::fp8_t>((f32_x * fp32_cos - f32_y * fp32_sin) * inv_qscale);
        q_out_rot[y_index] = opus::cast<opus::fp8_t>((f32_y * fp32_cos + f32_x * fp32_sin) * inv_qscale);
    } else {
        q_out_rot[x_index] = static_cast<query_t>((f32_x * fp32_cos - f32_y * fp32_sin));
        q_out_rot[y_index] = static_cast<query_t>((f32_y * fp32_cos + f32_x * fp32_sin));
    }
  }

}
 template <typename scalar_t, typename cache_t, typename query_t, vllm::Fp8KVCacheDataType kv_dt, vllm::Fp8KVCacheDataType q_dt, int32_t vec_size=4>
__global__ void fuse_qk_rope_concat_and_cache_mla_per_head_kernel(
    const scalar_t* __restrict__ q_nope,  // [num_tokens, num_heads, kv_lora_rank]
    const scalar_t* __restrict__ q_pe,  // [num_tokens, num_heads, pe_dim]
    const scalar_t* __restrict__ kv_c,  // [num_tokens, kv_lora_rank]
    const scalar_t* __restrict__ k_pe,  // [num_tokens, pe_dim]
    cache_t* __restrict__ kv_cache,  // [num_blocks, block_size, (qk_lora_rank
                                     // + pe_dim)]
    query_t* __restrict__ q_out,  // [num_tokens, num_heads, kv_lora_rank + pe_dim]
    const int64_t* __restrict__ slot_mapping,  // [num_tokens]
    const int64_t* __restrict__ positions,     // [num_tokens]
    const scalar_t *__restrict__ cos_cache,        // [max_position, rot_dim //2]
    const scalar_t *__restrict__ sin_cache,        // [max_position, rot_dim //2]
    const int block_stride, const int entry_stride,                    //
    const int q_nope_stride_0, const int q_nope_stride_1,                   //
    const int q_pe_stride_0, const int q_pe_stride_1,                     //
    const int q_out_stride_0, const int q_out_stride_1,                    //
    const int num_heads,                       //
    const int kv_c_stride, const int k_pe_stride,                     //
    const int kv_lora_rank, const int pe_dim,                          // 64
    const int block_size,                      //
    const float* k_scale, const float* q_scale,
    bool is_neox, bool is_nope_first, const int max_position,
    const bool compute_all_q_rope
) {
  // Probe: NeoX arm only (the launch passes is_neox = true).
    fuse_qk_rope_concat_and_cache_mla_per_head_kernel_impl<scalar_t, cache_t, query_t, kv_dt, q_dt, true, true, vec_size>(q_nope, q_pe, kv_c, k_pe, kv_cache, q_out, slot_mapping,
                                                  positions, cos_cache, sin_cache,block_stride, entry_stride, q_nope_stride_0, q_nope_stride_1, q_pe_stride_0, q_pe_stride_1,
                                                  q_out_stride_0, q_out_stride_1, num_heads, kv_c_stride, k_pe_stride, kv_lora_rank, pe_dim, block_size, k_scale, q_scale, max_position, compute_all_q_rope);

}
template __global__ void fuse_qk_rope_concat_and_cache_mla_per_head_kernel<float, float, float, vllm::Fp8KVCacheDataType::kAuto, vllm::Fp8KVCacheDataType::kAuto, 4>(
    const float*, const float*, const float*, const float*, float*, float*,
    const int64_t*, const int64_t*, const float*, const float*, const int, const int, const int, const int,
    const int, const int, const int, const int, const int, const int, const int, const int, const int, const int,
    const float*, const float*, bool, bool, const int, const bool);
}
