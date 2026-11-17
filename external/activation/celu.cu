// PyTorch's CELU as its CUDA elu_kernel computes it, elu(x, alpha, 1, 1 / alpha): y[i] = x > 0 ?
// x : expm1(x * inv_alpha) * alpha, inv_alpha = 1 / alpha computed by the host, expm1 as in
// elu.cu; one thread per element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

__attribute__((device)) static float expm1(float v) {
    float e;
    asm("ex2.approx.f32 %0, %1;" : "=f"(e) : "f"(v * 1.44269504088896340736f));
    return e - 1.0f;
}

extern "C" __global__ void celu(const float *x, float *y, float alpha, float inv_alpha, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    const float a = x[i];
    const float negative = expm1(a * inv_alpha) * alpha;
    y[i] = a > 0.0f ? a : negative;
}
