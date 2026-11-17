// PyTorch's SELU as its CUDA elu_kernel computes it, elu(x, SELU_ALPHA, SELU_SCALE, 1): y[i] =
// x > 0 ? x * scale : expm1(x) * (alpha * scale), the constants PyTorch's in f32 and their
// product rounded to f32 as its host rounds negcoef, expm1 as in elu.cu; one thread per element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

__attribute__((device)) static float expm1(float v) {
    float e;
    asm("ex2.approx.f32 %0, %1;" : "=f"(e) : "f"(v * 1.44269504088896340736f));
    return e - 1.0f;
}

constexpr float alpha = 1.6732632423543772848170429916717f;
constexpr float scale = 1.0507009873554804934193349852946f;

extern "C" __global__ void selu(const float *x, float *y, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    const float a = x[i];
    const float positive = a * scale;
    const float negative = expm1(a) * (alpha * scale);
    y[i] = a > 0.0f ? positive : negative;
}
