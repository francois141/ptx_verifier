// The ROCm device library's definitions (ockl's workitem.cl, ocml's expF.cl as hipcc links it
// under -ffast-math), which -nogpulib omits.
#pragma once
#include <hip/hip_runtime.h>
extern "C" __device__ size_t __ockl_get_group_id(unsigned dim)
{
    return dim == 0 ? __builtin_amdgcn_workgroup_id_x()
         : dim == 1 ? __builtin_amdgcn_workgroup_id_y()
         : dim == 2 ? __builtin_amdgcn_workgroup_id_z() : 0;
}
extern "C" __device__ size_t __ockl_get_local_id(unsigned dim)
{
    return dim == 0 ? __builtin_amdgcn_workitem_id_x()
         : dim == 1 ? __builtin_amdgcn_workitem_id_y()
         : dim == 2 ? __builtin_amdgcn_workitem_id_z() : 0;
}
extern "C" __device__ float __ocml_exp_f32(float x) { return __builtin_expf(x); }

// Code object v5 keeps the grid's block counts (u32, from offset 0) and the workgroup sizes (u16,
// from offset 12) in the hidden kernel arguments; the kernels launch uniform workgroups.
extern "C" __device__ size_t __ockl_get_num_groups(unsigned dim)
{
    const unsigned *block_count = (const unsigned *)__builtin_amdgcn_implicitarg_ptr();
    return dim < 3 ? block_count[dim] : 1;
}
extern "C" __device__ size_t __ockl_get_local_size(unsigned dim)
{
    const unsigned short *group_size =
        (const unsigned short *)((const char *)__builtin_amdgcn_implicitarg_ptr() + 12);
    return dim < 3 ? group_size[dim] : 1;
}
// ockl's wfaall: whether `x` is nonzero in every active lane of the wave.
extern "C" __device__ bool __ockl_wfall_i32(int x)
{
    return __builtin_amdgcn_ballot_w64(x != 0) == __builtin_amdgcn_read_exec();
}
