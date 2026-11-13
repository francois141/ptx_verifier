// Legacy CK's ck::math::cos<double> (5a74dec, ck/utility/math_v2.hpp:970), written
// `return cos(x);`: unqualified lookup finds the specialization itself, not HIP's ::cos(double).
// The recursion is UB, so the compiler deletes the kernel's store.
#include "ck/utility/math_v2.hpp"

// The spec language has no cos, so the kernel takes a scalar x for its launch to give as 0.
extern "C" __global__ void ck_math_cos_double(float x, float* y)
{
    y[__builtin_amdgcn_workitem_id_x()] = static_cast<float>(ck::math::cos(static_cast<double>(x)));
}
