// PyTorch's Hardsigmoid (torch.nn.Hardsigmoid) as its CUDA kernel writes it: y[i] =
// min(max(x + 3, 0), 6) * one_sixth, std::min and std::max spelled as libstdc++ defines them;
// one thread per element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

__attribute__((device)) static const float &max(const float &a, const float &b) {
    return (a < b) ? b : a;
}

__attribute__((device)) static const float &min(const float &a, const float &b) {
    return (b < a) ? b : a;
}

extern "C" __global__ void hardsigmoid(const float *x, float *y, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    const float a = x[i];
    const float zero = 0.0f, three = 3.0f, six = 6.0f, one_sixth = 1.0f / 6.0f;
    y[i] = min(max(a + three, zero), six) * one_sixth;
}
