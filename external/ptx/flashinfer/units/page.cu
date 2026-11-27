// Instantiates FlashInfer's paged-KV append (include/flashinfer/page.cuh) through its host
// launchers, as csrc/page.cu does, for bf16 and f16.
#include <cuda_bf16.h>
#include <cuda_fp16.h>
#include <flashinfer/page.cuh>

using namespace flashinfer;

template <typename T>
void instantiate(paged_kv_t<T, int32_t> kv, T* key, T* value, int32_t* batch, int32_t* pos) {
  AppendPagedKVCacheDecode<T, int32_t>(kv, key, value);
  AppendPagedKVCache<T, int32_t>(kv, key, value, batch, pos, 4, 1024, 128, 1024, 128);
}

template void instantiate<__nv_bfloat16>(paged_kv_t<__nv_bfloat16, int32_t>, __nv_bfloat16*,
                                         __nv_bfloat16*, int32_t*, int32_t*);
template void instantiate<half>(paged_kv_t<half, int32_t>, half*, half*, int32_t*, int32_t*);
