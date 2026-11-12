// CK Tile's Logistic (5a74dec), y = alpha / (1 + exp(-x) * alpha), on one fp32 element per
// work-item. CK constructs the op on the host and passes it to the device by value.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/elementwise/unary_element_wise_operation.hpp"
#include "ocml.hpp"

extern "C" __global__ void ck_logistic(const float* x, float* y, ck_tile::element_wise::Logistic op)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    op(out, x[i]);
    y[i] = out;
}
