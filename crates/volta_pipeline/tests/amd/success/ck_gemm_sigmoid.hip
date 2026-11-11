// ck_gemm.hip's fp32 GEMM (CK rocm-7.0.0) with CK's Sigmoid, 1 / (1 + exp(-c)), as its C element
// op, so the epilogue applies it to each accumulator before the store. Built with -ffast-math,
// which lowers exp to v_exp_f32 with an underflow rescale and the division to v_rcp_f32.
#define CK_ENABLE_DYNAMIC_WARP_SIZE 1
// CK 7.0.0's device_gemm_xdl_cshuffle_v3.hpp uses std::map and std::string without including them.
#include <map>
#include <string>
#include "ck/tensor_operation/gpu/device/impl/device_gemm_xdl_cshuffle_v3.hpp"

template <ck::index_t... Is>
using S = ck::Sequence<Is...>;
using Row = ck::tensor_layout::gemm::RowMajor;
using Col = ck::tensor_layout::gemm::ColumnMajor;
using PassThrough = ck::tensor_operation::element_wise::PassThrough;
using Sigmoid = ck::tensor_operation::element_wise::Sigmoid;

// clang-format off
using DeviceGemm =
    ck::tensor_operation::device::DeviceGemm_Xdl_CShuffleV3<
        Row, Col, Row,
        float, float, float, float, float,
        PassThrough, PassThrough, Sigmoid,
        ck::tensor_operation::device::GemmSpecialization::MNKPadding,
        128,
        64, 64,
        64, 4, 4,
        16, 16,
        2, 4,
        S<4, 32, 1>, S<1, 0, 2>, S<1, 0, 2>,
        2, 2, 2, 0,
        S<4, 32, 1>, S<1, 0, 2>, S<1, 0, 2>,
        2, 2, 2, 0,
        1, 2, S<1, 32, 1, 4>, 2,
        ck::BlockGemmPipelineScheduler::Intrawave, ck::BlockGemmPipelineVersion::v3>;
// clang-format on

// An 8 x 8 x 8 problem padded to one K block: no main loop and a full tail.
using GridwiseGemm = DeviceGemm::GridwiseGemm;
template __global__ void ck::kernel_gemm_xdl_cshuffle_v3<GridwiseGemm, false, ck::InMemoryDataOperationEnum::Set, 1, ck::TailNumber::Full>(GridwiseGemm::Argument);

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
