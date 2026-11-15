// CK Tile's ImageToColumn (5a74dec) on a 4 x 4 image with C = 3 channels and vectors of 4. Each
// thread copies 4 consecutive elements as one vector, which straddles two pixels when C is not a
// multiple of 4; nothing rejects such a C, so columns that wrap to the next window row get the
// wrong pixel's channels.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/image_to_column.hpp"

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

// The report's instance: one wave, each thread a 4 x 4 piece of the [M, K] columns, vectors of 4.
using Shape  = TileImageToColumnShape<sequence<4, 4>, sequence<64, 16>, sequence<64, 16>>;
using Kernel = ImageToColumn<BlockImageToColumnProblem<float, float, Shape, 2, 4, 4>>;

// One NHWGC image (N = G = 1) of 4 x 4 pixels and 3 channels, a 2 x 2 window, stride 1, no
// padding: 3 x 3 output pixels, so the columns are [M, K] = [9, 12].
extern "C" __global__ void ck_img2col(const float* image, float* columns)
{
    Kernel::Kargs kargs{image,    columns,  1,        1,        3,        {4, 4},  {2, 2},
                        {3, 3},   {3, 48, 1, 12, 3},  {108, 12, 1},       {1, 1},  {1, 1},
                        {0, 0},   {0, 0}};
    Kernel{}(kargs);
}
