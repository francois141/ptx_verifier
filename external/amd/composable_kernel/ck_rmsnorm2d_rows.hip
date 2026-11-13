// CK Tile's one-pass forward RMSNorm (5a74dec) with rows of 64 fp32 elements, 4 rows per block and
// 16 threads per row. Generic2dBlockShape counts each 16-lane group as a wave, so the block has 256
// threads instead of 64 and wave w computes rows w..w+3: workgroup 0 writes rows 0-6, not 0-3.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/epilogue.hpp"
#include "ck_tile/ops/rmsnorm2d.hpp"

// hipcc links these from ROCm's device library (ocml, ockl); a 1-D launch has only x ids.
extern "C" __device__ float __ocml_rsqrt_f32(float x) { return __builtin_amdgcn_rsqf(x); }
extern "C" __device__ size_t __ockl_get_group_id(unsigned d)
{
    return d == 0 ? __builtin_amdgcn_workgroup_id_x() : 0;
}
extern "C" __device__ size_t __ockl_get_local_id(unsigned d)
{
    return d == 0 ? __builtin_amdgcn_workitem_id_x() : 0;
}
extern "C" __device__ unsigned __ockl_mul_hi_u32(unsigned a, unsigned b)
{
    return (1ull * a * b) >> 32;
}

using namespace ck_tile;

// The rmsnorm2d generator's tm=4, tn=16, vn=4 instance: a 4 x 64 block tile, 4 x 16 threads.
using Shape  = Generic2dBlockShape<sequence<4, 64>, sequence<4, 16>, sequence<1, 4>>;
using Traits = Rmsnorm2dFwdTraits<true, false, false, false, Rmsnorm2dFusedAddEnum::NO_ADD,
                                  Rmsnorm2dFusedQuantEnum::NO_SWEEP,
                                  Rmsnorm2dSensitiveEnum::NO_SPECIFIC_MODEL>;
using Kernel = Rmsnorm2dFwd<
    Rmsnorm2dFwdPipelineOnePass<Rmsnorm2dFwdPipelineProblem<float, float, float, float, float,
                                                            float, float, float, Shape, Traits>>,
    Default2DEpilogue<Default2DEpilogueProblem<float, float, false, true, false>>>;

extern "C" __global__ void ck_rmsnorm2d_rows(Kernel::Kargs kargs) { Kernel{}(kargs); }
