// Instantiates FlashInfer's attention-state merges (include/flashinfer/attention/cascade.cuh)
// through their host launchers, as csrc/cascade.cu does, for bf16 and f16.
#include <cuda_bf16.h>
#include <cuda_fp16.h>
#include <flashinfer/attention/cascade.cuh>

using namespace flashinfer;

template <typename T>
void instantiate(T* v, T* w, T* o, float* s, float* t, float* u, int32_t* indptr,
                 uint32_t* seq_len) {
  MergeState<T, T>(v, s, w, t, o, u, 1, 32, 128);
  MergeStateInPlace<T>(v, s, w, t, 1, 32, 128);
  MergeStates<T, T>(v, s, o, u, 4, 1, 32, 128);
  VariableLengthMergeStates<T, T, int32_t>(v, s, indptr, o, u, 1, seq_len, 32, 128, false);
}

template void instantiate<__nv_bfloat16>(__nv_bfloat16*, __nv_bfloat16*, __nv_bfloat16*, float*,
                                         float*, float*, int32_t*, uint32_t*);
template void instantiate<half>(half*, half*, half*, float*, float*, float*, int32_t*, uint32_t*);
