// CK pin 5a74dec07a894484b9489d0c0e00cd3b52652d18.
// Launch 64 work-items. Each clamps 300: expected 300; CK produces 44.
// Store the integer result as float for Volta's real-valued specification.
#include "ck/utility/amd_inline_asm.hpp"
#include "ck/tensor_operation/gpu/element/unary_element_wise_operation.hpp"

// CK constructs Clamp on the host and passes it to the device by value.
extern "C" __global__ void ck_clamp(float* out,
                                  ck::tensor_operation::element_wise::Clamp clamp)
{
    const int x = 300;
    int y;
    clamp(y, x);
    out[__builtin_amdgcn_workitem_id_x()] = y;
}

// Control: the same overload's body with int8_t replaced by int.
extern "C" __global__ void ck_clamp_fixed(float* out,
                                        ck::tensor_operation::element_wise::Clamp clamp)
{
    const int x = 300;
    const int& a = x;
    const int y = a > clamp.floor_ ? (a < clamp.ceil_ ? a : clamp.ceil_) : clamp.floor_;
    out[__builtin_amdgcn_workitem_id_x()] = y;
}
