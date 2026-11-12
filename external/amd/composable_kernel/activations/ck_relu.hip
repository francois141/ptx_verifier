// CK Tile's Relu (5a74dec), y = x > 0 ? x : 0, on one fp32 element per work-item.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/elementwise/unary_element_wise_operation.hpp"

extern "C" __global__ void ck_relu(const float* x, float* y)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    ck_tile::element_wise::Relu{}(out, x[i]);
    y[i] = out;
}
