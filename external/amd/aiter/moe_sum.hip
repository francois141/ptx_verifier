// Aiter's moe_sum (`aiter.moe_sum(input, output)`: each token's top-k expert outputs summed),
// instantiated as the host dispatch (topk_softmax_kernels.cu, moe_sum) picks it for fp32 data:
// one workgroup per token of min(hidden, 1024) threads. Its bf16 path stores through
// hip_bfloat16's software rounding, bit operations on the data that Volta does not model.
#include "prelude.h"
#include "aiter_hip_common.h"

namespace vllm {
namespace moe {
// aiter: csrc/kernels/topk_softmax_kernels.cu 771-789

template __global__ void moe_sum_kernel<float, 2>(float*, const float*, const int);
template __global__ void moe_sum_kernel<float, 4>(float*, const float*, const int);
} // namespace moe
} // namespace vllm
