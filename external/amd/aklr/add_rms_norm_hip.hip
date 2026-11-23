// AKLR's HIP add_rms_norm_hidden_size6144 kernel (kernel.hip's device code, lines 30-184), launched
// as its `run` does for hidden size 6144: add_rmsnorm_bf16_kernel<3>, one 256-thread block per row.
// The host code (the torch binding) is left out; only <hip/hip_runtime.h> is needed.
#include <hip/hip_runtime.h>

#include "prelude.h"

#include <cstdint>
#include <initializer_list>

// aklr: kernel.hip 30-184

template __global__ void add_rmsnorm_bf16_kernel<3>(const void*, const void*, const void*, void*, void*,
                                                    double);
}  // namespace
