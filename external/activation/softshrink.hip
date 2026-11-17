// PyTorch's Softshrink (torch.nn.Softshrink) as its CUDA kernel writes it: y[i] = x - lambd if
// x > lambd, x + lambd if x < -lambd, else 0; one wave of 64 work-items, one element each.
// Header-free so LLVM's clang compiles it without ROCm:
//   clang -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
//     -nogpuinc -O2 -g0 -fno-verbose-asm -S softshrink.hip -o softshrink.s

#define __global__ __attribute__((global))

// A 32-bit byte offset from a uniform base lowers to the scalar-base global_load/store form.
static inline __attribute__((device)) float *at(const float *base, unsigned index) {
    return (float *)((const char *)base + index * 4u);
}

extern "C" __global__ __attribute__((amdgpu_flat_work_group_size(64, 64))) void
softshrink(const float *x, float *y, float lambd, unsigned n) {
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i >= n)
        return;

    const float a = *at(x, i);
    *at(y, i) = a > lambd ? a - lambd : (a < -lambd ? a + lambd : 0.0f);
}
