// Composable Kernel's fp32 universal GEMM, DeviceGemm_Xdl_CShuffleV3 (rocm-7.0.0), at M = N = K = 256
// with ACTIVATION, a C element-wise operation, fused into its CShuffle epilogue. The 64 x 256 block
// tile spans whole rows of C, so workgroup 0, the one Volta runs, writes rows 0..64 of C and the
// launch file's C array is that tile. extract.py compiles one kernel per activation:
//   clang++ -x hip ... -DACTIVATION=<type> -S gemm.hip -o <case>.s
#define CK_ENABLE_DYNAMIC_WARP_SIZE 1
// CK 7.0.0's device_gemm_xdl_cshuffle_v3.hpp uses std::map and std::string without including them.
#include <map>
#include <string>
#include "ck/tensor_operation/gpu/device/impl/device_gemm_xdl_cshuffle_v3.hpp"
#include "ocml.hpp"
#include "activations.hpp"

#ifndef ACTIVATION
#error "compile with -DACTIVATION=<C element-wise operation type>"
#endif

template <ck::index_t... Is>
using S = ck::Sequence<Is...>;
using Row = ck::tensor_layout::gemm::RowMajor;
using Col = ck::tensor_layout::gemm::ColumnMajor;
using PassThrough = ck::tensor_operation::element_wise::PassThrough;
using CElementOp = ACTIVATION;

// A 256-thread block computes a 64 x 256 tile with 16 x 16 x 4 fp32 MFMAs (the instruction Volta
// models): 2 x 8 XDL tiles per wave over 2 x 2 waves, 32 of K per LDS stage.
// clang-format off
using DeviceGemm =
    ck::tensor_operation::device::DeviceGemm_Xdl_CShuffleV3<
        Row, Col, Row,
        float, float, float, float, float,
        PassThrough, PassThrough, CElementOp,
        ck::tensor_operation::device::GemmSpecialization::Default,
        256,
        64, 256,
        32, 4, 4,
        16, 16,
        2, 8,
        S<8, 32, 1>, S<1, 0, 2>, S<1, 0, 2>,
        2, 4, 4, 0,
        S<8, 32, 1>, S<1, 0, 2>, S<1, 0, 2>,
        2, 4, 4, 0,
        2, 4, S<1, 32, 1, 8>, 4,
        ck::BlockGemmPipelineScheduler::Intrawave, ck::BlockGemmPipelineVersion::v3>;
// clang-format on

// K = 256 is eight 32-wide K blocks: a main loop of seven and a full tail.
using GridwiseGemm = DeviceGemm::GridwiseGemm;
static_assert(GridwiseGemm::CalculateHasMainKBlockLoop(256));
static_assert(GridwiseGemm::CalculateKBlockLoopTailNum(256) == ck::TailNumber::Full);
template __global__ void ck::kernel_gemm_xdl_cshuffle_v3<GridwiseGemm, true, ck::InMemoryDataOperationEnum::Set, 1, ck::TailNumber::Full>(GridwiseGemm::Argument);

// The C operation's size and alignment, for extract.py's launch file: the kernel argument carries
// the operation by value, so its bytes follow Problem's fields.
extern "C" {
__device__ __constant__ int c_element_op_size = sizeof(CElementOp);
__device__ __constant__ int c_element_op_align = alignof(CElementOp);
}

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
