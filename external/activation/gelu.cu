// PyTorch's tanh GELU (torch.nn.GELU(approximate='tanh')): y[i] = 0.5 * x * (1 + tanh(kBeta *
// (x + kKappa * x^3))), written as PyTorch's GeluCUDAKernelImpl writes it, its tanhf the
// tanh.approx.f32 of --use_fast_math; one thread per element.

#include <__clang_cuda_builtin_vars.h>

#define __global__ __attribute__((global))

__attribute__((device)) static float tanh_approx(float v) {
    float t;
    asm("tanh.approx.f32 %0, %1;" : "=f"(t) : "f"(v));
    return t;
}

extern "C" __global__ void gelu(const float *x, float *y, unsigned n) {
    const unsigned i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n)
        return;

    constexpr float kBeta = 1.41421356237309504880f * 1.12837916709551257390f * 0.5f;
    constexpr float kKappa = 0.044715f;
    const float a = x[i];
    const float x_cube = a * a * a;
    const float inner = kBeta * (a + kKappa * x_cube);
    y[i] = 0.5f * a * (1.0f + tanh_approx(inner));
}
