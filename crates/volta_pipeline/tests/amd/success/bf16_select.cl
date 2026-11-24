// Selects between `p = (a, b)` and `q = (c, d)` under a condition on the inputs select each
// half; a condition ordering the halves it selects between gives their max or min. Output `k`
// holds `out[64k + i]`.
__kernel void bf16_select(__global const float *a, __global const float *b,
                          __global const float *c, __global const float *d,
                          __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], z = c[i];
    unsigned p, q, r, s;
    float h[6];
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %0, %2, %3\n\t"
        "v_cvt_pk_bf16_f32 %1, %4, %5"
        : "=&v"(p), "=&v"(q) : "v"(x), "v"(b[i]), "v"(z), "v"(d[i]));
    // `a <= c ? q : p`: `(max(a, c), a <= c ? d : b)`.
    __asm__ volatile(
        "v_cmp_le_f32_e32 vcc, %1, %2\n\t"
        "v_cndmask_b32_e32 %0, %3, %4, vcc"
        : "=v"(r) : "v"(x), "v"(z), "v"(p), "v"(q) : "vcc");
    // `a > c ? q : p` through an SGPR mask: `(min(a, c), a > c ? d : b)`.
    __asm__ volatile(
        "v_cmp_gt_f32_e64 s[4:5], %1, %2\n\t"
        "v_cndmask_b32_e64 %0, %3, %4, s[4:5]"
        : "=v"(s) : "v"(x), "v"(z), "v"(p), "v"(q) : "s4", "s5");
    // A pair against a concrete word, bf16 `(1, 2)`: `(a <= c ? 1 : a, a <= c ? 2 : b)`.
    unsigned t;
    __asm__ volatile(
        "v_cmp_le_f32_e32 vcc, %1, %2\n\t"
        "v_cndmask_b32_e32 %0, %3, %4, vcc"
        : "=v"(t) : "v"(x), "v"(z), "v"(p), "v"(0x40003f80u) : "vcc");
    unsigned words[3] = {r, s, t};
    for (int k = 0; k < 3; ++k)
        __asm__ volatile(
            "v_lshlrev_b32_e32 %0, 16, %2\n\t"
            "v_and_b32_e32 %1, 0xffff0000, %2"
            : "=&v"(h[2 * k]), "=&v"(h[2 * k + 1]) : "v"(words[k]));
    for (int k = 0; k < 6; ++k)
        out[64 * k + i] = h[k];
}
