// CK Tile's one-pass forward RMSNorm (fc2862d712) in the block-per-row shape that
// example/ck_tile/10_rmsnorm2d/generate.py lists under row length 1,024, with fp32 data:
// four waves reduce one row together. No fused add, quantization or saved inverse RMS.
#include "ck_tile/core.hpp"
#include "ck_tile/host/kernel_launch.hpp"
#include "ck_tile/ops/epilogue.hpp"
#include "ck_tile/ops/rmsnorm2d.hpp"

// One row of 1,024 elements per block and 256 work-items along it, each handling four single
// elements: Repeat_N = 4 and Vector_N = 1 in the generator's terms.
using Shape = ck_tile::Generic2dBlockShape<
    ck_tile::sequence<1, 1024>, ck_tile::sequence<1, 256>, ck_tile::sequence<1, 1>>;

// Padding along the row; no saved inverse RMS or unquantized output, one pass, no fused add or
// quantization, and no model-specific variant.
using Traits = ck_tile::Rmsnorm2dFwdTraits<
    true, false, false, false,
    ck_tile::Rmsnorm2dFusedAddEnum::NO_ADD,
    ck_tile::Rmsnorm2dFusedQuantEnum::NO_SWEEP,
    ck_tile::Rmsnorm2dSensitiveEnum::NO_SPECIFIC_MODEL>;

// X, gamma, compute, Y and inverse-RMS types, then the three types only quantization uses.
using Problem = ck_tile::Rmsnorm2dFwdPipelineProblem<
    float, float, float, float, float, float, float, float, Shape, Traits>;
// The row spans four waves, so their sums of squares cross waves through LDS.
static_assert(Shape::WarpPerBlock_N == 4 && Problem::kNeedCrossWarpSync);
using Pipeline = ck_tile::Rmsnorm2dFwdPipelineOnePass<Problem>;
// Stores the normalized row with the row's padding, as the generator's default epilogue does.
using Epilogue = ck_tile::Default2DEpilogue<
    ck_tile::Default2DEpilogueProblem<float, float, false, true, false>>;
using Kernel = ck_tile::Rmsnorm2dFwd<Pipeline, Epilogue>;

// Instantiate the device entry make_kernel<1> launches; the row count and length, the row
// strides and epsilon come from Kargs.
template __global__ void ck_tile::kentry<1, Kernel, Kernel::Kargs>(Kernel::Kargs);

// ROCm 7.0.0's ocml definition of rsqrtf (rsqrtF.cl) when denormals are flushed, as this
// fixture is compiled: the instruction alone. hipcc links it from the device library.
extern "C" __device__ float __ocml_rsqrt_f32(float x)
{
    return __builtin_amdgcn_rsqf(x);
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
