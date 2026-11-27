// Instantiates FlashInfer's RMSNorm family (include/flashinfer/norm.cuh) through its host
// launchers, as csrc/norm.cu does, for bf16 and f16. Compiled by external/ptx/extraction/survey.py.
#include <cuda_bf16.h>
#include <cuda_fp16.h>
#include <flashinfer/norm.cuh>

using namespace flashinfer::norm;

template <typename T>
void instantiate(T* x, T* r, T* w, T* o) {
  RMSNorm<T>(x, w, o, 1, 4096, 4096, 4096);
  QKRMSNorm<T>(x, w, o, 1, 8, 128, 1024, 128, 1024, 128);
  FusedAddRMSNorm<T>(x, r, w, 1, 4096, 4096, 4096);
  GemmaRMSNorm<T>(x, w, o, 1, 4096, 4096, 4096);
  GemmaFusedAddRMSNorm<T>(x, r, w, 1, 4096, 4096, 4096);
}

template void instantiate<__nv_bfloat16>(__nv_bfloat16*, __nv_bfloat16*, __nv_bfloat16*,
                                         __nv_bfloat16*);
template void instantiate<half>(half*, half*, half*, half*);
