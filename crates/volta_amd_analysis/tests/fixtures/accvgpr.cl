// Each work-item moves its element of `a` into AGPR a0 and stores it from there to `out`, then
// moves it back into a VGPR and stores it to `back`. Inline assembly emits the moves, which
// Clang otherwise generates only around MFMA instructions.
__kernel void accvgpr(__global const float *a, __global float *out, __global float *back) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float acc, x;
    __asm__ volatile("v_accvgpr_write_b32 %0, %1" : "=a"(acc) : "v"(a[i]));
    out[i] = acc;
    __asm__ volatile("v_accvgpr_read_b32 %0, %1" : "=v"(x) : "a"(acc));
    back[i] = x;
}
