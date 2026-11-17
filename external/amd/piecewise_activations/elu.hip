// PyTorch's ELU as its CUDA elu_kernel computes it with scale = input_scale = 1: y[i] = x > 0 ?
// x : expm1(x) * alpha. expm1 is the hardware exp2 of x * log2(e), minus 1: the fast-math exp, as
// gelu.cu's tanh.approx. Both pieces are computed before the select, so clang emits a v_cndmask
// rather than a branch on x. One wave of 64 work-items, one element each. Header-free so LLVM's
// clang compiles it without ROCm:
//   clang -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
//     -nogpuinc -O2 -g0 -fno-verbose-asm -S elu.hip -o elu.s

#define __global__ __attribute__((global))

// A 32-bit byte offset from a uniform base lowers to the scalar-base global_load/store form.
static inline __attribute__((device)) float *at(const float *base, unsigned index) {
    return (float *)((const char *)base + index * 4u);
}

static inline __attribute__((device)) float expm1(float v) {
    return __builtin_amdgcn_exp2f(v * 1.44269504088896340736f) - 1.0f;
}

extern "C" __global__ __attribute__((amdgpu_flat_work_group_size(64, 64))) void
elu(const float *x, float *y, float alpha, unsigned n) {
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i >= n)
        return;

    const float a = *at(x, i);
    const float negative = expm1(a) * alpha;
    *at(y, i) = a > 0.0f ? a : negative;
}
