// PyTorch's LeakyReLU (torch.nn.LeakyReLU) as its CUDA kernel writes it: y[i] = x > 0 ? x :
// x * negval; one wave of 64 work-items, one element each. Header-free so LLVM's clang compiles
// it without ROCm:
//   clang -x hip -std=c++17 --offload-arch=gfx950:xnack- --offload-device-only -nogpulib \
//     -nogpuinc -O2 -g0 -fno-verbose-asm -S leaky_relu.hip -o leaky_relu.s

#define __global__ __attribute__((global))

// A 32-bit byte offset from a uniform base lowers to the scalar-base global_load/store form.
static inline __attribute__((device)) float *at(const float *base, unsigned index) {
    return (float *)((const char *)base + index * 4u);
}

extern "C" __global__ __attribute__((amdgpu_flat_work_group_size(64, 64))) void
leaky_relu(const float *x, float *y, float negval, unsigned n) {
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i >= n)
        return;

    const float a = *at(x, i);
    *at(y, i) = a > 0.0f ? a : a * negval;
}
