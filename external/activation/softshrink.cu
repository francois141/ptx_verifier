// PyTorch's Softshrink (torch.nn.Softshrink) as its CUDA kernel writes it: y[i] = x - lambd if
// x > lambd, x + lambd if x < -lambd, else 0; one thread per element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

extern "C" __global__ void softshrink(const float *x, float *y, float lambd, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    const float a = x[i];
    y[i] = a > lambd ? a - lambd : (a < -lambd ? a + lambd : 0.0f);
}
