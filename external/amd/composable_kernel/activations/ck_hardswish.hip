// CK's AddHardswish (5a74dec), the only Hardswish CK defines: a = x0 + x1, then
// y = (a + 3 > 0) * min(a + 3, 6) * a * 0.166667f, on one fp32 element pair per work-item.
#include "ck/tensor_operation/gpu/element/binary_element_wise_operation.hpp"

extern "C" __global__ void ck_hardswish(const float* x0, const float* x1, float* y)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    ck::tensor_operation::element_wise::AddHardswish{}.template operator()<float>(out, x0[i], x1[i]);
    y[i] = out;
}
