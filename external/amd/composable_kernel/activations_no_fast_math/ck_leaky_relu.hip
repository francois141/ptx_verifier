// CK Tile's LeakyRelu (5a74dec), y = x >= 0 ? x : alpha * x, on one fp32 element per work-item.
// CK constructs the op on the host and passes it to the device by value.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/elementwise/unary_element_wise_operation.hpp"

extern "C" __global__ void ck_leaky_relu(const float* x, float* y, ck_tile::element_wise::LeakyRelu op)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    op(out, x[i]);
    y[i] = out;
}
