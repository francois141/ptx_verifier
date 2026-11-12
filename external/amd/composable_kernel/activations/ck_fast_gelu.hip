// CK Tile's FastGelu (5a74dec), its C++ device path y = x * rcp(1 + exp(x * (c1 * x * x + c2)))
// with c1 = -2 * 0.035677f and c2 = -2 * 0.797885f, on one fp32 element per work-item.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/elementwise/unary_element_wise_operation.hpp"
#include "ocml.hpp"

extern "C" __global__ void ck_fast_gelu(const float* x, float* y)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    ck_tile::element_wise::FastGelu{}(out, x[i]);
    y[i] = out;
}
