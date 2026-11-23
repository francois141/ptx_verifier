// AKLR's HIP bf16 lm-head GEMMs (gemm_n<N>_k<K>: out[m, N] = a[m, K] @ b[N, K].T): gemm_stream.h's
// kernel instantiated with the tile the schema's kernel.hip `run` launches for the case's m
// (LMHEAD_CFG, given by cases.py). The host code (the torch binding) is left out.
#include <hip/hip_runtime.h>

#include "prelude.h"
#include "gemm_stream.h"

template __global__ void lmhead::gemm_kernel<LMHEAD_CFG>(const __bf16*, const __bf16*, __bf16*,
                                                         lmhead::f32x4*, uint64_t*, int);
