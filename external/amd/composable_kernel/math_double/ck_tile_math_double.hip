// CK Tile's ck_tile::exp<double> (5a74dec, ck_tile/core/numeric/math_v2.hpp:889), written
// `return exp(x);`: unqualified lookup finds the specialization itself, not HIP's ::exp(double).
// The recursion is UB, so the compiler deletes the kernel's store.
#include "ck_tile/core.hpp"

extern "C" __global__ void ck_tile_exp_double(const float* x, float* y)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    y[i]             = static_cast<float>(ck_tile::exp(static_cast<double>(x[i])));
}
