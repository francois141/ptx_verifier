// Instantiates FlashInfer's cos/sin-cache RoPE (include/flashinfer/pos_enc.cuh) through its host
// launcher, as csrc/rope.cu's apply_rope_pos_ids_cos_sin_cache does, for bf16 and f16.
#include <cuda_bf16.h>
#include <cuda_fp16.h>
#include <flashinfer/pos_enc.cuh>

using namespace flashinfer;

template <typename T>
void instantiate(T* q, T* k, T* qr, T* kr, float* cache, int64_t* pos) {
  for (bool interleave : {false, true}) {
    BatchQKApplyRotaryPosIdsCosSinCache<T, int64_t>(q, k, qr, kr, cache, pos, 4, 32, 8, 128, 128,
                                                    4096, 128, 1024, 128, 4096, 128, 1024, 128,
                                                    interleave);
  }
}

template void instantiate<__nv_bfloat16>(__nv_bfloat16*, __nv_bfloat16*, __nv_bfloat16*,
                                         __nv_bfloat16*, float*, int64_t*);
template void instantiate<half>(half*, half*, half*, half*, float*, int64_t*);
