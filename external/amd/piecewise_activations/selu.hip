// PyTorch's SELU as its CUDA elu_kernel computes it, elu(x, SELU_ALPHA, SELU_SCALE, 1): y[i] =
// x > 0 ? x * scale : expm1(x) * (alpha * scale), the constants PyTorch's, in f32. Its host
// rounds negcoef = alpha * scale to f32; clang folds the product the same way. expm1 is the
// hardware exp2 of x * log2(e), minus 1, as in elu.hip, and both pieces are computed before
// the select. One wave of 64 work-items, one element each:
//   clang -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
//     -nogpuinc -O2 -g0 -fno-verbose-asm -S selu.hip -o selu.s

#define __global__ __attribute__((global))

// A 32-bit byte offset from a uniform base lowers to the scalar-base global_load/store form.
static inline __attribute__((device)) float *at(const float *base, unsigned index) {
    return (float *)((const char *)base + index * 4u);
}

static inline __attribute__((device)) float expm1(float v) {
    return __builtin_amdgcn_exp2f(v * 1.44269504088896340736f) - 1.0f;
}

constexpr float alpha = 1.6732632423543772848170429916717f;
constexpr float scale = 1.0507009873554804934193349852946f;

extern "C" __global__ __attribute__((amdgpu_flat_work_group_size(64, 64))) void
selu(const float *x, float *y, unsigned n) {
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i >= n)
        return;

    const float a = *at(x, i);
    const float positive = a * scale;
    const float negative = expm1(a) * (alpha * scale);
    *at(y, i) = a > 0.0f ? positive : negative;
}
