// SDWA instructions reading one 16-bit half of `p = (a, b)` and all of their second source. A
// bf16 half is the low half of a word whose high half is zero; masking it within 16 bits keeps a
// bit field, whose exponent test folds for a real. Output `k` holds `out[64k + i]`.
__kernel void sdwa_ops(__global const float *a, __global const float *b,
                       __global const float *c, __global const float *d,
                       __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], z = c[i];
    unsigned p, q, r, s;
    float h[5];
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %0, %2, %3\n\t"
        "v_cvt_pk_bf16_f32 %1, %4, %5"
        : "=&v"(p), "=&v"(q) : "v"(x), "v"(b[i]), "v"(z), "v"(d[i]));
    // `p`'s high half: `b`.
    __asm__ volatile(
        "v_and_b32_sdwa %0, %1, %2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD\n\t"
        "v_lshlrev_b32_e32 %0, 16, %0"
        : "=&v"(h[0]) : "v"(p), "v"(0xffffu));
    // `b`'s exponent is not all ones: `a`.
    __asm__ volatile(
        "v_and_b32_sdwa %1, %2, %3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD\n\t"
        "v_cmp_ne_u32_e32 vcc, 0x7f80, %1\n\t"
        "v_cndmask_b32_e32 %0, %5, %4, vcc"
        : "=&v"(h[1]), "=&v"(r) : "v"(p), "v"(0x7f80u), "v"(x), "v"(z) : "vcc");
    // `a <= c ? q : (a, 0)`: `(max(a, c), a <= c ? d : 0)`.
    __asm__ volatile(
        "v_cmp_le_f32_e32 vcc, %1, %2\n\t"
        "v_cndmask_b32_sdwa %0, %3, %4, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD"
        : "=v"(s) : "v"(x), "v"(z), "v"(p), "v"(q) : "vcc");
    __asm__ volatile(
        "v_lshlrev_b32_e32 %0, 16, %2\n\t"
        "v_and_b32_e32 %1, 0xffff0000, %2"
        : "=&v"(h[2]), "=&v"(h[3]) : "v"(s));
    // A concrete word's half is its bits: `0x3f80` from `0x3f800000`, bf16 1.0, so `1`.
    __asm__ volatile(
        "v_and_b32_sdwa %0, %1, %2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD\n\t"
        "v_lshlrev_b32_e32 %0, 16, %0"
        : "=&v"(h[4]) : "v"(0x3f800000u), "v"(0xffffu));
    for (int k = 0; k < 5; ++k)
        out[64 * k + i] = h[k];
}
