// CK Tile's FastGeluAsm (5a74dec, the pin of ROCm/composable_kernel#3763) on one fp32 element
// per work-item of one workgroup, as the issue's ec_check.hip applies it. Its inline asm's scratch
// `tmp` is not earlyclobber, so from -O1 up the register allocator may give it an input's register.
#include "ck_tile/core.hpp"
#include "ck_tile/ops/elementwise/unary_element_wise_operation.hpp"

extern "C" __global__ void ck_fast_gelu_asm(const float* x, float* y)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    ck_tile::element_wise::FastGeluAsm{}.template operator()<float, float>(out, x[i]);
    y[i] = out;
}

// The issue's suggested fix: the same asm with its scratch operand write-only and earlyclobber.
struct FastGeluAsmFixed
{
    __device__ void operator()(float& y, const float& x) const
    {
        const uint32_t c1     = 0xbd92220c; // -2.0 * 0.035677f;
        const float c2        = -2.0 * 0.797885f;
        const uint32_t log2e_ = 0x3fb8aa3b; // log2e_v<float>;
        float tmp;

        asm volatile("v_mul_f32 %[v_tmp], %[v_x], %[v_x]        ; x*x\n"
                     "v_fma_f32 %[v_tmp], %[v_tmp], %[s_c1], %[v_c2]  ; c1*x*x+c2\n"
                     "v_mul_f32 %[v_tmp], %[v_tmp], %[v_x]      ; x*(c1*x*x+c2)\n"
                     "v_mul_f32 %[v_tmp], %[v_tmp], %[s_log2e]  ; log2e*x*(c1*x*x+c2)\n"
                     "v_exp_f32 %[v_tmp], %[v_tmp]              ; emu = exp2(log2e*x*(c1*x*x+c2))\n"
                     "s_nop 0                                   ; hazard for exp\n"
                     "v_add_f32 %[v_tmp], %[v_tmp], 1.0         ; emu+1.0f\n"
                     "v_rcp_f32 %[v_tmp], %[v_tmp]              ; 1/(emu+1.0f)\n"
                     "s_nop 0                                   ; hazard for rcp \n"
                     "v_mul_f32 %[v_y], %[v_tmp], %[v_x]        ; x * 1/(emu+1f)\n"
                     : [v_y] "=v"(y), [v_tmp] "=&v"(tmp)
                     : [v_x] "v"(x), [s_c1] "s"(c1), [v_c2] "v"(c2), [s_log2e] "s"(log2e_)
                     :);
    }
};

extern "C" __global__ void ck_fast_gelu_asm_fixed(const float* x, float* y)
{
    const unsigned i = __builtin_amdgcn_workitem_id_x();
    float out;
    FastGeluAsmFixed{}(out, x[i]);
    y[i] = out;
}
