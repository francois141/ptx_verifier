// PyTorch's LeakyReLU (torch.nn.LeakyReLU) as its CUDA kernel writes it: y[i] = x > 0 ? x :
// x * negval; one thread per element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

extern "C" __global__ void leaky_relu(const float *x, float *y, float negval, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    const float a = x[i];
    y[i] = a > 0.0f ? a : a * negval;
}
