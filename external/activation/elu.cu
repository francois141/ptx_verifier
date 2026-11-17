// PyTorch's ELU as its CUDA elu_kernel computes it with scale = input_scale = 1: y[i] = x > 0 ?
// x : expm1(x) * alpha, expm1 the ex2.approx.f32 of x * log2(e), minus 1, as gelu.cu's
// tanh.approx; one thread per element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

__attribute__((device)) static float expm1(float v) {
    float e;
    asm("ex2.approx.f32 %0, %1;" : "=f"(e) : "f"(v * 1.44269504088896340736f));
    return e - 1.0f;
}

extern "C" __global__ void elu(const float *x, float *y, float alpha, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    const float a = x[i];
    const float negative = expm1(a) * alpha;
    y[i] = a > 0.0f ? a : negative;
}
