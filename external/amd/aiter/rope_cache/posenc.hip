// Probe: vllm::rotary_embedding_kernel (csrc/kernels/pos_encoding_kernels.cu:100-124), verbatim except that the
// in-place query/key are split into read-only inputs and separate outputs (Volta has no in-place arrays); each
// thread reads and writes only its own (x, y) pair, so the split preserves semantics.
#include "prelude.h"
#include <hip/hip_bf16.h>
#include "aiter_hip_common.h"
#include <hip/amd_detail/amd_hip_bfloat16.h>
namespace probe {
template <typename scalar_t, bool IS_NEOX>
inline __device__ void apply_token_rotary_embedding(const scalar_t* __restrict__ arr, scalar_t* __restrict__ arr_o,
    const scalar_t* __restrict__ cos_ptr, const scalar_t* __restrict__ sin_ptr, int rot_offset, int embed_dim)
{
    int x_index, y_index;
    scalar_t cos, sin;
    if (IS_NEOX) { x_index = rot_offset; y_index = embed_dim + rot_offset; cos = *(cos_ptr + x_index); sin = *(sin_ptr + x_index); }
    else { x_index = 2 * rot_offset; y_index = 2 * rot_offset + 1; cos = *(cos_ptr + x_index / 2); sin = *(sin_ptr + x_index / 2); }
    const scalar_t x = arr[x_index];
    const scalar_t y = arr[y_index];
    arr_o[x_index] = x * cos - y * sin;
    arr_o[y_index] = y * cos + x * sin;
}
template <typename scalar_t, bool IS_NEOX, bool is_nope_first>
inline __device__ void apply_rotary_embedding(const scalar_t* __restrict__ query, scalar_t* __restrict__ query_o,
    const scalar_t* __restrict__ key, scalar_t* __restrict__ key_o, const scalar_t* cos_ptr, const scalar_t* sin_ptr,
    const int head_size, const int num_heads, const int num_kv_heads, const int rot_dim, const int token_idx,
    const int64_t query_stride, const int64_t key_stride)
{
    const int embed_dim = rot_dim / 2;
    const int nq = num_heads * embed_dim;
    if (is_nope_first) { query += head_size - rot_dim; key += head_size - rot_dim; query_o += head_size - rot_dim; key_o += head_size - rot_dim; }
    for (int i = threadIdx.x; i < nq; i += blockDim.x) {
        const int head_idx = i / embed_dim;
        const int64_t token_head = token_idx * query_stride + head_idx * head_size;
        const int rot_offset = i % embed_dim;
        apply_token_rotary_embedding<scalar_t, IS_NEOX>(query + token_head, query_o + token_head, cos_ptr, sin_ptr, rot_offset, embed_dim);
    }
    const int nk = num_kv_heads * embed_dim;
    for (int i = threadIdx.x; i < nk; i += blockDim.x) {
        const int head_idx = i / embed_dim;
        const int64_t token_head = token_idx * key_stride + head_idx * head_size;
        const int rot_offset = i % embed_dim;
        apply_token_rotary_embedding<scalar_t, IS_NEOX>(key + token_head, key_o + token_head, cos_ptr, sin_ptr, rot_offset, embed_dim);
    }
}
template <typename scalar_t, bool IS_NEOX, bool is_nope_first>
__global__ void rotary_embedding_kernel(const int64_t* __restrict__ positions, const scalar_t* __restrict__ query,
    scalar_t* __restrict__ query_o, const scalar_t* __restrict__ key, scalar_t* __restrict__ key_o,
    const scalar_t* __restrict__ cos_cache, const scalar_t* __restrict__ sin_cache, const int rot_dim,
    const int64_t query_stride, const int64_t key_stride, const int num_heads, const int num_kv_heads, const int head_size)
{
    const int token_idx = blockIdx.x;
    int64_t pos = positions[token_idx];
    int64_t cos_sin_cache_offset = pos * rot_dim / 2;
    const scalar_t* cos_ptr = cos_cache + cos_sin_cache_offset;
    const scalar_t* sin_ptr = sin_cache + cos_sin_cache_offset;
    apply_rotary_embedding<scalar_t, IS_NEOX, is_nope_first>(query, query_o, key, key_o, cos_ptr, sin_ptr, head_size,
        num_heads, num_kv_heads, rot_dim, token_idx, query_stride, key_stride);
}
#define INST(T, N, F) template __global__ void rotary_embedding_kernel<T, N, F>(const int64_t*, const T*, T*, const T*, T*, \
    const T*, const T*, int, int64_t, int64_t, int, int, int);
INST(hip_bfloat16, true, false)
INST(hip_bfloat16, false, false)
INST(float, true, false)
INST(float, false, true)
}
