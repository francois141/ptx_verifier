// CK's i4_to_f8x4 (5a74dec) on the packed int4 word `q`, in every work-item. It masks the high
// nibbles without shifting them down, and v_cvt_off_f32_i4 reads bits 3:0, so its last two fp8
// values are always zero. Each fp8 code is stored as a float, for the spec to state.
#include "ck/utility/amd_inline_asm.hpp"
#include "ck/tensor_operation/gpu/element/unary_element_wise_operation.hpp"

__device__ void store_codes(unsigned codes, float* b0, float* b1, float* b2, float* b3)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    b0[i] = codes & 0xff;
    b1[i] = (codes >> 8) & 0xff;
    b2[i] = (codes >> 16) & 0xff;
    b3[i] = codes >> 24;
}

extern "C" __global__ void ck_i4_to_f8x4(int q, float* b0, float* b1, float* b2, float* b3)
{
    store_codes(ck::bit_cast<unsigned>(ck::i4_to_f8x4(q)), b0, b1, b2, b3);
}

// The conversion it is named for, the low word of CK's amd_assembly_i4_to_fp8x8: nibbles 0, 4,
// 1 and 5, each sext(n) / 16, the high ones shifted down first and packed by clang's builtin.
extern "C" __global__ void ck_i4_to_f8x4_fixed(int q, float* b0, float* b1, float* b2, float* b3)
{
    const int lo = q & 0x000f000f;
    const int hi = (q & 0x00f000f0) >> 4;
    const float f32_0 = ck::amd_assemble_cvt_f32_i4(lo);
    const float f32_1 = ck::amd_assemble_cvt_f32_i4(lo >> 16);
    const float f32_2 = ck::amd_assemble_cvt_f32_i4(hi);
    const float f32_3 = ck::amd_assemble_cvt_f32_i4(hi >> 16);
    int codes = __builtin_amdgcn_cvt_pk_fp8_f32(f32_0, f32_1, 0, false);
    codes     = __builtin_amdgcn_cvt_pk_fp8_f32(f32_2, f32_3, codes, true);
    store_codes(static_cast<unsigned>(codes), b0, b1, b2, b3);
}
