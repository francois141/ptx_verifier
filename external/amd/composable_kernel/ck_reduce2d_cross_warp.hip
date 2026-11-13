// CK Tile's ReduceKernel (5a74dec) summing each row of x[16, 16], with two waves along each row
// and 16 rows per wave. BlockReduce2dCrossWarpSync shares only lane 0's partial (row 0's) through
// LDS, so every row's output is row 0's sum.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/reduce.hpp"

// hipcc links these from ROCm's device library (ockl); a 1-D launch has only x ids.
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

// Two waves along a row, each holding 16 rows x 8 columns.
using Shape   = Reduce2dShape<sequence<1, 2>, sequence<16, 16>, sequence<16, 8>, sequence<1, 2>>;
using Problem = Reduce2dProblem<float, float, float, Shape, ReduceOp::Add, sequence<0>,
                                sequence<1>, 2>;

extern "C" __global__ void ck_reduce2d_cross_warp(const float* x, float* y)
{
    ReduceKernel<Problem>{}(x, y, make_tuple(number<16>{}, number<16>{}),
                            make_tuple(number<16>{}, number<1>{}));
}
