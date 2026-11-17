// PyTorch's Hardswish (torch.nn.Hardswish) as its CUDA kernel writes it: y[i] =
// x * min(max(x + 3, 0), 6) * one_sixth, std::min and std::max spelled as libstdc++ defines
// them; one wave of 64 work-items, one element each. With -funsafe-math-optimizations, the min
// and max stay NaN-preserving selects. Header-free so LLVM's clang compiles it without ROCm:
//   clang -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
//     -nogpuinc -O2 -g0 -fno-verbose-asm -funsafe-math-optimizations \
//     -S hardswish_nans.hip -o hardswish_nans.s

#define __global__ __attribute__((global))

// A 32-bit byte offset from a uniform base lowers to the scalar-base global_load/store form.
static inline __attribute__((device)) float *at(const float *base, unsigned index) {
    return (float *)((const char *)base + index * 4u);
}

static inline __attribute__((device)) const float &max(const float &a, const float &b) {
    return (a < b) ? b : a;
}

static inline __attribute__((device)) const float &min(const float &a, const float &b) {
    return (b < a) ? b : a;
}

extern "C" __global__ __attribute__((amdgpu_flat_work_group_size(64, 64))) void
hardswish_nans(const float *x, float *y, unsigned n) {
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i >= n)
        return;

    const float a = *at(x, i);
    const float zero = 0.0f, three = 3.0f, six = 6.0f, one_sixth = 1.0f / 6.0f;
    *at(y, i) = a * min(max(a + three, zero), six) * one_sixth;
}
