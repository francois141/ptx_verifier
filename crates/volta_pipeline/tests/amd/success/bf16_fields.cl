// A mask within a bf16 pair's low half keeps a bit field of that half. The exponent field of a
// real is never all ones, so `p = (a, b)`'s low half is finite: `out[i]` takes `a`, and the
// inverted test makes `out[64 + i]` take `b`.
__kernel void bf16_fields(__global const float *a, __global const float *b,
                          __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], y = b[i], finite, infinite;
    unsigned p, exponent;
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %2, %4, %5\n\t"
        "v_and_b32_e32 %3, 0x7f80, %2\n\t"
        "v_cmp_ne_u32_e32 vcc, 0x7f80, %3\n\t"
        "v_cndmask_b32_e32 %0, %5, %4, vcc\n\t"
        "v_cmp_eq_u32_e32 vcc, 0x7f80, %3\n\t"
        "v_cndmask_b32_e32 %1, %5, %4, vcc"
        : "=&v"(finite), "=&v"(infinite), "=&v"(p), "=&v"(exponent)
        : "v"(x), "v"(y)
        : "vcc");
    out[i] = finite;
    out[64 + i] = infinite;
}
