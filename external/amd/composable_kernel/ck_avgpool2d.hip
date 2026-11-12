// Composable Kernel's fp32 average pooling 2D (rocm-7.0.0): the first DevicePool2dFwd_NHWC_NHWC
// entry of CK's pool2d_fwd instance list, with the types its fp32 average-pooling instances use.
// Each of 256 work-items sums one output element's window and divides by the window size.
#include "ck/tensor_operation/gpu/device/impl/device_pool2d_fwd_nhwc_nhwc.hpp"

// Input, output, index and compute types, the average reduction without output indices, then
// the block size, the M and K thread cluster sizes, the M and K thread slice sizes and the
// vector size.
using DevicePool = ck::tensor_operation::device::DevicePool2dFwd_NHWC_NHWC<
    float, float, int32_t, float, ck::ReduceTensorOp::AVG, false, 256, 256, 1, 1, 1, 1>;

// The threadwise reduction that DevicePool's Invoker::Run launches: it sets its outputs, does
// not propagate NaN, and vectorizes along M, where the channel dimension lies.
using GridwiseReduce = ck::GridwiseReduction_mk_to_m_threadwise<
    float, float, float, int32_t,
    DevicePool::AGridDesc_M_K, DevicePool::BGridDesc_M,
    DevicePool::ReduceOperation,
    DevicePool::InElementwiseOperation, DevicePool::AccElementwiseOperation,
    ck::InMemoryDataOperationEnum::Set, false, 256, 1, 1, 0, 1, 1>;

// Instantiate the device entry as Invoker::Run does: no output index, window indices made
// global, no index input. The tensor shapes, window, strides, dilations and pads come from the
// two descriptor arguments.
template __global__ void ck::kernel_reduce_threadwise<
    GridwiseReduce, false, true, false, float, float, float, int32_t,
    DevicePool::AGridDesc_M_K, DevicePool::BGridDesc_M,
    DevicePool::InElementwiseOperation, DevicePool::AccElementwiseOperation>(
    DevicePool::AGridDesc_M_K, DevicePool::BGridDesc_M,
    DevicePool::InElementwiseOperation, DevicePool::AccElementwiseOperation,
    float, const float*, const int32_t*, float, float*, int32_t*);

// The ROCm device library's definitions (ockl's workitem.cl and mul.cl), linked by hipcc.
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
extern "C" __device__ unsigned __ockl_mul_hi_u32(unsigned a, unsigned b)
{
    return static_cast<unsigned>((static_cast<unsigned long long>(a) * b) >> 32);
}
