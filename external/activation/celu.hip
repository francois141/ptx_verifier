// PyTorch's CELU as its CUDA elu_kernel computes it, elu(x, alpha, 1, 1 / alpha): y[i] = x > 0 ?
// x : expm1(x * inv_alpha) * alpha, inv_alpha = 1 / alpha computed by the host, as PyTorch's
// celu does. expm1 is the hardware exp2 of x * log2(e), minus 1, as in elu.hip, and both pieces
// are computed before the select. It takes n first so its arguments end on a 16-byte boundary:
// with n last, clang reads alpha, inv_alpha and n with one 16-byte load, which runs past the
// 28-byte argument segment. One wave of 64 work-items, one element each:
//   clang -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
//     -nogpuinc -O2 -g0 -fno-verbose-asm -S celu.hip -o celu.s

#define __global__ __attribute__((global))

// A 32-bit byte offset from a uniform base lowers to the scalar-base global_load/store form.
static inline __attribute__((device)) float *at(const float *base, unsigned index) {
    return (float *)((const char *)base + index * 4u);
}

static inline __attribute__((device)) float expm1(float v) {
    return __builtin_amdgcn_exp2f(v * 1.44269504088896340736f) - 1.0f;
}

extern "C" __global__ __attribute__((amdgpu_flat_work_group_size(64, 64))) void
celu(unsigned n, const float *x, float *y, float alpha, float inv_alpha) {
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i >= n)
        return;

    const float a = *at(x, i);
    const float negative = expm1(a * inv_alpha) * alpha;
    *at(y, i) = a > 0.0f ? a : negative;
}
