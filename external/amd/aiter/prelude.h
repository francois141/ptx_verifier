// The ROCm device library's functions that Aiter's kernels call, which -nogpulib omits:
// ockl's workitem.cl and ocml's math as hipcc links them (each module's own flags decide
// whether -ffast-math lets __builtin_expf lower to v_exp_f32 directly).
#pragma once
#include <hip/hip_runtime.h>

extern "C" __device__ size_t __ockl_get_group_id(unsigned dim)
{
    return dim == 0   ? __builtin_amdgcn_workgroup_id_x()
           : dim == 1 ? __builtin_amdgcn_workgroup_id_y()
           : dim == 2 ? __builtin_amdgcn_workgroup_id_z()
                      : 0;
}
extern "C" __device__ size_t __ockl_get_local_id(unsigned dim)
{
    return dim == 0   ? __builtin_amdgcn_workitem_id_x()
           : dim == 1 ? __builtin_amdgcn_workitem_id_y()
           : dim == 2 ? __builtin_amdgcn_workitem_id_z()
                      : 0;
}
extern "C" __device__ size_t __ockl_get_local_size(unsigned dim)
{
    return dim == 0   ? __builtin_amdgcn_workgroup_size_x()
           : dim == 1 ? __builtin_amdgcn_workgroup_size_y()
           : dim == 2 ? __builtin_amdgcn_workgroup_size_z()
                      : 1;
}
// Code object v5: the grid's block counts open the implicit arguments.
extern "C" __device__ size_t __ockl_get_num_groups(unsigned dim)
{
    const unsigned* counts = static_cast<const unsigned*>(__builtin_amdgcn_implicitarg_ptr());
    return dim < 3 ? counts[dim] : 1;
}
extern "C" __device__ float __ocml_exp_f32(float x) { return __builtin_expf(x); }
extern "C" __device__ float __ocml_exp2_f32(float x) { return __builtin_exp2f(x); }
extern "C" __device__ float __ocml_sqrt_f32(float x) { return __builtin_sqrtf(x); }
extern "C" __device__ float __ocml_rsqrt_f32(float x) { return __builtin_amdgcn_rsqf(x); }
extern "C" __device__ float __ocml_native_rsqrt_f32(float x) { return __builtin_amdgcn_rsqf(x); }
extern "C" __device__ double __ocml_rsqrt_f64(double x) { return __builtin_amdgcn_rsq(x); }
extern "C" __device__ float __ocml_fmax_f32(float x, float y) { return __builtin_fmaxf(x, y); }
extern "C" __device__ float __ocml_fmin_f32(float x, float y) { return __builtin_fminf(x, y); }
