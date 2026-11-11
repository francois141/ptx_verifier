// Copy symbolic VGPR and SGPR sources and inline constants into AGPRs, then store them.
// Read the VGPR copy back through an accumulator read as well. Inline assembly retains
// each source form instead of letting Clang replace the copies.
__kernel void accvgpr(__global const float *a, __global float *out, __global float *back) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float value = a[i];
    unsigned scalar = (unsigned)__builtin_amdgcn_readfirstlane(as_uint(value));
    float acc, scalar_acc, zero, one, x;
    __asm__ volatile("v_accvgpr_write_b32 %0, %1" : "=a"(acc) : "v"(value));
    __asm__ volatile("v_accvgpr_write_b32 %0, %1" : "=a"(scalar_acc) : "s"(scalar));
    __asm__ volatile("v_accvgpr_write_b32 %0, 0" : "=a"(zero));
    __asm__ volatile("v_accvgpr_write_b32 %0, 1.0" : "=a"(one));
    out[i] = acc;
    out[i + 64] = scalar_acc;
    out[i + 128] = zero;
    out[i + 192] = one;
    __asm__ volatile("v_accvgpr_read_b32 %0, %1" : "=v"(x) : "a"(acc));
    back[i] = x;
}
