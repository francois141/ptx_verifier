// PyTorch's Hardtanh (torch.nn.Hardtanh): y[i] = min(max(x, min_val), max_val), the clamp its
// CUDA kernel applies, std::min and std::max spelled as libstdc++ defines them; one thread per
// element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

__attribute__((device)) static const float &max(const float &a, const float &b) {
    return (a < b) ? b : a;
}

__attribute__((device)) static const float &min(const float &a, const float &b) {
    return (b < a) ? b : a;
}

extern "C" __global__ void hardtanh(const float *x, float *y, float min_val, float max_val, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    const float a = x[i];
    y[i] = min(max(a, min_val), max_val);
}
