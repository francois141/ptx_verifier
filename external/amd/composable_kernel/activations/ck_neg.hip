// CK Tile's Neg (5a74dec), y = -x, on one fp32 element per work-item.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/elementwise/unary_element_wise_operation.hpp"

extern "C" __global__ void ck_neg(const float* x, float* y)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    ck_tile::element_wise::Neg{}(out, x[i]);
    y[i] = out;
}
