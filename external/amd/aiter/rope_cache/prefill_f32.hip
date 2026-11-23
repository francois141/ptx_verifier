// Verbatim copy of fuse_qk_rope_concat_and_cache_mla_kernel_prefill_opt and its __global__ wrapper
// fuse_qk_rope_concat_and_cache_mla_kernel_prefill from csrc/kernels/cache_kernels.cu (Aiter 183a6ce,
// lines 3595-3903 and 4211-4252), wrapper reduced to its (is_neox, is_nope_first) arm. The host
// (fused_qk_rope_concat_and_cache_mla, GQA prefill: kv_c 3-D with size(1) > 1, rot_dim 64,
// kv_lora_rank 512) launches it with grid(num_tokens), block(256).
#define AITER_NO_TORCH_TYPES
#include "prelude.h"
#include "aiter_hip_common.h"
#include "attention_dtypes.h"
#include "opus/opus.hpp"
#include "aiter_opus_plus.h"
namespace aiter {
    template <typename scalar_t, typename cache_t, typename query_t, vllm::Fp8KVCacheDataType kv_dt, vllm::Fp8KVCacheDataType q_dt, bool is_neox, bool is_nope_first>
    __device__ void fuse_qk_rope_concat_and_cache_mla_kernel_prefill_opt(
        const scalar_t* __restrict__ q_nope,  // [num_tokens, num_heads, kv_lora_rank]
        const scalar_t* __restrict__ q_pe,    // [num_tokens, num_heads, pe_dim]
        const scalar_t* __restrict__ kv_c,    // [num_tokens, kv_lora_rank]
        const scalar_t* __restrict__ k_pe,    // [num_tokens, pe_dim]
        cache_t* __restrict__ kv_cache,       // [num_blocks, block_size, (qk_lora_rank + pe_dim)]
        query_t* __restrict__ q_out,          // [num_tokens, num_heads, kv_lora_rank + pe_dim]
        const int64_t* __restrict__ slot_mapping,  // [num_tokens]
        const int64_t* __restrict__ positions,     // [num_tokens]
        const scalar_t *__restrict__ cos_cache,        // [max_position, rot_dim //2]
        const scalar_t *__restrict__ sin_cache,        // [max_position, rot_dim //2]
        const int block_stride, const int entry_stride, const int kv_cache_stride_h,
        const int q_nope_stride_0, const int q_nope_stride_1, 
        const int q_pe_stride_0,const int q_pe_stride_1,
        const int q_out_stride_0, const int q_out_stride_1, 
        const int num_heads, const int num_kv_heads,
        const int kv_c_stride_0, const int kv_c_stride_1, 
        const int k_pe_stride_0, const int k_pe_stride_1,
        const int kv_lora_rank, const int pe_dim,
        const int block_size,
        const float* scale, const float* q_scale
    ) {
      const int64_t token_idx = blockIdx.x;
      const int64_t slot_idx = slot_mapping[token_idx];
      // NOTE: slot_idx can be -1 if the token is padded
      if (slot_idx < 0) {
        return;
      }
      //concat
      const int64_t block_idx = slot_idx / block_size;
      const int64_t block_offset = slot_idx % block_size;
      const float inverted_kscale = 1.0f / *scale;
      const int64_t kv_cache_offset = block_idx * block_stride + block_offset * entry_stride;
      static constexpr int32_t vec_size_i = std::is_same_v<scalar_t, float> ? 4 : 8;
      static constexpr int32_t vec_size_o = vec_size_i;
      using opus_vec_i = opus::vector_t<scalar_t, vec_size_i>;
      using opus_vec_o = opus::vector_t<cache_t, vec_size_o>;
      static constexpr int32_t ooba_i = 4 / sizeof(scalar_t);
      static constexpr int32_t ooba_o = 4 / sizeof(cache_t);
      const int64_t qH_per_kH = num_heads;
      const int64_t kv_lora_dim = 512; // extend: = kv_lora_rank
      const int64_t head_size = kv_lora_dim + pe_dim;
      const int32_t oob_i             = (kv_lora_dim * num_kv_heads + ooba_i - 1) / ooba_i * ooba_i;
      const int32_t oob_o             = (head_size * num_kv_heads + ooba_o - 1) / ooba_o * ooba_o;
      int32_t nope_offset = 0;
      if constexpr (!is_nope_first) {
        nope_offset = pe_dim;
      }
      auto const* ptr_i               = reinterpret_cast<scalar_t const*>(kv_c + token_idx * kv_c_stride_0);
      auto* ptr_o                     = reinterpret_cast<cache_t*>(kv_cache + kv_cache_offset + nope_offset);
      
      // FIX: oob_i is in elements, but make_gmem expects size in BYTES
      auto buffer_i = opus::make_gmem<scalar_t>(ptr_i, oob_i * sizeof(scalar_t));
      auto buffer_o = opus::make_gmem<cache_t>(ptr_o, oob_o * sizeof(cache_t));
      
      const float inverted_qscale = 1.0f / *q_scale;
      const int32_t size = num_heads * kv_lora_dim;
      static constexpr int32_t q_ooba_o = 4 / sizeof(query_t);
      const int64_t q_input_span = (num_heads - 1) * static_cast<int64_t>(q_nope_stride_1) + kv_lora_dim;
      const int64_t q_oob_i = (q_input_span + ooba_i - 1) / ooba_i * ooba_i;
      const int32_t q_oob_o = (num_heads * head_size + q_ooba_o - 1) / q_ooba_o * q_ooba_o;
      
      // Use opus::make_gmem for Q buffers, size in BYTES
      auto q_buffer_i = opus::make_gmem<scalar_t>(q_nope + token_idx * q_nope_stride_0, q_oob_i * sizeof(scalar_t));
      auto q_buffer_o = opus::make_gmem<query_t>(q_out + q_out_stride_0 * token_idx + nope_offset, q_oob_o * sizeof(query_t));
      
      const int32_t num_vecs = (size + vec_size_i - 1) / vec_size_i;
      const int32_t num_kv_vecs = (kv_lora_dim * num_kv_heads + vec_size_i - 1) / vec_size_i;
      const uint32_t kv_lora_vec = 64;//kv_lora_dim / vec_size_o;
      
      using opus_vec_q = opus::vector_t<query_t, vec_size_o>;
      // Reduced vector registers: only use two vectors total (reuse for both Q and K)
      opus_vec_i vec_cur, vec_nxt;
      uint32_t vec_idx = threadIdx.x;
      constexpr uint32_t vec_stride = 256;
      
      // Prepare RoPE cos/sin pointers (needed for both Q and K RoPE)
      const int32_t cos_sin_cache_offset = positions[token_idx] * (pe_dim >> 1);
      const scalar_t *cos_ptr = cos_cache + cos_sin_cache_offset;
      const scalar_t *sin_ptr = sin_cache + cos_sin_cache_offset;
      constexpr int32_t embed_dim = 32;
      
      // Phase 1: Process Q and K nope together for first num_kv_heads
      // Calculate head indices once and maintain them as loop variables
      uint32_t head_idx = vec_idx / kv_lora_vec;
      uint32_t in_head_idx = vec_idx % kv_lora_vec;
      bool has_data = (vec_idx < num_kv_vecs);
      
      // Load first vectors if thread is in range
      if (has_data) {
        // Calculate offset considering stride(1) for non-contiguous tensors
        uint32_t kv_c_offset = head_idx * kv_c_stride_1 + in_head_idx * vec_size_i;
        size_t q_nope_offset = head_idx * static_cast<size_t>(q_nope_stride_1) + in_head_idx * vec_size_i;
        vec_cur = buffer_i.template load<vec_size_i>(kv_c_offset);  // K data in vec_cur initially
        vec_nxt = q_buffer_i.template load<vec_size_i>(q_nope_offset); // Q data in vec_nxt
      }
      
      // Double buffering loop: process Q and K nope together
      for (uint32_t next_idx = vec_idx + vec_stride; next_idx < num_kv_vecs; next_idx += vec_stride)
      {
        // Calculate store offsets using current head_idx and in_head_idx
        uint32_t store_offset = head_idx * kv_cache_stride_h + in_head_idx * vec_size_o;
        uint32_t q_store_offset = head_idx * q_out_stride_1 + in_head_idx * vec_size_o;
        
        // Calculate next indices for prefetch
        uint32_t next_head_idx = next_idx / kv_lora_vec;
        uint32_t next_in_head_idx = next_idx % kv_lora_vec;
        uint32_t next_kv_c_offset = next_head_idx * kv_c_stride_1 + next_in_head_idx * vec_size_i;
        size_t next_q_nope_offset = next_head_idx * static_cast<size_t>(q_nope_stride_1) + next_in_head_idx * vec_size_i;
        opus_vec_i k_nxt = buffer_i.template load<vec_size_i>(next_kv_c_offset);
        opus_vec_i q_nxt = q_buffer_i.template load<vec_size_i>(next_q_nope_offset);
        
        // Store K data (vec_cur holds K)
        if constexpr (kv_dt == vllm::Fp8KVCacheDataType::kAuto) {
          buffer_o.template store<vec_size_o>(vec_cur, store_offset);
        } else {
          buffer_o.template store<vec_size_o>(aiter::scaled_cast<cache_t>(vec_cur, inverted_kscale), store_offset);
        }
        
        // Store Q data (vec_nxt holds Q)
        if constexpr (q_dt == vllm::Fp8KVCacheDataType::kAuto) {
          q_buffer_o.template store<vec_size_o>(vec_nxt, q_store_offset);
        } else {
          q_buffer_o.template store<vec_size_o>(aiter::scaled_cast<query_t>(vec_nxt, inverted_qscale), q_store_offset);
        }
        
        // Swap: next K goes to vec_cur, next Q goes to vec_nxt
        vec_cur = k_nxt;
        vec_nxt = q_nxt;
        
        // Update loop variables for next iteration
        vec_idx = next_idx;
        head_idx = next_head_idx;
        in_head_idx = next_in_head_idx;
      }
      
      // Store last vectors if we loaded data (use maintained head_idx and in_head_idx)
      if (has_data) {
        // Store last K
        if constexpr (kv_dt == vllm::Fp8KVCacheDataType::kAuto) {
          buffer_o.template store<vec_size_o>(vec_cur, head_idx * kv_cache_stride_h + in_head_idx * vec_size_o);
        } else {
          buffer_o.template store<vec_size_o>(aiter::scaled_cast<cache_t>(vec_cur, inverted_kscale), 
              head_idx * kv_cache_stride_h + in_head_idx * vec_size_o);
        }
        
        // Store last Q
        if constexpr (q_dt == vllm::Fp8KVCacheDataType::kAuto) {
          q_buffer_o.template store<vec_size_o>(vec_nxt, head_idx * q_out_stride_1 + in_head_idx * vec_size_o);
        } else {
          q_buffer_o.template store<vec_size_o>(aiter::scaled_cast<query_t>(vec_nxt, inverted_qscale), 
              head_idx * q_out_stride_1 + in_head_idx * vec_size_o);
        }
      }
      
      // Phase 2: Process remaining Q nope only
      // Start from the next vector after num_kv_vecs
      uint32_t q_vec_idx = num_kv_vecs + threadIdx.x;
      uint32_t q_head_idx = q_vec_idx / kv_lora_vec;
      uint32_t q_in_head_idx = q_vec_idx % kv_lora_vec;
      
      // Load first Q vector if in range (num_heads > num_kv_heads case)
      if (q_vec_idx < num_vecs) {
        size_t q_nope_offset = q_head_idx * static_cast<size_t>(q_nope_stride_1) + q_in_head_idx * vec_size_i;
        vec_cur = q_buffer_i.template load<vec_size_i>(q_nope_offset);
      }
      
      // Double buffering loop for remaining Q
      for (uint32_t next_q_idx = q_vec_idx + vec_stride; next_q_idx < num_vecs; next_q_idx += vec_stride)
      {
        // Calculate next indices for prefetch
        uint32_t next_head_idx = next_q_idx / kv_lora_vec;
        uint32_t next_in_head_idx = next_q_idx % kv_lora_vec;
        size_t next_q_nope_offset = next_head_idx * static_cast<size_t>(q_nope_stride_1) + next_in_head_idx * vec_size_i;
        vec_nxt = q_buffer_i.template load<vec_size_i>(next_q_nope_offset);
        
        // Calculate store offset using current q_head_idx and q_in_head_idx
        uint32_t store_offset = q_head_idx * q_out_stride_1 + q_in_head_idx * vec_size_o;
        
        if constexpr (q_dt == vllm::Fp8KVCacheDataType::kAuto) {
          q_buffer_o.template store<vec_size_o>(vec_cur, store_offset);
        } else {
          q_buffer_o.template store<vec_size_o>(aiter::scaled_cast<query_t>(vec_cur, inverted_qscale), store_offset);
        }
        
        // Update loop variables
        vec_cur = vec_nxt;
        q_vec_idx = next_q_idx;
        q_head_idx = next_head_idx;
        q_in_head_idx = next_in_head_idx;
      }
      
      // Store last Q vector if loaded (use maintained q_head_idx and q_in_head_idx)
      if (q_vec_idx < num_vecs) {
        uint32_t store_offset = q_head_idx * q_out_stride_1 + q_in_head_idx * vec_size_o;
        if constexpr (q_dt == vllm::Fp8KVCacheDataType::kAuto) {
          q_buffer_o.template store<vec_size_o>(vec_cur, store_offset);
        } else {
          q_buffer_o.template store<vec_size_o>(aiter::scaled_cast<query_t>(vec_cur, inverted_qscale), store_offset);
        }
      }
    
      // ============ RoPE Phase ============
      // Adjust base pointers for RoPE region
      if constexpr (is_nope_first) {
        q_out += head_size - pe_dim;
        kv_cache += head_size - pe_dim;
      }
      
      const int32_t nq = num_heads * embed_dim;
      const int32_t nk = num_kv_heads * embed_dim;
      const int32_t token_q_base = token_idx * q_pe_stride_0;
      const int32_t token_k_base = token_idx * k_pe_stride_0;
      const int32_t token_q_out_base = token_idx * q_out_stride_0;
      
      // Phase 1: Process Q and K RoPE together
      for (uint32_t r_idx = threadIdx.x; r_idx < nk; r_idx += vec_stride)
      {
          const uint32_t rope_head = r_idx / embed_dim;
          const uint32_t rot_off = r_idx % embed_dim;
          
          // Calculate cos/sin indices and load once
          uint32_t x_idx, y_idx;
          float f32_cos, f32_sin;
          if constexpr (is_neox) {
            x_idx = rot_off;
            y_idx = embed_dim + rot_off;
            f32_cos = static_cast<float>(*(cos_ptr + x_idx));
            f32_sin = static_cast<float>(*(sin_ptr + x_idx));
          } else {
            x_idx = rot_off << 1;  // *2
            y_idx = x_idx + 1;
            f32_cos = static_cast<float>(*(cos_ptr + (x_idx >> 1)));
            f32_sin = static_cast<float>(*(sin_ptr + (x_idx >> 1)));
          }
          
          // K RoPE: load, compute, store
          const scalar_t* k_in = k_pe + token_k_base + rope_head * k_pe_stride_1;
          cache_t* k_out = kv_cache + kv_cache_offset + rope_head * kv_cache_stride_h;
          
          float kx = static_cast<float>(k_in[x_idx]);
          float ky = static_cast<float>(k_in[y_idx]);
          float k_rot_x = kx * f32_cos - ky * f32_sin;
          float k_rot_y = ky * f32_cos + kx * f32_sin;
          
          if constexpr (std::is_same_v<cache_t, opus::fp8_t>) {
            k_out[x_idx] = opus::cast<opus::fp8_t>(k_rot_x * inverted_kscale);
            k_out[y_idx] = opus::cast<opus::fp8_t>(k_rot_y * inverted_kscale);
          } else {
            k_out[x_idx] = static_cast<cache_t>(k_rot_x);
            k_out[y_idx] = static_cast<cache_t>(k_rot_y);
          }
          
          // Q RoPE: load, compute, store (same head index in this range)
          const scalar_t* q_in = q_pe + token_q_base + rope_head * q_pe_stride_1;
          query_t* q_out_ptr = q_out + token_q_out_base + rope_head * q_out_stride_1;
          
          float qx = static_cast<float>(q_in[x_idx]);
          float qy = static_cast<float>(q_in[y_idx]);
          float q_rot_x = qx * f32_cos - qy * f32_sin;
          float q_rot_y = qy * f32_cos + qx * f32_sin;
          
          if constexpr (std::is_same_v<query_t, opus::fp8_t>) {
            q_out_ptr[x_idx] = opus::cast<opus::fp8_t>(q_rot_x * inverted_qscale);
            q_out_ptr[y_idx] = opus::cast<opus::fp8_t>(q_rot_y * inverted_qscale);
          } else {
            q_out_ptr[x_idx] = static_cast<query_t>(q_rot_x);
            q_out_ptr[y_idx] = static_cast<query_t>(q_rot_y);
          }
      }
      
      // Phase 2: Process remaining Q RoPE only (if num_heads > num_kv_heads)
      for (uint32_t r_idx = nk + threadIdx.x; r_idx < nq; r_idx += vec_stride)
      {
          const uint32_t rope_head = r_idx / embed_dim;
          const uint32_t rot_off = r_idx % embed_dim;
          
          // Calculate cos/sin indices and load
          uint32_t x_idx, y_idx;
          float f32_cos, f32_sin;
          if constexpr (is_neox) {
            x_idx = rot_off;
            y_idx = embed_dim + rot_off;
            f32_cos = static_cast<float>(*(cos_ptr + x_idx));
            f32_sin = static_cast<float>(*(sin_ptr + x_idx));
          } else {
            x_idx = rot_off << 1;
            y_idx = x_idx + 1;
            f32_cos = static_cast<float>(*(cos_ptr + (x_idx >> 1)));
            f32_sin = static_cast<float>(*(sin_ptr + (x_idx >> 1)));
          }
          
          // Q RoPE: load, compute, store
          const scalar_t* q_in = q_pe + token_q_base + rope_head * q_pe_stride_1;
          query_t* q_out_ptr = q_out + token_q_out_base + rope_head * q_out_stride_1;
          
          float qx = static_cast<float>(q_in[x_idx]);
          float qy = static_cast<float>(q_in[y_idx]);
          
          if constexpr (std::is_same_v<query_t, opus::fp8_t>) {
            q_out_ptr[x_idx] = opus::cast<opus::fp8_t>((qx * f32_cos - qy * f32_sin) * inverted_qscale);
            q_out_ptr[y_idx] = opus::cast<opus::fp8_t>((qy * f32_cos + qx * f32_sin) * inverted_qscale);
          } else {
            q_out_ptr[x_idx] = static_cast<query_t>(qx * f32_cos - qy * f32_sin);
            q_out_ptr[y_idx] = static_cast<query_t>(qy * f32_cos + qx * f32_sin);
          }
      }
    }
    template <typename scalar_t, typename cache_t, typename query_t, vllm::Fp8KVCacheDataType kv_dt, vllm::Fp8KVCacheDataType q_dt>
    __global__ void fuse_qk_rope_concat_and_cache_mla_kernel_prefill(
        const scalar_t* __restrict__ q_nope,  // [num_tokens, num_heads, kv_lora_rank]
        const scalar_t* __restrict__ q_pe,    // [num_tokens, num_heads, pe_dim]
        const scalar_t* __restrict__ kv_c,    // [num_tokens, num_kv_heads, kv_lora_rank]
        const scalar_t* __restrict__ k_pe,    // [num_tokens, num_kv_heads, pe_dim]
        cache_t* __restrict__ kv_cache,       // [num_blocks, block_size, num_kv_heads, (qk_lora_rank + pe_dim)]
        query_t* __restrict__ q_out,          // [num_tokens, num_heads, num_kv_heads, kv_lora_rank + pe_dim]
        const int64_t* __restrict__ slot_mapping,  // [num_tokens]
        const int64_t* __restrict__ positions,     // [num_tokens]
        const scalar_t *__restrict__ cos_cache,        // [max_position, rot_dim //2]
        const scalar_t *__restrict__ sin_cache,        // [max_position, rot_dim //2]
        const int block_stride, const int entry_stride, const int kv_cache_stride_h,
        const int q_nope_stride_0, const int q_nope_stride_1,
        const int q_pe_stride_0, const int q_pe_stride_1,
        const int q_out_stride_0, const int q_out_stride_1, 
        const int num_heads, const int num_kv_heads,
        const int kv_c_stride_0, const int kv_c_stride_1, 
        const int k_pe_stride_0, const int k_pe_stride_1,
        const int kv_lora_rank, const int pe_dim,
        const int block_size,
        const float* scale, const float* q_scale,
        bool is_neox, bool is_nope_first
    ) {
      // Probe: NeoX, nope-first arm only (the launch passes both true).

        fuse_qk_rope_concat_and_cache_mla_kernel_prefill_opt<scalar_t,cache_t,query_t, kv_dt, q_dt, true, true>(q_nope, q_pe, kv_c, k_pe, kv_cache, q_out, slot_mapping, positions, 
                                           cos_cache, sin_cache, block_stride, entry_stride, kv_cache_stride_h, q_nope_stride_0, q_nope_stride_1, q_pe_stride_0, q_pe_stride_1, q_out_stride_0,
                                           q_out_stride_1, num_heads, num_kv_heads, kv_c_stride_0, kv_c_stride_1, k_pe_stride_0, k_pe_stride_1, kv_lora_rank, pe_dim, block_size, scale, q_scale);

    }

template __global__ void fuse_qk_rope_concat_and_cache_mla_kernel_prefill<float, float, float, vllm::Fp8KVCacheDataType::kAuto, vllm::Fp8KVCacheDataType::kAuto>(
    const float*, const float*, const float*, const float*, float*, float*, const int64_t*, const int64_t*,
    const float*, const float*, const int, const int, const int, const int, const int, const int, const int,
    const int, const int, const int, const int, const int, const int, const int, const int, const int, const int,
    const int, const float*, const float*, bool, bool);
}
